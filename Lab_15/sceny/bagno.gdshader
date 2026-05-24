shader_type canvas_item;

uniform vec4 color_deep : source_color = vec4(0.1, 0.3, 0.1, 1.0);
uniform vec4 color_light : source_color = vec4(0.2, 0.6, 0.2, 1.0);
uniform float speed = 1.0;
uniform float scale = 0.05; // Skala (im mniejsza, tym większe fale rozciągnięte na wszystkie kafelki)

void fragment() {
    // Używamy SCREEN_UV lub współrzędnych świata, aby zsynchronizować kafelki.
    // Dzięki temu każdy piksel oblicza pozycję względem ekranu/świata, a nie swojego kafelka.
    vec2 world_pos = SCREEN_UV / SCREEN_PIXEL_SIZE * scale;
    
    // Tworzymy ruchomy wzór bazując na pozycji globalnej
    float wave1 = sin(world_pos.y + TIME * speed);
    float wave2 = cos(world_pos.x + TIME * speed * 0.7);
    
    float mask = (wave1 + wave2) * 0.5;
    
    vec4 final_color = mix(color_deep, color_light, mask * 0.5 + 0.5);
    
    COLOR = final_color;
}