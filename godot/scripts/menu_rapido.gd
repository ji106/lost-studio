extends CanvasLayer

func _ready():
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado

func _on_boton_reanudar_pressed():
	cambiar_pausa()

func _on_boton_opciones_pressed():
	print("Abriendo opciones...")

# LA FUNCIÓN CLAVE DE GUARDADO
func _on_boton_menu_guarda_pressed():
	print("Intentando guardar en Slot: ", Global.current_slot)
	
	var player = get_tree().get_first_node_in_group("jugador")
	
	if player != null:
		# 1. Guardamos datos del jugador
		Global.game_data["player_position"] = player.global_position
		
		if "vidas_actuales" in player:
			Global.game_data["vidas"] = player.vidas_actuales
			
		# 2. NUEVO: Guardamos la ruta exacta del nivel actual (start.tscn o exit.tscn)
		Global.game_data["current_scene"] = get_tree().current_scene.scene_file_path
		
		# 3. Disparamos el guardado
		Global.guardar_partida()
		
		# 4. Quitamos pausa y salimos al menú principal
		get_tree().paused = false
		TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
	else:
		print("❌ ERROR: No se encuentra al jugador. ¿Le pusiste el grupo 'jugador'?")
