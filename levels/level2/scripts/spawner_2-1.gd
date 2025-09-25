extends "res://levels/level2/scripts/spawner_base.gd"

func _ready() -> void:
	LEVEL_ENEMY_WAVES = [
		{
			"name": "BossEntering",
			"type": "scene",
			"active": true,
			"scene": "boss_entering",
			"wait_before_start": 2.0,
			"wait_before_end": 4.0,
			"timeout": 3
		},
		{
			"name": "testboss",
			"type": "boss",
			"active": true,
			"enemies": [
				{"type": "boss_sharktwo", "number": 1, "wait": 1.0}
			]
		},
		{
			"name": "test", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_strafer", "number": 2, "wait": 2.0},
				{"type": "chopter_darc_shooter", "number": 2, "wait": 2.0},
				{"type": "chopter_dspitfire", "number": 2, "wait": 2.0},
				{"type": "chopter_dfollow", "number": 2, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 1.0},
				{"type": "chopter_dfollow", "number": 2, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 7.0},
				{"type": "chopter_dfollow", "number": 2, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 7.0},
			]
		},
	]
	super()
