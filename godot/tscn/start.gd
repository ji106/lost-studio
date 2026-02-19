extends Node2D

@onready var destino_subida = $DestinoSubida # Asegúrate de que la ruta al nodo sea correcta
@onready var destino_bajada = $DestinoBajada 

# --- CUANDO ENTRA EN LA ESCALERA DE ABAJO ---
func _on_entrada_subida_body_entered(body):
	if body.name == "Player":
		print("Subiendo escalera...")
		# Le pasamos: a dónde ir, cuántos segundos tarda, y hacia dónde mira
		body.usar_escalera(destino_subida.global_position, 2, "Izquierda")

# --- CUANDO ENTRA EN LA ESCALERA DE ARRIBA ---
func _on_entrada_bajada_body_entered(body):
	if body.name == "Player":
		print("Bajando escalera...")
		body.usar_escalera(destino_bajada.global_position, 2, "Derecha")
