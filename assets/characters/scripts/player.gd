extends Area2D

const SCENA_ESPLOSIONE = preload("res://assets/characters/scenes/explosion.tscn")
const SCENA_HIT = preload("res://assets/characters/scenes/hit.tscn")

# La parola chiave @export permette di modificare questa variabile direttamente dall'Inspector di Godot.
@export var velocita = 300.0
# Esportiamo una variabile di tipo "PackedScene"
# Questo creerà uno slot nell'Inspector dove potremo trascinare la nostra scena del proiettile.
@export var proiettile_scena: PackedScene
@onready var collision_shape = $CollisionPolygon2D
@onready var ombra_giocatore = $OmbraGiocatore
@onready var grafica_giocatore = $GraficaGiocatore

var joystick_node = null
var invincibile = false
# In cima a giocatore.gd
@export var energy_max = 10
var current_energy

# Creiamo un nuovo segnale che verrà emesso quando la salute cambia
signal energy_updated(new_energy, energy_top)
signal giocatore_morto

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
	current_energy -= SettingsManager.calculate_difficulty(number, "minus")

	# Emettiamo il segnale per aggiornare la UI
	energy_updated.emit(current_energy, energy_max)
	
	grafica_giocatore.modulate = Color(100,100,100,1)  # Imposta il colore a bianco vivo
	$HitFlashTimer.start()

	#suono_colpo.play()

	if current_energy <= 0:
		morire() # Chiamiamo la funzione di morte solo quando la salute è finita
	else:
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		var hit_position = global_position
		hit_position.y += 50
		hit.global_position = hit_position
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
	var esplosione = SCENA_ESPLOSIONE.instantiate()
	get_parent().add_child(esplosione)
	esplosione.global_position = global_position
	
	# Nascondi la grafica e disattiva le collisioni
	grafica_giocatore.hide()
	ombra_giocatore.hide()
	$AutofireTimer.stop()
	collision_shape.set_deferred("disabled", true)

	# Ferma il movimento del giocatore
	set_physics_process(false)
	await get_tree().create_timer(3.0).timeout
	
	var game_over = GameManager.perdi_vita()
	if game_over:
		GameManager.ultima_difficolta = SettingsManager.difficulty_multiplier
		GameManager.ultimo_aereo = GameManager.giocatore_selezionato
		GameManager.ultimo_punteggio = GameManager.punteggio_attuale
		# Se è Game Over, aspettiamo un po' e torniamo al menu
		await get_tree().create_timer(2.0).timeout
		
		GameManager.clean_up_level()
		
		if HighscoreManager.is_high_score(GameManager.ultimo_punteggio):
			get_tree().change_scene_to_file("res://inserimento_highscore.tscn")
		else:
			giocatore_morto.emit()
			GameManager.reset_level()
	else:
		# Altrimenti, avviamo la sequenza di respawn
		await get_tree().create_timer(1.5).timeout
		respawn()
		
func respawn():
	# 1. Resettiamo la salute del giocatore
	current_energy = energy_max
	energy_updated.emit(current_energy, energy_max)

	# 2. Riposizioniamo il giocatore al centro in basso
	var screen_size = get_viewport().get_visible_rect().size
	global_position = Vector2(screen_size.x / 2.0, screen_size.y - 300)

	# 3. Riattiviamo il giocatore
	grafica_giocatore.show()
	ombra_giocatore.show()
	collision_shape.set_deferred("disabled", false)
	set_physics_process(true)

	# 4. Avviamo l'invincibilità e l'effetto visivo
	invincibile = true
	$InvincibilityTimer.start()
	# Effetto lampeggio
	grafica_giocatore.modulate.a = 0.5

# Quando il timer di invincibilità finisce
func _on_invincibility_timer_timeout():
	invincibile = false
	# Riportiamo il giocatore alla piena visibilità
	grafica_giocatore.modulate.a = 1.0

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
	grafica_giocatore.modulate = Color(1, 1, 1, 1)

func _on_autofire_timer_timeout() -> void:
	sparare() # Replace with function body.
