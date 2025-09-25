extends Control

@onready var fighter01 = $GridContainer/Fighter01
@onready var fighter02 = $GridContainer/Fighter02
@onready var fighter03 = $GridContainer/Fighter03

var selection = null

func _on_button_2_button_down() -> void:
	$Click.play()

func _on_button_2_pressed() -> void:
	#get_tree().change_scene_to_file("res://levels/level1/livello_1-1.tscn")
	#TransitionManager.change_scene("res://levels/level1/livello_1-1.tscn")
	#TransitionManager.change_scene("res://levels/level1/scenes/intro01.tscn")
	TransitionManager.change_scene("res://levels/level2/livello_2-1.tscn")

func _ready() -> void:
	var fighters_selection = get_tree().get_nodes_in_group("player_selection")
	for fighter_select in fighters_selection:
		fighter_select.fighter_selected.connect(on_fighter_selection)
	
	fighter01.Energy = 3
	fighter01.Power = 3
	fighter01.Velocity = 3
	
	fighter02.Energy = 2
	fighter02.Power = 2
	fighter02.Velocity = 4
	
	fighter03.Energy = 4
	fighter03.Power = 4
	fighter03.Velocity = 2

func on_fighter_selection(hero_key, fighter):
	selection = fighter
	var fighters_selection = get_tree().get_nodes_in_group("player_selection")
	for fighter_select in fighters_selection:
		fighter_select.is_selected = false
		
	selection.is_selected = true
	GameManager.giocatore_selezionato = hero_key


func _on_menu_button_button_down() -> void:
	$Click.play()

func _on_menu_button_pressed() -> void:
	TransitionManager.change_scene("res://menu_principale.tscn")
