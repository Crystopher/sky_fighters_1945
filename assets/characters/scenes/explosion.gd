extends AnimatedSprite2D

func _ready():
	animation_finished.connect(on_animation_finished)
	play("play")
	AudioManager.plane_explosion()

func on_animation_finished():
	await get_tree().create_timer(2.0, false).timeout
	queue_free() # Distruggi la scena dell'esplosione
