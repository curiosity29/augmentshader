## Database
extends Node

var _all_shaders: ResourceGroup = preload("res://Resource/ResourceGroup/all_shaders.tres")
var all_shaders: Array[ShaderResource]
var shader_map: Dictionary[String, ShaderResource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_all_shaders.load_all_into(all_shaders)
	for shader_resource: ShaderResource in all_shaders:
		shader_map[shader_resource.id] = shader_resource
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
