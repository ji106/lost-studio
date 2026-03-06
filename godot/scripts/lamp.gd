extends StaticBody2D

# Señal que avisa al nivel cuando una lámpara cambia de estado
signal lamp_changed

# Texturas para mostrar la lámpara apagada y encendida
@export var texture_off: Texture2D
@export var texture_on: Texture2D
@export var is_on: bool = false # Estado inicial de la lámpara

# Lista de lámparas vecinas que se activan o desactivan junto a esta
# Arrastra aquí las otras lámparas que se deben encender/apagar junto a esta
@export var neighbors: Array[Node2D] 

# Referencia al sprite de la bombilla para cambiar la textura
@onready var sprite = $BombillaSprite
var player_near: bool = false # Indica si el jugador está cerca para permitir interacción

func _ready():
	# Añadimos esta lámpara al grupo "lamparas" para que el nivel pueda gestionarlas
	add_to_group("lamparas") # Importante para que el nivel las encuentre
	
	# Cargamos el estado guardado: si esta lámpara estaba encendida, la activamos
	if name in Global.game_data["luces_encendidas_level2"]:
		is_on = true
	
	update_visuals() # Actualizamos la apariencia según el estado

func _process(_delta):
	# Si el jugador está cerca y pulsa la tecla de interacción, activamos la lámpara
	if player_near and Input.is_action_just_pressed("interactuar"):
		activate_mechanic()

func activate_mechanic():
	# Cambiamos el estado de esta lámpara
	toggle()
	
	# Cambiamos el estado de todas las lámparas vecinas conectadas
	for n in neighbors:
		if n != null and n.has_method("toggle"):
			n.toggle()
	
	# Avisamos al nivel que una lámpara ha cambiado para comprobar condiciones
	emit_signal("lamp_changed")

func toggle():
	# Cambiamos el estado de encendido/apagado
	is_on = !is_on
	update_visuals()
	
	# Guardamos el cambio en el estado global para persistencia
	Global.registrar_cambio_luz(name, is_on)
	
	# Reproducimos sonido si el nodo existe
	if has_node("SonidoClick"):
		$SonidoClick.play()

func update_visuals():
	# Actualizamos la textura según el estado de la lámpara
	if is_on and texture_on:
		sprite.texture = texture_on
	elif texture_off:
		sprite.texture = texture_off

func _on_area_2d_body_entered(body):
	# Detectamos si el jugador entra en el área para permitir interacción
	if body.is_in_group("jugador"):
		player_near = true

func _on_area_2d_body_exited(body):
	# Detectamos si el jugador sale del área para desactivar interacción
	if body.is_in_group("jugador"):
		player_near = false
