extends Control

@onready var fighter01 = $GridContainer/Fighter01
@onready var fighter02 = $GridContainer/Fighter02
@onready var fighter03 = $GridContainer/Fighter03

var selection = null

func _on_button_2_button_down() -> void:
	$Click.play()

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level1/livello_1-1.tscn")

func _ready() -> void:
	var fighters_selection = get_tree().get_nodes_in_group("player_selection")
	for fighter_select in fighters_selection:
		fighter_select.fighter_selected.connect(on_fighter_selection)

func on_fighter_selection(hero_key, fighter):
	selection = fighter
	var fighters_selection = get_tree().get_nodes_in_group("player_selection")
	for fighter_select in fighters_selection:
		fighter_select.is_selected = false
		
	selection.is_selected = true
	GameManager.giocatore_selezionato = hero_key
