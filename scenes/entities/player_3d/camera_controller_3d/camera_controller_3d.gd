## A Controller for handling camera movement.
##
## An extention of [SpringArm3D] with a [Camera3D] as a child that handles the 
## camera movement as it is controlled by the player. It supports mouse and
## controller input.
class_name CameraController3D
extends SpringArm3D


## The different focused input states that the camera controller can be in depending on the input.
enum InputState {
	## The input is disabled. The camera controller should not respond to any input.
	UNFOCUSED,
	## The focused input method is the mouse. 
	MOUSE,
	## The focused input method is the joypad.
	JOYPAD,
}


## The maximum vertical rotation that the camera can have in degrees.
@export var max_v_rotation_deg: float = 90.0:
	set(value):
		max_v_rotation_deg = value
		max_v_rotation_rad = deg_to_rad(value)
## The maximum vertical rotation that the camera can have in radians.
var max_v_rotation_rad: float = deg_to_rad(max_v_rotation_deg)
## The minimum vertical rotation that the camera can have in degrees.
@export var min_v_rotation_deg: float = -90.0:
	set(value):
		min_v_rotation_deg = value
		min_v_rotation_rad = deg_to_rad(value)
## The minimum vertical rotation that the camera can have in radians.
var min_v_rotation_rad: float = deg_to_rad(min_v_rotation_deg)
@export_group("Mouse Settings")
## The horizontal rotation speed of the camera when using a mouse. AKA the rotation speed on the local Y axis (left or right).
@export var mouse_h_rotation_speed: float = 1.0
## The vertical rotation speed of the camera when using a mouse. AKA the rotation speed on the local X axis (up or down).
@export var mouse_v_rotation_speed: float = 1.0
## If [code]True[/code] the horizontal rotation when using a mouse is inverted.
@export var invert_mouse_h_rotation: bool = false
## If [code]True[/code] the vertical rotation when using a mouse is inverted.
@export var invert_mouse_v_rotation: bool = false
@export_group("Joypad Settings")
## The horizontal rotation speed of the camera when using a joypad. AKA the rotation speed on the local Y axis (left or right).
@export var joy_h_rotation_speed: float = 1.0
## The vertical rotation speed of the camera when using a joypad. AKA the rotation speed on the local X axis (up or down).
@export var joy_v_rotation_speed: float = 1.0
## If [code]True[/code] the horizontal rotation when using a joypad is inverted.
@export var invert_joy_h_rotation: bool = false
## If [code]True[/code] the vertical rotation when using a joypad is inverted.
@export var invert_joy_v_rotation: bool = false
@export_group("Node References")
## The main camera.
@export var camera: Camera3D

## The currently selected [enum InputState].
var input_state: InputState = InputState.MOUSE


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and input_state == InputState.MOUSE:
		_rotate_from_vector(Vector2(
			event.relative.x * mouse_h_rotation_speed * signf(float(invert_mouse_h_rotation) - 0.5),
			event.relative.y * mouse_v_rotation_speed * signf(float(invert_mouse_v_rotation) - 0.5)
		))
	if event is InputEventMouseButton or event is InputEventKey:
		input_state = InputState.MOUSE
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_state = InputState.JOYPAD
	


func _process(delta: float) -> void:
	
	if input_state == InputState.JOYPAD:
		var joy_dir := Input.get_vector("Camera3DPanLeft", "Camera3DPanRight", "Camera3DPanDown", "Camera3DPanUp")
		_rotate_from_vector(Vector2(
			joy_dir.x * joy_h_rotation_speed * signf(float(invert_joy_h_rotation) - 0.5),
			-joy_dir.y * joy_v_rotation_speed * signf(float(invert_joy_v_rotation) - 0.5)
		) * delta)


# Rotates the camera controller depending on the vector v.
func _rotate_from_vector(v: Vector2) -> void:
	if v.length() == 0.0: return
	if input_state == InputState.UNFOCUSED: return
	
	rotation += Vector3(v.y, v.x, 0.0)
	rotation.x = clampf(rotation.x, min_v_rotation_rad, max_v_rotation_rad)


# *****************************************************
