extends CharacterBody2D

@onready var health = $Health
@onready var health_label = $HealthLabel

func _ready():
	# overwrite initial health
	health.max_health = 100
	health.health = 100
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Detected:", body.name)
	if body.has_node("Health"):
		body.get_node("Health").take_damage(10)


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("Exited:", body.name)

func _on_health_changed(current, max):
	health_label.text = "%d" % [current]

func _on_died():
	queue_free()
