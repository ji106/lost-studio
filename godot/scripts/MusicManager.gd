extends Node

# Creamos un nuevo objeto para reproducir sonidos al iniciar el nodo
@onready var player = AudioStreamPlayer.new()

func _ready():
	# Añadimos el reproductor de audio como hijo del nodo actual para que funcione en la escena
	add_child(player)

	# Asignamos el reproductor al bus de audio llamado "Music" para controlar volumen y efectos
	player.bus = "Music"

func play_music(nombre_archivo: String):
	# Cargamos el archivo de sonido desde la carpeta "sounds" usando el nombre recibido
	var stream = load("res://sounds/" + nombre_archivo)
	
	# Comprobamos si el sonido que queremos reproducir ya está sonando para evitar reiniciarlo
	if player.stream == stream and player.playing:
		return # Si ya suena, no hacemos nada

	# Asignamos el audio cargado al reproductor
	player.stream = stream

	# Iniciamos la reproducción del audio
	player.play()

func stop_music():
	# Paramos la reproducción del sonido
	player.stop()
