# Character draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:22
func f_shadeCol(p_hex: Variant = null, p_f: Variant = null) -> Variant:
	var v_r: Variant = null
	var v_g: Variant = null
	var v_b: Variant = null
	var v_hex: Variant = p_hex
	var v_f: Variant = p_f
	v_r = J.parse_int(J.method(v_hex, "substr", [1.0, 2.0]), 16.0)
	v_g = J.parse_int(J.method(v_hex, "substr", [3.0, 2.0]), 16.0)
	v_b = J.parse_int(J.method(v_hex, "substr", [5.0, 2.0]), 16.0)
	v_r = game.math_utils.f_clamp(floor((v_r * v_f) + 0.5), 0.0, 255.0)
	v_g = game.math_utils.f_clamp(floor((v_g * v_f) + 0.5), 0.0, 255.0)
	v_b = game.math_utils.f_clamp(floor((v_b * v_f) + 0.5), 0.0, 255.0)
	return J.add(J.add(J.add(J.add(J.add(J.add("rgb(", v_r), ","), v_g), ","), v_b), ")")
	return null

# chars.js:352
func f_kafaKontur(p_sekil: Variant = null, p_hw: Variant = null, p_hh: Variant = null) -> Variant:
	var v_g: Variant = null
	var v_n: Variant = null
	var v_i: Variant = null
	var v_dy: Variant = null
	var v_u: Variant = null
	var v_e: Variant = null
	var v_f: Variant = null
	var v_wv: Variant = null
	var v_sekil: Variant = p_sekil
	var v_hw: Variant = p_hw
	var v_hh: Variant = p_hh
	v_g = []
	v_n = J.add((v_hh * 2.0), 1.0)
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_dy = (v_i - v_hh)
		v_u = (float(v_i) / float((v_n - 1.0)))
		v_e = sqrt(max(0.0, (1.0 - (float((v_dy * v_dy)) / float((v_hh * v_hh))))))
		match v_sekil:
			1.0:
				v_f = (pow(v_e, 0.62) * (0.9 - (v_u * 0.16)))
				if J.gt(v_u, 0.74):
					v_f = (v_f * (1.0 - ((v_u - 0.74) * 1.9)))
			2.0:
				v_f = (pow(v_e, 0.78) if J.lt(v_u, 0.3) else (max(pow(v_e, 0.78), 0.93) if J.lt(v_u, 0.82) else (0.93 - ((v_u - 0.82) * 4.0))))
			3.0:
				v_f = (pow(v_e, 0.58) * 1.05)
				if J.gt(v_u, 0.88):
					v_f = (v_f * (1.0 - ((v_u - 0.88) * 4.0)))
			4.0:
				v_f = ((pow(v_e, 0.7) * (1.1 - (v_u * 0.1))) - (pow(v_u, 3.0) * 0.55))
			_:
				v_f = v_e
		v_wv = floor((v_f * v_hw) + 0.5)
		J.method(v_g, "push", [(0.0 if J.lt(v_wv, 2.0) else v_wv)])
		v_i = J.add(v_i, 1.0)
	return v_g
	return null

# chars.js:387
func f_gozAki(p_ex: Variant = null, p_ey: Variant = null, p_w: Variant = null, p_h: Variant = null, p_bicim: Variant = null, p_yon: Variant = null, p_s: Variant = null) -> Variant:
	var v_AK: Variant = null
	var v_ry: Variant = null
	var v_enKis: Variant = null
	var v_i: Variant = null
	var v_u: Variant = null
	var v_kis: Variant = null
	var v_c: Variant = null
	var v_dis: Variant = null
	var v_kay: Variant = null
	var v_ex: Variant = p_ex
	var v_ey: Variant = p_ey
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_bicim: Variant = p_bicim
	var v_yon: Variant = p_yon
	var v_s: Variant = p_s
	v_AK = "#ffffff"
	if J.eq(v_bicim, 2.0):
		v_ry = max(2.0, (int(J.n((v_h - 1.0))) >> int(J.n(1.0))))
		game.f_ell(J.add(v_ex, (int(J.n((v_w - 1.0))) >> int(J.n(1.0)))), J.add(v_ey, (int(J.n((v_h - 1.0))) >> int(J.n(1.0)))), max(2.0, (int(J.n((v_w - 1.0))) >> int(J.n(1.0)))), v_ry, v_AK)
	else:
		if J.eq(v_bicim, 1.0):
			v_enKis = max(0.0, (int(J.n((v_w - 3.0))) >> int(J.n(1.0))))
			v_i = 0.0
			while J.lt(v_i, v_h):
				v_u = ((float(abs((v_i - (float((v_h - 1.0)) / float(2.0))))) / float((float((v_h - 1.0)) / float(2.0)))) if J.gt(v_h, 1.0) else 0.0)
				v_kis = min(v_enKis, floor((pow(v_u, 1.8) * 1.6) + 0.5))
				game.f_fr(J.add(v_ex, v_kis), J.add(v_ey, v_i), (v_w - (v_kis * 2.0)), 1.0, v_AK)
				v_i = J.add(v_i, 1.0)
		else:
			if J.eq(v_bicim, 3.0):
				game.f_fr(v_ex, J.add(v_ey, 2.0), v_w, max(1.0, (v_h - 2.0)), v_AK)
				game.f_fr(v_ex, v_ey, v_w, 2.0, J.getv(v_s, 2.0))
				game.f_hl(v_ex, J.add(v_ey, 1.0), v_w, J.getv(v_s, 3.0))
			else:
				if J.eq(v_bicim, 4.0):
					game.f_fr(v_ex, J.add(v_ey, max(1.0, (int(J.n((v_h - 2.0))) >> int(J.n(1.0))))), v_w, 2.0, v_AK)
					game.f_hl(v_ex, J.add(v_ey, max(0.0, ((int(J.n((v_h - 2.0))) >> int(J.n(1.0))) - 1.0))), v_w, J.getv(v_s, 3.0))
				else:
					if J.eq(v_bicim, 5.0):
						v_c = 0.0
						while J.lt(v_c, v_w):
							v_dis = (v_c if J.lt(v_yon, 0.0) else ((v_w - 1.0) - v_c))
							v_kay = (1.0 if J.lt(v_dis, 2.0) else 0.0)
							game.f_fr(J.add(v_ex, v_c), J.add(v_ey, v_kay), 1.0, max(1.0, (v_h - v_kay)), v_AK)
							v_c = J.add(v_c, 1.0)
					else:
						game.f_fr(v_ex, v_ey, v_w, v_h, v_AK)
	return null

