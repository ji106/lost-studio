extends CharacterBody2D

# --- VARIABLES DE MOVIMIENTO ---
@export var speed: float = 100.0
@onready var animated_sprite_2d = $AnimatedSprite2D

# --- VARIABLES DE ESPERA (IDLE) ---
var tiempo_quieto : float = 0.0
var ultima_direccion : String = "Abajo" 

# --- VARIABLES DE INTERACCIÓN ---
var cerca_del_tren : bool = false

# --- INICIALIZACIÓN ---
func _ready():
	if Global.cargando_partida == true:
		print("🚀 Teletransportando jugador a posición guardada...")
		if "player_position" in Global.game_data:
			global_position = Global.game_data["player_position"]
		Global.cargando_partida = false

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * speed
		tiempo_quieto = 0.0
		update_animation(direction)
		
		# Forzamos que, si se mueve, no tenga animación de Stop
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation.begins_with("Stop"):
			pass 
	else:
		velocity = Vector2.ZERO
		tiempo_quieto += delta
		
		if tiempo_quieto >= 5.0:
			var animacion_stop = "Stop" + ultima_direccion
			if animated_sprite_2d.sprite_frames.has_animation(animacion_stop):
				if animated_sprite_2d.animation != animacion_stop:
					animated_sprite_2d.play(animacion_stop)
		else:
			if not animated_sprite_2d.animation.begins_with("Stop"):
				animated_sprite_2d.stop()
	
	move_and_slide()
	
	# --- CORRECCIÓN SONIDO DE PASOS ---
	# Quitamos 'is_on_floor()' porque en vista Top-Down suele fallar al no haber gravedad
	if velocity.length() > 0:
		# Verificamos que el nodo existe para evitar errores si lo borras
		if has_node("SonidoPasos"):
			if not $SonidoPasos.playing:
				$SonidoPasos.play()
	else:
		if has_node("SonidoPasos"):
			$SonidoPasos.stop()
	
	# --- LÓGICA DE INTERACTUAR ---
	if Input.is_action_just_pressed("interactuar"):
		if cerca_del_tren:
			print("Subiendo al tren... ¡Iniciando transición!")
			if has_node("/root/TransitionScreen"):
				TransitionScreen.cambiar_escena("res://tscn/exit.tscn")
			else:
				get_tree().change_scene_to_file("res://tscn/exit.tscn")

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
	
	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
	elif not animated_sprite_2d.is_playing():
		animated_sprite_2d.play(animation_name)

# --- FUNCIONES EXTRA ---
func usar_escalera(destino: Vector2, tiempo: float, animacion_parado: String):
	set_physics_process(false)
	velocity = Vector2.ZERO
	animated_sprite_2d.play(animacion_parado)
	animated_sprite_2d.stop() 
	var tween = create_tween()
	tween.tween_property(self, "global_position", destino, tiempo)
	tween.tween_callback(terminar_escalera)

func terminar_escalera():
	set_physics_process(true)

func set_congelado(estoy_congelado: bool):
	set_physics_process(!estoy_congelado)
	if estoy_congelado:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()
