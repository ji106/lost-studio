extends Sprite2D

var jugador_cerca = false

func _ready():
	# --- Animación de llegada del tren ---
	var destino_final = position
	position.x -= 800 
	var tween = create_tween()
	tween.tween_property(self, "position", destino_final, 3.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

# CAMBIO 1: Ponemos un guion bajo "_delta" para decirle a Godot que sabemos que no se usa
func _process(_delta):
	# Si el jugador está cerca Y pulsa la tecla
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		print("Subiendo al tren... Cambiando de mapa!")
		get_tree().change_scene_to_file("res://tscn/exit.tscn")

# --- SEÑALES DEL AREA2D ---
func _on_zona_interaccion_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		# CAMBIO 2: Actualizamos la variable DE ESTE SCRIPT, no la del cuerpo
		jugador_cerca = true

func _on_zona_interaccion_body_exited(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		# CAMBIO 2: Actualizamos la variable DE ESTE SCRIPT
		jugador_cerca = false
