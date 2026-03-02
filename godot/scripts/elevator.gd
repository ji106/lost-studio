extends StaticBody2D

# Configuración
@export var next_scene_path: String = "res://tscn/level_03.tscn"

# Referencias
@onready var anim = $AnimationPlayer
@onready var zona = $ZonaDetectora
@onready var punto_entrada = $PuntoEntrada # El Marker2D donde debe acabar el jugador
@onready var sprite = $Sprite2D

var player_ref = null # Guardaremos al jugador aquí
var is_active = false # Para evitar que le des a la E dos veces

func _ready():
	# Nos aseguramos de conectar la detección
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	
	# Aseguramos que la puerta empiece cerrada (ajusta 'cerrar' o 'RESET' según tus animaciones)
	anim.play("cerrar") 
	# O fuerza el frame cerrado: sprite.frame = 0

func _process(_delta):
	# Si hay jugador, no está activa la secuencia y pulsa E
	if player_ref != null and not is_active and Input.is_action_just_pressed("interactuar"):
		iniciar_secuencia_ascensor()

func iniciar_secuencia_ascensor():
	is_active = true
	print("Iniciando secuencia de ascensor...")

	# 1. BLOQUEAR AL JUGADOR (Para que no se pueda mover con teclas)
	if player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false) # Desactiva el movimiento del script del jugador
	
	# Opcional: Poner animación de "Idle" o "Walk" hacia arriba
	if player_ref.has_node("AnimatedSprite2D"):
		player_ref.get_node("AnimatedSprite2D").play("Arriba") # O la animación de espalda

	# 2. ABRIR PUERTA
	$AudioStreamPlayer2D.play()
	anim.play("abrir")
	await anim.animation_finished # Esperamos a que termine de abrirse

	# 3. MOVER AL JUGADOR DENTRO (Cinemática)
	var tween = create_tween()
	# Movemos al jugador desde donde esté hasta el Marker2D 'PuntoEntrada'
	# Tardará 1.5 segundos en entrar.
	tween.tween_property(player_ref, "global_position", punto_entrada.global_position, 1.5)
	
	await tween.finished # Esperamos a que el jugador llegue al centro

	# 4. OCULTAR O TAPAR AL JUGADOR
	# Opción A: Hacerlo invisible (truco de magia)
	player_ref.visible = false 
	# Opción B: Si el Z-Index del ascensor es mayor que el del jugador, la puerta lo tapará sola.

	# 5. CERRAR PUERTA
	anim.play("cerrar")
	await anim.animation_finished

	# 6. CAMBIAR ESCENA
	print("Viajando al nivel 3...")
	if has_node("/root/TransitionScreen"):
		get_node("/root/TransitionScreen").cambiar_escena(next_scene_path)
	else:
		get_tree().change_scene_to_file(next_scene_path)

# --- DETECCIÓN ---
func _on_body_entered(body):
	if body.is_in_group("jugador"):
		player_ref = body

func _on_body_exited(body):
	if body.is_in_group("jugador"):
		player_ref = null
