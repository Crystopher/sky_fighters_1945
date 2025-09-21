extends Area2D

var velocita = 150.0
@export var punti_nemico = 50
@export var punti_impatto = 1
@export var max_health = 1
@onready var grafica_nemico = $GraficaNemico
@onready var ombra_nemico = $OmbraGiocatore
@onready var ombra_nemico_animata = $OmbraNemico

var salute_attuale: float
var already_destroyed = false

const SCENA_ESPLOSIONE = preload("res://assets/enemies/scenes/explosion_base.tscn")
const SCENA_ESPLOSIONE_PROIETTILE = preload("res://assets/bosses/weapons/scenes/bullet_explosion.tscn")
const SCENA_HIT = preload("res://assets/characters/scenes/hit.tscn")

signal enemy_destroyed()

func subire_danno(quantita):
	grafica_nemico.modulate = Color(100,100,100,1)
	salute_attuale -= SettingsManager.calculate_difficulty(quantita, "add")
	if salute_attuale > 0:
		var hit = SCENA_HIT.instantiate()
		get_parent().add_child(hit)
		var hit_position = global_position
		hit_position.y += 50
		hit.global_position = hit_position
		$HitFlashTimer.start()

	if salute_attuale <= 0:
		explode(true) # Il nemico muore solo quando la salute è finita

func _ready() -> void:
	salute_attuale = max_health
	
	await ready
	# 1. Troviamo il livello delle nuvole
	var strato_nuvole = get_tree().get_first_node_in_group("strato_nuvole")

	if strato_nuvole and ombra_nemico:
		# 2. Stacchiamo l'ombra da noi stessi
		remove_child(ombra_nemico)

		# 3. La riattacchiamo come figlia dello strato delle nuvole
		strato_nuvole.add_child(ombra_nemico)
		
	if strato_nuvole and ombra_nemico_animata:
		# 2. Stacchiamo l'ombra da noi stessi
		remove_child(ombra_nemico_animata)

		# 3. La riattacchiamo come figlia dello strato delle nuvole
		strato_nuvole.add_child(ombra_nemico_animata)

func aggiorna_posizione_ombra():
	if ombra_nemico and is_inside_tree() and ombra_nemico.is_inside_tree():
		var shadow_position = global_position
		shadow_position.x += 70
		shadow_position.y -= 70
		ombra_nemico.global_position = shadow_position

func aggiorna_posizione_ombra_animata():
	if ombra_nemico_animata and is_inside_tree() and ombra_nemico_animata.is_inside_tree():
		var shadow_position = global_position
		shadow_position.x += 70
		shadow_position.y -= 70
		ombra_nemico_animata.global_position = shadow_position

func _process(delta):
	# Muovi il nemico verso il basso (l'asse Y positivo)
	position.y += velocita * delta

	aggiorna_posizione_ombra()

	# Se il nemico esce dal bordo inferiore, distruggilo
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 100: # +50 è un margine di sicurezza
		explode(false)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("proiettili_giocatore"):
		subire_danno(area.current_damage)
		area.queue_free()
	elif area.is_in_group("giocatore"):
		explode(true)

func explode(with_sound):	
	if with_sound == true:
		var esplosione = SCENA_ESPLOSIONE.instantiate()
		get_parent().add_child(esplosione)
		esplosione.global_position = global_position
		GameManager.aggiungi_punti(punti_nemico)
	# the enemy starts to be destroyed
	set_process(false)
	#if wing_sx_collision: wing_sx_collision.set_deferred("disabled", true)
	#if wing_dx_collision: wing_dx_collision.set_deferred("disabled", true)
	if ombra_nemico: ombra_nemico.hide()
	if ombra_nemico_animata: ombra_nemico_animata.hide()
	grafica_nemico.hide()
	destroying()

func destroying():
	if already_destroyed:
		return
	
	already_destroyed = true
	# The enemy is destroyed here
	enemy_destroyed.emit() # Annuncia al mondo che stiamo per morire
	queue_free()

func _on_hit_flash_timer_timeout() -> void:
	grafica_nemico.modulate = Color(1, 1, 1, 1)
