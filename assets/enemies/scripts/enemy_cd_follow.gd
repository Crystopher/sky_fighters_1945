extends "res://assets/enemies/scripts/enemy_cd_base.gd"

# Definiamo i due stati: entrata e mira
enum State { ENTRANDO, MIRA }
var stato_attuale = State.ENTRANDO

@export var weapon_scene: PackedScene
@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena

@onready var spawn_shot_1 = $SpawnTimer
var y_bersaglio_stop # L'altezza a cui il nemico si fermerà
var riferimento_giocatore = null # Una variabile per "ricordare" dov'è il giocatore

func _ready():
	super() # Eseguiamo la funzione _ready() del genitore
	
	velocita = velocita_entrata

	# Troviamo subito il giocatore per sapere a chi sparare
	riferimento_giocatore = get_tree().get_first_node_in_group("giocatore")

	# Calcoliamo la posizione Y casuale in cui fermarsi (nella metà superiore dello schermo)
	var screen_height = get_viewport_rect().size.y
	y_bersaglio_stop = randf_range(screen_height * 0.1, screen_height * 0.5)
	
	spawn_shot_1.start()

func _process(delta):
	match stato_attuale:
		State.ENTRANDO:
			# Muoviti verso il basso
			position.y += velocita * delta
			aggiorna_posizione_ombra()

			# Controlla se abbiamo raggiunto l'altezza prestabilita
			if position.y >= y_bersaglio_stop:
				# Se sì, fermati e inizia a sparare
				stato_attuale = State.MIRA

		State.MIRA:
			# Da fermo, non facciamo nulla nel _process. L'azione è gestita dal Timer.
			aggiorna_posizione_ombra()

func sparare_raffica():
	# Controllo di sicurezza: se il giocatore è stato distrutto, non sparare.
	if not is_instance_valid(riferimento_giocatore):
		return

	# Eseguiamo un ciclo per sparare 4 proiettili
	for i in range(2):
		# Calcoliamo la direzione verso il giocatore IN QUESTO ISTANTE
		var direzione = (riferimento_giocatore.global_position - global_position).normalized()

		# Creiamo un proiettile (usiamo quello base nemico)
		var proiettile = weapon_scene.instantiate() # Assumiamo di avere proiettile_nemico_scena
		get_parent().add_child(proiettile)
		proiettile.global_position = global_position
		proiettile.direzione = direzione
		
		proiettile.rotation = direzione.angle() + PI / 2.0

		# Aspettiamo un breve istante prima di sparare il prossimo colpo della raffica
		await get_tree().create_timer(0.2).timeout

func _on_spawn_timer_timeout() -> void:
	sparare_raffica()
