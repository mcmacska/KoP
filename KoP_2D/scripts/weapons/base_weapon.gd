extends Node2D

class_name BaseWeapon

# projectile stats
@export var projectile_damage: int = 22
@export var projectile_speed: int = 5000  # pixels per seconds

var projectile_scene = preload("res://scenes/weapons/projectile.tscn")

@export var fire_rate: float = 0.8
@export var reload_speed: float = 2.0

@export var current_ammo: int = 10
@export var clip_max_ammo: int = 10
@export var full_ammo: int = 100

@onready var muzzle_flash = $MuzzleFlash
const muzzle_flash_time: float = 0.1

signal ammo_changed(current_ammo, full_ammo)

var can_shoot: bool = true
var is_reloading: bool = false

var wielder


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
	var projectile = projectile_scene.instantiate()
	
	# spawn it at muzzle position
	projectile.position = $Muzzle.global_position
	projectile.damage = projectile_damage
	# set who shoots it
	projectile.shooter = wielder
	# make it go in the direction the weapon is facing
	var direction = Vector2.RIGHT.rotated(global_rotation)
	projectile.velocity = direction * projectile_speed
	# add effects
	await shooting_effects()
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
	if not is_reloading:
		can_shoot = true
		return  # cancelled
	# decrease full ammo
	full_ammo = full_ammo - (clip_max_ammo - current_ammo)
	current_ammo = clip_max_ammo
	ammo_changed.emit(current_ammo, full_ammo)
	can_shoot = true
	is_reloading = false


func cancel_reload():
	is_reloading = false


func shooting_effects():
	muzzle_flash.visible = true
	await get_tree().create_timer(muzzle_flash_time).timeout
	muzzle_flash.visible = false
