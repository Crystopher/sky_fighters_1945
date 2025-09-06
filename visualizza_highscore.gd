extends Control

@onready var score_list_container = $ScoreListContainer
@onready var back_button = $BackButton

func _ready():
	# Connettiamo il pulsante Indietro
	back_button.pressed.connect(_on_back_button_pressed)

	# Carichiamo e visualizziamo i punteggi
	visualizza_punteggi()

func visualizza_punteggi():
	# Per prima cosa, carichiamo i punteggi (anche se dovrebbe essere già fatto dall'autoload)
	HighscoreManager.load_scores()

	# Puliamo la lista da eventuali elementi precedenti
	for child in score_list_container.get_children():
		child.queue_free()

	# Creiamo una riga per ogni punteggio salvato
	var i = 1
	for entry in HighscoreManager.high_scores:
		var nome = entry["name"]
		var punteggio = entry["score"]

		# Creiamo una label per la riga
		var riga_label = Label.new()
		# Usiamo la formattazione di stringa per allineare il testo
		riga_label.text = "%2d. %-3s ...... %d" % [i, nome, punteggio]

		# Aggiungiamo la riga al nostro contenitore
		score_list_container.add_child(riga_label)
		i += 1

func _on_back_button_pressed():
	TransitionManager.change_scene("res://menu_principale.tscn")
