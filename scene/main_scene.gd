extends Node2D



#region component ref
@onready var file_dialog: FileDialog = $FileDialog

@onready var visual_sub_viewport: SubViewport = %VisualSubViewport
@onready var capture_sub_viewport: SubViewport = %CaptureSubViewport
@onready var visual_texture_rect: TextureRect = %VisualTextureRect
@onready var capture_sprite_2d: Sprite2D = %CaptureSprite2D

var visual_material: ShaderMaterial:
	get: return visual_texture_rect.material

@onready var shader_setting: ShaderSetting = %ShaderSetting
@onready var paths_scroll_container: PathArgsContainer = %PathsScrollContainer
@onready var custom_shader_component: CustomShaderContainer = %CustomShaderComponent
@onready var executor: Executor = $Executor

#endregion

#region vars

@export var default_texture: Texture

#endregion

#region ready and update
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#open_folder_picker()
	shader_setting.current_parameter_changed.connect(_on_shader_parameter_changed)
	_on_shader_parameter_changed()
	executor.folder_progress_updated.connect(_on_execute_progress_updated.bind(false))
	executor.done_augment_folder.connect(_on_execute_progress_updated.bind(true))
	custom_shader_component.shader_updated.connect(update_custom_shader)
	#visual_texture_rect.material = custom_shader_material

func _on_execute_progress_updated(processed_count: int, total_count: int, is_done: bool = false):
	if is_done:
		progress_label.text = done_progress_label_format % [
			executor.current_input_folder, executor.current_output_folder,
			processed_count, total_count
		]
	else:
		progress_label.text = running_progress_label_format % [
			executor.current_input_folder, executor.current_output_folder,
			processed_count, total_count
		]

func update_custom_shader():
	visual_texture_rect.material = custom_shader_component.custom_shader_material

#endregion


#region UI
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

#func _on_folder_selected(dir_name: String):
	#print(dir_name)

func _on_image_picker_button_pressed() -> void:
	open_file_picker(load_and_change_visual_image)
func _on_load_default_images_pressed() -> void:
	visual_texture_rect.texture = default_texture



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
	#print()
	var new_shader_parameter: Dictionary = shader_setting.shader_parameters_current
	for parameter_name in new_shader_parameter:
		#visual_material.set_shader_parameter(parameter_name, new_shader_parameter[parameter_name])
		visual_texture_rect.material.set_shader_parameter(parameter_name, new_shader_parameter[parameter_name])
		#print(parameter_name, ", ", new_shader_parameter[parameter_name])
		#print(visual_texture_rect.material.get_shader_parameter(parameter_name))
	
	
#endregion


#region main process
var variations_each_image: int = 1
var running_progress_label_format = \
"""Status: Running
From:\t%s
To:\t%s
Processed: %d / %d images"""
var done_progress_label_format = \
"""Status: DONE
From:\t%s
To:\t%s
Processed: %d / %d images"""
@onready var progress_label: RichTextLabel = %ProgressLabel

var input_output_folders_map: Dictionary[String, String]:
	get: return paths_scroll_container.input_output_folders_map

var shader_paramters: Dictionary[String, Array]:
	get: return shader_setting.shader_parameters_range

func _on_start_button_pressed() -> void:
	executor.execute_setup(
		shader_paramters, paths_scroll_container.input_output_folders_map
	)
	executor.execute()
	
#endregion


#region main component UI


#endregion
