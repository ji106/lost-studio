extends CanvasLayer

# Referencia al ColorRect que cubre toda la pantalla para hacer el fundido
@onready var color_rect = $ColorRect

# Función para cambiar de escena con efecto de fundido suave
func cambiar_escena(ruta_escena: String):
	# 1. Fundido a negro (fade out) para ocultar la escena actual
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5) # Tarda 0.5 segundos en ponerse negro
	
	# Esperamos a que termine la animación de fundido a negro
	await tween.finished
	
	# 2. Cambiamos la escena mientras la pantalla está negra, evitando parpadeos
	get_tree().change_scene_to_file(ruta_escena)
	
	# 3. Fundido a transparente (fade in) para mostrar la nueva escena suavemente
	var tween_aparecer = create_tween()
	tween_aparecer.tween_property(color_rect, "color:a", 0.0, 0.5) # Tarda 0.5 seg en revelar el mapa
