extends Sprite2D

@export var marker:Marker2D





func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	
	if (marker.global_position - global_position).length() > 12.0:
		global_position = lerp(global_position, marker.global_position, 0.1)
	#tween might be better
