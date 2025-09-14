extends Area2D

const SCENA_ESPLOSIONE = preload("res://assets/characters/scenes/explosion.tscn")
const SCENA_HIT = preload("res://assets/characters/scenes/hit.tscn")

# La parola chiave @export permette di modificare questa variabile direttamente dall'Inspector di Godot.
@export var velocita = 300.0
var velocita_attuale
var current_weapon = 0
var max_waepon = 3
var current_damage_powerup = 0.0
# Esportiamo una variabile di tipo "PackedScene"
# Questo creerà uno slot nell'Inspector dove potremo trascinare la nostra scena del proiettile.
@export var weapons: Array[PackedScene]
@onready var collision_shape = $CollisionPolygon2D
@onready var ombra_giocatore = $OmbraGiocatore
@onready var ombra_giocatore_animata = $OmbraGiocatoreAnimata
@onready var grafica_giocatore = $GraficaGiocatore

@export var player_code = ""

var joystick_node = null
var invincibile = false
# In cima a giocatore.gd
@export var energy_max = 10
var current_energy
var tipo_sparo_attuale
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
		if $Autofire2Timer.is_stopped():
			$Autofire2Timer.start()
	else:
		# Se il giocatore è fermo, ferma il timer.
		$AutofireTimer.stop()
		$Autofire2Timer.stop()

	position += direzione_input * velocita_attuale * delta

	# --- BLOCCO AI BORDI (INVARIATO) ---
	var screen_size = get_viewport_rect().size
	#var player_half_size = collision_shape.shape / 2
	var player_half_size:PackedVector2Array = collision_shape.polygon
	position.x = clamp(position.x, player_half_size[0].x, screen_size.x - player_half_size[0].x)
	position.y = clamp(position.y, player_half_size[0].y, screen_size.y - player_half_size[0].y)

	# --- GESTIONE SPARO (INVARIATO) ---
	if Input.is_action_just_pressed("sparo"):
		sparare()
		
	var shadow_position = global_position
	shadow_position.x += 50 
	
	if ombra_giocatore: ombra_giocatore.global_position = shadow_position
	if ombra_giocatore_animata: ombra_giocatore_animata.global_position = shadow_position

# Aggiungi questa nuova funzione in giocatore.gd
func energy_down(number):
	if invincibile: return
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
	velocita_attuale = velocita
	await ready
	# 1. Troviamo il livello delle nuvole
	var strato_nuvole = get_tree().get_first_node_in_group("strato_nuvole")

	if strato_nuvole and ombra_giocatore:
		# 2. Stacchiamo l'ombra da noi stessi
		remove_child(ombra_giocatore)

		# 3. La riattacchiamo come figlia dello strato delle nuvole
		strato_nuvole.add_child(ombra_giocatore)
		
	if strato_nuvole and ombra_giocatore_animata:
		# 2. Stacchiamo l'ombra da noi stessi
		remove_child(ombra_giocatore_animata)

		# 3. La riattacchiamo come figlia dello strato delle nuvole
		strato_nuvole.add_child(ombra_giocatore_animata)

	joystick_node = get_tree().get_first_node_in_group("virtual_joystick")

func shot_0():
	var nuovo_proiettile = weapons[0].instantiate()
	get_parent().add_child(nuovo_proiettile)
	nuovo_proiettile.current_damage = nuovo_proiettile.current_damage + (nuovo_proiettile.damage * current_damage_powerup)
	nuovo_proiettile.global_position = global_position

func shot_green_3():
	var projectile_sx = weapons[2].instantiate()
	var projectile_dx = weapons[2].instantiate()
	projectile_dx.sound_mute = true
	projectile_sx.sound_mute = true
	projectile_sx.is_left = true
	projectile_dx.is_right = true
	get_parent().add_child(projectile_dx)
	get_parent().add_child(projectile_sx)
	projectile_sx.current_damage = projectile_sx.current_damage + (projectile_sx.damage * current_damage_powerup)
	projectile_dx.current_damage = projectile_dx.current_damage + (projectile_dx.damage * current_damage_powerup)
	var sx_postion = global_position
	sx_postion.x -= 80
	sx_postion.y += 30
	var dx_postion = global_position
	dx_postion.x += 80
	dx_postion.y += 30
	projectile_dx.global_position = sx_postion
	projectile_sx.global_position = dx_postion

func shot_green_2():
	var projectile_sx = weapons[1].instantiate()
	var projectile_dx = weapons[1].instantiate()
	projectile_dx.sound_mute = true
	projectile_sx.sound_mute = true
	get_parent().add_child(projectile_dx)
	get_parent().add_child(projectile_sx)
	projectile_sx.current_damage = projectile_sx.current_damage + (projectile_sx.damage * current_damage_powerup)
	projectile_dx.current_damage = projectile_dx.current_damage + (projectile_dx.damage * current_damage_powerup)
	var sx_postion = global_position
	sx_postion.x -= 80
	sx_postion.y += 30
	var dx_postion = global_position
	dx_postion.x += 80
	dx_postion.y += 30
	projectile_dx.global_position = sx_postion
	projectile_sx.global_position = dx_postion

func shot_green_1():
	var nuovo_proiettile_1 = weapons[0].instantiate()
	var nuovo_proiettile_2 = weapons[0].instantiate()
	nuovo_proiettile_2.sound_mute = true
	nuovo_proiettile_1.sound_mute = false
	get_parent().add_child(nuovo_proiettile_1)
	get_parent().add_child(nuovo_proiettile_2)
	nuovo_proiettile_1.current_damage = (nuovo_proiettile_1.current_damage/2) + ((nuovo_proiettile_1.damage/2) * current_damage_powerup)
	nuovo_proiettile_2.current_damage = (nuovo_proiettile_2.current_damage/2) + ((nuovo_proiettile_2.damage/2) * current_damage_powerup)
	var position_dx = global_position
	position_dx.x += 20
	var position_sx = global_position
	position_sx.x -= 20
	nuovo_proiettile_1.global_position = position_sx
	nuovo_proiettile_2.global_position = position_dx

func shot_1():
	if player_code == "green":
		shot_green_1()
		
func shot_2():
	if player_code == "green":
		shot_green_2()
		
func shot_3():
	if player_code == "green":
		shot_green_3()

func sparare():
	if not weapons: return
	
	if current_weapon > max_waepon: current_weapon = max_waepon
	
	if current_weapon == 0:
		shot_0()
	elif current_weapon == 1:
		if weapons.size() >= 1:
			shot_1()
	elif current_weapon == 2:
		if weapons.size() >= 2:
			shot_1()
	elif current_weapon == 3:
		if weapons.size() >= 3:
			shot_1()

func sparare_02():
	if not weapons: return
	
	if current_weapon > max_waepon: current_weapon = max_waepon
	
	if current_weapon == 2:
		if weapons.size() >= 2:
			shot_2()
	elif current_weapon == 3:
		if weapons.size() >= 3:
			shot_2()
			shot_3()

func morire():
	var esplosione = SCENA_ESPLOSIONE.instantiate()
	get_parent().add_child(esplosione)
	esplosione.global_position = global_position
	
	# Nascondi la grafica e disattiva le collisioni
	grafica_giocatore.hide()
	if ombra_giocatore: ombra_giocatore.hide()
	if ombra_giocatore_animata: ombra_giocatore_animata.hide()
	$AutofireTimer.stop()
	$Autofire2Timer.stop()
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
	
	current_weapon = 0
	velocita_attuale = velocita
	current_damage_powerup = 0.0

	# 2. Riposizioniamo il giocatore al centro in basso
	var screen_size = get_viewport().get_visible_rect().size
	global_position = Vector2(screen_size.x / 2.0, screen_size.y - 300)

	# 3. Riattiviamo il giocatore
	grafica_giocatore.show()
	if ombra_giocatore: ombra_giocatore.show()
	if ombra_giocatore_animata: ombra_giocatore_animata.show()
	collision_shape.set_deferred("disabled", false)
	set_physics_process(true)

	# 4. Avviamo l'invincibilità e l'effetto visivo
	invincibile = true
	$InvincibilityTimer.start()
	# Effetto lampeggio
	grafica_giocatore.modulate.a = 0.5

func applica_powerup(powerup_data: PowerUpData):
	match powerup_data.type:
		PowerUpData.PowerUpType.VELOCITY:
			velocita_attuale += velocita * powerup_data.value # Es. +10%

		PowerUpData.PowerUpType.ENERGY:
			current_energy = energy_max # Cura salute a max

		PowerUpData.PowerUpType.WEAPON_DAMAGE:
			current_damage_powerup += powerup_data.value # Es. +20%

		PowerUpData.PowerUpType.WEAPON_UPGRADE:
			current_weapon += 1
			print("Power-up Danno: Sparo a Ventaglio!")

	# Riaggiorna la UI (se necessario)
	emit_signal("energy_updated", current_energy, energy_max)

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
		if not area.keep_visible: area.queue_free()

func _on_hit_flash_timer_timeout() -> void:
	grafica_giocatore.modulate = Color(1, 1, 1, 1)

func _on_autofire_timer_timeout() -> void:
	sparare() # Replace with function body.


func _on_autofire_2_timer_timeout() -> void:
	sparare_02() # Replace with function body.
