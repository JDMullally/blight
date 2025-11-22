shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_alpha = 1.0;

void fragment() {
    COLOR = vec4(tint_color.rgb, tint_alpha);
}