extends CanvasLayer

@onready var color_rect = $ColorRect

func cambiar_escena(ruta_escena: String):
	# 1. Fundido a NEGRO (Fade Out)
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5) # Tarda 0.5 segundos en ponerse negro
	
	# Esperamos a que termine el fundido
	await tween.finished
	
	# 2. Cambiamos de mapa mientras la pantalla está negra
	get_tree().change_scene_to_file(ruta_escena)
	
	# 3. Fundido a TRANSPARENTE (Fade In)
	var tween_aparecer = create_tween()
	tween_aparecer.tween_property(color_rect, "color:a", 0.0, 0.5) # Tarda 0.5 seg en revelar el mapa
