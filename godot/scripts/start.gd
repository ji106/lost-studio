extends Node2D

# --- REFERENCIAS A NODOS ---
@onready var destino_subida = $DestinoSubida 
@onready var destino_bajada = $DestinoBajada 

# Referencias para el diálogo y el sistema de juego
@onready var caja_dialogo = $DialogueBox

func _ready():
	# 1. TRANSICIÓN DE ENTRADA
	# Esto asegura que el nivel aparezca suavemente tras la escena negra de la intro.
	# Si tu TransitionScreen no lo hace automático, puedes llamar a su función de entrada aquí.
	if has_node("/root/TransitionScreen"):
		print("Iniciando mapa con transición...")
		# TransitionScreen.play_fade_in() # <--- Descomenta si tienes esta función
	
	# 2. INICIO DE PENSAMIENTOS
	# Lanzamos los pensamientos 3 segundos después de empezar
	programar_comentario_entrada()

func programar_comentario_entrada():
	# Esperamos los 3 segundos solicitados antes de que Trevor hable
	await get_tree().create_timer(3.0).timeout
	
	# Ruta de la imagen del retrato de Trevor
	var ruta_cara = "res://assets/ui/dialogue/portrait_01.png"
	
	# Definimos los 4 pensamientos solicitados
	var pensamientos_estacion = [
		{
			"nombre": "Trevor",
			"texto": "It’s strange that there’s no one here...",
			"cara": ruta_cara
		},
		{
			"nombre": "Trevor",
			"texto": "There’s no sign of life, not a single sound...",
			"cara": ruta_cara
		},
		{
			"nombre": "Trevor",
			"texto": "This place should be more crowded, but it’s empty.",
			"cara": ruta_cara
		},
		{
			"nombre": "Trevor",
			"texto": "I don’t understand why everything is so quiet.",
			"cara": ruta_cara
		}
	]
	
	# Lanzamos la interfaz de diálogo si existe en la escena
	if caja_dialogo:
		var p = get_tree().get_first_node_in_group("jugador")
		
		# Congelamos al personaje para que no pueda caminar mientras piensa [cite: 2025-11-28]
		if p: p.set_congelado(true)
		
		caja_dialogo.iniciar_dialogo(pensamientos_estacion)
		
		# Esperamos a que el jugador termine de leer todos los cuadros
		await caja_dialogo.dialogo_terminado
		
		# Devolvemos el control al jugador
		if p: p.set_congelado(false)

# --- LÓGICA DE ESCALERAS (TU CÓDIGO ORIGINAL) ---

func _on_entrada_subida_body_entered(body):
	# Detección mejorada usando grupos para mayor seguridad [cite: 2025-11-28]
	if body.name == "Player" or body.is_in_group("jugador"):
		print("Subiendo escalera...")
		body.usar_escalera(destino_subida.global_position, 2, "Izquierda")

func _on_entrada_bajada_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		print("Bajando escalera...")
		body.usar_escalera(destino_bajada.global_position, 2, "Derecha")
