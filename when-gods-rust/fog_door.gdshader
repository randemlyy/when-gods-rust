shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 fog_color : source_color = vec4(0.78, 0.82, 0.90, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.6;
uniform float noise_scale : hint_range(0.5, 8.0) = 2.5;
uniform float scroll_speed : hint_range(0.0, 1.0) = 0.12;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float t = TIME * scroll_speed;

	float n = value_noise(uv + vec2(t, -t * 0.6));
	n = mix(n, value_noise(uv * 2.0 + vec2(-t * 1.4, t * 0.9)), 0.45);
	n = clamp(n * 1.6, 0.0, 1.0);

	float edge_x = smoothstep(0.0, 0.12, UV.x) * (1.0 - smoothstep(0.88, 1.0, UV.x));
	float edge_y = smoothstep(0.0, 0.10, UV.y) * (1.0 - smoothstep(0.90, 1.0, UV.y));
	float ground_bias = mix(0.55, 1.0, UV.y);

	ALBEDO = fog_color.rgb;
	ALPHA = n * density * edge_x * edge_y * ground_bias;
}
