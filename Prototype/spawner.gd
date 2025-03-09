extends Marker2D

@export var unit:PackedScene
@export var timer_spawn := 7.0

var timer := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > timer_spawn:
		timer = 0.0
		spawn_unit()


func spawn_unit() -> void:
	if !unit: return
	var new_unit = unit.instantiate()
	add_child(new_unit)
