extends Node2D

# --- REFERENCIAS A NODOS ---
@onready var keypad_layer = $CanvasLayer       # Capa del Keypad
@onready var keypad = $CanvasLayer/Keypad

# Nota: Ojo con las rutas, en tu imagen veo que Note2 está en CanvasLayer2
@onready var nota_layer = $CanvasLayer2         # Capa de la Nota (Opcional, para ocultar todo)
@onready var nota = $CanvasLayer2/Note2 

# NUEVO: Referencias al Móvil
@onready var mobile_layer = $CanvasLayer3       # Capa del Móvil
@onready var mobile = $CanvasLayer3/mobile      # La escena del móvil

# --- ESTADOS (Interruptores para saber dónde está el jugador) ---
var cerca_keypad : bool = false
var cerca_estanteria : bool = false 
var cerca_mesa : bool = false  # <--- NUEVO

func _ready():
	# Nos aseguramos de que todo empiece oculto al iniciar el nivel
	if keypad_layer: keypad_layer.visible = false
	if nota: nota.visible = false
	if mobile_layer: mobile_layer.visible = false # Ocultamos el móvil al inicio

func _input(event):
	# Detectamos si pulsa la E ("interactuar")
	if event.is_action_pressed("interactuar"):
		
		# CASO 1: Estamos frente al PANEL NUMÉRICO
		if cerca_keypad:
			abrir_cerrar_keypad()
			
		# CASO 2: Estamos frente a la ESTANTERÍA
		elif cerca_estanteria:
			abrir_cerrar_nota()
			
		# CASO 3: Estamos frente a la MESA (MÓVIL)
		elif cerca_mesa:
			abrir_cerrar_movil()

# --- LÓGICA DEL KEYPAD ---
func abrir_cerrar_keypad():
	# PROTECCIÓN: Si la nota o el móvil están abiertos, no hacemos nada
	if nota.visible or mobile_layer.visible: return

	keypad_layer.visible = !keypad_layer.visible
	gestionar_estado_jugador(keypad_layer.visible)
	
	if keypad_layer.visible: print("Abriendo Keypad...")
	else: print("Cerrando Keypad...")

# --- LÓGICA DE LA NOTA ---
func abrir_cerrar_nota():
	# PROTECCIÓN: Si el keypad o el móvil están abiertos, no hacemos nada
	if keypad_layer.visible or mobile_layer.visible: return

	nota.visible = !nota.visible
	gestionar_estado_jugador(nota.visible)

# --- LÓGICA DEL MÓVIL (NUEVO) ---
func abrir_cerrar_movil():
	# PROTECCIÓN: Si el keypad o la nota están abiertos, no hacemos nada
	if keypad_layer.visible or nota.visible: return
	
	mobile_layer.visible = !mobile_layer.visible
	gestionar_estado_jugador(mobile_layer.visible)
	
	if mobile_layer.visible: print("Abriendo Móvil...")
	else: print("Cerrando Móvil...")

# --- FUNCIÓN AUXILIAR COMÚN ---
func gestionar_estado_jugador(pausar: bool):
	var player = get_tree().get_first_node_in_group("jugador")
	
	if pausar:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
		if player: player.set_congelado(true) 
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 
		if player: player.set_congelado(false)

# ==========================================
#              SEÑALES (DETECTORES)
# ==========================================

# 1. ZONA KEYPAD
func _on_zona_keypad_body_entered(body):
	if body.is_in_group("jugador"): cerca_keypad = true

func _on_zona_keypad_body_exited(body):
	if body.is_in_group("jugador"):
		cerca_keypad = false
		if keypad_layer.visible: abrir_cerrar_keypad()

# 2. ZONA ESTANTERÍA
func _on_zona_estanteria_body_entered(body):
	if body.is_in_group("jugador"): cerca_estanteria = true

func _on_zona_estanteria_body_exited(body):
	if body.is_in_group("jugador"):
		cerca_estanteria = false
		if nota.visible: abrir_cerrar_nota()

# 3. ZONA MESA (NUEVO) - ¡Conecta estas señales en el editor!
func _on_zona_mesa_body_entered(body):
	if body.is_in_group("jugador"):
		cerca_mesa = true
		print("Cerca del Móvil")

func _on_zona_mesa_body_exited(body):
	if body.is_in_group("jugador"):
		cerca_mesa = false
		# Si te alejas de la mesa con el móvil abierto, se cierra solo
		if mobile_layer.visible:
			abrir_cerrar_movil()
