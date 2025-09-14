extends "res://assets/characters/powerups/scripts/railgun.gd"

func _process(delta):
	var angolo_rad = deg_to_rad(20.0)
	
	var direzione = Vector2.DOWN
	
	if is_right:
		direzione = Vector2.DOWN.rotated(-angolo_rad)
	elif is_left:
		direzione = Vector2.DOWN.rotated(angolo_rad)
	# Il movimento verso l'alto non cambia

	position.y -= direzione.y * velocita * delta
	position.x -= direzione.x * velocita * delta

	# NUOVA LOGICA DI CANCELLAZIONE:
	# Chiediamo al gioco le dimensioni attuali della finestra/viewport.
	var screen_size = get_viewport_rect().size

	# Distruggiamo il proiettile se la sua posizione Y è minore di 0 (oltre il bordo superiore)
	# o se per qualche motivo dovesse andare oltre il bordo inferiore (screen_size.y).
	if position.y < 0 or position.y > screen_size.y:
		queue_free() # Questo comando distrugge il nodo in modo sicuro
