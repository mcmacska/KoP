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
	ATTACK
}

var current_state = State.PATROL

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
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#
	#move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Enemy detected:", body.name)
	if body.is_in_group("friends"):
		targets.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("friends"):
		targets.erase(body)
		
		
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
	

# MOVEMENT
func patrol(delta):
	velocity = direction * speed
	move_and_slide()
	distance_moved += 1

	if is_on_wall() || distance_moved > max_distance:
		# reset distance moved
		distance_moved = 0
		# turn
		direction *= -1


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
