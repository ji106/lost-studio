extends Control

# --- CONFIGURACIÓN ---
var pin_desbloqueo_movil = "52032"
var respuesta_enigma_frase = "The reality you see is only a reflection"
var codigo_secreto_final = "20055"

# --- VARIABLES DE ESTADO LOCAL ---
var codigo_actual_lockscreen = ""

# --- REFERENCIAS ---
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
	# 1. Configuración inicial
	lbl_resultado_hint.text = ""
	
	# --- CARGAR ESTADO GUARDADO ---
	if Global.game_data["movil_desbloqueado"] == true:
		ir_a_pantalla(home_screen)
	else:
		ir_a_pantalla(lock_screen)
		
	# B. Verificar si ya se resolvió el enigma de texto
	if Global.game_data["movil_pista_resuelta"] == true:
		lbl_resultado_hint.modulate = Color.RED
		lbl_resultado_hint.text = codigo_secreto_final
		input_hint.text = respuesta_enigma_frase 
		input_hint.editable = false 

	# 2. CONEXIÓN AUTOMÁTICA DE LOS NÚMEROS
	for i in range(10):
		var nombre_boton = "MobileBtn" + str(i)
		if lock_screen.has_node(nombre_boton):
			var boton = lock_screen.get_node(nombre_boton)
			if not boton.pressed.is_connected(_on_btn_numero_lock_pressed):
				boton.pressed.connect(_on_btn_numero_lock_pressed.bind(str(i)))

# --- GESTOR DE PANTALLAS ---
func ir_a_pantalla(pantalla_destino):
	lock_screen.visible = false
	home_screen.visible = false
	music_app.visible = false
	notes_app.visible = false
	hint_app.visible = false
	
	pantalla_destino.visible = true
	
	if pantalla_destino != music_app and music_player:
		music_player.stop()

# --- BOTÓN HOME ---
func _on_home_button_pressed():
	# Si estamos bloqueados, no hace nada. Si estamos desbloqueados, va al Home.
	if Global.game_data["movil_desbloqueado"] == true:
		ir_a_pantalla(home_screen)

# ==========================================
# LÓGICA 1: PANTALLA DE BLOQUEO
# ==========================================

func _on_btn_numero_lock_pressed(numero):
	# Si venimos de un error, nos aseguramos de que el texto vuelva a ser blanco
	lbl_pin_lockscreen.modulate = Color.WHITE
	
	if codigo_actual_lockscreen.length() < 5:
		codigo_actual_lockscreen += numero
		lbl_pin_lockscreen.text = codigo_actual_lockscreen

func _on_btn_enter_lock_pressed():
	if codigo_actual_lockscreen == pin_desbloqueo_movil:
		print("Móvil desbloqueado")
		
		# --- GUARDAR ESTADO ---
		Global.game_data["movil_desbloqueado"] = true
		Global.guardar_partida()
		
		codigo_actual_lockscreen = ""
		lbl_pin_lockscreen.text = ""
		ir_a_pantalla(home_screen)
	else:
		# --- ERROR EN ROJO ---
		lbl_pin_lockscreen.modulate = Color.RED
		lbl_pin_lockscreen.text = "ERROR"
		await get_tree().create_timer(1.0).timeout
		
		# --- RESETEAR ---
		codigo_actual_lockscreen = ""
		lbl_pin_lockscreen.text = ""
		lbl_pin_lockscreen.modulate = Color.WHITE # Vuelve a blanco

func _on_btn_clear_lock_pressed():
	codigo_actual_lockscreen = ""
	lbl_pin_lockscreen.text = ""
	lbl_pin_lockscreen.modulate = Color.WHITE

# ==========================================
# LÓGICA 2: HOME SCREEN
# ==========================================
func _on_btn_app_music_pressed(): ir_a_pantalla(music_app)
func _on_btn_app_notes_pressed(): ir_a_pantalla(notes_app)
func _on_btn_app_hint_pressed(): ir_a_pantalla(hint_app)

# ==========================================
# LÓGICA 3: MÚSICA
# ==========================================
func _on_btn_play_pause_toggled(button_pressed):
	if music_player:
		if button_pressed:
			if not music_player.playing:
				music_player.play()
			music_player.stream_paused = false
		else:
			music_player.stream_paused = true

# ==========================================
# LÓGICA 4: HINT APP
# ==========================================
func _on_btn_submit_hint_pressed():
	# Si ya estaba resuelto, no hacemos nada
	if Global.game_data["movil_pista_resuelta"]: return

	var texto_escrito = input_hint.text.strip_edges().to_lower()
	var respuesta_correcta = respuesta_enigma_frase.to_lower()
	
	if texto_escrito == respuesta_correcta:
		lbl_resultado_hint.modulate = Color.RED
		lbl_resultado_hint.text = codigo_secreto_final
		
		# --- GUARDAR ESTADO ---
		Global.game_data["movil_pista_resuelta"] = true
		Global.guardar_partida()
		
		print("Puzzle del móvil resuelto y guardado")
	else:
		lbl_resultado_hint.modulate = Color.WHITE
		lbl_resultado_hint.text = "ERROR"
