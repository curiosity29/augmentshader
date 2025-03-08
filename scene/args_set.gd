class_name ArgsSet
extends Control

signal attempt_invalid_input_folder(String)
signal attempt_invalid_output_folder(String)

var args: Dictionary[String, String]:
	get:
		var invalid_paths: bool = false
		if not input_line_edit or not output_line_edit: return {}
		var input_path: String = input_line_edit.text
		var output_path: String = output_line_edit.text 
		if input_path.is_empty() or output_path.is_empty(): return {}
		if not DirAccess.dir_exists_absolute(input_path):
			invalid_paths = true
			attempt_invalid_input_folder.emit()
		if not DirAccess.dir_exists_absolute(output_path):
			invalid_paths = true
			attempt_invalid_output_folder.emit()
		if invalid_paths: return {}
		
		return {input_path: output_path}

@onready var input_line_edit: LineEdit = %InputLineEdit
@onready var output_line_edit: LineEdit = %OutputLineEdit


#region file picker
func _on_input_file_picker_button_pressed() -> void:
	var file_picker = FileDialog.new()
	file_picker.use_native_dialog = true
	file_picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_picker.access = FileDialog.Access.ACCESS_FILESYSTEM
	file_picker.dir_selected.connect(
		func(selected_path: String): input_line_edit.text = selected_path
		, CONNECT_ONE_SHOT
	)
	file_picker.close_requested.connect(
		func():file_picker.queue_free()
		, CONNECT_ONE_SHOT
	)
	add_child(file_picker)
	file_picker.popup_centered_ratio()
	
func _on_output_file_picker_button_pressed() -> void:
	var file_picker = FileDialog.new()
	file_picker.use_native_dialog = true
	file_picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_picker.access = FileDialog.Access.ACCESS_FILESYSTEM
	file_picker.dir_selected.connect(
		func(selected_path: String): output_line_edit.text = selected_path
		, CONNECT_ONE_SHOT
	)
	file_picker.close_requested.connect(
		func(): file_picker.queue_free()
		, CONNECT_ONE_SHOT
	)
	add_child(file_picker)
	file_picker.popup_centered_ratio()
#endregion
