extends "res://levels/level2/scripts/spawner_base.gd"

func _ready() -> void:
	LEVEL_ENEMY_WAVES = [
		{
			"name": "test", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_dspitfire", "number": 2, "wait": 2.0},
				{"type": "chopter_dfollow", "number": 2, "wait": 2.0},
			]
		},
	]
	super()
