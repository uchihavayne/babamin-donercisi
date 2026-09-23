// TAS KEMER BANDI (remake HD) — art.js bakeBG stoneBand'in GPU karsiligi.
// 23x13 bloklar, tek sira 11 px kaydirmali; blok tonu hash'le tas paletinin
// ilk uc tonundan; Blender dokusu (tas.png, 4 varyant) isik/derz verir. Kemer
// siniri her satir icin kenar dokusundan (R32F: x degeri): sol bant x < kenar,
// sag bant x >= kenar.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D tasdoku : filter_nearest;
uniform sampler2D kenar : filter_nearest;
uniform vec3 t0; uniform vec3 t1; uniform vec3 t2; uniform vec3 t3; uniform vec3 t4;
uniform float taraf = -1.0;
uniform vec4 bolge;

float h1(float v) { return fract(sin(v * 127.1) * 43758.5453); }

void fragment() {
	vec2 lp = bolge.xy + UV * bolge.zw;
	vec2 hd = floor(lp * 2.0) / 2.0 + 0.25;
	float ex = texelFetch(kenar, ivec2(0, int(clamp(floor(hd.y), 0.0, 269.0))), 0).r;
	if ((taraf < 0.0 && hd.x >= ex) || (taraf > 0.0 && hd.x < ex)) discard;
	float y = hd.y;
	float row = floor(y / 13.0);
	float off = mod(row, 2.0) > 0.5 ? 11.0 : 0.0;
	float col = floor((hd.x + off) / 23.0);
	vec2 yerel = vec2(mod(hd.x + off, 23.0), mod(y, 13.0));
	float v = h1(row * 7.3 + col * 3.1);
	float varyant = floor(h1(row * 3.9 + col * 5.3) * 4.0);
	vec4 t = texture(tasdoku, vec2((varyant * 46.0 + floor(yerel.x * 2.0) + 0.5) / 184.0, (floor(yerel.y * 2.0) + 0.5) / 26.0));
	vec3 c;
	if (t.g < 0.5) {
		c = t4;
	} else {
		vec3 taban = v < 0.3 ? t0 : (v < 0.72 ? t1 : t2);
		float i = t.r;
		if (i > 0.84) c = t0;
		else if (i > 0.5) c = taban;
		else if (i > 0.32) c = t3;
		else c = t4;
		if (h1(floor(hd.x) * 1.7 + floor(y) * 2.3) > 0.93) c = v < 0.5 ? t0 : t3;
	}
	COLOR = vec4(c, 1.0);
}
