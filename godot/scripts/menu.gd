extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_new_game_pressed():
	# Le decimos al Global que queremos SOBREESCRIBIR/CREAR
	Global.modo_menu = "NEW" 
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_load_game_pressed():
	# Le decimos al Global que queremos LEER
	Global.modo_menu = "LOAD"
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_settings_pressed():
	print("Botón Settings pulsado (Aún en desarrollo)")
