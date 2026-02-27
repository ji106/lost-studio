extends Node

# --- VARIABLES DE ESTADO ---
var current_slot : int = 1
var cargando_partida : bool = false
var modo_menu : String = "LOAD" 

# --- PLANTILLA DE DATOS (Lo que se guarda) ---
var default_data = {
	"player_position": Vector2(0, 0), 
	"vidas": 3,
	"puertas_abiertas": [],
	"current_scene": "res://tscn/start.tscn" # <--- NUEVO: Por defecto empezamos en el nivel 1
}

var game_data = default_data.duplicate()

# --- FUNCIONES DE GUARDADO ---
func guardar_partida():
	var file = FileAccess.open("user://save_slot_" + str(current_slot) + ".save", FileAccess.WRITE)
	if file:
		file.store_var(game_data)
		print("✅ Partida guardada correctamente en el Slot ", current_slot)

func cargar_partida(slot: int) -> bool:
	var path = "user://save_slot_" + str(slot) + ".save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		game_data = file.get_var()
		current_slot = slot
		cargando_partida = true
		print("📂 Partida cargada con éxito del Slot ", slot)
		return true
	else:
		print("❌ No hay datos guardados en el Slot ", slot)
		return false

func crear_partida_nueva(slot: int):
	current_slot = slot
	game_data = default_data.duplicate(true) 
	cargando_partida = false 
	guardar_partida()
	print("✨ Nueva partida creada en el Slot ", slot)
