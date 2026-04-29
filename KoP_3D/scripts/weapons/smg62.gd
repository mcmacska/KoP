extends BaseWeapon

func _init():
	weapon_slot = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accuracy = 0.01
	damage = 8
	fire_rate = 0.08
	reload_speed = 2.5
	current_ammo = 30
	clip_max_ammo = 30
	full_ammo = 120


func trigger_held(camera_transform: Transform3D):
	shoot(camera_transform)
