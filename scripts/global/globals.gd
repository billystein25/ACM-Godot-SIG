extends Node


## A reference to the [Player3D] to be used by other nodes for targeting.
var player_node: Player3D

## The list of active [Bullet3D]s. Bullets that are already active and shown
## in the scene.
var active_bullets: Array[Bullet3D]
## The list of inactive [Bullet3D]s. Bullets that have been deactivated and are
## hidden from the scene but still exist in it to implement object pulling.
var inactive_bullets: Array[Bullet3D]


## Requests a new [Bullet3D] to be spawned. Uses a bullet from
## [member inactive_bullets] in a LIFO order. If the list is empty then it
## creates a new one. If a new bullet is created then it is added as a child of
## [param parent].
func request_bullet(pos: Vector3, dir: Vector3, spd: float, parent: Node) -> void:
	if inactive_bullets.size() > 0:
		var new_bullet: Bullet3D = inactive_bullets.pop_back()
		active_bullets.append(new_bullet)
		new_bullet.activate(pos, dir, spd)
	else:
		var new_bullet: Bullet3D = Bullet3D.create_bullet(pos, dir, spd)
		active_bullets.append(new_bullet)
		parent.add_child(new_bullet)


## Deactivates [param bullet] and removes it from [member active_bullets].
func request_deactivate_bullet(bullet: Bullet3D) -> void:
	var id: int = active_bullets.find(bullet)
	if id == -1:
		push_error("Bullet '%s' is not in active_bullets array" % str(bullet))
		return
	var active_bullet: Bullet3D = active_bullets.pop_at(id)
	active_bullet.deactivate()
	inactive_bullets.append(active_bullet)

# ********************
