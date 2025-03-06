extends Node


func get_external_texture(path: String) -> Texture:
	var img = Image.new()
	var error = img.load(path)
	#print("error: ", error)
	var texture = ImageTexture.create_from_image(img)
	#Image.create_from_image(img)
	return texture
