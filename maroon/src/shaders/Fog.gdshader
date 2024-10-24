shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_texture: hint_depth_texture, repeat_disable;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

uniform float depth_strength = 24.0;

void fragment() {

	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(screen_texture, uv);

	float limit = texture(depth_texture, uv).r;

	ALBEDO.rgb = screen_color.rgb * limit*depth_strength;
	ALBEDO.rgb += vec3(1.0, 0.3, 0.0)/80.0;
	ALPHA = screen_color.a;
}

