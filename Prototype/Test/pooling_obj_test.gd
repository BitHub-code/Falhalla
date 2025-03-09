extends Node2D

@onready var mead_group := preload("res://SS/group_projectile.tscn")
@onready var no_pool_proj := preload("res://SS/group_projectiles_no_pooling.tscn")

@export var pool_cap := 90

var pooling_list:Array[Node] = []
var current_index: = -1
var no_pooling := true

#BUG when shoot() and not recycled

func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if no_pooling:
			var new_proj = no_pool_proj.instantiate()
			new_proj.global_position = Vector2(100, 100) #global_position
			new_proj.speed = 300.0
			add_child(new_proj)
		current_index += 1
		if current_index == pool_cap: current_index = 0
		if pooling_list.size() < pool_cap: 
			var new_proj = mead_group.instantiate()
			new_proj.global_position = Vector2(100, 100) #global_position
			new_proj.speed = 300.0
			add_child(new_proj)
			pooling_list.append(new_proj)
		else:
			pooling_list[current_index].shoot(Vector2(100, 100))


func _on_timer_timeout() -> void:
	print(pooling_list.size())
