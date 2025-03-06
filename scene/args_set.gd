extends Control

@onready var output_line_edit: LineEdit = $VBoxContainer/Args2/OutputLineEdit
@onready var input_line_edit: LineEdit = $VBoxContainer/Args1/InputLineEdit

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
	file_picker.files_selected.connect(
		func(selected_path: String):
			input_line_edit.text = selected_path
	)
	file_picker.close_requested.connect(
		func():
			file_picker.queue_free()
	)
	
	
func _on_output_file_picker_button_pressed() -> void:
	var file_picker = FileDialog.new()
	file_picker.use_native_dialog = true
	file_picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_picker.files_selected.connect(
		func(selected_path: String):
			output_line_edit.text = selected_path
	)
	file_picker.close_requested.connect(
		func():
			file_picker.queue_free()
	)
