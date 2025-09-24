extends "res://assets/bosses/scripts/boss_base.gd"

# Definiamo i due stati: entrata e mira
enum State { ENTERING, STOP, IDLE }
var stato_attuale = State.ENTERING

@export var wing_weapon_scene: PackedScene
@export var cannon_weapon_scene: PackedScene
@export var railgun_weapon_scene: PackedScene

var max_follow_missiles = 5

@export var max_health_wing_sx = 1
@export var max_health_wing_dx = 1
@export var max_health_cannon = 1

var wing_dx_destroyed = false
var wing_sx_destroyed = false
var cannon_destroyed = false
var boss_destroyed = false

var health_wing_sx: float
var health_wing_dx: float
var health_cannon: float

# Collisions section
@onready var wing_sx_collision = $WingSXArea/WingSXCollision
@onready var wing_dx_collision = $WingDXArea/WingDXCollision
@onready var body_collision = $BodyCollision

@onready var wings_sx_smoke = $WingSX_Smoke
@onready var wings_dx_smoke = $WingDX_Smoke
@onready var cannon_smoke = $Cannon_Smoke
@onready var cannon_smoke2 = $Cannon_Smoke2

@onready var cannon_open_graphics = $CannonOpenGraphics
@onready var cannon_up_graphics = $CannonUpGraphics
@onready var eyes_lights = $EyesLights
@onready var mouth = $Mouth

@onready var cannon_collision = $CannonArea/CannonCollision

@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena
var y_bersaglio_stop # L'altezza a cui il nemico si fermerà

@export var velocita_orbitale = 1.7  # In radianti al secondo (più alto = più veloce)
var raggio_orbita = 100.0           # Il raggio del cerchio
var centro_orbita = Vector2.ZERO   # Il centro del cerchio
var direzione_orbita = 1.0         # 1 per antiorario, -1 per orario
var angolo_attuale = 0.0           # L'angolo attuale sull'orbita

var riferimento_giocatore = null # Una variabile per "ricordare" dov'è il giocatore

func _ready():
	super() # Eseguiamo la funzione _ready() del genitore
	
	velocita = velocita_entrata
	
	riferimento_giocatore = get_tree().get_first_node_in_group("giocatore")

	# Calcoliamo la posizione Y casuale in cui fermarsi (nella metà superiore dello schermo)
	var screen_height = get_viewport_rect().size.y
	var screen_size = get_viewport_rect().size
	y_bersaglio_stop = (screen_height / 3) + 100
	
	raggio_orbita = screen_size.x * 0.20
	
	# Scegliamo una direzione di rotazione casuale
	direzione_orbita = 1.0 if randi() % 2 == 0 else -1.0
	
	# Decidiamo a quale altezza dovrà iniziare a orbitare
	# La Y del *centro* dell'orbita sarà questa + il raggio
	var y_inizio_orbita = y_bersaglio_stop
	centro_orbita.y = y_inizio_orbita - 120
	centro_orbita.x = screen_size.x / 2
	
	health_wing_sx = max_health_wing_sx
	health_wing_dx = max_health_wing_dx
	health_cannon = max_health_cannon
	deactivate_cannon_collision(true)
	deactivate_body_collision(true)
	deactivate_wings_collision(true)

func deactivate_cannon_collision(value):
	cannon_collision.set_deferred("disabled", value)

func deactivate_wings_collision(value):
	wing_sx_collision.set_deferred("disabled", value)
	wing_dx_collision.set_deferred("disabled", value)
	
	if wing_dx_destroyed:
		wing_dx_collision.set_deferred("disabled", true)
		
	if wing_sx_destroyed:
		wing_sx_collision.set_deferred("disabled", true)

func deactivate_body_collision(value):
	body_collision.set_deferred("disabled", value)

func _process(delta):	
	match stato_attuale:
		State.ENTERING:
			# Muoviti verso il basso
			position.y += velocita * delta

			# Controlla se abbiamo raggiunto l'altezza prestabilita
			if position.y >= y_bersaglio_stop:
				# Se sì, fermati e inizia a sparare
				stato_attuale = State.STOP

			if position.y >= centro_orbita.y - raggio_orbita:
				
				# Impostiamo l'angolo iniziale per partire dal punto più alto
				angolo_attuale = PI / 2.0
		
		State.STOP:
			stato_attuale = State.IDLE
			$WeaponTimerRailgun.start()
			start_idle_animation()
		
		State.IDLE:
			# Aggiorniamo l'angolo
			angolo_attuale += velocita_orbitale * direzione_orbita * delta
			
			# Calcoliamo la nuova posizione sull'orbita
			position.x = centro_orbita.x + cos(angolo_attuale) * raggio_orbita
			position.y = centro_orbita.y + sin(angolo_attuale) * raggio_orbita

	aggiorna_posizione_ombra_animata()

func start_idle_animation():
	if not wing_dx_destroyed or not wing_sx_destroyed:
		grafica_nemico.animation = "open"
		ombra_nemico_animata.animation = "open"
		cannon_up_graphics.animation = "openup"
		grafica_nemico.play()
		ombra_nemico_animata.play()
		$AperturaAlareTimer.start()

func _on_apertura_alare_timer_timeout() -> void:
	grafica_nemico.animation = "close"
	ombra_nemico_animata.animation = "close"
	$WeaponTimerWing.stop()
	grafica_nemico.play()
	ombra_nemico_animata.play()
	$ChiusuraAlareTimer.start()

func _on_chiusura_alare_timer_timeout() -> void:
	start_idle_animation()

func explode(with_sound):
	if wing_sx_collision: wing_sx_collision.set_deferred("disabled", true)
	if wing_dx_collision: wing_dx_collision.set_deferred("disabled", true)
	super(with_sound)


func _on_grafica_nemico_animation_finished() -> void:
	if grafica_nemico.animation == "open":
		$WeaponTimerWing.start()
		deactivate_wings_collision(false)
	elif grafica_nemico.animation == "close": 
		deactivate_wings_collision(true)

func _on_wing_sx_area_area_entered(area: Area2D) -> void:
	check_damage(area, "wing_sx")

func _on_wing_dx_area_area_entered(area: Area2D) -> void:
	check_damage(area, "wing_dx")

func wing_damage(damage, wing):
	grafica_nemico.modulate = Color(100,100,100,1)
	var wing_to_check
	var hit_position = global_position
	hit_position.y -= 50
	if wing == "wing_sx":
		health_wing_sx -= SettingsManager.calculate_difficulty(damage, "add")
		wing_to_check = health_wing_sx
		hit_position.x -= 150
		if wing_to_check <= 0:
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			var esplosione_position = global_position
			esplosione_position.x -= 100
			esplosione_position.y -= 100
			esplosione.global_position = esplosione_position
			wing_sx_destroyed = true
			wings_sx_smoke.visible = true
			wings_sx_smoke.play()
			wing_sx_collision.set_deferred("disabled", true)
	elif wing == "wing_dx":
		health_wing_dx -= SettingsManager.calculate_difficulty(damage, "add")
		wing_to_check = health_wing_dx
		hit_position.x += 150
		if wing_to_check <= 0:
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			var esplosione_position = global_position
			esplosione_position.x += 150
			esplosione_position.y -= 100
			esplosione.global_position = esplosione_position
			wing_dx_destroyed = true
			wings_dx_smoke.visible = true
			wings_dx_smoke.play()
			wing_dx_collision.set_deferred("disabled", true)
	
	if wing_sx_destroyed and wing_dx_destroyed:
		cannon_open_graphics.visible = true
		cannon_open_graphics.play()
		max_follow_missiles = 4
		
	if wing_to_check > 0:
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		hit.global_position = hit_position
	
	$HitFlashTimer.start()
		#explode(true) # Il nemico muore solo quando la salute è finita

func check_damage(area, part_name):
	if area.is_in_group("proiettili_giocatore"):
		wing_damage(area.current_damage, part_name)
		area.queue_free()

func _on_cannon_open_graphics_animation_finished() -> void:
	cannon_up_graphics.visible = true
	cannon_up_graphics.play()

func _on_cannon_up_graphics_animation_finished() -> void:
	if cannon_up_graphics.animation == "openup":
		deactivate_cannon_collision(false)
		$WeaponTimerCannon.start()

func _on_cannon_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		health_cannon -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		if health_cannon > 0:
			grafica_nemico.modulate = Color(100,100,100,1)
			var hit = SCENA_HIT.instantiate()
			get_parent().add_child(hit)
			var hit_position = global_position
			hit_position.y -= 50
			hit.global_position = hit_position
		else:
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			var esplosione_position = global_position
			esplosione_position.y -= 100
			esplosione.global_position = esplosione_position
			cannon_up_graphics.animation = "exploded"
			cannon_up_graphics.play()
			cannon_smoke.visible = true
			cannon_smoke.play()
			cannon_smoke2.visible = true
			cannon_smoke2.play()
			eyes_lights.play()
			$OpenMouth.start()
			$WeaponTimerCannon.stop()
			deactivate_cannon_collision(true)
			deactivate_body_collision(false)

		$HitFlashTimer.start()
		area.queue_free()


func _on_open_mouth_timeout() -> void:
	mouth.animation = "open"
	mouth.play()

func _on_close_mouth_timeout() -> void:
	mouth.animation = "close"
	mouth.play()

func _on_mouth_animation_finished() -> void:
	if not boss_destroyed:
		if mouth.animation == "open":
			$LaserWeapon/LaserAudio.play()
			await get_tree().create_timer(1.35, false).timeout
			$LaserWeapon.visible = true
			$LaserPlayer.play("laser_on")
			$CloseMouth.start()
			await get_tree().create_timer(2, false).timeout
			$LaserPlayer.play("RESET")
			$LaserWeapon.visible = false
		elif mouth.animation == "close":
			$OpenMouth.start()
	else:
		$CloseMouth.start()


func _on_weapon_timer_railgun_timeout() -> void:
	railgun_weapon_shot()

func railgun_weapon_shot():
	# Controllo di sicurezza: se il giocatore è stato distrutto, non sparare.
	if not is_instance_valid(riferimento_giocatore):
		return

	# Eseguiamo un ciclo per sparare 4 proiettili
	for i in range(max_follow_missiles):
		# Calcoliamo la direzione verso il giocatore IN QUESTO ISTANTE
		var direzione = (riferimento_giocatore.global_position - global_position).normalized()

		# Creiamo un proiettile (usiamo quello base nemico)
		var railgun_follow_sx = railgun_weapon_scene.instantiate()
		var railgun_follow_dx = railgun_weapon_scene.instantiate()
		get_parent().add_child(railgun_follow_sx)
		get_parent().add_child(railgun_follow_dx)
		
		var railgun_sx_explosion = SCENA_ESPLOSIONE_PROIETTILE.instantiate()
		var railgun_dx_explosion = SCENA_ESPLOSIONE_PROIETTILE.instantiate()
		get_parent().add_child(railgun_sx_explosion)
		get_parent().add_child(railgun_dx_explosion)
		
		var position_sx = global_position
		var position_dx = global_position
		
		position_sx.y -= 35
		position_dx.y -= 35
		
		position_sx.x -= 75
		position_dx.x += 75
		
		railgun_sx_explosion.global_position = position_sx
		railgun_follow_sx.global_position = position_sx
		railgun_follow_sx.direzione = direzione
		
		railgun_dx_explosion.global_position = position_dx
		railgun_follow_dx.global_position = position_dx
		railgun_follow_dx.direzione = direzione
		
		railgun_follow_sx.rotation = direzione.angle() + PI / 2.0
		railgun_follow_dx.rotation = direzione.angle() + PI / 2.0

		# Aspettiamo un breve istante prima di sparare il prossimo colpo della raffica
		await get_tree().create_timer(0.3, false).timeout


func _on_weapon_timer_wing_timeout() -> void:
	wing_weapon_shoot() # Replace with function body.

func wing_weapon_shoot():
	if not wing_weapon_scene: return

	var new_weapon1 = wing_weapon_scene.instantiate()
	var new_weapon2 = wing_weapon_scene.instantiate()
	var new_weapon3 = wing_weapon_scene.instantiate()
	var new_weapon4 = wing_weapon_scene.instantiate()

	# Aggiungiamo il proiettile alla scena principale, non al nemico stesso
	get_tree().get_root().add_child(new_weapon1)
	get_tree().get_root().add_child(new_weapon2)
	get_tree().get_root().add_child(new_weapon3)
	get_tree().get_root().add_child(new_weapon4)
	var weapon1_position = global_position
	var weapon2_position = global_position
	var weapon3_position = global_position
	var weapon4_position = global_position
	weapon1_position.y -= 60
	weapon1_position.x -= 120
	
	weapon2_position.y -= 60
	weapon2_position.x += 120
	
	weapon3_position.y -= 80
	weapon3_position.x -= 220
	
	weapon4_position.y -= 80
	weapon4_position.x += 220
	# Lo posizioniamo dove si trova il nemico
	new_weapon1.global_position = weapon1_position
	new_weapon2.global_position = weapon2_position
	new_weapon3.global_position = weapon3_position
	new_weapon4.global_position = weapon4_position


func _on_weapon_timer_cannon_timeout() -> void:
	cannon_weapon_shot()

func cannon_weapon_shot():
	if not cannon_weapon_scene: return
	
	var new_weapon = cannon_weapon_scene.instantiate()
	get_tree().get_root().add_child(new_weapon)
	$CannonFire1.play()
	$CannonFire2.play()
	
	var weapon_position = global_position
	weapon_position.y -= 10
	
	new_weapon.global_position = weapon_position
