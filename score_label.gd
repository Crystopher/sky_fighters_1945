extends Label

# _ready() viene chiamato quando il nodo è pronto
func _ready():
	# Connettiamo questa label al segnale del nostro GameManager globale
	GameManager.punteggio_aggiornato.connect(aggiorna_testo)
	# Assicuriamoci che il testo sia corretto all'avvio
	aggiorna_testo(GameManager.punteggio_attuale)

# Questa funzione viene eseguita ogni volta che il segnale viene emesso
func aggiorna_testo(nuovo_punteggio):
	text = str(nuovo_punteggio)
