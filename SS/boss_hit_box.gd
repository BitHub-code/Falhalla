extends Area2D

@onready var boss_node: Node2D = $"../.."

@export var max_hp := 100.0
@export var inactive_timer := 10.0

var hp := 100.0

var inactive := false

func _ready() -> void:
	hp = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func getting_hit(amount:float) -> void:
	hp -= amount
	boss_node.overall_hp -= amount
	if hp < 0.001:
		defeated()

func defeated() -> void:
	inactive = true
	$CollisionShape2D.set_deferred("disabled", true)
	get_parent().self_modulate = Color(0.4, 0.4, 0.4)
	boss_node.overall_hp -= max_hp
	#boss_node.animation_player.play()
	#queue_free()
