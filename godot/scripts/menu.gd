extends Control

func _ready():
	# Mostramos el cursor para que el jugador pueda interactuar con el menú
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_new_game_pressed():
	# Cambiamos el modo a "NEW" para crear una nueva partida y vamos al menú de guardados
	Global.modo_menu = "NEW" 
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_load_game_pressed():
	# Cambiamos el modo a "LOAD" para cargar una partida y vamos al menú de guardados
	Global.modo_menu = "LOAD"
	TransitionScreen.cambiar_escena("res://tscn/menu_guardados.tscn")

func _on_btn_settings_pressed():
	# Abrimos la escena de configuración o ajustes
	TransitionScreen.cambiar_escena("res://tscn/settings.tscn")

func _on_btn_exit_pressed():
	# Cerramos el juego
	get_tree().quit()
