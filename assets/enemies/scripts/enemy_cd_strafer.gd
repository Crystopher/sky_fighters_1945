extends "res://assets/enemies/scripts/enemy_cd_base.gd"

# Definiamo i due stati: entrata e mira
enum State { SCENDE, DESTRA_SINISTRA }
var stato_attuale = State.SCENDE
var y_bersaglio_strafe
var velocita_orizzontale = 200.0
var direzione_orizzontale = 1 # 1 per destra, -1 per sinistra
@export var weapon_scene: PackedScene
@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena

@onready var spawn_shot_1 = $SpawnTimer_1
@onready var spawn_shot_2 = $SpawnTimer_2
@onready var spawn_shot_3 = $SpawnTimer_3

@onready var muzzle_dx_1 = $Muzzle_01
@onready var muzzle_dx_2 = $Muzzle_02
@onready var muzzle_dx_3 = $Muzzle_03
@onready var muzzle_sx_1 = $Muzzle_04
@onready var muzzle_sx_2 = $Muzzle_05
@onready var muzzle_sx_3 = $Muzzle_06

func _ready() -> void:
	var screen_height = get_viewport_rect().size.y
	y_bersaglio_strafe = randf_range(screen_height * 0.15, screen_height * 0.4)
	super()
	spawn_shot_1.start()
	await get_tree().create_timer(0.3, false).timeout
	spawn_shot_2.start()
	await get_tree().create_timer(0.3, false).timeout
	spawn_shot_3.start()

func _process(delta):
	# Usiamo 'match' per eseguire codice diverso in base allo stato attuale
	match stato_attuale:
		State.SCENDE:
			# Esegui il normale movimento verso il basso del nemico base
			super(delta)

			# Controlla se abbiamo raggiunto l'altezza prestabilita
			if position.y >= y_bersaglio_strafe:
				# Se sì, cambia stato!
				stato_attuale = State.DESTRA_SINISTRA

		State.DESTRA_SINISTRA:
			# Esegui il movimento laterale
			position.x += velocita_orizzontale * direzione_orizzontale * delta

			# Controlla se ha toccato i bordi dello schermo e inverti la direzione
			var screen_width = get_viewport_rect().size.x
			var self_half_size = $CollisionPolygon2D.polygon[0].x / 2

			if position.x >= screen_width - self_half_size:
				direzione_orizzontale = -1 # Vai a sinistra
			elif position.x <= self_half_size:
				direzione_orizzontale = 1 # Vai a destra
				
	aggiorna_posizione_ombra()

func explode(with_sound):
	spawn_shot_1.stop()
	spawn_shot_2.stop()
	spawn_shot_3.stop()
	super(with_sound)
	
func sparare(muzzle_dx, muzzle_sx):
	if not weapon_scene: return

	var new_weapon_dx = weapon_scene.instantiate()
	get_tree().get_root().add_child(new_weapon_dx)
	var new_weapon_sx = weapon_scene.instantiate()
	get_tree().get_root().add_child(new_weapon_sx)
	var position_dx = muzzle_dx.global_position
	var position_sx = muzzle_sx.global_position
		
	new_weapon_dx.global_position = position_dx
	new_weapon_sx.global_position = position_sx

func _on_spawn_timer_1_timeout() -> void:
	sparare(muzzle_dx_1, muzzle_sx_1)


func _on_spawn_timer_2_timeout() -> void:
	sparare(muzzle_dx_2, muzzle_sx_2)


func _on_spawn_timer_3_timeout() -> void:
	sparare(muzzle_dx_3, muzzle_sx_3)
