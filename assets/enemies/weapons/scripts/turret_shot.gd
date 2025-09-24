extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

class_name ProiettileTorretta

var linear_velocity: Vector2 = Vector2.ZERO # Impostata dalla torretta

func _ready():
	add_to_group("proiettili_nemici") # Importante per la gestione delle collisioni
	body_entered.connect(_on_body_entered) # Per colpire il giocatore
	AudioManager.enemy_turret_fire()

func _process(delta):
	global_position += linear_velocity * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("giocatore"):
		body.subire_danno(punti_arma) # Assumi che il giocatore abbia la funzione subire_danno
		queue_free() # Distruggi il proiettile dopo aver colpito

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Replace with function body.
