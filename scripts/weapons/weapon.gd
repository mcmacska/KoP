extends BaseWeapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile_damage = 22
	projectile_speed = 5000  # pixels per seconds
	fire_rate = 0.8
	reload_speed = 2.5
	current_ammo = 10
	clip_max_ammo = 10
	full_ammo = 120
