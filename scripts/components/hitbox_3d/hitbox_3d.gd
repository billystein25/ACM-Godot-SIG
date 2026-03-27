## A generic implementation of a hitbox.
##
## A generic hitbox in 3D space that can be either active or disabled. While it is active
## it will listen for [Hurtbox3D] objects that enter it and call their [method Hurtbox3D.get_hit].
## method.
class_name ActiveHitbox3D
extends Area3D


## The data that will be passed to the [Hurtbox3D] that was attacked.
@export var attack: float


# If [code]True[/code] then this hitbox is active and therefore it will listen for [Hurtbox3D]
# objects that enter it.
var _is_active := true


func _init() -> void:
	area_entered.connect(_on_area_entered)


## Enables the hitbox.
func enable() -> void:
	_is_active = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)


## Disables the hitbox.
func disable() -> void:
	_is_active = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)


## Returns whether or not this hitbox is currently active.
func is_active() -> bool:
	return _is_active


func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox3D and attack:
		area.get_hit(attack)

# ***********************************
