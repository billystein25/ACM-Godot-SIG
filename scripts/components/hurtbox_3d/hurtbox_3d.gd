## An extention of [Area3D] that acts as a hurtbox.
class_name Hurtbox3D
extends Area3D


## The [HealthComponent] that is attached to this hurtbox. When this hurtbox is
## attacked it will call that component's [method HealthComponent.get_damaged] method.
@export var health_component: HealthComponent
@export_group("Node References")
## A reference to the root entity that this hurtbox is attached to. It is used by
## [HandledHitbox3D]. See [member HandledHitbox3D.monitor_bodies_only].
@export var parent: Node3D


## This method is called when [Hitbox3D]s collide with this node
func get_hit(attack: float) -> void:
	if not health_component: return
	health_component.get_damaged(attack)
