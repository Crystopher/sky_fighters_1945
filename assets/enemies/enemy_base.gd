extends Area2D

var velocita = 150.0

signal enemy_destroyed

func _process(delta):
	# Muovi il nemico verso il basso (l'asse Y positivo)
	position.y += velocita * delta

	# Se il nemico esce dal bordo inferiore, distruggilo
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 50: # +50 è un margine di sicurezza
		destroying()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		GameManager.aggiungi_punti(100)
		area.queue_free()
	
	explode()

func explode():
	print("Enemy is destroiyng....")
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.hide()
	$SuonoEsplosione.play()
	await $SuonoEsplosione.finished
	destroying()

func destroying():
	print("Enemy Destroyed")
	enemy_destroyed.emit() # Annuncia al mondo che stiamo per morire
	queue_free()
