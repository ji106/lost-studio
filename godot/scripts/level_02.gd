extends Node2D

@export var puerta_recompensa: Node2D  # Referencia a la puerta que se abrirá al completar el puzzle

func _ready():
	# Iniciamos la música del nivel 2 si el MusicManager está disponible
	if has_node("/root/MusicManager"):
		MusicManager.play_music("musica1.mp3")

	# Buscamos todas las lámparas en el grupo "lamparas"
	var lamps = get_tree().get_nodes_in_group("lamparas")

	# Conectamos la señal de cambio de lámpara para comprobar la victoria cada vez que cambie una
	for lamp in lamps:
		if not lamp.lamp_changed.is_connected(comprobar_victoria):
			lamp.lamp_changed.connect(comprobar_victoria)

func comprobar_victoria():
	var todas_encendidas = true
	var lamps = get_tree().get_nodes_in_group("lamparas")
	
	# Revisamos si todas las lámparas están encendidas
	for lamp in lamps:
		# Usamos la variable "is_on" que definimos en lamp.gd
		if lamp.is_on == false:
			todas_encendidas = false
			break 
	
	# Si todas están encendidas, activamos el éxito
	if todas_encendidas:
		print("¡Puzzle Completado! Abriendo puerta...")
		
		# Desactivamos las lámparas para evitar más interacciones
		desactivar_lamparas()
		
		# Abrimos la puerta llamando a su método específico
		if puerta_recompensa and puerta_recompensa.has_method("abrir_puerta"):
			puerta_recompensa.abrir_puerta()
		else:
			print("¡CUIDADO! No has asignado la Puerta en el Inspector del Level 02")

func desactivar_lamparas():
	# Desactiva el procesamiento de las lámparas para que no respondan a la tecla E
	var lamps = get_tree().get_nodes_in_group("lamparas")
	for lamp in lamps:
		lamp.set_process(false) # Deja de detectar la tecla E
