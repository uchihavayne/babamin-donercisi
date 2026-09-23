// DONER SISI — remake HD (2x piksel) koni shader'i.
//
// Oyunun art.js drawSpit'indeki et konisinin karsiligi: ayni koni profili,
// ayni kutle / pisme / donus / kesim kurallari, ayni kademeli ton bantlari
// ve meatColCalc renk egrisi. Fark: yuzey artik elle "dikis" ve "katman
// dalgasi" formulu degil, Blender'da modellenmis 3B donerden pisirilmis
// silindirik doku (blender/models/sis_hd.py): dilim araliklari (AO), yag
// katmanlari ve damlalari, kizarma lekeleri, dilim kenarlarinin silüeti.
//
// OYUNDA GERCEKTE DEGISEN yalniz donus ve bicak kesimi: game.js'te pisme her
// yerde sabit .85, kutle hep 1 (yanik / az pismis / azalan sis YOK; art.js'teki
// roast > 1.02 yanik dali hic calismayan kod). Kesim: her dilimde cutDepth = 5,
// saniyede 5 azalarak 0.2 sn'de kapanir. Parametreler yine de oyunun
// gonderdigi gibi aktariliyor.
//
// Parametreler tepe rengiyle geliyor (tek malzeme, cagri basina farkli
// deger; ornek-basina uniform gerekmiyor):
//   COLOR.r = kutle (0..1)        COLOR.g = pisme / 1.5
//   COLOR.b = donus / 2pi         COLOR.a = kesim derinligi / 20
//
// Dortgen: yatayda cx-23 .. cx+24 (47 mantik pikseli), dikeyde koni
// tepesinin 1 piksel ustunden, coneH + 2 piksel. Her parca 2x ekranin
// piksel merkezine yuvarlanir: sonuc keskin, "yari mantik pikseli" boyutunda
// piksel art.
shader_type canvas_item;

uniform sampler2D doku : filter_nearest, repeat_enable;
uniform sampler2D yukseklik : filter_nearest, repeat_enable;
// dukkan ekraninin siyah-beyaz arka plani (gpu_canvas mono kipi ile ayni formul)
uniform bool mono = false;

const float MAXR = 19.0;
const float H0 = 110.0;
const float QW = 47.0;

float cone_profile(float ty) {
	if (ty < 0.09) {
		float u = ty / 0.09;
		return 0.52 + 0.44 * u * u * (3.0 - 2.0 * u);
	}
	if (ty < 0.62) return 0.96 + 0.04 * sin((ty - 0.09) / 0.53 * PI);
	float k = (ty - 0.62) / 0.38;
	return max(0.10, 1.0 - k * k * 0.90);
}

// art.js: nx -> ton kademeleri
float ton_bandi(float nx) {
	if (nx < -0.78) return 0.52;
	if (nx < -0.55) return 0.66;
	if (nx < -0.25) return 0.80;
	if (nx < 0.10) return 0.95;
	if (nx < 0.38) return 1.12;
	if (nx < 0.62) return 1.30;
	if (nx < 0.86) return 1.12;
	return 0.86;
}

// art.js meatColCalc (0..255 -> 0..1)
vec3 et_rengi(float roast) {
	vec3 c;
	if (roast < 0.34) c = mix(vec3(233.0, 158.0, 136.0), vec3(242.0, 180.0, 104.0), roast / 0.34);
	else if (roast < 0.78) c = mix(vec3(242.0, 180.0, 104.0), vec3(208.0, 138.0, 64.0), (roast - 0.34) / 0.44);
	else if (roast < 1.0) c = mix(vec3(208.0, 138.0, 64.0), vec3(158.0, 92.0, 40.0), (roast - 0.78) / 0.22);
	else c = mix(vec3(158.0, 92.0, 40.0), vec3(58.0, 42.0, 30.0), min(1.0, (roast - 1.0) / 0.35));
	return c / 255.0;
}

// oyunun meatColQ'su gibi kademeli: pisme 1/15, ton 1/12 adimda
vec3 et_q(float roast, float ton) {
	return clamp(et_rengi(floor(roast * 15.0) / 15.0) * (floor(ton * 12.0) / 12.0), 0.0, 1.0);
}

void fragment() {
	float kutle = COLOR.r;
	float pisme = COLOR.g * 1.5;
	float donus = COLOR.b * TAU;
	float kesim = COLOR.a * 20.0;
	float cone_h = H0 - floor((1.0 - kutle) * 18.0 + 0.5);
	float olcek_r = 0.45 + 0.55 * kutle;

	// 2x ekran pikselinin merkezi, mantik pikseli cinsinden
	vec2 hd = floor(UV * vec2(QW, cone_h + 2.0) * 2.0);
	float X = (hd.x + 0.5) * 0.5 - 23.0;
	float Y = (hd.y + 0.5) * 0.5 - 1.0;
	float ty = Y / cone_h;
	if (ty < 0.0 || ty >= 1.0) discard;
	float v = ty;

	// silüet: iki yandaki dilim kenarlari donusle birlikte kayar
	float r0 = MAXR * olcek_r * cone_profile(ty);
	float hR = (texture(yukseklik, vec2(fract((PI * 0.5 + donus) / TAU), v)).r - 0.5) * 3.0;
	float hL = (texture(yukseklik, vec2(fract((-PI * 0.5 + donus) / TAU), v)).r - 0.5) * 3.0;
	float rR = max(0.5, r0 + 0.9 * hR * (r0 / MAXR));
	float rL = max(0.5, r0 + 0.9 * hL * (r0 / MAXR));

	// bicakla kesilen sol yuz (art.js cutAmt)
	float kes = 0.0;
	if (kesim > 0.0 && Y > 8.0 && Y < cone_h * 0.8)
		kes = floor(kesim * (1.0 - abs(ty - 0.45)) + 0.5);
	float sol = -rL + kes;

	if (X > rR + 0.5 || X < sol - 0.5) discard;
	// dis hat: 1 HD piksel, yari saydam koyu (art.js rgba(30,18,10,.45))
	if (X > rR || X < sol) {
		COLOR = vec4(30.0 / 255.0, 18.0 / 255.0, 10.0 / 255.0, 0.45);
	} else {
		float r = X >= 0.0 ? rR : rL;
		float nx = clamp(X / r, -1.0, 1.0);
		float u = fract((asin(nx) + donus) / TAU);
		vec4 d = texture(doku, vec2(u, v));
		float h = (texture(yukseklik, vec2(u, v)).r - 0.5) * 3.0;
		float n01 = nx * 0.5 + 0.5;

		float ton = ton_bandi(nx);
		ton *= mix(0.74, 1.0, pow(d.a, 2.0));              // dilim araligi golgesi
		ton *= 0.95 + 0.07 * clamp(h, -1.0, 1.5);           // cikinti isik alir
		ton *= mix(0.86, 1.16, d.r);                        // dilim tonu / topak

		float pis = pisme * (0.84 + 0.30 * n01);
		if (ty < 0.05) pis *= 0.82;
		vec3 renk = et_q(pis, ton);

		// yag: daha acik ve az pismis ton. Ilk denemede art.js'in 1.55 parlakligi
		// kullanildi: 1 HD piksellik damlalar parlak sari "cizik" gibi duruyordu.
		if (d.g > 0.5) renk = et_q(pisme * 0.86, min(1.32, ton * 1.13));
		else if (d.g > 0.3) renk = et_q(pisme * 0.93, min(1.26, ton * 1.06));

		// citir kenarlar: disa tasan dilim kenarlari biraz daha kizarmis
		if (d.b > 0.55) renk = et_q(pis * 1.14 + 0.06, ton * 0.92);

		// kabuk kenari (art.js: sagda r-1 acik, r koyu; solda koyu)
		if (X > rR - 0.5) renk = et_q(pisme * 1.05, 0.80);
		else if (X > rR - 1.5) renk = et_q(pisme, 1.22);
		if (kes == 0.0 && X < sol + 0.5) renk = et_q(pisme * 0.78, 0.60);

		// REMAKE canlilik 1: yag isiltisi. Isik alan bantta (nx 0.05..0.7) yagli
		// dokularda ara sira bir kademe parlak piksel; yuzeye bagli (u, v doku
		// hucresi) oldugu icin donusle birlikte kayar, zamanla goz kirpar.
		vec2 ds = vec2(textureSize(doku, 0));
		vec2 hucre = floor(vec2(u, v) * ds);
		float par = fract(sin(dot(hucre + floor(TIME * 3.0) * vec2(7.13, 3.71), vec2(12.9898, 78.233))) * 43758.5453);
		if (d.g > 0.3 && nx > 0.05 && nx < 0.7 && par > 0.955 && kes == 0.0)
			renk = et_q(pisme * 0.84, min(1.45, ton * 1.3));

		// taze kesim yuzu: ic et, az pismis, lifli
		if (kes > 0.0 && X < sol + 1.5) {
			float t2 = X < sol + 0.75 ? 1.15 : 0.98;
			renk = et_q(pisme * (0.22 + 0.12 * d.r), t2 * mix(0.92, 1.08, d.r));
		}
		// REMAKE canlilik 2: sagdaki isiticidan gelen sicak kenar isigi (hafif titrer)
		if (nx > 0.72) {
			float titre = 0.75 + 0.25 * sin(TIME * 7.3 + Y * 0.21) * sin(TIME * 3.1 + 1.7);
			float k = (nx - 0.72) / 0.28 * 0.16 * titre;
			renk = mix(renk, renk * vec3(1.28, 1.02, 0.72) + vec3(0.06, 0.02, 0.0), k);
		}
		COLOR = vec4(renk, 1.0);
	}
	if (mono) {
		float g = dot(COLOR.rgb, vec3(0.32, 0.55, 0.13)) * 0.8 + 44.0 / 255.0;
		COLOR.rgb = vec3(g, g, min(1.0, g * 1.02));
	}
}
