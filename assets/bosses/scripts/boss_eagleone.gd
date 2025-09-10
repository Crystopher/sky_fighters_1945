extends "res://assets/bosses/scripts/boss_base.gd"

# Definiamo i due stati: entrata e mira
enum State { ENTERING, STOP, IDLE }
var stato_attuale = State.ENTERING

@export var weapon_scene: PackedScene

@export var max_health_wing_sx = 1
@export var max_health_wing_dx = 1

var wing_dx_destroyed = false
var wing_sx_destroyed = false

var health_wing_sx: float
var health_wing_dx: float

# Collisions section
@onready var wing_sx_collision = $WingSXArea/WingSXCollision
@onready var wing_dx_collision = $WingDXArea/WingDXCollision
@onready var body_collision = $BodyCollision
@onready var hit_no_damage_sound = $HitNoDamageSound

@onready var wings_sx_smoke = $WingSX_Smoke
@onready var wings_dx_smoke = $WingDX_Smoke

@onready var cannon_open_graphics = $CannonOpenGraphics
@onready var cannon_up_graphics = $CannonUpGraphics

@onready var cannon_collision = $CannonCollision

@export var velocita_entrata = 400.0 # Velocità alta per l'ingresso in scena
var y_bersaglio_stop # L'altezza a cui il nemico si fermerà

@export var velocita_orbitale = 1.7  # In radianti al secondo (più alto = più veloce)
var raggio_orbita = 100.0           # Il raggio del cerchio
var centro_orbita = Vector2.ZERO   # Il centro del cerchio
var direzione_orbita = 1.0         # 1 per antiorario, -1 per orario
var angolo_attuale = 0.0           # L'angolo attuale sull'orbita

func _ready():
	super() # Eseguiamo la funzione _ready() del genitore
	
	velocita = velocita_entrata

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
		grafica_nemico.play()
		ombra_nemico_animata.play()
		$AperturaAlareTimer.start()

func _on_apertura_alare_timer_timeout() -> void:
	grafica_nemico.animation = "close"
	ombra_nemico_animata.animation = "close"
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
		
	if wing_to_check > 0:
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		hit.global_position = hit_position
	
	$HitFlashTimer.start()
		#explode(true) # Il nemico muore solo quando la salute è finita

func check_damage(area, part_name):
	if area.is_in_group("proiettili_giocatore"):
		wing_damage(area.damage, part_name)
		area.queue_free()


func _on_cannon_open_graphics_animation_finished() -> void:
	cannon_up_graphics.visible = true
	cannon_up_graphics.play()
