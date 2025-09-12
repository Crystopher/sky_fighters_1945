extends "res://assets/bosses/weapons/scripts/weapon_base_boss.gd"

# Questa variabile permette a chi crea il proiettile (lo splitter)
# di dirgli in quale direzione viaggiare.
@onready var suono_colpo = $SuonoSparo

func _ready() -> void:
	suono_colpo.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
