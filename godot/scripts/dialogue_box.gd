extends CanvasLayer

signal dialogo_terminado

@onready var texto_label = $Control/Panel/Texto
@onready var nombre_label = $Control/Panel/Nombre
@onready var retrato_tex = $Control/Panel/Retrato # Tu nodo se llama Retrato
@onready var boton_skip = $Control/Panel/BotonSkip
@onready var contenedor = $Control

var dialogos = []            
var indice_actual = 0        
var esta_escribiendo = false
var tween_actual : Tween 

func _ready():
	contenedor.visible = false
	if not boton_skip.pressed.is_connected(_on_skip_pressed):
		boton_skip.pressed.connect(_on_skip_pressed)

func _input(event):
	if not contenedor.visible: return
	if event.is_action_pressed("interactuar") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		avanzar_o_completar()

func _on_skip_pressed():
	if esta_escribiendo:
		completar_texto_ahora()
	else:
		terminar_dialogo()

func iniciar_dialogo(lista_dialogos: Array):
	dialogos = lista_dialogos
	indice_actual = 0
	contenedor.visible = true
	mostrar_frase()

func mostrar_frase():
	if indice_actual >= dialogos.size():
		terminar_dialogo()
		return
	
	var info = dialogos[indice_actual]
	
	# 1. Nombre seguro (Usamos .get para evitar errores de clave)
	nombre_label.text = str(info.get("nombre", "???"))
	
	# 2. Retrato seguro (SOLUCIÓN AL ERROR DE CLAVE)
	var ruta_cara = info.get("cara", "")
	
	if ruta_cara != "" and FileAccess.file_exists(ruta_cara):
		retrato_tex.texture = load(ruta_cara)
		retrato_tex.visible = true
	else:
		# Si la ruta está mal escrita o no existe, ocultamos el cuadro
		retrato_tex.visible = false
		if ruta_cara != "":
			print("⚠️ ERROR: No existe el archivo en: ", ruta_cara)

	# 3. Texto seguro
	var texto_a_mostrar = str(info.get("texto", "..."))
	texto_label.text = texto_a_mostrar
	
	# Animación
	texto_label.visible_ratio = 0.0
	esta_escribiendo = true
	
	if tween_actual: tween_actual.kill()
	tween_actual = create_tween()
	
	var tiempo = texto_a_mostrar.length() * 0.05
	tween_actual.tween_property(texto_label, "visible_ratio", 1.0, tiempo)
	tween_actual.finished.connect(func(): esta_escribiendo = false)

func avanzar_o_completar():
	if esta_escribiendo:
		completar_texto_ahora()
	else:
		indice_actual += 1
		mostrar_frase()

func completar_texto_ahora():
	if tween_actual: tween_actual.kill()
	texto_label.visible_ratio = 1.0
	esta_escribiendo = false

func terminar_dialogo():
	contenedor.visible = false
	emit_signal("dialogo_terminado")
