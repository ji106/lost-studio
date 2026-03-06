extends Node2D

# Referencias a nodos de interfaz y jugador
@onready var keypad_layer = $CanvasLayer 	# Capa del keypad numérico
@onready var keypad = $CanvasLayer/Keypad 	# Nodo del keypad
@onready var nota_layer = $CanvasLayer2 	# Capa de la nota
@onready var nota = $CanvasLayer2/Note2 	# Nodo de la nota
@onready var mobile_layer = $CanvasLayer3 	# Capa del móvil
@onready var mobile = $CanvasLayer3/mobile 	# Nodo del móvil

# Estados para saber si el jugador está cerca de cada objeto o si la puerta está desbloqueada
var cerca_keypad : bool = false
var cerca_estanteria : bool = false
var cerca_mesa : bool = false
var cerca_puerta : bool = false
var puerta_desbloqueada : bool = false

func _ready():
	# Iniciamos la música del nivel 1
	MusicManager.play_music("musica2.mp3")
	
	# Ocultamos todas las interfaces al comenzar
	if keypad_layer: keypad_layer.visible = false
	if nota: nota.visible = false
	if mobile_layer: mobile_layer.visible = false
	
	# Cargamos el estado guardado de la puerta para saber si está desbloqueada
	# Si en el Global dice que ya hicimos el keypad, abrimos la puerta directamente
	if Global.game_data.get("keypad_completado") == true:
		puerta_desbloqueada = true
		print("Nivel 1: Puerta cargada como DESBLOQUEADA")
	
	# Conectamos la señal que indica que el puzzle se resolvió
	if keypad.has_signal("simon_completado"):
		keypad.simon_completado.connect(_on_puzzle_resuelto)

func _input(event):
	# Detectamos si se presiona la tecla de interacción
	if event.is_action_pressed("interactuar"):
		
		# Evitamos interacciones si el móvil está visible y el input está en un campo de texto
		if mobile_layer.visible:
			var input_line = mobile.get_node("Pantallas/HintApp/LineEdit")
			if input_line and input_line.has_focus():
				return 
		
		# Comprobamos cerca de qué objeto está el jugador para abrir/cerrar interfaces o intentar salir
		if cerca_puerta:
			intentar_salir()
		elif cerca_keypad:
			abrir_cerrar_keypad()
		elif cerca_estanteria:
			abrir_cerrar_nota()
		elif cerca_mesa:
			abrir_cerrar_movil()

func _on_puzzle_resuelto():
	# Se ejecuta cuando el puzzle del keypad se completa correctamente
	puerta_desbloqueada = true
	
	# Guardamos la partida para asegurar persistencia
	Global.guardar_partida()

	# Esperamos un poco y cerramos el keypad si está visible
	await get_tree().create_timer(1.5).timeout
	if keypad_layer.visible: abrir_cerrar_keypad()

func intentar_salir():
	# Si la puerta está desbloqueada, cambiamos de nivel
	if puerta_desbloqueada:
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/level_02.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/level_02.tscn")
	else:
		print("La puerta está cerrada. Necesitas el código.")

func abrir_cerrar_keypad():
	# Solo abrimos el keypad si no están abiertas otras interfaces
	if nota.visible or mobile_layer.visible: return
	keypad_layer.visible = !keypad_layer.visible
	gestionar_estado_jugador(keypad_layer.visible)

func abrir_cerrar_nota():
	# Solo abrimos la nota si no están abiertas otras interfaces
	if keypad_layer.visible or mobile_layer.visible: return
	nota.visible = !nota.visible
	gestionar_estado_jugador(nota.visible)

func abrir_cerrar_movil():
	# Solo abrimos el móvil si no están abiertas otras interfaces
	if keypad_layer.visible or nota.visible: return
	mobile_layer.visible = !mobile_layer.visible

	# Si cerramos el móvil, liberamos el foco del campo de texto
	if not mobile_layer.visible:
		var input_line = mobile.get_node("Pantallas/HintApp/LineEdit")
		if input_line: input_line.release_focus()
		
	gestionar_estado_jugador(mobile_layer.visible)

func gestionar_estado_jugador(pausar: bool):
	# Congela o descongela al jugador y cambia el modo del cursor según el estado de las interfaces
	var player = get_tree().get_first_node_in_group("jugador")
	if pausar:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if player: player.set_congelado(true)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		if player: player.set_congelado(false)

# Señales para detectar cuando el jugador entra o sale de las zonas de interacción

func _on_zona_keypad_body_entered(body):
	if body.is_in_group("jugador"):
		cerca_keypad = true

func _on_zona_keypad_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_keypad = false
		if keypad_layer.visible:
			abrir_cerrar_keypad()

func _on_zona_estanteria_body_entered(body):
	if body.is_in_group("jugador"):
		cerca_estanteria = true

func _on_zona_estanteria_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_estanteria = false
		if nota.visible:
			abrir_cerrar_nota()

func _on_zona_mesa_body_entered(body):
	if body.is_in_group("jugador"):
		cerca_mesa = true

func _on_zona_mesa_body_exited(body): 
	if body.is_in_group("jugador"): 
		cerca_mesa = false
		if mobile_layer.visible:
			abrir_cerrar_movil()

func _on_puerta_salida_body_entered(body):
	if body.is_in_group("jugador"):
		cerca_puerta = true

func _on_puerta_salida_body_exited(body):
	if body.is_in_group("jugador"):
		cerca_puerta = false
