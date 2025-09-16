extends "res://assets/enemies/weapons/scripts/weapon_base.gd"

@export var proiettile_secondario: PackedScene

func _ready():
	AudioManager.enemy_railgun_fire()
	$Timer.start()

func _process(delta):
	# Il proiettile viaggia semplicemente verso il basso
	position.y += velocita * delta

# Quando il timer finisce, il proiettile si divide
func _on_timer_timeout():
	if not proiettile_secondario: return

	# Calcoliamo gli angoli (45 gradi in radianti)
	var angolo_rad = deg_to_rad(45.0)

	# Creiamo i due nuovi proiettili
	var proiettile_sx = proiettile_secondario.instantiate()
	var proiettile_dx = proiettile_secondario.instantiate()

	# Impostiamo le loro direzioni
	proiettile_sx.direzione = Vector2.DOWN.rotated(-angolo_rad)
	proiettile_dx.direzione = Vector2.DOWN.rotated(angolo_rad)
	
	proiettile_dx.rotation = proiettile_dx.direzione.angle() - PI / 2.5
	proiettile_sx.rotation = proiettile_sx.direzione.angle() - PI / 1.9

	# Aggiungiamo i nuovi proiettili alla scena
	get_parent().add_child(proiettile_sx)
	get_parent().add_child(proiettile_dx)

	# Posizioniamoli dove siamo noi
	proiettile_sx.global_position = global_position
	proiettile_dx.global_position = global_position

	# Ora che abbiamo rilasciato il carico, ci autodistruggiamo
	queue_free()
