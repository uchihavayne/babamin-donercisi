// KESKIN-BILINEAR SUNUM (remake): oyun 960x540 SubViewport'ta ciziliyor,
// pencere herhangi bir boyutta olabilir (1440x810 = 1.5x). En yakin komsu
// ile kesirli olcekte bazi pikseller 1, bazilari 2 ekran pikseli olur ve
// hareket halinde titrer. Bu shader her doku pikselinin icini tam dolu
// (keskin) birakir, yalniz komsu piksel sinirinda 1 ekran pikseli genisliginde
// yumusak gecis yapar: her olcekte esit piksel boyutu.
// Doku filtresi LINEAR olmali (sinirdaki karisimi donanim yapar).
shader_type canvas_item;

uniform vec2 kaynak = vec2(960.0, 540.0);

void fragment() {
	vec2 texel = UV * kaynak;
	// ekran pikseli basina doku pikseli -> doku pikseli basina ekran pikseli
	vec2 olcek = 1.0 / max(fwidth(texel), vec2(1e-4));
	vec2 t0 = floor(texel);
	vec2 s = fract(texel) - 0.5;
	vec2 bolge = max(vec2(0.0), 0.5 - 0.5 / olcek);
	vec2 f = (s - clamp(s, -bolge, bolge)) * olcek + 0.5;
	COLOR = texture(TEXTURE, (t0 + f) / kaynak);
}
