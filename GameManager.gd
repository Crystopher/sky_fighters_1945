extends Node

var punteggio_attuale = 0
signal punteggio_aggiornato(nuovo_punteggio)
signal giocatore_morto # Nuovo segnale!

var current_level = 1
var current_wave = 0

const LEVEL_1_1 = [
	{"type": "base", "number": 5, "wait": 1.5},
	{"type": "enemy_spitfire", "number": 3, "wait": 2.0},
	{"type": "enemy_strafer", "number": 3, "wait": 1.0},
]

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
