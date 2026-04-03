extends CharacterBody2D

var is_running: bool = false
const BASE_SPEED: float = 200.0
@export var speed_changer: float = 1.0
#const JUMP_VELOCITY = -400.0

@onready var health = $Health
@onready var weapon = $Weapon

var current_weapon: Node = null

func _on_died():
	queue_free()

func _ready():
	# overwrite initial health
	health.max_health = 100
	health.health = 100
	health.died.connect(_on_died)


func _process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()
	if Input.is_action_just_pressed("reload"):
		weapon.reload()
	if Input.is_action_just_pressed("run"):
		speed_changer = 2
	if Input.is_action_just_released("run"):
		speed_changer = 1
		


func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	manage_movement()
	move_and_slide()
	
	
func manage_movement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
		
	velocity = direction * BASE_SPEED * speed_changer


func apply_speed_changer(multiplier: float):
	speed_changer = multiplier
	

func equip_weapon(weapon_scene: PackedScene):
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate()
	add_child(current_weapon)
	current_weapon.position = Vector2.ZERO
