extends CanvasLayer

# Señal que avisa cuando el diálogo ha terminado
signal dialogo_terminado

# Referencias a nodos importantes dentro del panel de diálogo
@onready var texto_label = $Control/Panel/Texto 	# Donde se muestra el texto del diálogo
@onready var nombre_label = $Control/Panel/Nombre 	# Donde se muestra el nombre del hablante
@onready var retrato_tex = $Control/Panel/Retrato 	# Imagen del personaje que habla
@onready var boton_skip = $Control/Panel/BotonSkip 	# Botón para saltar o avanzar el diálogo
@onready var contenedor = $Control 					# Contenedor principal del diálogo (todo el panel)

# Variables para controlar el flujo del diálogo
var dialogos = [] 				# Lista con todas las frases del diálogo
var indice_actual = 0 			# Índice que indica qué frase se está mostrando ahora
var esta_escribiendo = false 	# Controla si el texto se está escribiendo animado
var tween_actual : Tween		# Tween para animar la aparición del texto

func _ready():
	# Al iniciar, ocultamos el panel de diálogo para que no se vea
	contenedor.visible = false

	# Detectamos si el jugador pulsa la tecla de "interactuar" o hace clic izquierdo
	if not boton_skip.pressed.is_connected(_on_skip_pressed):
		boton_skip.pressed.connect(_on_skip_pressed)

func _input(event):
	# Si el diálogo no está visible, no hacemos nada
	if not contenedor.visible: return

	# Detectamos si el jugador pulsa la tecla de "interactuar" o hace clic izquierdo
	if event.is_action_pressed("interactuar") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		avanzar_o_completar()  # Avanzamos el diálogo o completamos el texto si está escribiéndose

func _on_skip_pressed():
	# Si el texto está escribiéndose, completamos la frase al instante
	if esta_escribiendo:
		completar_texto_ahora()
	else:
		# Si no, terminamos el diálogo
		terminar_dialogo()

# Inicia el diálogo con una lista de frases (cada frase es un diccionario con nombre, cara y texto)
func iniciar_dialogo(lista_dialogos: Array):
	dialogos = lista_dialogos 	# Guardamos la lista que nos pasan
	indice_actual = 0 			# Empezamos desde la primera frase
	contenedor.visible = true 	# Mostramos el panel de diálogo
	mostrar_frase() 			# Mostramos la primera frase

# Muestra la frase actual en pantalla (nombre, retrato y texto)
func mostrar_frase():
	# Si ya no quedan frases, terminamos el diálogo
	if indice_actual >= dialogos.size():
		terminar_dialogo()
		return
	
	var info = dialogos[indice_actual] # Obtenemos el diccionario con los datos de la frase
	
	# 1. Ponemos el nombre (usando .get para evitar errores si falta la clave)
	nombre_label.text = str(info.get("nombre", "???"))
	
	# 2. Cargamos el retrato si la ruta existe, si no, ocultamos la imagen
	var ruta_cara = info.get("cara", "")
	if ruta_cara != "" and FileAccess.file_exists(ruta_cara):
		retrato_tex.texture = load(ruta_cara)
		retrato_tex.visible = true
	else:
		# Si la ruta está mal escrita o no existe, ocultamos el cuadro
		retrato_tex.visible = false
		if ruta_cara != "":
			print("⚠️ ERROR: No existe el archivo en: ", ruta_cara)

	# 3. Texto del diálogo (seguro, con valor por defecto)
	var texto_a_mostrar = str(info.get("texto", "..."))
	texto_label.text = texto_a_mostrar
	
	# Preparamos la animación para que el texto aparezca poco a poco
	texto_label.visible_ratio = 0.0 # Empezamos con el texto invisible
	esta_escribiendo = true 		# Indicamos que estamos escribiendo

	# Si hay una animación previa, la cancelamos para evitar conflictos
	if tween_actual: tween_actual.kill()
	tween_actual = create_tween()

	# Calculamos el tiempo de animación según la longitud del texto (0.05s por carácter)
	var tiempo = texto_a_mostrar.length() * 0.05

	# Animamos la propiedad visible_ratio de 0 a 1 para que el texto aparezca gradualmente
	tween_actual.tween_property(texto_label, "visible_ratio", 1.0, tiempo)

	# Cuando termine la animación, indicamos que ya no estamos escribiendo
	tween_actual.finished.connect(func(): esta_escribiendo = false)

# Función que avanza a la siguiente frase o completa el texto actual si está escribiéndose
func avanzar_o_completar():
	if esta_escribiendo:
		completar_texto_ahora() # Completar texto instantáneamente
	else:
		indice_actual += 1 		# Pasar a la siguiente frase
		mostrar_frase() 		# Mostrarla

# Completa el texto actual instantáneamente (sin animación)
func completar_texto_ahora():
	if tween_actual: tween_actual.kill() 	# Cancelamos la animación en curso
	texto_label.visible_ratio = 1.0 		# Mostramos todo el texto
	esta_escribiendo = false 				# Indicamos que ya no se está escribiendo

func terminar_dialogo():
	contenedor.visible = false
	emit_signal("dialogo_terminado")
