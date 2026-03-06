extends CanvasLayer

@onready var fondo = $FondoNegro 		# Fondo negro para el efecto de transición
@onready var texto = $TextoContinuara 	# Texto que muestra "Continuará" o mensaje final

func _ready():
	# 1. Empezamos con el fondo y texto invisibles (transparencia total)
	fondo.modulate.a = 0
	texto.modulate.a = 0
	
	# 2. Creamos una animación para que el fondo y el texto aparezcan suavemente (fade in)
	var tween = create_tween()
	# El fondo negro aparece en 1.5 segundos
	tween.tween_property(fondo, "modulate:a", 1.0, 1.5)
	# El texto aparece en 2 segundos, empezando al mismo tiempo que el fondo (en paralelo)
	tween.parallel().tween_property(texto, "modulate:a", 1.0, 2.0)
	
	# 3. Esperamos 5 segundos mostrando el mensaje antes de cerrar
	print("El juego ha terminado. Gracias por jugar.")
	await get_tree().create_timer(5.0).timeout
	
	# 4. Cerramos el juego
	get_tree().quit()
