extends Control

@onready var health_bar = $HealthBar
@onready var current_ammo = $HBoxContainer/CurrentAmmo
@onready var full_ammo = $HBoxContainer/FullAmmo

#func _ready() -> void:
	#health_bar.add_theme_color_override("fg_color", Color(1, 0, 0))  # red

func _on_health_changed(current_health, max_health):
	health_bar.max_value = max_health
	health_bar.value = current_health
	print(current_health, max_health)

func update_ammo(current, max_ammo):
	print("ui update ammo: ", current, max_ammo)
	current_ammo.text = str(current)
	full_ammo.text = str(max_ammo)
