class_name EnemyFloatingSpike
extends Area2D

signal hit_player(me: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	hit_player.emit(self)
