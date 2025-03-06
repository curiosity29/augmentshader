class_name PathArgsContainer
extends VBoxContainer

@onready var args_set_container: VBoxContainer = %ArgsSetContainer


var input_output_folders_map: Dictionary[String, String]:
	get:
		## BUG-ish: can't repeat pair
		var pairs: Dictionary[String, String] = {}
		for args_set: ArgsSet in args_set_container.get_children():
			pairs.merge(args_set.args)
		return pairs


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
