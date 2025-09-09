extends Control

@onready var score_label = $ScoreLabel
@onready var confirm_button = $ConfirmButton
@onready var lettere = [$HBoxContainer/VBoxContainer1/Lettera1, $HBoxContainer/VBoxContainer2/Lettera2, $HBoxContainer/VBoxContainer3/Lettera3]

var punteggio_attuale = 0
var lettera_selezionata = 0
var caratteri = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

@onready var freccia_su_1 = $HBoxContainer/VBoxContainer1/freccia_su_1
@onready var freccia_su_2 = $HBoxContainer/VBoxContainer2/freccia_su_2
@onready var freccia_su_3 = $HBoxContainer/VBoxContainer3/freccia_su_3

@onready var freccia_giu_1 = $HBoxContainer/VBoxContainer1/freccia_giu_1
@onready var freccia_giu_2 = $HBoxContainer/VBoxContainer2/freccia_giu_2
@onready var freccia_giu_3 = $HBoxContainer/VBoxContainer3/freccia_giu_3

@onready var freccia_sinistra = $HBoxContainer/freccia_sinistra
@onready var freccia_destra = $HBoxContainer/freccia_destra

func _ready():
	# Prendiamo il punteggio dal GameManager (che lo avrà salvato temporaneamente)
	punteggio_attuale = GameManager.ultimo_punteggio
	score_label.text = "SCORE: " + str(punteggio_attuale)
	
	confirm_button.pressed.connect(salva_e_chiudi)
	
	$HBoxContainer/VBoxContainer1/freccia_su_1.pressed.connect(cambia_lettera.bind(1)) # 1 per "su"
	$HBoxContainer/VBoxContainer1/freccia_giu_1.pressed.connect(cambia_lettera.bind(-1)) # -1 per "giù"
	
	$HBoxContainer/VBoxContainer2/freccia_su_2.pressed.connect(cambia_lettera.bind(1)) # 1 per "su"
	$HBoxContainer/VBoxContainer2/freccia_giu_2.pressed.connect(cambia_lettera.bind(-1)) # -1 per "giù"
	
	$HBoxContainer/VBoxContainer3/freccia_su_3.pressed.connect(cambia_lettera.bind(1)) # 1 per "su"
	$HBoxContainer/VBoxContainer3/freccia_giu_3.pressed.connect(cambia_lettera.bind(-1)) # -1 per "giù"
	
	$HBoxContainer/freccia_sinistra.pressed.connect(cambia_slot.bind(-1)) # -1 per "sinistra"
	$HBoxContainer/freccia_destra.pressed.connect(cambia_slot.bind(1)) # 1 per "destra"
	
	aggiorna_cursore()

func cambia_lettera(direzione): # direzione è +1 per su, -1 per giù
	var char_idx = caratteri.find(lettere[lettera_selezionata].text)
	char_idx = (char_idx + direzione + caratteri.length()) % caratteri.length()
	lettere[lettera_selezionata].text = caratteri[char_idx]

func cambia_slot(direzione): # direzione è +1 per destra, -1 per sinistra
	lettera_selezionata = (lettera_selezionata + direzione + 3) % 3
	aggiorna_cursore()

func _input(event):
	if event is InputEventKey and event.pressed:
		var char_idx = caratteri.find(lettere[lettera_selezionata].text)

		if event.is_action("ui_up"):
			char_idx = (char_idx + 1) % caratteri.length()
		elif event.is_action("ui_down"):
			char_idx = (char_idx - 1 + caratteri.length()) % caratteri.length()
		elif event.is_action("ui_left"):
			lettera_selezionata = (lettera_selezionata - 1 + 3) % 3
		elif event.is_action("ui_right"):
			lettera_selezionata = (lettera_selezionata + 1) % 3
		elif event.is_action("ui_accept"): # Tasto Invio
			salva_e_chiudi()
			return

		lettere[lettera_selezionata].text = caratteri[char_idx]
		aggiorna_cursore()

func aggiorna_cursore():
	for i in range(lettere.size()):
		lettere[i].modulate = Color.WHITE if i == lettera_selezionata else Color.GRAY

func salva_e_chiudi():
	var nome = lettere[0].text + lettere[1].text + lettere[2].text
	HighscoreManager.add_score(
		nome,
		GameManager.ultimo_punteggio,
		GameManager.ultima_difficolta,
		GameManager.ultimo_aereo
	)
	TransitionManager.change_scene("res://menu_principale.tscn") # Torna al menu
