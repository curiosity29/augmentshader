@tool

class_name ShaderResourceUI
extends VBoxContainer
@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

@export var shader_resource: ShaderResource:
	set(value):
		shader_resource = value
		print("shader updated")
		if is_node_ready():
			update_display()
		

			
		#texture_rect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_display()
	pass # Replace with function body.
	
func update_display():
	texture_rect.texture = shader_resource.icon
	label.text = shader_resource.display_name
