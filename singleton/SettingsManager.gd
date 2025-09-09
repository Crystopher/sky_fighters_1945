extends Node

const SAVE_PATH = "user://settings.json"

# Valori di default
var sfx_volume = 0.0
var music_volume = 0.0
var difficulty_multiplier = 4.0 # 1.0 = Normale
var default_difficulty_multiplier = 4.0 # 1.0 = Normale

func _ready():
	load_settings()

func save_settings():
	var settings_data = {
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"difficulty": difficulty_multiplier
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(settings_data))
	file.close()

func load_settings():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			sfx_volume = data.get("sfx_volume", 0.0)
			music_volume = data.get("music_volume", 0.0)
			difficulty_multiplier = data.get("difficulty", 4.0)

	# Applica subito le impostazioni audio caricate
	update_sfx_volume(sfx_volume)
	update_music_volume(music_volume)
	set_difficulty(difficulty_multiplier)

func update_sfx_volume(db_value):
	sfx_volume = db_value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_volume)

func update_music_volume(db_value):
	music_volume = db_value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)

func set_difficulty(multiplier):
	difficulty_multiplier = multiplier

func calculate_difficulty(value, criteria):
	var calculated_number = 0
	var multiplier_float = 1.0
	
	if difficulty_multiplier == 1: multiplier_float = 1.5
	elif difficulty_multiplier == 2: multiplier_float = 1.332
	elif difficulty_multiplier == 3: multiplier_float = 1.166
	elif difficulty_multiplier == 4: multiplier_float = 1.000
	elif difficulty_multiplier == 5: multiplier_float = 1.125
	elif difficulty_multiplier == 6: multiplier_float = 1.25
	elif difficulty_multiplier == 7: multiplier_float = 1.375
	elif difficulty_multiplier == 8: multiplier_float = 1.5
	
	if criteria == "add":
		if difficulty_multiplier > 4:
			calculated_number = value / multiplier_float
		elif difficulty_multiplier < 4:
			calculated_number = value * multiplier_float
		else:
			calculated_number = value
	elif criteria == "minus":
		if difficulty_multiplier > 4:
			calculated_number = value * multiplier_float
		elif difficulty_multiplier < 4:
			calculated_number = value / multiplier_float
		else:
			calculated_number = value
		
	return calculated_number
