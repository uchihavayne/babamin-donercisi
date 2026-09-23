// ELEKTRIK KESINTISI ISIGI (birlesik surum). Ekran kararir; tek sicak isik
// kaynagi yanmaya devam eden doner ocagi: ondan yumusak (gauss) sonen, hafif
// titreyen turuncu hale. Pencereden soguk, cok zayif sokak isigi girer.
// Kullanici: "kare gibi, dogal degil" -> duz dikdortgenler yerine bu.
shader_type canvas_item;

uniform vec2 boyut = vec2(480.0, 270.0);   // quad'in mantik piksel boyu
uniform vec2 isik = vec2(94.0, 110.0);     // ocak merkezi (quad'a gore)
uniform vec2 yaricap = vec2(78.0, 62.0);   // halenin yatay / dikey yayilimi
uniform vec4 cam = vec4(130.0, 32.0, 292.0, 95.0);   // pencere camı
uniform float karanlik = 0.84;
uniform float titre = 0.5;

void fragment() {
	vec2 p = UV * boyut;
	vec2 d = (p - isik) / yaricap;
	float r2 = dot(d, d);
	float L = exp(-r2 * 1.6) * (0.86 + 0.14 * titre);
	float cekirdek = exp(-r2 * 7.0) * (0.8 + 0.2 * titre);
	// pencereden gelen soguk isik: cam dikdortgeninde yumusak kenarli
	vec2 ck = smoothstep(cam.xy, cam.xy + vec2(10.0), p) * (1.0 - smoothstep(cam.xy + cam.zw - vec2(10.0), cam.xy + cam.zw, p));
	float sokak = ck.x * ck.y * 0.22;
	float a = karanlik * (1.0 - clamp(L * 1.05 + sokak, 0.0, 1.0));
	vec3 gece = vec3(0.016, 0.024, 0.06);
	vec3 sicak = vec3(1.0, 0.54, 0.16);
	// sicak bolgede karanlik yerine turuncu ton (isik rengi yuzeylere vurur)
	float ton = clamp(L * 0.34 + cekirdek * 0.18, 0.0, 0.5);
	vec3 renk = mix(gece, sicak, ton / max(a + ton, 1e-4));
	// 12 kademe: yumusak ama piksel sanatina uygun hafif bantlama
	float alfa = floor(clamp(a + ton, 0.0, 1.0) * 24.0 + 0.5) / 24.0;
	COLOR = vec4(renk, alfa);
}
