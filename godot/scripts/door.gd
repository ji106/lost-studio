extends StaticBody2D

# --- CONFIGURACIÓN ---
@export var texture_closed: Texture2D # Arrastra aquí la imagen CERRADA
@export var texture_open: Texture2D   # Arrastra aquí la imagen ABIERTA
@export var next_scene_path: String = "" # Escribe aquí la ruta de la siguiente escena (ej: "res://tscn/level_03.tscn")

var is_open: bool = false
var player_near: bool = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D # La colisión física que bloquea el paso

func _ready():
	# Nos aseguramos de empezar cerrados
	sprite.texture = texture_closed

func _process(delta):
	# Solo si la puerta está abierta, el jugador está cerca y pulsa E
	if is_open and player_near and Input.is_action_just_pressed("interactuar"):
		enter_door()

# Esta función la llamará el Nivel cuando completes el puzzle
func abrir_puerta():
	if not is_open:
		is_open = true
		sprite.texture = texture_open
		print("¡La puerta se ha abierto!")
		
		# Opcional: Desactivar la colisión física para que parezca que puedes "entrar"
		# collision.set_deferred("disabled", true) 

func enter_door():
	if next_scene_path != "":
		# Usamos tu sistema de transición si lo tienes, o el cambio normal
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena(next_scene_path)
		else:
			get_tree().change_scene_to_file(next_scene_path)
	else:
		print("¡Falta definir la ruta de la siguiente escena en el Inspector!")

# --- SEÑALES DEL AREA2D ---
# Conéctalas desde el nodo ZonaInteraccion
func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("jugador"):
		player_near = true

func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("jugador"):
		player_near = false
