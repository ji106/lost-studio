extends Control

# PIN que desbloquea el móvil
var pin_desbloqueo_movil = "52032"
# Frase correcta para resolver el enigma de pistas
var respuesta_enigma_frase = "The reality you see is only a reflection"
# Código que se muestra tras resolver el enigma
var codigo_secreto_final = "20055"

# Código que el jugador va ingresando en la pantalla de bloqueo
var codigo_actual_lockscreen = ""

# Referencias a las pantallas y elementos del móvil
@onready var lock_screen = $Pantallas/LockScreen
@onready var home_screen = $Pantallas/HomeScreen
@onready var music_app = $Pantallas/MusicApp
@onready var notes_app = $Pantallas/NotesApp
@onready var hint_app = $Pantallas/HintApp

@onready var lbl_pin_lockscreen = $Pantallas/LockScreen/LabelPIN 
@onready var music_player = $Pantallas/MusicApp/MusicPlayer
@onready var input_hint = $Pantallas/HintApp/LineEdit 
@onready var lbl_resultado_hint = $Pantallas/HintApp/ResultadoLabel

func _ready():
	# Inicializamos el texto del resultado del hint vacío
	lbl_resultado_hint.text = ""
	
	# Si el móvil ya está desbloqueado, mostramos la pantalla principal
	if Global.game_data["movil_desbloqueado"] == true:
		ir_a_pantalla(home_screen)
	else:
		# Si no, mostramos la pantalla de bloqueo
		ir_a_pantalla(lock_screen)
		
	# Si el enigma ya fue resuelto, mostramos el código secreto y bloqueamos la edición
	if Global.game_data["movil_pista_resuelta"] == true:
		lbl_resultado_hint.modulate = Color.RED
		lbl_resultado_hint.text = codigo_secreto_final
		input_hint.text = respuesta_enigma_frase 
		input_hint.editable = false 

	# Conectamos los botones numéricos en la pantalla de bloqueo
	for i in range(10):
		var nombre_boton = "MobileBtn" + str(i)
		if lock_screen.has_node(nombre_boton):
			var boton = lock_screen.get_node(nombre_boton)
			if not boton.pressed.is_connected(_on_btn_numero_lock_pressed):
				boton.pressed.connect(_on_btn_numero_lock_pressed.bind(str(i)))

# Cambia la pantalla visible, ocultando las demás
func ir_a_pantalla(pantalla_destino):
	lock_screen.visible = false
	home_screen.visible = false
	music_app.visible = false
	notes_app.visible = false
	hint_app.visible = false
	
	pantalla_destino.visible = true

	# Si no estamos en la app de música, detenemos la reproducción
	if pantalla_destino != music_app and music_player:
		music_player.stop()

# Botón home: solo funciona si el móvil está desbloqueado
func _on_home_button_pressed():
	if Global.game_data["movil_desbloqueado"] == true:
		ir_a_pantalla(home_screen)

# Al pulsar un número en la pantalla de bloqueo, se añade al código actual
func _on_btn_numero_lock_pressed(numero):
	# Si hubo error previo, volvemos el texto a blanco
	lbl_pin_lockscreen.modulate = Color.WHITE

	# Añadimos el número solo si no se excede la longitud máxima
	if codigo_actual_lockscreen.length() < 5:
		codigo_actual_lockscreen += numero
		lbl_pin_lockscreen.text = codigo_actual_lockscreen

# Al pulsar enter, comprobamos si el código es correcto
func _on_btn_enter_lock_pressed():
	if codigo_actual_lockscreen == pin_desbloqueo_movil:
		print("Móvil desbloqueado")
		
		# Guardamos que el móvil está desbloqueado
		Global.game_data["movil_desbloqueado"] = true
		Global.guardar_partida()

		# Reseteamos el código y mostramos la pantalla principal
		codigo_actual_lockscreen = ""
		lbl_pin_lockscreen.text = ""
		ir_a_pantalla(home_screen)
	else:
		# Mostramos error en rojo y texto "ERROR"
		lbl_pin_lockscreen.modulate = Color.RED
		lbl_pin_lockscreen.text = "ERROR"
		await get_tree().create_timer(1.0).timeout
		
		# Reseteamos el código y volvemos el texto a blanco
		codigo_actual_lockscreen = ""
		lbl_pin_lockscreen.text = ""
		lbl_pin_lockscreen.modulate = Color.WHITE # Vuelve a blanco

# Botón para borrar el código ingresado
func _on_btn_clear_lock_pressed():
	codigo_actual_lockscreen = ""
	lbl_pin_lockscreen.text = ""
	lbl_pin_lockscreen.modulate = Color.WHITE

# Botones para abrir las apps desde la pantalla principal
func _on_btn_app_music_pressed(): ir_a_pantalla(music_app)
func _on_btn_app_notes_pressed(): ir_a_pantalla(notes_app)
func _on_btn_app_hint_pressed(): ir_a_pantalla(hint_app)

# Control de reproducción en la app de música
func _on_btn_play_pause_toggled(button_pressed):
	if music_player:
		if button_pressed:
			if not music_player.playing:
				music_player.play()
			music_player.stream_paused = false
		else:
			music_player.stream_paused = true

# Al enviar respuesta en la app de pistas, comprobamos si es correcta
func _on_btn_submit_hint_pressed():
	# Si ya se resolvió el enigma, no hacemos nada
	if Global.game_data["movil_pista_resuelta"]: return

	var texto_escrito = input_hint.text.strip_edges().to_lower()
	var respuesta_correcta = respuesta_enigma_frase.to_lower()

	# Comprobamos la respuesta
	if texto_escrito == respuesta_correcta:
		lbl_resultado_hint.modulate = Color.RED
		lbl_resultado_hint.text = codigo_secreto_final
		
		# Guardamos que el enigma fue resuelto
		Global.game_data["movil_pista_resuelta"] = true
		Global.guardar_partida()
		
		print("Puzzle del móvil resuelto y guardado")
	else:
		# Mostramos error en blanco y texto "ERROR"
		lbl_resultado_hint.modulate = Color.WHITE
		lbl_resultado_hint.text = "ERROR"
