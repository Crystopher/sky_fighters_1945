extends Control

@onready var progress_bar = $ProgressBar
@onready var label = $Label

# La scena che vogliamo caricare in background
var percorso_scena_da_caricare = "res://menu_principale.tscn"

# Questa variabile-array verrà usata per tracciare l'avanzamento
var progress = []

func _ready():
	# Avviamo la richiesta di caricamento
	ResourceLoader.load_threaded_request(percorso_scena_da_caricare)
	label.text = "Caricamento..."

func _process(delta):
	# Controlliamo lo stato passando l'array 'progress' come secondo argomento
	var stato_caricamento = ResourceLoader.load_threaded_get_status(percorso_scena_da_caricare, progress)
	
	match stato_caricamento:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Se sta caricando, aggiorniamo la barra usando il valore nell'array
			progress_bar.value = progress[0] * 100
			label.text = "Caricamento... %d%%" % progress_bar.value

		ResourceLoader.THREAD_LOAD_LOADED:
			# Se ha finito, prendiamo la risorsa e cambiamo scena
			var scena_caricata = ResourceLoader.load_threaded_get(percorso_scena_da_caricare)
			get_tree().change_scene_to_packed(scena_caricata)

		ResourceLoader.THREAD_LOAD_FAILED:
			label.text = "Errore nel caricamento!"
			print("Errore nel caricamento della scena: ", percorso_scena_da_caricare)
