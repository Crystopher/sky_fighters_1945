extends Node

# Il percorso del nostro file di salvataggio. 'user://' è una cartella speciale
# che Godot usa per salvare i dati dell'utente in modo sicuro.
const SAVE_PATH = "user://highscores.json"
const MAX_SCORES = 10 # Quanti punteggi vogliamo salvare in classifica

var high_scores = [] # L'array che conterrà la nostra classifica

func _ready():
	# Quando il gioco parte, carichiamo i punteggi salvati
	load_scores()

func load_scores():
	# Controlliamo se il file di salvataggio esiste
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			high_scores = data
		file.close()
	else:
		# Se non esiste, creiamo una classifica vuota
		high_scores = []

func save_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))
	file.close()

# Controlla se un punteggio è abbastanza alto per entrare in classifica
func is_high_score(score):
	# Se la classifica non è piena, ogni punteggio è un high score
	if high_scores.size() < MAX_SCORES:
		return true
	# Altrimenti, controlla se è più alto dell'ultimo punteggio in classifica
	return score > high_scores.back()["score"]

# Aggiunge un nuovo punteggio, riordina la classifica e la salva
func add_score(player_name, player_score):
	high_scores.append({"name": player_name, "score": player_score})
	# Riordiniamo la classifica dal punteggio più alto al più basso
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	# Se la classifica è troppo lunga, rimuoviamo l'ultimo elemento
	if high_scores.size() > MAX_SCORES:
		high_scores.pop_back()

	save_scores()
