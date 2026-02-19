extends CharacterBody2D

# --- VARIABLES DE MOVIMIENTO ---
@export var speed: float = 100.0
@onready var animated_sprite_2d = $AnimatedSprite2D

# --- VARIABLES DE ESPERA (IDLE) ---
var tiempo_quieto : float = 0.0
var ultima_direccion : String = "Abajo" # Por defecto miramos hacia abajo al empezar

# --- VARIABLES DE VIDA ---
@export var vidas_maximas : int = 3
var vidas_actuales : int = 0

@export var textura_lleno : Texture2D
@export var textura_vacio : Texture2D
@onready var contenedor_corazones = $Vidas/ContenedorCorazones

# --- VARIABLES DE INTERACCIÓN ---
var cerca_del_tren : bool = false

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
		# --- EL JUGADOR SE MUEVE ---
		direction = direction.normalized()
		velocity = direction * speed
		tiempo_quieto = 0.0 # Reseteamos el contador si se mueve
		update_animation(direction)
	else:
		# --- EL JUGADOR ESTÁ QUIETO ---
		velocity = Vector2.ZERO
		tiempo_quieto += delta # Empezamos a sumar segundos
		
		if tiempo_quieto >= 5.0:
			# Han pasado 5 segundos, reproducimos la animación de Stop correspondiente
			var animacion_stop = "Stop" + ultima_direccion
			if animated_sprite_2d.animation != animacion_stop:
				animated_sprite_2d.play(animacion_stop)
		else:
			# Si aún no han pasado 5 segundos, simplemente paramos la animación de caminar
			if not animated_sprite_2d.animation.begins_with("Stop"):
				animated_sprite_2d.stop()
	
	move_and_slide()
	
	# --- LÓGICA DE INTERACTUAR ---
	if Input.is_action_just_pressed("interactuar"):
		if cerca_del_tren:
			print("Subiendo al tren... ¡Iniciando transición!")
			# Llamamos a nuestro nuevo Autoload en lugar del get_tree()
			TransitionScreen.cambiar_escena("res://tscn/exit.tscn")

func update_animation(direction: Vector2) -> void:
	var animation_name: String = animated_sprite_2d.animation

	# --- CORRECCIÓN DE DESFASES (OFFSET) Y ACTUALIZACIÓN DE DIRECCIÓN ---
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
	
	# Reproducir animación
	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)
	elif not animated_sprite_2d.is_playing():
		animated_sprite_2d.play(animation_name)

# --- FUNCIONES DE VIDA ---
func recibir_dano():
	vidas_actuales -= 1
	print("Auch! Vidas restantes: ", vidas_actuales)
	actualizar_interfaz()
	if vidas_actuales <= 0:
		morir()

func actualizar_interfaz():
	if contenedor_corazones:
		var corazones = contenedor_corazones.get_children()
		for i in range(corazones.size()):
			if i < vidas_actuales:
				corazones[i].texture = textura_lleno
			else:
				corazones[i].texture = textura_vacio

func morir():
	print(" Game Over")
	get_tree().reload_current_scene()

# --- SEÑALES ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass

# --- FUNCIÓN PARA USAR ESCALERAS MECÁNICAS ---
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
