extends Node3D

@onready var player = $Player
@onready var ui = $CanvasLayer/Ui
@onready var pause_menu = $PauseMenu
@onready var death_screen = $DeathScreen

var capture_points: Array = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.health.health_changed.connect(ui._on_health_changed)
	#player.weapon_changed.connect(weapon_changed)
	
	# init ammo
	player.ammo_changed.connect(ui.update_ammo)
	player.sync_ammo()
	
	# init player health
	ui.get_node("HealthBar").max_value = player.get_node("Health").max_health
	ui.get_node("HealthBar").value = player.get_node("Health").max_health
	player.died.connect(player_died)
	
	# set capture points
	capture_points = get_tree().get_nodes_in_group("capture_points")
	for point in capture_points:
		point.ownership_changed.connect(check_win_condition)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("exit"):
		#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause():
	var paused = get_tree().paused
	get_tree().paused = !paused
	pause_menu.visible = !paused
	if !paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func player_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	death_screen.visible = true


func check_win_condition():
	if capture_points.is_empty():
		return

	var first_owner = capture_points[0].base_owner

	if first_owner == "neutral":
		return

	for point in capture_points:
		if point.base_owner != first_owner:
			return  # Not all owned by same team

	# If we reach here → all points owned by same team
	end_game(first_owner)


func end_game(winning_team):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if winning_team == "friends":
		get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
	if winning_team == "enemies":
		get_tree().change_scene_to_file("res://scenes/defeat_screen.tscn")
