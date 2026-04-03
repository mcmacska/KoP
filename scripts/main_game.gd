extends Node2D

@onready var player = $Player
@onready var ui = $CanvasLayer/Ui

func _ready():
	player.health.health_changed.connect(ui._on_health_changed)
	
	# init ammo
	if player.has_node("Weapon"):
		var weapon = player.get_node("Weapon")
		weapon.ammo_changed.connect(ui.update_ammo)
		ui.update_ammo(weapon.current_ammo, weapon.full_ammo)
	
	# init player health
	ui.get_node("HealthBar").max_value = player.get_node("Health").max_health
	ui.get_node("HealthBar").value = player.get_node("Health").max_health
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
