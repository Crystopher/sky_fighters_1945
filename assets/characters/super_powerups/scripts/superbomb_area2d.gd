extends Area2D

@export var damage = 20.0
var current_damage
@export var keep_visible = true

func _ready() -> void:
	current_damage = damage
