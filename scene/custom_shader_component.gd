class_name CustomShaderContainer
extends Control

signal shader_updated

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
	
	
	
