## A 3D bullet scene that moves and attacks
##
## A scene that represents a bullet in 3D space. It moves in a direction at a steady
## speed and attacks other [Hurtbox3D]s.
class_name Bullet3D
extends Node3D


## The Bullet3D scene preloaded.
const BULLET_3D = preload("uid://ng6cpextk2wi")


## The direction in 3D space that the bullet is moving towards. It is always normalised.
@export var direction: Vector3:
	set(value):
		direction = value.normalized()
		rotation = direction
		if is_node_ready():
			_cpu_particles_3d.gravity = -direction * 6.0
			_cpu_particles_3d.direction = -direction
## The speed at which the bullet is moving at.
@export var speed: float

@onready var _cpu_particles_3d: CPUParticles3D = $CPUParticles3D


func _ready() -> void:
	direction = direction.normalized()
	_cpu_particles_3d.gravity = -direction * 6.0
	_cpu_particles_3d.direction = -direction


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


# A static function is a function that can be called without having an instance of
# that object. In this case we use it to bundle all the bullet initialization
# within the bullet class script itself, instead of doing it in the script that 
# instaniates the new bullet.

## Creates and returns a new instance of a bullet initialized with a spawn
## [member Node3D.position], a [member direction], and a [member speed].
static func create_bullet(pos: Vector3, dir: Vector3, spd: float) -> Bullet3D:
	var new_bullet: Bullet3D = BULLET_3D.instantiate()
	new_bullet.position = pos
	new_bullet.direction = dir
	new_bullet.speed = spd
	return new_bullet


# ************************************************
