extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

var linear_velocity: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("proiettili_nemici")
	body_entered.connect(_on_body_entered)

func _process(delta):
	global_position += linear_velocity * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("giocatore"):
		body.subire_danno(punti_arma)
		queue_free()

func _on_visibility_notifier_2d_screen_exited():
	queue_free()
