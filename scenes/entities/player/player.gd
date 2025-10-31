class_name Player
extends CharacterBody2D

@export var max_speed : float = 10.0
@export var jump_power : float = 10.0
@export var acceleration : float = 10.0
@export var active_upward_gravity : float = 10.0
@export var neutral_upward_gravity : float = 10.0
@export var downward_gravity : float = 10.0

@onready var skin: Sprite2D = $PlayerSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer

var just_left_floor := true
var can_jump := false

func _ready() -> void:
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)

func _physics_process(delta: float) -> void:
	
	_handle_jump(delta)
	_handle_movement(delta)
	
	_handle_sprite()
	
	move_and_slide()
	

func _handle_jump(delta) -> void:
	
	if Input.is_action_just_pressed("PlayerJump") and can_jump:
		velocity.y = -jump_power
	
	if not is_on_floor():
		
		if just_left_floor:
			just_left_floor = false
			coyote_timer.start()
		
		if velocity.y <= 0.0:
			if Input.is_action_pressed("PlayerJump"):
				velocity.y += active_upward_gravity * delta
			else:
				velocity.y += neutral_upward_gravity * delta
		else:
			velocity.y += downward_gravity * delta
	else:
		can_jump = true
		just_left_floor = true
		coyote_timer.stop()


func _handle_movement(delta: float) -> void:
	var dir : float = Input.get_axis("PlayerMoveLeft", "PlayerMoveRight")
	var target_vel_x : float = move_toward(velocity.x, max_speed * dir, acceleration * delta)
	
	velocity.x = target_vel_x
	

func _handle_sprite() -> void:
	if velocity.x > 0.0:
		skin.flip_h = false
	elif velocity.x < 0.0:
		skin.flip_h = true
	
	if is_on_floor():
		if velocity.length() == 0.0:
			animation_player.play("idle")
		else:
			animation_player.play("run")
	else:
		animation_player.play("jump")
	

func _on_coyote_timer_timeout() -> void:
	can_jump = false
