extends Node

# Carichiamo le scene dei nemici che possiamo spawnare
@export var start_level_scene: PackedScene
@export var level_completed_scene: PackedScene
@export var base_enemy_scene: PackedScene
@export var spitfire_enemy_scene: PackedScene
@export var strafer_enemy_scene: PackedScene
@export var orbital_enemy_scene: PackedScene
@export var sniper_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var boss_entering_scene: PackedScene
@export var boss_defated_scene: PackedScene
@export var powerup_scenes: Array[PackedScene]

@export var level_music: AudioStreamPlayer
@export var boss_music: AudioStreamPlayer

var LEVEL_ENEMY_WAVES = []

@export var level_tag = "0.0"

var enemies_remains = 0
var wave_in_live = false
var spawn_completed = false

func _ready():
	GameManager.current_level = level_tag
	# Inizia la prima ondata all'avvio
	var scena_giocatore = GameManager.GIOCATORI_DISPONIBILI[GameManager.giocatore_selezionato]
	var nuovo_giocatore = scena_giocatore.instantiate()
	
	# 2. Calcoliamo la posizione dinamicamente
	var screen_size = get_viewport().get_visible_rect().size
	var start_position = Vector2() # Creiamo un vettore di posizione vuoto
	
	# Impostiamo la X al centro esatto dello schermo
	start_position.x = screen_size.x / 2.0 
	
	# Impostiamo la Y in fondo allo schermo, con un margine di 100 pixel
	start_position.y = screen_size.y - 300
	
	# 3. Assegniamo la posizione calcolata al giocatore
	nuovo_giocatore.position = start_position
	
	nuovo_giocatore.giocatore_morto.connect(_on_giocatore_morto)
	
	# 4. Aggiungiamo il giocatore alla scena (invariato)
	get_parent().call_deferred("add_child", nuovo_giocatore)
	
	start_next_wave()
	level_music.play()

func _on_giocatore_morto():
	GameManager.reset_level()
	# Esegui qui la chiamata che ti dava problemi.
	# Ad esempio, per tornare al menu principale:
	get_tree().change_scene_to_file("res://menu_principale.tscn")

	# O per ricaricare semplicemente il livello:
	# get_tree().reload_current_scene()

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
		# Forzato a uscire su 1.2 per testare il giro completo
		if level_tag == "1.2":
			await get_tree().create_timer(2.0).timeout
			GameManager.end_game(false)
		return # Abbiamo finito le ondate

	wave_in_live = true
	spawn_completed = false
	var wave_data = LEVEL_ENEMY_WAVES[GameManager.current_wave]

	if wave_data.type == "scene" and wave_data.scene != "mission_complete" and wave_data.scene != "end_level01":	
		spawn_powerup()
	elif wave_data.type == "enemy":
		spawn_powerup()
	
	enemies_remains = 0
	
	# Get totale of enemies
	if wave_data.active and (wave_data.type == "enemy" or wave_data.type == "boss"):
		for enemy_data in wave_data.enemies:
			enemies_remains += enemy_data["number"]
	
		for enemy_data in wave_data.enemies:
			var enemies_number = enemy_data["number"]
			var enemy_type = enemy_data["type"]
			var enemy_wait = enemy_data["wait"]
			var is_boss = false

			var scene_to_spawn
			if enemy_type == "base":
				scene_to_spawn = base_enemy_scene
			elif enemy_type == "enemy_spitfire":
				scene_to_spawn = spitfire_enemy_scene
			elif enemy_type == "enemy_strafer":
				scene_to_spawn = strafer_enemy_scene
			elif enemy_type == "enemy_orbital":
				scene_to_spawn = orbital_enemy_scene
			elif enemy_type == "enemy_sniper":
				scene_to_spawn = sniper_enemy_scene
			elif enemy_type == "boss_eagleone":
				scene_to_spawn = boss_enemy_scene
				is_boss = true

			# Usiamo un timer per spawnare i nemici in sequenza
			var spawn_timer = get_tree().create_timer(enemy_wait, true, false, true)
			var counter = 0
			while counter < enemies_number:
				await spawn_timer.timeout
				if wave_data.type == "boss":
					level_music.stop()
					boss_music.play()
				enemy_spawn(scene_to_spawn, is_boss)
				counter += 1
				spawn_timer = get_tree().create_timer(enemy_wait, true, false, true)
		spawn_completed = true
	elif wave_data.active and wave_data.type == "scene":
		await get_tree().create_timer(wave_data.wait_before_start).timeout
		var scene_to_spawn
		if wave_data.scene == "boss_entering":
			scene_to_spawn = boss_entering_scene
		elif wave_data.scene == "mission_start":
			scene_to_spawn = start_level_scene
		elif wave_data.scene == "end_level01":
			scene_to_spawn = boss_defated_scene
		elif wave_data.scene == "mission_complete":
			level_music.stop()
			boss_music.stop()
			scene_to_spawn = level_completed_scene
		scene_spawn(scene_to_spawn)
		await get_tree().create_timer(wave_data.wait_before_end).timeout
		delete_scene(scene_to_spawn, wave_data.name)
		GameManager.current_wave += 1
		start_next_wave()
	elif not wave_data.active:
		wave_in_live = false
		GameManager.current_wave += 1
		start_next_wave()

func delete_scene(scene_to_spawn, name):
	for i in get_parent().get_child_count():
		var child = get_parent().get_child(i)
		if child != null and child.name == name:
			child.free()

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

func on_nemico_destroy():
	enemies_remains -= 1
	if enemies_remains <= 0 and wave_in_live and spawn_completed:
		wave_in_live = false
		GameManager.current_wave += 1
		# Aspettiamo 3 secondi prima di lanciare la prossima ondata
		await get_tree().create_timer(3.0).timeout
		start_next_wave()
