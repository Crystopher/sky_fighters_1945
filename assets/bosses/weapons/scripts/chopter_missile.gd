extends "res://assets/bosses/weapons/scripts/weapon_base_boss.gd"

var direzione

func _ready() -> void:
	AudioManager.enemy_chopter_missile()
	
func _process(delta):
	position.y += velocita * delta
	if position.y > get_viewport_rect().size.y + 20:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
