# Double comments ## allow the programer to set custom documentation for their own 
# classes, methods, etc. Godot automatically adds these entries to the build in
# documentation which you can access with the Search Help button at the top
# right of this docker window. By holding Ctrol/Command and left clicking on any 
# variable/member, function/method, signal, or Class Godot will take you to the
# respective member's documentation.

## The Player Character Controller. Implements variable jump, coyote time, and
## horizontal acceleration and deceleration
class_name Player
# We extend CharacyerBody2D which gives us build in functions and methods such as
# collision detection and movement functions.
extends CharacterBody2D

# With @export_group we can create groups in the editor to better organise our variables
# In this first group we store references to the nodes we want to use, connect their
# signals, call their functions, access their members, etc.
@export_group("Node References")
## The [Player]'s sprite.
@export var skin: Sprite2D
## The animation player node for the [Player].
@export var animation_player: AnimationPlayer
## The timer node used to implement coyote time. The [Player] will stil be able to jump
## [member coyote_timer.wait_time] seconds after leaving the ground.
@export var coyote_timer: Timer

## Used so that in [method Player._handle_jump] [member coyote_timer] is only started once.
var just_left_floor := true
## The condition that allows the player to jump. Is set to [code]false[/code] after
## [member coyote_timer.wait_time] seconds have passed. Is set to [code]true[/code]
## when touching the ground.
var can_jump := false

# In general @export allows a variable to be modifiable from the editor. That way we
# can fine-tune variables more easily without having to change the code every time.
@export_group("Movement")
## The maximum horizontal speed of the [Player].
@export var max_speed : float = 10.0
## The jump power of the [Player].
@export var jump_power : float = 10.0
## The horizontal acceleration of the [Player].
@export var acceleration : float = 10.0
## The horizontal deceleration of the [Player].
@export var deceleration : float = 10.0

# implemenation of variable jump
## The gravity exerted on the [Player] when they are holding the jump button and
## moving upwards. Should be lower than [member neutral_upward_gravity].
@export var active_upward_gravity : float = 10.0
## The gravity exerted on the [Player] when they are not holding the jump button and 
## moving upwards. Should be higher than [member active_upward_gravity].
@export var neutral_upward_gravity : float = 10.0
## The gravity exerted on the [Player] when they are falling.
@export var downward_gravity : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# coyote_timer is of type Timer. Meaning it has built in variables functions and signals.
	# We use the timeout signal which is emited when the timer has reached its wait_time.
	# We connect that signal to our function that we call _on_coyote_timer_timeout.
	# Select the Timer from the Scene tree on the left and check its attributes on the right.
	# At the top navigate to 'Node' and check the built in signals of this Node.
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Note that the game will pause until this frame is drawn, so we should be really
# careful for infinite loops and expensive functions.
# It is called every frame that is rendered. By default Godot has no frame cap and
# VSync On, so this will be called at your monitor's refresh rate. 
# You can change this behavior in the Project Settings/Display/Window/V-Sync Mode
# and Project Settings/Application/Run/max_fps
# Generally we want to keep everything visual (like sprites changing, camera movement etc)
# in _process, while everything physics (like movement and collision) stay in _physics_process.
func _process(_delta: float) -> void:
	
	# We simply call the _handle_sprite function
	_handle_skin()
	

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
# Unlike _process, this is called every physics frame which by default is set to 60 FPS.
# You can set this in Project Settings/Physics/Common/physics_ticks_per_second.
# Godot will attempt to keep a stable physics process to make physics operations more
# consistent. If your process time (delta) ends up being higher than your desired 
# physics process time then you need to optimize your code.
func _physics_process(delta: float) -> void:
	
	# We simply call the _handle_jump function which takes one argument 'delta'.
	_handle_jump(delta)
	_handle_movement(delta)
	
	# Call this function every physics frame to apply velocity. Uses the velocity
	# member/variable which is built in the CharacterBody2D Class.
	# If we don't want to slide or we want to detect what we collided with we instead
	# use move_and_collide. Note that move_and_slide automatically applies delta, 
	# where move_and_collide doesn't. So for proper frame independant movement we
	# would have to multiply velocity with delta when using move_and_collide
	move_and_slide()

## Handles the [Player]'s jump logic. Implements coyote time and variable jump height.
func _handle_jump(delta) -> void:
	
	# We check if the action PlayerJump is just pressed. Since _handle_jump is called
	# in _physics_process it is called every frame, and thus this block happens every frame.
	# Where Input.is_action_pressed checks if an action is pressed every frame, with
	# Input.is_action_just_pressed we only check for it on the first frame that it was pressed.
	# If can_jump is true then the playe ris allowed to jump. This is the same as writing:
	# if Input.is_action_just_pressed("PlayerJump") == true and can_jump == true:
	if Input.is_action_just_pressed("PlayerJump") and can_jump:
		velocity.y = -jump_power
	
	# One of the default functions/methods of CharacterBody2D. 
	# Ctrl/Command + Left Click on this function for more info.
	if not is_on_floor():
		
		# We implement just_left_floor so that we start the coyote_timer only once.
		# We are essentially building our own is_action_just_pressed action, but 
		# instead of listening for an action, we check if we've left the floor.
		if just_left_floor:
			# Set just_left_floor to false.
			just_left_floor = false
			# Start the coyote timer. Why don't we need to reset the timer first?
			# Use Ctrl/Command + Left Click to check the description of the 
			# start method.
			coyote_timer.start()
		
		# If the player is moving upwards.
		# Remember that 'up' in 2D is negative y.
		if velocity.y <= 0.0:
			# Implementation of variable jump. The more you hold the Jump button,
			# the higher the player will reach.
			# We chech if the Jump button is being pressed and if it is apply
			# a weaker gravity.
			if Input.is_action_pressed("PlayerJump"):
				velocity.y += active_upward_gravity * delta
			else:
				velocity.y += neutral_upward_gravity * delta
		# If the player is falling apply a constant downward gravity.
		else:
			velocity.y += downward_gravity * delta
	
	# If the player is on the ground allow them to jump, reset just_left_floor
	# and stop the coyote timer. 
	else:
		can_jump = true
		just_left_floor = true
		coyote_timer.stop()

## Handles the [Player]'s horizontal movement. Implements acceleration
func _handle_movement(delta: float) -> void:
	
	# Set a variable as the input direction using the Input.get_axis function.
	var dir : float = Input.get_axis("PlayerMoveLeft", "PlayerMoveRight")
	var target_vel_x : float
	# If there is an input direction use the normal acceleration.
	if dir != 0.0:
		target_vel_x = move_toward(velocity.x, max_speed * dir, acceleration * delta)
	# Else decelerate to 0.0 at a slower rate.
	else:
		target_vel_x = move_toward(velocity.x, 0.0, deceleration * delta)
	
	# Set the built in velocity variable/member to target_vel_x.
	velocity.x = target_vel_x
	

## Handles the [member skin] animations.
func _handle_skin() -> void:
	# The sprite is built to face right.
	# So if we're moving to the right don't flip the sprite.
	if velocity.x > 0.0:
		skin.flip_h = false
	# If we're moving to the left flip the sprite.
	# Why didn't we use else?
	elif velocity.x < 0.0:
		skin.flip_h = true
	
	if is_on_floor():
		# If the player is grounded and isn't moving play the idle animation.
		if velocity.length() == 0.0:
			animation_player.play("idle")
		# If the player is grounded and is moving play the running animation.
		else:
			animation_player.play("run")
	# if the player isn't grounded play the jump animation.
	else:
		animation_player.play("jump")

## Listens to the [signal Timer.timeout] signal emited by the [member coyote_timer].
## When [member coyote_timer].wait_time has elapsed we disable the [Player]'s
## ability to jump by setting [member can_jump] to [code]false[/code].
func _on_coyote_timer_timeout() -> void:
	can_jump = false
