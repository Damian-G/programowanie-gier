shader_type canvas_item;

uniform float predkosc_pulsowania : hint_range(0.1, 10.0) = 4.0;
uniform float predkosc_pradu : hint_range(0.1, 10.0) = 3.0;
uniform float jasnosc_blysku : hint_range(1.0, 3.0) = 1.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	float fala = sin(UV.y * 15.0 - TIME * predkosc_pradu);
	float pasek_swiatla = smoothstep(0.5, 1.0, fala);
	
	float pulse = 0.8 + 0.3 * sin(TIME * predkosc_pulsowania);
	
	if (tex.g > tex.r && tex.g > 0.2) {
		
		tex.rgb *= pulse + (pasek_swiatla * (jasnosc_blysku - 1.0));
		
		tex.rgb += vec3(0.0, pasek_swiatla * 0.2, pasek_swiatla * 0.1);
	}
	
	COLOR = tex;
}