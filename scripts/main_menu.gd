extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		print("Exiting...")
		get_tree().quit()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
