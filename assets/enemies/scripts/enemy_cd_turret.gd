# Script: torretta_terrestre.gd
extends Node2D
class_name TorrettaTerrestre

var already_destroyed = false
signal enemy_destroyed()
@export var punti_nemico = 50
@export var salute_massima = 7
var salute_attuale
@export var proiettile_nemico_scene: PackedScene # Scena del proiettile che spara la torretta
@export var velocita_proiettile: float = 300.0
@export var fire_rate: float = 1.0: # Tempo tra uno sparo e l'altro
	set(value):
		fire_rate = value
		if is_node_ready(): # Aggiorna il timer se è già inizializzato
			$ShootTimer.wait_time = fire_rate

@onready var canna = $Cannon
@onready var canna_destroyed = $CannonDestroyed
@onready var muzzle = $Cannon/Muzzle
@onready var shoot_timer = $ShootTimer
@onready var hitbox = $Area2D/Hitbox

const SCENA_ESPLOSIONE = preload("res://assets/enemies/scenes/explosion_base.tscn")
const SCENA_HIT = preload("res://assets/characters/scenes/hit.tscn")

var is_dead = false # Flag per evitare decrementi multipli
var player_node: Node2D = null # Riferimento al giocatore

func _ready():
	salute_attuale = salute_massima
	# Cerca il giocatore nel gruppo "giocatore"
	player_node = GameManager.get_player_node()
	if not player_node:
		push_warning("Giocatore non trovato per la torretta: ", name)
		set_process(false) # Disattiva processing se non c'è il giocatore
		return

	shoot_timer.wait_time = fire_rate
	shoot_timer.start() # Assicurati che il timer parta

	is_dead = false


func _process(delta):
	if not is_dead and player_node:
		var direction_to_player = (player_node.global_position - global_position).normalized()
		var target_angle = direction_to_player.angle()
		canna.rotation = target_angle
		canna_destroyed.rotation = target_angle
	
	position.y += 100 * delta
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 100: # +50 è un margine di sicurezza
		explode(false)

func _on_shoot_timer_timeout():
	if is_dead or not player_node or not is_instance_valid(player_node):
		return # Non sparare se la torretta è morta o il giocatore non esiste

	spawn_proiettile()

func spawn_proiettile():
	if not proiettile_nemico_scene:
		push_error("Proiettile nemico non assegnato alla torretta.")
		return

	var proiettile_instance = proiettile_nemico_scene.instantiate()
	get_tree().root.add_child(proiettile_instance) # Aggiungi il proiettile al root per non essere influenzato dalla rotazione della torretta

	proiettile_instance.global_position = muzzle.global_position

	# La direzione del proiettile è la direzione attuale della canna
	var fire_direction = Vector2(1, 0).rotated(canna.global_rotation) # Usa global_rotation per ottenere la direzione assoluta
	proiettile_instance.linear_velocity = fire_direction * velocita_proiettile

func subire_danno(danno_ricevuto):
	if is_dead: return

	canna.modulate = Color(100,100,100,1)
	salute_attuale -= SettingsManager.calculate_difficulty(danno_ricevuto, "add")
	if salute_attuale <= 0:
		morire()
	else:
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		var hit_position = global_position
		hit_position.y += 50
		hit.global_position = hit_position
		$HitFlashTimer.start()

func morire():
	if is_dead: return
	is_dead = true
	explode(true)

func explode(with_sound):	
	if with_sound == true:
		var esplosione = SCENA_ESPLOSIONE.instantiate()
		get_parent().add_child(esplosione)
		esplosione.global_position = global_position
		GameManager.aggiungi_punti(punti_nemico)
	# the enemy starts to be destroyed
	hitbox.set_deferred("disabled", true)
	destroying()

func destroying():
	if already_destroyed:
		return
	# The enemy is destroyed here
	already_destroyed = true
	canna.visible = false
	canna_destroyed.visible = true
	$ShootTimer.stop()
	enemy_destroyed.emit() # Annuncia al mondo che stiamo per morire

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_dead: return

	if area.is_in_group("proiettili_giocatore"):
		subire_danno(area.current_damage) # Assumi che il proiettile abbia una proprietà 'danno'
		area.queue_free() # Distruggi il proiettile dopo aver colpito


func _on_hit_flash_timer_timeout() -> void:
	canna.modulate = Color(1, 1, 1, 1) # Replace with function body.
