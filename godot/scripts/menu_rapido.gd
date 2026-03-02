extends CanvasLayer

# --- REFERENCIAS ---
# Corregimos la ruta según tu jerarquía
@onready var contenedor_botones = $ColorRect/VBoxContainer
@onready var settings_menu = $Settings 

func _ready():
	visible = false
	
	# Preparamos el menú de settings si existe
	if settings_menu:
		settings_menu.visible = false
		if "es_ventana_emergente" in settings_menu:
			settings_menu.es_ventana_emergente = true
			if not settings_menu.cerrar_solicitado.is_connected(_on_settings_back):
				settings_menu.cerrar_solicitado.connect(_on_settings_back)

func _process(_delta):
	# Usamos _delta para evitar avisos de Godot
	if Input.is_action_just_pressed("ui_cancel"):
		if settings_menu and settings_menu.visible:
			_on_settings_back()
		else:
			cambiar_pausa()

func cambiar_pausa():
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado
	
	# --- LÓGICA DEL RATÓN ---
	if visible:
		# Si el menú está abierto, forzamos el ratón visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Reset visual: mostrar botones y ocultar settings
		if settings_menu: settings_menu.visible = false
		if contenedor_botones: contenedor_botones.visible = true
	else:
		# Si el menú se cierra, ocultamos el ratón para jugar
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_boton_opciones_pressed():
	if contenedor_botones: contenedor_botones.visible = false
	if settings_menu: settings_menu.visible = true

func _on_settings_back():
	if settings_menu: settings_menu.visible = false
	if contenedor_botones: contenedor_botones.visible = true

func _on_boton_reanudar_pressed():
	cambiar_pausa()

func _on_boton_menu_guarda_pressed():
	print("Guardando progreso Trevor... Slot: ", Global.current_slot)
	
	var player = get_tree().get_first_node_in_group("jugador")
	
	if player != null:
		# 1. Guardamos datos del jugador [cite: 2025-11-28]
		Global.game_data["player_position"] = player.global_position
		
		# Eliminamos la referencia a "vidas" si ya las quitaste del Global
		if "vidas_actuales" in player and Global.game_data.has("vidas"):
			Global.game_data["vidas"] = player.vidas_actuales
			
		# 2. Guardamos la escena actual
		Global.game_data["current_scene"] = get_tree().current_scene.scene_file_path
		
		# 3. Disparamos el guardado
		Global.guardar_partida()
		
		# 4. Quitamos pausa y salimos al menú con el ratón visible
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Aseguramos ratón para el menú principal
		
		# Transición de salida
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/menu.tscn")
	else:
		print("❌ ERROR: Jugador no encontrado. Revisa el grupo 'jugador' [cite: 2025-11-28]")
