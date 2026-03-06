extends Node2D

# Referencias a nodos importantes
@onready var caja_dialogo = $DialogueBox 	# Panel donde se muestra el diálogo
@onready var player = $Player 				# Referencia al jugador

# Variable para saber si el jugador está cerca de las escaleras
var cerca_escaleras : bool = false

# Ruta de la imagen del retrato de Trevor para mostrar en el diálogo
var ruta_cara_trevor = "res://assets/ui/dialogue/portrait_01.png"

func _ready():
	# Programamos un comentario inicial que se mostrará tras 3 segundos
	programar_comentario_entrada()

# Función que muestra una serie de pensamientos iniciales del personaje
func programar_comentario_entrada():
	# Esperamos 3 segundos antes de empezar el diálogo
	await get_tree().create_timer(3.0).timeout

	# Lista de frases con nombre, texto y retrato para el diálogo
	var pensamientos = [
		{"nombre": "Trevor", "texto": "What was that?", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "It’s strange that there’s no one here...", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "There’s no sign of life, not a single sound...", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "This place should be more crowded, but it’s empty.", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "I don’t understand why everything is so quiet.", "cara": ruta_cara_trevor}
	]

	# Si el panel de diálogo existe, iniciamos el diálogo y pausamos al jugador mientras
	if caja_dialogo:
		gestionar_estado_jugador(true) 				# Pausamos al jugador para que no se mueva
		caja_dialogo.iniciar_dialogo(pensamientos) 	# Mostramos las frases
		await caja_dialogo.dialogo_terminado 		# Esperamos a que termine el diálogo
		gestionar_estado_jugador(false) 			# Reactivamos al jugador

# Función para pausar o reactivar el control del jugador y el cursor del ratón
func gestionar_estado_jugador(pausar: bool):
	if player: player.set_congelado(pausar) # Congela o descongela al jugador (según implementación)

	# Cambiamos el modo del cursor para que sea visible o no según el estado
	if pausar:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_area_escaleras_body_entered(body):
	# Comprobamos si el cuerpo que entró es el jugador (por grupo o nombre)
	if body.is_in_group("jugador") or body.name == "Player":
		cerca_escaleras = true # Marcamos que el jugador está cerca de las escaleras
		
		# Solo lanzamos el diálogo si el cuadro no está visible ya
		if caja_dialogo and not caja_dialogo.get_node("Control").visible:
			var frase_escaleras = [
				{
					"nombre": "Trevor",
					"texto": "I prefer to use the elevator.",
					"cara": ruta_cara_trevor
				}
			]

			# Pausamos al jugador y mostramos el diálogo
			gestionar_estado_jugador(true)
			caja_dialogo.iniciar_dialogo(frase_escaleras)
			await caja_dialogo.dialogo_terminado
			gestionar_estado_jugador(false)

func _on_area_escaleras_body_exited(body):
	# Cuando el jugador sale del área, indicamos que ya no está cerca
	if body.is_in_group("jugador") or body.name == "Player":
		cerca_escaleras = false
