extends Sprite2D

# export allows the variable to be modified in the editor
# without having to open the script
# var signifies a variable. then we set its type (not necessary
# similar to python, gdscript can dynamically adjust variables)
@export var speed: float = 10.0

# _process function runs every frame rendered (by default it is
# your monitor's refresh rate because V-sync is enabled)
# delta is the time elapsed since last frame was rendered
# -> void is what this function returns
func _process(delta: float) -> void:
	
	# create a variable with the direction we want to move of type Vector2
	# get_global_mouse_position() returns the true position of the mouse
	# global_position is the true position of this node
	var dir: Vector2 = get_global_mouse_position() - global_position
	# normalize the direction to a circle of length 1
	# that way we can multiply that vector with our speed
	dir = dir.normalized()
	# move the sprite
	global_position += dir * speed * delta
