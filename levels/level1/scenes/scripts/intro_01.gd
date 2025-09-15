extends Control

@onready var animation_player = $intro01_1_player
@onready var foot_steps_sound = $Footsteps
@onready var engine_start = $EngineStart

var SCENA_LIVELLO_PRINCIPALE = "res://levels/level1/livello_1-1.tscn"

func _ready() -> void:
	animation_player.play("intro01_1")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro01_1":
		animation_player.play("intro01_2")
		foot_steps_sound.play()
	elif anim_name == "intro01_2":
		animation_player.play("intro01_3")
		engine_start.play()
	elif anim_name == "intro01_3":
		TransitionManager.change_scene_async(SCENA_LIVELLO_PRINCIPALE)

func _on_skip_pressed() -> void:
	animation_player.stop()
	TransitionManager.change_scene_async(SCENA_LIVELLO_PRINCIPALE)
