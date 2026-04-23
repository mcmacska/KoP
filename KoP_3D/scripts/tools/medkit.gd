extends Area2D

@export var hp: int = 20


func _on_body_entered(body: Node2D) -> void:
	if !body.has_node("Health"):
		return
	if body.get_node("Health").health == body.get_node("Health").max_health:
		return
	body.get_node("Health").heal(hp)
	queue_free()
