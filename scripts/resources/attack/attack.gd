## A custom resource used for handling attack data.
##
## A custom resource that is used by [ActiveHitbox3D], [Hurtbox3D], and [HealthComponent]
## for handling attack data.
class_name Attack
extends Resource

## The damage that is dealt to the body that got hit.
@export var damage: float = 10.0
