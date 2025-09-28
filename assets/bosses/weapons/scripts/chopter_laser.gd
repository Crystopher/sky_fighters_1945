extends "res://assets/bosses/weapons/scripts/weapon_base_complex_boss.gd"

var direzione

@onready var laser_shot = $LaserRay
@onready var laser_beam = $LaserBeam

var global_x = 0

func _ready() -> void:
	AudioManager.enemy_chopter_laser_ray()
	global_x = global_position.x
	
func _process(delta):
	if laser_shot:
		laser_shot.position.y += velocita * delta
		laser_shot.global_position.x = global_x
		if position.y > get_viewport_rect().size.y + 200:
			laser_shot.queue_free()
			laser_beam.queue_free()
			queue_free()
