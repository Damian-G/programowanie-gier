shader_type canvas_item;

uniform float predkosc = 5.0;
uniform float sila = 0.1;

void vertex() {
    float scale_factor = 1.0 + sin(TIME * predkosc) * sila;
    
    VERTEX *= scale_factor;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 color = tex;
    color.rgb += 0.15 * sin(TIME * predkosc); 
    COLOR = vec4(color.rgb, tex.a);
}