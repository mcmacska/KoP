extends Node2D

@onready var player = $Player
@onready var ui = $Ui

func _ready():
	player.health.health_changed.connect(ui._on_health_changed)
	
	# init player health
	ui.get_node("HealthBar").max_value = player.get_node("Health").max_health
	ui.get_node("HealthBar").value = player.get_node("Health").max_health
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
