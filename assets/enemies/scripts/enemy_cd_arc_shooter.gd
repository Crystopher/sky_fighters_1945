extends "res://assets/enemies/scripts/enemy_cd_base.gd"

# Definiamo i due stati: entrata e mira
enum State { ENTRANDO, MIRA }
var stato_attuale = State.ENTRANDO

@export var weapon_scene: PackedScene
@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena

@export var numero_proiettili_ventaglio: int = 5
@export var angolo_apertura_ventaglio: float = 30.0 # Gradi
@export var velocita_proiettile: float = 200.0

@onready var muzzle = $Muzzle
@onready var spawn_shot_1 = $SpawnTimer

func _ready() -> void:
	super()
	spawn_shot_1.start()

func sparare():
	if not weapon_scene: return

	var player_node = GameManager.get_player_node()
	var direction_to_player = (player_node.global_position - muzzle.global_position).normalized()
	var base_angle = direction_to_player.angle() # Angolo in radianti

	# Converte l'angolo di apertura da gradi a radianti
	var apertura_rad = deg_to_rad(angolo_apertura_ventaglio)

	# Calcola l'angolo iniziale e l'incremento tra un proiettile e l'altro
	var start_angle = base_angle - (apertura_rad / 2.0)
	var angle_increment = apertura_rad / (numero_proiettili_ventaglio - 1.0) if numero_proiettili_ventaglio > 1 else 0.0

	for i in range(numero_proiettili_ventaglio):
		var current_angle = start_angle + (angle_increment * i)
		var bullet_direction = Vector2(cos(current_angle), sin(current_angle))

		var proiettile_instance = weapon_scene.instantiate()
		get_tree().root.add_child(proiettile_instance) # Aggiungi al root per movimento indipendente

		proiettile_instance.global_position = muzzle.global_position
		proiettile_instance.linear_velocity = bullet_direction * velocita_proiettile

func explode(with_sound):
	spawn_shot_1.stop()
	super(with_sound)

func _on_spawn_timer_timeout() -> void:
	sparare()

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
