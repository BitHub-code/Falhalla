extends CharacterBody2D

@onready var projectile := preload("res://SS/area_projectile.tscn")
@onready var attack_timer: Timer = $AttackTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var asp_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var player:CharacterBody2D
@export var speed := 50.0
@export var direction := Vector2.LEFT
@export var attack_speed := 1.0
@export var hp := 10.0
@export var intoxication := 100.0 #max_intox, at 0 drunk, at -max becomes a falling corpse that takes on bullets and can hit enemies

var drunk := false
var self_intox := 0.0
var timer := 0.0
var dying := false

func _ready() -> void:
	attack_timer.wait_time = attack_speed

func _physics_process(delta: float) -> void:
	if dying: return
	timer += delta
	if timer > 10.0:
		timer = 0.0
		direction *= -1
		
	intoxication -= self_intox*delta
	if intoxication < 0.0 and !drunk:
		drunk = true
		$Wasted_VFX.visible = true
	if direction:
		velocity = direction * speed
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.2)
	
	move_and_slide()
	
	


func _on_attack_timer_timeout() -> void:
	var new_proj = projectile.instantiate()
	new_proj.direction = Vector2.RIGHT.rotated(timer)
	new_proj.global_position = global_position
	new_proj.og_parent = self
	get_parent().add_child(new_proj)
	if drunk:
		var random_f = randf()
		if random_f > 0.7:
			new_proj.damage = -5.0
			new_proj.sprite.frame = 444
		elif random_f < 0.1:
			new_proj.queue_free()
		elif random_f < 0.4:
			new_proj.set_collision_mask_value(2, true)
			new_proj.sprite.frame = 739
	#if drunk: chance for healing shots? or no shots or shots that can hit other enemies

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
	
