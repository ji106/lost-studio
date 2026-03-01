extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_new_game_pressed():
	Global.modo_menu = "NEW" 
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_load_game_pressed():
	Global.modo_menu = "LOAD"
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_settings_pressed():
	# ¡Ahora sí funciona!
	TransitionScreen.cambiar_escena("res://tscn/settings.tscn")

func _on_btn_exit_pressed():
	get_tree().quit()
