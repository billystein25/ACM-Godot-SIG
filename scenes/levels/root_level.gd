extends Node2D

# We store a reference to the death plane area. An Area2D detects when areas or bodies
# enter or exit it. We access this node by name using path strings similar to navigating
# through folders in the Linux terminal. So if we want to access the parent we would use
# $.. Or if we wanted to access a child's children we would do $DeathPlane/child
# Note that if we change the name of the referenced node in the scene tree then this
# reference breaks. Additionally we use the @onready keyword to only set this variable
# after the tree is loaded and is ready (so all of its children are also loaded and ready)
@onready var death_plane: Area2D = $DeathPlane

func _ready() -> void:
	# The death_plane is of type Area2D and thus has access to a signal called
	# body_entered which is emitted whenever any body that this area monitors enters it.
	# Select the DeathPlane from the scene tree and check for other signals it has by 
	# navigating to the Node tab at the left, next to Inspector.
	death_plane.body_entered.connect(_on_player_entered_death_plane)

# We listen to the body_entered signal and call this function when it is emitted.
func _on_player_entered_death_plane(_body: Node2D) -> void:
	# We get access to the tree, this returns the entire scene tree structure.
	# From this structure we call the reload_current_scene function to restart
	# this scene. We also use call_deferred which calls this function after the current
	# frame is processed, to ensure no weird physics calls happen.
	get_tree().reload_current_scene.call_deferred()
