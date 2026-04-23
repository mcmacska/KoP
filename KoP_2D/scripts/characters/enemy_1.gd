extends CharacterBody2D

@export var attack_range := 500

var direction := Vector2.LEFT
var distance_moved = 0
const max_distance = 100

const speed = 160.0
var targets: Array = []
#var current_target: Node2D = null

@onready var health = $Health
@onready var weapon = $Weapon
@onready var sprite = $Sprite2D
var dead_sprite = preload("res://assets/characters/dead_character.png")

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
	sprite.texture = dead_sprite
	is_dead = true
	died.emit()
	set_process(false)
	set_physics_process(false)
	
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
	if get_tree().paused:
		return
		
		
func _physics_process(delta: float) -> void:
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Enemy detected:", body.name)
	if body.is_in_group("friends"):
		targets.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("friends"):
		targets.erase(body)
		

# WEAPON HANDLING
func get_closest_target():
	var closest: Node2D = null
	var closest_distance = INF

	for t in targets:
		if not is_instance_valid(t):
			continue

		var dist = global_position.distance_to(t.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = t

	return closest


func is_aiming_at_target(target: Node2D) -> bool:
	var direction_to_target = (target.global_position - global_position).angle()
	var angle_diff = abs(angle_difference(rotation, direction_to_target))
	return angle_diff < deg_to_rad(10) # tolerance


func weapon_shooting():
	if weapon.full_ammo < 1:
		print("no ammo")
		return
	if weapon.current_ammo < 1:
		print("reloading")
		weapon.reload()
	else:
		weapon.shoot()


func _draw():
	draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(rotation) * 50, Color.RED)
	

# STATES
func patrol(delta):
	if patrol_points.is_empty():
		return

	var target = patrol_points[current_point_index]
	var dir = (target.global_position - global_position)
	var target_angle = dir.angle()
	rotation = lerp_angle(rotation, target_angle, 5 * delta)

	if dir.length() < 5:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		return

	velocity = dir.normalized() * speed
	move_and_slide()
	
	
func get_closest_base() -> Node2D:
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

	# rotate like before
	var target_angle = dir.angle()
	rotation = lerp_angle(rotation, target_angle, 5 * delta)

	if global_position.distance_to(base.global_position) < 20:
		print("Im in position")
		velocity = Vector2.ZERO
	else:
		velocity = dir.normalized() * speed
		move_and_slide()
		

func chase(delta):
	var target = get_closest_target()
	if not target:
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()


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
	var current_target: Node2D = get_closest_target()
	if not current_target:
		return

	if current_target.is_dead:
		targets.erase(current_target)
		return

	var direction = current_target.global_position - global_position
	var target_angle = direction.angle()

	rotation = lerp_angle(rotation, target_angle, 5 * delta)

	if is_aiming_at_target(current_target):
		weapon_shooting()
