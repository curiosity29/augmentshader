class_name ArgsSet
extends Control

var args: Dictionary[String, String]

@onready var input_line_edit: LineEdit = %InputLineEdit
@onready var output_line_edit: LineEdit = %OutputLineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
