class_name PathArgsContainer
extends VBoxContainer

@onready var args_set_container: VBoxContainer = %ArgsSetContainer


var input_output_folders_map: Dictionary[String, String]:
	get:
		## BUG-ish: can't repeat pair
		var pairs: Dictionary[String, String] = {}
		for args_set: ArgsSet in args_set_container.get_children():
			if args_set.args.is_empty(): continue
			pairs.merge(args_set.args)
		return pairs
