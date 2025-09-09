extends Control

@onready var score_list_container = $ScoreListContainer
@onready var global_button = $HBoxContainer/Global

@onready var difficulty1_button = $HBoxContainer2/Difficulty1
@onready var difficulty2_button = $HBoxContainer2/Difficulty2
@onready var difficulty3_button = $HBoxContainer2/Difficulty3
@onready var difficulty4_button = $HBoxContainer2/Difficulty4
@onready var difficulty5_button = $HBoxContainer2/Difficulty5
@onready var difficulty6_button = $HBoxContainer2/Difficulty6
@onready var difficulty7_button = $HBoxContainer2/Difficulty7
@onready var difficulty8_button = $HBoxContainer2/Difficulty8

@onready var green_button = $HBoxContainer3/GreentBerret
@onready var blue_button = $HBoxContainer3/BluThunder
@onready var red_button = $HBoxContainer3/RedRibbon

@onready var back_button = $BackButton

func _on_filtro_difficolta_premuto(difficolta):
	var scores_filtrati = HighscoreManager.get_scores_by_difficulty(difficolta)
	visualizza_punteggi(scores_filtrati)
	
func _on_filtro_aereo_premuto(aereo):
	var scores_filtrati = HighscoreManager.get_scores_by_plane(aereo)
	visualizza_punteggi(scores_filtrati)

func _ready():
	global_button.pressed.connect(visualizza_punteggi.bind(HighscoreManager.high_scores))
	
	difficulty1_button.pressed.connect(_on_filtro_difficolta_premuto.bind(1))
	difficulty2_button.pressed.connect(_on_filtro_difficolta_premuto.bind(2))
	difficulty3_button.pressed.connect(_on_filtro_difficolta_premuto.bind(3))
	difficulty4_button.pressed.connect(_on_filtro_difficolta_premuto.bind(4))
	difficulty5_button.pressed.connect(_on_filtro_difficolta_premuto.bind(5))
	difficulty6_button.pressed.connect(_on_filtro_difficolta_premuto.bind(6))
	difficulty7_button.pressed.connect(_on_filtro_difficolta_premuto.bind(7))
	difficulty8_button.pressed.connect(_on_filtro_difficolta_premuto.bind(8))
	
	green_button.pressed.connect(_on_filtro_aereo_premuto.bind("verde"))
	blue_button.pressed.connect(_on_filtro_aereo_premuto.bind("blue"))
	red_button.pressed.connect(_on_filtro_aereo_premuto.bind("rosso"))
	# Connettiamo il pulsante Indietro
	back_button.pressed.connect(_on_back_button_pressed)

	# Carichiamo e visualizziamo i punteggi
	visualizza_punteggi(HighscoreManager.high_scores)

func visualizza_punteggi(lista_punteggi):
	for child in score_list_container.get_children():
		child.queue_free()

	var i = 1
	for entry in lista_punteggi:
		var plane_name = ""
		var nome = entry["name"]
		var punteggio = entry["score"]
		if entry["plane"].to_lower() == "verde": plane_name = "GREEN BERRET"
		elif entry["plane"].to_lower() == "blue": plane_name = "BLUE THUNDER"
		elif entry["plane"].to_lower() == "rosso": plane_name = "RED RIBBON"
		var aereo = plane_name # Es. "VERDE"

		var riga_label = Label.new()
		# Formattiamo la stringa per includere l'aereo
		riga_label.text = "%2d. %-3s ...... %-8d (%s)" % [i, nome, punteggio, aereo]
		score_list_container.add_child(riga_label)
		i += 1

func _on_back_button_pressed():
	TransitionManager.change_scene("res://menu_principale.tscn")
