extends Area2D

@export var speed := 300.0
var damage := 5.0
var proj_list:Array[CollisionShape2D]
var used_proj_list:Array[CollisionShape2D]
var inactive := false

func _ready() -> void:
	fill_list()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if inactive: return
	global_position += Vector2.DOWN * delta * speed
	if global_position.y > 2000.0:
		recycle_in()

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("getting_hit"):
		body.getting_hit(damage)
		#proj_list[local_shape_index].disabled = true
		#proj_list[local_shape_index].visible = false
		var used_p = get_child(local_shape_index)
		used_p.set_deferred("disabled", true)
		used_p.set_deferred("visible", false)
		#used_p.disabled = true
		#used_p.visible = false
		proj_list.erase(used_p)
		if proj_list.size() == 0:
			recycle_in()
		
	
func recycle_in() -> void:
	visible = false #with current set up, not needed; unless you have a sprite for the group?
	for node in proj_list:
		node.disabled = true
		node.visible = false
	fill_list()
	inactive = true
	
func shoot(pos:Vector2) -> void:
	global_position = pos
	for node in proj_list:
		node.disabled = false
		node.visible = true
	visible = true
	inactive = false

func fill_list() -> void:
	proj_list = []
	for index in get_child_count():
		if get_child(index) is CollisionShape2D:
			proj_list.append(get_child(index))
