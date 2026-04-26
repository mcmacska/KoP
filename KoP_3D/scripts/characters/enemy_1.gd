extends CharacterBody3D

@export var attack_range := 500

var direction := Vector2.LEFT
var distance_moved = 0
const max_distance = 100

const speed = 16.0
var targets: Array = []
#var current_target: Node2D = null

@onready var health = $Health
@onready var weapon = $Weapon
@onready var muzzle: Node3D = $Muzzle
@onready var body_mesh = $Body
var dead_scene = preload("res://scenes/characters/enemy_dead.tscn")

enum State {
	PATROL,
	CHASE,
	ATTACK,
	CAPTURE
}

var current_state = State.PATROL

@export var patrol_points: Array[Node] = []
var current_point_index := 0

var bases: Array[Node] = []
var base_target: Node

var is_dead = false
signal died()


func _on_died():
	is_dead = true
	died.emit()
	var body = dead_scene.instantiate()
	body.global_transform = global_transform
	#body.linear_velocity = velocity
	get_parent().add_child(body)
	queue_free()


func _ready():
	# overwrite initial health
	health.max_health = 100
	health.health = 100
	health.died.connect(_on_died)
	# set weapon user
	weapon.wielder = self
	# set capture points
	bases = get_tree().get_nodes_in_group("capture_points")
	print("bases: ", bases)
	
	
func _process(delta):
	if is_dead || get_tree().paused:
		return
		
		
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Add the gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	elif velocity.y < 0:
			velocity.y = 0
	update_state()
	match current_state:
		State.PATROL:
			patrol(delta)
		State.CHASE:
			chase(delta)
		State.ATTACK:
			attack(delta)
		State.CAPTURE:
			capture(delta)
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Enemy detected:", body.name)
	if body.is_in_group("friends"):
		targets.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("friends"):
		targets.erase(body)
		

# WEAPON HANDLING
func get_closest_target():
	var closest: Node3D = null
	var closest_distance = INF

	for t in targets:
		if not is_instance_valid(t):
			continue

		var dist = global_position.distance_to(t.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = t

	return closest


func is_aiming_at_target(target: Node3D) -> bool:
	var dir = target.global_position - global_position
	if dir.length_squared() < 0.000001:
		return false
	var to_target = dir.normalized()
	var forward = -global_transform.basis.z
	var dot = forward.dot(to_target)
	# 10 degrees tolerance
	return dot > cos(deg_to_rad(10.0))


func weapon_shooting():
	if weapon.full_ammo < 1:
		print("no ammo")
		return
	if weapon.current_ammo < 1:
		print("reloading")
		weapon.reload()
	else:
		pass
		weapon.shoot(muzzle.global_transform)

func rotate_towards(dir: Vector3, delta: float) -> void:
	var target_basis = Basis.looking_at(dir, Vector3.UP)

	global_transform.basis = global_transform.basis.slerp(
		target_basis,
		5.0 * delta
	)

# STATES
func patrol(delta):
	if patrol_points.is_empty():
		return

	var target = patrol_points[current_point_index]
	var dir = (target.global_position - global_position)
	if dir.length_squared() < 0.000001:
		return # prevent invalid basis
	rotate_towards(dir, delta)

	if dir.length() < 5:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		return

	velocity = dir.normalized() * speed
	
	
func get_closest_base() -> Node3D:
	var closest = null
	var min_dist = INF

	for b in bases:
		if not is_instance_valid(b):
			continue

		# optional: skip already owned bases
		if b.base_owner == "enemies":
			continue

		var dist = global_position.distance_to(b.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = b

	return closest


func capture(delta):
	var base = get_closest_base()
	if not base:
		return

	var dir = base.global_position - global_position
	if dir.length_squared() < 0.000001:
		return # prevent invalid basis
	# rotate like before
	rotate_towards(dir, delta)

	if global_position.distance_to(base.global_position) < 20:
		print("Im in position")
		velocity = Vector3.ZERO
	else:
		velocity = dir.normalized() * speed
		

func chase(delta):
	var target = get_closest_target()
	if not target:
		return

	var dir = (target.global_position - global_position)
	if dir.length_squared() < 0.000001:
		return # prevent invalid basis
	velocity = dir.normalized() * speed


func update_state():
	var target = get_closest_target()
	# if it can see the target, attack it
	if target:
		if global_position.distance_to(target.global_position) < attack_range:
			current_state = State.ATTACK
		else:
			current_state = State.CHASE
	elif get_closest_base():
		current_state = State.CAPTURE
	else:
		# go back to patrolling
		current_state = State.PATROL


func attack(delta):
	var current_target: Node3D = get_closest_target()
	if not current_target:
		return

	if current_target.is_dead:
		targets.erase(current_target)
		return

	var dir = current_target.global_position - global_position
	rotate_towards(dir, delta)

	if is_aiming_at_target(current_target):
		weapon_shooting()
