extends Node


signal died
signal health_changed(current, max)

@export var max_health = 100
var health

func _ready():
	health = max_health

func take_damage(amount):
	print("damage taken: ", amount)
	health -= amount
	emit_signal("health_changed", health, max_health)

	if health <= 0:
		emit_signal("died")

func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
	emit_signal("health_changed", health, max_health)
