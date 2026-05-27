shader_type canvas_item;

uniform bool rura_pozioma = false;
uniform bool odwroc_kierunek = false;

uniform float predkosc_przeplywu : hint_range(0.1, 10.0) = 4.0;
uniform float czestotliwosc_impulsow : hint_range(1.0, 30.0) = 6.0;
uniform float jasnosc_blysku : hint_range(1.0, 5.0) = 2.5;
uniform vec4 kolor_swiatla : source_color = vec4(0.0, 1.0, 0.6, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float os = rura_pozioma ? UV.x : UV.y;
	float kierunek = odwroc_kierunek ? -1.0 : 1.0;
	float fala = sin(os * czestotliwosc_impulsow - TIME * predkosc_przeplywu * kierunek);
	float prad = smoothstep(0.2, 0.8, fala);
	
	if (tex.a > 0.0) {
		vec3 efekt_neon = kolor_swiatla.rgb * prad * (jasnosc_blysku - 1.0);
		tex.rgb += efekt_neon;
	}
	
	COLOR = tex;
}