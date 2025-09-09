extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

# Questa variabile permette a chi crea il proiettile (lo splitter)
# di dirgli in quale direzione viaggiare.
var direzione = Vector2.DOWN # Di default va in basso, ma verrà sovrascritta
@onready var suono_colpo = $SuonoSparo

func _ready() -> void:
	suono_colpo.play()

func _process(delta):
	# Il movimento usa la variabile 'direzione'
	position += direzione.normalized() * velocita * delta
	
	# Logica per l'autodistruzione se esce dallo schermo
	var screen_size = get_viewport_rect().size
	if position.y > screen_size.y + 20 or position.y < -20 or position.x < -20 or position.x > screen_size.x + 20:
		queue_free()

# La logica di collisione non serve più qui, la gestisce il giocatore.
# Puoi cancellare la funzione _on_body_entered se è ancora presente.
