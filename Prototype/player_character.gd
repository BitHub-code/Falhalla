extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throwing_knife := preload("res://SS/rigid_body_projectile.tscn")
@onready var arrow := preload("res://SS/rigid_body_projectile_arrow.tscn")
@onready var wind_proj := preload("res://SS/area_projectile_wind_player.tscn")
@onready var mead_group := preload("res://SS/group_projectiles_no_pooling.tscn")
@onready var mead_bottle := preload("res://SS/rigid_body_projectile_bottle.tscn")

@onready var weapon_icon: Sprite2D = $CanvasLayer/MarginContainer/VBoxContainer/Attack_types/TextureRect2/Obj2
@onready var health_bar: ProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/HealthBar
@onready var laa: CollisionShape2D = $Lightning_atk_area/CollisionShape2D
@onready var laa_upgraded: CollisionShape2D = $Lightning_atk_area/LAA_upgraded

@onready var defeat_sfx: AudioStreamPlayer = $Defeat_SFX

@export var max_intox := 0.0
@export var min_intox := -30.0
var intoxication := 0.0:
	set(f):
		intoxication = clampf(f, min_intox, max_intox)
		if intoxication < 0.0: drunk = true
		else: drunk = false
		$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer2/AlcoholBar.value = -intoxication
@export var max_hp := 100.0
var drunk := false:
	set(b):
		drunk = b
		if drunk: 
			modulate = Color.BROWN
			
		else: modulate = Color.WHITE
var damage := 5.0
var defeated := false:
	set(b):
		defeated = b
		#if defeated: $"../CanvasLayer/MainMenu".pause()
var targets_list:Array[CharacterBody2D] = []
var atk_speed := 0.5
var atk_timer := 0.0
var no_move_input:= false

var hp := 100.0:
	set(f):
		hp = f
		health_bar.value = hp

var atk_charge := 0.0
var current_atk :int = 0:
	set(i):
		current_atk = i
		
		match i:
			0: #drop knife
				weapon_icon.frame = 726
				damage = 15.0
				atk_speed = 0.5
			1: #lightning smash close range area - needs to be a hold & release with an indication circle!!!!
				weapon_icon.frame = 730
				damage = 30.0
			2: #wind atk
				weapon_icon.frame = 784
				atk_speed = 0.2
			3: #arrow shot with aim
				weapon_icon.frame = 1515
				damage = 10.0
				atk_speed = 0.6
			4: #auto aiming to closest enemy
				weapon_icon.frame = 844
				damage = 5.0
				atk_speed = 0.1
			5: #mead multishot down
				weapon_icon.frame = 1000
				damage = 5.0
				atk_speed = 0.05
			6: #mead bottle
				weapon_icon.frame = 271
				damage = 50.0
				atk_speed = 0.8

#@export_enum("knifes", "smash", "wind", "arrows") var atk_type :int


func _ready() -> void:
	hp = max_hp
	intoxication = max_intox

func _physics_process(delta: float) -> void:
	if defeated: return
	if intoxication < max_intox: intoxication += delta #* 5.0
	atk_timer += delta
	
	

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	if no_move_input:
		velocity.x = move_toward(velocity.x, 0, 10.0)
		velocity.y = move_toward(velocity.y, 0, 10.0)
	elif drunk:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, 10.0) 
		if direction.y > 0.0:
			#velocity.y = lerpf(velocity.y, direction.y * SPEED, 0.2)
			velocity.y = move_toward(velocity.y, direction.y * SPEED, 30.0)
			
		else:
			velocity.y = move_toward(velocity.y, direction.y * SPEED, 6.5)
		#drunk bonuses
		hp += delta * 0.2
	elif direction:
		velocity = direction * SPEED * 0.5
		
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, 10.0)
		velocity.y = move_toward(velocity.y, 0, 10.0)
	
	#extra movement effects
	if sprite.animation == "smash":
		pass
		#velocity.y += 30.0; problem with move_toward and adding velocity
	#print(velocity)
	#should falling be normalized? meaning on diagonal movement the speed is reduced compaired to a straight fall
	move_and_slide()
	
	#Animations
	if direction.x > 0.0:
		sprite.flip_h = true
		if sprite.animation == "falling": sprite.play("side_fall")
		elif sprite.animation == "flying": sprite.play("side_fly")
	elif direction.x <0.0:
		sprite.flip_h = false
		if sprite.animation == "falling": sprite.play("side_fall")
		elif sprite.animation == "flying": sprite.play("side_fly")
	else:
		if sprite.animation == "side_fall": sprite.play("falling")
		elif sprite.animation == "side_fly": sprite.play("flying")
		#for fall/fly transition = diagonal when switching fall/fly and moving sideways  
	
	if direction.y > 0.0 and (sprite.animation == "flying" or sprite.animation == "side_fly" or sprite.animation == "fall_to_fly"):
		#sprite.stop()
		sprite.play("fly_to_fall")
		$WindGust.visible = true
		await get_tree().create_timer(0.15).timeout
		$WindGust.visible = false
		await sprite.animation_finished
		sprite.play("falling")
		
	
	elif direction.y <= 0.0 and (sprite.animation == "falling" or sprite.animation == "side_fall" or sprite.animation == "fly_to_fall"):
		#sprite.stop()
		sprite.play("fall_to_fly")
		await sprite.animation_finished
		sprite.play("flying")
	
	if !sprite.is_playing(): sprite.play("flying")
	
	#Attacks
	if Input.is_action_just_released("shoot"):
		if current_atk == 1 and sprite.animation != "smash" and !$Impact_anim.is_playing():
			damage = (1.0 + atk_charge) * 30.0
			no_move_input = true
			
			var temp:CollisionShape2D
			if drunk: temp = laa_upgraded
			else: temp = laa
			temp.shape.radius = 50.0 * (1.0 + 3.0*atk_charge)
			sprite.play("smash")
			$VFX_lightning.play("default")
			await get_tree().create_timer(0.6).timeout
			$LightningA_VFX.visible = true
			$Impact_anim.play("default")
			temp.disabled = false
			await get_tree().create_timer(0.2).timeout
			$LightningA_VFX.visible = false
			temp.disabled = true
			
			atk_charge = 0.0
			queue_redraw()
			damage = 30.0
			await get_tree().create_timer(0.2).timeout
			no_move_input = false
	
	if Input.is_action_pressed("shoot"):
		if atk_timer > atk_speed:
			atk_timer = 0.0
			match current_atk:
				0:
					var new_proj = throwing_knife.instantiate()
					new_proj.global_position = global_position + Vector2(0.0, 18.0)
					add_child(new_proj)
				1:
					if sprite.animation != "smash" and !$Impact_anim.is_playing():
						if atk_charge < 0.2:
							atk_charge += delta #DOESN'T GET COUNTED EVERY FRAME
							if atk_charge > 0.2: atk_charge = 0.2
						print(atk_charge)
						queue_redraw()
				2:
					var new_proj = wind_proj.instantiate()
					new_proj.global_position = global_position
					if velocity.length() < 1.0:
						var r_number: float = randf()
						new_proj.direction = Vector2(1.0 - r_number, r_number).rotated(randfn(-PI, PI))
					else:
						new_proj.direction = velocity.normalized()
					#new_proj.speed = 300.0
					#look_at(get_global_mouse_position())
					add_child(new_proj)
				3:
					var new_proj = arrow.instantiate()
					new_proj.global_position = global_position
					new_proj.rotation = get_angle_to(get_global_mouse_position())
					new_proj.impulse_force = Vector2(550.0, 0.0).rotated(new_proj.rotation) + velocity
					#look_at(get_global_mouse_position())
					add_child(new_proj)
				4:
					var new_proj = wind_proj.instantiate()
					var target = closest_target()
					new_proj.global_position = global_position
					new_proj.rotation = -global_position.angle_to_point(target)
					new_proj.homing = true
					new_proj.target_pos = target
					new_proj.speed = 300.0
					new_proj.expiration_time = 5.0
					add_child(new_proj)
				5:
					var new_proj = mead_group.instantiate()
					new_proj.global_position = global_position
					new_proj.speed = 300.0
					add_child(new_proj)
				6:
					var new_proj = mead_bottle.instantiate()
					new_proj.global_position = global_position
					new_proj.impulse_force = (get_global_mouse_position() - global_position).normalized() * 200.0 + velocity*0.6 + Vector2(0.0, -300.0)
					add_child(new_proj)
	
	
	

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("shoot"):
	
	if event.is_action_pressed("mouse_wheel_up") and atk_charge == 0.0:
		current_atk = (current_atk + 1) % 7
	if event.is_action_pressed("mouse_wheel_down") and atk_charge == 0.0:
		current_atk -= 1
		if current_atk < 0: current_atk = 6 
			
	if event.is_action_pressed("hotkey1") and atk_charge == 0.0: current_atk = 0
	if event.is_action_pressed("hotkey2") and atk_charge == 0.0: current_atk = 1
	if event.is_action_pressed("hotkey3") and atk_charge == 0.0: current_atk = 2
	if event.is_action_pressed("hotkey4") and atk_charge == 0.0: current_atk = 3
	if event.is_action_pressed("hotkey5") and atk_charge == 0.0: current_atk = 4
	if event.is_action_pressed("hotkey6") and atk_charge == 0.0: current_atk = 5
	if event.is_action_pressed("hotkey7") and atk_charge == 0.0: current_atk = 6

func take_damage(amount:float) -> void:
	hp -= amount
	if hp < 0.001:
		defeat()
	else:
		sprite.self_modulate = Color(1.0, 0.3, 0.3, 0.5)
		await get_tree().create_timer(0.2).timeout
		sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		#play animation, block actions, invulnurable, S/VFX, makes you fall further


func defeat() -> void:
	if !defeated:
		defeated = true
		defeat_sfx.play()

func drink(amount: float) -> void:
	intoxication -= amount

func _on_lightning_atk_area_body_entered(body: Node2D) -> void:
	if body.has_method("getting_hit"):
		body.getting_hit(damage)

func closest_target():
	var final_target:= Vector2.ZERO
	var distance_check := 1000.0
	for target in targets_list:
		if distance_check > global_position.distance_to(target.global_position):
			distance_check = global_position.distance_to(target.global_position)
			final_target = target.global_position
	return final_target
	

func _draw() -> void:
	if atk_charge != 0.0:
		draw_circle(Vector2.ZERO, 50.0 * (1.0 + 3.0*atk_charge), Color.WHITE, false, -2.0, false)


func _on_auto_targets_body_entered(body: Node2D) -> void:
	if body != self:
		targets_list.append(body)
	


func _on_auto_targets_body_exited(body: Node2D) -> void:
	targets_list.erase(body)
