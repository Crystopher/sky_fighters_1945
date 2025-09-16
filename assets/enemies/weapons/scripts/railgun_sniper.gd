extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

var direzione = Vector2.DOWN

func _ready() -> void:
	AudioManager.enemy_railgun_fire()
	
func _process(delta):
	# Muovi il proiettile verso il basso (Y positivo)
	position += direzione.normalized() * velocita * delta

	# Distruggilo se esce dallo schermo
	if not get_viewport().get_visible_rect().has_point(global_position):
		queue_free()

# Gestiamo la collisione con il giocatore

func _on_body_entered(body: Node2D) -> void:
	# Se colpisce il giocatore, distrugge se stesso
	queue_free()
	# La logica della morte del giocatore è già nel giocatore stesso
