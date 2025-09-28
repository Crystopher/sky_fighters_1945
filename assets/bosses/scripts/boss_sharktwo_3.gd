extends "res://assets/bosses/scripts/boss_base.gd"

enum phase { PHASE1, PHASE2, PHASE3 }
var current_phase = phase.PHASE1

enum BossState { IDLE_POSITIONING, CHARGING, RETREATING, ATTACKING_MINIONS }
var current_state: BossState = BossState.IDLE_POSITIONING

@onready var body_collision = $BodyCollision
@onready var missile_wing_dx_collision = $MissileWingsDXArea/MissileWingDXCollision
@onready var missile_wing_sx_collision = $MissileWingsSXArea/MissileWingSXCollision
@onready var missile_expl_dx_muzzle = $MissileWingsDXArea/MuzzleDX
@onready var missile_expl_sx_muzzle = $MissileWingsSXArea/MuzzleSX

@onready var missile_wing_dx = $MissileWingDX
@onready var missile_wing_sx = $MissileWingSX
@onready var missile_wings_timer_sx_open = $OpenWingSX
@onready var missile_wings_timer_dx_open = $OpenWingDX

@onready var horn_dx = $HornDX/HornLaserDX
@onready var horn_sx = $HornSX/HornLaserSX

@export var missile_wing_dx_health = 1
@export var missile_wing_sx_health = 1

@export var horn_laser_dx_health = 1
@export var horn_laser_sx_health = 1

@export var frontal_weapon_scene: PackedScene
@export var wing_weapon_scene: PackedScene
@export var wing_laser_weapon_scene: PackedScene
@export var drone_weapon_scene: PackedScene

var invincible = true
var horn_dx_invincible = true
var horn_sx_invincible = true

var target_waypoint: Vector2
@export var waypoint_speed: float = 150.0
@export var waypoint_change_interval: float = 3.0

var missile_wing_dx_destroyed = false
var missile_wing_sx_destroyed = false

var horn_dx_destroyed = false
var horn_sx_destroyed = false

var waypoint_timer: Timer
@onready var spawn_shot_1 = $SpawnTimer
@onready var spawn_shot_2 = $SpawnTimer2

@export var charge_speed: float = 400.0
@export var retreat_speed: float = 250.0
@export var target_idle_position: Vector2 = Vector2(0, 100) # Posizione di attesa
@export var charge_duration: float = 2.0 # Quanto dura una carica

var target_position: Vector2 = Vector2.ZERO # Posizione di carica o di attesa
var charge_timer: Timer

var _time_elapsed: float = 0.0

func _ready() -> void:
	super()
	spawn_shot_1.start()
	await get_tree().create_timer(0.5, false).timeout
	spawn_shot_2.start()
	waypoint_timer = Timer.new()
	add_child(waypoint_timer)
	waypoint_timer.wait_time = waypoint_change_interval
	waypoint_timer.autostart = true
	waypoint_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	waypoint_timer.timeout.connect(_on_waypoint_timer_timeout)
	generate_new_waypoint()
	
	deactivate_missile_wing_dx(true)
	deactivate_missile_wing_sx(true)
	
	await get_tree().create_timer(2, false).timeout
	missile_wings_timer_sx_open.start()
	missile_wings_timer_dx_open.start()
	
	var screen_width = get_viewport().get_visible_rect().size.x
	target_idle_position = Vector2(screen_width / 2, 350) # Es. centro, 80% in basso

func generate_new_waypoint():
	var vp_rect = get_viewport_rect()
	# Genera un waypoint all'interno di una porzione dello schermo
	target_waypoint = Vector2(
		randf_range(vp_rect.position.x + 100, vp_rect.size.x - 100),
		randf_range(vp_rect.position.y + 100, vp_rect.size.y / 2) # Limita la Y per rimanere in alto
	)
	# Potresti usare un Tween per un movimento più fluido
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_waypoint, waypoint_change_interval * 0.8)

func move_towards_target(target: Vector2, delta: float, speed: float):
	var direction = (target - global_position).normalized()
	global_position += direction * speed * delta
	aggiorna_posizione_ombra_animata()

func _process(delta):
	super(delta)

	if already_destroyed: return

	if current_phase == phase.PHASE1 or current_phase == phase.PHASE2:
		move_towards_target(target_waypoint, delta, waypoint_speed)

		# Se è vicino al waypoint, genera subito il prossimo
		if global_position.distance_to(target_waypoint) < 10:
			generate_new_waypoint()
			aggiorna_posizione_ombra_animata()
	elif current_phase == phase.PHASE3:
		_time_elapsed += delta
		match current_state:
			BossState.IDLE_POSITIONING:
				move_towards_target(target_idle_position, delta, velocita)
				if global_position.distance_to(target_idle_position) < 5:
					# Ha raggiunto la posizione di attesa, decide il prossimo attacco
					choose_next_attack()

			BossState.CHARGING:
				move_towards_target(target_position, delta, charge_speed)
				# La carica finisce per tempo o se raggiunge il bordo
				if charge_timer.is_stopped() or global_position.y > get_viewport_rect().size.y + 50:
					change_state(BossState.RETREATING)

			BossState.RETREATING:
				# Si ritira verso la posizione di attesa
				move_towards_target(target_idle_position, delta, retreat_speed)
				if global_position.distance_to(target_idle_position) < 5:
					change_state(BossState.IDLE_POSITIONING)

			BossState.ATTACKING_MINIONS:
				move_towards_target(target_idle_position + Vector2(sin(_time_elapsed*0.5)*50, 0), delta, velocita * 0.7)
				if drone_weapon_scene:
					var drone_sx = drone_weapon_scene.instantiate()
					var drone_dx = drone_weapon_scene.instantiate()
					$Drone_DX.add_child(drone_dx)
					$Drone_SX.add_child(drone_sx)
				choose_next_attack()

func choose_next_attack():
	# Logica per scegliere tra CHARGING o ATTACKING_MINIONS
	if randf() < 0.7: # 70% di probabilità di caricare
		change_state(BossState.CHARGING)
	else:
		change_state(BossState.ATTACKING_MINIONS)

func change_state(new_state: BossState):
	current_state = new_state
	match new_state:
		BossState.IDLE_POSITIONING:
			target_position = target_idle_position
		BossState.CHARGING:
			target_position = GameManager.get_player_node().global_position # Carica verso il giocatore
			charge_timer.start(charge_duration)
		BossState.RETREATING:
			target_position = target_idle_position
		BossState.ATTACKING_MINIONS:
			pass # Inizia a spawnare minion

func _on_waypoint_timer_timeout():
	generate_new_waypoint()

func deactivate_body_collision(value):
	body_collision.set_deferred("disabled", value)

func deactivate_missile_wing_dx(value):
	missile_wing_dx_collision.set_deferred("disabled", value)
	
func deactivate_missile_wing_sx(value):
	missile_wing_sx_collision.set_deferred("disabled", value)

func manage_damage(area):
	if invincible and area.is_in_group("proiettili_giocatore"):
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		hit.global_position = area.global_position
		area.queue_free()
	else:
		super(area)

func _on_missile_wings_sx_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		missile_wing_sx_health -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		area.queue_free()
		if missile_wing_sx_health <= 0:
			missile_wing_sx.play("close")
			missile_wing_sx_destroyed = true
			var smoke = SCENA_SMOKE.instantiate()
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			$SmokeArea/WingSX.add_child(smoke)
			esplosione.global_position = missile_expl_sx_muzzle.global_position
			deactivate_missile_wing_sx(true)
		else:
			missile_wing_sx.modulate = Color(100,100,100,1)
			grafica_nemico.modulate = Color(100,100,100,1)
			var hit = SCENA_HIT.instantiate()
			get_parent().add_child(hit)
			hit.global_position = area.global_position
			$HitFlashTimer.start()
	check_to_explode()

func _on_hit_flash_timer_timeout() -> void:
	super()
	missile_wing_sx.modulate = Color(1, 1, 1, 1)
	missile_wing_dx.modulate = Color(1, 1, 1, 1)
	horn_dx.modulate = Color(1, 1, 1, 1)
	horn_sx.modulate = Color(1, 1, 1, 1)

func _on_missile_wings_dx_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		missile_wing_dx_health -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		area.queue_free()
		if missile_wing_dx_health <= 0:
			missile_wing_dx.play("close")
			missile_wing_dx_destroyed = true
			var smoke = SCENA_SMOKE.instantiate()
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			$SmokeArea/WingDX.add_child(smoke)
			esplosione.global_position = missile_expl_dx_muzzle.global_position
			deactivate_missile_wing_dx(true)
		else:
			missile_wing_dx.modulate = Color(100,100,100,1)
			grafica_nemico.modulate = Color(100,100,100,1)
			var hit = SCENA_HIT.instantiate()
			get_parent().add_child(hit)
			hit.global_position = area.global_position
			$HitFlashTimer.start()
	check_to_explode()

func check_to_explode():
	if missile_wing_dx_destroyed and missile_wing_sx_destroyed:
		if horn_dx_destroyed and horn_sx_destroyed:
			if current_phase == phase.PHASE2:
				current_phase = phase.PHASE3
				activate_phase3()
		
		if current_phase == phase.PHASE1:
			current_phase = phase.PHASE2
			activate_phase2()


func activate_phase3():
	charge_timer = Timer.new()
	add_child(charge_timer)
	charge_timer.one_shot = true
	charge_timer.timeout.connect(_on_charge_timer_timeout)
	invincible = false

func activate_phase2():
	horn_dx.play("open")
	horn_sx.play("open")

func _on_open_wing_dx_timeout() -> void:
	if not missile_wing_dx_destroyed:
		missile_wing_dx.play("open")
		await missile_wing_dx.animation_finished
		deactivate_missile_wing_dx(false)

	$CloseWingDX.start()


func _on_open_wing_sx_timeout() -> void:
	if not missile_wing_sx_destroyed:
		missile_wing_sx.play("open")
		await missile_wing_sx.animation_finished
		deactivate_missile_wing_sx(false)

	$CloseWingSX.start()


func _on_close_wing_dx_timeout() -> void:
	if not missile_wing_dx_destroyed:
		deactivate_missile_wing_dx(true)
		missile_wing_dx.play("close")
	await missile_wing_dx.animation_finished
	
	$OpenWingDX.start()


func _on_close_wing_sx_timeout() -> void:
	if not missile_wing_sx_destroyed:
		deactivate_missile_wing_sx(true)
		missile_wing_sx.play("close")
	await missile_wing_sx.animation_finished
	
	$OpenWingSX.start()

func sparare(side):
	if not frontal_weapon_scene: return

	var new_weapon = frontal_weapon_scene.instantiate()
	get_tree().get_root().add_child(new_weapon)
	var shot_position
	if side == "sx":
		shot_position = $MuzzleSX.global_position
	elif side == "dx":
		shot_position = $MuzzleDX.global_position
		
	new_weapon.global_position = shot_position

func _on_spawn_timer_2_timeout() -> void:
	sparare("sx") # Replace with function body.


func _on_spawn_timer_timeout() -> void:
	sparare("dx") # Replace with function body.


func _on_missile_wing_dx_animation_finished() -> void:
	if not wing_weapon_scene: return
	
	if missile_wing_dx.animation == "open":
		for i in range(5):
			if not missile_wing_dx_destroyed:
				var new_weapon = wing_weapon_scene.instantiate()
				get_tree().get_root().add_child(new_weapon)
				var muzzle_name = "Muzzle_" + str(i+1)
				new_weapon.global_position = $MissileWingsDXArea.get_node(muzzle_name).global_position
				await get_tree().create_timer(0.3, false).timeout

		for i in range(4,2,-1):
			if not missile_wing_dx_destroyed:
				var new_weapon = wing_weapon_scene.instantiate()
				get_tree().get_root().add_child(new_weapon)
				var muzzle_name = "Muzzle_" + str(i+1)
				new_weapon.global_position = $MissileWingsDXArea.get_node(muzzle_name).global_position
				await get_tree().create_timer(0.3, false).timeout


func _on_missile_wing_sx_animation_finished() -> void:
	if not wing_weapon_scene: return
	
	if missile_wing_sx.animation == "open":
		for i in range(5):
			if not missile_wing_sx_destroyed:
				var new_weapon = wing_weapon_scene.instantiate()
				get_tree().get_root().add_child(new_weapon)
				var muzzle_name = "Muzzle_" + str(i+1)
				new_weapon.global_position = $MissileWingsSXArea.get_node(muzzle_name).global_position
				await get_tree().create_timer(0.3, false).timeout
			
		for i in range(4,2,-1):
			if not missile_wing_sx_destroyed:
				var new_weapon = wing_weapon_scene.instantiate()
				get_tree().get_root().add_child(new_weapon)
				var muzzle_name = "Muzzle_" + str(i+1)
				new_weapon.global_position = $MissileWingsSXArea.get_node(muzzle_name).global_position
				await get_tree().create_timer(0.3, false).timeout

func manage_damage_dx_horn(area):
	if horn_dx_invincible and area.is_in_group("proiettili_giocatore"):
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		hit.global_position = area.global_position
		area.queue_free()
	elif area.is_in_group("proiettili_giocatore"):
		horn_laser_dx_health -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		area.queue_free()
		if horn_laser_dx_health <= 0:
			horn_dx_destroyed = true
			var smoke = SCENA_SMOKE.instantiate()
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			$SmokeArea/HornDX.add_child(smoke)
			esplosione.global_position = $HornDX/MuzzleExplosion.global_position
			deactivate_missile_wing_sx(true)
		else:
			horn_dx.modulate = Color(100,100,100,1)
			grafica_nemico.modulate = Color(100,100,100,1)
			var hit = SCENA_HIT.instantiate()
			get_parent().add_child(hit)
			hit.global_position = area.global_position
			$HitFlashTimer.start()
	check_to_explode()
		
func manage_damage_sx_horn(area):
	if horn_sx_invincible and area.is_in_group("proiettili_giocatore"):
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		hit.global_position = area.global_position
		area.queue_free()
	elif area.is_in_group("proiettili_giocatore"):
		horn_laser_sx_health -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		area.queue_free()
		if horn_laser_sx_health <= 0:
			horn_sx_destroyed = true
			var smoke = SCENA_SMOKE.instantiate()
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
			$SmokeArea/HornSX.add_child(smoke)
			esplosione.global_position = $HornSX/MuzzleExplosion.global_position
			deactivate_missile_wing_sx(true)
		else:
			horn_sx.modulate = Color(100,100,100,1)
			grafica_nemico.modulate = Color(100,100,100,1)
			var hit = SCENA_HIT.instantiate()
			get_parent().add_child(hit)
			hit.global_position = area.global_position
			$HitFlashTimer.start()
	check_to_explode()

func _on_horn_sx_area_entered(area: Area2D) -> void:
	manage_damage_sx_horn(area)

func _on_horn_dx_area_entered(area: Area2D) -> void:
	manage_damage_dx_horn(area)

func laser_shot(side):
	if not wing_laser_weapon_scene: return
	
	if side == "dx":
		for i in range(4):
			var laser_weapon = wing_laser_weapon_scene.instantiate()
			$HornDX/MuzzleLaser.add_child(laser_weapon)
			await get_tree().create_timer(0.3, false).timeout
	if side == "sx":
		for i in range(4):
			var laser_weapon = wing_laser_weapon_scene.instantiate()
			$HornSX/MuzzleLaser.add_child(laser_weapon)
			await get_tree().create_timer(0.3, false).timeout

func _on_horn_laser_dx_animation_finished() -> void:
	if horn_dx.animation == "open":
		$HornDX/CollisionDX.set_deferred("disabled", true)
		$HornDX/CollisionHittableDX.set_deferred("disabled", false)
		horn_dx_invincible = false
		if wing_laser_weapon_scene: laser_shot("dx")
		await get_tree().create_timer(3, false).timeout
		horn_dx.play("close")
	elif horn_dx.animation == "close":
		$HornDX/CollisionDX.set_deferred("disabled", false)
		$HornDX/CollisionHittableDX.set_deferred("disabled", true)
		horn_dx_invincible = true
		if not horn_dx_destroyed:
			await get_tree().create_timer(2, false).timeout
			horn_dx.play("open")


func _on_horn_laser_sx_animation_finished() -> void:
	if horn_sx.animation == "open":
		$HornSX/CollisionSX.set_deferred("disabled", true)
		$HornSX/CollisionHittableSX.set_deferred("disabled", false)
		horn_sx_invincible = false
		if wing_laser_weapon_scene: laser_shot("sx")
		await get_tree().create_timer(3, false).timeout
		horn_sx.play("close")
	elif horn_sx.animation == "close":
		$HornSX/CollisionSX.set_deferred("disabled", false)
		$HornSX/CollisionHittableSX.set_deferred("disabled", true)
		horn_sx_invincible = true
		if not horn_sx_destroyed:
			await get_tree().create_timer(2, false).timeout
			horn_sx.play("open")


func _on_charge_timer_timeout() -> void:
	if current_state == BossState.CHARGING:
		change_state(BossState.RETREATING)
