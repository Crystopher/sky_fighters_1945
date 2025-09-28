extends Control

@onready var level_label = $Level

func _ready() -> void:
	level_label.text = "LEVEL " + str(GameManager.PLAYING_LEVEL_SCHEMA.schema["next_level"].replace(".", "-"))

func _on_load_level_timeout() -> void:
	$Label.visible = false
	$Level.visible = false
	TransitionManager.change_scene_async(GameManager.PLAYING_LEVEL_SCHEMA.schema["level_scene"])
	GameManager.supermoves_activated = GameManager.PLAYING_LEVEL_SCHEMA.schema["supermoves"]
