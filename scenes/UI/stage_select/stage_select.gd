extends CanvasLayer

@onready var select_2d: Button = $VBoxContainer/Select2D
@onready var select_3d: Button = $VBoxContainer/Select3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select_2d.pressed.connect(
		func():
			get_tree().change_scene_to_file("uid://6ynyujr3dhsf")
	)
	select_3d.pressed.connect(
		func():
			get_tree().change_scene_to_file("uid://dbeqekyoti3gf")
	)
