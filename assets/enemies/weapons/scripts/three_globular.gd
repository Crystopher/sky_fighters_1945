extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

var direzione = Vector2.DOWN
@onready var suono_colpo = $SuonoSparo

func _ready() -> void:
	suono_colpo.play()

func _process(delta):
	# Muoviamo il proiettile usando il vettore direzione.
	# .normalized() assicura che il movimento sia a velocità costante.
	position += direzione.normalized() * velocita * delta

	# Logica per uscire dallo schermo (la lasciamo generica)
	var screen_size = get_viewport_rect().size
	if position.y > screen_size.y + 20 or position.y < -20 or position.x < -20 or position.x > screen_size.x + 20:
		queue_free()

# Gestiamo la collisione con il giocatore

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	# La logica della morte del giocatore è già nel giocatore stesso
