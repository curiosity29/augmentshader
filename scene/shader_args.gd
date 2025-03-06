class_name ShaderSetting
extends Control








signal current_parameter_changed

#region gamma

#var gamma_min: float = 0.0
#var gamma_max: float = 0.0
var gamma_current: float = 0.0:
	set(value):
		gamma_current = value
		current_parameter_changed.emit()
		
#var gamma_slide_value: float = 0.0

@onready var gamma_min_spin_box: SpinBox = %GammaMinSpinBox
@onready var gamma_max_spin_box: SpinBox = %GammaMaxSpinBox
@onready var gamma_slider: HSlider = %GammaSlider
@onready var gamma_current_label: Label = %GammaCurrentLabel



func _on_gamma_min_spin_box_value_changed(value: float) -> void:
	gamma_slider.min_value = value
func _on_gamma_max_spin_box_value_changed(value: float) -> void:
	gamma_slider.max_value = value
func _on_gamma_slider_value_changed(value: float) -> void:
	gamma_current_label.text = str(value)
	gamma_current = value
#endregion

#region contrast

#var contrast_min: float = 0.0
#var contrast_max: float = 0.0
var contrast_current: float = 0.0:
	set(value):
		contrast_current = value
		current_parameter_changed.emit()
#var contrast_slide_value: float = 0.0
@onready var contrast_min_spin_box: SpinBox = %ContrastMinSpinBox
@onready var contrast_max_spin_box: SpinBox = %ContrastMaxSpinBox
@onready var contrast_slider: HSlider = %ContrastSlider
@onready var contrast_current_label: Label = %ContrastCurrentLabel


func _on_contrast_slider_value_changed(value: float) -> void:
	contrast_current_label.text = str(value)
	contrast_current = value

func _on_contrast_min_spin_box_value_changed(value: float) -> void:
	contrast_slider.min_value = value

func _on_contrast_max_spin_box_value_changed(value: float) -> void:
	contrast_slider.max_value = value
	
#endregion contrast

#region blur_radius

#var blur_radius_min: int = 0
#var blur_radius_max: int = 0
var blur_radius_current: int = 0:
	set(value):
		blur_radius_current = value
		current_parameter_changed.emit()
	
#var blur_radius_slide_value: int = 0

@onready var blur_radius_min_spin_box: SpinBox = %BlurRadiusMinSpinBox
@onready var blur_radius_max_spin_box: SpinBox = %BlurRadiusMaxSpinBox
@onready var blur_radius_slider: HSlider = %BlurRadiusSlider
@onready var blur_radius_current_label: Label = %BlurRadiusCurrentLabel

func _on_blur_radius_slider_value_changed(value: float) -> void:
	blur_radius_current_label.text = str(value)
	blur_radius_current = value
func _on_blur_radius_min_spin_box_value_changed(value: float) -> void:
	blur_radius_slider.min_value = value
func _on_blur_radius_max_spin_box_value_changed(value: float) -> void:
	blur_radius_slider.max_value = value

#endregion

#region hsv offset

#var hsv_offset_min: Vector3 = Vector3.ZERO
#var hsv_offset_max: Vector3 = Vector3.ZERO
var hsv_offset_current: Vector3 = Vector3.ZERO:
	set(value):
		hsv_offset_current = value
		current_parameter_changed.emit()
#var hsv_offset_slide_value: Vector3 = Vector3.ZERO

@onready var hue_min_spin_box: SpinBox = %HueMinSpinBox
@onready var saturation_min_spin_box: SpinBox = %SaturationMinSpinBox
@onready var value_min_spin_box: SpinBox = %ValueMinSpinBox

@onready var hue_max_spin_box: SpinBox = %HueMaxSpinBox
@onready var saturation_max_spin_box: SpinBox = %SaturationMaxSpinBox
@onready var value_max_spin_box: SpinBox = %ValueMaxSpinBox

@onready var hue_slider: HSlider = %HueSlider
@onready var saturation_slider: HSlider = %SaturationSlider
@onready var value_slider: HSlider = %ValueSlider

@onready var hue_current_label: Label = %HueCurrentLabel
@onready var saturation_current_label: Label = %SaturationCurrentLabel
@onready var value_current_label: Label = %ValueCurrentLabel


	
func _on_hue_slider_value_changed(value: float) -> void:
	hue_current_label.text = str(value)
	hsv_offset_current.x = value
func _on_hue_min_spin_box_value_changed(value: float) -> void:
	hue_slider.min_value = value
func _on_hue_max_spin_box_value_changed(value: float) -> void:
	hue_slider.max_value = value


func _on_saturation_slider_value_changed(value: float) -> void:
	saturation_current_label.text = str(value)
	hsv_offset_current.y = value
func _on_saturation_min_spin_box_value_changed(value: float) -> void:
	saturation_slider.min_value = value
func _on_saturation_max_spin_box_value_changed(value: float) -> void:
	saturation_slider.max_value = value


func _on_value_slider_value_changed(value: float) -> void:
	value_current_label.text = str(value)
	hsv_offset_current.z = value
func _on_value_min_spin_box_value_changed(value: float) -> void:
	value_slider.min_value = value
func _on_value_max_spin_box_value_changed(value: float) -> void:
	value_slider.max_value = value


#endregion

var shader_parameters_range: Dictionary[String, Array]:
	get: return {
	"blur_radius": [blur_radius_min_spin_box.value, blur_radius_max_spin_box.value],
	"gamma": [gamma_min_spin_box.value, gamma_max_spin_box.value],
	"contrast": [contrast_min_spin_box.value, contrast_max_spin_box.value],
	"hsv_offset": [
		Vector3(hue_min_spin_box.value, saturation_min_spin_box.value, value_min_spin_box.value), 
		Vector3(hue_max_spin_box.value, saturation_max_spin_box.value, value_max_spin_box.value)],
}

#var shader_parameters_current: Dictionary:
	#get: return {
	#"blur_radius": int(contrast_current_label.text),
	#"gamma": float(gamma_current_label.text),
	#"contrast":  float(contrast_current_label.text),
	#"hsv_offset": Vector3(float(hue_current_label.text), float(saturation_current_label.text), float(value_current_label.text)) 
#}
var shader_parameters_current: Dictionary:
	get: return {
	"blur_radius": contrast_current,
	"gamma": gamma_current,
	"contrast": contrast_current,
	"hsv_offset": hsv_offset_current,
}
