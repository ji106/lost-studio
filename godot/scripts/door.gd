extends StaticBody2D

# --- CONFIGURACIÓN ---
@export var texture_closed: Texture2D 
@export var texture_open: Texture2D   

# CAMBIO 1: He puesto tu ruta aquí directamente para que funcione automático
@export var next_scene_path: String = "res://tscn/final_screen.tscn" 

var is_open: bool = false
var player_near: bool = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D 

func _ready():
	sprite.texture = texture_closed

# CAMBIO 2: Puse "_delta" para quitar el aviso amarillo
func _process(_delta):
	# Si la puerta está abierta, el jugador cerca y pulsa E
	if is_open and player_near and Input.is_action_just_pressed("interactuar"):
		enter_door()

func abrir_puerta():
	if not is_open:
		is_open = true
		sprite.texture = texture_open
		print("¡La puerta se ha abierto! Pulsa E para entrar.")

func enter_door():
	if next_scene_path != "":
		print("Viajando a: ", next_scene_path)
		
		# Intenta usar tu pantalla de carga, si no, usa el cambio normal
		if has_node("/root/TransitionScreen"):
			# Asegúrate de que tu singleton se llame TransitionScreen
			get_node("/root/TransitionScreen").cambiar_escena(next_scene_path)
		else:
			get_tree().change_scene_to_file(next_scene_path)
	else:
		print("¡ERROR! No has puesto la ruta en el script ni en el Inspector.")

# --- SEÑALES ---
func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("jugador"):
		player_near = true

func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("jugador"):
		player_near = false
