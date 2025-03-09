extends RigidBody2D

@export var damage := 10.0
var impulse_force: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if impulse_force:
		apply_central_impulse(impulse_force)
		#apply_impulse(impulse_force, Vector2.ZERO)
		#apply_torque_impulse()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation, linear_velocity.angle(), 0.4)
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
