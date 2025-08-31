extends Area2D
var velocita = 400.0

func _process(delta):
	# Muovi il proiettile verso il basso (Y positivo)
	position.y += velocita * delta

	# Distruggilo se esce dallo schermo
	if position.y > get_viewport_rect().size.y + 20:
		queue_free()

# Gestiamo la collisione con il giocatore

func _on_body_entered(body: Node2D) -> void:
	print("Proiettile nemico")
	# Se colpisce il giocatore, distrugge se stesso
	queue_free()
	# La logica della morte del giocatore è già nel giocatore stesso
