extends Node3D

@export_group("Node References")
@export var spawners: Node3D
@export var bullets: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for child in spawners.get_children():
		if child is BulletSpawner3D:
			child.shoot_bullet.connect(
				func(pos: Vector3, dir: Vector3, spd: float):
					Globals.request_bullet(pos, dir, spd, bullets)
			)

# ************************************
