extends Node2D

@onready var death_plane: Area2D = $DeathPlane

func _ready() -> void:
	death_plane.body_entered.connect(_on_player_entered_death_plane)

func _on_player_entered_death_plane(_body: Node2D) -> void:
	get_tree().reload_current_scene.call_deferred()
