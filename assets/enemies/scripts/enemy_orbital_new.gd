extends "res://assets/enemies/scripts/enemy_base.gd"

# Definiamo i due stati: entrata e orbita
enum State { ENTRATA, ORBITA }
var stato_attuale = State.ENTRATA

@export var weapon_scene: PackedScene

# --- Parametri Configurabili ---
@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena
@export var velocita_orbitale = 2.0  # In radianti al secondo (più alto = più veloce)
var raggio_orbita = 100.0           # Il raggio del cerchio
var centro_orbita = Vector2.ZERO   # Il centro del cerchio
var direzione_orbita = 1.0         # 1 per antiorario, -1 per orario
var angolo_attuale = 0.0           # L'angolo attuale sull'orbita

func sparare():
	if not weapon_scene: return

	var new_weapon = weapon_scene.instantiate()

	# Aggiungiamo il proiettile alla scena principale, non al nemico stesso
	get_tree().get_root().add_child(new_weapon)

	# Lo posizioniamo dove si trova il nemico
	new_weapon.global_position = global_position

func _on_spawn_timer_timeout() -> void:
	sparare()

# _ready() viene eseguita all'inizio per preparare il nemico
func _ready():
	# Eseguiamo la funzione _ready() del genitore (nemico_base)
	super()

	# Sostituiamo la velocità base con quella di entrata
	velocita = velocita_entrata

	# --- NUOVA LOGICA INIZIALE ---
	# Decidiamo solo le proprietà dell'orbita, NON il suo centro
	var screen_size = get_viewport_rect().size
	raggio_orbita = randf_range(screen_size.x * 0.15, screen_size.x * 0.25)
	
	# Scegliamo una direzione di rotazione casuale
	direzione_orbita = 1.0 if randi() % 2 == 0 else -1.0
	
	# Decidiamo a quale altezza dovrà iniziare a orbitare
	# La Y del *centro* dell'orbita sarà questa + il raggio
	var y_inizio_orbita = randf_range(raggio_orbita, screen_size.y * 0.4)
	centro_orbita.y = y_inizio_orbita + raggio_orbita
	# --- FINE NUOVA LOGICA ---

# _process() viene eseguito a ogni frame
func _process(delta):
	match stato_attuale:
		State.ENTRATA:
			# Muoviti verso il basso velocemente
			position.y += velocita * delta
			aggiorna_posizione_ombra()
			
			# Controlla se abbiamo raggiunto l'altezza del punto più alto dell'orbita
			if position.y >= centro_orbita.y - raggio_orbita:
				
				# --- CALCOLO DINAMICO DEL CENTRO ---
				# Il centro X dell'orbita sarà la nostra posizione X attuale
				centro_orbita.x = position.x
				
				# Impostiamo l'angolo iniziale per partire dal punto più alto
				angolo_attuale = -PI / 2.0
				
				# Sincronizziamo la posizione per evitare piccoli scatti
				position.x = centro_orbita.x + cos(angolo_attuale) * raggio_orbita
				position.y = centro_orbita.y + sin(angolo_attuale) * raggio_orbita
				
				# Ora cambiamo stato
				stato_attuale = State.ORBITA
		
		State.ORBITA:
			# Aggiorniamo l'angolo
			angolo_attuale += velocita_orbitale * direzione_orbita * delta
			
			# Calcoliamo la nuova posizione sull'orbita
			position.x = centro_orbita.x + cos(angolo_attuale) * raggio_orbita
			position.y = centro_orbita.y + sin(angolo_attuale) * raggio_orbita
			
			# Aggiorniamo l'ombra
			aggiorna_posizione_ombra()

	# Questa logica non è più necessaria qui perché la gestiamo negli stati
	# super(delta)
