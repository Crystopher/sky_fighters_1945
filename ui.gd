extends CanvasLayer

# Prendiamo una referenza alla nostra barra della vita
@onready var health_bar = $HealthBar
var player = null

func _ready():
	# Aspettiamo che la scena sia completamente caricata per trovare il giocatore
	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("giocatore")

	if player:
		# Connettiamo la funzione di aggiornamento al segnale del giocatore
		player.energy_updated.connect(on_energy_player_updated)

		# Impostiamo i valori iniziali della barra
		health_bar.max_value = player.energy_max
		health_bar.value = player.current_energy

func on_energy_player_updated(new_energy, energy_max):
	health_bar.value = new_energy
