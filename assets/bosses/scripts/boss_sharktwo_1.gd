extends "res://assets/bosses/scripts/boss_base.gd"

@onready var body_collision = $BodyCollision
@onready var missile_wing_dx_collision = $MissileWingsDXArea/MissileWingDXCollision
@onready var missile_wing_sx_collision = $MissileWingsSXArea/MissileWingSXCollision
@onready var missile_expl_dx_muzzle = $MissileWingsDXArea/MuzzleDX
@onready var missile_expl_sx_muzzle = $MissileWingsSXArea/MuzzleSX

@onready var missile_wing_dx = $MissileWingDX
@onready var missile_wing_sx = $MissileWingSX
@onready var missile_wings_timer_sx_open = $OpenWingSX
@onready var missile_wings_timer_dx_open = $OpenWingDX

@export var missile_wing_dx_health = 1
@export var missile_wing_sx_health = 1

@export var frontal_weapon_scene: PackedScene
@export var wing_weapon_scene: PackedScene

var invincible = true

var target_waypoint: Vector2
@export var waypoint_speed: float = 150.0
@export var waypoint_change_interval: float = 3.0

var missile_wing_dx_destroyed = false
var missile_wing_sx_destroyed = false

var waypoint_timer: Timer

func _ready() -> void:
	super()
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

	move_towards_target(target_waypoint, delta, waypoint_speed)

	# Se è vicino al waypoint, genera subito il prossimo
	if global_position.distance_to(target_waypoint) < 10:
		generate_new_waypoint()
		aggiorna_posizione_ombra_animata()
	
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
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
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

func _on_missile_wings_dx_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		missile_wing_dx_health -= SettingsManager.calculate_difficulty(area.current_damage, "add")
		area.queue_free()
		if missile_wing_dx_health <= 0:
			missile_wing_dx.play("close")
			missile_wing_dx_destroyed = true
			var esplosione = SCENA_ESPLOSIONE.instantiate()
			get_parent().add_child(esplosione)
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
		explode(true)

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
