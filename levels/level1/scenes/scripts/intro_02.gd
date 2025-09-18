extends Control

@onready var animation_player = $intro01_1_player
@onready var mech_install_sound = $MechInstallation

var SCENA_LIVELLO_PRINCIPALE = "res://levels/level1/livello_1-2.tscn"

func _ready() -> void:
	animation_player.play("intro01_1")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro01_1":
		animation_player.play("intro01_2")
		mech_install_sound.play()
	elif anim_name == "intro01_2":
		TransitionManager.change_scene_async(SCENA_LIVELLO_PRINCIPALE)

func _on_skip_pressed() -> void:
	animation_player.stop()
	TransitionManager.change_scene_async(SCENA_LIVELLO_PRINCIPALE)
