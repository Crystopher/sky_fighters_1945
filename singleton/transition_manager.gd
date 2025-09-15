extends CanvasLayer

@onready var animation_player = $AnimationPlayer
var current_loading_thread = null

func _ready():
	# Assicurati che all'avvio la dissolvenza sia invisibile
	animation_player.play("fade_in")

func finish_async_scene_change(loaded_scene: PackedScene):
	if loaded_scene:
		get_tree().change_scene_to_packed(loaded_scene)
		animation_player.play("fade_in")
	else:
		push_error("Errore: Impossibile caricare la scena.")

	hide_loading_screen()
	current_loading_thread = null # Rilascia il thread

# Funzione per cambiare scena con un loading screen e progress bar
func change_scene_async(path: String):
	show_loading_screen()
	$LoadingScreen/ProgressBar.value = 0 # Resetta la barra

	await get_tree().process_frame # Un frame per mostrare la schermata

	current_loading_thread = Thread.new()
	current_loading_thread.start(func():
		var resource_loader = ResourceLoader
		resource_loader.load_threaded_request(path, "", false) # Inizia il caricamento in background

		var progress = []
		while resource_loader.load_threaded_get_status(path, progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				call_deferred("update_loading_progress", progress[0]) # Aggiorna la UI dal thread principale
			await get_tree().process_frame # Aspetta un frame per non bloccare il gioco
		call_deferred("update_loading_progress", 1.0)
		await get_tree().create_timer(0.3).timeout
		animation_player.play("fade_out")
		await animation_player.animation_finished
		var loaded_scene = resource_loader.load_threaded_get(path)

		# Quando il caricamento è completato nel thread, esegui il cambio scena nel thread principale
		call_deferred("finish_async_scene_change", loaded_scene)
	)

func update_loading_progress(progress_value):
	$LoadingScreen/ProgressBar.value = progress_value

func show_loading_screen():
	$LoadingScreen.visible = true
	animation_player.play("fade_in")
	await animation_player.animation_finished

func hide_loading_screen():
	$LoadingScreen.visible = false
		
func change_scene(percorso_scena):
	# 1. Dissolvi a nero
	animation_player.play("fade_out")

	# 2. Aspetta che l'animazione sia finita
	await animation_player.animation_finished
	#await get_tree().create_timer(3).timeout
	# 3. Cambia la scena
	get_tree().change_scene_to_file(percorso_scena)
	# 4. Dissolvi dalla schermata nera alla nuova scena
	animation_player.play("fade_in")


func _on_reasonable_wait_timeout() -> void:
	pass # Replace with function body.
