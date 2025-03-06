extends Node2D

@onready var file_dialog: FileDialog = $FileDialog

@onready var visual_sub_viewport: SubViewport = %VisualSubViewport
@onready var capture_sub_viewport: SubViewport = %CaptureSubViewport
@onready var visual_texture_rect: TextureRect = %VisualTextureRect
@onready var capture_sprite_2d: Sprite2D = %CaptureSprite2D

@export var visual_material: ShaderMaterial:
	get: return visual_texture_rect.material

@onready var shader_setting: ShaderSetting = %ShaderSetting
@onready var paths_scroll_container: PathArgsContainer = %PathsScrollContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#open_folder_picker()
	shader_setting.current_parameter_changed.connect(on_shader_parameter_changed)
	on_shader_parameter_changed()

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
var progress_label_format = \
""" Running %s
Progress:
%d / %d images
"""
@onready var progress_label: RichTextLabel = %ProgressLabel

var input_output_folders_map: Dictionary[String, String]:
	get: return paths_scroll_container.input_output_folders_map

var shader_paramters: Dictionary[String, Array]:
	get: return shader_setting.shader_parameters_range
	

func get_random_shader_parameter():
	var blur_radius_range = shader_paramters["blur_radius"]
	var blur_radius = randi_range(blur_radius_range[0], blur_radius_range[1])
	
	var gamma_range = shader_paramters["gamma"]
	var gamma = randf_range(gamma_range[0], gamma_range[1])
	
	var hsv_offset_range = shader_paramters["hsv_offset"]
	var hsv_offset = Vector3(
		randf_range(hsv_offset_range[0].x, hsv_offset_range[1].x), 
		randf_range(hsv_offset_range[0].y, hsv_offset_range[1].y), 
		randf_range(hsv_offset_range[0].z, hsv_offset_range[1].z), 
	)
	
	var contrast_range = shader_paramters["contrast"]
	var contrast = randf_range(contrast_range[0], contrast_range[1])
	return {
		"blur_radius": blur_radius,
		"gamma": gamma,
		"hsv_offset": hsv_offset,
		"contrast": contrast,
	}
# Called when the node enters the scene tree for the first time.
#func start_augment() -> void:
	##sprite_2d.texture = load(image_input_path)
	##get_tree().create_timer(0.05, false).timeout.connect(update_viewport_size)
	#
	#get_tree().create_timer(0.1, false).timeout.connect(main)

signal done_augment_folder
func main():
	#assert(len(input_folders) == len(output_folders))
	for input_folder_path in input_output_folders_map:
		var output_folder_path: String = input_output_folders_map[input_folder_path]
		print("running for ", input_folder_path)
		augment_folder(input_folder_path, output_folder_path)
		await done_augment_folder

func update_viewport_size():
	#var texture_size: Vector2 = sprite_2d.get_rect().size
	#get_viewport().size = texture_size
	#sprite_2d.position = texture_size/2
	
	var texture_size: Vector2 = capture_sprite_2d.get_rect().size
	capture_sub_viewport.size = texture_size
	capture_sprite_2d.position = texture_size/2
	#print("texture size: ", texture_size)
	
	
func get_external_texture(path: String) -> Texture:
	var img = Image.new()
	var error = img.load(path)
	#print("error: ", error)
	var texture = ImageTexture.create_from_image(img)
	#Image.create_from_image(img)
	return texture
	
func augment_folder(input_folder_path: String, output_folder_path: String):
	DirAccess.make_dir_recursive_absolute(output_folder_path)
	var image_files = get_image_files_in_folder(input_folder_path)
	var total_files: int = len(image_files)
	#print(image_files)
	var image_index: int = 0
	for image_path in image_files:
		progress_label.text = progress_label_format % [input_folder_path, image_index, total_files]
		var texture: Texture =  get_external_texture(image_path)
		var image_name: String = image_path.split("/")[-1]
		
		#sprite_2d.texture = texture#load(image_path)
		capture_sprite_2d.texture = texture
		#print(texture.get_height())
		#print()
		#RenderingServer.frame_pre_draw.connect(update_viewport_size, CONNECT_ONE_SHOT)
		RenderingServer.frame_pre_draw.connect(update_viewport_size, CONNECT_ONE_SHOT)
		#get_tree().create_timer(0.05, false).timeout.connect(update_viewport_size, CONNECT_ONE_SHOT)
		
		#await get_tree().create_timer(0.1, false).timeout#.connect(augment_image.bind(image_path))
		#print("img path: ", image_path)
		RenderingServer.frame_post_draw.connect(augment_image.bind(output_folder_path, image_name), CONNECT_ONE_SHOT)
		#augment_image(image_path)
		#continue
		#augment_image()
		await done_augment
		progress_label.text = progress_label_format % [output_folder_path, image_index, total_files]
		image_index += 1
		#print(sub_viewport.size)
		break
	progress_label.text = progress_label_format % [output_folder_path, image_index, total_files]
	done_augment_folder.emit()
signal done_augment
func augment_image(output_folder_path: String, image_name: String = ""):
	if not output_folder_path.ends_with("/"):
		output_folder_path += "/"
	for index in range(variations_each_image):
		var shader_parameter = get_random_shader_parameter()
		#await get_tree().create_timer(0.01, false).timeout
		for key in shader_parameter:
			
			var material = capture_sprite_2d.material
			#var material = sprite_2d.material
			material.set_shader_parameter(key, shader_parameter[key])
			#await RenderingServer.frame_post_draw
			
		var file_path: String = "%s%d_%s" % [output_folder_path, index, image_name]
		#print(file_path)
		await capture_image(file_path)
	done_augment.emit()
	
func capture_image(output_path: String):
	await RenderingServer.frame_post_draw
	#var texture: Texture = get_viewport().get_texture()
	#var texture: Texture = sub_viewport.get_texture()
	#var image: Image = texture.get_image()
	#var image: Image = get_viewport().get_texture().get_image()
	var image: Image = capture_sub_viewport.get_texture().get_image()
	#save_image(image, output_file_path)
	var ok
	if output_path.ends_with(".png") or output_path.ends_with(".PNG"):
		ok = image.save_png(output_path)
	elif output_path.ends_with(".jpg"):
		ok = image.save_jpg(output_path)
	if not (ok == OK):
		print("not ok: ", output_path)
	#if image.save_png(output_path) == OK:
		##print("Image saved successfully at: " + output_path)
		#pass
	#else:
		#print("Failed to save the image ", output_path)
	
	
func save_image(image: Image, file_path: String):
	# Save the captured image to the specified file path
	if image.save_png(file_path) == OK:
		print("Image saved successfully at: " + file_path)
	else:
		print("Failed to save the image.")
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func get_image_files_in_folder(folder_path: String) -> Array:
	var files = []
	var dir = DirAccess.open(folder_path)

	dir.list_dir_begin()
		
	while true:
		var file_name = dir.get_next()

		if file_name == "":
			break
		
		# Check if it's a file and has a .png or .jpg extension
		if (file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".PNG")):
			files.append(folder_path + file_name)
			
	dir.list_dir_end()
	
	return files


#endregion
