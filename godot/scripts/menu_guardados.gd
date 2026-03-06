extends Control

# Referencias a los botones de los slots y al título del menú
@onready var btn_slot_1 = $VBoxContainer/Slot1
@onready var btn_slot_2 = $VBoxContainer/Slot2
@onready var btn_slot_3 = $VBoxContainer/Slot3
@onready var titulo_menu = $screen/Title

# Texturas para los títulos según modo (nuevo o cargar partida)
@export_group("Titulos del Menu")
@export var img_titulo_new_game : Texture2D 
@export var img_titulo_load_game : Texture2D 

# Texturas para los slots vacíos y ocupados (slot 1)
@export_group("Texturas Slot 1")
@export var img_vacio_1 : Texture2D
@export var img_ocupado_1 : Texture2D

# Texturas para los slots vacíos y ocupados (slot 2)
@export_group("Texturas Slot 2")
@export var img_vacio_2 : Texture2D
@export var img_ocupado_2 : Texture2D

# Texturas para los slots vacíos y ocupados (slot 3)
@export_group("Texturas Slot 3")
@export var img_vacio_3 : Texture2D
@export var img_ocupado_3 : Texture2D

func _ready():
	# Mostramos el cursor para poder interactuar con el menú
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Actualizamos la apariencia de los botones y el título según el estado actual
	actualizar_aspecto_botones()
	actualizar_titulo()

func actualizar_titulo():
	# Cambia el título según el modo actual (nuevo juego o cargar)
	if Global.modo_menu == "NEW":
		titulo_menu.texture = img_titulo_new_game
	elif Global.modo_menu == "LOAD":
		titulo_menu.texture = img_titulo_load_game

func actualizar_aspecto_botones():
	# Cambia la textura de cada botón según si el slot tiene una partida guardada o está vacío
	if FileAccess.file_exists("user://save_slot_1.save"):
		btn_slot_1.texture_normal = img_ocupado_1
	else:
		btn_slot_1.texture_normal = img_vacio_1
		
	if FileAccess.file_exists("user://save_slot_2.save"):
		btn_slot_2.texture_normal = img_ocupado_2
	else:
		btn_slot_2.texture_normal = img_vacio_2
		
	if FileAccess.file_exists("user://save_slot_3.save"):
		btn_slot_3.texture_normal = img_ocupado_3
	else:
		btn_slot_3.texture_normal = img_vacio_3

func procesar_slot(numero_slot: int):
	# Según el modo, crea una partida nueva o carga una existente y cambia la escena
	if Global.modo_menu == "NEW":
		Global.crear_partida_nueva(numero_slot)
		TransitionScreen.cambiar_escena("res://tscn/intro.tscn")
	elif Global.modo_menu == "LOAD":
		if Global.cargar_partida(numero_slot):
			var escena = Global.game_data.get("current_scene", "res://tscn/start.tscn")
			TransitionScreen.cambiar_escena(escena)

# Funciones que manejan la pulsación de cada botón de slot
func _on_slot_1_pressed():
	procesar_slot(1)

func _on_slot_2_pressed():
	procesar_slot(2)

func _on_slot_3_pressed():
	procesar_slot(3)

func _on_btn_back_pressed():
	# Volver al menú principal
	TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
