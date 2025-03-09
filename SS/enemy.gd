extends CharacterBody2D

@onready var projectile := preload("res://SS/area_projectile.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var asp_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var player:CharacterBody2D
@export var speed := 80.0
@export var hp := 10.0
@export var intoxication := 50.0 #max_intox, at 0 drunk, at -max becomes a falling corpse that takes on bullets and can hit enemies

var self_intox := 0.0
var timer := 0.0
var drunk := false
var dying := false
var target_loc: Vector2

func _physics_process(delta: float) -> void:
	if dying: return
	intoxication -= self_intox*delta
	if intoxication < 0.0 and !drunk:
		drunk = true
		$Wasted_VFX.visible = true
		#accepts enemies bullets, or bumps into others? basically gets clumsy and not very helpful to its allies
	var direction:Vector2
	if player:
		direction = global_position.direction_to(player.global_position)
	else:
		if !target_loc: pick_random_tl()
		direction = ((target_loc) - global_position) 
		if direction.length() < 20.0: pick_random_tl()
		direction = direction.normalized()
		
		
	
	if direction:
		velocity = direction * speed
		if drunk: velocity.rotated(randf())
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.2)
	
	move_and_slide()
	
	timer += delta


func _on_attack_timer_timeout() -> void:
	pass
	#var new_proj = projectile.instantiate()
	#new_proj.direction = Vector2.RIGHT.rotated(timer)
	#new_proj.global_position = global_position
	#add_child(new_proj)
	
		
func getting_hit(amount:float) -> void:
	hp -= amount
	if hp < 0.001:
		defeated()

func defeated() -> void:
	dying = true
	asp_2d.play()
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

func drink(amount: float) -> void:
	intoxication -= amount

func pick_random_tl() -> void:
	target_loc = Vector2(randf_range(20.0, get_window().size.x - 40.0), randf_range(20.0, get_window().size.y - 40.0)) * 0.25
