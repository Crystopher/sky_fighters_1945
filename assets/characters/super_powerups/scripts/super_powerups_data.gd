# Script: supermove_data.gd
# Questo è un file di risorsa
extends Resource
class_name SuperMoveData

enum SuperMoveType {
	BOMB,              # Bomba che distrugge tutti i nemici/proiettili
	SHIELD,             # Scudo temporaneo di invulnerabilità
	OVERCHARGE_WEAPON  # Aumento temporaneo massivo del danno/frequenza di fuoco
}

@export var type: SuperMoveType
@export var name: String = "Supermossa"
@export var icon: Texture2D          # Icona visualizzata nella UI
@export var cooldown: float = 15.0    # Tempo di ricarica
@export var duration: float = 0.0       # Durata dell'effetto (0.0 se istantaneo, es. Bomba)
@export var description: String = "Una potente abilità speciale."
@export var animation: PackedScene
