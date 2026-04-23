extends Node2D

@export var max_capture_points: int = 100
@export var capture_speed: float = 5.0 # points per second

var capture_progress: float = 0.0
var base_owner: String = "neutral"
signal ownership_changed

var own_counter: int = 0
var enemy_counter: int = 0

const neutral_group: String = "neutral"

var ally_group: String = "friends"
var enemy_group: String = "enemies"

@onready var capture_label = $CaptureLabel
@onready var base_owner_label = $BaseOwner

func _ready() -> void:
	base_owner_label.text = base_owner
	capture_label.text = "%d" % [capture_progress]

	
func _process(delta: float) -> void:
	calculate_capture(delta)

func calculate_capture(delta: float):
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
	
	capture_label.text = "%d" % [capture_progress]
	
	update_owner()
	

func update_owner():
	if capture_progress >= max_capture_points:
		base_owner = ally_group
		base_owner_label.text = ally_group
		ownership_changed.emit()
	elif capture_progress <= -max_capture_points:
		base_owner = enemy_group
		base_owner_label.text = enemy_group
		ownership_changed.emit()
	elif abs(capture_progress) < max_capture_points:
		base_owner = neutral_group
		base_owner_label.text = neutral_group
		ownership_changed.emit()


func change_team(ally_team_name: String, enemy_team_name: String):
	ally_group = ally_team_name
	enemy_group = enemy_team_name
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("body entered: ", body.get_groups())
	
	if body.is_in_group(enemy_group):
		enemy_counter += 1
		# Connect to died signal (if it exists)
		if body.has_signal("died"):
			body.died.connect(_on_body_died.bind(body))
		return
	elif body.is_in_group(ally_group):
		own_counter += 1
		# Connect to died signal (if it exists) and hasn't been connected
		if body.has_signal("died") && !body.died.is_connected(_on_body_died):
			body.died.connect(_on_body_died.bind(body))
		return


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group(enemy_group):
		enemy_counter -= 1
		return
	if body.is_in_group(ally_group):
		own_counter -= 1
		return


func _on_body_died(body: Node2D) -> void:
	if body.is_in_group(enemy_group):
		enemy_counter -= 1
		return
	if body.is_in_group(ally_group):
		own_counter -= 1
		return
