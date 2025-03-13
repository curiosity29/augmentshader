@tool
extends EditorScript
#extends Node

func extract_shader_parameters(shader_code: String) -> Dictionary:
	var parameters = {}
	var lines = shader_code.strip_edges().split("\n")

	for line in lines:
		line = line.strip_edges()
		RegEx
		if line.begins_with("uniform"):
			var pattern = "^uniform\\s+(\\w+)\\s+(\\w+)(?:\\s*:\\s*(\\w+)(?:\\(([^)]*)\\))?)?(?:\\s*=\\s*([^;]+))?;"
			var match = RegEx.new()
			#if match.compile(pattern).search(line):
				#var result = match.search(line)
#
				#var param_type = result.get_string(1)
				#var param_name = result.get_string(2)
				#var param_hint = result.get_string(3)
				#var hint_args = result.get_string(4)
				#var param_default = result.get_string(5)
#
				#parameters[param_name] = {
					#"type": param_type,
					#"default": param_default.strip_edges() if param_default else null,
					#"hint": param_hint,
					#"hint_args": hint_args.split(",") if hint_args else null
				#}

	return parameters

func _ready() -> void:
	#var result = extract_shader_parameters(shader_code)
	#print(result)
	pass
func _run() -> void:
	test()
#@export_tool_button("test") var test_action: Callable = test

func test():
	var new_shader: Shader = Shader.new()
	new_shader.code = shader_code
	
	for uniform_var in new_shader.get_shader_uniform_list():
		print(uniform_var)

#region sample shader code
# Example usage
var shader_code = '''
shader_type canvas_item;
uniform int blur_radius : hint_range(0, 10) = 0;  // Adjust the radius for blur intensity
uniform float middle_mult = 5.0;
uniform float gamma = 1.0;
uniform vec3 hsv_offset = vec3(0.0, 0.0, 0.0);
uniform float contrast: hint_range(-1.0, 5.0, 0.1) = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 rgb2hsv(vec3 c) {
	float c_max = max(c.r, max(c.g, c.b));
	float c_min = min(c.r, min(c.g, c.b));
	float delta = c_max - c_min;

	float h = 0.0;
	if (delta > 0.00001) {
		if (c_max == c.r) {
			h = mod((c.g - c.b) / delta, 6.0);
		} else if (c_max == c.g) {
			h = (c.b - c.r) / delta + 2.0;
		} else {
			h = (c.r - c.g) / delta + 4.0;
		}
		h /= 6.0;
		if (h < 0.0) h += 1.0;
	}

	float s = (c_max > 0.0) ? (delta / c_max) : 0.0;
	float v = c_max;

	return vec3(h, s, v);
}

vec3 hsv2rgb(vec3 _c) {
	vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
	return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}


void fragment() {
	//ivec2 int_tex_size = textureSize(TEXTURE, 0);
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	//vec2 tex_size = vec2(float(int_tex_size.x), float(int_tex_size.y));
	//vec2 texel_size = 1.0 / vec2(tex_size);

	vec4 color = vec4(0.0);
	int count = 0;

	// Loop over the neighboring pixels in a square grid (3x3)
	for (int x = -blur_radius; x <= blur_radius; x++) {
		for (int y = -blur_radius; y <= blur_radius; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_size;
			color += texture(TEXTURE, UV.xy + offset);
			count++;
		}
	}
	color += texture(TEXTURE, UV.xy) * (middle_mult - 1.0);
	// Calculate the average color
	color /= (float(count) + middle_mult - 1.0);

	// GAMMA
	color.rgb = vec3(pow(color.r, gamma), pow(color.g, gamma),pow(color.b, gamma));
	// contrast
	color = (color - 0.5) * (contrast) + 0.5;

	vec3 hsv_color = rgb2hsv(color.rgb);
	//hsv_color.rgb = fract(hsv_offset + hsv_color.rgb);
	hsv_color += hsv_offset;
	hsv_color = vec3(
		fract(hsv_color.r),
		min(1.0, hsv_color.g),
		min(1.0, hsv_color.b)
	);

	//hsv_color.gb = vec2(max(hsv_color.g + 1.0)hsv_offset.gb, vec2(1.0, 1.0));

	color.rgb = hsv2rgb(hsv_color.rgb);

	COLOR = color;

}


'''
#endregion
