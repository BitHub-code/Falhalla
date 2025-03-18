extends Area2D

@export var damage := 5.0
@export var speed := 50.0
@export var expiration_time := 10.0
@export var homing := true
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var og_parent:CharacterBody2D
var direction := Vector2.RIGHT
var timer := 0.0
var target:CharacterBody2D
var target_pos := Vector2.ZERO:
	set(vector):
		if vector != Vector2.ZERO: modulate = Color.DARK_GRAY
		else: modulate = Color.WHITE
		target_pos = vector

func _ready() -> void:
	pass
	


# Growth period, speed per size?, chasing player, stops/slows on being hit
func _process(delta: float) -> void:
	if homing:
		if target_pos != Vector2.ZERO:
			direction = global_position.direction_to(target_pos)
			global_position += direction * delta * speed
			if global_position.distance_to(target_pos) < 4.0: target_pos = Vector2.ZERO
		elif target:
			global_position = global_position.lerp(target.global_position, 1.0 * delta) 
			if global_position.distance_to(target.global_position) < 70.0:
				target_pos = target.global_position
		else:
			direction = Vector2.RIGHT
			global_position += direction * delta * speed
	
	timer += delta
	if timer > expiration_time:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == og_parent: return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body.has_method("getting_hit"):
		body.getting_hit(damage)
		queue_free()
	


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("getting_hit"):
		area.getting_hit(damage)
		queue_free()
