extends Node

var punteggio_attuale = 0
signal punteggio_aggiornato(nuovo_punteggio)
signal giocatore_morto

var player_stats_store = {}

var current_level = ""
var current_wave = 0

var vite_iniziali = 3
var vite_rimanenti

var current_energy
var current_speed
var speed_powerup_max = 10
var current_speed_powerup = 0
var damage_powerup_max = 10
var current_damage_powerup = 0
var current_weapon_damage_powerup = 0.0
var current_weapon_selected = 0

var ultimo_punteggio = 0
var ultima_difficolta = 1.0
var ultimo_aereo = "verde"

signal vite_aggiornate(nuove_vite)

const LEVELS_SCHEMA = [
	{
		"level": "1.1",
		"schema": {
			"next_level": "1.2",
			"level_scene": "res://levels/level1/scenes/intro02.tscn"
		}
	},
	{
		"level": "1.2",
		"schema": {
			"next_level": "end_game"
		}
	}
]

# Carichiamo le scene dei giocatori disponibili
const GIOCATORI_DISPONIBILI = {
	"verde": preload("res://assets/characters/player_green.tscn"),
	"blue": preload("res://assets/characters/player_blue.tscn"),
	"rosso": preload("res://assets/characters/player_red.tscn")
}

# Memorizziamo la scelta attuale del giocatore (il verde sarà il default)
var giocatore_selezionato = "verde"

# in GameManager.gd

func clean_up_level():
	# Trova tutti i proiettili nemici e distruggili
	var proiettili_nemici = get_tree().get_nodes_in_group("proiettili_nemici")
	for p in proiettili_nemici:
		p.queue_free()

	# Trova tutti i proiettili del giocatore e distruggili
	var proiettili_giocatore = get_tree().get_nodes_in_group("proiettili_giocatore")
	for p in proiettili_giocatore:
		p.queue_free()

	# Trova tutti i nemici e distruggili
	var nemici = get_tree().get_nodes_in_group("nemici") # Assicurati che i nemici siano in questo gruppo
	for n in nemici:
		n.queue_free()

func reset_player_stats():
	player_stats_store = {}

func store_player_info():
	player_stats_store = {
		"current_damage_powerup": current_damage_powerup,
		"current_speed_powerup": current_speed_powerup,
		"current_speed": current_speed,
		"current_weapon_damage_powerup": current_weapon_damage_powerup,
		"current_weapon_selected": current_weapon_selected
	}
	
func next_level(current_finished):
	var found_levels = LEVELS_SCHEMA.filter(func(item): return item.level == current_finished)
	if not found_levels.is_empty():
		var level_data = found_levels[0]
		if level_data.schema["next_level"] == "end_game":
			await get_tree().create_timer(2.0).timeout
			GameManager.end_game(false)
		else:
			GameManager.current_wave = 0
			TransitionManager.change_scene(level_data.schema["level_scene"])
			print("Livello trovato: ", level_data) # Stampa: Livello trovato: {level:1.1, schema:{next_level:1.2}}
			print("Prossimo livello: ", level_data.schema.next_level) # Stampa: Prossimo livello: 1.2
	else:
		print("Nessun livello trovato con quell'ID.")

func update_weapon_level(value):
	current_weapon_selected = value

# Nuova funzione per gestire la perdita di una vita
func perdi_vita():
	vite_rimanenti -= 1
	vite_aggiornate.emit(vite_rimanenti)

	# Restituisce true se è Game Over, altrimenti false
	return vite_rimanenti < 0

func reset_level():
	current_weapon_selected = 0
	current_weapon_damage_powerup = 0.0
	punteggio_attuale = 0
	current_wave = 0 # Resettiamo anche l'ondata
	vite_rimanenti = vite_iniziali # Imposta le vite all'inizio
	punteggio_aggiornato.emit(punteggio_attuale)

func _ready():
	# Connettiamo il nuovo segnale alla funzione di game over
	vite_rimanenti = vite_iniziali
	giocatore_morto.connect(game_over)

func aggiungi_punti(punti):
	punteggio_attuale += punti
	punteggio_aggiornato.emit(punteggio_attuale)

func reset_punteggio():
	punteggio_attuale = 0
	punteggio_aggiornato.emit(punteggio_attuale)

func game_over():
	reset_punteggio()
	# Aspettiamo un istante per dare tempo ai suoni di finire, poi ricarichiamo
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func end_game(player_won: bool):
	# Metti in pausa il gioco per bloccare tutto
	get_tree().paused = true

	ultimo_punteggio = punteggio_attuale
	ultima_difficolta = SettingsManager.difficulty_multiplier
	ultimo_aereo = giocatore_selezionato

	# Pulisci gli elementi visivi della scena
	clean_up_level()

	# Riattiva il gioco per permettere al TransitionManager di funzionare
	get_tree().paused = false

	if player_won:
		# Se il giocatore ha "vinto" o raggiunto la fine del livello
		# Potresti voler una schermata di "Vittoria" o "Livello Completato"
		# Per ora, reindirizziamo semplicemente alla schermata di inserimento highscore
		if HighscoreManager.is_high_score(ultimo_punteggio):
			TransitionManager.change_scene("res://inserimento_highscore.tscn")
		else:
			TransitionManager.change_scene("res://menu_principale.tscn")
	else:
		# Questo è# il caso del Game Over "standard" (es. vite esaurite)
		if HighscoreManager.is_high_score(ultimo_punteggio):
			TransitionManager.change_scene("res://inserimento_highscore.tscn")
		else:
			TransitionManager.change_scene("res://menu_principale.tscn")
