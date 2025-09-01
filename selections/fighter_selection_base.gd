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
		energy_value = v
		$Energy/EnergyBar01.visible = false
		$Energy/EnergyBar02.visible = false
		$Energy/EnergyBar03.visible = false
		$Energy/EnergyBar04.visible = false
		var EnergySelected = $Energy.get_node(str("EnergyBar0", energy_value))
		EnergySelected.visible = true
	get():
		if energy_value == null:
			energy_value = 1
		return energy_value

@onready var power_value = 1

@export var Power := 1:
	set(v):
		power_value = v
		$Power/PowerBar01.visible = false
		$Power/PowerBar02.visible = false
		$Power/PowerBar03.visible = false
		$Power/PowerBar04.visible = false
		var Selected = $Power.get_node(str("PowerBar0", power_value))
		Selected.visible = true
	get():
		if power_value == null:
			power_value = 1
		return power_value

@onready var velocity_value = 1

@export var Velocity := 1:
	set(v):
		velocity_value = v
		$Velocity/VelocityBar01.visible = false
		$Velocity/VelocityBar02.visible = false
		$Velocity/VelocityBar03.visible = false
		$Velocity/VelocityBar04.visible = false
		var Selected = $Velocity.get_node(str("VelocityBar0", velocity_value))
		Selected.visible = true
	get():
		if velocity_value == null:
			velocity_value = 1
		return velocity_value

@export var Name := "Green Berret":
	set(v):
		if $Name != null:
			$Name.text = v
	get:
		return $Name.text

@export_enum("Green", "Blue", "Red") var PlaneType := "Green":
	set(v):
		selectedFighterName = v
		if v != null:
			if $Green != null:
				$Green.visible = false
			if $Blue != null:
				$Blue.visible = false
			if $Red != null:
				$Red.visible = false
			var ControlSelected = get_node(v)
			if ControlSelected != null:
				ControlSelected.visible = true
	get:
		return selectedFighterName

@export var HeroKey: String


func _on_button_pressed() -> void:
	fighter_selected.emit(HeroKey, self)
