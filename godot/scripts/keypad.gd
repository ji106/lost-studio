extends Control

# --- SEÑALES ---
signal simon_completado 

# --- CONFIGURACIÓN ---
var codigo_secreto_normal : String = "20055" 
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
	"0": $KeypadBtn0, "1": $KeypadBtn1, "2": $KeypadBtn2, "3": $KeypadBtn3,
	"4": $KeypadBtn4, "5": $KeypadBtn5, "6": $KeypadBtn6, "7": $KeypadBtn7,
	"8": $KeypadBtn8, "9": $KeypadBtn9
}

func _ready():
	luz_verde.visible = false
	luz_roja.visible = false
	for key in botones: 
		botones[key].modulate = Color.WHITE
	
	# --- CARGAR ESTADO GUARDADO ---
	if Global.game_data["keypad_completado"] == true:
		pantalla.text = "OPEN"
		pantalla.modulate = Color.GREEN
		luz_verde.visible = true
		input_bloqueado = true 
	else:
		actualizar_pantalla()

# --- FUNCIONES PÚBLICAS ---
func iniciar_simon_dice():
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
	for i in range(5): 
		secuencia_simon.append(str(randi() % 10))
	
	reproducir_animacion_luces()

func reproducir_animacion_luces():
	input_bloqueado = true 
	pantalla.text = "..." 
	await get_tree().create_timer(0.5).timeout
	
	for numero in secuencia_simon:
		if botones.has(numero): 
			botones[numero].modulate = Color(2, 2, 0.5) 
		await get_tree().create_timer(0.5).timeout
		if botones.has(numero): 
			botones[numero].modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
	
	pantalla.text = "" 
	input_bloqueado = false 

# --- LÓGICA INTERNA ---
func anadir_numero(numero: String):
	if input_bloqueado: return
	if codigo_actual.length() < 5: 
		codigo_actual += numero
		actualizar_pantalla()
		animar_pulsacion(numero)

func animar_pulsacion(numero):
	if botones.has(numero):
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
	pantalla.text = "OPEN"
	pantalla.modulate = Color.GREEN
	luz_verde.visible = true
	input_bloqueado = true
	
	# --- GUARDAR ESTADO ---
	Global.game_data["keypad_completado"] = true
	Global.guardar_partida()
	
	emit_signal("simon_completado") 
	
	await get_tree().create_timer(2.0).timeout
	# luz_verde.visible = false
	modo_simon_activo = false 

func exito_normal():
	pantalla.text = "OK"
	pantalla.modulate = Color.CYAN
	luz_verde.visible = true
	
	await get_tree().create_timer(1.0).timeout
	luz_verde.visible = false
	iniciar_simon_dice() 

func error_generico():
	pantalla.text = "ERROR"
	pantalla.modulate = Color.RED
	luz_roja.visible = true
	input_bloqueado = true 
	
	await get_tree().create_timer(1.0).timeout
	
	luz_roja.visible = false
	pantalla.modulate = Color.WHITE
	borrar_todo() 
	
	# --- MODIFICACIÓN: REPETIR SECUENCIA SI ES SIMÓN ---
	if modo_simon_activo:
		print("Fallaste. Repitiendo secuencia...")
		reproducir_animacion_luces() # <--- Se vuelve a mostrar la misma secuencia
	else:
		input_bloqueado = false 

func actualizar_pantalla():
	pantalla.text = codigo_actual

# --- SEÑALES BOTONES ---
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
