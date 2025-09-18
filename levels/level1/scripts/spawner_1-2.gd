extends "res://levels/level1/scripts/spawner_base.gd"

func _ready() -> void:
	LEVEL_ENEMY_WAVES = [
		{
			"name": "MissionExplain",
			"type": "scene",
			"active": true,
			"scene": "mission_explain",
			"wait_before_start": 1.0,
			"wait_before_end": 2.0,
			"timeout": 3
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
				{"type": "enemy_sniper", "number": 2, "wait": 2.0},
				{"type": "base", "number": 3, "wait": 1.0},
				{"type": "enemy_sniper", "number": 2, "wait": 1.0},
			]
		},
		{
			"name": "wave1", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "base", "number": 3, "wait": 1.0},
				{"type": "enemy_spitfire", "number": 4, "wait": 1.0}
			]
		},
		{
			"name": "wave2", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "enemy_strafer", "number": 3, "wait": 1.0},
				{"type": "enemy_spitfire", "number": 1, "wait": 2.0},
				{"type": "base", "number": 2, "wait": 1.5},
				{"type": "enemy_orbital", "number": 2, "wait": 1.5},
			]
		},
		{
			"name": "wave3", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "base", "number": 8, "wait": 1.5},
				{"type": "base", "number": 6, "wait": 0.5},
				{"type": "base", "number": 4, "wait": 0.5},
				{"type": "base", "number": 8, "wait": 0.5},
			]
		},
		{
			"name": "wave4", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "enemy_spitfire", "number": 3, "wait": 1.5},
				{"type": "base", "number": 4, "wait": 0.5},
				{"type": "enemy_spitfire", "number": 2, "wait": 1.5},
				{"type": "base", "number": 3, "wait": 0.5},
				{"type": "enemy_strafer", "number": 2, "wait": 1.5}
			]
		},
		{
			"name": "wave5", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "enemy_spitfire", "number": 3, "wait": 1.5},
				{"type": "base", "number": 6, "wait": 0.5},
				{"type": "enemy_strafer", "number": 1, "wait": 1.5},
				{"type": "enemy_orbital", "number": 4, "wait": 1.5},
			]
		},
		{
			"name": "wave6", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "enemy_spitfire", "number": 3, "wait": 1.5},
				{"type": "base", "number": 6, "wait": 0.5},
				{"type": "enemy_strafer", "number": 1, "wait": 1.5},
				{"type": "enemy_orbital", "number": 2, "wait": 1.5},
			]
		},
		{
			"name": "wave7", 
			"active": true,
			"type": "enemy",
			"enemies": [
				{"type": "enemy_sniper", "number": 5, "wait": 2.0},
				{"type": "enemy_orbital", "number": 2, "wait": 2.0},
				{"type": "enemy_spitfire", "number": 2, "wait": 2.0},
				{"type": "base", "number": 2, "wait": 1.5},
				{"type": "enemy_strafer", "number": 2, "wait": 1.5}
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
			"name": "EagleBoss2",
			"type": "boss",
			"active": true,
			"enemies": [
				{"type": "boss_eagleone", "number": 1, "wait": 1.0}
			]
		},
		{
			"name": "EndLevel02",
			"type": "scene",
			"active": true,
			"scene": "end_level02",
			"wait_before_start": 1.0,
			"wait_before_end": 4.0,
			"timeout": 3
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
