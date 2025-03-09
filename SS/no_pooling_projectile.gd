extends Area2D

var damage := 5.0


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("getting_hit"):
		body.getting_hit(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("getting_hit"):
		area.getting_hit(damage)
		queue_free()
