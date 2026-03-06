extends CanvasLayer

# Referencias a nodos del menú de pausa y configuración
@onready var contenedor_botones = $ColorRect/VBoxContainer 	# Contenedor con botones principales del menú
@onready var settings_menu = $Settings 						# Submenú de configuración

func _ready():
	# Ocultamos el menú al iniciar
	visible = false
	
	# Configuramos el menú de settings si existe
	if settings_menu:
		settings_menu.visible = false
		# Si el menú de settings es ventana emergente, conectamos la señal para cerrar
		if "es_ventana_emergente" in settings_menu:
			settings_menu.es_ventana_emergente = true
			if not settings_menu.cerrar_solicitado.is_connected(_on_settings_back):
				settings_menu.cerrar_solicitado.connect(_on_settings_back)

func _process(_delta):
	# Detectamos la tecla de cancelar para cerrar menú o cambiar pausa
	if Input.is_action_just_pressed("ui_cancel"):
		if settings_menu and settings_menu.visible:
			_on_settings_back() # Cerramos settings si está abierto
		else:
			cambiar_pausa() 	# Alternamos pausa y menú

func cambiar_pausa():
	# Cambiamos el estado de pausa del juego y la visibilidad del menú
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado
	
	# Control del cursor y visibilidad de submenús según estado
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Mostramos cursor
				if settings_menu: settings_menu.visible = false
		if contenedor_botones: contenedor_botones.visible = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 	# Ocultamos cursor

func _on_boton_opciones_pressed():
	# Mostramos el menú de configuración y ocultamos botones principales
	if contenedor_botones: contenedor_botones.visible = false
	if settings_menu: settings_menu.visible = true

func _on_settings_back():
	# Volvemos al menú principal desde configuración
	if settings_menu: settings_menu.visible = false
	if contenedor_botones: contenedor_botones.visible = true

func _on_boton_reanudar_pressed():
	# Reanuda el juego quitando la pausa
	cambiar_pausa()

func _on_boton_menu_guarda_pressed():
	print("Guardando progreso Trevor... Slot: ", Global.current_slot)
	
	var player = get_tree().get_first_node_in_group("jugador")
	
	if player != null:
		# Guardamos la posición actual del jugador
		Global.game_data["player_position"] = player.global_position
		
		# Guardamos vidas si existen en el jugador y en el global
		if "vidas_actuales" in player and Global.game_data.has("vidas"):
			Global.game_data["vidas"] = player.vidas_actuales
			
		# Guardamos la escena actual
		Global.game_data["current_scene"] = get_tree().current_scene.scene_file_path
		
		# Ejecutamos el guardado en disco
		Global.guardar_partida()
		
		# Quitamos la pausa y mostramos cursor para el menú principal
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Aseguramos ratón para el menú principal
		
		# Cambiamos a la escena del menú principal con transición si existe
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/menu.tscn")
	else:
		print("❌ ERROR: Jugador no encontrado.")
