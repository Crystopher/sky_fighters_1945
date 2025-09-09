extends Control

@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var difficulty_slider = $DifficultySlider
@onready var back_button = $Back

func _ready():
	# Inizializza i valori della UI con quelli salvati
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	difficulty_slider.value = SettingsManager.difficulty_multiplier

	# Connetti i segnali
	music_slider.value_changed.connect(SettingsManager.update_music_volume)
	sfx_slider.value_changed.connect(SettingsManager.update_sfx_volume)
	difficulty_slider.value_changed.connect(SettingsManager.set_difficulty)

	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	SettingsManager.save_settings()
	TransitionManager.change_scene("res://menu_principale.tscn")
