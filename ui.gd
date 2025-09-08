extends CanvasLayer

# Prendiamo una referenza alla nostra barra della vita
@onready var health_bar = $HealthBar
@onready var health_container = $HealthContainer
@onready var health_tick = $HealthContainer/TextureRect
var player = null

const SCENA_ICONA_VITA = preload("res://life_icon.tscn")
const SCENA_ICONA_ENERGY = preload("res://energy_icon.tscn")
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
		populate_health_bar()

func populate_health_bar():
	for i in player.energy_max:
		health_container.add_child(SCENA_ICONA_ENERGY.instantiate())

func update_health_bar(new_energy, energy_max):
	var total_point_toremove = energy_max - new_energy
	for n in health_container.get_children():
		n.free()

	for i in player.energy_max:
		var new_child: TextureRect = SCENA_ICONA_ENERGY.instantiate()
		if i >= new_energy:
			new_child.modulate = Color(0,0,0,0)
		health_container.add_child(new_child)

func on_energy_player_updated(new_energy, energy_max):
	update_health_bar(new_energy, energy_max)
