extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

var direzione = Vector2.DOWN

func _ready() -> void:
	AudioManager.enemy_three_globular()

func _process(delta):
	position += direzione.normalized() * velocita * delta

	var screen_size = get_viewport_rect().size
	if position.y > screen_size.y + 20 or position.y < -20 or position.x < -20 or position.x > screen_size.x + 20:
		queue_free()

# Gestiamo la collisione con il giocatore

func _on_body_entered(body: Node2D) -> void:
	queue_free()
