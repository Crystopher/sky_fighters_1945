extends "res://assets/bosses/weapons/scripts/weapon_base_boss.gd"

@export var proiettile_secondario: PackedScene
@onready var suono_colpo = $SuonoSparo
var direzione

func _ready() -> void:
	suono_colpo.play()
	
func _process(delta):
	# Muovi il proiettile verso il basso (Y positivo)
	position.y += velocita * delta

	# Distruggilo se esce dallo schermo
	if position.y > get_viewport_rect().size.y + 20:
		queue_free()

# Gestiamo la collisione con il giocatore

func _on_body_entered(body: Node2D) -> void:
	# Se colpisce il giocatore, distrugge se stesso
	queue_free()
	# La logica della morte del giocatore è già nel giocatore stesso


func _on_timer_timeout() -> void:
	if not proiettile_secondario: return

	# Creiamo i due nuovi proiettili
	var bullet_explosion = proiettile_secondario.instantiate()

	# Aggiungiamo i nuovi proiettili alla scena
	get_parent().add_child(bullet_explosion)

	# Posizioniamoli dove siamo noi
	bullet_explosion.global_position = global_position

	# Ora che abbiamo rilasciato il carico, ci autodistruggiamo
	queue_free()
