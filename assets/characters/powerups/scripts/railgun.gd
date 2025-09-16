extends Area2D

@export var velocita = 600.0
@export var damage = 1.0
var current_damage
var sound_delay = 0.0
var sound_mute = false

@export var keep_visible = false

var is_right = false
var is_left = false

# _process viene chiamato a ogni frame, è ottimo per movimenti non legati alla fisica
# _process viene chiamato a ogni frame
func _ready() -> void:
	current_damage = damage
	if not sound_mute:
		get_tree().create_timer(sound_delay).timeout
		AudioManager.weapon_railgun()
	
	if $Rotation != null:
		$Rotation.play("rotation")
	
func _process(delta):
	# Il movimento verso l'alto non cambia
	position.y -= velocita * delta

	# NUOVA LOGICA DI CANCELLAZIONE:
	# Chiediamo al gioco le dimensioni attuali della finestra/viewport.
	var screen_size = get_viewport_rect().size

	# Distruggiamo il proiettile se la sua posizione Y è minore di 0 (oltre il bordo superiore)
	# o se per qualche motivo dovesse andare oltre il bordo inferiore (screen_size.y).
	if position.y < 0 or position.y > screen_size.y:
		queue_free() # Questo comando distrugge il nodo in modo sicuro

func _on_area_entered(area: Area2D) -> void:
	#queue_free() # Replace with function body.
	pass

func _on_thunder_timer_timeout() -> void:
	AudioManager.weapon_thunder()
	$CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D2.set_deferred("disabled", false)
	$TextureRect.visible = true
	$ThunderTimer2.start()

func _on_thunder_timer_2_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D2.set_deferred("disabled", true)
	$TextureRect.visible = false
	$ThunderTimer.start()
