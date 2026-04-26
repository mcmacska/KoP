extends CharacterBody3D

@export var sensitivity: float = 0.003
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera
var pitch: float = 0.0

var is_running: bool = false
const BASE_SPEED: float = 16.0
@export var speed_changer: float = 1.0
var internal_speed_changer: float = 1.0
const JUMP_VELOCITY: float = 4.5

@onready var health = $Health
@onready var hitbox = $Hitbox

var is_dead = false
signal died()

# weapon management
var inventory: Array = []
var current_weapon_index := 0
var current_weapon: Node = null
@onready var weapon_holder = $CameraPivot/WeaponHolder
signal ammo_changed(current, max)


func _on_died():
	is_dead = true
	died.emit()
	set_process(false)
	set_physics_process(false)

func _ready():
	# overwrite initial health
	health.max_health = 100
	health.health = 100
	health.died.connect(_on_died)
	
	# add starter weapons
	print("segg")
	add_weapon(preload("res://scenes/weapons/weapon.tscn"))
	add_weapon(preload("res://scenes/weapons/pistol.tscn"))
	print("amog")
	equip_weapon(0)


func _input(event):
	if is_dead || get_tree().paused:
		return
	if event is InputEventMouseMotion:
		manage_direction(event)
	elif event.is_action_pressed("scroll_up"):
		var next = (current_weapon_index + 1) % inventory.size()
		equip_weapon(next)
	elif event.is_action_pressed("scroll_down"):
		var prev = (current_weapon_index - 1 + inventory.size()) % inventory.size()
		equip_weapon(prev)


func _process(delta):
	if get_tree().paused:
		return
	if Input.is_action_just_pressed("shoot"):
		current_weapon.shoot(camera.global_transform)
	if Input.is_action_just_pressed("reload"):
		current_weapon.reload()
	if Input.is_action_just_pressed("run"):
		internal_speed_changer = 2
	if Input.is_action_just_released("run"):
		internal_speed_changer = 1


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	# Add the gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	elif velocity.y < 0:
			velocity.y = 0
	manage_movement()
	move_and_slide()


func manage_direction(event):
	 # LEFT / RIGHT (yaw)
	rotate_y(-event.relative.x * sensitivity)
	# UP / DOWN (pitch)
	pitch -= event.relative.y * sensitivity
	pitch = clamp(pitch, -1.5, 1.5)
	camera_pivot.rotation.x = pitch
	

func manage_movement():
	var input_dir = Input.get_vector("left", "right", "backwards", "forward")
	var direction = Vector3.ZERO
	
	# Get forward and right directions from player
	var forward = -transform.basis.z
	var right = transform.basis.x
	
	direction = (right * input_dir.x + forward * input_dir.y).normalized()
		
	velocity.x = direction.x * BASE_SPEED * internal_speed_changer * speed_changer
	velocity.z = direction.z * BASE_SPEED * internal_speed_changer * speed_changer
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func apply_speed_changer(multiplier: float):
	speed_changer = multiplier
	

func add_weapon(weapon_scene: PackedScene):
	print("add_weapon")
	var weapon = weapon_scene.instantiate()
	print("add_weapon 2")
	inventory.append(weapon)
	print("add_weapon 3")
	weapon.hide()  # don't show yet
	weapon_holder.add_child(weapon)
	# Connect weapon ammo change
	weapon.ammo_changed.connect(_on_weapon_ammo_changed)


func equip_weapon(index: int):
	print("Equiping weapon ", index)
	if current_weapon:
		current_weapon.cancel_reload()
		current_weapon.hide()
	# Spawn new weapon
	current_weapon = inventory[index]
	current_weapon.show()
	current_weapon_index = index
	# set wielder
	current_weapon.wielder = self
	 ## Sync
	_on_weapon_ammo_changed(
		current_weapon.current_ammo,
		current_weapon.full_ammo
	)


func _on_weapon_ammo_changed(current_, max_):
	print("ammo changed: ", current_, max_)
	ammo_changed.emit(current_, max_)

	
func sync_ammo():
	if current_weapon:
		ammo_changed.emit(current_weapon.current_ammo, current_weapon.full_ammo)
