shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.03, 0.01, 0.07, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.10, 0.02, 0.15, 1.0);

uniform float small_star_density = 0.004;
uniform float big_star_density = 0.0012;

float random(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {

    vec2 uv = SCREEN_UV;

    // ===== TŁO =====
    vec3 bg = mix(bottom_color.rgb, top_color.rgb, uv.y);

    // ===== MGŁAWICA =====
    float nebula =
        sin(uv.x * 5.0 + TIME * 0.02) *
        sin(uv.y * 3.0);

    nebula +=
        sin(uv.x * 9.0 - TIME * 0.01) *
        cos(uv.y * 7.0);

    nebula *= 0.03;

    bg += vec3(0.18, 0.04, 0.25) * nebula;

    // ===== MAŁE GWIAZDY =====
    vec2 small_grid = floor(uv * 220.0);

    float small_rand = random(small_grid);

    float small_star =
        step(1.0 - small_star_density, small_rand);

    // losowa pozycja gwiazdy w gridzie
    vec2 small_offset = vec2(
        random(small_grid),
        random(small_grid + 15.0)
    );

    vec2 small_local_uv =
        fract(uv * 220.0) - small_offset;

    float small_shape =
        1.0 - smoothstep(0.0, 0.08, length(small_local_uv));

    // migotanie
    float small_twinkle =
        sin(
            TIME * (1.0 + random(small_grid) * 2.0)
            + random(small_grid + 5.0) * 10.0
        ) * 0.15 + 0.85;

    small_star *= small_shape * small_twinkle * 0.7;

    // ===== DUŻE GWIAZDY =====
    vec2 big_grid = floor(uv * 80.0);

    float big_rand = random(big_grid + 42.0);

    float big_star =
        step(1.0 - big_star_density, big_rand);

    vec2 big_offset = vec2(
        random(big_grid + 2.0),
        random(big_grid + 8.0)
    );

    vec2 big_local_uv =
        fract(uv * 80.0) - big_offset;

    float big_shape =
        1.0 - smoothstep(0.0, 0.15, length(big_local_uv));

    float big_twinkle =
        sin(
            TIME * 0.8
            + random(big_grid) * 20.0
        ) * 0.2 + 0.8;

    big_star *= big_shape * big_twinkle;

    // ===== FINAL =====
    vec3 stars =
        vec3(small_star * 0.8) +
        vec3(big_star);

    COLOR = vec4(bg + stars, 1.0);
}