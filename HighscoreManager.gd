extends Node

const SAVE_PATH = "user://highscores.json"
const MAX_SCORES = 10

var high_scores = []

func _ready():
	load_scores()

func load_scores():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			var scores_aggiornati = []
			for entry in data:
				# --- NUOVA LOGICA DI MIGRAZIONE ---
				# Controlla se manca la chiave "difficulty". Se sì, la aggiungiamo.
				if not entry.has("difficulty"):
					entry["difficulty"] = 4.0 # Default: Normale
				
				# Controlla se manca la chiave "plane". Se sì, la aggiungiamo.
				if not entry.has("plane"):
					entry["plane"] = "VERDE" # Default: Aereo Verde (o come preferisci)
				
				scores_aggiornati.append(entry)
				# --- FINE LOGICA DI MIGRAZIONE ---

			high_scores = scores_aggiornati
			
			# CONSIGLIATO: Salva subito i punteggi corretti, così la migrazione avviene una sola volta!
			save_scores()
	else:
		# Se non esiste nessun file, creiamo una classifica vuota (invariato)
		high_scores = []

func save_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))
	file.close()

func is_high_score(score):
	if high_scores.size() < MAX_SCORES:
		return true
	return score > high_scores.back()["score"]

# --- FUNZIONE AGGIORNATA ---
# Ora accetta anche la difficoltà e l'aereo
func add_score(player_name, player_score, difficulty, plane_color):
	var new_entry = {
		"name": player_name,
		"score": player_score,
		"difficulty": difficulty,
		"plane": plane_color
	}
	high_scores.append(new_entry)
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if high_scores.size() > MAX_SCORES:
		high_scores.pop_back()
	save_scores()

# --- NUOVE FUNZIONI DI FILTRAGGIO ---
func get_scores_by_difficulty(target_difficulty):
	var filtered_scores = []
	for score in high_scores:
		if score["difficulty"] == target_difficulty:
			filtered_scores.append(score)
	return filtered_scores

func get_scores_by_plane(target_plane):
	var filtered_scores = []
	for score in high_scores:
		if score["plane"] == target_plane:
			filtered_scores.append(score)
	return filtered_scores
