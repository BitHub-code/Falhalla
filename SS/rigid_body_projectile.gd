extends RigidBody2D

@export var damage := 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.y > 2000.0:
		queue_free()
		


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("getting_hit"):
		body.getting_hit(damage)
		queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.has_method("getting_hit"):
		area.getting_hit(damage)
		queue_free()
