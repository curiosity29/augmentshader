extends Node2D

#region base component ref
@export var shader_setting_template_scene: PackedScene
@export var visible_toggle_button_scene: PackedScene
@export var default_shader: Shader
@export var default_shader_material: ShaderMaterial

#endregion

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
@onready var other_setting: OtherSetting = $ScrollContainer/ArgsComponentContainer/OtherSetting
@onready var executor: Executor = $Executor
@onready var args_component_container: VBoxContainer = %ArgsComponentContainer

var current_shader_setting_visible_button: VisibleToggleButton
var current_shader_setting_ui: ShaderSettingTemplate
	
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
	executor.folder_progress_updated.connect(_on_execute_progress_updated)
	executor.done_execute.connect(_on_execute_done)
	custom_shader_component.shader_updated.connect(update_custom_shader)
	
	## set default shader
	custom_shader_component.shader_code_edit.text = default_shader.code
	custom_shader_component.update_custom_shader()
	#update_custom_shader()
	
	#visual_texture_rect.material = custom_shader_material
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

func update_custom_shader():
	#visual_texture_rect.material = custom_shader_component.custom_shader_material
	update_new_shader_ui(custom_shader_component.custom_shader, custom_shader_component.custom_shader_material)
	visual_texture_rect.material = current_shader_setting_ui.shader_material

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
