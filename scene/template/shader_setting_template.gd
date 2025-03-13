class_name ShaderSettingTemplate
extends VBoxContainer

#region signal
signal current_parameter_changed
#endregion



#region base component ref
@export_group("init")
@export var shader: Shader
@export var shader_material: ShaderMaterial

@export_group("building blocks")
@export var float_arg_scene: PackedScene
@export var int_arg_scene: PackedScene
@export var vec3_arg_scene: PackedScene

#endregion

#region component ref
@onready var title_bar: HBoxContainer = %TitleBar
@onready var args_container: VBoxContainer = %ArgsContainer

#endregion

#region info/reminder
#TYPE_BOOL = 1
#TYPE_INT = 2
#TYPE_FLOAT = 3
#TYPE_STRING = 4
#TYPE_VECTOR2 = 5
#TYPE_VECTOR2I = 6
#TYPE_VECTOR3 = 9
#TYPE_VECTOR3I = 10

var args_metadata: Dictionary = {}#\
#{
	#"contrast": {
		#"type": 3,
		#"args_scene": []
	#}
#}
#endregion

func _ready() -> void:
	
	for property: Dictionary in shader.get_shader_uniform_list():
		## NOTE: not sure if directly modifying property cause any problem in get_shader_uniform_list
		var new_arg: FloatArgModifier
		var arg_nodes: Array[FloatArgModifier] = []
		var default_value
		var arg_name: String = property["name"]
		print(property)
		match property.type:
			2:
				#default_value = shader.get_default_texture_parameter(arg_name)
				#print(arg_name)
				#print(default_value)
				new_arg = int_arg_scene.instantiate()
				setup_float_arg(new_arg, property)
				arg_nodes.append(new_arg)
			3:
				new_arg = float_arg_scene.instantiate()
				setup_float_arg(new_arg, property)
				arg_nodes.append(new_arg)
			9:
				#var axis_arg_property: Dictionary = property.duplicate(true)
				property["name"] = arg_name + "\nx"
				new_arg = float_arg_scene.instantiate()
				setup_float_arg(new_arg, property)
				arg_nodes.append(new_arg)
				
				property["name"] = arg_name + "\ny"
				new_arg = float_arg_scene.instantiate()
				setup_float_arg(new_arg, property)
				arg_nodes.append(new_arg)
				
				property["name"] = arg_name + "\nz"
				new_arg = float_arg_scene.instantiate()
				setup_float_arg(new_arg, property)
				arg_nodes.append(new_arg)
			_:
				continue
		
		args_metadata[arg_name] = {
			"type": property["type"],
			"arg_nodes": arg_nodes
		}
		#new_arg.
	print(args_metadata)
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	
	for modifier in args_container.get_children():
		if modifier is FloatArgModifier:
			modifier.current_value_changed.connect(on_arg_value_changed)
	
	
func setup_float_arg(scene: FloatArgModifier, property: Dictionary) -> void:
	args_container.add_child(scene)
	scene.arg_name = property["name"]
	var hint_string: String = property["hint_string"]
	var hint_string_array: PackedStringArray = hint_string.split(",")
	if hint_string_array.size() == 3:
		scene.hard_min_value = float(hint_string_array[0])
		scene.min_value = float(hint_string_array[0])
		
		scene.hard_max_value = float(hint_string_array[1])
		scene.max_value = float(hint_string_array[1])
		
		scene.snap_step_size = float(hint_string_array[2])
		scene.current_value = property["hint"]
	else:
		print("Unintended: invalid hint format")
		
func on_arg_value_changed():
		#print()
	var new_shader_parameter: Dictionary = shader_parameters_current
	for parameter_name in new_shader_parameter:
		#visual_material.set_shader_parameter(parameter_name, new_shader_parameter[parameter_name])
		shader_material.set_shader_parameter(parameter_name, new_shader_parameter[parameter_name])
		#print(parameter_name, ", ", new_shader_parameter[parameter_name])
		#print(visual_texture_rect.material.get_shader_parameter(parameter_name))
	current_parameter_changed.emit()
#region for external usage
var shader_parameters_range: Dictionary[String, Array]:
	get:
		var result: Dictionary[String, Array] = {}
		var arg_modifier: FloatArgModifier
		for arg_name in args_metadata:
			var arg_metadata: Dictionary = args_metadata[arg_name]
			match arg_metadata["type"]:
				2:
					arg_modifier = arg_metadata["arg_nodes"][0]
					result[arg_name] = [arg_modifier.min_value, arg_modifier.max_value]
				3:
					arg_modifier = arg_metadata["arg_nodes"][0]
					result[arg_name] = [arg_modifier.min_value, arg_modifier.max_value]
				9:
					var min_value: Vector3
					var max_value: Vector3
					arg_modifier = arg_metadata["arg_nodes"][0]
					min_value.x = arg_modifier.min_value
					max_value.x = arg_modifier.max_value
					
					arg_modifier = arg_metadata["arg_nodes"][1]
					min_value.y = arg_modifier.min_value
					max_value.y = arg_modifier.max_value
					
					arg_modifier = arg_metadata["arg_nodes"][2]
					min_value.z = arg_modifier.min_value
					max_value.z = arg_modifier.max_value
					
					result[arg_name] = [min_value, max_value]
				_:
					continue
		#for arg_modifier in args_container.get_children():
			#if not (arg_modifier is FloatArgModifier): continue
			#match arg_metadata[arg]
		return result

var shader_parameters_current: Dictionary:
	get: 
		var result: Dictionary = {}
		var arg_modifier: FloatArgModifier
		for arg_name in args_metadata:
			var arg_metadata: Dictionary = args_metadata[arg_name]
			match arg_metadata["type"]:
				2:
					arg_modifier = arg_metadata["arg_nodes"][0]
					result[arg_name] = arg_modifier.current_value
				3:
					arg_modifier = arg_metadata["arg_nodes"][0]
					result[arg_name] = arg_modifier.current_value
				9:
					var current_value: Vector3
					arg_modifier = arg_metadata["arg_nodes"][0]
					current_value.x = arg_modifier.current_value
					
					arg_modifier = arg_metadata["arg_nodes"][1]
					current_value.y = arg_modifier.current_value
					
					arg_modifier = arg_metadata["arg_nodes"][2]
					current_value.z = arg_modifier.current_value
					
					result[arg_name] = current_value
				_:
					continue
		#for arg_modifier in args_container.get_children():
			#if not (arg_modifier is FloatArgModifier): continue
			#match arg_metadata[arg]
		return result

#endregion
