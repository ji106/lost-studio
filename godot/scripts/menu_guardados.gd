extends Control

# --- REFERENCIAS A LOS NODOS ---
@onready var btn_slot_1 = $VBoxContainer/Slot1
@onready var btn_slot_2 = $VBoxContainer/Slot2
@onready var btn_slot_3 = $VBoxContainer/Slot3
@onready var titulo_menu = $screen/Title  # <--- NUEVO: Arrastra aquí tu nodo TextureRect si se llama distinto

# --- IMÁGENES DE TÍTULO (Arrastrar en Inspector) ---
@export_group("Titulos del Menu")
@export var img_titulo_new_game : Texture2D # <--- Arrastra la imagen "NEW GAME"
@export var img_titulo_load_game : Texture2D # <--- Arrastra la imagen "LOAD GAME"

# --- IMÁGENES DE SLOTS ---
@export_group("Texturas Slot 1")
@export var img_vacio_1 : Texture2D
@export var img_ocupado_1 : Texture2D

@export_group("Texturas Slot 2")
@export var img_vacio_2 : Texture2D
@export var img_ocupado_2 : Texture2D

@export_group("Texturas Slot 3")
@export var img_vacio_3 : Texture2D
@export var img_ocupado_3 : Texture2D

func _ready():
	actualizar_aspecto_botones()
	actualizar_titulo() # <--- Llamamos a la nueva función

func actualizar_titulo():
	# El Global.modo_menu nos dice si venimos de pulsar "New Game" o "Load Game"
	if Global.modo_menu == "NEW":
		titulo_menu.texture = img_titulo_new_game
	elif Global.modo_menu == "LOAD":
		titulo_menu.texture = img_titulo_load_game

func actualizar_aspecto_botones():
	# --- SLOT 1 ---
	if FileAccess.file_exists("user://save_slot_1.save"):
		btn_slot_1.texture_normal = img_ocupado_1
	else:
		btn_slot_1.texture_normal = img_vacio_1
		
	# --- SLOT 2 ---
	if FileAccess.file_exists("user://save_slot_2.save"):
		btn_slot_2.texture_normal = img_ocupado_2
	else:
		btn_slot_2.texture_normal = img_vacio_2
		
	# --- SLOT 3 ---
	if FileAccess.file_exists("user://save_slot_3.save"):
		btn_slot_3.texture_normal = img_ocupado_3
	else:
		btn_slot_3.texture_normal = img_vacio_3

func procesar_slot(numero_slot: int):
	if Global.modo_menu == "NEW":
		Global.crear_partida_nueva(numero_slot)
		TransitionScreen.cambiar_escena("res://tscn/start.tscn") 
		
	elif Global.modo_menu == "LOAD":
		var carga_exitosa = Global.cargar_partida(numero_slot)
		if carga_exitosa:
			var escena_a_cargar = Global.game_data.get("current_scene", "res://tscn/start.tscn")
			TransitionScreen.cambiar_escena(escena_a_cargar)
		else:
			print("Slot vacío, no se puede cargar.")

# --- SEÑALES ---
func _on_slot_1_pressed():
	procesar_slot(1)

func _on_slot_2_pressed():
	procesar_slot(2)

func _on_slot_3_pressed():
	procesar_slot(3)

func _on_btn_back_pressed():
	TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
