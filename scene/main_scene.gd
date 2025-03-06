extends Node2D

@onready var file_dialog: FileDialog = $FileDialog

@onready var visual_sub_viewport: SubViewport = %VisualSubViewport
@onready var capture_sub_viewport: SubViewport = %CaptureSubViewport
@onready var visual_texture_rect: TextureRect = %VisualTextureRect
@onready var capture_sprite_2d: Sprite2D = %CaptureSprite2D

@export var visual_material: ShaderMaterial

@onready var shader_setting: ShaderSetting = %ShaderSetting

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#open_folder_picker()
	shader_setting.current_parameter_changed.connect(on_shader_parameter_changed)
	pass # Replace with function body.

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
	open_folder_picker(load_and_change_visual_image)

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
	
func on_shader_parameter_changed():
	var new_shader_parameter: Dictionary = shader_setting.shader_parameters_current
	for parameter_name in new_shader_parameter:
		visual_material.set_shader_parameter(parameter_name, new_shader_parameter[parameter_name])
	
	
	
