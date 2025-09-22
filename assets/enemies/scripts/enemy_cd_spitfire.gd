extends "res://assets/enemies/scripts/enemy_cd_base.gd"

# Definiamo i due stati: entrata e mira
enum State { ENTRANDO, MIRA }
var stato_attuale = State.ENTRANDO

@export var weapon_scene: PackedScene
@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena

@onready var spawn_shot_1 = $SpawnTimer
@onready var spawn_shot_2 = $SpawnTimer2

func _ready() -> void:
	super()
	spawn_shot_1.start()
	await get_tree().create_timer(0.5).timeout
	spawn_shot_2.start()

func sparare(side):
	if not weapon_scene: return

	var new_weapon = weapon_scene.instantiate()
	get_tree().get_root().add_child(new_weapon)
	var position = global_position
	position.y -= 20
	if side == "sx":
		position.x -= 40
	
	if side == "dx":
		position.x += 40
		
	new_weapon.global_position = position

func explode(with_sound):
	spawn_shot_1.stop()
	spawn_shot_2.stop()
	super(with_sound)

func _on_spawn_timer_timeout() -> void:
	sparare("sx")

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_spawn_timer_2_timeout() -> void:
	sparare("dx")
