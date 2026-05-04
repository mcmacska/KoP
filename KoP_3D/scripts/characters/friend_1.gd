extends BaseCharacter

@export var should_capture_: bool = true

func _ready() -> void:
	dead_scene = preload("res://scenes/characters/friend_dead.tscn")
	friends_group_name = "friends"
	enemies_group_name = "enemies"
	should_capture = should_capture_
	super._ready()
