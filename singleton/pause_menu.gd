extends CanvasLayer

# Riferimenti ai pulsanti
@onready var continua_button = $ContinueButton # Assicurati che i nomi corrispondano
@onready var menu_button = $BackButton
@onready var esci_button = $ExitButton

func _ready():
	# Nascondi il menu all'avvio del gioco
	hide()

	# Connetti i segnali dei pulsanti
	continua_button.pressed.connect(toggle_pause)
	menu_button.pressed.connect(_on_torna_al_menu_pressed)
	esci_button.pressed.connect(_on_esci_dal_gioco_pressed)

# Questa funzione viene eseguita a ogni input, anche quando il gioco è in pausa
func _unhandled_input(event):
	# Controlliamo se è stata premuta l'azione "pausa"
	if event.is_action_pressed("pausa"):
		toggle_pause()

func toggle_pause():
	# Inverti lo stato di pausa del gioco
	get_tree().paused = not get_tree().paused

	# Mostra o nascondi il menu di conseguenza
	visible = get_tree().paused

func _on_torna_al_menu_pressed():
	# FONDAMENTALE: riattiva il gioco prima di cambiare scena
	toggle_pause()
	GameManager.reset_level()
	GameManager.clean_up_level()
	TransitionManager.change_scene("res://menu_principale.tscn")

func _on_esci_dal_gioco_pressed():
	toggle_pause()
	get_tree().quit()
