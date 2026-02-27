extends Node2D

# --- VARIABLES ---
var jugador_cerca : bool = false
@onready var keypad_layer = $CanvasLayer # Asegúrate de que se llame así tu nodo
@onready var keypad = $CanvasLayer/Keypad

func _ready():
	# Nos aseguramos de que empiece oculto y el ratón escondido (si tu juego no usa ratón)
	keypad_layer.visible = false

func _input(event):
	# Detectamos si pulsa la E ("interactuar")
	if event.is_action_pressed("interactuar"):
		if jugador_cerca:
			abrir_cerrar_keypad()

func abrir_cerrar_keypad():
	# Invertimos la visibilidad
	keypad_layer.visible = !keypad_layer.visible
	
	# Buscamos al jugador
	var player = get_tree().get_first_node_in_group("jugador")
	
	if keypad_layer.visible:
		print("Abriendo Keypad...")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
		
		# USAMOS TU FUNCIÓN DEL PLAYER:
		if player: player.set_congelado(true) 
		
	else:
		print("Cerrando Keypad...")
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 
		
		# USAMOS TU FUNCIÓN DEL PLAYER:
		if player: player.set_congelado(false)

func _on_zona_keypad_body_entered(body):
	if body.is_in_group("jugador"):
		jugador_cerca = true
		print("Pulsa E para usar el panel")

func _on_zona_keypad_body_exited(body):
	if body.is_in_group("jugador"):
		jugador_cerca = false
		
		# Si se aleja y se dejó el panel abierto, lo cerramos forzosamente
		if keypad_layer.visible:
			abrir_cerrar_keypad()
