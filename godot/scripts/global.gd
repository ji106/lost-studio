extends Node

# --- VARIABLES DE ESTADO ---
var current_slot : int = 1 			# Slot actual de guardado/carga
var cargando_partida : bool = false # Indica si se está cargando una partida
var modo_menu : String = "LOAD" 	# Modo del menú, puede ser "LOAD" o "SAVE"

# Datos por defecto que se guardan y cargan
var default_data = {
	"player_position": Vector2(100, 450), 
	"puertas_abiertas": [],
	"puzzles_resueltos": [],
	"luces_encendidas_level2": [], 		# Estado de las luces en niveles 1 y 2
	"hermana_rescatada": false,
	"current_scene": "res://tscn/start.tscn",
	
	"movil_desbloqueado": false,
	"movil_pista_resuelta": false,
	"keypad_completado": false,
	"puzzle_lamparas_completado": false # Nuevo dato para puzzle nivel 1
}

var game_data = default_data.duplicate(true)

func guardar_partida():
	# Construimos la ruta del archivo según el slot actual
	var path = "user://save_slot_" + str(current_slot) + ".save"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(game_data) # Guardamos los datos en disco
		print(" Partida guardada (Slot: ", current_slot, ")")

func cargar_partida(slot: int) -> bool:
	# Ruta del archivo para el slot solicitado
	var path = "user://save_slot_" + str(slot) + ".save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		game_data = file.get_var() # Cargamos los datos desde el archivo
		current_slot = slot
		cargando_partida = true
		
		# Aseguramos que los datos nuevos estén presentes para evitar errores
		verificar_datos_nuevos()
		
		print(" Partida cargada del Slot ", slot)
		return true
	return false # No existe archivo para ese slot

func crear_partida_nueva(slot: int):
	current_slot = slot
	game_data = default_data.duplicate(true) 	# Reseteamos los datos a valores por defecto
	cargando_partida = false 
	guardar_partida() 							# Guardamos la nueva partida inmediatamente

func verificar_datos_nuevos():
	# Añadimos las claves nuevas si no están presentes en partidas antiguas
	if not "movil_desbloqueado" in game_data: game_data["movil_desbloqueado"] = false
	if not "movil_pista_resuelta" in game_data: game_data["movil_pista_resuelta"] = false
	if not "keypad_completado" in game_data: game_data["keypad_completado"] = false
	if not "puzzle_lamparas_completado" in game_data: game_data["puzzle_lamparas_completado"] = false

func puzzle_completado(nombre_puzzle: String) -> bool:
	# Devuelve true si el puzzle ya está marcado como resuelto
	return nombre_puzzle in game_data["puzzles_resueltos"]

func marcar_puzzle_resuelto(nombre_puzzle: String):
	# Añade el puzzle a la lista solo si no estaba ya resuelto
	if not puzzle_completado(nombre_puzzle):
		game_data["puzzles_resueltos"].append(nombre_puzzle)

func registrar_cambio_luz(id_luz: String, esta_encendida: bool):
	# Añade o elimina la luz de la lista según su estado actual
	if esta_encendida:
		if not id_luz in game_data["luces_encendidas_level2"]:
			game_data["luces_encendidas_level2"].append(id_luz)
	else:
		game_data["luces_encendidas_level2"].erase(id_luz)
	
	# Guardamos automáticamente cada vez que se cambia el estado de una luz
	guardar_partida()
