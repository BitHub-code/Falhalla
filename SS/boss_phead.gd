extends Node2D

@export var max_hp:= 1000.0
@export var player:CharacterBody2D

@onready var head:Sprite2D = $Head
@onready var move_pos:Vector2 = global_position

var overall_hp := 1000.0

var alignment_delay := 56.0 #try to establish a rythm, if idle is 1.5 sec loop look at X-ing it
var timer := 0.0


func _ready() -> void:
	overall_hp = max_hp
	


func _process(delta: float) -> void:
	#Head movements outside animPlayer
	
	#head.look_at(player.global_position)
	#head.rotation += PI
	#head.rotation = clamp(head.rotation - PI, 0.25 * PI * scale.x, -0.25 * PI * scale.x) - needs fixing
	timer += delta
	if timer > alignment_delay:
		return
		timer -= alignment_delay
		var pos_or_neg := 1.0
		#if randf() > 0.5: pos_or_neg = -1.0
		#if scale.x != pos_or_neg: flip_all()
		to_default_pos()
		#flip_all()
		#indication warning of where it will move, after short delay - move
	
	global_position = lerp(global_position, move_pos, 0.2)
	


func flip_all() -> void:
	scale.x *= -1.0
	#not sure if I will need more tweaks

func charge_move_pos() -> void:
	move_pos = Vector2(global_position.x + (-scale.x * 520.0), global_position.y)
	print(move_pos)
	
func to_default_pos() -> void:
	move_pos = Vector2( 186 + 102 * scale.x, global_position.y)

#When flipping sides, boss moves to other side first, then spins (most likely off screen), then moves to the level of the player; 
#Want recovery animation, when completed any parts not broken heal and parts broken become active again, if interupted = enter rage_mode; Interuption on broken part or enough damage done
#If deciding to add intoxication == If drunk can do fire breath attack and L_hand can hit mobs as well (not just the R_hand)
