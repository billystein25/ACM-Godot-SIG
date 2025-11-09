extends Area2D

@export var scene_to_transition : String
var is_player_in_range := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("EnterDoor") and is_player_in_range and scene_to_transition:
		if FileAccess.file_exists(scene_to_transition):
			get_tree().change_scene_to_file(scene_to_transition)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	
	is_player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	
	is_player_in_range = false
