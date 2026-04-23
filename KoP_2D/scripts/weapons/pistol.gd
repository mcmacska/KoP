extends BaseWeapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile_damage = 22
	projectile_speed = 4500  # pixels per seconds
	fire_rate = 0.6
	reload_speed = 2
	current_ammo = 6
	clip_max_ammo = 6
	full_ammo = 30
