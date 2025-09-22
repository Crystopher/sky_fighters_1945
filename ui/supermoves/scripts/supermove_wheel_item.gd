# Script: supermove_wheel_item.gd
extends Control

class_name SupermoveWheelItem

@onready var super_button = $SuperMoveButton
@onready var icon = $TextureButton/SupermoveIcon
@onready var cooldown_bar = $CooldownProgressBar

var supermove_data: SuperMoveData = null
signal selected(supermove_type)

func _ready():
	cooldown_bar.value = 1.0 # Inizia a pieno
	cooldown_bar.visible = false # Nascondi fino a quando non in cooldown

func setup(sm_data: SuperMoveData):
	supermove_data = sm_data
	if sm_data:
		super_button.icon = sm_data.icon
		super_button.disabled = false
	else:
		super_button.disabled = true
	update_cooldown_display(1.0) # Mostra come pronto all'uso

func update_cooldown_display(progress: float):
	if supermove_data == null: return

	cooldown_bar.value = progress
	if progress >= 1.0: # Pronto
		super_button.modulate = Color(1, 1, 1, 1)
		cooldown_bar.visible = false
	else: # In cooldown
		super_button.modulate = Color(0.7, 0.7, 0.7, 0.7)
		cooldown_bar.visible = true
		# countdown_label.text = str(int(supermove_data.cooldown * (1.0 - progress)) + 1)

func _on_texture_button_pressed():
	if supermove_data and GameManager.get_player_node().supermove_cooldowns.get(supermove_data.type, 0.0) <= 0.0:
		selected.emit(supermove_data.type)

func _on_super_move_button_pressed() -> void:
	if supermove_data and GameManager.get_player_node().supermove_cooldowns.get(supermove_data.type, 0.0) <= 0.0:
		selected.emit(supermove_data.type)
