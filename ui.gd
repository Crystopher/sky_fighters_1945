extends CanvasLayer

# Prendiamo una referenza alla nostra barra della vita
@onready var health_bar = $HealthBar
var player = null

const SCENA_ICONA_VITA = preload("res://life_icon.tscn")
@onready var vite_container = $ViteContainer

func aggiorna_icone_vita(numero_vite):
	# Prima cancelliamo tutte le icone vecchie
	for icona in vite_container.get_children():
		icona.queue_free()

	# Poi creiamo le nuove icone
	for i in range(numero_vite):
		vite_container.add_child(SCENA_ICONA_VITA.instantiate())

func _ready():
	# Aspettiamo che la scena sia completamente caricata per trovare il giocatore
	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("giocatore")

	# Connettiamoci al segnale del GameManager
	GameManager.vite_aggiornate.connect(aggiorna_icone_vita)
	# Mostriamo le vite iniziali
	aggiorna_icone_vita(GameManager.vite_rimanenti)

	if player:
		# Connettiamo la funzione di aggiornamento al segnale del giocatore
		player.energy_updated.connect(on_energy_player_updated)

		# Impostiamo i valori iniziali della barra
		health_bar.max_value = player.energy_max
		health_bar.value = player.current_energy

func on_energy_player_updated(new_energy, energy_max):
	health_bar.value = new_energy
