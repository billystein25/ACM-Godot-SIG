## A simple container to implement a health system for bodies.
##
## An implementation of a health system. Has support both for traditional 
@tool
class_name HealthComponent
extends Node


## Emitted when the body's [member current_health] reaches [code]0[/code] or when the body's
## [memebr current_hits] reaches [code]0[/code]. If the cause of death is both then this signal
## will be emitted twice, once for health and once for hits.
signal died(from: StringName)
## Emitted when the body's [member current_health] reaches [code]0[/code].
signal health_reached_0
## Emitted when the body's when the body's [memebr current_hits] reaches [code]0[/code].
signal hits_reached_0


## The flags that specify when the body can be revived.
enum UsageFlags{
	## This component will track the body's health as a float number.
	HEALTH = 1<<0,
	## This component will track the times the body has gotten hit.
	HITS = 1<<1
}


## The maximum raw health that the body can withstand. Only used when [member usage_flags] includes
## [constant UsageFlags.HEALTH].
var max_health: float = 100.0:
	set(value):
		max_health = maxf(0.0, value)
		if max_health < current_health:
			current_health = max_health
## The current health points of the body. Only used when [member usage_flags] includes
## [constant UsageFlags.HEALTH].
@onready var current_health: float = max_health:
	set(value):
		current_health = clampf(value, 0.0, max_health)
		if current_health == 0.0 and not _dead:
			health_reached_0.emit()
			died.emit(&"Health")
			_dead = true
## The maximum number of individual hits that the body can withstand. Only used when
## [member usage_flags] includes [constant UsageFlags.HITS].
var max_hits: int = 10:
	set(value):
		max_hits = maxi(0, value)
		if max_hits < current_hits:
			current_hits = max_hits
## The current number of inidividual hits remaining before the body is considered dead. Only used
## when [member usage_flags] includes [constant UsageFlags.HITS].
@onready var current_hits: int = max_hits:
	set(value):
		current_health = clampi(value, 0, max_hits)
		if current_health == 0 and not _dead:
			hits_reached_0.emit()
			died.emit(&"Hits")
			_dead = true
## The chosen flags that specify when the body can be revived. All of these flags have to be true
## for the body to be allowed to be revived by healing. [member revive] bypasses this requirement.
@export_flags("Health", "Hits") var usage_flags: int = UsageFlags.HEALTH:
	set(value):
		usage_flags = value
		notify_property_list_changed()

var _dead := false


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary]
	if usage_flags & UsageFlags.HEALTH > 0:
		properties.append({
			"name": "max_health",
			"class_name": "",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	if usage_flags & UsageFlags.HITS > 0:
		properties.append({
			"name": "max_hits",
			"class_name": "",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	return properties


func _property_can_revert(property: StringName) -> bool:
	match property:
		&"max_health":
			return true
		&"max_hits":
			return true
		_:
			return false


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"max_health":
			return 100.0
		&"max_hits":
			return 10
		_:
			return null


## Returns [code]True[/code] if health is being used regardless of if hits is being used.
func is_health_tracked() -> bool:
	return usage_flags & UsageFlags.HEALTH > 0.0


## Returns [code]True[/code] if hits is being used regardless of if health is being used.
func is_hits_tracked() -> bool:
	return usage_flags & UsageFlags.HITS > 0


## Damage the body by [param damage] health points and reduce [member current_hits] by
## [code]1[/code].[br][br]
## If overide_dead is [code]True[/code] then the body can be damaged further even if it is already
## dead.
func get_damaged(damage: float, overide_dead := false) -> void:
	if not overide_dead and _dead: return
	if is_health_tracked():
		current_health -= damage
	if is_hits_tracked():
		current_hits -= 1


## Heal the body by [param damage] health points and increase [member current_hits] by
## [param hits].[br][br]
## If overide_dead is [code]True[/code] then the body can be healed even if it is already
## dead. This could potentially lead to a revive.
func get_healed(health: float, hits: int, overide_dead := false) -> void:
	if not overide_dead and _dead: return
	if is_health_tracked():
		current_health += health
	if is_hits_tracked():
		current_hits += hits
	# if health is tracked and health > 0.0 -> revive
	if usage_flags == UsageFlags.HEALTH and current_health > 0.0:
		_dead = false
	# if only hits is tracked and hits > 0 -> revive
	if usage_flags == UsageFlags.HITS and current_hits > 0:
		_dead = false
	# if both health and hits are tracked and both are sufficient -> revive
	if (
		is_health_tracked() and is_hits_tracked()
		and current_health > 0.0 and current_hits > 0
	):
		_dead = false
	


## Revives the body at [param health] [member current_health] and [param hits] [current_hits].
func revive(health: float = max_health, hits: int = max_hits) -> void:
	_dead = false
	if is_health_tracked():
		current_health = health
	if is_hits_tracked():
		current_hits = hits

# *************************
