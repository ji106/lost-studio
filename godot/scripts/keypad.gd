extends Control

# --- SEÑALES ---
signal codigo_correcto      # Para el código 20055
signal simon_completado     # Para cuando gane el Simón Dice

# --- CONFIGURACIÓN ---
var codigo_secreto_normal : String = "20055" # <--- CAMBIADO: Ahora son 5 dígitos
var codigo_actual : String = ""

# --- VARIABLES SIMÓN DICE ---
var modo_simon_activo : bool = false
var secuencia_simon : Array = []
var input_bloqueado : bool = false

# --- REFERENCIAS ---
@onready var pantalla = $Label
@onready var luz_verde = $IndicatorLightGreen
@onready var luz_roja = $IndicatorLightRed

# --- DICCIONARIO DE BOTONES ---
@onready var botones = {
	"0": $KeypadBtn0, 
	"1": $KeypadBtn1,
	"2": $KeypadBtn2,
	"3": $KeypadBtn3,
	"4": $KeypadBtn4,
	"5": $KeypadBtn5,
	"6": $KeypadBtn6,
	"7": $KeypadBtn7,
	"8": $KeypadBtn8,
	"9": $KeypadBtn9
}

func _ready():
	luz_verde.visible = false
	luz_roja.visible = false
	
	# Aseguramos que todos los botones empiecen con su color normal (Blanco/Sin tinte)
	for key in botones:
		botones[key].modulate = Color.WHITE
		
	actualizar_pantalla()

# --- FUNCIONES PÚBLICAS ---

func iniciar_simon_dice():
	print("🎲 Iniciando Simón Dice (5 dígitos)...")
	modo_simon_activo = true
	borrar_todo()
	pantalla.text = "READY"
	pantalla.modulate = Color.YELLOW
	
	await get_tree().create_timer(1.5).timeout
	
	generar_secuencia_y_mostrar()

# --- LÓGICA DEL SIMÓN ---

func generar_secuencia_y_mostrar():
	secuencia_simon.clear()
	borrar_todo()
	
	# Generamos 5 números aleatorios (antes eran 4)
	for i in range(5): # <--- CAMBIADO: Generamos 5 números
		secuencia_simon.append(str(randi() % 10))
	
	print("Secuencia generada (secreto): ", secuencia_simon)
	reproducir_animacion_luces()

func reproducir_animacion_luces():
	input_bloqueado = true 
	pantalla.text = "..." 
	
	await get_tree().create_timer(0.5).timeout
	
	for numero in secuencia_simon:
		# 1. ILUMINAR: Cambiamos el color del botón a AMARILLO BRILLANTE
		if botones.has(numero):
			botones[numero].modulate = Color(2, 2, 0.5) 
		
		# 2. Esperamos (tiempo encendido)
		await get_tree().create_timer(0.5).timeout
		
		# 3. APAGAR: Volvemos al color BLANCO original
		if botones.has(numero):
			botones[numero].modulate = Color.WHITE
			
		# 4. Pequeña pausa entre números
		await get_tree().create_timer(0.1).timeout
	
	pantalla.text = "" 
	input_bloqueado = false 
	print("Turno del jugador")

# --- LÓGICA INTERNA ---

func anadir_numero(numero: String):
	if input_bloqueado: return
	
	# Limitamos a 5 dígitos (antes eran 4)
	if codigo_actual.length() < 5: # <--- CAMBIADO: Límite subido a 5
		codigo_actual += numero
		actualizar_pantalla()
		
		# Efecto visual al pulsar nosotros
		animar_pulsacion(numero)

func animar_pulsacion(numero):
	if botones.has(numero):
		# Al pulsar nosotros, se pone un poco VERDE para diferenciar
		botones[numero].modulate = Color.GREEN 
		await get_tree().create_timer(0.15).timeout
		botones[numero].modulate = Color.WHITE

func borrar_todo():
	if input_bloqueado: return
	codigo_actual = ""
	actualizar_pantalla()

func comprobar_codigo():
	if input_bloqueado: return
	
	if modo_simon_activo:
		var secuencia_string = "".join(secuencia_simon)
		if codigo_actual == secuencia_string:
			exito_simon()
		else:
			error_generico()
	else:
		if codigo_actual == codigo_secreto_normal:
			exito_normal()
		else:
			error_generico()

# --- RESULTADOS ---

func exito_simon():
	print("¡Simón Completado!")
	pantalla.text = "OK"
	pantalla.modulate = Color.GREEN
	luz_verde.visible = true
	input_bloqueado = true
	
	await get_tree().create_timer(1.0).timeout
	
	emit_signal("simon_completado")
	luz_verde.visible = false
	modo_simon_activo = false 

func exito_normal():
	print("¡Código 20055 Correcto!")
	pantalla.text = "OK"
	pantalla.modulate = Color.GREEN
	luz_verde.visible = true
	
	emit_signal("codigo_correcto")
	
	# TRUCO: Iniciar el Simón justo después de acertar el código normal
	await get_tree().create_timer(1.0).timeout
	luz_verde.visible = false
	iniciar_simon_dice() 

func error_generico():
	print("ERROR: Código incorrecto")
	pantalla.text = "NO"
	pantalla.modulate = Color.RED
	luz_roja.visible = true
	input_bloqueado = true 
	
	await get_tree().create_timer(1.0).timeout
	
	luz_roja.visible = false
	pantalla.modulate = Color.WHITE
	
	# Primero desbloqueamos y luego borramos para evitar el bug
	input_bloqueado = false 
	borrar_todo() 

func actualizar_pantalla():
	pantalla.text = codigo_actual

# --- SEÑALES DE LOS BOTONES ---
func _on_keypad_btn_0_pressed(): anadir_numero("0")
func _on_keypad_btn_1_pressed(): anadir_numero("1")
func _on_keypad_btn_2_pressed(): anadir_numero("2")
func _on_keypad_btn_3_pressed(): anadir_numero("3")
func _on_keypad_btn_4_pressed(): anadir_numero("4")
func _on_keypad_btn_5_pressed(): anadir_numero("5")
func _on_keypad_btn_6_pressed(): anadir_numero("6")
func _on_keypad_btn_7_pressed(): anadir_numero("7")
func _on_keypad_btn_8_pressed(): anadir_numero("8")
func _on_keypad_btn_9_pressed(): anadir_numero("9")
func _on_keypad_btn_clear_pressed(): borrar_todo()
func _on_keypad_btn_enter_pressed(): comprobar_codigo()
