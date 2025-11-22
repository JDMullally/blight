shader_type particles;

uniform int point_count = 0;
uniform vec2 points[256]; // max points; raise if needed
uniform float spawn_jitter = 0.0; // how far we can jitter around each point

void start() {

}
