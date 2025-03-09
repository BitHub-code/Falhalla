extends Control

signal confirm_signal

@onready var confirm_panel: Panel = $ConfirmPanel
@onready var options: VBoxContainer = $MarginContainer/Options
@onready var main: VBoxContainer = $MarginContainer/Main
@onready var control_instructions: Panel = $MarginContainer/ControlInstructions
@onready var res_options: OptionButton = $MarginContainer/Options/HBoxContainer/ResOptions

@export var scene_path:String = "res://Prototype/test_world.tscn"

@export var pause_menu_mode:bool = false

var resolutions = {
	"1920x1080": Vector2i(1920, 1080),
	"1280x720": Vector2i(1280, 720),
	"1024x600": Vector2i(1024, 600),
	"800x600": Vector2i(800, 600)
}

var previous_mouse_mode
var paused_mode: bool = false
var yes: bool 
var full_screen:bool = false:
	set(b):
		if b == full_screen:
			return
		if b:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		full_screen = b

func _ready() -> void:
	if pause_menu_mode:
		$MarginContainer/Main/Title.text = "PAUSE MENU"
		$MarginContainer/Main/Start.text = "Resume game"
		$MarginContainer/Main/Restart.visible = true
	else:
		for index in AudioServer.bus_count:
			AudioServer.set_bus_volume_db(
				index,
				linear_to_db(0.5)
			)
			print(index)
	if get_tree().paused == true:
		get_tree().paused = false

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if pause_menu_mode:
		if Input.is_action_just_pressed("esc"):
			if options.visible: _on_cancel_button_down()
			elif confirm_panel.visible: confirm_panel.visible = false
			elif control_instructions.visible: _on_cancel_2_button_down()
			elif paused_mode:
				unpause()
			else:
				pause()

func unpause() -> void:
	if confirm_panel.visible: confirm_panel.visible = false
	visible = false
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false
	Input.mouse_mode = previous_mouse_mode
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	paused_mode = false
	

func pause() -> void:
	visible = true
	previous_mouse_mode = Input.mouse_mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	get_tree().paused = true
	paused_mode = true


func _on_start_button_down() -> void:
	if !pause_menu_mode:
		get_tree().change_scene_to_file(scene_path)
	else:
		unpause()


func _on_options_button_down() -> void:
	main.visible = false
	options.visible = true
	


func _on_exit_button_down() -> void:
	confirm_panel.visible = true
	await confirm_signal
	if yes == true:
		get_tree().quit()


func _on_yes_button_down() -> void:
	yes = true
	confirm_signal.emit()
	confirm_panel.visible = false


func _on_no_button_down() -> void:
	yes = false
	confirm_signal.emit()
	confirm_panel.visible = false


func _on_cancel_button_down() -> void:
	main.visible = true
	options.visible = false
	
	


func _on_control_inst_button_down() -> void:
	main.visible = false
	control_instructions.visible = true


func _on_cancel_2_button_down() -> void:
	main.visible = true
	control_instructions.visible = false


func _on_full_screen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		full_screen = true
		$MarginContainer/Options/HBoxContainer/Label_res.visible = false
		$MarginContainer/Options/HBoxContainer/ResOptions.visible = false
	else:
		full_screen = false
		$MarginContainer/Options/HBoxContainer/Label_res.visible = true
		$MarginContainer/Options/HBoxContainer/ResOptions.visible = true



func _on_res_options_item_selected(index: int) -> void:
	var key = res_options.get_item_text(index)
	get_window().set_size(resolutions[key])
	if !full_screen:
		center_window()
		


func center_window() -> void:
	var screen_scenter = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_scenter - window_size / 2)


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_restart_button_down() -> void:
	get_tree().reload_current_scene()
