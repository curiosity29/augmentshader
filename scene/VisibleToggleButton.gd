class_name VisibleToggleButton
extends Button

@export var target_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_mode = true
	toggled.connect(on_toggle)
	#button_pressed = false
	on_toggle(button_pressed)

func on_toggle(toggled_on: bool):
	target_node.visible = toggled_on
