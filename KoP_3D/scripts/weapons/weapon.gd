extends BaseWeapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accuracy = 0.005
	damage = 22
	fire_rate = 0.5
	reload_speed = 2.5
	current_ammo = 10
	clip_max_ammo = 10
	full_ammo = 120
