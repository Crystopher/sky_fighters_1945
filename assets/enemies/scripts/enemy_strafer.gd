extends "res://assets/enemies/scripts/enemy_base.gd"

# Definiamo i possibili "stati mentali" del nostro nemico
enum State { SCENDE, DESTRA_SINISTRA }

# Impostiamo le variabili per il nuovo movimento
var stato_attuale = State.SCENDE # Inizia nello stato SCENDE
var velocita_orizzontale = 200.0
var direzione_orizzontale = 1 # 1 per destra, -1 per sinistra

var y_bersaglio_strafe # La posizione Y a cui cambierà comportamento

# _ready() viene eseguita all'inizio per preparare il nemico
func _ready():
	# Scegliamo un'altezza casuale a cui iniziare il movimento laterale
	# Vogliamo che sia nella parte alta dello schermo
	var screen_height = get_viewport_rect().size.y
	y_bersaglio_strafe = randf_range(screen_height * 0.15, screen_height * 0.4)
	super()

# Carichiamo la scena del proiettile che questo nemico userà
@export var weapon_scene: PackedScene
# In nemico_tiratore.gd

func sparare():
	if not weapon_scene: return

	# 1. Definiamo la direzione di base (dritto verso il basso)
	var direzione_base = Vector2.DOWN

	# 2. Definiamo l'angolo di deviazione in gradi
	var angolo_deviazione_gradi = 30.0

	# 3. Godot lavora in radianti, quindi convertiamo i gradi
	var angolo_deviazione_rad = deg_to_rad(angolo_deviazione_gradi)

	# 4. Calcoliamo i tre vettori di direzione ruotando quello base
	var direzioni = [
		direzione_base.rotated(-angolo_deviazione_rad), # Proiettile sinistro
		direzione_base,                                # Proiettile centrale
		direzione_base.rotated(angolo_deviazione_rad)  # Proiettile destro
	]

	# 5. Creiamo un proiettile per ogni direzione calcolata
	for dir in direzioni:
		var nuovo_proiettile = weapon_scene.instantiate()

		# Aggiungiamo il proiettile alla scena principale
		get_tree().get_root().add_child(nuovo_proiettile)

		# Lo posizioniamo dove si trova il nemico
		nuovo_proiettile.global_position = global_position

		# IMPORTANTE: Assegniamo al nuovo proiettile la sua direzione specifica!
		nuovo_proiettile.direzione = dir

func explode():
	$SpawnTimer.stop()
	super()

# _process() viene eseguito a ogni frame e contiene la nostra "macchina a stati"
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
			var self_half_size = $CollisionShape2D.shape.size.x / 2

			if position.x >= screen_width - self_half_size:
				direzione_orizzontale = -1 # Vai a sinistra
			elif position.x <= self_half_size:
				direzione_orizzontale = 1 # Vai a destra


func _on_spawn_timer_timeout() -> void:
	sparare()
