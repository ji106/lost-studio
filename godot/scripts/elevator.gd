extends StaticBody2D

# Ruta de la siguiente escena a cargar cuando se usa el ascensor
@export var next_scene_path: String = "res://tscn/level_03.tscn"

# Referencias a nodos importantes
@onready var anim = $AnimationPlayer 		# Controla las animaciones de la puerta
@onready var zona = $ZonaDetectora 			# Zona para detectar al jugador cerca
@onready var punto_entrada = $PuntoEntrada 	# Lugar donde debe quedar el jugador dentro del ascensor
@onready var sprite = $Sprite2D 			# Sprite visual de la puerta

var player_ref = null # Referencia al jugador cuando está dentro de la zona
var is_active = false # Control para evitar activar la secuencia varias veces

func _ready():
	# Conectamos las señales para detectar cuando el jugador entra o sale del área
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	
	# Ponemos la puerta cerrada al iniciar para el estado inicial
	anim.play("cerrar") 
	# Alternativamente, se puede forzar un frame cerrado con sprite.frame = 0

func _process(_delta):
	# Comprobamos si el jugador está en la zona, la secuencia no está activa y se pulsa la tecla "interactuar"
	if player_ref != null and not is_active and Input.is_action_just_pressed("interactuar"):
		iniciar_secuencia_ascensor() # Iniciamos la secuencia del ascensor

func iniciar_secuencia_ascensor():
	is_active = true
	print("Iniciando secuencia de ascensor...")

	# 1. Bloqueamos el movimiento del jugador para que no pueda moverse durante la secuencia
	if player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false)
	
	# 2. Opcionalmente, cambiamos la animación del jugador para que mire hacia arriba
	if player_ref.has_node("AnimatedSprite2D"):
		player_ref.get_node("AnimatedSprite2D").play("Arriba")

	# 3. Reproducimos el sonido y animamos la apertura de la puerta
	$AudioStreamPlayer2D.play()
	anim.play("abrir")
	await anim.animation_finished # Esperamos a que termine la animación

	# 4. Movemos al jugador suavemente hacia dentro del ascensor usando tween
	var tween = create_tween()
	tween.tween_property(player_ref, "global_position", punto_entrada.global_position, 1.5)
	await tween.finished # Esperamos a que el jugador llegue al punto de entrada

	# 5. Ocultamos al jugador para simular que está dentro del ascensor cerrado
	player_ref.visible = false 
	# Nota: Si el Z-Index del ascensor es mayor que el del jugador, la puerta lo tapará visualmente

	# 6. Cerramos la puerta y esperamos a que termine la animación
	anim.play("cerrar")
	await anim.animation_finished

	# 7. Cambiamos a la siguiente escena, usando pantalla de transición si está disponible
	print("Viajando al nivel 2...")
	if has_node("/root/TransitionScreen"):
		get_node("/root/TransitionScreen").cambiar_escena(next_scene_path)
	else:
		get_tree().change_scene_to_file(next_scene_path)

# Señal que detecta cuando un cuerpo entra en la zona de detección
func _on_body_entered(body):
	# Si el cuerpo pertenece al grupo "jugador", guardamos la referencia
	if body.is_in_group("jugador"):
		player_ref = body

# Señal que detecta cuando un cuerpo sale de la zona de detección
func _on_body_exited(body):
	# Si el cuerpo pertenece al grupo "jugador", eliminamos la referencia
	if body.is_in_group("jugador"):
		player_ref = null
