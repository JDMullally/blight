shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_alpha = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    tex.rgb *= tint_color.rgb;
    tex.a *= tint_alpha;
    COLOR = tex;
}