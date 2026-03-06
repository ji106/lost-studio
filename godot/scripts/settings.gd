extends Control

# Señal que avisa cuando se solicita cerrar esta ventana (útil si es ventana emergente)
signal cerrar_solicitado
# Indica si este menú es una ventana emergente (modal) o una pantalla completa
var es_ventana_emergente : bool = false 

# Referencias a botones y barras de volumen
@onready var btn_save = $save
@onready var btn_back = $back
@onready var barra_master = $BarraVolumenMaster
@onready var barra_music = $BarraVolumenMusic

# Índices de buses de audio para controlar volumen
var master_bus_index
var music_bus_index
# Ruta donde se guarda la configuración de audio
var save_path = "user://settings.cfg"
# Objeto para manejar archivos de configuración
var config = ConfigFile.new()

func _ready():
	# Obtenemos índices de los buses Master y Music (soporte para "Musica" por si acaso)
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	# Corrección por si acaso se llama "Musica"
	if music_bus_index == -1:
		music_bus_index = AudioServer.get_bus_index("Musica")

	# Conectamos señales personalizadas de las barras para detectar cambios de volumen
	barra_master.volumen_cambiado.connect(_on_barra_master_cambiada)
	barra_music.volumen_cambiado.connect(_on_barra_music_cambiada)

	# Conectamos botones para guardar y volver atrás
	btn_save.pressed.connect(_on_save_pressed)
	btn_back.pressed.connect(_on_back_pressed)

	# Cargamos la configuración guardada al iniciar
	cargar_configuracion()

# Cuando cambia el volumen master, actualizamos el bus de audio
func _on_barra_master_cambiada(nuevo_valor):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(nuevo_valor))

# Cuando cambia el volumen de música, actualizamos el bus de audio
func _on_barra_music_cambiada(nuevo_valor):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(nuevo_valor))

# Carga la configuración de volumen desde archivo o usa valores por defecto
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
		# Si no hay archivo, ponemos volumen máximo por defecto
		barra_master.set_valor(1.0)
		barra_music.set_valor(1.0)

# Guarda la configuración actual en archivo
func _on_save_pressed():
	config.set_value("audio", "master", barra_master.valor_actual)
	config.set_value("audio", "music", barra_music.valor_actual)
	config.save(save_path)
	print("Configuración guardada")

# Botón para volver atrás o cerrar menú
func _on_back_pressed():
	# Si es ventana emergente, emitimos señal para que el controlador la cierre
	if es_ventana_emergente:
		# Si estamos en pausa, solo avisamos para cerrarnos
		emit_signal("cerrar_solicitado")
	else:
		# Si es menú completo, cambiamos a la escena del menú principal
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/menu.tscn")
		else:
			get_tree().change_scene_to_file("res://tscn/menu.tscn")
