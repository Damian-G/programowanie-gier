shader_type canvas_item;

// --- PROSTE PRZEŁĄCZNIKI KIERUNKU (KLIKAJ ON/OFF W INSPEKTORZE) ---
uniform bool rura_pozioma = false; // ON = pozioma (lewo/prawo), OFF = pionowa (góra/dół)
uniform bool odwroc_kierunek = false; // ON = w lewo / w górę, OFF = w prawo / w dół

// --- PARAMETRY WYGLĄDU ---
uniform float predkosc_przeplywu : hint_range(0.1, 10.0) = 4.0;
uniform float czestotliwosc_impulsow : hint_range(1.0, 30.0) = 6.0;
uniform float jasnosc_blysku : hint_range(1.0, 5.0) = 2.5;
uniform vec4 kolor_swiatla : source_color = vec4(0.0, 1.0, 0.6, 1.0);

void fragment() {
	// Pobieramy oryginalny obrazek rury
	vec4 tex = texture(TEXTURE, UV);
	
	// Wybieramy oś: UV.x dla poziomych rur, UV.y dla pionowych
	float os = rura_pozioma ? UV.x : UV.y;
	
	// Ustalamy zwrot na podstawie przełącznika "odwroc_kierunek"
	float kierunek = odwroc_kierunek ? -1.0 : 1.0;
	
	// Tworzymy przemieszczającą się falę z uwzględnieniem kierunku
	float fala = sin(os * czestotliwosc_impulsow - TIME * predkosc_przeplywu * kierunek);
	
	// Przerabiamy falę na wyraźne paski prądu (od 0.0 do 1.0)
	float prad = smoothstep(0.2, 0.8, fala);
	
	// Świecenie rury (tylko widoczne piksele)
	if (tex.a > 0.0) {
		vec3 efekt_neon = kolor_swiatla.rgb * prad * (jasnosc_blysku - 1.0);
		tex.rgb += efekt_neon;
	}
	
	COLOR = tex;
}