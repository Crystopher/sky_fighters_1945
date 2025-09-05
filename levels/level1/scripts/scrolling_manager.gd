extends Node2D

@export var scroll_speed = 100.0
@export var textures : Array[Texture2D]

# Ora l'array conterrà tutti i nostri segmenti
var segmenti = []
var segment_height
var prossimo_texture_idx = 0

func _ready():
	if textures.is_empty():
		print("Nessuna texture assegnata a questo layer.")
		return

	# Popoliamo l'array con i figli TextureRect
	for child in get_children():
		if child is TextureRect:
			segmenti.append(child)

	if segmenti.is_empty():
		print("Nessun nodo TextureRect trovato come figlio.")
		return

	# Posizioniamo tutti i segmenti iniziali in una pila verticale
	for i in range(segmenti.size()):
		segment_height = textures[i].get_height()
		
		if i == 0:
			segment_height = segment_height * 2

		segmenti[i].texture = get_prossima_texture()
		segmenti[i].position = Vector2(0, -i * segment_height)

func _process(delta):
	if segmenti.is_empty(): return

	# Muoviamo tutti i segmenti verso il basso (invariato)
	for segmento in segmenti:
		segmento.position.y += scroll_speed * delta
	
	# Controlliamo se il PRIMO segmento è uscito dallo schermo
	var primo_segmento_attuale = segmenti[0]
	if primo_segmento_attuale.get_global_rect().position.y > get_viewport_rect().size.y:
		
		# --- LOGICA DI RIORDINO CORRETTA ---
		
		# 1. Rimuoviamo il primo segmento dall'array e lo salviamo in una variabile.
		var segmento_spostato = segmenti.pop_front()
		
		# 2. Aggiungiamo lo stesso segmento alla fine dell'array.
		segmenti.push_back(segmento_spostato)
		
		# --- FINE LOGICA CORRETTA ---

		# Troviamo la posizione dell'ultimo segmento (che ora è il nostro "nuovo" ultimo)
		var ultimo_segmento = segmenti[-2] # L'elemento prima dell'ultimo che abbiamo appena spostato
		
		# Spostiamo il segmento in cima all'ultimo e cambiamo la sua texture
		segmento_spostato.position.y = ultimo_segmento.position.y - segment_height
		segmento_spostato.texture = get_prossima_texture()


func get_prossima_texture():
	var texture_da_usare
	if prossimo_texture_idx < textures.size():
		texture_da_usare = textures[prossimo_texture_idx]
		prossimo_texture_idx += 1
	else:
		texture_da_usare = textures.back()

	return texture_da_usare
