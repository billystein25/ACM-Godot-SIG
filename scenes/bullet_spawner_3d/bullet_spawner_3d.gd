class_name BulletSpawner3D
extends Node3D

signal shoot_bullet(pos: Vector3, dir: Vector3, spd: float)

@export var interval: float = 1.0
@export_group("Bullet Data")
@export var speed: float = 1.0
@export_group("Node References")
@export var interval_timer: Timer
@export var marker_3d: Marker3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interval_timer.timeout.connect(
		func():
			shoot_bullet.emit(position, (marker_3d.global_position - global_position).normalized(), speed)
	)
	interval_timer.wait_time = interval
	interval_timer.start()

# ********************
