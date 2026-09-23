# City system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# sehir.js:175
func f_sehirTema() -> Variant:
	var v_i: Variant = null
	v_i = (J.getv(game.j_G, "city") if ((not J.eq(J.kind(game.j_G), "undefined") and J.truth(game.j_G)) and J.eq(J.kind(J.getv(game.j_G, "city")), "number")) else (-J.n(1.0)))
	return J.getv(game.j_SEHIR, game.math_utils.f_clamp(J.add(v_i, 1.0), 0.0, (J.getv(game.j_SEHIR, "length") - 1.0)))
	return null

# sehir.js:180
func f_sehirAdi(p_i: Variant = null) -> Variant:
	var v_i: Variant = p_i
	if J.eq(v_i, null):
		v_i = (J.getv(game.j_G, "city") if (not J.eq(J.kind(game.j_G), "undefined") and J.truth(game.j_G)) else (-J.n(1.0)))
	if J.lt(v_i, 0.0):
		return game.localization.f_T("BABANIN DÜKKÂNI")
	return game.localization.f_T(J.getv(J.getv(game.j_BRANCH, game.math_utils.f_clamp(v_i, 0.0, (J.getv(game.j_BRANCH, "length") - 1.0))), "name"))
	return null

# sehir.js:186
func f_sehirAcik(p_i: Variant = null) -> Variant:
	var v_i: Variant = p_i
	if J.lt(v_i, 0.0):
		return true
	return J.lt(v_i, (J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0))
	return null

# sehir.js:196
func f__hex2rgb(p_h: Variant = null) -> Variant:
	var v_v: Variant = null
	var v_h: Variant = p_h
	v_v = J.parse_int(J.method(v_h, "slice", [1.0]), 16.0)
	return [(int(J.n((int(J.n(v_v)) >> int(J.n(16.0))))) & int(J.n(255.0))), (int(J.n((int(J.n(v_v)) >> int(J.n(8.0))))) & int(J.n(255.0))), (int(J.n(v_v)) & int(J.n(255.0)))]
	return null

# sehir.js:200
func f__rgb2hex(p_r: Variant = null, p_g: Variant = null, p_b: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_r: Variant = p_r
	var v_g: Variant = p_g
	var v_b: Variant = p_b
	v_k = game.city_system._closure_77.bind({})
	return J.add(J.add(J.add("#", J.invoke(v_k, [v_r])), J.invoke(v_k, [v_g])), J.invoke(v_k, [v_b]))
	return null

# sehir.js:204
func f__rgb2hsl(p_r: Variant = null, p_g: Variant = null, p_b: Variant = null) -> Variant:
	var v_mx: Variant = null
	var v_mn: Variant = null
	var v_d: Variant = null
	var v_l: Variant = null
	var v_h: Variant = null
	var v_sat: Variant = null
	var v_r: Variant = p_r
	var v_g: Variant = p_g
	var v_b: Variant = p_b
	v_r = (float(v_r) / float(255.0))
	v_g = (float(v_g) / float(255.0))
	v_b = (float(v_b) / float(255.0))
	v_mx = max(max(v_r, v_g), v_b)
	v_mn = min(min(v_r, v_g), v_b)
	v_d = (v_mx - v_mn)
	v_l = (float(J.add(v_mx, v_mn)) / float(2.0))
	v_h = 0.0
	v_sat = 0.0
	if J.truth(v_d):
		v_sat = ((float(v_d) / float(((2.0 - v_mx) - v_mn))) if J.gt(v_l, 0.5) else (float(v_d) / float(J.add(v_mx, v_mn))))
		if J.eq(v_mx, v_r):
			v_h = J.add((float((v_g - v_b)) / float(v_d)), (6.0 if J.lt(v_g, v_b) else 0.0))
		else:
			if J.eq(v_mx, v_g):
				v_h = J.add((float((v_b - v_r)) / float(v_d)), 2.0)
			else:
				v_h = J.add((float((v_r - v_g)) / float(v_d)), 4.0)
		v_h = (float(v_h) / float(6.0))
	return [v_h, v_sat, v_l]
	return null

# sehir.js:217
func f__hsl2rgb(p_h: Variant = null, p_s: Variant = null, p_l: Variant = null) -> Variant:
	var v_f: Variant = null
	var v_q: Variant = null
	var v_p: Variant = null
	var v_h: Variant = p_h
	var v_s: Variant = p_s
	var v_l: Variant = p_l
	v_f = game.city_system._closure_78.bind({})
	if (not J.truth(v_s)):
		return [(v_l * 255.0), (v_l * 255.0), (v_l * 255.0)]
	v_q = ((v_l * J.add(1.0, v_s)) if J.lt(v_l, 0.5) else (J.add(v_l, v_s) - (v_l * v_s)))
	v_p = ((2.0 * v_l) - v_q)
	return [(J.invoke(v_f, [v_p, v_q, J.add(v_h, (float(1.0) / float(3.0)))]) * 255.0), (J.invoke(v_f, [v_p, v_q, v_h]) * 255.0), (J.invoke(v_f, [v_p, v_q, (v_h - (float(1.0) / float(3.0)))]) * 255.0)]
	return null

# sehir.js:238
func f_boyaUygula(p_renk: Variant = null, p_kat: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_hsl: Variant = null
	var v_h: Variant = null
	var v_taban: Variant = null
	var v_sa: Variant = null
	var v_l: Variant = null
	var v_o: Variant = null
	var v_renk: Variant = p_renk
	var v_kat: Variant = p_kat
	v_c = game.city_system.f__hex2rgb(v_renk)
	v_hsl = game.city_system.f__rgb2hsl(J.getv(v_c, 0.0), J.getv(v_c, 1.0), J.getv(v_c, 2.0))
	v_h = (J.getv(v_hsl, 0.0) if J.eq(J.getv(v_kat, 0.0), null) else J.getv(v_kat, 0.0))
	v_taban = max(J.getv(v_hsl, 1.0), (J.getv(v_hsl, 1.0) if J.eq(J.getv(v_kat, 0.0), null) else 0.3))
	v_sa = max(0.0, min(1.0, (v_taban * J.getv(v_kat, 1.0))))
	v_l = max(0.04, min(0.96, J.add(J.getv(v_hsl, 2.0), J.getv(v_kat, 2.0))))
	v_o = game.city_system.f__hsl2rgb(v_h, v_sa, v_l)
	return game.city_system.f__rgb2hex(J.getv(v_o, 0.0), J.getv(v_o, 1.0), J.getv(v_o, 2.0))
	return null

# sehir.js:249
func f_duvarPaleti(p_tema: Variant = null, p_decor: Variant = null) -> Variant:
	var v_kat: Variant = null
	var v_o: Variant = null
	var v_i: Variant = null
	var v_tema: Variant = p_tema
	var v_decor: Variant = p_decor
	v_kat = J.getv(game.j_BOYA_KAT, fmod(J.n((v_decor if J.truth(v_decor) else 0.0)), J.n(J.getv(game.j_BOYA_KAT, "length"))))
	if J.eq(J.getv(v_kat, 0.0), null):
		return J.getv(v_tema, "duvar")
	v_o = []
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_tema, "duvar"), "length")):
		J.method(v_o, "push", [game.city_system.f_boyaUygula(J.getv(J.getv(v_tema, "duvar"), v_i), v_kat)])
		v_i = J.add(v_i, 1.0)
	return v_o
	return null

# sehir.js:258
func f_tasPaleti(p_tema: Variant = null, p_decor: Variant = null) -> Variant:
	var v_kat: Variant = null
	var v_yumusak: Variant = null
	var v_o: Variant = null
	var v_i: Variant = null
	var v_tema: Variant = p_tema
	var v_decor: Variant = p_decor
	v_kat = J.getv(game.j_BOYA_KAT, fmod(J.n((v_decor if J.truth(v_decor) else 0.0)), J.n(J.getv(game.j_BOYA_KAT, "length"))))
	if J.eq(J.getv(v_kat, 0.0), null):
		return J.getv(v_tema, "tas")
	v_yumusak = [J.getv(v_kat, 0.0), (J.getv(v_kat, 1.0) * 0.3), (J.getv(v_kat, 2.0) * 0.4)]
	v_o = []
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_tema, "tas"), "length")):
		J.method(v_o, "push", [game.city_system.f_boyaUygula(J.getv(J.getv(v_tema, "tas"), v_i), v_yumusak)])
		v_i = J.add(v_i, 1.0)
	return v_o
	return null

func _closure_77(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_s: Variant = null
	var v_n: Variant = null
	v_n = J.arg(_args, 0)
	v_n = max(0.0, min(255.0, floor(v_n + 0.5)))
	v_s = J.method(v_n, "toString", [16.0])
	return (J.add("0", v_s) if J.lt(J.getv(v_s, "length"), 2.0) else v_s)
	return null

func _closure_78(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_p: Variant = null
	var v_q: Variant = null
	var v_t: Variant = null
	v_p = J.arg(_args, 0)
	v_q = J.arg(_args, 1)
	v_t = J.arg(_args, 2)
	if J.lt(v_t, 0.0):
		v_t = J.add(v_t, 1.0)
	if J.gt(v_t, 1.0):
		v_t = (v_t - 1.0)
	if J.lt(v_t, (float(1.0) / float(6.0))):
		return J.add(v_p, (((v_q - v_p) * 6.0) * v_t))
	if J.lt(v_t, (float(1.0) / float(2.0))):
		return v_q
	if J.lt(v_t, (float(2.0) / float(3.0))):
		return J.add(v_p, (((v_q - v_p) * ((float(2.0) / float(3.0)) - v_t)) * 6.0))
	return v_p
	return null
