extends Node2D

#region base component ref
@export var shader_setting_template_scene: PackedScene
@export var visible_toggle_button_scene: PackedScene


#endregion

#region component ref

@onready var file_dialog: FileDialog = $FileDialog

@onready var visual_sub_viewport: SubViewport = %VisualSubViewport
@onready var visual_texture_rect: TextureRect = %VisualTextureRect
@onready var capture_viewport_container: SubViewportContainer = %CaptureViewportContainer
@onready var capture_sub_viewport: SubViewport = %CaptureSubViewport
@onready var capture_sprite_2d: Sprite2D = %CaptureSprite2D

var visual_material: ShaderMaterial:
	get: return visual_texture_rect.material

@onready var shader_setting: ShaderSetting = %ShaderSetting
@onready var paths_scroll_container: PathArgsContainer = %PathsScrollContainer
@onready var custom_shader_component: CustomShaderContainer = %CustomShaderComponent
@onready var other_setting: OtherSetting = $ScrollContainer/ArgsComponentContainer/OtherSetting
@onready var executor: Executor = $Executor
@onready var args_component_container: VBoxContainer = %ArgsComponentContainer

var current_shader_setting_visible_button: VisibleToggleButton
var current_shader_setting_ui: ShaderSettingTemplate
	
#endregion

#region vars

@export var default_texture: Texture

			
			
#endregion

#region command line run

var command_input_path: String = ""
const valid_image_extension: Array[String] = [".png", ".jpg", ".PNG", ".jpeg"]
enum ExecuteMode {UI, ContextImage, ContextFolder}
var execute_mode: ExecuteMode = ExecuteMode.UI

@onready var debug_label: Label = %DebugLabel

func _parse_command_line_args():
	var args = OS.get_cmdline_user_args()
	var debug_label_text: String = ""
	for command_component: String in args:
		debug_label_text += command_component + "\n"
	debug_label.text = "command: \n%s" % debug_label_text
	var options: Dictionary = {
		"execute_mode": ExecuteMode.UI # 
	}
	
	if not args:
		args = Setting.get_default_setting_args()
		# print("empty args, running with default")
		# args = []
		
		# var executable_path: String = OS.get_executable_path()
		
		# var default_config_args = default_config_path_format % executable_path.get_base_dir()
		# args.append(default_config_args)
	else:
		for arg in args:
			var key_value = arg.split("=")
			var key: String = key_value[0]
			var value: String = key_value[1]

			match key:
				# "setting_path":
				# 	Setting.setting_path = value
				"input_path":
					## convert path with \ to /
					command_input_path = value
					
					command_input_path = command_input_path.replace("\\", "/")
					## set texture to the image in path 
					var path_ext: String = get_path_ext(command_input_path)
					if FileAccess.file_exists(command_input_path) and command_input_path.ends_with(path_ext):
						options["execute_mode"] = ExecuteMode.ContextImage
					
					if DirAccess.dir_exists_absolute(command_input_path):
						options["execute_mode"] = ExecuteMode.ContextFolder
					
					print("command_input_path: %s" % command_input_path)
	
	print("starting with args: ", args)
	

	#if is_debugging:
		#config_json_path = default_config_path_format % OS.get_executable_path().get_base_dir()
		#print("debugging using config path: ", config_json_path)
		
	print("started with args: ", args)
	## run with different mode depend on options
	match options["execute_mode"]:
		ExecuteMode.UI:
			pass
		ExecuteMode.ContextImage:
			context_option_run_for_image(command_input_path)
		ExecuteMode.ContextFolder:
			context_option_run_for_folder(command_input_path)
		
	
	
## augment an input image and save to the same folder with added postfix for image name "_shadered"
## does not check path validity

## change to shader code edit text and update similar to when using UI
func load_context_shader_to_custom() -> void:
	var context_shader: Shader = ResourceLoader.load(Setting.context_shader_path)
	var context_shader_material = ResourceLoader.load(Setting.context_shader_material_path)
	custom_shader_component.shader_code_edit.text = context_shader.code
	custom_shader_component.update_custom_shader()
	update_custom_shader()
	

func context_option_run_for_image(input_image_path: String) -> void:
	var base_path_and_ext: Array[String] = osp_splitext(input_image_path)
	var postfix: String = "_shadered"
	var output_path: String = "%s%s%s" % [base_path_and_ext[0], postfix, base_path_and_ext[1]]
	
	load_context_shader_to_custom()
	
	load_and_change_visual_image(input_image_path)
	await RenderingServer.frame_pre_draw ## wait for visual to update
	#save_visual_image(output_path)
	executor.load_and_augment(input_image_path, output_path)

## augment an input folder and save a new folder in the same root as input folder with added postfix
## for folder name and file name "_shadered"
## does not check path validity
## NOTE: This function is incomplete
## required to change to reading a shader from current project folder instead
## (shader_paramters and new_shader_material)
func context_option_run_for_folder(input_folder_path: String) -> void:
	
	## 
	load_context_shader_to_custom()
	
	var context_input_output_folders_map = {
		input_folder_path: input_folder_path + "_shadered"
	}
	var context_other_setting = {
		"variation_count": 1
	}
	executor.execute_setup(
		shader_paramters, context_input_output_folders_map,
		context_other_setting["variation_count"],
		custom_shader_component.custom_shader_material
	)
	executor.execute()
	
	pass

func setup_context_data() -> void:
	ResourceSaver.save(custom_shader_component.custom_shader, Setting.context_shader_path)
	ResourceSaver.save(custom_shader_component.custom_shader_material, Setting.context_shader_material_path)

#endregion

#region path helper
func osp_splitext(path: String) -> Array[String]:
	var ext: String = get_path_ext(path)
	var base_path: String = path.erase(path.length() - ext.length(), ext.length())
	return [base_path, ext] as Array[String]

func get_path_ext(path: String) -> String:
	var splitted_path: PackedStringArray = path.split(".")
	#print("path: ", path)
	#print("splitted_path: ", splitted_path)
	if splitted_path.is_empty():
		return ""
	return "." + splitted_path[-1]

#endregion

#region ready and update
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#open_folder_picker()
	shader_setting.current_parameter_changed.connect(_on_shader_parameter_changed)
	_on_shader_parameter_changed()
	executor.folder_progress_updated.connect(_on_execute_progress_updated)
	executor.done_execute.connect(_on_execute_done)
	custom_shader_component.shader_updated.connect(update_custom_shader)
	
	## set default shader
	# custom_shader_component.shader_code_edit.text = default_shader.code
	# custom_shader_component.update_custom_shader()
	#update_custom_shader()
	
	#visual_texture_rect.material = custom_shader_material
	
	## NOTE: debugging:
	setup_context_data()
	
	call_deferred("ready_execute")
	#call_deferred("context_option_run_for_image", "C:/Personal/Godot/sample/image/0.jpg")
	#context_option_run_for_image("C:/Personal/Godot/sample/image/0.jpg")
	

func ready_execute():
	_parse_command_line_args()

func _on_execute_done():
	progress_label.text = done_progress_label_format % [
		executor.last_run_time,
		executor.current_input_folder, executor.current_output_folder,
		executor.current_folder_processed_count, executor.current_folder_total_count,
	]

func _on_execute_progress_updated():
	progress_label.text = running_progress_label_format % [
		executor.current_input_folder, executor.current_output_folder,
		executor.current_folder_processed_count, executor.current_folder_total_count
	]
## apply the shader code to take effect in setting and visual UI texture
func update_custom_shader():
	#visual_texture_rect.material = custom_shader_component.custom_shader_material
	update_new_shader_ui(custom_shader_component.custom_shader, custom_shader_component.custom_shader_material)
	visual_texture_rect.material = current_shader_setting_ui.shader_material

## 
func update_new_shader_ui(shader: Shader, shader_material: ShaderMaterial):
	if current_shader_setting_ui: current_shader_setting_ui.queue_free()
	if current_shader_setting_visible_button: current_shader_setting_visible_button.queue_free()
	
	var new_visible_button: VisibleToggleButton = visible_toggle_button_scene.instantiate()
	var new_shader_setting_ui: ShaderSettingTemplate = shader_setting_template_scene.instantiate()
	new_shader_setting_ui.shader = shader
	new_shader_setting_ui.shader_material = shader_material
	#var new_shader_material = ShaderMaterial.new()
	#new_shader_material.shader = shader
	#print(new_shader_material.get_shader_parameter('gamma'))
	
	new_visible_button.target_node = new_shader_setting_ui
	new_visible_button.text = "Shader setting"
	args_component_container.add_child(new_visible_button)
	args_component_container.add_child(new_shader_setting_ui)
	
	current_shader_setting_ui = new_shader_setting_ui
	current_shader_setting_visible_button = new_visible_button
	
	
	
	
	pass

#endregion


#region UI (becoming dirty)
#region filesystem
func open_folder_picker(callback: Callable = func(): pass):
	file_dialog.dir_selected.connect(callback, CONNECT_ONE_SHOT)
	file_dialog.close_requested.connect(func(): file_dialog.disconnect("dir_selected", callback))
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.popup_centered_ratio()

func open_file_picker(callback: Callable = func(): pass):
	file_dialog.file_selected.connect(callback, CONNECT_ONE_SHOT)
	file_dialog.close_requested.connect(func(): file_dialog.disconnect("file_selected", callback))
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered_ratio()
	
func save_file_picker(callback: Callable = func(): pass):
	#file_dialog.files_dropped
	
	file_dialog.file_selected.connect(callback, CONNECT_ONE_SHOT)
	file_dialog.close_requested.connect(func(): file_dialog.disconnect("file_selected", callback))
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.popup_centered_ratio()
#endregion
#func _on_folder_selected(dir_name: String):
	#print(dir_name)

func _on_image_picker_button_pressed() -> void:
	open_file_picker(load_and_change_visual_image)
func _on_load_default_images_pressed() -> void:
	visual_texture_rect.texture = default_texture

func _on_save_current_images_button_pressed() -> void:
	save_file_picker(save_visual_image)

## save the current image with shader using the capture viewport
func save_visual_image(output_image_path: String):
	await RenderingServer.frame_post_draw
	var image: Image = capture_sub_viewport.get_texture().get_image()
	#save_image(image, output_file_path)
	var error_code
	var output_image_ext = get_path_ext(output_image_path)
	#print(output_image_ext)
	#if output_image_path.ends_with(".png") or output_image_path.ends_with(".PNG"):
	if output_image_ext in valid_image_extension:
		error_code = image.save_png(output_image_path)
		print("saved to %s with error code %d: " % [output_image_path, error_code])
	return error_code
#func update_viewport_size_by_texture() -> void:
	#capture_viewport_container.size = 
	#pass

var permitted_image_extension = ["png", "jpg"]
func load_and_change_visual_image(image_path: String):
	var valid_extension = false
	for extension in permitted_image_extension:
		if image_path.ends_with(extension):
			valid_extension = true
			break
	if not valid_extension: return
	
	var new_texture: Texture = Utils.get_external_texture(image_path)
	visual_texture_rect.texture = new_texture
	capture_sprite_2d.texture = new_texture
	
func _on_shader_parameter_changed():
	## NOTE: parameter value update moved to shader setting template
	pass
	

#endregion


#region main process
var variations_each_image: int = 1
var running_progress_label_format = \
"""Status: Running
From:\t%s
To:\t%s
Processed: %d / %d images"""
var done_progress_label_format = \
"""Status: DONE (in %.2f seconds)
From:\t%s
To:\t%s
Processed: %d / %d images"""
@onready var progress_label: RichTextLabel = %ProgressLabel

var input_output_folders_map: Dictionary[String, String]:
	get: return paths_scroll_container.input_output_folders_map

var shader_paramters: Dictionary[String, Array]:
	get: return shader_setting.shader_parameters_range

func _on_start_button_pressed() -> void:
	if executor.is_executing:
		return
		
	var new_shader_material: ShaderMaterial = ShaderMaterial.new()
	new_shader_material.shader = current_shader_setting_ui.shader
	
	executor.execute_setup(
		shader_paramters, paths_scroll_container.input_output_folders_map,
		other_setting.current_setting["variation_count"],
		new_shader_material
	)
	executor.execute()
	
#endregion


#region main component UI


#endregion
