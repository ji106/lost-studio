extends StaticBody2D

# Textura que muestra la puerta cuando está cerrada
@export var texture_closed: Texture2D
# Textura que muestra la puerta cuando está abierta
@export var texture_open: Texture2D

# Ruta de la siguiente escena a cargar al entrar por la puerta
@export var next_scene_path: String = "res://tscn/final_screen.tscn" 

# Estado interno de la puerta: abierta o cerrada
var is_open: bool = false
# Indica si el jugador está cerca de la puerta
var player_near: bool = false

# Referencia al sprite que muestra la puerta
@onready var sprite = $Sprite2D
# Referencia a la forma de colisión para detectar presencia
@onready var collision = $CollisionShape2D 

func _ready():
	# Al iniciar, ponemos la textura de puerta cerrada
	sprite.texture = texture_closed

func _process(_delta):
	# Si la puerta está abierta, el jugador está cerca y pulsa la tecla "interactuar" (E)
	if is_open and player_near and Input.is_action_just_pressed("interactuar"):
		enter_door() # Entramos por la puerta y cambiamos de escena

func abrir_puerta():
	# Cambia el estado a abierta y actualiza la textura si no está ya abierta
	if not is_open:
		is_open = true
		sprite.texture = texture_open
		print("¡La puerta se ha abierto! Pulsa E para entrar.")

func enter_door():
	# Cambia a la siguiente escena si la ruta está configurada
	if next_scene_path != "":
		print("Viajando a: ", next_scene_path)
		
		# Usa el singleton TransitionScreen si existe para animar la transición
		if has_node("/root/TransitionScreen"):
			# Asegúrate de que tu singleton se llame TransitionScreen
			get_node("/root/TransitionScreen").cambiar_escena(next_scene_path)
		else:
			# Cambia directamente la escena si no hay pantalla de transición
			get_tree().change_scene_to_file(next_scene_path)
	else:
		# Muestra error si no se ha configurado la ruta
		print("¡ERROR! No has puesto la ruta en el script ni en el Inspector.")

func _on_zona_interaccion_body_entered(body):
	# Marca que el jugador está cerca cuando entra en la zona de interacción
	if body.is_in_group("jugador"):
		player_near = true

func _on_zona_interaccion_body_exited(body):
	# Marca que el jugador ya no está cerca cuando sale de la zona de interacción
	if body.is_in_group("jugador"):
		player_near = false
