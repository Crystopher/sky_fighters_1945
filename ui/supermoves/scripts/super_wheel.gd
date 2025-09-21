extends Control

var is_open: bool = false
var player_node = null

@export var supermove_item_scene: PackedScene # Collegheremo supermove_wheel_item.tscn qui
@export var radius: float = 150.0 # Raggio della ruota
@export var animation_duration: float = 0.2 # Durata animazione apertura/chiusura

var items: Array[SupermoveWheelItem] = []

func toggle_wheel_visibility(player_node_instance):
	if not player_node:
		player_node = player_node_instance
		player_node.supermove_status_updated.connect(_on_supermove_status_updated)
		player_node.supermove_activated.connect(_on_supermove_activated)
		
		for super_move in GameManager.supermoves_activated:
			player_node.add_supermove(load(super_move))
		
	is_open = not is_open
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	if is_open:
		setup_wheel_items() # Crea gli slot iniziali
		visible = true
		tween.tween_property(self, "modulate", Color(1,1,1,1), animation_duration)
		tween.tween_property(self, "scale", Vector2(1,1), animation_duration)
		await tween.finished
		get_tree().paused = true # Metti in pausa il gioco mentre la ruota è aperta
	else:
		tween.tween_property(self, "modulate", Color(1,1,1,0), animation_duration)
		tween.tween_property(self, "scale", Vector2(0.8,0.8), animation_duration) # Rimpicciolisci leggermente
		await tween.finished
		visible = false
		get_tree().paused = false # Togli la pausa

func _ready():
	pass

func setup_wheel_items():
	# Pulisce gli item precedenti
	for child in items:
		child.queue_free()
	items.clear()

	# Recupera le supermosse dal giocatore
	if player_node:
		var acquired_supermoves = player_node.supermove_enabled
		var angle_step = TAU / acquired_supermoves.size() if acquired_supermoves.size() > 0 else 0.0

		for i in range(acquired_supermoves.size()):
			var sm_data = acquired_supermoves[i]
			var item_instance = supermove_item_scene.instantiate()
			item_instance.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(item_instance)
			item_instance.setup(sm_data)
			item_instance.selected.connect(_on_supermove_item_selected)
			items.append(item_instance)

			# Posiziona l'item sulla circonferenza
			var angle = angle_step * i - (TAU / 4.0) # Inizia da "su" e va in senso orario
			var item_pos = Vector2(cos(angle), sin(angle)) * radius
			item_instance.position = item_pos - item_instance.size / 2.0 # Centra l'item sulla sua posizione

			# Aggiorna subito lo stato del cooldown
			var cooldown_progress = 1.0 - (player_node.supermove_cooldowns.get(sm_data.type, 0.0) / sm_data.cooldown) if sm_data.cooldown > 0 else 1.0
			item_instance.update_cooldown_display(cooldown_progress)

	# Nascondi la ruota all'inizio
	#visible = false
	modulate = Color(1,1,1,0) # Totalmente trasparente

func _on_supermove_item_selected(supermove_type: SuperMoveData.SuperMoveType):
	player_node.activate_supermove(supermove_type)
	toggle_wheel_visibility(player_node) # Chiudi la ruota dopo aver selezionato

func _on_supermove_status_updated(supermove_type, cooldown_progress):
	for item in items:
		if item.supermove_data and item.supermove_data.type == supermove_type:
			item.update_cooldown_display(cooldown_progress)
			break

func _on_supermove_activated(supermove_type: SuperMoveData.SuperMoveType):
	_on_supermove_status_updated(supermove_type, 0.0) # Imposta subito il cooldown a 0%
