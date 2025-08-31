extends Area2D

# La parola chiave @export permette di modificare questa variabile direttamente dall'Inspector di Godot.
@export var velocita = 300.0

# Esportiamo una variabile di tipo "PackedScene"
# Questo creerà uno slot nell'Inspector dove potremo trascinare la nostra scena del proiettile.
@export var proiettile_scena: PackedScene

# Aggiungiamo i suoni come nodi pronti all'uso
@onready var suono_morte = $SuonoMorte
@onready var collision_shape = $CollisionShape2D

var joystick_node = null

# In cima a giocatore.gd
@export var energy_max = 10
var current_energy

# Creiamo un nuovo segnale che verrà emesso quando la salute cambia
signal energy_updated(new_energy, energy_top)

func _physics_process(delta):
	var direzione_input = Vector2.ZERO # Iniziamo con una direzione nulla
	# --- CONTROLLO JOYSTICK ---
	# Controlliamo se il joystick esiste e se è in uso
	if joystick_node and joystick_node.is_pressed:
		# Se sì, prendiamo la sua direzione
		direzione_input = joystick_node.output
	else:
		# --- CONTROLLO TASTIERA (FALLBACK) ---
		# Altrimenti, usiamo la tastiera come prima
		direzione_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	position += direzione_input * velocita * delta

	# --- BLOCCO AI BORDI (INVARIATO) ---
	var screen_size = get_viewport_rect().size
	var player_half_size = collision_shape.shape.size / 2
	position.x = clamp(position.x, player_half_size.x, screen_size.x - player_half_size.x)
	position.y = clamp(position.y, player_half_size.y, screen_size.y - player_half_size.y)

	# --- GESTIONE SPARO (INVARIATO) ---
	if Input.is_action_just_pressed("sparo"):
		sparare()

# Aggiungi questa nuova funzione in giocatore.gd
func energy_down(number):
	print("Salute PRIMA del colpo: ", current_energy) # Messaggio di debug
	current_energy -= number

	# Emettiamo il segnale per aggiornare la UI
	energy_updated.emit(current_energy, energy_max)

	if current_energy <= 0:
		morire() # Chiamiamo la funzione di morte solo quando la salute è finita

func _ready():
	# Questa funzione viene eseguita all'avvio della scena
	self.position = Vector2(270, 850)
	current_energy = energy_max
	joystick_node = get_tree().get_first_node_in_group("virtual_joystick")

func sparare():
	if not proiettile_scena: return
	var nuovo_proiettile = proiettile_scena.instantiate()
	get_parent().add_child(nuovo_proiettile)
	nuovo_proiettile.global_position = global_position

func morire():
	# Nascondi la grafica e disattiva le collisioni
	hide()
	collision_shape.set_deferred("disabled", true)

	# Ferma il movimento del giocatore
	set_physics_process(false)
	suono_morte.play()
	await suono_morte.finished
	print("Suono terminato, riavvio la scena.") # Se non vedi questo messaggio, il problema è l'await
	get_tree().change_scene_to_file("res://menu_principale.tscn")
	GameManager.reset_level()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("nemici"):
		# Se un nemico ci tocca, subiamo un danno maggiore
		energy_down(2)
		# Il nemico viene comunque distrutto per evitare danni multipli
	elif area.is_in_group("enemy_weapons"):
		# Se un proiettile nemico ci tocca, subiamo danno
		energy_down(1)
		# Il proiettile viene distrutto
		area.queue_free()
