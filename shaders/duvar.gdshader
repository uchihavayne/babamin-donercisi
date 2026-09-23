// DUVAR KAROLARI (remake HD) — art.js bakeBG karo dongusunun GPU karsiligi.
// Karo dokusu Blender'dan TON tasir (R isik, G yuzey maskesi); renk sehrin
// (ve boya yukseltmesinin) duvar paletinden. Karo tonu art.js'teki gibi
// karo koordinati hash'iyle 3 tondan biri; %4.5 karo kirik.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D karo : filter_nearest;
uniform vec3 p0; uniform vec3 p1; uniform vec3 p2; uniform vec3 p3; uniform vec3 p4;
uniform vec3 vurgu = vec3(0.553, 0.769, 0.863);   // #8dc4dc
uniform vec4 bolge;      // x0, y0, w, h (mantik pikseli)

float h1(float v) { return fract(sin(v * 127.1) * 43758.5453); }

void fragment() {
	vec2 lp = bolge.xy + UV * bolge.zw;
	vec2 hd = floor(lp * 2.0) / 2.0 + 0.25;
	float tx = floor(hd.x / 18.0) * 18.0;
	float ty = floor((hd.y + 8.0) / 18.0) * 18.0 - 8.0;
	vec2 yerel = hd - vec2(tx, ty);
	vec4 t = texture(karo, (floor(yerel * 2.0) + 0.5) / 36.0);
	float hsh = h1(tx * 0.37 + ty * 1.13);
	vec3 taban = hsh < 0.18 ? p0 : (hsh < 0.62 ? p1 : p2);
	vec3 c;
	if (t.g < 0.5) {
		c = p3;
	} else {
		float i = t.r;
		if (i > 0.86) c = hsh < 0.18 ? vurgu : p0;
		else if (i > 0.55) c = taban;
		else if (i > 0.38) c = hsh < 0.62 ? p2 : p3;
		else c = p3;
		// kirik karo
		if (h1(tx * 2.7 + ty * 0.91) > 0.955) {
			float bw = 5.0 + floor(h1(tx + ty) * 6.0);
			float bh = 4.0 + floor(h1(tx * 2.0 + ty) * 5.0);
			float bx = 3.0 + floor(h1(tx * 0.5 + ty) * 6.0);
			float by = 3.0 + floor(h1(ty * 0.5 + tx) * 6.0);
			if (yerel.x >= bx && yerel.x < bx + bw && yerel.y >= by && yerel.y < by + bh + 1.0) {
				if (yerel.y >= by + bh) c = p0;
				else if (yerel.x < bx + 1.0 || yerel.x >= bx + bw - 1.0 || yerel.y < by + 1.0 || yerel.y >= by + bh - 1.0) c = vec3(0.235, 0.165, 0.141);
				else c = vec3(0.165, 0.110, 0.094);
			}
		}
	}
	COLOR = vec4(c, 1.0);
}
