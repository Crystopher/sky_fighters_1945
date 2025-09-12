extends AnimatedSprite2D

func _ready():
	# Collega il segnale 'animation_finished' a una funzione che distrugge il nodo
	animation_finished.connect(on_animation_finished)

	# Avvia l'animazione
	play("play")

func on_animation_finished():
	queue_free() # Distruggi la scena dell'esplosione
