extends Node2D

# --- REFERENCIAS ---
@onready var caja_dialogo = $DialogueBox 
@onready var player = $Player 

# Variable para saber si estamos en el área de las escaleras
var cerca_escaleras : bool = false
var ruta_cara_trevor = "res://assets/ui/dialogue/portrait_01.png"

func _ready():
	
	programar_comentario_entrada()

# --- LÓGICA DE PENSAMIENTOS INICIALES ---
func programar_comentario_entrada():
	await get_tree().create_timer(3.0).timeout
	
	var pensamientos = [
		{"nombre": "Trevor", "texto": "What was that?", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "It’s strange that there’s no one here...", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "There’s no sign of life, not a single sound...", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "This place should be more crowded, but it’s empty.", "cara": ruta_cara_trevor},
		{"nombre": "Trevor", "texto": "I don’t understand why everything is so quiet.", "cara": ruta_cara_trevor}
	]
	
	if caja_dialogo:
		gestionar_estado_jugador(true)
		caja_dialogo.iniciar_dialogo(pensamientos)
		await caja_dialogo.dialogo_terminado
		gestionar_estado_jugador(false)

func gestionar_estado_jugador(pausar: bool):
	if player: player.set_congelado(pausar)
	if pausar:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

# ==========================================
#        SEÑALES DEL AREA2D (Escaleras)
# ==========================================

func _on_area_escaleras_body_entered(body):
	# Comprobamos si es el jugador
	if body.is_in_group("jugador") or body.name == "Player":
		cerca_escaleras = true
		
		# Solo lanzamos el diálogo si el cuadro no está ya abierto
		if caja_dialogo and not caja_dialogo.get_node("Control").visible:
			var frase_escaleras = [
				{
					"nombre": "Trevor",
					"texto": "I prefer to use the elevator.",
					"cara": ruta_cara_trevor
				}
			]
			
			gestionar_estado_jugador(true)
			caja_dialogo.iniciar_dialogo(frase_escaleras)
			await caja_dialogo.dialogo_terminado
			gestionar_estado_jugador(false)

func _on_area_escaleras_body_exited(body):
	if body.is_in_group("jugador") or body.name == "Player":
		cerca_escaleras = false
