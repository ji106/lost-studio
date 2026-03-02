extends Node

# --- VARIABLES DE ESTADO ---
var current_slot : int = 1
var cargando_partida : bool = false
var modo_menu : String = "LOAD" 

# --- PLANTILLA DE DATOS (Lo que se guarda) ---
var default_data = {
	"player_position": Vector2(100, 450), 
	"puertas_abiertas": [],
	"puzzles_resueltos": [],
	"luces_encendidas_level2": [], # <--- Registro de las lámparas
	"hermana_rescatada": false,
	"current_scene": "res://tscn/start.tscn"
}

var game_data = default_data.duplicate(true)

# --- FUNCIONES DE GUARDADO ---
func guardar_partida():
	var path = "user://save_slot_" + str(current_slot) + ".save"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(game_data)
		print("✅ Partida guardada (Luces en memoria: ", game_data["luces_encendidas_level2"].size(), ")")

func cargar_partida(slot: int) -> bool:
	var path = "user://save_slot_" + str(slot) + ".save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		game_data = file.get_var()
		current_slot = slot
		cargando_partida = true
		print("📂 Partida cargada del Slot ", slot)
		return true
	return false

func crear_partida_nueva(slot: int):
	current_slot = slot
	game_data = default_data.duplicate(true) 
	cargando_partida = false 
	guardar_partida()

# --- GESTIÓN DE PROGRESO (Puzzles y Luces) ---

func puzzle_completado(nombre_puzzle: String) -> bool:
	return nombre_puzzle in game_data["puzzles_resueltos"]

func marcar_puzzle_resuelto(nombre_puzzle: String):
	if not puzzle_completado(nombre_puzzle):
		game_data["puzzles_resueltos"].append(nombre_puzzle)

# ESTA ES LA FUNCIÓN QUE TE DABA ERROR
func registrar_cambio_luz(id_luz: String, esta_encendida: bool):
	if esta_encendida:
		if not id_luz in game_data["luces_encendidas_level2"]:
			game_data["luces_encendidas_level2"].append(id_luz)
	else:
		game_data["luces_encendidas_level2"].erase(id_luz)
	
	# Opcional: Auto-guardar para que el progreso de las luces no se pierda
	guardar_partida()
