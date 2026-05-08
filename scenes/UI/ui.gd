class_name UI
extends CanvasLayer

@export_group("Node References")
@export var health_bar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.ui_node = self


func set_health_bar_value(value: float) -> void:
	health_bar.value = value

# ********************
