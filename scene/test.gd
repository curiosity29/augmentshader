extends Node2D

signal done_augment_folder
#@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sub_viewport: SubViewport = %SubViewport
@onready var viewport_sprite_2d: Sprite2D = %ViewportSprite2D
@onready var progress_label: RichTextLabel = %ProgressLabel

var progress_label_format = \
""" Running %s
Progress:
%d / %d images
"""

#var base_output_path: String = "output.png"
#var base_folder_path: String = "user://output/test1/"
#var image_input_path: String = "res://images/-0.79_file_サンプル_(2)-1.jpg"
#var image_input_path: String = "res://images/input.PNG"
#var input_folder = "user://input/test1/"
#var input_folder = "C:/Users/admin/AppData/Roaming/Godot/app_userdata/augmentShader/input/test1"
var input_folders: Array[String] = [
	"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/egs_custom_2025_03_07/train",
	"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/egs_custom_2025_03_07/val",
	#"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05/test3/",
	#"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05/test3/",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined/train",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined/val",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined/test"
]
var output_folders: Array[String] = [
	"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/egs_custom_2025_03_07_shadered/train",
	"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/egs_custom_2025_03_07_shadered/val",	#"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05_shadered/test3/",
	#"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05_testing/test3/",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined_shadered/train",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined_shadered/val",
	#"C:/Users/admin/Projects/table_rotation/datasets/reviewing_2025_02_26/no_table_splited_combined_shadered/test"
]

var input_output_folders_map = {
	"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05/test3/": \
		"C:/Users/admin/Projects/table_rotation/datasets/augmented_Mar5/generated_v3/egs_and_no_table_2025_03_05_testing/test3/",
	
	
}

var shader_paramters: Dictionary[String, Array] = {
	"blur_radius": [0, 2],
	"gamma": [0.8, 1.3],
	"hsv_offset": [Vector3(-0.5, -0.15, -0.1), Vector3(0.5, 0.15, 0.1)],
	"contrast": [0.8, 1.3],
}

@export var variations_each_image: int = 1

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
func _ready() -> void:
	#sprite_2d.texture = load(image_input_path)
	#get_tree().create_timer(0.05, false).timeout.connect(update_viewport_size)
	
	get_tree().create_timer(0.1, false).timeout.connect(main)


func main():
	assert(len(input_folders) == len(output_folders))
	for index in range(len(input_folders)):
		var input_folder_path: String = input_folders[index]
		var output_folder_path: String = output_folders[index]
		if not input_folder_path.ends_with("/"):
			input_folder_path += "/"
		if not output_folder_path.ends_with("/"):
			output_folder_path += "/"
		print("running for ", input_folder_path)
		augment_folder(input_folder_path, output_folder_path)
		await done_augment_folder
	get_tree().quit()
func update_viewport_size():
	#var texture_size: Vector2 = sprite_2d.get_rect().size
	#get_viewport().size = texture_size
	#sprite_2d.position = texture_size/2
	
	var texture_size: Vector2 = viewport_sprite_2d.get_rect().size
	sub_viewport.size = texture_size
	viewport_sprite_2d.position = texture_size/2
	#print("texture size: ", texture_size)
	
	
func get_external_texture(path: String) -> Texture:
	var img = Image.new()
	var error = img.load(path)
	#print(path)
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
		viewport_sprite_2d.texture = texture
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
			
			var material = viewport_sprite_2d.material
			#var material = sprite_2d.material
			material.set_shader_parameter(key, shader_parameter[key])
			#await RenderingServer.frame_post_draw
			
		var file_path: String = "%s%d_%s" % [output_folder_path, index, image_name]
		#print(file_path)
		#await 
		capture_image(file_path)
	done_augment.emit()
	
func capture_image(output_path: String):
	#await RenderingServer.frame_post_draw
	#var texture: Texture = get_viewport().get_texture()
	#var texture: Texture = sub_viewport.get_texture()
	#var image: Image = texture.get_image()
	#var image: Image = get_viewport().get_texture().get_image()
	var image: Image = sub_viewport.get_texture().get_image()
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
