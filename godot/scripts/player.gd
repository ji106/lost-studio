extends CharacterBody2D

# Velocidad de movimiento del jugador
@export var speed: float = 100.0
# Referencia al sprite animado para cambiar animaciones según movimiento
@onready var animated_sprite_2d = $AnimatedSprite2D

# Tiempo que el jugador lleva quieto, para activar animación de espera
var tiempo_quieto : float = 0.0
# Última dirección en la que se movió el jugador, usada para animación de espera
var ultima_direccion : String = "Abajo" 

# Variable que indica si el jugador está cerca del tren para poder interactuar
var cerca_del_tren : bool = false

func _ready():
	# Si estamos cargando desde una partida guardada, teletransportamos al jugador a la posición guardada
	if Global.cargando_partida == true:
		print("🚀 Teletransportando jugador a posición guardada...")
		if "player_position" in Global.game_data:
			global_position = Global.game_data["player_position"]
		Global.cargando_partida = false

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	# Detectamos la dirección según las teclas pulsadas
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	# Si hay alguna dirección, normalizamos para evitar velocidad diagonal mayor
	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * speed 	# Aplicamos velocidad
		tiempo_quieto = 0.0 			# Reiniciamos tiempo quieto
		update_animation(direction) 	# Actualizamos animación según dirección
		
		# Si la animación actual es de parada, no hacemos nada para evitar conflictos
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation.begins_with("Stop"):
			pass 
	else:
		# Si no se mueve, velocidad cero y contamos tiempo quieto
		velocity = Vector2.ZERO
		tiempo_quieto += delta

		# Si lleva más de 5 segundos quieto, mostramos animación de espera según última dirección
		if tiempo_quieto >= 5.0:
			var animacion_stop = "Stop" + ultima_direccion
			if animated_sprite_2d.sprite_frames.has_animation(animacion_stop):
				if animated_sprite_2d.animation != animacion_stop:
					animated_sprite_2d.play(animacion_stop)
		else:
			# Mientras no llegue a 5 segundos, paramos animación si no es de espera
			if not animated_sprite_2d.animation.begins_with("Stop"):
				animated_sprite_2d.stop()
	
	move_and_slide() # Movemos el personaje con la velocidad calculada
	
	# Reproducimos sonido de pasos solo si el jugador se mueve
	if velocity.length() > 0:
		# Verificamos que el nodo existe para evitar errores si lo borras
		if has_node("SonidoPasos"):
			if not $SonidoPasos.playing:
				$SonidoPasos.play()
	else:
		if has_node("SonidoPasos"):
			$SonidoPasos.stop()
	
	# Detectamos si el jugador pulsa la tecla de interacción
	if Input.is_action_just_pressed("interactuar"):
		# Si está cerca del tren, iniciamos transición para subir
		if cerca_del_tren:
			print("Subiendo al tren... ¡Iniciando transición!")
			if has_node("/root/TransitionScreen"):
				TransitionScreen.cambiar_escena("res://tscn/exit.tscn")
			else:
				get_tree().change_scene_to_file("res://tscn/exit.tscn")

# Actualiza la animación según la dirección de movimiento
func update_animation(direction: Vector2) -> void:
	var animation_name: String = animated_sprite_2d.animation

	if direction.x > 0:
		animation_name = "Derecha"
		ultima_direccion = "Derecha"
		animated_sprite_2d.offset = Vector2(0, 0) 
	elif direction.x < 0:
		animation_name = "Izquierda"
		ultima_direccion = "Izquierda"
		animated_sprite_2d.offset = Vector2(0, 0)
	elif direction.y > 0:
		animation_name = "Abajo"
		ultima_direccion = "Abajo"
		animated_sprite_2d.offset = Vector2(0, 0)
	elif direction.y < 0:
		animation_name = "Arriba"
		ultima_direccion = "Arriba"
		animated_sprite_2d.offset = Vector2(0, 0) 

	# Cambiamos la animación solo si es distinta a la actual
	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
	elif not animated_sprite_2d.is_playing():
		animated_sprite_2d.play(animation_name)

# Función para usar una escalera: mueve al jugador suavemente a destino con animación parada
func usar_escalera(destino: Vector2, tiempo: float, animacion_parado: String):
	set_physics_process(false) 										# Desactivamos el movimiento manual
	velocity = Vector2.ZERO
	animated_sprite_2d.play(animacion_parado) 						# Animación de parada
	animated_sprite_2d.stop() 										# Se asegura que la animación no se repita
	var tween = create_tween()
	tween.tween_property(self, "global_position", destino, tiempo) 	# Animamos movimiento
	tween.tween_callback(terminar_escalera)							# Al terminar, reactivamos el movimiento

func terminar_escalera():
	set_physics_process(true) # Reactivamos el movimiento manual

# Congela o descongela al jugador (por ejemplo, durante diálogos o pausas)
func set_congelado(estoy_congelado: bool):
	set_physics_process(!estoy_congelado)
	if estoy_congelado:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()
