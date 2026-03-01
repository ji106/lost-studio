extends Control

# Señal para avisar al menú de Settings
signal volumen_cambiado(nuevo_valor)

@onready var detector_clics = $DetectorClics
@onready var contenedor_cuadros = $ContenedorCuadros

var cuadraditos : Array = []
var valor_actual : float = 1.0 # Empieza al máximo (100%)

func _ready():
	# 1. Guardamos los cuadraditos en un Array
	for hijo in contenedor_cuadros.get_children():
		if hijo is TextureRect:
			cuadraditos.append(hijo)
	
	# 2. Conectamos el detector de clics
	detector_clics.gui_input.connect(_on_detector_gui_input)
	
	# 3. Pintamos el estado inicial
	actualizar_visuales(valor_actual)

# Esta función decide qué cuadraditos se ven y cuáles no
func actualizar_visuales(valor_0_a_1 : float):
	var total_cuadros = cuadraditos.size()
	
	# Calculamos cuántos cuadros hay que encender (Ej: 0.5 * 10 = 5 cuadros)
	var cuadros_a_encender = round(valor_0_a_1 * total_cuadros)
	
	for i in range(total_cuadros):
		# Si el índice es menor que el número a encender, se ve (Amarillo)
		# Si no, se oculta (Vacio)
		if i < cuadros_a_encender:
			cuadraditos[i].visible = true
		else:
			cuadraditos[i].visible = false

func _on_detector_gui_input(event):
	# Detectamos clic izquierdo (Pressed) o arrastre (Drag)
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
	   (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		
		# Calculamos en qué porcentaje de la barra has hecho clic
		var ancho_total = detector_clics.size.x
		var click_x = event.position.x
		
		# Evitamos errores de división por cero
		if ancho_total > 0:
			var nuevo_valor = click_x / ancho_total
			
			# Aseguramos que esté entre 0 y 1
			nuevo_valor = clamp(nuevo_valor, 0.0, 1.0)
			
			# Actualizamos los cuadraditos visualmente
			actualizar_visuales(nuevo_valor)
			
			# Avisamos a settings.gd para que cambie el volumen real
			valor_actual = nuevo_valor
			emit_signal("volumen_cambiado", valor_actual)

# Función para recibir el valor guardado al iniciar
func set_valor(valor_0_a_1):
	valor_actual = valor_0_a_1
	actualizar_visuales(valor_actual)
