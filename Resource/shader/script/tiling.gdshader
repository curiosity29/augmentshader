shader_type canvas_item;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform float uv_offset: hint_range(0.0, 1.0, 0.01) = 0.0;

void vertex() {
	UV = UV * tiling + uv_offset;
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
