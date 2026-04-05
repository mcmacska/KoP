extends RigidBody2D

@export var damage: int = 20
var velocity = Vector2.ZERO

# who shoots it
var shooter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	gravity_scale = 0
	linear_damp = 0
	
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()  # rotate sprite to match movement direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_body_entered(collision.get_collider())


func _on_body_entered(body: Node2D) -> void:
	print("Detected:", body.name)
	if body == shooter:
		queue_free()
		return # don't hit yourself
	
	if body.is_in_group("friends") and shooter.is_in_group("friends"):
		queue_free()
		return # ally → no damage

	if body.is_in_group("enemies") and shooter.is_in_group("enemies"):
		queue_free()
		return # same team → no damage
		
	if body.has_node("Health"):
		body.get_node("Health").take_damage(damage)
	queue_free()
