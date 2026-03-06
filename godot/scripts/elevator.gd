extends StaticBody2D

# Ruta de la siguiente escena a cargar cuando se usa el ascensor
@export var next_scene_path: String = "res://tscn/level_03.tscn"

# Referencias a nodos importantes
@onready var anim = $AnimationPlayer 		# Controla las animaciones de la puerta
@onready var zona = $ZonaDetectora 			# Zona para detectar al jugador cerca
@onready var punto_entrada = $PuntoEntrada 	# Lugar donde debe quedar el jugador dentro del ascensor
@onready var sprite = $Sprite2D 			# Sprite visual de la puerta

var player_ref = null # Referencia al jugador cuando está dentro de la zona
var is_active = false # Para evitar activar la secuencia más de una vez

func _ready():
	# Conectamos señales para detectar cuando el jugador entra o sale de la zona
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	
	# Ponemos la puerta cerrada al iniciar (ajusta el nombre de la animación según tu proyecto)
	anim.play("cerrar") 
	# Alternativamente, puedes forzar un frame cerrado: sprite.frame = 0

func _process(_delta):
	# Si el jugador está en la zona, la secuencia no está activa, y pulsa la tecla "interactuar"
	if player_ref != null and not is_active and Input.is_action_just_pressed("interactuar"):
		iniciar_secuencia_ascensor() # Iniciamos la secuencia del ascensor

func iniciar_secuencia_ascensor():
	is_active = true
	print("Iniciando secuencia de ascensor...")

	# 1. Bloqueamos el movimiento del jugador para que no pueda salir ni moverse
	if player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false)
	
	# Opcional: Cambiamos la animación del jugador para que mire hacia arriba (o la que corresponda)
	if player_ref.has_node("AnimatedSprite2D"):
		player_ref.get_node("AnimatedSprite2D").play("Arriba")

	# 2. Abrimos la puerta del ascensor y reproducimos sonido
	$AudioStreamPlayer2D.play()
	anim.play("abrir")
	await anim.animation_finished # Esperamos a que termine la animación de apertura

	# 3. Movemos al jugador dentro del ascensor usando tween para movimiento suave
	var tween = create_tween()
	tween.tween_property(player_ref, "global_position", punto_entrada.global_position, 1.5)
	await tween.finished # Esperamos a que el jugador llegue al punto de entrada

	# 4. Ocultamos al jugador para simular que está dentro del ascensor cerrado
	player_ref.visible = false 
	# Nota: Si el Z-Index del ascensor es mayor que el del jugador, la puerta lo tapará visualmente

	# 5. Cerramos la puerta y esperamos a que termine la animación
	anim.play("cerrar")
	await anim.animation_finished

	# 6. Cambiamos a la siguiente escena, usando pantalla de transición si existe
	print("Viajando al nivel 3...")
	if has_node("/root/TransitionScreen"):
		get_node("/root/TransitionScreen").cambiar_escena(next_scene_path)
	else:
		get_tree().change_scene_to_file(next_scene_path)

# Detecta cuando un cuerpo entra en la zona del ascensor
func _on_body_entered(body):
	# Si el cuerpo pertenece al grupo "jugador", guardamos la referencia
	if body.is_in_group("jugador"):
		player_ref = body

# Detecta cuando un cuerpo sale de la zona del ascensor
func _on_body_exited(body):
	# Si el cuerpo pertenece al grupo "jugador", eliminamos la referencia
	if body.is_in_group("jugador"):
		player_ref = null
