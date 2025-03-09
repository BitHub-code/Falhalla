extends Node2D

@export var speed := 300.0
var damage := 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN * delta * speed
	if global_position.y > 2000.0:
		queue_free()
