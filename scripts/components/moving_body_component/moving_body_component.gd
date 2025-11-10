@tool
class_name MovingBodyComponent
extends Node

enum BOUNCE_MODES {CYCLE, PING_PONG}
@export var parent : Node2D
@export var bounce_mode : BOUNCE_MODES
@export var time_to_reach_point : float = 2.0
@export var wait_time_between_movement : float = 5.0

var list_of_marker_positions : Array[Vector2]:
	set(value):
		list_of_marker_positions = value
		_get_configuration_warnings()

var curr_position_in_array : int = 0
var moving_forward := true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if list_of_marker_positions.size() < 2:
		warnings.append("This node needs at least 2 Marker2D nodes to function properly.")
	return warnings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	child_entered_tree.connect(_on_child_entered_tree)
	
	if Engine.is_editor_hint():
		if not parent:
			parent = get_parent()
		_make_positions_list()
	else:
		_make_positions_list()
		if list_of_marker_positions.size() >= 2 and parent:
			_advance()

func _make_positions_list() -> void:
	list_of_marker_positions.clear()
	for child in get_children():
		if child is Marker2D:
			list_of_marker_positions.append(child.position)

func _advance() -> void:
	if bounce_mode == BOUNCE_MODES.CYCLE:
		curr_position_in_array += 1
		if curr_position_in_array == list_of_marker_positions.size():
			curr_position_in_array = 0
	else:
		if moving_forward:
			curr_position_in_array += 1
			if curr_position_in_array == list_of_marker_positions.size():
				curr_position_in_array -= 2
				moving_forward = false
		else:
			curr_position_in_array -= 1
			if curr_position_in_array == -1:
				curr_position_in_array += 2
				moving_forward = true
	_move_to_point(list_of_marker_positions[curr_position_in_array])

func _move_to_point(next: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(parent, "position", next, time_to_reach_point)
	await tween.finished
	if wait_time_between_movement > 0.0:
		await get_tree().create_timer(wait_time_between_movement).timeout
	_advance()

func _on_child_entered_tree(node: Node) -> void:
	if not node.tree_exited.is_connected(_on_child_exited_tree):
		node.tree_exited.connect(_on_child_exited_tree.bind(node))
	_make_positions_list()

func _on_child_exited_tree(_node: Node) -> void:
	_make_positions_list()
