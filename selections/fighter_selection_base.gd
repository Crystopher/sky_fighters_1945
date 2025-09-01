@tool

extends Control

signal fighter_selected(hero_selected_key, fighter)

@onready var bgColor = $Bg.color

var is_selected := false:
	set(value):
		_highlightSelection(value)

func _highlightSelection(selected):
	if selected:
		$Bg.color = Color("0000003c")
	else:
		$Bg.color = bgColor
		

@export var Name := "Green Berret":
	set(v):
		if $Name != null:
			$Name.text = v
	get:
		return $Name.text

@export var Description: String:
	set(value):
		if $Description != null:
			$Description.text = value
	get:
		return $Description.text

@export var Avatar: Color:
	set(value): 
		if $Avatar != null:
			$Avatar.color = value
	get:
		return $Avatar.color

@export var HeroKey: String


func _on_button_pressed() -> void:
	fighter_selected.emit(HeroKey, self)
