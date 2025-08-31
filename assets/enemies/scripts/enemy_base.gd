extends Area2D

var velocita = 150.0
@export var punti_nemico = 50
@export var punti_impatto = 1
@export var salute_massima = 1
var salute_attuale

signal enemy_destroyed

func subire_danno(quantita):
	salute_attuale -= quantita
	if salute_attuale <= 0:
		explode() # Il nemico muore solo quando la salute è finita

func _ready() -> void:
	salute_attuale = salute_massima

func _process(delta):
	# Muovi il nemico verso il basso (l'asse Y positivo)
	position.y += velocita * delta

	# Se il nemico esce dal bordo inferiore, distruggilo
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 50: # +50 è un margine di sicurezza
		explode()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		subire_danno(1)
		area.queue_free()
	elif area.is_in_group("giocatore"):
		explode()

func explode():
	GameManager.aggiungi_punti(punti_nemico)
	# the enemy starts to be destroyed
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.hide()
	$SuonoEsplosione.play()
	await $SuonoEsplosione.finished
	destroying()

func destroying():
	# The enemy is destroyed here
	enemy_destroyed.emit() # Annuncia al mondo che stiamo per morire
	queue_free()
