@tool
extends EditorPlugin

var button: Button
func _enter_tree() -> void:
	button = Button.new()
	button.text = "Fold all regions"
	var base = EditorInterface.get_script_editor()
	base.get_child(0).get_child(0).add_child(button)
	button.move_to_front()
	button.pressed.connect(func():
		var editor = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
		if editor is CodeEdit:
			for i in editor.get_line_count():
				if editor.is_line_code_region_start(i):
					#if editor.is_line_folded(i):
						#editor.unfold_line(i)
					#else:
					editor.fold_line(i)
	)
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	button.queue_free()
	pass
	

#
#func _run() -> void:
	#var button = Button.new()
	#button.text = "Fold/Unfold all regions"
	#var base = EditorInterface.get_script_editor()
	#base.get_child(0).get_child(0).add_child(button)
	#button.move_to_front()
	#button.pressed.connect(func():
		#var editor = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
		#if editor is CodeEdit:
			#for i in editor.get_line_count():
				#if editor.is_line_code_region_start(i):
					#if editor.is_line_folded(i):
						#editor.unfold_line(i)
					#else:
						#editor.fold_line(i)
	#)
	
	
