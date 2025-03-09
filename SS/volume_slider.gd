extends HSlider

@export var bus_name:String
@export var bus_index:int #if bus_name is set, this becomes optional

func _ready() -> void:
	if !bus_index and bus_name:
		bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	_on_value_changed(value)

func _process(delta: float) -> void:
	pass
	#lerp value? if someone fidgets with the slider

func _on_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
