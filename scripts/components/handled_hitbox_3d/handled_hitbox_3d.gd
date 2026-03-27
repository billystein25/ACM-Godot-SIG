## A hitbox that keeps track of the [Hurtbox3D] objects it has hit and doesn't allow for repeated
## hits.
##
## A hitbox that keeps track of the [Hurtbox3D] objects it has hit in order to hit an object
## only once per activation. This solves the problem of hurtboxes entering and exiting the
## hitbox multiple times during an attack resulting in them being attacked multiple times.
class_name HandledHitbox3D
extends ActiveHitbox3D


## If [code]True[/code] then this hitbox will not attack the same body multiple times even if
## it hits multiple hurtboxes that are attached to the same body.[br][br]
## If [code]False[/code] then this hitbox will not attack the same hurtbox multiple times
## but it will attack different hurtboxes that are all attached to the same body.
@export var monitor_bodies_only := true


# the list of bodies that have been hit. If monitor_bodies_only is true and the parent of the
# hurtbox that got hit is in this list then it will not be attacked again.
var _bodies_hit: Array[Node3D]
# The list of hurtboxes that have been hit. If monitor_bodies_only is false and the hurtbox
# that got hit is in this list then it will not be attacked again.
var _hurtboxes_hit: Array[Hurtbox3D]


func _init() -> void:
	super()


## Starts the attack by enabling the hitbox. Should be followed by [method reset].
func shoot() -> void:
	enable()


## Ends the attack by disabling the hitbox and clearing the list of bodies it has hit. Should
## come after [method shoot].
func reset() -> void:
	disable()
	_hurtboxes_hit.clear()
	_bodies_hit.clear()


func _on_area_entered(area: Node3D) -> void:
	if area is Hurtbox3D:
		if monitor_bodies_only and area.parent in _bodies_hit: return
		elif not monitor_bodies_only and area in _hurtboxes_hit: return
		_hurtboxes_hit.append(area)
		if area.parent != null:
			_bodies_hit.append(area.parent)
		super(area)

# *********************************
