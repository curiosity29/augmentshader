class_name OtherSetting
extends VBoxContainer

@onready var variation_count_modifier: FloatArgModifier = $VariationCountModifier

var current_setting: Dictionary:
	get:
		return {
			"variation_count": variation_count_modifier.current_value
		}
