extends Node2D

# Referencias a los destinos donde el jugador se moverá al usar las escaleras
@onready var destino_subida = $DestinoSubida 
@onready var destino_bajada = $DestinoBajada 

# Referencia al panel de diálogo para mostrar pensamientos o diálogos
@onready var caja_dialogo = $DialogueBox

func _ready():
	# Si existe un sistema de transición, aquí podría iniciarse la animación de entrada
	if has_node("/root/TransitionScreen"):
		print("Iniciando mapa con transición...")
		# Puedes activar aquí la animación de entrada si tu sistema lo soporta
	
	# Programamos que tras 3 segundos se muestren los pensamientos iniciales del personaje
	programar_comentario_entrada()

func programar_comentario_entrada():
	# Esperamos 3 segundos para dar tiempo a la escena a cargar o al jugador a ubicarse
	await get_tree().create_timer(3.0).timeout
	
	# Imagen que acompañará los pensamientos de Trevor en el diálogo
	var ruta_cara = "res://assets/ui/dialogue/portrait_01.png"
	
	# Lista con las frases que Trevor piensa al llegar a la estación, cada una con nombre, texto y retrato
	var pensamientos_estacion = [
		{"nombre": "Trevor", "texto": "It’s strange that there’s no one here...", "cara": ruta_cara},
		{"nombre": "Trevor", "texto": "There’s no sign of life, not a single sound...", "cara": ruta_cara},
		{"nombre": "Trevor", "texto": "This place should be more crowded, but it’s empty.", "cara": ruta_cara},
		{"nombre": "Trevor", "texto": "I don’t understand why everything is so quiet.", "cara": ruta_cara}
	]
	
	# Si el panel de diálogo está disponible, mostramos los pensamientos y bloqueamos al jugador mientras lee
	if caja_dialogo:
		var p = get_tree().get_first_node_in_group("jugador")
		if p: p.set_congelado(true) # Evitar movimiento durante el diálogo
		
		caja_dialogo.iniciar_dialogo(pensamientos_estacion)
		
		# Esperamos a que el jugador termine de leer todo el diálogo
		await caja_dialogo.dialogo_terminado
		
		# Devolvemos el control al jugador para que pueda moverse de nuevo
		if p: p.set_congelado(false)

# Detecta cuando el jugador entra en la zona para subir la escalera
func _on_entrada_subida_body_entered(body):
	# Comprobamos que el cuerpo sea el jugador para evitar activaciones erróneas
	if body.name == "Player" or body.is_in_group("jugador"):
		print("Subiendo escalera...")
		# Llamamos a la función que anima la subida hacia el destino indicado con la animación de "Izquierda"
		body.usar_escalera(destino_subida.global_position, 2, "Izquierda")

# Detecta cuando el jugador entra en la zona para bajar la escalera
func _on_entrada_bajada_body_entered(body):
	# Igual que antes, comprobamos que sea el jugador
	if body.name == "Player" or body.is_in_group("jugador"):
		print("Bajando escalera...")
		# Animamos la bajada hacia el destino con animación "Derecha"
		body.usar_escalera(destino_bajada.global_position, 2, "Derecha")
