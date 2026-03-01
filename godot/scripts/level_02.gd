extends Node2D

# Arrastra aquí tu nodo Puerta (Exit/Door) desde el editor
@export var puerta_recompensa: Node2D 

func _ready():
	# IMPORTANTE: Usamos el grupo "lamparas" porque tus lámparas están dentro de "map"
	# Si usáramos get_children() aquí, no encontraría nada porque "map" las oculta.
	var lamps = get_tree().get_nodes_in_group("lamparas")
	
	for lamp in lamps:
		# Conectamos la señal que definimos en lamp.gd
		if not lamp.lamp_changed.is_connected(comprobar_victoria):
			lamp.lamp_changed.connect(comprobar_victoria)

func comprobar_victoria():
	var todas_encendidas = true
	var lamps = get_tree().get_nodes_in_group("lamparas")
	
	# Revisamos una por una
	for lamp in lamps:
		# Usamos la variable "is_on" que definimos en lamp.gd
		if lamp.is_on == false:
			todas_encendidas = false
			break 
	
	# Si el bucle termina y seguimos en true... ¡Ganamos!
	if todas_encendidas:
		print("¡Puzzle Completado! Abriendo puerta...")
		
		# Desactivamos las lámparas para que no se puedan volver a tocar
		desactivar_lamparas()
		
		# Abrimos la puerta
		if puerta_recompensa and puerta_recompensa.has_method("abrir_puerta"):
			puerta_recompensa.abrir_puerta()
		else:
			print("¡CUIDADO! No has asignado la Puerta en el Inspector del Level 02")

func desactivar_lamparas():
	var lamps = get_tree().get_nodes_in_group("lamparas")
	for lamp in lamps:
		lamp.set_process(false) # Deja de detectar la tecla E
