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

func _process(_delta):
	# Si el jugador está cerca Y pulsa la tecla de interacción
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		print("Subiendo al tren... Iniciando transición!")
		
		# --- CAMBIO: Usamos el Autoload TransitionScreen ---
		if has_node("/root/TransitionScreen"):
			TransitionScreen.cambiar_escena("res://tscn/exit.tscn")
		else:
			# Fallback por seguridad si el Autoload no está activo
			get_tree().change_scene_to_file("res://tscn/exit.tscn")

# --- SEÑALES DEL AREA2D ---
func _on_zona_interaccion_body_entered(body):
	# Verificamos si es el jugador por nombre o grupo
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador_cerca = true

func _on_zona_interaccion_body_exited(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador_cerca = false
