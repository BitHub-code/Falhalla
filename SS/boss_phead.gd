extends Node2D

@export var max_hp:= 1000.0
@export var player:CharacterBody2D
@export var melee_dmg:= 10.0
@export var action_delay := 2.0

#@onready var head:Sprite2D = $Head
@onready var power_atk_visual:Sprite2D = $Head/Marker2D/Orb
@onready var move_pos:Vector2 = global_position
@onready var state_machine = $AnimationTree.get("parameters/playback")
#state_machine.travel("some_state")

@onready var head_marker: Marker2D = $Head/Marker2D
@onready var rh_marker: Marker2D = $Right_hand/Marker2D
@onready var lh_marker: Marker2D = $Left_hand/Marker2D

@onready var lh_hit_box: Area2D = $Left_hand/boss_hit_box
@onready var head_hit_box: Area2D = $Head/boss_hit_box
@onready var rh_hit_box: Area2D = $Right_hand/boss_hit_box

const RIGID_BODY_PROJECTILE = preload("res://SS/rigid_body_projectile_purple.tscn")
const AREA_PROJECTILE = preload("res://SS/area_projectile.tscn")
const AREA_PROJECTILE_BIGORB = preload("res://SS/area_projectile_bigorb.tscn")

var actions_list:Array = [null, null, null]

var overall_hp := 1000.0
var timer := 0.0
var shoot_pattern_timer := 0.0
var started_p_bup := false
var power_buildup := 0.0
var counter:int = 0

func _ready() -> void:
	overall_hp = max_hp
	pick_actions()


func _process(delta: float) -> void:
	
	#Power_buildup attacks
	if power_buildup > 10.0:
		bigorb_release(power_buildup)
		state_machine.call_deferred("travel", "orb_release")
		#state_machine.travel("orb_release")
		
		
		
	elif started_p_bup:
		power_buildup += delta * 2.0
		power_atk_visual.scale.x = 0.01 
		if snappedf(power_buildup, 1.0) > power_atk_visual.scale.x:
			power_atk_visual.scale = Vector2(snappedf(power_buildup, 1.0)*0.1, snappedf(power_buildup, 1.0)*0.1)
	#elif power_buildup > max_p_bup:
	
	#if $AnimationPlayer.current_animation == "idle": #doesn't work because of AnimationTree overriding the animations, instead use:
	if state_machine.get_current_node() == "idle":
		timer += delta
	shoot_pattern_timer += delta
	print(timer)
	
	if timer > action_delay:
		timer = 0.0
		take_actions()
		
		
		#indication warning of where it will move, after short delay - move
	
	global_position = lerp(global_position, move_pos, 0.2)
	


func flip_all() -> void:
	scale.x *= -1.0
	#not sure if I will need more tweaks

func charge_move_pos() -> void:
	move_pos = Vector2(global_position.x + (-scale.x * 520.0), global_position.y)
	
func to_default_pos() -> void:
	#move_pos = Vector2( 186 + 102 * scale.x, global_position.y)
	move_pos = Vector2( 186 + 102 * scale.x, 52 * (1 + 9*randi_range(0, 1)))
	
func to_bottom_right_pos() -> void:
	scale.x = 1.0
	move_pos = Vector2(290, 560)

func to_custom_pos(pos:Vector2) -> void:
	move_pos = pos
	

func move_out_ofscreen() -> void:
	var x_cord:float
	var y_cord:float
	if global_position.x > 180.0: x_cord = 565.0
	else: x_cord = - 205.0
	if global_position.y > 320.0: y_cord = 840.0
	else: y_cord = -200.0
	move_pos = Vector2(x_cord, y_cord)

func shoot2() -> void:
	for n in 3:
		var new_proj = RIGID_BODY_PROJECTILE.instantiate()
		new_proj.global_position = head_marker.global_position
		new_proj.rotation = -2.14 + 0.2*n
		new_proj.impulse_force = Vector2(650.0 + 50.0*n*randf(), 0.0).rotated(new_proj.rotation)
		add_child(new_proj)
		

func shoot_area_projs(intigure:int) -> void:
	shoot_pattern_timer = wrapf(shoot_pattern_timer, -1.0, 1.0)
	for n in intigure:
		if !lh_hit_box.inactive: 
			var new_proj = AREA_PROJECTILE.instantiate()
			new_proj.global_position = lh_marker.global_position
			if player.global_position.y > global_position.y:
				new_proj.direction = Vector2(0.707*scale.x, 0.707).rotated(shoot_pattern_timer + 0.2*n)
			else:
				new_proj.direction = Vector2(0.707*-scale.x, -0.707).rotated(shoot_pattern_timer + 0.2*n)
			add_child(new_proj)
		if !rh_hit_box.inactive: 
			var new_proj2 = AREA_PROJECTILE.instantiate()
			new_proj2.global_position = rh_marker.global_position
			if player.global_position.y > global_position.y:
				new_proj2.direction = Vector2(0.707*-scale.x, 0.707).rotated(shoot_pattern_timer + 0.2*n)
			else:
				new_proj2.direction = Vector2(0.707*-scale.x, -0.707).rotated(shoot_pattern_timer + 0.2*n)
			add_child(new_proj2)

func shoot_homing_projs(proj_n:int, expiration:float) -> void: #homing_delay:float
	for n in proj_n:
		var new_proj = AREA_PROJECTILE.instantiate()
		new_proj.global_position = head_marker.global_position
		
		new_proj.homing = true
		new_proj.expiration_time = expiration
		new_proj.target_pos = player.global_position + Vector2(20.0*n, 3.0*n)
		add_child(new_proj)
		new_proj.sprite.frame = 840
		new_proj.marker.visible = true

func move_to_player_y() -> void:
	move_pos = Vector2(global_position.x, player.global_position.y)
	
	
func pick_actions() -> void:
	#melee, change pos, ranged; Light-Heavy, break, Heavy-light
	for index in 3:
		actions_list[index] = randi_range(1, 5)
	#change sides?


func take_actions() -> void:
	var action:int
	for i in actions_list.size():
		if actions_list[i]:
			action = actions_list[i]
			actions_list[i] = null 
			break
	#action = 2 #for testing
	match action:
		0:
			state_machine.travel("idle") #not needed, auto-switches to idle anyway from anim_tree
		1:
			state_machine.travel("bhfa_prep")
		2:
			state_machine.travel("charge_forward")
		3:
			state_machine.travel("punches")
		4:
			state_machine.travel("shooting1")
		5:
			state_machine.travel("orb_charge") # to be added
		6: #change sides?
			pass
	if !actions_list[-1]: pick_actions()
	


func _on_l_atk_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		atk_impact(body)

func _on_r_atk_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		atk_impact(body)

func atk_impact(body: CharacterBody2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(melee_dmg)
		#v/sfx

func bigorb_buildup() -> void:
	#power_buildup in process 
	started_p_bup = true
	power_atk_visual.visible = true
	#can do a tween alternative
	
func reset_bup() -> void:
	started_p_bup = false
	power_buildup = 0.0
	power_atk_visual.visible = false

func bigorb_release(amount:float) -> void:
	reset_bup()
	var new_orb := AREA_PROJECTILE_BIGORB.instantiate()
	new_orb.damage *= amount * 0.5
	new_orb.target = player
	new_orb.global_position = head_marker.global_position
	#new_orb.expiration_time = 
	add_child(new_orb)
	new_orb.sprite.scale = Vector2(amount * 0.1, amount * 0.1)
	new_orb.collision_shape_2d.shape.radius = 3.0 * amount
	

func closest_target() -> Vector2:
	return player.global_position

#When flipping sides, boss moves to other side first, then spins (most likely off screen), then moves to the level of the player; 
#Want recovery animation, when completed any parts not broken heal and parts broken become active again, if interupted = enter rage_mode; Interuption on broken part or enough damage done
#If deciding to add intoxication == If drunk can do fire breath attack and L_hand can hit mobs as well (not just the R_hand)
#Punches need fixing if one or more hands are not active; Alternative - use a recovery animation before punches
#Check on and connect signal:broken from boss_hit_box(es)


func _on_head_hit_box_broken(check: bool) -> void:
	print(check)
