extends Control

# --- REFERENCIAS ---
@onready var btn_save = $save
@onready var btn_back = $back

# Referencias a los Nodos de las Barras (Asegúrate de que los nombres coinciden con tu árbol)
@onready var barra_master = $BarraVolumenMaster
@onready var barra_music = $BarraVolumenMusic

# Indices de los buses de audio de Godot
var master_bus_index
var music_bus_index

# Configuración de guardado
var save_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	# 1. Obtener los índices de Audio de Godot
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	
	# 2. CONEXIÓN DE SEÑALES (AQUÍ ESTÁ LA CLAVE) 🔌
	# Conectamos la señal "volumen_cambiado" de cada barra a una función en este script
	barra_master.volumen_cambiado.connect(_on_barra_master_cambiada)
	barra_music.volumen_cambiado.connect(_on_barra_music_cambiada)
	
	# Conectamos los botones también
	btn_save.pressed.connect(_on_save_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	# 3. Cargar la configuración guardada
	cargar_configuracion()

# --- FUNCIONES QUE RESPONDEN A LAS SEÑALES ---

func _on_barra_master_cambiada(nuevo_valor):
	# Cambia el volumen real del juego (Master)
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(nuevo_valor))

func _on_barra_music_cambiada(nuevo_valor):
	# Cambia el volumen real de la Música
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(nuevo_valor))

# --- GUARDADO Y CARGA ---

func cargar_configuracion():
	var err = config.load(save_path)
	if err == OK:
		var master_vol = config.get_value("audio", "master", 1.0)
		var music_vol = config.get_value("audio", "music", 1.0)
		
		# Mandamos el valor a las barras para que se pinten correctamente
		barra_master.set_valor(master_vol)
		barra_music.set_valor(music_vol)
		
		# Ajustamos el audio real
		AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_vol))
		AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_vol))
	else:
		# Primera vez: Todo al máximo
		barra_master.set_valor(1.0)
		barra_music.set_valor(1.0)

func _on_save_pressed():
	# Guardamos los valores actuales
	config.set_value("audio", "master", barra_master.valor_actual)
	config.set_value("audio", "music", barra_music.valor_actual)
	config.save(save_path)
	print("Configuración guardada")

func _on_back_pressed():
	# Vuelve al menú (ajusta la ruta si es necesario)
	if has_node("/root/TransitionScreen"):
		TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/menu.tscn")
