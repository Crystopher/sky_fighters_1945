@tool

extends Control

signal fighter_selected(hero_selected_key, fighter)

@onready var bgColor = $Bg.color
var selectedFighterName = "Green"
var is_selected := false:
	set(value):
		_highlightSelection(value)

func _highlightSelection(selected):
	if selected:
		$Bg.color = Color("0000003c")
	else:
		$Bg.color = bgColor

@onready var energy_value = 1

@export var Energy := 1:
	set(v):
		if $GridContainer/Details/EnergyBar != null and v != null:
			energy_value = v
			$GridContainer/Details/EnergyBar.value = v
	get():
		if energy_value == null:
			energy_value = 1
		return energy_value

@onready var power_value = 1

@export var Power := 1:
	set(v):
		if $GridContainer/Details/PowerBar != null and v != null:
			power_value = v
			$GridContainer/Details/PowerBar.value = v
	get():
		if power_value == null:
			power_value = 1
		return power_value

@onready var velocity_value = 1

@export var Velocity := 1:
	set(v):
		if $GridContainer/Details/VelocityBar != null and v != null:
			velocity_value = v
			$GridContainer/Details/VelocityBar.value = v
	get():
		if velocity_value == null:
			velocity_value = 1
		return velocity_value

var name_string = "PIPPO"

@export var Name := "PIPPO":
	set(v):
		if $GridContainer/Avatar/Name != null and v != null:
			name_string = v
			$GridContainer/Avatar/Name.text = v
	get:
		if name_string == null:
			return ""
		return $GridContainer/Avatar/Name.text

@export_enum("Green", "Blue", "Red") var PlaneType := "Green":
	set(v):
		selectedFighterName = v
		if v != null:
			if $GridContainer/Avatar/Green != null:
				$GridContainer/Avatar/Green.visible = false
			if $GridContainer/Avatar/Blue != null:
				$GridContainer/Avatar/Blue.visible = false
			if $GridContainer/Avatar/Red != null:
				$GridContainer/Avatar/Red.visible = false
			var ControlSelected = get_node("GridContainer/Avatar/"+ v)
			if ControlSelected != null:
				ControlSelected.visible = true
	get:
		return selectedFighterName

@export var HeroKey: String


func _on_button_pressed() -> void:
	fighter_selected.emit(HeroKey, self)
	$HitSound.play()
