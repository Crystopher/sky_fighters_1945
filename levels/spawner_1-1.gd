extends Node

# Carichiamo le scene dei nemici che possiamo spawnare
@export var base_enemy_scene: PackedScene
@export var spitfire_enemy_scene: PackedScene
@export var strafer_enemy_scene: PackedScene

var enemies_remains = 0
var wave_in_live = false

const LEVEL_ENEMY_WAVES = [
	[
		{"type": "enemy_spitfire", "number": 3, "wait": 2.0},
		{"type": "base", "number": 5, "wait": 1.5}
	],
	[
		{"type": "base", "number": 3, "wait": 1.5},
		{"type": "enemy_spitfire", "number": 3, "wait": 2.0}
	],
	[
		{"type": "enemy_spitfire", "number": 2, "wait": 2.0},
		{"type": "base", "number": 2, "wait": 1.5},
		{"type": "enemy_strafer", "number": 1, "wait": 1.0}
	],
	[
		{"type": "enemy_spitfire", "number": 1, "wait": 1.5},
		{"type": "base", "number": 2, "wait": 0.5},
		{"type": "enemy_spitfire", "number": 1, "wait": 1.5},
		{"type": "base", "number": 2, "wait": 0.5},
		{"type": "enemy_strafer", "number": 3, "wait": 1.5}
	]
]

func _ready():
	# Inizia la prima ondata all'avvio
	var scena_giocatore = GameManager.GIOCATORI_DISPONIBILI[GameManager.giocatore_selezionato]
	var nuovo_giocatore = scena_giocatore.instantiate()
	get_parent().call_deferred("add_child", nuovo_giocatore)
	
	start_next_wave()

func start_next_wave():
	if GameManager.current_wave >= LEVEL_ENEMY_WAVES.size():
		print("LEVEL COMPLETE!")
		return # Abbiamo finito le ondate

	wave_in_live = true
	var wave_data = LEVEL_ENEMY_WAVES[GameManager.current_wave]
	
	# Get totale of enemies
	for enemy_data in wave_data:
		enemies_remains += enemy_data["number"]
	
	for enemy_data in wave_data:	
		var enemies_number = enemy_data["number"]
		var enemy_type = enemy_data["type"]
		var enemy_wait = enemy_data["wait"]

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
		while counter < enemies_number:
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
