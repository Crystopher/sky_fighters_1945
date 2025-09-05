extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func _ready():
	# Assicurati che all'avvio la dissolvenza sia invisibile
	animation_player.play("fade_in")

func change_scene(percorso_scena):
	# 1. Dissolvi a nero
	animation_player.play("fade_out")

	# 2. Aspetta che l'animazione sia finita
	await animation_player.animation_finished

	# 3. Cambia la scena
	get_tree().change_scene_to_file(percorso_scena)

	# 4. Dissolvi dalla schermata nera alla nuova scena
	animation_player.play("fade_in")
