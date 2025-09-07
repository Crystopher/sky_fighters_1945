extends "res://assets/enemies/scripts/enemy_base.gd"

# Carichiamo la scena del proiettile che questo nemico userà
@export var weapon_scene: PackedScene

func _ready() -> void:
	super()

func sparare():
	if not weapon_scene: return

	var new_weapon = weapon_scene.instantiate()

	# Aggiungiamo il proiettile alla scena principale, non al nemico stesso
	get_tree().get_root().add_child(new_weapon)

	# Lo posizioniamo dove si trova il nemico
	new_weapon.global_position = global_position

func explode(with_sound):
	$SpawnTimer.stop()
	super(with_sound)

func _on_spawn_timer_timeout() -> void:
	sparare()

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
