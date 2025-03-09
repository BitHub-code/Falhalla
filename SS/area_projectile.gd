extends Area2D

@export var damage := 5.0
@export var speed := 50.0
@export var expiration_time := 10.0
@export var homing := false
@onready var sprite: Sprite2D = $Sprite

var og_parent:CharacterBody2D
var direction := Vector2.RIGHT
var timer := 0.0
var target_pos:Vector2:
	set(vector):
		target_pos = vector
		$Marker.global_position = target_pos

func _ready() -> void:
	if homing:
		sprite.frame = 844


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if homing:
		if target_pos or target_pos != Vector2.ZERO:
			direction = (target_pos - global_position)
			if direction.length() < 22.0:
				var new_target = get_parent().closest_target()
				if new_target:
					target_pos = new_target
				#pick new target
			else:
				direction = direction.normalized()
		else:
			direction = (get_global_mouse_position() - global_position).normalized()
		rotation = lerp_angle(rotation, direction.angle(), 0.145)
		direction = Vector2.RIGHT.rotated(rotation)
		
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
