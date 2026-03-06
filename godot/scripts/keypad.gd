extends Control

signal simon_completado # Señal que indica que el modo Simón fue completado

var codigo_secreto_normal : String = "20055" 	# Código normal para desbloquear
var codigo_actual : String = "" 				# Código que el jugador está ingresando

var modo_simon_activo : bool = false 			# Indica si el modo Simón está activo
var secuencia_simon : Array = [] 				# Secuencia generada para el modo Simón
var input_bloqueado : bool = false 				# Bloquea la entrada mientras se muestran animaciones

@onready var pantalla = $Label					# Label donde se muestra el código o mensajes
@onready var luz_verde = $IndicatorLightGreen 	# Luz verde para éxito
@onready var luz_roja = $IndicatorLightRed 		# Luz roja para error

# Diccionario con referencias a los botones numéricos para facilitar acceso
@onready var botones = {
	"0": $KeypadBtn0, "1": $KeypadBtn1, "2": $KeypadBtn2, "3": $KeypadBtn3,
	"4": $KeypadBtn4, "5": $KeypadBtn5, "6": $KeypadBtn6, "7": $KeypadBtn7,
	"8": $KeypadBtn8, "9": $KeypadBtn9
}

func _ready():
	# Al iniciar, apagamos luces y ponemos botones en color blanco
	luz_verde.visible = false
	luz_roja.visible = false
	for key in botones: 
		botones[key].modulate = Color.WHITE
	
	# Si el puzzle ya está completado según datos globales, mostramos estado abierto y bloqueamos entrada
	if Global.game_data["keypad_completado"] == true:
		pantalla.text = "OPEN"
		pantalla.modulate = Color.GREEN
		luz_verde.visible = true
		input_bloqueado = true 
	else:
		actualizar_pantalla() # Mostramos el código actual (vacío)

func iniciar_simon_dice():
	# Activa el modo Simón y resetea pantalla
	modo_simon_activo = true
	borrar_todo()
	pantalla.text = "READY"
	pantalla.modulate = Color.YELLOW

	# Espera 1.5 segundos antes de generar y mostrar la secuencia
	await get_tree().create_timer(1.5).timeout
	generar_secuencia_y_mostrar()

func generar_secuencia_y_mostrar():
	# Limpiamos secuencia anterior y pantalla
	secuencia_simon.clear()
	borrar_todo()

	# Generamos secuencia aleatoria de 5 números (0-9)
	for i in range(5): 
		secuencia_simon.append(str(randi() % 10))

	# Mostramos la secuencia con animación de luces
	reproducir_animacion_luces()

func reproducir_animacion_luces():
	# Bloqueamos la entrada mientras se reproduce la animación
	input_bloqueado = true 
	pantalla.text = "..." 
	await get_tree().create_timer(0.5).timeout

	# Para cada número en la secuencia, iluminamos el botón correspondiente y luego lo apagamos
	for numero in secuencia_simon:
		if botones.has(numero): 
			botones[numero].modulate = Color(2, 2, 0.5) # Color amarillo intenso
		await get_tree().create_timer(0.5).timeout
		if botones.has(numero): 
			botones[numero].modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout

	# Limpiamos texto y desbloqueamos entrada para que el jugador pueda responder
	pantalla.text = "" 
	input_bloqueado = false 

func anadir_numero(numero: String):
	# Si la entrada está bloqueada, no se acepta nada
	if input_bloqueado: return

	# Si el código actual tiene menos de 5 dígitos, añadimos el nuevo número
	if codigo_actual.length() < 5: 
		codigo_actual += numero
		actualizar_pantalla()
		animar_pulsacion(numero)

func animar_pulsacion(numero):
	# Animación rápida de cambio de color al pulsar un botón
	if botones.has(numero):
		botones[numero].modulate = Color.GREEN 
		await get_tree().create_timer(0.15).timeout
		botones[numero].modulate = Color.WHITE

func borrar_todo():
	# Si la entrada está bloqueada, no se puede borrar
	if input_bloqueado: return

	# Limpiamos el código actual y actualizamos pantalla
	codigo_actual = ""
	actualizar_pantalla()

func comprobar_codigo():
	# No hacer nada si entrada bloqueada
	if input_bloqueado: return

	# Si estamos en modo Simón, comparamos con la secuencia generada
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

func exito_simon():
	# Mostramos éxito, activamos luz verde y bloqueamos entrada
	pantalla.text = "OPEN"
	pantalla.modulate = Color.GREEN
	luz_verde.visible = true
	input_bloqueado = true
	
	# Guardamos estado global de puzzle completado
	Global.game_data["keypad_completado"] = true
	Global.guardar_partida()
	
	emit_signal("simon_completado") 

	# Esperamos 2 segundos antes de desactivar modo Simón
	await get_tree().create_timer(2.0).timeout
	modo_simon_activo = false 

func exito_normal():
	# Mostramos mensaje OK y luz verde temporalmente
	pantalla.text = "OK"
	pantalla.modulate = Color.CYAN
	luz_verde.visible = true
	
	await get_tree().create_timer(1.0).timeout
	luz_verde.visible = false
	iniciar_simon_dice() 

func error_generico():
	# Mostramos error, luz roja y bloqueamos entrada temporalmente
	pantalla.text = "ERROR"
	pantalla.modulate = Color.RED
	luz_roja.visible = true
	input_bloqueado = true 
	
	await get_tree().create_timer(1.0).timeout

	# Apagamos luz roja, restauramos pantalla y limpiamos código
	luz_roja.visible = false
	pantalla.modulate = Color.WHITE
	borrar_todo() 
	
	# Si estamos en modo Simón, repetimos la secuencia para el jugador
	if modo_simon_activo:
		print("Fallaste. Repitiendo secuencia...")
		reproducir_animacion_luces()
	else:
		input_bloqueado = false 

func actualizar_pantalla():
	# Actualiza el texto visible con el código actual ingresado
	pantalla.text = codigo_actual

# Funciones que manejan la pulsación de cada botón numérico
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
