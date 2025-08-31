extends "res://assets/enemies/scripts/enemy_base.gd"

# Carichiamo la scena del proiettile che questo nemico userà
@export var weapon_scene: PackedScene
	
# Questa funzione viene chiamata quando il Timer scatta
func _on_timer_timeout():
	sparare()

func sparare():
	if not weapon_scene: return

	var new_weapon = weapon_scene.instantiate()

	# Aggiungiamo il proiettile alla scena principale, non al nemico stesso
	get_tree().get_root().add_child(new_weapon)

	# Lo posizioniamo dove si trova il nemico
	new_weapon.global_position = global_position

func explode():
	$SpawnTimer.stop()
	super()
