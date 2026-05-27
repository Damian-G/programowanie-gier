shader_type canvas_item;

uniform float predkosc : hint_range(0.0, 10.0) = 2.5;
uniform float sila_bujania : hint_range(0.0, 20.0) = 5.0;

void vertex() {
	float world_x = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).x;
	
	if (VERTEX.y < 0.8) {
		float oscylacja = sin(TIME * predkosc + (world_x + 123.45) * 0.05);
		VERTEX.x += oscylacja * sila_bujania;
	}
}