extends Control

# Señal que se emite cuando cambia el volumen, pasa el nuevo valor (0 a 1)
signal volumen_cambiado(nuevo_valor)

# Referencia al nodo que detecta clics y movimientos del ratón
@onready var detector_clics = $DetectorClics
# Contenedor que agrupa los cuadros visuales del volumen
@onready var contenedor_cuadros = $ContenedorCuadros

var cuadraditos : Array = [] # Lista para guardar los cuadros que representan niveles de volumen
var valor_actual : float = 1.0 # Volumen actual, 1.0 = 100%

func _ready():
	# Recorremos los hijos del contenedor y guardamos los que son TextureRect (los cuadros)
	for hijo in contenedor_cuadros.get_children():
		if hijo is TextureRect:
			cuadraditos.append(hijo)
	
	# Conectamos la función que maneja la entrada de ratón en detector_clics
	detector_clics.gui_input.connect(_on_detector_gui_input)

# Actualiza la visibilidad de los cuadros según el valor de volumen (0 a 1)
func actualizar_visuales(valor_0_a_1 : float):
	var total_cuadros = cuadraditos.size()
	# Calculamos cuántos cuadros deben estar visibles según el volumen
	var cuadros_a_encender = round(valor_0_a_1 * total_cuadros)
	
	for i in range(total_cuadros):
		if i < cuadros_a_encender:
			cuadraditos[i].visible = true # Encendemos el cuadro
		else:
			cuadraditos[i].visible = false # Apagamos el cuadro

# Detecta clics y arrastres para cambiar el volumen
func _on_detector_gui_input(event):
	# Detectamos si se hizo clic izquierdo o se está arrastrando con el botón izquierdo
	var click_izquierdo = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var arrastrando = event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if click_izquierdo or arrastrando:
		var ancho_total = detector_clics.size.x  # Ancho del área clicable
		var click_x = event.position.x # Posición horizontal del clic o arrastre
		
		if ancho_total > 0:
			# Calculamos el nuevo valor de volumen proporcional a la posición del ratón
			var nuevo_valor = click_x / ancho_total
			
			# Limitamos el valor para que esté entre 0 y 1
			nuevo_valor = clamp(nuevo_valor, 0.0, 1.0)

			# Solo actualizamos si el valor cambió para evitar emisiones innecesarias
			if valor_actual != nuevo_valor:
				valor_actual = nuevo_valor
				actualizar_visuales(valor_actual) # Actualizamos la visualización
				emit_signal("volumen_cambiado", valor_actual) # Avisamos a otros nodos

# Permite establecer el valor del volumen desde fuera (por ejemplo, al cargar configuración)
func set_valor(valor_0_a_1):
	valor_actual = clamp(valor_0_a_1, 0.0, 1.0) # Limitamos el valor
	actualizar_visuales(valor_actual) # Actualizamos visualmente
