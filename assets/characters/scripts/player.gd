extends Area2D

# La parola chiave @export permette di modificare questa variabile direttamente dall'Inspector di Godot.
@export var velocita = 300.0
# Esportiamo una variabile di tipo "PackedScene"
# Questo creerà uno slot nell'Inspector dove potremo trascinare la nostra scena del proiettile.
@export var proiettile_scena: PackedScene

# Aggiungiamo i suoni come nodi pronti all'uso
@onready var suono_morte = $SuonoMorte
@onready var suono_colpo = $SuonoColpo
@onready var collision_shape = $CollisionPolygon2D
@onready var ombra_giocatore = $OmbraGiocatore

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

	# --- NUOVA LOGICA PER L'AUTOFIRE ---
	# Controlliamo se il giocatore si sta muovendo (se il vettore di input non è zero)
	if direzione_input != Vector2.ZERO:
		# Se il giocatore si sta muovendo e il timer è fermo, fallo partire.
		if $AutofireTimer.is_stopped():
			$AutofireTimer.start()
	else:
		# Se il giocatore è fermo, ferma il timer.
		$AutofireTimer.stop()

	position += direzione_input * velocita * delta

	# --- BLOCCO AI BORDI (INVARIATO) ---
	var screen_size = get_viewport_rect().size
	#var player_half_size = collision_shape.shape / 2
	var player_half_size:PackedVector2Array = collision_shape.polygon
	position.x = clamp(position.x, player_half_size[0].x, screen_size.x - player_half_size[0].x)
	position.y = clamp(position.y, player_half_size[0].y, screen_size.y - player_half_size[0].y)

	# --- GESTIONE SPARO (INVARIATO) ---
	if Input.is_action_just_pressed("sparo"):
		sparare()
	
	ombra_giocatore.global_position = global_position

# Aggiungi questa nuova funzione in giocatore.gd
func energy_down(number):
	current_energy -= number

	# Emettiamo il segnale per aggiornare la UI
	energy_updated.emit(current_energy, energy_max)

	suono_colpo.play()

	if current_energy <= 0:
		morire() # Chiamiamo la funzione di morte solo quando la salute è finita
	else: 
		$HitFlashTimer.start()

func _ready():
	# Questa funzione viene eseguita all'avvio della scena
	current_energy = energy_max
	await ready
	# 1. Troviamo il livello delle nuvole
	var strato_nuvole = get_tree().get_first_node_in_group("strato_nuvole")

	if strato_nuvole and ombra_giocatore:
		# 2. Stacchiamo l'ombra da noi stessi
		remove_child(ombra_giocatore)

		# 3. La riattacchiamo come figlia dello strato delle nuvole
		strato_nuvole.add_child(ombra_giocatore)

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
		# Se un nemico ci tocca, subiamo il danno definito in punti_impatto
		energy_down(area.punti_impatto)
		# Il nemico viene comunque distrutto per evitare danni multipli
	elif area.is_in_group("enemy_weapons"):
		# Se un proiettile nemico ci tocca, subiamo danno secondo il valore di punti_arma
		energy_down(area.punti_arma)
		# Il proiettile viene distrutto
		area.queue_free()

func _on_hit_flash_timer_timeout() -> void:
	#$ColorRect.color = grafica_giocatore
	pass

func _on_autofire_timer_timeout() -> void:
	sparare() # Replace with function body.
