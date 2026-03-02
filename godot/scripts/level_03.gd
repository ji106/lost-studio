extends Node2D

# --- REFERENCIAS A NODOS ---
@onready var keypad_layer = $CanvasLayer
@onready var keypad = $CanvasLayer/Keypad
@onready var nota_layer = $CanvasLayer2
@onready var nota = $CanvasLayer2/Note2 
@onready var mobile_layer = $CanvasLayer3
@onready var mobile = $CanvasLayer3/mobile

# --- ESTADOS ---
var cerca_keypad : bool = false
var cerca_estanteria : bool = false 
var cerca_mesa : bool = false
var cerca_puerta : bool = false
var puerta_desbloqueada : bool = false

func _ready():
	MusicManager.play_music("musica2.mp3")
	if keypad_layer: keypad_layer.visible = false
	if nota: nota.visible = false
	if mobile_layer: mobile_layer.visible = false
	
	if keypad.has_signal("simon_completado"):
		keypad.simon_completado.connect(_on_puzzle_resuelto)

func _input(event):
	if event.is_action_pressed("interactuar"):
		
		# --- NUEVA PROTECCIÓN PARA EL MÓVIL ---
		# Si el móvil está abierto, comprobamos si el LineEdit tiene el foco (el cursor)
		if mobile_layer.visible:
			# Accedemos al LineEdit de la HintApp
			var input_line = mobile.get_node("Pantallas/HintApp/LineEdit")
			if input_line and input_line.has_focus():
				return # SALIMOS DE LA FUNCIÓN: Escribe la 'e' pero NO cierra el móvil
		
		# Si no estamos escribiendo, el comportamiento es el normal:
		if cerca_puerta:
			intentar_salir()
		elif cerca_keypad:
			abrir_cerrar_keypad()
		elif cerca_estanteria:
			abrir_cerrar_nota()
		elif cerca_mesa:
			abrir_cerrar_movil()

# --- LÓGICA DEL PUZZLE ---

func _on_puzzle_resuelto():
	puerta_desbloqueada = true
	await get_tree().create_timer(1.5).timeout
	if keypad_layer.visible: abrir_cerrar_keypad()

func intentar_salir():
	if puerta_desbloqueada:
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/level_02.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/level_02.tscn")

# --- LÓGICA DE INTERFACES ---

func abrir_cerrar_keypad():
	if nota.visible or mobile_layer.visible: return
	keypad_layer.visible = !keypad_layer.visible
	gestionar_estado_jugador(keypad_layer.visible)

func abrir_cerrar_nota():
	if keypad_layer.visible or mobile_layer.visible: return
	nota.visible = !nota.visible
	gestionar_estado_jugador(nota.visible)

func abrir_cerrar_movil():
	if keypad_layer.visible or nota.visible: return
	mobile_layer.visible = !mobile_layer.visible
	
	# Al cerrar el móvil, le quitamos el foco al LineEdit por seguridad
	if not mobile_layer.visible:
		var input_line = mobile.get_node("Pantallas/HintApp/LineEdit")
		if input_line: input_line.release_focus()
		
	gestionar_estado_jugador(mobile_layer.visible)

func gestionar_estado_jugador(pausar: bool):
	var player = get_tree().get_first_node_in_group("jugador")
	if pausar:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
		if player: player.set_congelado(true) 
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 
		if player: player.set_congelado(false)

# --- SEÑALES (DETECTORES) ---

func _on_zona_keypad_body_entered(body): if body.is_in_group("jugador"): cerca_keypad = true
func _on_zona_keypad_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_keypad = false
		if keypad_layer.visible: abrir_cerrar_keypad()

func _on_zona_estanteria_body_entered(body): if body.is_in_group("jugador"): cerca_estanteria = true
func _on_zona_estanteria_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_estanteria = false
		if nota.visible: abrir_cerrar_nota()

func _on_zona_mesa_body_entered(body): if body.is_in_group("jugador"): cerca_mesa = true
func _on_zona_mesa_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_mesa = false
		if mobile_layer.visible: abrir_cerrar_movil()

func _on_puerta_salida_body_entered(body): if body.is_in_group("jugador"): cerca_puerta = true
func _on_puerta_salida_body_exited(body): if body.is_in_group("jugador"): cerca_puerta = false
