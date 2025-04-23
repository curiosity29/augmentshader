## class_name Helper (global class)
extends Node

func read_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		return {}
	return json.data