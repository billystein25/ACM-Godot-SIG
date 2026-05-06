## The 3D Player Character Controller. Implements acceleration and deceleration.
class_name Player3D
extends CharacterBody3D


@export_group("Movement")
## The maximum speed that the player can accelerate to.
@export var max_speed: float = 1.0
## The rate at which the player accelerates from a [member CharacterBody3D.velocity] of [code]0.0[/code] to [member max_speed].
@export var acceleration: float = 1.0
## The rate at which the player decelerates from a [member CharacterBody3D.velocity] of [member max_speed] to [code]0.0[/code].
@export var deceleration: float = 1.0
## The force that is set to the [code]y[/code] property of [member CharacterBody3D.velocity] when the player jumps.
@export var jump_force: float = 1.0
## The gravity that is applied to this body while it is moving in the positive Y axis.
@export var upward_gravity: float = -9.8
## The gravity that is applied to this body while it is moving in the negative Y axis.
@export var downward_gravity: float = -9.8

@export_group("Attack")
## The 3D physics raycast collision mask when the player "shoots".
@export_flags_3d_physics var raycast_collision_mask: int = 1

@export_group("Visuals")
## The rate at which the [member skin] will rotate towards the moving direction
## according to [member CharacterBody3D.velocity].
@export var skin_rotation_rate: float = 1.0

@export_group("Node References")
## The root skin of the player. The model should face in the negative Z axis.
@export var skin: Node3D
## The camera controller for the camera that is attached to the player.
@export var camera_controller: CameraController3D
## The main camera that is attached to the player.
@onready var camera: Camera3D = camera_controller.camera
## A 2D representation of [member CharacterBody3D.velocity].
var velocity_2d: Vector2


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print(self)


func _process(delta: float) -> void:
	_handle_animations(delta)


func _physics_process(delta: float) -> void:
	velocity_2d = Vector2(velocity.x, velocity.z)
	_handle_movement(delta)
	_handle_attack()
	
	move_and_slide()


func _to_string() -> String:
	return str(name, ":<Player3D#", get_instance_id(), ">")


# all the logic for setting the velocity property 
func _handle_movement(delta: float) -> void:
	var input_vector := Input.get_vector("Player3DMoveLeft", "Player3DMoveRight", "Player3DMoveForward", "Player3DMoveBackward")
	var dir := input_vector.rotated(-camera.global_rotation.y)
	var target_velocity_2d := dir * max_speed
	var target_velocity := Vector3(target_velocity_2d.x, velocity.y, target_velocity_2d.y)
	
	# horizontal movement
	# acceleration
	if target_velocity.length() > Vector2(velocity.x, velocity.z).length():
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	# deceleration
	else:
		velocity = velocity.move_toward(target_velocity, deceleration * delta)
	
	# jump
	if is_on_floor():
		velocity.y = float(Input.is_action_just_pressed("Player3DJump")) * jump_force
	# gravity
	else:
		if velocity.y >= 0.0:
			velocity.y += upward_gravity * delta
		else:
			velocity.y += downward_gravity * delta


# all the logic for handling attacks
func _handle_attack() -> void:
	if Input.is_action_just_pressed("PlayerAttack"):
		var raycast_result := _shoot_raycast_from_viewport_center(0.0, 0.0, true, true, 100.0, raycast_collision_mask)
		print(raycast_result)


# Shoots a raycast from the center of the screen and returns the collision dictionary.
func _shoot_raycast_from_viewport_center(
	rand_y: float = 0.0, 
	rand_x: float = 0.0, 
	col_with_bodies := true, 
	col_with_areas := true, 
	max_range: float = 100.0,
	col_mask: int = 1,
) -> Dictionary:
	
	# get 3d physics space state
	var space_state : PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	# get the center of the visible viewport rectangle
	var screen_center : Vector2 = get_viewport().get_visible_rect().size / 2
	# get the origin of the raycast
	var origin : Vector3 = camera.project_ray_origin(screen_center)
	# get the direction the camera is looking at
	var camera_dir : Vector3 = camera.project_ray_normal(screen_center)
	# random spread 
	camera_dir = camera_dir.rotated(Vector3(1, 0, 0), randf_range(-rand_x, rand_x))
	camera_dir = camera_dir.rotated(Vector3(0, 1, 0), randf_range(-rand_y, rand_y))
	# get the end of the raycast via the max range
	var end : Vector3 = origin + camera_dir * max_range
	# create a raycast query
	var query := PhysicsRayQueryParameters3D.create(origin, end, col_mask)
	query.collide_with_bodies = col_with_bodies
	query.collide_with_areas = col_with_areas
	# return the collision result as a dictionary
	var result := space_state.intersect_ray(query)
	return result


# Handles the logic for animating the skin.
func _handle_animations(delta: float) -> void:
	if velocity_2d.length() > 0.0:
		# if a line of code is getting too long you can use \ to split it in the
		# line below. This is the same as writing:
		# skin.rotation.y = Vector2.from_angle(skin.rotation.y).move_toward(Vector2(velocity_2d.x, -velocity_2d.y).rotated(-PI/2), skin_rotation_rate * delta).angle()
		# in one line.
		skin.rotation.y = Vector2.from_angle(skin.rotation.y) \
			.move_toward(Vector2(velocity_2d.x, -velocity_2d.y) \
			.rotated(-PI/2), skin_rotation_rate * delta) \
			.angle()


# *************************************************
