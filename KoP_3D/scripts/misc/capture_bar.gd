extends Sprite3D


@export var max_progress: float = 100.0
@export var team_color: Color
@onready var prograss_bar := $SubViewport/ProgressBar
@onready var bar_name := $Name
var style = StyleBoxFlat.new()
@onready var camera = get_viewport().get_camera_3d()


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# scale, so it is visible from far away
	var dist = global_position.distance_to(camera.global_position)
	var scale_factor = clamp(dist * 0.16, 1.0, 32.0)
	scale = Vector3.ONE * scale_factor
	
	
func setup_bar(max_value: float, name: String):
	prograss_bar.max_value = max_value
	bar_name.text = name
	
	
	
func set_progress(progress: float, color: Color):
	prograss_bar.value = progress
	# change color
	style.bg_color = color
	prograss_bar.add_theme_stylebox_override("fill", style)
	
