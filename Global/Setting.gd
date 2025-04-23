## class_name Setting (global class)
extends Node



#region default
# setting file in the same directory as the executable with name setting.json
var setting_file_name: String = "setting.json"
var setting_file_path: String:
	get:
		return "%s/%s" % [OS.get_user_data_dir(), setting_file_name]

func get_default_setting_args() -> Array[String]:
	return [
		"execute_mode=UI",
	]

var shader_folder_path: String = "%s/shader" % OS.get_user_data_dir()

var default_shader_filename: String = "default_shader.gdshader"
var default_shader_path: String = "%/%s" % [shader_folder_path, default_shader_filename]

# context shader

var context_shader_file_name: String = "context_shader.gdshader"
var context_shader_path: String = "%s/%s" % [shader_folder_path, context_shader_file_name]

var context_shader_material_file_name: String = "context_shader_material.tres"
var context_shader_material_path: String = "%s/%s" % [shader_folder_path, context_shader_material_file_name]
#endregion


var is_debugging: bool:
	get: return OS.has_feature("editor")
var setting_path: String:
	get:
		if is_debugging:
			return setting_file_name
		else:
			return  "%s/%s" % [OS.get_executable_path(), setting_file_name]


func save_to_file(path: String, data: Dictionary) -> void:
	var setting_data: Dictionary = Helper.read_json(setting_file_path)

func init_setting_data_structure():
	if not DirAccess.dir_exists_absolute(shader_folder_path):
		DirAccess.make_dir_absolute(shader_folder_path)
	
func _ready() -> void:
	init_setting_data_structure()


# func load_from_file(path: String) -> Dictionary:
# 	var file: File = File.new()
# 	file.open(path, File.READ)
# 	var data: Dictionary = JSON.parse(file.get_as_text())
# 	file.close()
	# return data
