extends "res://assets/bosses/weapons/scripts/weapon_base_boss.gd"

var direzione
var _time_elapsed: float = 0.0 # Per il calcolo del movimento sinusoidale
var vertical_speed: float = 200.0
var horizontal_amplitude: float = 150.0
var horizontal_frequency: float = 5.0
var initial_position: Vector2

func _ready() -> void:
	AudioManager.enemy_chopter_missile()
	initial_position = global_position
	
func _process(delta):
	_time_elapsed += delta
	var vertical_movement = Vector2(0, vertical_speed * delta)
	var horizontal_offset = sin(_time_elapsed * horizontal_frequency) * horizontal_amplitude
	var horizontal_movement = Vector2(horizontal_offset, 0)

	global_position.x = initial_position.x + horizontal_offset
	global_position.y += vertical_speed * delta
	
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()
