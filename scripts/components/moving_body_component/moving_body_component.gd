## A component to move the parent node through a series of points in 2D space
## defined by the children of this node. Only considers [Marker2D] nodes.[br]

# The @tool annotation allows us to run this script in the editor.
@tool
class_name MovingBodyComponent
extends Node

## The kinds of movement that the [member parent] can perform.[br]
enum BOUNCE_MODES {
	## Cycles through the points. Once it reaches the final point
	## it goes back to the first.
	CYCLE,
	## Ping-pongs through the points. Once it reaches the final point
	## it traces the same points backwards until it reaches the first one again.
	PING_PONG 
	}
## The node to which the transform will be applied. By default it is the direct
## [member Node.owner] of this node.
@export var parent : Node2D
## The type of movement selected. See [enum BOUNCE_MODES].
@export var bounce_mode : BOUNCE_MODES
## The time in seconds the tween takes to reach the next point.
@export var time_to_reach_point : float = 2.0
## The time in seconds the node waits before moving to the next point.
@export var wait_time_between_movement : float = 5.0

## The list of [Marker2D] nodes that the [member parent] will move through.
var list_of_marker_nodes : Array[Marker2D]:
	set(value):
		list_of_marker_nodes = value
		_get_configuration_warnings()
## The pointer to show the point the [member parent] is moving to. Refers to an id
## in [member list_of_marker_nodes]
var curr_position_in_array : int = 0
## Shows whether the node is moving forward or backward in the list of positions.
## Is only used when [member bounce_mode] is set to [constant PING_PONG].
var moving_forward := true

# One of the built in functions of Godot. The returned value refers to the warnigns
# next to the node's name in the Scene viewer. In our case we return a warning 
# that the node needs at least 2 Marker2D nodes as children to function.
# This is a more advanced topic and it only takes effect within the editor and has
# no impact on the actual game. It is good to properly set up our custom classes when 
# we are working on a big project, though this may be a bit extreme.
# Depends on your workflow.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if list_of_marker_nodes.size() < 2:
		warnings.append("This node needs at least 2 Marker2D nodes to function properly.")
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	child_entered_tree.connect(_on_child_entered_tree)
	
	# Engine.is_editor_hint() returns true only if this script is currently running
	# in the editor. This way we can run different code depending on if we are in
	# the editor or if we are in the game. In our case if we are in the editor then
	# we set the parent node if it hasn't been set yet. Otherwise we advance to the
	# next point to start the movement.
	if Engine.is_editor_hint():
		if not parent:
			parent = get_parent()
		_make_positions_list()
	else:
		_make_positions_list()
		if list_of_marker_nodes.size() >= 2 and parent:
			_advance()

## Generates the list of positions to move through. Clears the
## [member list_of_marker_nodes] array and then it populates it with all the direct
## children that are [Marker2D].
func _make_positions_list() -> void:
	list_of_marker_nodes.clear()
	for child in get_children():
		if child is Marker2D:
			list_of_marker_nodes.append(child)

## Selects the next point to move to.[br][br]
## If [member bounce_mode] is set to [constant CYCLE] then [member curr_position_in_array]
## always advances by [code]1[/code].[br][br]When [member curr_position_in_array] is set to
## [code]list_of_marker_nodes.size()[/code] and thus it has reached the array's end,
## [member curr_position_in_array] will be set to [code]0[/code] so that the [member parent] cycles
## by moving to the original position.[br][br]
##
## If [member bounce_mode] is set to [constant PING_PONG] then when
## [member moving_forward] is set to [code]true[/code] [member curr_position_in_array]
## will advance by [code]1[/code]. Otherwise it is decreased by [code]1[/code].[br][br]
##
## When [member moving_forward] is set to [code]true[/code] and
## [member curr_position_in_array] is set to
## [code]list_of_marker_nodes.size()[/code] then [member curr_position_in_array] will
## be set to [code]list_of_marker_nodes.size() - 2[/code] and [member moving_forward]
## will be set to [code]false[/code] so that the [member parent] starts moving backwards
## and ping pongs through the positions.[br][br]
##
## When [member moving_forward] is set to [code]false[/code] and
## [member curr_position_in_array] is set to [code]0[/code] then [member curr_position_in_array] will
## be set to [code]1[/code] and [member moving_forward] will be set to [code]true[/code]
## so that the [member parent] starts moving forward.
func _advance() -> void:
	
	# The match keyword works similar to the switch case statement in C. The syntax is:
	# match <member>:
	#	<value>:
	# where <member> is the variable that we are checking and <value> is the value that
	# we check if is the same to <member>'s value. Unlike if, match can only compare
	# constant values. This is the same as doing:
	# if <member> == <value>:
	# The performance gain is minimal so it is generally used to improve code
	# readability. Using one over the other is a matter of personal preference.
	
	match bounce_mode:
		BOUNCE_MODES.CYCLE:
			curr_position_in_array += 1
			if curr_position_in_array == list_of_marker_nodes.size():
				curr_position_in_array = 0
		BOUNCE_MODES.PING_PONG:
			if moving_forward:
				curr_position_in_array += 1
				if curr_position_in_array == list_of_marker_nodes.size():
					curr_position_in_array = list_of_marker_nodes.size() - 2
					moving_forward = false
			else:
				curr_position_in_array -= 1
				if curr_position_in_array == -1:
					curr_position_in_array = 1
					moving_forward = true
	_move_to_point(list_of_marker_nodes[curr_position_in_array].position)

## Moves to the [member parent] by changing its local [param position] to [param next]
## using a [Tween]. It takes [member time_to_reach_point] to get from it's current
## position to [param next]. After the tween is finished if
## [member wait_time_between_movement] is greater than 0.0 it creates a [SceneTreeTimer]
## and waits for that long.
func _move_to_point(next: Vector2) -> void:
	
	# A Tween is a special class that can only be instanciated with code, meaning it does
	# not exist to be added in the scene tree like any other node (though it used to be
	# a node in previous versions of Godot). It is used to interpolate the value of a
	# variable of an object to another value over the period of real time. To create a 
	# tween we call the create_tween function and store the returned Tween to a variable.
	var tween = create_tween()
	# We set the tween ease and transition type to make the movement smoother.
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	# The syntax to tween the property goes as follows:
	# From the tween we access its tween_property function which takes 4 parameters.
	# 1: The Object that we want to tween its property.
	# 2: The property of the Object that we want to interpolate to.
	# 3: The new value of the property.
	# 4: The real time in seconds it takes to interpolate to the new value.
	tween.tween_property(parent, "position", next, time_to_reach_point)
	# The await keyword "waits" until the following function is finished or the signal
	# is emitted. In our case we wait until the tween finishes, which we know from the 
	# finished signal, and then we continue to the code bellow.
	await tween.finished
	if wait_time_between_movement > 0.0:
		# Similar to how we created a tween with code we can also create a timer with
		# code. Just in this case the create_timer method is a function in the
		# SceneTree class instead of the Node class. With:
		# get_tree().create_timer(<wait_time>)
		# we create a timer that lasts <wait_time> seconds, autostarts, and is destroyed
		# once it finishes (unless we keep a reference to it by storring the result in
		# a variable). We take this timer and access its timeout signal, then using the
		# await keyword again we can wait until that signal is emitted and thus the
		# timer has finished.
		await get_tree().create_timer(wait_time_between_movement).timeout
	_advance()

# These two functions handle the entering and exiting of child nodes. They are used
# to update the list of marker nodes so that the warning is updated. Like I said this
# is a more advanced topic and doesn't impact the game itself, only the editor behavior.

## Listens to the [signal Node.child_entered_tree] signal. When a child is added to the
## tree its [signal Node.tree_exited] is connected to [method _on_child_exited_tree]
## and the positions list is updated by calling [method _make_positions_list].
func _on_child_entered_tree(node: Node) -> void:
	if not node.tree_exited.is_connected(_on_child_exited_tree):
		node.tree_exited.connect(_on_child_exited_tree.bind(node))
	_make_positions_list()

## Listens to the [signal Node.tree_exited] signal emitted by each child of this node.
func _on_child_exited_tree(_node: Node) -> void:
	_make_positions_list()
