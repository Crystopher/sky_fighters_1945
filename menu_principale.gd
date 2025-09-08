extends Control

func _on_button_pressed() -> void:
	# get_tree() si riferisce all'albero delle scene del gioco.
	# change_scene_to_file() carica una nuova scena, distruggendo quella attuale.
	# "res://" è il percorso della cartella principale del tuo progetto.
	#get_tree().change_scene_to_file("res://levels/livello_1-1.tscn")
	#get_tree().change_scene_to_file("res://player_selection.tscn")
	TransitionManager.change_scene("res://player_selection.tscn")

func _on_button_2_pressed() -> void:
	# Questo comando chiude l'applicazione.
	# Nota: funziona solo quando il gioco è stato esportato,
	# non sempre chiude la finestra dell'editor di Godot.
	get_tree().quit()

func _on_button_button_down() -> void:
	$Click.play()

func _on_button_2_button_down() -> void:
	$Click.play()

func _on_button_3_pressed() -> void:
	TransitionManager.change_scene("res://visualizza_highscore.tscn")

func _on_button_3_button_down() -> void:
	$Click.play()
