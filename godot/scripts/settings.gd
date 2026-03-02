extends Control

# --- NUEVO: SEÑALES Y VARIABLES ---
signal cerrar_solicitado 
var es_ventana_emergente : bool = false 

# --- REFERENCIAS (TUS ORIGINALES) ---
@onready var btn_save = $save
@onready var btn_back = $back
@onready var barra_master = $BarraVolumenMaster
@onready var barra_music = $BarraVolumenMusic

var master_bus_index
var music_bus_index
var save_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	# Corrección por si acaso se llama "Musica"
	if music_bus_index == -1: music_bus_index = AudioServer.get_bus_index("Musica")
	
	barra_master.volumen_cambiado.connect(_on_barra_master_cambiada)
	barra_music.volumen_cambiado.connect(_on_barra_music_cambiada)
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	cargar_configuracion()

func _on_barra_master_cambiada(nuevo_valor):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(nuevo_valor))

func _on_barra_music_cambiada(nuevo_valor):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(nuevo_valor))

func cargar_configuracion():
	var err = config.load(save_path)
	if err == OK:
		var master_vol = config.get_value("audio", "master", 1.0)
		var music_vol = config.get_value("audio", "music", 1.0)
		barra_master.set_valor(master_vol)
		barra_music.set_valor(music_vol)
		AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_vol))
		AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_vol))
	else:
		barra_master.set_valor(1.0)
		barra_music.set_valor(1.0)

func _on_save_pressed():
	config.set_value("audio", "master", barra_master.valor_actual)
	config.set_value("audio", "music", barra_music.valor_actual)
	config.save(save_path)
	print("Configuración guardada")

func _on_back_pressed():
	# --- NUEVO: Lógica inteligente ---
	if es_ventana_emergente:
		# Si estamos en pausa, solo avisamos para cerrarnos
		emit_signal("cerrar_solicitado")
	else:
		# Si estamos en el menú principal, cambiamos de escena normal
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/menu.tscn")
