extends CharacterBody2D

# --- VARIABLES DE MOVIMIENTO ---
@export var speed: float = 100.0
@onready var animated_sprite_2d = $AnimatedSprite2D

# --- VARIABLES DE VIDA ---
@export var vidas_maximas : int = 3
var vidas_actuales : int = 0

@export var textura_lleno : Texture2D
@export var textura_vacio : Texture2D
@onready var contenedor_corazones = $Vidas/ContenedorCorazones

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
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()
	
	move_and_slide()

func update_animation(direction: Vector2) -> void:
	var animation_name: String = animated_sprite_2d.animation

	# --- CORRECCIÓN DE DESFASES (OFFSET) ---
	if direction.x > 0:
		animation_name = "Derecha"
		# Modifica la 'Y' si el personaje tiembla al mirar a la derecha
		animated_sprite_2d.offset = Vector2(0, 0) 
		
	elif direction.x < 0:
		animation_name = "Izquierda"
		# Modifica la 'Y' si el personaje tiembla al mirar a la izquierda
		animated_sprite_2d.offset = Vector2(0, 0)
		
	elif direction.y > 0:
		animation_name = "Abajo"
		# Esta suele ser la animación base, quizás la puedas dejar en (0,0)
		animated_sprite_2d.offset = Vector2(0, 0)
		
	elif direction.y < 0:
		animation_name = "Arriba"
		# Modifica la 'Y' si el personaje tiembla al mirar hacia arriba
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

func set_congelado(estoy_congelado: bool):
	# 1. Encendemos o apagamos el movimiento 
	set_physics_process(!estoy_congelado)
	
	# 2. Si nos congelan, obligamos a parar la animación
	if estoy_congelado:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()
