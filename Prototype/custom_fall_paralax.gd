extends Node2D

@export var scrolling_speed := 5.0
var children_list: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	children_list = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in children_list:
		child.position.y -= delta * scrolling_speed * child.offset.y
		if child.position.y < - 1200.0:
			child.position.y += 1200.0
