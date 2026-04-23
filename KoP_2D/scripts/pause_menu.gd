extends CanvasLayer

func _ready():
	get_tree().paused = false
		

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_exit_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
