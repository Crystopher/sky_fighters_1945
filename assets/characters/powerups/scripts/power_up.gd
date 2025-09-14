# Script: powerup.gd
extends Area2D

@export var powerup_data: PowerUpData # Collegheremo la risorsa qui
@onready var sprite = $Sprite2D
var velocita = 150

func _ready():
	if powerup_data and powerup_data.icon:
		sprite.texture = powerup_data.icon

	# Connetti il segnale per quando il giocatore lo raccoglie
	body_entered.connect(_on_body_entered)

func _process(delta):
	position.y += velocita * delta
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 100:
		queue_free() # +50 è un margine di sicurezza

func _on_body_entered(body):
	if body.is_in_group("giocatore"):
		$Obtained.play()
		$Sprite2D.visible = false
		$Sprite2D2.visible = false
		$CollisionShape2D.set_deferred_thread_group("disabled", true)
		$Message.visible = true
		$AnimationPlayer.play("glow")
		body.applica_powerup(powerup_data) # Chiamiamo una funzione nel giocatore
		await $AnimationPlayer.animation_finished
		queue_free() # Distruggiamo il power-up dopo la raccolta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("giocatore"):
		$Obtained.play()
		$Sprite2D.visible = false
		$Sprite2D2.visible = false
		$CollisionShape2D.set_deferred_thread_group("disabled", true)
		$Message.visible = true
		$AnimationPlayer.play("glow")
		area.applica_powerup(powerup_data) # Chiamiamo una funzione nel giocatore
		await $AnimationPlayer.animation_finished
		queue_free() # Distruggiamo il power-up dopo la raccolta
