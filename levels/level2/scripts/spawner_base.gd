extends Node

# Carichiamo le scene dei nemici che possiamo spawnare
@export var start_level_scene: PackedScene
@export var extra_start_level_scene: PackedScene
@export var level_completed_scene: PackedScene
@export var chopter_dspitfire_scene: PackedScene
@export var chopter_dfollow_scene: PackedScene
@export var turret_enemy_scene: PackedScene
@export var chopter_darc_shooter_scene: PackedScene
@export var chopter_strafer_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var boss_entering_scene: PackedScene
@export var boss_defated_scene: PackedScene
@export var powerup_scenes: Array[PackedScene]

@export var level_music: AudioStreamPlayer
@export var boss_music: AudioStreamPlayer

var LEVEL_ENEMY_WAVES = []

@export var level_tag = "0.0"

var total_enemies = 0
var enemies_remains = 0
var wave_in_live = false
var spawn_completed = false

func manage_warning_scene(): # Esempio di funzione
	# 1. Calcola la posizione target per il giocatore
	var screen_width = get_viewport().get_visible_rect().size.x
	var screen_height = get_viewport().get_visible_rect().size.y
	var target_player_pos = Vector2(screen_width / 2, screen_height * 0.8) # Es. centro, 80% in basso

	# 2. Resetta la posizione del giocatore
	var riferimento_giocatore = get_tree().get_first_node_in_group("giocatore")
	if riferimento_giocatore:
		# Aspetta che il giocatore sia arrivato alla sua posizione
		await riferimento_giocatore.move_to_target_position(target_player_pos, 1.5)

func _ready():
	GameManager.current_level = level_tag
	# Inizia la prima ondata all'avvio
	var scena_giocatore = GameManager.GIOCATORI_DISPONIBILI[GameManager.giocatore_selezionato]
	var nuovo_giocatore = scena_giocatore.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	var start_position = Vector2() # Creiamo un vettore di posizione vuoto

	start_position.x = screen_size.x / 2.0 
	start_position.y = screen_size.y - 300
	nuovo_giocatore.position = start_position
	nuovo_giocatore.giocatore_morto.connect(_on_giocatore_morto)

	get_parent().call_deferred("add_child", nuovo_giocatore)
	
	start_next_wave()
	level_music.play()

func _on_giocatore_morto():
	GameManager.reset_level()
	get_tree().change_scene_to_file("res://menu_principale.tscn")

func spawn_powerup():
	if powerup_scenes.is_empty(): return
	
	var safe_area = 200

	var chosen_powerup_scene = powerup_scenes[randi() % powerup_scenes.size()]
	var powerup_instance = chosen_powerup_scene.instantiate()

	var screen_width = get_viewport().get_visible_rect().size.x
	var spawn_x = randf_range(safe_area, screen_width - safe_area)
	
	powerup_instance.position = Vector2(spawn_x, -100)
	
	get_parent().add_child(powerup_instance)

func start_next_wave():
	if GameManager.current_wave >= LEVEL_ENEMY_WAVES.size():
		# LEVEL COMPLETE STAGE
		GameManager.next_level(level_tag)
		GameManager.store_player_info()
		return # Abbiamo finito le ondate

	wave_in_live = true
	spawn_completed = false
	var wave_data = LEVEL_ENEMY_WAVES[GameManager.current_wave]

	if wave_data.type == "scene" and not "mission_" in wave_data.scene and not "end_" in wave_data.scene:	
		spawn_powerup()
	elif wave_data.type == "enemy":
		spawn_powerup()
	
	enemies_remains = 0
	total_enemies = 0
	
	# Get totale of enemies
	if wave_data.active and (wave_data.type == "enemy" or wave_data.type == "boss"):
		for enemy_data in wave_data.enemies:
			enemies_remains += enemy_data["number"]
		
		total_enemies = enemies_remains
		
		for enemy_data in wave_data.enemies:
			var enemies_number = enemy_data["number"]
			var enemy_type = enemy_data["type"]
			var enemy_wait = enemy_data["wait"]
			var is_boss = false

			var scene_to_spawn
			if enemy_type == "chopter_dspitfire":
				scene_to_spawn = chopter_dspitfire_scene
			elif enemy_type == "chopter_dfollow":
				scene_to_spawn = chopter_dfollow_scene
			elif enemy_type == "enemy_turret":
				scene_to_spawn = turret_enemy_scene
			elif enemy_type == "chopter_darc_shooter":
				scene_to_spawn = chopter_darc_shooter_scene
			elif enemy_type == "chopter_strafer":
				scene_to_spawn = chopter_strafer_scene
			elif enemy_type == "boss_eagleone":
				scene_to_spawn = boss_enemy_scene
				is_boss = true

			# Usiamo un timer per spawnare i nemici in sequenza
			var spawn_timer = get_tree().create_timer(enemy_wait, false, false, true)
			var counter = 0
			while counter < enemies_number:
				await spawn_timer.timeout
				if wave_data.type == "boss":
					level_music.stop()
					boss_music.play()
				if enemy_type == "enemy_turret":
					turret_spawn(scene_to_spawn, randi_range(1, 3))
				else:
					enemy_spawn(scene_to_spawn, is_boss)
				counter += 1
				spawn_timer = get_tree().create_timer(enemy_wait, false, false, true)
		spawn_completed = true
	elif wave_data.active and wave_data.type == "scene":
		await get_tree().create_timer(wave_data.wait_before_start, false).timeout
		var scene_to_spawn
		if wave_data.scene == "boss_entering":
			scene_to_spawn = boss_entering_scene
			manage_warning_scene()
		elif wave_data.scene == "mission_start":
			scene_to_spawn = start_level_scene
		elif wave_data.scene == "mission_explain":
			scene_to_spawn = extra_start_level_scene
		elif wave_data.scene == "end_level01":
			scene_to_spawn = boss_defated_scene
		elif wave_data.scene == "mission_complete":
			level_music.stop()
			boss_music.stop()
			scene_to_spawn = level_completed_scene
		scene_spawn(scene_to_spawn)
		await get_tree().create_timer(wave_data.wait_before_end, false).timeout
		delete_scene(wave_data.name)
		GameManager.current_wave += 1
		start_next_wave()
	elif not wave_data.active:
		wave_in_live = false
		GameManager.current_wave += 1
		start_next_wave()

func delete_scene(scene_name):
	for i in get_parent().get_child_count():
		var child = get_parent().get_child(i)
		if child != null and child.name == scene_name:
			child.free()

func turret_spawn(scene_to_spawn, screen_section):
	if not scene_to_spawn: return
	var middle_x = get_viewport().get_visible_rect().size.x / 2
	var static_y = -200
	var position = Vector2(200, static_y)
	if screen_section == 1:
		position = Vector2(middle_x - 200, static_y)
	elif screen_section == 3:
		position = Vector2(middle_x + 200, static_y)
	elif screen_section == 2:
		position = Vector2(middle_x, static_y)
	var turret_instance = scene_to_spawn.instantiate()
	turret_instance.position = position
	var sfondo = get_tree().get_first_node_in_group("sfondo")
	sfondo.add_child(turret_instance)
	await turret_instance.ready

func scene_spawn(scene_to_spawn):
	if not scene_to_spawn: return
	var scene = scene_to_spawn.instantiate()

	scene.size.x = get_viewport().get_visible_rect().size.x
	scene.size.y = get_viewport().get_visible_rect().size.y

	get_parent().add_child(scene)

func enemy_spawn(scene_to_spawn, is_boss):
	var safe_area = 100
	if not scene_to_spawn: return
	var new_enemy = scene_to_spawn.instantiate()

	# Colleghiamo un segnale per sapere quando il nemico muore
	new_enemy.enemy_destroyed.connect(on_nemico_destroy)

	var screen_width = get_viewport().get_visible_rect().size.x
	var spawn_x = screen_width / 2
	if is_boss == false:
		spawn_x = randf_range(safe_area, screen_width - safe_area)
	
	new_enemy.position = Vector2(spawn_x, -100)

	get_parent().add_child(new_enemy)
	await new_enemy.ready

func on_nemico_destroy():
	enemies_remains -= 1
	if enemies_remains <= 0 and wave_in_live and spawn_completed:
		wave_in_live = false
		GameManager.current_wave += 1
		# Aspettiamo 3 secondi prima di lanciare la prossima ondata
		await get_tree().create_timer(3.0, false).timeout
		start_next_wave()
