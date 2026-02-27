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

func _process(delta):
	# Si el jugador está en la puerta y pulsa la tecla E (interactuar)
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		print("Subiendo al tren... Cambiando de mapa!")
		# Cambiamos a la escena de salida
		get_tree().change_scene_to_file("res://tscn/exit.tscn")

# --- SEÑALES DEL AREA2D ---
func _on_zona_interaccion_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		body.cerca_del_tren = true

func _on_zona_interaccion_body_exited(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		body.cerca_del_tren = false
