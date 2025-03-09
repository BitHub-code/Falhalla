extends RigidBody2D

@onready var booze_cloud := preload("res://SS/booze_area.tscn")
@onready var hit_shape: CollisionShape2D = $HitBox/HitShape
@onready var drink_shape: CollisionShape2D = $DrinkBox/DrinkShape


@export var damage := 50.0
@export var break_speed := 100.0
@export var initial_toruqe := 10.0
@export var impulse_force: Vector2
@export var unpicable_until := 0.1

var timer := 0.0

func _ready() -> void:
	if impulse_force:
		apply_central_impulse(impulse_force)
		#apply_impulse(impulse_force, Vector2.ZERO)
	if initial_toruqe:
		apply_torque_impulse(initial_toruqe)



func _physics_process(delta: float) -> void:
	#rotation = lerp_angle(rotation, linear_velocity.angle(), 0.4)
	timer += delta
	if global_position.y > 1000.0:
		queue_free()
		


func _on_hit_box_body_entered(body: Node2D) -> void:
	#print(str(snappedf(linear_velocity.length(), 0.1))  + str(linear_velocity) )
	
	if linear_velocity.length() < 120.0: 
		if timer > unpicable_until: 
			print("Implement picking up!" + str(body))
			#or maybe it needs to stay within proximity for a certain amount of time and then it's considered picked up
		return
	if body.has_method("getting_hit"):
		body.getting_hit(damage)
		#big splash of booze, area affecting all enemies inside
		var new_cloud = booze_cloud.instantiate()
		new_cloud.global_position = global_position
		get_parent().add_child(new_cloud)
		queue_free()


func _on_drink_box_area_entered(area: Area2D) -> void:
	
	if area.has_signal("drink"):
		area.emit_signal("drink")
	if area.get_parent().has_method("drink") and timer > 0.05:
		hit_shape.set_deferred("disabled", true)
		drink_shape.set_deferred("disabled", true)
		print("DRINKING SUCCESSFUL!!!")
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		#process_mode = Node.PROCESS_MODE_DISABLED
		area.get_parent().drink(damage*4.0)
		await get_tree().create_timer(0.3).timeout
		queue_free()
		
	""" 
	if area.has_method("getting_hit"): #call_deferred might be necessary, or sort out NPC death
		area.getting_hit(damage)
		var new_cloud = booze_cloud.instantiate()
		new_cloud.global_position = global_position
		get_parent().add_child(new_cloud)
		queue_free()
	"""
	
