shader_type spatial;

uniform sampler2D depth_texture: hint_depth_texture, repeat_disable;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

uniform float depth_strength = 24.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	float limit = texture(depth_texture, uv).r;

	ALBEDO.rgb = texture(screen_texture, uv).rgb * limit*depth_strength;
	ALBEDO.rgb += vec3(1.0, 0.3, 0.0)/80.0;
}

