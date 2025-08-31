extends Node

# Carichiamo le scene dei nemici che possiamo spawnare
@export var base_enemy_scene: PackedScene
@export var spitfire_enemy_scene: PackedScene
@export var strafer_enemy_scene: PackedScene

var enemies_remains = 0
var wave_in_live = false

func _ready():
	# Inizia la prima ondata all'avvio
	start_next_wave()

func start_next_wave():
	if GameManager.current_wave >= GameManager.LEVEL_1_1.size():
		print("LEVEL COMPLETE!")
		return # Abbiamo finito le ondate

	wave_in_live = true
	var wave_data = GameManager.LEVEL_1_1[GameManager.current_wave]

	enemies_remains = wave_data["number"]

	var enemy_type = wave_data["type"]
	var enemy_wait = wave_data["wait"]

	var scene_to_spawn
	if enemy_type == "base":
		scene_to_spawn = base_enemy_scene
	elif enemy_type == "enemy_spitfire":
		scene_to_spawn = spitfire_enemy_scene
	elif enemy_type == "enemy_strafer":
		scene_to_spawn = strafer_enemy_scene

	# Usiamo un timer per spawnare i nemici in sequenza
	var spawn_timer = get_tree().create_timer(enemy_wait)
	var counter = 0
	while counter < enemies_remains:
		await spawn_timer.timeout
		enemy_spawn(scene_to_spawn)
		counter += 1
		spawn_timer = get_tree().create_timer(enemy_wait)

func enemy_spawn(scene_to_spawn):
	if not scene_to_spawn: return
	var new_enemy = scene_to_spawn.instantiate()

	# Colleghiamo un segnale per sapere quando il nemico muore
	new_enemy.enemy_destroyed.connect(on_nemico_destroy)

	var screen_width = get_viewport().size.x
	var spawn_x = randf_range(50, screen_width - 50)
	new_enemy.position = Vector2(spawn_x, -50)

	get_parent().add_child(new_enemy)

func on_nemico_destroy():
	enemies_remains -= 1
	if enemies_remains <= 0 and wave_in_live:
		wave_in_live = false
		GameManager.current_wave += 1
		# Aspettiamo 3 secondi prima di lanciare la prossima ondata
		await get_tree().create_timer(3.0).timeout
		start_next_wave()
