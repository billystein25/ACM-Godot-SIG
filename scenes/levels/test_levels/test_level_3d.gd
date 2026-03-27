extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# To create a new bullet we just call the static function that initialises and
	# instantiates a new bullet 3d scene.
	var new_bullet := Bullet3D.create_bullet(Vector3(0.0, 2.0, 0.0), Vector3(0.0, 0.0, 1.0), 2.0)
	add_child(new_bullet)

# ************************************
