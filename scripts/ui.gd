extends Control

@onready var health_bar = $HealthBar

#func _ready() -> void:
	#health_bar.add_theme_color_override("fg_color", Color(1, 0, 0))  # red

func _on_health_changed(current, max):
	health_bar.max_value = max
	health_bar.value = current
	print(current, max)
