extends Area2D

signal broken(check:bool)

@onready var boss_node: Node2D = $"../.."

@export var max_hp := 100.0
@export var inactive_timer := 10.0
@export var dmg_to_main := 1.0 #some parts can have high vulnurability (acting as weak points) while other less (and act as protection)

var hp := 100.0
var timer := 0.0
var inactive := false

func _ready() -> void:
	hp = max_hp


func _process(delta: float) -> void:
	if inactive:
		timer += delta
		if timer > inactive_timer:
			re_activate()
			timer = 0.0


func getting_hit(amount:float) -> void:
	hp -= amount
	boss_node.overall_hp -= amount
	if hp < 0.001:
		defeated()

func defeated() -> void:
	inactive = true
	$CollisionShape2D.set_deferred("disabled", true)
	get_parent().self_modulate = Color(0.4, 0.4, 0.4)
	boss_node.overall_hp -= max_hp * dmg_to_main
	emit_signal("broken", true)
	#boss_node.animation_player.play()
	#queue_free()

func re_activate() -> void:
	inactive = false
	$CollisionShape2D.set_deferred("disabled", false)
	get_parent().self_modulate = Color(1, 1, 1)
	hp = max_hp
	emit_signal("broken", false)
	
