@tool

class_name FloatArgModifier
extends HBoxContainer

#region signal

signal current_value_changed


#endregion

#region component ref
@onready var arg_name_label: RichTextLabel = $ArgNameLabel
@onready var min_spin_box: SpinBox = %MinSpinBox
@onready var max_spin_box: SpinBox = %MaxSpinBox
@onready var slider: HSlider = %Slider
@onready var current_value_edit: LineEdit = %CurrentValueEdit
@onready var current_spin_box: SpinBox = %CurrentSpinBox
#endregion


#region vars

#region value editting
@export_group("value editting")
@export var integer_rounded: bool = false:
	set(value):
		integer_rounded = value
		if min_spin_box: min_spin_box.rounded = value
		if max_spin_box: max_spin_box.rounded = value
		if current_spin_box: current_spin_box.rounded = value
		
@export var snap_step_size: float = 0.001:
	set(value):
		snap_step_size = value
		if min_spin_box: min_spin_box.step = value
		if max_spin_box: max_spin_box.step = value
		if current_spin_box: current_spin_box.step = value
#@export var increment_step_size: float = 0.001
# scroll value, not adding this to slider cause it blue ball the spinbox or slider (can't set it to max, for some reason)
# it could be solve-ish by manually adding a step amount to the max but it's too much for my own sanity
#@export var page_step_size: float = 0.01:
	#set(value):
		#page_step_size = value
		#if min_spin_box: min_spin_box.page = value
		#if max_spin_box: max_spin_box.page = value
		#if current_spin_box: current_spin_box.page = value

@export var enable_hard_min: bool = true:
	set(value):
		enable_hard_min = value
		if min_spin_box: min_spin_box.allow_lesser = !value
		if max_spin_box: max_spin_box.allow_lesser = !value
@export var hard_min_value: float:
	set(value):
		hard_min_value = value
		if hard_min_value > hard_max_value: hard_max_value = hard_min_value
		min_value = clampf(min_value, hard_min_value, hard_max_value)
		max_value = clampf(max_value, hard_min_value, hard_max_value)
		if min_spin_box: min_spin_box.min_value = value
		if max_spin_box: max_spin_box.min_value = value
@export var enable_hard_max: bool = true:
	set(value):
		enable_hard_max = value
		if min_spin_box: min_spin_box.allow_greater = !value
		if max_spin_box: max_spin_box.allow_greater = !value
@export var hard_max_value: float:
	set(value):
		hard_max_value = value
		if hard_min_value > hard_max_value: hard_min_value = hard_max_value
		min_value = clampf(min_value, hard_min_value, hard_max_value)
		max_value = clampf(max_value, hard_min_value, hard_max_value)
		if min_spin_box: min_spin_box.max_value = value
		if max_spin_box: max_spin_box.max_value = value
#endregion

#region main values
@export_group("main values")
@export var min_value: float:
	set(value):
		if enable_hard_min: value = max(value, hard_min_value)
		if enable_hard_max: value = min(value, hard_max_value)
		value = snappedf(value, snap_step_size)
		
		min_value = value
		if min_spin_box: min_spin_box.value = value
		if current_spin_box: current_spin_box.min_value = value
		## must check instead of direct assign to prevent infinite setter cycle
		if min_value > max_value: max_value = min_value
		if slider: slider.min_value = value
		current_value = current_value
@export var max_value: float:
	set(value):
		if enable_hard_min: value = max(value, hard_min_value)
		if enable_hard_max: value = min(value, hard_max_value)
		value = snappedf(value, snap_step_size)
		max_value = value
		
		if max_spin_box: max_spin_box.value = value
		if current_spin_box: current_spin_box.max_value = value
		## must check instead of direct assign to prevent infinite setter cycle
		if min_value > max_value: min_value = max_value
		## legacy note: possible fix of adding a small value to slider max value as a workaround for the slider to actually reach max 
		## instead of max_value - page
		if slider: slider.max_value = value #+ page_step_size
		current_value = current_value
@export var current_value: float:
	set(value):
		value = clampf(value, min_value, max_value)
		value = snappedf(value, snap_step_size)
		if integer_rounded: value = float(round(value))
		current_value = value
		if current_spin_box: current_spin_box.value = value
		if slider: slider.value = value
		current_value_changed.emit()
@export_group("visual")
@export_multiline var arg_name: String:
	set(value):
		arg_name = value
		if arg_name_label: arg_name_label.text = value
#endregion

#endregion


#region event

func _on_min_spin_box_value_changed(value: float) -> void:
	min_value = value
func _on_max_spin_box_value_changed(value: float) -> void:
	max_value = value
func _on_current_spin_box_value_changed(value: float) -> void:
	## NOTE: infinite preventing
	if current_value != value: current_value = value
	#print(current_value, ", " ,value)
func _on_slider_value_changed(value: float) -> void:
	current_value = value

#endregion


#region setup
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		min_spin_box.value_changed.connect(_on_min_spin_box_value_changed)
		max_spin_box.value_changed.connect(_on_max_spin_box_value_changed)
		current_spin_box.value_changed.connect(_on_current_spin_box_value_changed)
		slider.value_changed.connect(_on_slider_value_changed)
	reset_all_setter()
	

#endregion


#region utils

@export_tool_button("reset_all_setter") var reset_all_setter_action = reset_all_setter
func reset_all_setter():
	for property in get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:  # Filters user-defined vars
			set(property["name"], get(property["name"]))


#endregion
