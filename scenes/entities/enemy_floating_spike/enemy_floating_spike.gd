class_name EnemyFloatingSpike
extends Area2D

# We can define our own signals like this. Inside the parenthesis we set any attributes
# that we want to pass with the signal. Similar to how the body_entered signal from
# Area2D passes the body that entered the area.
signal hit_player(me: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	# We can emit any signal of this class like this. For the attributes of the emit()
	# function we pass how many attributes the signal needs to pass. In our case we
	# have one attribute: 'me' of type Node2D.
	hit_player.emit(self)
