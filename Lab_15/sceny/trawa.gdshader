shader_type canvas_item;

uniform float predkosc : hint_range(0.0, 10.0) = 2.5;
uniform float sila_bujania : hint_range(0.0, 20.0) = 5.0;

void vertex() {
	// Pobieramy pozycję kafelka w świecie
	float world_x = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).x;
	
	// Używamy VERTEX.y, ale w sposób bardziej elastyczny.
	// Zakładamy, że góra kafelka ma mniejsze wartości Y niż dół.
	// Jeśli trawa buja się cała, zmniejsz 0.8 na mniejszą liczbę (np. 0.1)
	if (VERTEX.y < 0.8) {
		// Dodajemy 123.45 do fazy, żeby "rozbić" martwe punkty na mapie
		float oscylacja = sin(TIME * predkosc + (world_x + 123.45) * 0.05);
		VERTEX.x += oscylacja * sila_bujania;
	}
}