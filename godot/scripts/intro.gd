extends Control

@onready var caja_dialogo = $DialogueBox # Referencia al panel de diálogo

func _ready():
	# Activamos el cursor para que el jugador pueda interactuar con el diálogo
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Ruta de la imagen del retrato de Trevor para el diálogo
	var ruta_trevor = "res://assets/ui/dialogue/portrait_01.png"

	# Lista con las frases del monólogo de Trevor, cada una con nombre, texto y retrato
	var monologo_trevor = [
		{"nombre": "Trevor", "texto": "None of this feels real. My mind is fragmented, trapped in memories that fade before I can hold onto them.", "cara": ruta_trevor},
		{"nombre": "Trevor", "texto": "I feel like I’m not quite what I used to be, as if something inside me is incomplete, searching for a purpose I still don’t understand.", "cara": ruta_trevor},
		{"nombre": "Trevor", "texto": "Lost in a maze of shadows and broken memories, every step is a struggle to find her, to find a way out.", "cara": ruta_trevor}
	]

	# Esperamos 1.5 segundos antes de empezar el diálogo para dar tiempo a la escena
	await get_tree().create_timer(1.5).timeout

	# Conectamos la señal que detecta cuando el diálogo termina, evitando conexiones repetidas
	if not caja_dialogo.dialogo_terminado.is_connected(_al_terminar_intro):
		caja_dialogo.dialogo_terminado.connect(_al_terminar_intro)

	# Iniciamos el diálogo con las frases definidas
	caja_dialogo.iniciar_dialogo(monologo_trevor)

func _al_terminar_intro():
	# Ocultamos el cursor cuando termina el diálogo para volver al modo de juego
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	# Cambiamos a la escena inicial, usando pantalla de transición si está disponible
	if has_node("/root/TransitionScreen"):
		TransitionScreen.cambiar_escena("res://tscn/start.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/start.tscn")
