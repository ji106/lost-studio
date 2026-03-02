extends Control

@onready var caja_dialogo = $DialogueBox

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# --- RUTA CORREGIDA SEGÚN TUS ARCHIVOS ---
	var ruta_trevor = "res://assets/ui/dialogue/portrait_01.png"

	var monologo_trevor = [
		{
			"nombre": "Trevor",
			"texto": "None of this feels real. My mind is fragmented, trapped in memories that fade before I can hold onto them.",
			"cara": ruta_trevor
		},
		{
			"nombre": "Trevor",
			"texto": "I feel like I’m not quite what I used to be, as if something inside me is incomplete, searching for a purpose I still don’t understand.",
			"cara": ruta_trevor
		},
		{
			"nombre": "Trevor",
			"texto": "Lost in a maze of shadows and broken memories, every step is a struggle to find her, to find a way out.",
			"cara": ruta_trevor
		}
	]
	
	await get_tree().create_timer(1.5).timeout
	
	if not caja_dialogo.dialogo_terminado.is_connected(_al_terminar_intro):
		caja_dialogo.dialogo_terminado.connect(_al_terminar_intro)
	
	caja_dialogo.iniciar_dialogo(monologo_trevor)

func _al_terminar_intro():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if has_node("/root/TransitionScreen"):
		TransitionScreen.cambiar_escena("res://tscn/start.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/start.tscn")
