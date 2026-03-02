extends CanvasLayer

@onready var fondo = $FondoNegro
@onready var texto = $TextoContinuara

func _ready():
	# 1. Empezamos invisibles para el efecto
	fondo.modulate.a = 0
	texto.modulate.a = 0
	
	# 2. Hacemos que aparezca suavemente (Fade In)
	var tween = create_tween()
	# Aparece el fondo negro en 1.5 segundos
	tween.tween_property(fondo, "modulate:a", 1.0, 1.5)
	# Aparece el texto en 1.5 segundos después del fondo
	tween.parallel().tween_property(texto, "modulate:a", 1.0, 2.0)
	
	# 3. Esperamos los 5 segundos que me has pedido
	print("El juego ha terminado. Gracias por jugar.")
	await get_tree().create_timer(5.0).timeout
	
	# 4. Cerramos el juego
	get_tree().quit()
