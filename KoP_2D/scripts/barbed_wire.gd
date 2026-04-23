extends Node2D

const damage: int = 4
const damage_rate: int = 1
var body_in_area: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Detected:", body.name)
	# slow down
	if body.has_method("apply_speed_changer"):
		body.apply_speed_changer(0.5)
	# deal damage
	if body.has_node("Health"):
		body_in_area = true
		deal_damage_loop(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	body_in_area = false
	# reset speed
	if body.has_method("apply_speed_changer"):
		body.apply_speed_changer(1)

func deal_damage_loop(body):
	while body_in_area:
		body.get_node("Health").take_damage(damage)
		await get_tree().create_timer(damage_rate).timeout
