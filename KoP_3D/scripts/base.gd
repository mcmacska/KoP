extends Node3D

@export var max_capture_points: float = 100.0
@export var capture_speed: float = 5.0 # points per second
@export var bar_name: String = ""

var capture_progress: float = 0.0
var base_owner: String = "neutral"
signal ownership_changed

#
var enemies_in_area: = {}
var allies_in_area: = {}
var own_counter: int = 0
var enemy_counter: int = 0

const neutral_group: String = "neutral"

var ally_group: String = "friends"
var enemy_group: String = "enemies"

# labels
var progress: float = 0.0
var neutral_color := Color.from_rgba8(169, 169, 169)
var ally_color = Color.from_rgba8(82,255,6)
var enemy_color = Color.from_rgba8(179,6,255)
var team_color := neutral_color
@onready var capture_bar = $Bar


func _ready() -> void:
	# set the progress bar
	capture_bar.setup_bar(max_capture_points, bar_name)

	
func _process(delta: float) -> void:
	calculate_capture(delta)
	set_colors(delta)


func calculate_capture(delta: float):
	enemy_counter = enemies_in_area.size()
	own_counter = allies_in_area.size()
	# No one inside → do nothing
	if own_counter == 0 and enemy_counter == 0:
		return
	# Equal forces → no capture
	if own_counter == enemy_counter:
		return
		
	var direction := 0
	
	if own_counter > enemy_counter:
		direction = 1
	elif enemy_counter > own_counter:
		direction = -1
		
	# Speed scales with advantage
	var advantage = abs(own_counter - enemy_counter)
	capture_progress += direction * capture_speed * advantage * delta
	
	# Clamp progress
	capture_progress = clamp(capture_progress, -max_capture_points, max_capture_points)
	
	update_owner()
	

func update_owner():
	if capture_progress >= max_capture_points:
		base_owner = ally_group
		#base_owner_label.text = ally_group
		ownership_changed.emit()
	elif capture_progress <= -max_capture_points:
		base_owner = enemy_group
		#base_owner_label.text = enemy_group
		ownership_changed.emit()
	elif abs(capture_progress) < max_capture_points:
		base_owner = neutral_group
		#base_owner_label.text = neutral_group
		ownership_changed.emit()


func change_team(ally_team_name: String, enemy_team_name: String):
	ally_group = ally_team_name
	enemy_group = enemy_team_name
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body entered: ", body.get_groups())
	
	if body.is_in_group(enemy_group):
		#enemy_counter += 1
		enemies_in_area[body] = true
		# Connect to died signal (if it exists)
		if body.has_signal("died") && !body.died.is_connected(_on_body_died):
			body.died.connect(_on_body_died.bind(body))
		return
	elif body.is_in_group(ally_group):
		#own_counter += 1
		allies_in_area[body] = true
		# Connect to died signal (if it exists) and hasn't been connected
		if body.has_signal("died") && !body.died.is_connected(_on_body_died):
			body.died.connect(_on_body_died.bind(body))
		return


func _on_area_3d_body_exited(body: Node3D) -> void:
	enemies_in_area.erase(body)
	allies_in_area.erase(body)


func _on_body_died(body: Node3D) -> void:
	enemies_in_area.erase(body)
	allies_in_area.erase(body)
	

# VISUALS
func set_colors(delta: float):
	var direction = sign(capture_progress) # -1, 0, or 1
	var amount = abs(capture_progress)
	if progress < 0.05:
		if direction > 0:
			team_color = ally_color
		elif direction < 0:
			team_color = enemy_color
		else:
			team_color = neutral_color
	# update bar
	capture_bar.set_progress(amount, team_color)
