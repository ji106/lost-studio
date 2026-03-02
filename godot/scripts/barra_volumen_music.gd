extends Control

# Señal específica para la música
signal volumen_cambiado(nuevo_valor)

@onready var detector_clics = $DetectorClics
@onready var contenedor_cuadros = $ContenedorCuadros

var cuadraditos : Array = []
var valor_actual : float = 1.0

func _ready():
	for hijo in contenedor_cuadros.get_children():
		if hijo is TextureRect:
			cuadraditos.append(hijo)
	
	detector_clics.gui_input.connect(_on_detector_gui_input)

func actualizar_visuales(valor_0_a_1 : float):
	var total_cuadros = cuadraditos.size()
	var cuadros_a_encender = round(valor_0_a_1 * total_cuadros)
	
	for i in range(total_cuadros):
		if i < cuadros_a_encender:
			cuadraditos[i].visible = true
		else:
			cuadraditos[i].visible = false

func _on_detector_gui_input(event):
	var click_izquierdo = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var arrastrando = event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if click_izquierdo or arrastrando:
		var ancho_total = detector_clics.size.x
		var click_x = event.position.x
		
		if ancho_total > 0:
			var nuevo_valor = click_x / ancho_total
			nuevo_valor = clamp(nuevo_valor, 0.0, 1.0)
			
			if valor_actual != nuevo_valor:
				valor_actual = nuevo_valor
				actualizar_visuales(valor_actual)
				emit_signal("volumen_cambiado", valor_actual)

func set_valor(valor_0_a_1):
	valor_actual = clamp(valor_0_a_1, 0.0, 1.0)
	actualizar_visuales(valor_actual)
