extends Sprite2D

# Variable que indica si el jugador está cerca para permitir interacción
var jugador_cerca = false

func _ready():
	# Animación inicial para simular la llegada del tren desde la izquierda
	var destino_final = position 	# Guardamos la posición original
	position.x -= 800 				# Empezamos fuera de pantalla a la izquierda
	var tween = create_tween()
	tween.tween_property(self, "position", destino_final, 3.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT) 	# Movimiento suave desacelerando hasta la posición final

func _process(_delta):
	# Detectamos si el jugador está cerca y pulsa la tecla de interacción
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		print("Subiendo al tren... Iniciando transición!")
		
		# Usamos el Autoload TransitionScreen para cambiar de escena con transición
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/exit.tscn")
		else:
			# En caso de que no exista el Autoload, hacemos un cambio directo como respaldo
			get_tree().change_scene_to_file("res://tscn/exit.tscn")

# Señal que detecta cuando un cuerpo entra en la zona de interacción
func _on_zona_interaccion_body_entered(body):
	# Confirmamos que el cuerpo es el jugador, ya sea por nombre o grupo
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador_cerca = true # Activamos la posibilidad de interactuar

# Señal que detecta cuando un cuerpo sale de la zona de interacción
func _on_zona_interaccion_body_exited(body):
	# Confirmamos que es el jugador para desactivar la interacción
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador_cerca = false # Desactivamos la posibilidad de interactuar
