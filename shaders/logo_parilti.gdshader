// Baslik logosu parilti suzulmesi (logo.js logoParilti): altin harf maskesi
// uzerinde egik, 5 px genis parlak serit (dis au0, ic beyaz). Serit konumu
// modulate.r ile gelir (0..1), boyut mantik pikseli.
shader_type canvas_item;
render_mode blend_mix;

uniform vec2 boyut = vec2(275.0, 52.0);
varying vec4 mod_renk;

void vertex() {
	mod_renk = COLOR;
}

void fragment() {
	vec4 m = texture(TEXTURE, UV);
	float p = mod_renk.r;
	vec2 px = UV * boyut;
	float bx0 = -20.0 + p * (boyut.x + 60.0);
	float bx = bx0 - (boyut.y - px.y) * 0.5;
	float d = abs(px.x - bx);
	vec3 renk = d < 1.5 ? vec3(1.0, 0.98, 0.94) : vec3(1.0, 0.949, 0.659);
	float a = step(d, 2.5) * step(0.5, m.a) * mod_renk.a;
	COLOR = vec4(renk, a);
}
