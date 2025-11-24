class_name SceneTransitioner
extends Area2D

@export_file("*.tscn") var scene_to_transition : String

# We define our own signal like this. Use the `signal` keyword followed by the name
# of our custom signal. Then (if we need to) we set custom arguments for that signal
# to send. Just like how Area2D has the body_entered signal with a parameter of `body`
# we can define the parameter filepath of type String.
signal transition_to_scene(filepath: String)

var is_player_in_range := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PlayerJump") and is_player_in_range and scene_to_transition:
		# We check if the file that we set from the inspector exists.
		if FileAccess.file_exists(scene_to_transition):
			# We emit our custom signal like this. First access the signal and call on
			# it the `emit` function. This function takes as arguments how many
			# parameters we would like to pass with our signal. In our case the 
			# transition_to_scene signal needs an argument `filepath`, so we pass the 
			# variable that stores our filepath which is scene_to_transition.
			transition_to_scene.emit(scene_to_transition)

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
