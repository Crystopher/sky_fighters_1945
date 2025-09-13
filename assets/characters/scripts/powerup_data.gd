# Script: powerup_data.gd
# Questo è un file di risorsa, non una scena
extends Resource
class_name PowerUpData

# I tipi di power-up che avremo
enum PowerUpType {
	VELOCITY,
	ENERGY,
	WEAPON_DAMAGE,
	WEAPON_UPGRADE
}

@export var type: PowerUpType
@export var duration: float = 0.0 # Durata se temporaneo, 0.0 se permanente o istantaneo
@export var value: float = 1.0 # Quanto aumenta (es. +10% velocità, +1 salute)
@export var icon: Texture2D # Icona visiva del power-up
