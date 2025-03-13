class_name ShaderSettingTemplate
extends VBoxContainer

#region signal
signal current_parameter_changed
#endregion



#region base component ref
@export_group("init")
@export var shader: Shader
@export var shader_material: ShaderMaterial# = ShaderMaterial.new()

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
# Vec4 12
# Vec4i 13
var vector_prop_name: Array[String] = ["x", "y", "z", "w"]
var vector_prop_name_addon: Array[String] = ["\nx", "\ny", "\nz", "\nw"]
var args_metadata: Dictionary = {}#\
#{
	#"contrast": {
		#"type": 3,
		#"args_scene": []
	#}
#}
#endregion
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	
	
	#shader_material = ShaderMaterial.new()
	#shader_material.shader = shader
	#print(shader_material)
	## NOTE: NO FUCKING IDEA WHY THE MATERIAL PARAMETER IS NULL INSTEAD OF THE DEFAULT AFTER INIT
	## WORK AROUND: save it to some random place before poking it (see in the custom shader component)
	#var texture_rect = TextureRect.new()
	#print("gamma: ", shader_material.get_shader_parameter("gamma"))
	for property: Dictionary in shader.get_shader_uniform_list():
		## NOTE: not sure if directly modifying property cause any problem in get_shader_uniform_list
		# var new_arg: FloatArgModifier
		#print(property)
		var arg_nodes: Array[FloatArgModifier] = []
		var arg_name: String = property["name"]
		match property.type:
			2:	# int
				arg_nodes = setup_float_arg(int_arg_scene, property, 1)
			3:	# float
				arg_nodes = setup_float_arg(float_arg_scene, property, 1)
			5:	# vec2
				arg_nodes = setup_float_arg(float_arg_scene, property, 2)
			6:	#ivec2
				arg_nodes = setup_float_arg(int_arg_scene, property, 2)	
			9:	#vec3
				arg_nodes = setup_float_arg(float_arg_scene, property, 3)
			10:	#ivec3
				arg_nodes = setup_float_arg(int_arg_scene, property, 3)
			12:	#vec4
				arg_nodes = setup_float_arg(float_arg_scene, property, 4)
			13:	#ivec4
				arg_nodes = setup_float_arg(int_arg_scene, property, 4)
			20:	#color -> vec3 or vec4
				if property["hint"] == 21:
					arg_nodes = setup_float_arg(float_arg_scene, property, 3)
				else:
					arg_nodes = setup_float_arg(float_arg_scene, property, 4)
			
			_:
				continue
		
		args_metadata[arg_name] = {
			"type": property["type"],
			"arg_nodes": arg_nodes
		}
		#new_arg.
	#print(args_metadata)

	
	
	for modifier in args_container.get_children():
		if modifier is FloatArgModifier:
			modifier.current_value_changed.connect(on_arg_value_changed)
	
	
func setup_float_arg(base_scene: PackedScene, property: Dictionary, count: int) -> Array[FloatArgModifier]:
	if shader_material.shader != shader:
		push_error("Error: need to set the shader material first")
	var arg_nodes: Array[FloatArgModifier] = []
	for arg_index: int in range(count):
		var arg_name: String = property["name"] + vector_prop_name_addon[arg_index] if count > 1 else property["name"]
		var new_arg: FloatArgModifier = base_scene.instantiate()
		args_container.add_child(new_arg)
		new_arg.arg_name = arg_name
		var hint_string: String = property["hint_string"]
		var hint_string_array: PackedStringArray = hint_string.split(",")
		if hint_string_array.size() >= 2:
			new_arg.hard_min_value = float(hint_string_array[0])
			new_arg.min_value = float(hint_string_array[0])
			
			new_arg.hard_max_value = float(hint_string_array[1])
			new_arg.max_value = float(hint_string_array[1])
		if hint_string_array.size() >= 3:
			new_arg.snap_step_size = float(hint_string_array[2])
		var default_value = shader_material.get_shader_parameter(property["name"])
		new_arg.current_value = default_value[vector_prop_name[arg_index]] if count > 1 else default_value
		Vector3()
		#else:
			#print("Unintended: invalid hint format")

		arg_nodes.append(new_arg)
	return arg_nodes
			
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
