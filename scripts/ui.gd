extends Control

@onready var health_bar = $HealthBar
@onready var current_ammo = $HBoxContainer/CurrentAmmo
@onready var full_ammo = $HBoxContainer/FullAmmo

#func _ready() -> void:
	#health_bar.add_theme_color_override("fg_color", Color(1, 0, 0))  # red

func _on_health_changed(current, max):
	health_bar.max_value = max
	health_bar.value = current
	print(current, max)

func update_ammo(current, max):
	print("ui update ammo: ", current, max)
	current_ammo.text = str(current)
	full_ammo.text = str(max)
