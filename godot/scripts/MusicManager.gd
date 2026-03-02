extends Node

@onready var player = AudioStreamPlayer.new()

func _ready():
	add_child(player)
	player.bus = "Music" # ¡Esto es vital! La música va al bus "Music"

func play_music(nombre_archivo: String):
	# Cargamos el archivo desde tu carpeta "sounds"
	var stream = load("res://sounds/" + nombre_archivo)
	
	# Si ya está sonando esa canción, no la reiniciamos
	if player.stream == stream and player.playing:
		return
	
	player.stream = stream
	player.play()

func stop_music():
	player.stop()
