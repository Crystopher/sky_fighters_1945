# Script: powerup.gd
extends Area2D

@export var powerup_data: PowerUpData # Collegheremo la risorsa qui
@onready var sprite = $Sprite2D

func _ready():
	if powerup_data and powerup_data.icona:
		sprite.texture = powerup_data.icona

	# Connetti il segnale per quando il giocatore lo raccoglie
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("giocatore"):
		body.applica_powerup(powerup_data) # Chiamiamo una funzione nel giocatore
		queue_free() # Distruggiamo il power-up dopo la raccolta
