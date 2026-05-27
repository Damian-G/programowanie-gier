shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.75, 0.2, 0.6);
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float glow_radius : hint_range(0.0, 10.0) = 3.0;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.6);
uniform float shine_speed : hint_range(0.0, 5.0) = 1.5;
uniform float shine_width : hint_range(0.01, 0.5) = 0.08;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);
    
    vec2 size = TEXTURE_PIXEL_SIZE * glow_radius;
    float glow = 0.0;
    glow += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    glow += texture(TEXTURE, UV - vec2(size.x, 0.0)).a;
    glow += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    glow += texture(TEXTURE, UV - vec2(0.0, size.y)).a;
    glow += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    glow += texture(TEXTURE, UV - vec2(size.x, size.y)).a;
    glow /= 6.0; // Uśredniamy

    // 2. MATEMATYKA BŁYSKU
    float position = UV.x - UV.y - mod(TIME * shine_speed, 2.0) + 1.0;
    float shine = 1.0 - smoothstep(0.0, shine_width, abs(position));

    if (sprite_color.a > 0.1) {
        COLOR = mix(sprite_color, shine_color, shine * shine_color.a);
    } else {
        COLOR = vec4(glow_color.rgb, glow * glow_intensity * glow_color.a);
    }
}