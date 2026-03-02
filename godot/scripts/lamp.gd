extends StaticBody2D

# Señal que avisa al Nivel 02 cada vez que una lámpara cambia
signal lamp_changed

# --- CONFIGURACIÓN VISUAL ---
@export var texture_off: Texture2D  # Arrastra imagen gris
@export var texture_on: Texture2D   # Arrastra imagen amarilla
@export var is_on: bool = false      # Estado inicial

# --- VECINOS ---
# Arrastra aquí las otras lámparas que se deben encender/apagar junto a esta
@export var neighbors: Array[Node2D] 

# Asegúrate de que tu nodo hijo se llame "BombillaSprite"
@onready var sprite = $BombillaSprite
var player_near: bool = false

func _ready():
	add_to_group("lamparas") # Importante para que el nivel las encuentre
	
	# --- CARGAR ESTADO GUARDADO ---
	# Comprobamos si el nombre de este nodo está en la lista de luces encendidas
	if name in Global.game_data["luces_encendidas_level2"]:
		is_on = true
	
	update_visuals()

# --- DETECCIÓN DE INTERACCIÓN ---
func _process(_delta):
	# Detectar la tecla E cuando estás cerca
	if player_near and Input.is_action_just_pressed("interactuar"):
		activate_mechanic()

func activate_mechanic():
	# 1. Cambia esta lámpara
	toggle()
	
	# 2. Cambia a sus vecinos conectados
	for n in neighbors:
		if n != null and n.has_method("toggle"):
			n.toggle()
	
	# 3. Avisa al nivel para comprobar victoria
	emit_signal("lamp_changed")

# Función que cambia el estado y guarda el progreso
func toggle():
	is_on = !is_on
	update_visuals()
	
	# --- GUARDAR ESTADO ---
	# Registramos si esta luz específica está encendida o apagada en el Global
	Global.registrar_cambio_luz(name, is_on)
	
	# Reproducir sonido si existe el nodo
	if has_node("SonidoClick"):
		$SonidoClick.play()

func update_visuals():
	if is_on and texture_on:
		sprite.texture = texture_on
	elif texture_off:
		sprite.texture = texture_off

# --- SEÑALES DE AREA2D ---
func _on_area_2d_body_entered(body):
	if body.is_in_group("jugador"):
		player_near = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("jugador"):
		player_near = false
