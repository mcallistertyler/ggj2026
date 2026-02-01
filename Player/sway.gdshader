shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform float alpha_scissor : hint_range(0.0, 1.0, 0.01) = 0.5;

uniform sampler2D tex : filter_nearest, source_color;
uniform float sway_strength : hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float sway_speed : hint_range(0.5, 5.0, 0.1) = 2.0;

void vertex() {
	// Sway effect - anchored at bottom (1.0 - UV.y), top moves more
	float sway_amount = (1.0 - UV.y) * sway_strength;
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * sway_speed) * sway_amount;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * sway_speed) * sway_amount * 0.5;

	// Extract scale from MODEL_MATRIX
	vec3 scale = vec3(
		length(MODEL_MATRIX[0].xyz),
		length(MODEL_MATRIX[1].xyz),
		length(MODEL_MATRIX[2].xyz)
	);

	// Y-axis billboard - always face camera, preserving scale
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
	vec3 forward = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(right * scale.x, 0.0),
		vec4(0.0, scale.y, 0.0, 0.0),
		vec4(forward * scale.z, 0.0),
		MODEL_MATRIX[3]
	);
}

void fragment() {
	vec4 col = texture(tex, UV);
	ALBEDO = col.rgb;
	ALPHA = col.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}