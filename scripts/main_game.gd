extends Node2D

@onready var player = $Player
@onready var ui = $CanvasLayer/Ui
@onready var pause_menu = $PauseMenu
@onready var death_screen = $DeathScreen
@onready var weapon_holder = $Player/WeaponHolder

func _ready():
	player.health.health_changed.connect(ui._on_health_changed)
	#player.weapon_changed.connect(weapon_changed)
	
	# init ammo
	player.ammo_changed.connect(ui.update_ammo)
	player.sync_ammo()
	
	# init player health
	ui.get_node("HealthBar").max_value = player.get_node("Health").max_health
	ui.get_node("HealthBar").value = player.get_node("Health").max_health
	player.died.connect(player_died)
		

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


func player_died():
	death_screen.visible = true


#func weapon_changed():
	#if player.current_weapon:
		#player.current_weapon.ammo_changed.connect(ui.update_ammo)
		#ui.update_ammo(player.current_weapon.current_ammo, player.current_weapon.full_ammo)
