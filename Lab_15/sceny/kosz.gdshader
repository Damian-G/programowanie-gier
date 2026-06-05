shader_type canvas_item;

uniform float pulse_speed = 5.0;
uniform float pulse_intensity = 0.3;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = sin(TIME * pulse_speed) * pulse_intensity + (1.0 - pulse_intensity);
    COLOR = vec4(tex.rgb * pulse, tex.a);
}