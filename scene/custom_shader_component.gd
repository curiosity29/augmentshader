class_name CustomShaderContainer
extends Control

signal shader_updated

#region workaround
#@export var test: PackedStringArray = ['void', 'vec2', 'vec3', 'vec4', 'mat2', 'mat3', 'mat4', 'uniform', 'sampler2D',
  #'texture', 'discard', 'return', 'for', 'while', 'break', 'continue',
  #'mix', 'fract', 'mod', 'abs', 'sin', 'cos', 'tan', 'normalize', 'length']
##'if', 'else',
#
#@export var keywords_colors: Dictionary = {
	#'void': Color(1.0, 0.302, 0.235), 'vec2': Color(1.0, 0.302, 0.235),
	#'vec3': Color(1.0, 0.302, 0.235), 'vec4': Color(1.0, 0.302, 0.235),
	#'mat2': Color(1.0, 0.302, 0.235), 'mat3': Color(1.0, 0.302, 0.235),
	#'mat4': Color(1.0, 0.302, 0.235), 'uniform': Color(1.0, 0.302, 0.235),
	#'sampler2D': Color(1.0, 0.302, 0.235), 'texture': Color(1.0, 0.302, 0.235),
	#'discard': Color(1.0, 0.302, 0.235), 'return': Color(1.0, 0.302, 0.235),
	#'for': Color(1.0, 0.302, 0.235), 'while': Color(1.0, 0.302, 0.235),
	#'break': Color(1.0, 0.302, 0.235), 'continue': Color(1.0, 0.302, 0.235),
	#'mix': Color(1.0, 0.302, 0.235), 'fract': Color(1.0, 0.302, 0.235),
	#'mod': Color(1.0, 0.302, 0.235), 'abs': Color(1.0, 0.302, 0.235),
	#'sin': Color(1.0, 0.302, 0.235), 'cos': Color(1.0, 0.302, 0.235),
	#'tan': Color(1.0, 0.302, 0.235), 'normalize': Color(1.0, 0.302, 0.235),
	#'length': Color(1.0, 0.302, 0.235)
#}

#endregion
var color: Color

@onready var shader_code_edit: CodeEdit = %ShaderCodeEdit

var custom_shader_material: ShaderMaterial
var custom_shader: Shader
func update_custom_shader() -> void:
	## remove old material
	#if custom_shader_material: custom_shader_material.free()
	if not custom_shader_material: 
		custom_shader_material = ShaderMaterial.new()
	if not custom_shader:
		custom_shader = Shader.new()
		
	var shader_code: String = shader_code_edit.text
	custom_shader.code = shader_code
	#var shader_material = ShaderMaterial.new()
	custom_shader_material.shader = custom_shader
	#custom_shader.get_shader_uniform_list()
	#new_shader.free()
	#print(OS.get_temp_dir())
	## have to save to file since it's not properly instatiate the default value otherwise
	ResourceSaver.save(custom_shader_material, OS.get_temp_dir() + "/custom_shader_material.tres")
	shader_updated.emit()
	
	## Me debugging at 12am
	#print("wtf: ", custom_shader_material.get_shader_parameter("gamma"))
	


func _on_shader_update_button_pressed() -> void:
	update_custom_shader()
	pass


#func _ready() -> void:
	#shader_code_edit.text = default_shader.code
	#update_custom_shader()
	#pass
	# setting default shade using this custom scene
	
	
	
