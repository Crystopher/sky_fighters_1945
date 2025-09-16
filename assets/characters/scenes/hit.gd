extends AnimatedSprite2D

func _ready():
	animation_finished.connect(on_animation_finished)
	play("play")
	AudioManager.plane_hit()

func on_animation_finished():
	queue_free() # Distruggi la scena dell'esplosione
