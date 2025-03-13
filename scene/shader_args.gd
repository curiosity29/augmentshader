class_name ShaderSetting
extends Control

#region signal
signal current_parameter_changed
#endregion

#region component ref
@onready var args_container: VBoxContainer = %ArgsContainer

@onready var contrast_modifier: FloatArgModifier = %ContrastModifier
@onready var gamma_modifier: FloatArgModifier = %GammaModifier
@onready var blur_radius_modifier: FloatArgModifier = %BlurRadiusModifier
@onready var hue_modifier: FloatArgModifier = %HueModifier
@onready var saturation_modifier: FloatArgModifier = %SaturationModifier
@onready var value_modifier: FloatArgModifier = %ValueModifier

#endregion

func _ready() -> void:
	for modifier in args_container.get_children():
		if modifier is FloatArgModifier:
			modifier.current_value_changed.connect(on_arg_value_changed)

func on_arg_value_changed():
	current_parameter_changed.emit()
#region for external usage
var shader_parameters_range: Dictionary[String, Array]:
	get: return {
	"gamma": [gamma_modifier.min_value, gamma_modifier.max_value],
	"contrast": [contrast_modifier.min_value, contrast_modifier.max_value],
	"blur_radius": [blur_radius_modifier.min_value, blur_radius_modifier.max_value],
	"hsv_offset": [
		Vector3(hue_modifier.min_value, saturation_modifier.min_value, value_modifier.min_value), 
		Vector3(hue_modifier.max_value, saturation_modifier.max_value, value_modifier.max_value), 
	],
}

var shader_parameters_current: Dictionary:
	get: return {
	"gamma": gamma_modifier.current_value,
	"contrast": contrast_modifier.current_value,
	"blur_radius": blur_radius_modifier.current_value,
	"hsv_offset": Vector3(hue_modifier.current_value, saturation_modifier.current_value, value_modifier.current_value),
}

#endregion
