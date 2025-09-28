extends "res://levels/level2/scripts/spawner_base.gd"

func _ready() -> void:
	LEVEL_ENEMY_WAVES = [
		{
			"name": "BossEntering",
			"type": "scene",
			"active": false,
			"scene": "boss_entering",
			"wait_before_start": 2.0,
			"wait_before_end": 4.0,
			"timeout": 3
		},
		{
			"name": "testboss",
			"type": "boss",
			"active": false,
			"enemies": [
				{"type": "boss_sharktwo", "number": 1, "wait": 1.0}
			]
		},
		{
			"name": "test", 
			"active": false,
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
		{
			"name": "MissionStart",
			"type": "scene",
			"active": true,
			"scene": "mission_start",
			"wait_before_start": 1.0,
			"wait_before_end": 3.0,
			"timeout": 3
		},
		{
			"name": "wave0", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_dspitfire", "number": 3, "wait": 2.0}
			]
		},
		{
			"name": "wave1", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 3, "wait": 1.0}
			]
		},
		{
			"name": "wave2", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 2, "wait": 2.0},
				{"type": "chopter_dspitfire", "number": 1, "wait": 1.5},
				{"type": "chopter_darc_shooter", "number": 1, "wait": 1.0}
			]
		},
		{
			"name": "wave3", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 1, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 1, "wait": 0.5},
				{"type": "chopter_darc_shooter", "number": 1, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 1, "wait": 0.5},
				{"type": "chopter_strafer", "number": 2, "wait": 1.5}
			]
		},
		{
			"name": "wave4", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 1, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 1, "wait": 1.5},
				{"type": "chopter_darc_shooter", "number": 1, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 1, "wait": 1.5},
				{"type": "chopter_strafer", "number": 3, "wait": 1.5}
			]
		},
		{
			"name": "wave5", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 3, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 2, "wait": 2.5},
				{"type": "chopter_strafer", "number": 1, "wait": 1.5},
				{"type": "enemy_turret", "number": 1, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 5.0},
			]
		},
		{
			"name": "wave6", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 3, "wait": 1.5},
				{"type": "chopter_dspitfire", "number": 2, "wait": 3.5},
				{"type": "chopter_strafer", "number": 1, "wait": 1.5},
				{"type": "enemy_turret", "number": 1, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 5.0},
			]
		},
		{
			"name": "wave7", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "chopter_darc_shooter", "number": 2, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 2.0},
				{"type": "enemy_turret", "number": 1, "wait": 5.0},
				{"type": "chopter_darc_shooter", "number": 2, "wait": 2.0},
				{"type": "chopter_dspitfire", "number": 2, "wait": 1.5},
				{"type": "chopter_strafer", "number": 2, "wait": 1.5}
			]
		},
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
			"name": "SharkBoss1",
			"type": "boss",
			"active": true,
			"enemies": [
				{"type": "boss_sharktwo", "number": 1, "wait": 1.0}
			]
		},
		{
			"name": "MissionComplete",
			"type": "scene",
			"active": true,
			"scene": "mission_complete",
			"wait_before_start": 1.0,
			"wait_before_end": 4.0,
			"timeout": 3
		}
	]
	super()
