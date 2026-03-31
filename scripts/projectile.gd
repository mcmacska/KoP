extends Area2D

@export var speed = 800  # pixels per second
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()  # rotate sprite to match movement direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	print("Detected:", body.name)
	if body.has_node("Health"):
		body.get_node("Health").take_damage(10)
	queue_free()
