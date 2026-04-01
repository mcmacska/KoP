extends Node2D

@export var fire_rate = 0.8
@export var damage = 10

@export var reload_speed = 2

@export var current_ammo = 10
@export var clip_max_ammo = 10
@export var full_ammo = 100

signal ammo_changed(current_ammo, full_ammo)

var can_shoot = true
var is_reloading = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if not can_shoot or is_reloading or current_ammo <= 0:
		return
	can_shoot = false
	print("shooting...")
	var projectile_scene = preload("res://scenes/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	
	# spawn it at muzzle position
	projectile.position = $Muzzle.global_position
	
	# make it go in the direction the weapon is facing
	var direction = Vector2.RIGHT.rotated(global_rotation)
	projectile.velocity = direction * projectile.speed
	
	# add to the scene tree
	get_tree().current_scene.add_child(projectile)
	# decrease current ammo
	current_ammo = current_ammo - 1
	ammo_changed.emit(current_ammo, full_ammo)
	# cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
	
	
func reload():
	if is_reloading or current_ammo == clip_max_ammo or full_ammo <= 0:
		return
	is_reloading = true
	can_shoot = false
	print("reloading...")
	# cooldown
	await get_tree().create_timer(reload_speed).timeout
	# decrease full ammo
	full_ammo = full_ammo - (clip_max_ammo - current_ammo)
	current_ammo = clip_max_ammo
	ammo_changed.emit(current_ammo, full_ammo)
	can_shoot = true
	is_reloading = false
