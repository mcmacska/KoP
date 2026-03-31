extends Node2D

@export var fire_rate = 0.8
@export var damage = 10

var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	var projectile_scene = preload("res://scenes/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	
	# spawn it at muzzle position
	projectile.position = $Muzzle.global_position
	
	# make it go in the direction the weapon is facing
	var direction = Vector2.RIGHT.rotated(global_rotation)
	projectile.velocity = direction * projectile.speed
	
	# add to the scene tree
	get_tree().current_scene.add_child(projectile)
	# cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
