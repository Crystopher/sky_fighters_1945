extends Node

var punteggio_attuale = 0
signal punteggio_aggiornato(nuovo_punteggio)
signal giocatore_morto # Nuovo segnale!

var current_level = 1
var current_wave = 0

# Carichiamo le scene dei giocatori disponibili
const GIOCATORI_DISPONIBILI = {
	"verde": preload("res://assets/characters/player_green.tscn"),
	"blue": preload("res://assets/characters/player_blue.tscn"),
	"rosso": preload("res://assets/characters/player_red.tscn")
}

# Memorizziamo la scelta attuale del giocatore (il verde sarà il default)
var giocatore_selezionato = "verde"

func reset_level():
	punteggio_attuale = 0
	current_wave = 0 # Resettiamo anche l'ondata
	punteggio_aggiornato.emit(punteggio_attuale)

func _ready():
	# Connettiamo il nuovo segnale alla funzione di game over
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
