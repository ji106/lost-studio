extends Node

# Creamos un nuevo objeto para reproducir sonidos al iniciar el nodo
@onready var player = AudioStreamPlayer.new()

func _ready():
	# Añadimos el reproductor de audio como hijo del nodo actual para que funcione en la escena
	add_child(player)
	# Indicamos que el audio se envíe al canal o bus llamado "Music" (para controlar volumen o efectos juntos)
	player.bus = "Music"
func play_music(nombre_archivo: String):
	# Cargamos el archivo de sonido desde la carpeta "sounds" usando el nombre que nos pasan
	var stream = load("res://sounds/" + nombre_archivo)
	
	# Comprobamos si el sonido que queremos reproducir ya está sonando
	if player.stream == stream and player.playing:
		# Si es así, no hacemos nada para que no se reinicie la canción
		return

	# Asignamos el audio cargado al reproductor
	player.stream = stream
	# Empezamos a reproducir el audio
	player.play()

func stop_music():
	# Paramos la reproducción del sonido
	player.stop()
