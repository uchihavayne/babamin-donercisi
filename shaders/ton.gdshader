// KARAKTER TON SHADER'I (remake)
// Musteri parcalari Blender'da gri "ton kodlu" render ediliyor; renk oyun
// aninda karakterin paletinden geliyor (ayni parca her ten/sac/gomlek icin).
//   kip 0 (carpan): cikti = taban renk * (ton * 2)   -> gomlek, sac, sapka
//                   art.js shadeCol(c, k) de rengi carpiyor: k = ton * 2
//   kip 1 (palet) : ton -> paletin `sutunlar` tonundan biri (1 = en acik ... 0 = en koyu)
//                   (ten: 4 ton; araba: l b d)
//                   satir (hangi ten) modulate.r'de: satir / (satir_sayisi - 1)
// Taban renk / satir, cizim cagrisinin modulate rengiyle geliyor; alfa = parca * modulate.a
shader_type canvas_item;
render_mode unshaded;

uniform int kip = 0;
uniform sampler2D palet : filter_nearest;
uniform int satirlar = 9;
uniform int sutunlar = 4;
uniform bool mono = false;
// dortgen cizimi (shader_quad) icin: ton dokusu TEXTURE yerine bu uniform'dan
uniform bool doku_uniform = false;
uniform sampler2D doku_ton : filter_nearest;
varying vec4 mod_renk;

void vertex() {
	mod_renk = COLOR;
}

void fragment() {
	vec4 t = doku_uniform ? texture(doku_ton, UV) : texture(TEXTURE, UV);
	vec3 c;
	if (kip == 1) {
		int sat = int(floor(mod_renk.r * float(satirlar - 1) + 0.5));
		int sut = int(floor((1.0 - t.r) * float(sutunlar - 1) + 0.5));
		c = texelFetch(palet, ivec2(sut, sat), 0).rgb;
	} else {
		c = min(vec3(1.0), mod_renk.rgb * (t.r * 2.0));
	}
	if (mono) {
		float g = dot(c, vec3(0.32, 0.55, 0.13)) * 0.8 + 44.0 / 255.0;
		c = vec3(g, g, min(1.0, g * 1.02));
	}
	COLOR = vec4(c, t.a * mod_renk.a);
}
