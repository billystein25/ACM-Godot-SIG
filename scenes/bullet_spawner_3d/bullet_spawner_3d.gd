class_name BulletSpawner3D
extends Marker3D

signal shoot_bullet(pos: Vector3, dir: Vector3, spd: float)

@export_group("Bullet Data")
@export var speed: float
@export_group("Node References")
@export var interval: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interval.timeout.connect(
		func():
			shoot_bullet.emit(position, rotation, speed)
	)

# ********************
