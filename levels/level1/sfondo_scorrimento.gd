extends ParallaxBackground

@export var scroll_speed = 100.0 # Velocità base dello scorrimento

func _process(delta):
	# Aggiungiamo un vettore di scorrimento verso il basso in base alla velocità
	scroll_offset += Vector2(0, scroll_speed * delta)
