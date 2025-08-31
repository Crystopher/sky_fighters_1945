extends Area2D

var velocita = 600.0

@onready var suono_sparo = $Sparo
# _process viene chiamato a ogni frame, è ottimo per movimenti non legati alla fisica
# _process viene chiamato a ogni frame
func _ready() -> void:
	suono_sparo.play()
	
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
	queue_free() # Replace with function body.
