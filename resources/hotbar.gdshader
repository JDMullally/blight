shader_type canvas_item;

uniform float speed = 2.0;
uniform vec4 dark_red : source_color = vec4(0.4, 0.0, 0.0, 1.0);
uniform vec4 light_red : source_color = vec4(1.0, 0.3, 0.3, 1.0);

void fragment() {
	float t = (sin(TIME * speed) + 1.0) * 0.5;

	vec4 final_color = mix(dark_red, light_red, t);

	COLOR = final_color;
}