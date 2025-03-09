extends Area2D

@export var expiration_time := 4.0
@export var intox_levels := 50.0 #while inside how much would get intoxicated per second (started with 50~100 max_intoxication)
var timer := 0.0


func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	timer += delta
	if timer > expiration_time:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	body.self_intox += intox_levels


func _on_body_exited(body: Node2D) -> void:
	body.self_intox -= intox_levels
