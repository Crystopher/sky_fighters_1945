extends Node2D

@onready var animation = $AnimationPlayer

func _ready() -> void:
	if animation:
		animation.play("play")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
