extends Node2D

# We store a reference to the death plane area. An Area2D detects when areas or bodies
# enter or exit it. We access this node by name using path strings similar to navigating
# through folders in the Linux terminal. So if we want to access the parent we would use
# $.. Or if we wanted to access a child's children we would do $DeathPlane/child
# Note that if we change the name of the referenced node in the scene tree then this
# reference breaks. Additionally we use the @onready keyword to only set this variable
# after the tree is loaded and is ready (so all of its children are also loaded and ready)
@onready var death_plane: Area2D = $DeathPlane
@onready var scene_transitioner: SceneTransitioner = $SceneTransitioner

func _ready() -> void:
	# The death_plane is of type Area2D and thus has access to a signal called
	# body_entered which is emitted whenever any body that this area monitors enters it.
	# Select the DeathPlane from the scene tree and check for other signals it has by 
	# navigating to the Node tab at the left, next to Inspector.
	death_plane.body_entered.connect(_on_player_entered_death_plane)
	
	# We can connect our custom signals the same way as the built in ones.
	# First we access the node that holds the signal, in our case the scene_transitioner.
	# Then we access the signal of that node that we want, in our case the
	# transition_to_scene signal. Finally we connect that signal to our function.
	# here we connect the signal to _on_transition_to_scene.
	scene_transitioner.transition_to_scene.connect(_on_transition_to_scene)
	
	# As soon as the scene loads we get every enemy via their group and connect their
	# signal. There's nothing stopping us from connecting multiple signals to the
	# same function.
	# The syntax to make a for loop in godot is as follows.
	# for <variable1> in <variable2>
	# <variable1> is a local variable that's defined within the for loop itself.
	# it will iterate through all the components of <variable2> (depending on its type)
	# in our case `get_tree().get_nodes_in_group("EnemyFloatingSpike")` returns an 
	# Array of nodes that are in the group that we defined as EnemyFloatingSpike from
	# the inspector. Then the enemy variable iterates through all the values of that Array.
	# To connect all the signals we will iterate through all the enemies that are in the
	# EnemyFloatingSpike group. Godot does some magic with hashing so using groups is
	# much faster than checking through every child node in the scene tree and checking
	# if it's an enemy. The signal hit_player is our custom signal we defined in the 
	# EnemyFloatingSpike scene.
	for enemy in get_tree().get_nodes_in_group("EnemyFloatingSpike"):
		enemy.hit_player.connect(_on_spike_hit_player)

# We listen to the body_entered signal and call this function when it is emitted.
func _on_player_entered_death_plane(_body: Node2D) -> void:
	# We get access to the tree, this returns the entire scene tree structure.
	# From this structure we call the reload_current_scene function to restart
	# this scene. We also use call_deferred which calls this function after the current
	# frame is processed, to ensure no weird physics calls happen.
	get_tree().reload_current_scene.call_deferred()

func _on_transition_to_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)

func _on_spike_hit_player(_spike: Node2D) -> void:
	get_tree().reload_current_scene.call_deferred()
