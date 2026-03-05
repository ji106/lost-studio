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
	"luces_encendidas_level2": [], # Usaremos esta misma lista para las lámparas del nivel 3
	"hermana_rescatada": false,
	"current_scene": "res://tscn/start.tscn",
	
	# --- DATOS DE PERSISTENCIA ---
	"movil_desbloqueado": false,
	"movil_pista_resuelta": false,
	"keypad_completado": false,
	"puzzle_lamparas_completado": false # <--- NUEVO: Para la puerta del Nivel 3
}

var game_data = default_data.duplicate(true)

# --- FUNCIONES DE GUARDADO ---
func guardar_partida():
	var path = "user://save_slot_" + str(current_slot) + ".save"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(game_data)
		print(" Partida guardada (Slot: ", current_slot, ")")

func cargar_partida(slot: int) -> bool:
	var path = "user://save_slot_" + str(slot) + ".save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		game_data = file.get_var()
		current_slot = slot
		cargando_partida = true
		
		# Parche de seguridad para saves antiguos
		verificar_datos_nuevos()
		
		print(" Partida cargada del Slot ", slot)
		return true
	return false

func crear_partida_nueva(slot: int):
	current_slot = slot
	game_data = default_data.duplicate(true) 
	cargando_partida = false 
	guardar_partida()

func verificar_datos_nuevos():
	if not "movil_desbloqueado" in game_data: game_data["movil_desbloqueado"] = false
	if not "movil_pista_resuelta" in game_data: game_data["movil_pista_resuelta"] = false
	if not "keypad_completado" in game_data: game_data["keypad_completado"] = false
	if not "puzzle_lamparas_completado" in game_data: game_data["puzzle_lamparas_completado"] = false

# --- GESTIÓN DE PROGRESO ---

func puzzle_completado(nombre_puzzle: String) -> bool:
	return nombre_puzzle in game_data["puzzles_resueltos"]

func marcar_puzzle_resuelto(nombre_puzzle: String):
	if not puzzle_completado(nombre_puzzle):
		game_data["puzzles_resueltos"].append(nombre_puzzle)

func registrar_cambio_luz(id_luz: String, esta_encendida: bool):
	if esta_encendida:
		if not id_luz in game_data["luces_encendidas_level2"]:
			game_data["luces_encendidas_level2"].append(id_luz)
	else:
		game_data["luces_encendidas_level2"].erase(id_luz)
	
	# Guardado automático cada vez que tocas una luz
	guardar_partida()
