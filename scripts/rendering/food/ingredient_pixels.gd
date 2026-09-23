# Ingredient pixels. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:3200
func f_pickleSlice(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdTursu(p_x, p_y, p_sh, p_k, p_sz): return null
	var v_rw: Variant = null
	var v_rh: Variant = null
	var v_don: Variant = null
	var v_kabK: Variant = null
	var v_kab: Variant = null
	var v_et: Variant = null
	var v_ic: Variant = null
	var v_pi: Variant = null
	var v_a: Variant = null
	var v_a2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	var v_sz: Variant = p_sz
	v_rw = (7.0 if J.gt(v_sz, 0.5) else 6.0)
	v_rh = (5.0 if J.gt(v_sz, 0.5) else 4.0)
	v_don = (game.f_hash1((v_k * 2.71)) * J.getv({"PI": PI}, "PI"))
	v_kabK = game.character_draw.f_shadeCol("#22350a", v_sh)
	v_kab = game.character_draw.f_shadeCol("#3f5c14", v_sh)
	v_et = game.character_draw.f_shadeCol("#6d9127", v_sh)
	v_ic = game.character_draw.f_shadeCol("#9dbe45", v_sh)
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_ell(v_x, J.add(v_y, 2.0), v_rw, 1.0, "#2e4410")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_x, J.add(v_y, 1.0), v_rw, v_rh, v_kabK)
	game.f_ell(v_x, v_y, v_rw, v_rh, v_kab)
	v_pi = 0.0
	while J.lt(v_pi, 7.0):
		v_a = J.add(v_don, (v_pi * (float((J.getv({"PI": PI}, "PI") * 2.0)) / float(7.0))))
		game.f_px(floor(J.add(v_x, (cos(v_a) * J.add(v_rw, 0.7))) + 0.5), floor(J.add(v_y, (sin(v_a) * J.add(v_rh, 0.6))) + 0.5), v_kab)
		v_a2 = J.add(v_a, (float(J.getv({"PI": PI}, "PI")) / float(7.0)))
		game.f_px(floor(J.add(v_x, (cos(v_a2) * (v_rw - 0.4))) + 0.5), floor(J.add(v_y, (sin(v_a2) * (v_rh - 0.4))) + 0.5), v_kabK)
		v_pi = J.add(v_pi, 1.0)
	game.f_ell(v_x, v_y, (v_rw - 1.0), (v_rh - 1.0), v_et)
	game.f_ell(v_x, v_y, max(1.0, (v_rw - 2.0)), max(1.0, (v_rh - 2.0)), v_ic)
	game.f_ell(v_x, (v_y - 1.0), max(2.0, (v_rw - 3.0)), 1.0, game.character_draw.f_shadeCol("#bcd668", v_sh))
	game.f_px((v_x - 1.0), v_y, game.character_draw.f_shadeCol("#e2efa4", v_sh))
	game.f_px(J.add(v_x, 1.0), v_y, game.character_draw.f_shadeCol("#e2efa4", v_sh))
	game.f_px(v_x, (v_y - 1.0), game.character_draw.f_shadeCol("#eef6c4", v_sh))
	if (J.gt(v_sh, 0.9) and J.gt(game.f_hash1((v_k * 2.3)), 0.45)):
		game.f_px((v_x - 2.0), (v_y - 2.0), "#f2fbd0")
	return null

# art.js:3257
func f_etPx(p_x: Variant = null, p_y: Variant = null, p_c: Variant = null, p_sh: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_c: Variant = p_c
	var v_sh: Variant = p_sh
	game.f_px(v_x, v_y, game.character_draw.f_shadeCol(v_c, (v_sh * game.j__etTon)))
	return null

# art.js:3260
func f__etDuz(p_x0: Variant = null, p_y: Variant = null, p_len: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_tilt: Variant = null) -> Variant:
	var v_oncekiY: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_dal: Variant = null
	var v_yy: Variant = null
	var v_uc: Variant = null
	var v_a0: Variant = null
	var v_b0: Variant = null
	var v_f: Variant = null
	var v_kUc: Variant = null
	var v_c2: Variant = null
	var v_x0: Variant = p_x0
	var v_y: Variant = p_y
	var v_len: Variant = p_len
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	var v_tilt: Variant = p_tilt
	v_oncekiY = null
	v_q = 0.0
	while J.lt(v_q, v_len):
		v_u = (float(v_q) / float((v_len - 1.0)))
		v_dal = (sin(J.add((v_u * 4.2), (v_k * 1.3))) * 0.55)
		v_yy = J.add(v_y, floor(J.add(v_dal, (((v_q - (float(v_len) / float(2.0))) * v_tilt) * 0.16)) + 0.5))
		v_uc = (J.eq(v_q, 0.0) if J.eq(v_q, 0.0) else J.eq(v_q, (v_len - 1.0)))
		if (not J.eq(v_oncekiY, null) and not J.eq(v_yy, v_oncekiY)):
			v_a0 = min(v_oncekiY, v_yy)
			v_b0 = max(v_oncekiY, v_yy)
			v_f = v_a0
			while J.le(v_f, v_b0):
				game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_f, 1.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.8))
				game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), v_f, J.getv(game.j_ET, "et"), (v_sh * 0.96))
				v_f = J.add(v_f, 1.0)
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_yy, 1.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.8))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), v_yy, (J.getv(game.j_ET, "koyu") if J.truth(v_uc) else J.getv(game.j_ET, "et")), v_sh)
		if (not J.truth(v_uc)):
			game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), (v_yy - 1.0), J.getv(game.j_ET, "ic"), (v_sh * 1.02))
		v_oncekiY = v_yy
		v_q = J.add(v_q, 1.0)
	v_kUc = (0.0 if J.gt(game.f_hash1((v_k * 2.3)), 0.5) else (v_len - 3.0))
	v_c2 = 0.0
	while (J.lt(v_c2, 3.0) and J.lt(J.add(v_kUc, v_c2), v_len)):
		game.ingredient_pixels.f_etPx(J.add(J.add(v_x0, v_kUc), v_c2), J.add(v_y, 1.0), J.getv(game.j_ET, "kömür"), (v_sh * 0.95))
		v_c2 = J.add(v_c2, 1.0)
	return null

# art.js:3290
func f__etKivrik(p_x0: Variant = null, p_y: Variant = null, p_len: Variant = null, p_sh: Variant = null, p_k: Variant = null) -> Variant:
	var v_yon: Variant = null
	var v_uc: Variant = null
	var v_oncekiK: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_p2: Variant = null
	var v_kalk: Variant = null
	var v_yy: Variant = null
	var v_a1: Variant = null
	var v_b1: Variant = null
	var v_f2: Variant = null
	var v_x0: Variant = p_x0
	var v_y: Variant = p_y
	var v_len: Variant = p_len
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	v_yon = (1.0 if J.gt(game.f_hash1((v_k * 3.7)), 0.5) else (-J.n(1.0)))
	v_uc = J.gt(game.f_hash1((v_k * 5.9)), 0.5)
	v_oncekiK = null
	v_q = 0.0
	while J.lt(v_q, v_len):
		v_u = (float(v_q) / float((v_len - 1.0)))
		v_p2 = (v_u if J.truth(v_uc) else (1.0 - v_u))
		v_kalk = (0.0 if J.lt(v_p2, 0.62) else (pow((float((v_p2 - 0.62)) / float(0.38)), 1.5) * 2.2))
		v_yy = J.add(v_y, floor(((-J.n(v_kalk)) * v_yon) + 0.5))
		if (not J.eq(v_oncekiK, null) and not J.eq(v_yy, v_oncekiK)):
			v_a1 = min(v_oncekiK, v_yy)
			v_b1 = max(v_oncekiK, v_yy)
			v_f2 = v_a1
			while J.le(v_f2, v_b1):
				game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_f2, 1.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.78))
				game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), v_f2, J.getv(game.j_ET, "et"), (v_sh * 0.94))
				v_f2 = J.add(v_f2, 1.0)
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_yy, 1.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.78))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), v_yy, (J.getv(game.j_ET, "koyu") if (J.eq(v_q, 0.0) or J.eq(v_q, (v_len - 1.0))) else J.getv(game.j_ET, "et")), v_sh)
		if J.gt(v_kalk, 0.8):
			game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), (v_yy - 1.0), J.getv(game.j_ET, "ic"), (v_sh * 1.08))
		v_oncekiK = v_yy
		v_q = J.add(v_q, 1.0)
	return null

# art.js:3320
func f__etKatli(p_x0: Variant = null, p_y: Variant = null, p_len: Variant = null, p_sh: Variant = null, p_k: Variant = null) -> Variant:
	var v_sag: Variant = null
	var v_katL: Variant = null
	var v_altL: Variant = null
	var v_q: Variant = null
	var v_ucA: Variant = null
	var v_kx: Variant = null
	var v_q2: Variant = null
	var v_ucB: Variant = null
	var v_kIc: Variant = null
	var v_x0: Variant = p_x0
	var v_y: Variant = p_y
	var v_len: Variant = p_len
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	v_sag = J.gt(game.f_hash1((v_k * 5.1)), 0.5)
	v_katL = max(3.0, floor((v_len * 0.45) + 0.5))
	v_altL = v_len
	v_q = 0.0
	while J.lt(v_q, v_altL):
		v_ucA = (J.eq(v_q, 0.0) if J.eq(v_q, 0.0) else J.eq(v_q, (v_altL - 1.0)))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_y, 2.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.74))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_y, 1.0), (J.getv(game.j_ET, "koyu") if J.truth(v_ucA) else J.getv(game.j_ET, "orta")), (v_sh * 0.95))
		v_q = J.add(v_q, 1.0)
	v_kx = ((J.add(v_x0, v_altL) - v_katL) if J.truth(v_sag) else v_x0)
	v_q2 = 0.0
	while J.lt(v_q2, v_katL):
		v_ucB = (J.eq(v_q2, 0.0) if J.eq(v_q2, 0.0) else J.eq(v_q2, (v_katL - 1.0)))
		game.ingredient_pixels.f_etPx(J.add(v_kx, v_q2), v_y, (J.getv(game.j_ET, "koyu") if J.truth(v_ucB) else J.getv(game.j_ET, "et")), v_sh)
		if (not J.truth(v_ucB)):
			game.ingredient_pixels.f_etPx(J.add(v_kx, v_q2), (v_y - 1.0), J.getv(game.j_ET, "ic"), (v_sh * 1.06))
		v_q2 = J.add(v_q2, 1.0)
	v_kIc = (v_kx if J.truth(v_sag) else (J.add(v_kx, v_katL) - 1.0))
	game.ingredient_pixels.f_etPx(v_kIc, v_y, J.getv(game.j_ET, "koyu"), (v_sh * 0.88))
	game.ingredient_pixels.f_etPx(v_kIc, J.add(v_y, 1.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.8))
	return null

# art.js:3346
func f__etParca(p_x0: Variant = null, p_y: Variant = null, p_len: Variant = null, p_sh: Variant = null, p_k: Variant = null) -> Variant:
	var v_q: Variant = null
	var v_uc: Variant = null
	var v_x0: Variant = p_x0
	var v_y: Variant = p_y
	var v_len: Variant = p_len
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	v_q = 0.0
	while J.lt(v_q, v_len):
		v_uc = (J.eq(v_q, 0.0) if J.eq(v_q, 0.0) else J.eq(v_q, (v_len - 1.0)))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_y, 2.0), J.getv(game.j_ET, "kabuk"), (v_sh * 0.7))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), J.add(v_y, 1.0), J.getv(game.j_ET, "orta"), (v_sh * 0.95))
		game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), v_y, (J.getv(game.j_ET, "koyu") if J.truth(v_uc) else J.getv(game.j_ET, "et")), v_sh)
		if (not J.truth(v_uc)):
			game.ingredient_pixels.f_etPx(J.add(v_x0, v_q), (v_y - 1.0), J.getv(game.j_ET, "ic"), (v_sh * 1.04))
		v_q = J.add(v_q, 1.0)
	return null

# art.js:3356
func f_meatStrip(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdEt(p_x, p_y, p_sh, p_k, p_sz): return null
	var v_bicim: Variant = null
	var v_len: Variant = null
	var v_x0: Variant = null
	var v_tilt: Variant = null
	var v_gLen: Variant = null
	var v_px0: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	var v_sz: Variant = p_sz
	v_bicim = fmod(J.n(floor((game.f_hash1((v_k * 2.71)) * 100.0))), J.n(10.0))
	v_y = J.add(v_y, floor(((game.f_hash1((v_k * 7.9)) - 0.5) * 3.0) + 0.5))
	game.j__etTon = J.add(0.92, (game.f_hash1((v_k * 1.37)) * 0.24))
	v_gLen = J.add(6.0, (int(J.n((v_sz * 8.0))) | int(J.n(0.0))))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(((v_x - (int(J.n(v_gLen)) >> int(J.n(1.0)))) - 1.0), J.add(v_y, 2.0), J.add(v_gLen, 2.0), 2.0, "#4a2a08")
	J.setv(game.j_ctx, "globalAlpha", 0.18)
	game.f_fr(((v_x - (int(J.n(v_gLen)) >> int(J.n(1.0)))) - 1.0), (v_y - 1.0), 1.0, 4.0, "#4a2a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.lt(v_bicim, 4.0):
		v_len = J.add(6.0, (int(J.n((v_sz * 8.0))) | int(J.n(0.0))))
		v_x0 = (v_x - (int(J.n(v_len)) >> int(J.n(1.0))))
		v_tilt = (1.0 if J.gt(v_sz, 0.66) else ((-J.n(1.0)) if J.lt(v_sz, 0.32) else 0.0))
		game.ingredient_pixels.f__etDuz(v_x0, v_y, v_len, v_sh, v_k, v_tilt)
	else:
		if J.lt(v_bicim, 7.0):
			v_len = J.add(7.0, (int(J.n((v_sz * 6.0))) | int(J.n(0.0))))
			v_x0 = (v_x - (int(J.n(v_len)) >> int(J.n(1.0))))
			game.ingredient_pixels.f__etKivrik(v_x0, v_y, v_len, v_sh, v_k)
		else:
			if J.lt(v_bicim, 9.0):
				v_len = J.add(5.0, (int(J.n((v_sz * 6.0))) | int(J.n(0.0))))
				v_x0 = (v_x - (int(J.n(v_len)) >> int(J.n(1.0))))
				game.ingredient_pixels.f__etKatli(v_x0, v_y, v_len, v_sh, v_k)
			else:
				v_len = J.add(3.0, (int(J.n((v_sz * 4.0))) | int(J.n(0.0))))
				v_x0 = (v_x - (int(J.n(v_len)) >> int(J.n(1.0))))
				game.ingredient_pixels.f__etParca(v_x0, v_y, v_len, v_sh, v_k)
	if (J.gt(v_sh, 0.86) and J.gt(game.f_hash1((v_k * 9.7)), 0.66)):
		v_px0 = J.add(J.add(v_x0, 1.0), floor((game.f_hash1((v_k * 6.3)) * max(1.0, (v_len - 2.0)))))
		game.ingredient_pixels.f_etPx(v_px0, (v_y - 1.0), J.getv(game.j_ET, "yag"), 1.0)
	if J.gt(game.f_hash1((v_k * 4.1)), 0.88):
		game.ingredient_pixels.f_etPx(J.add(v_x0, 1.0), J.add(v_y, 1.0), J.getv(game.j_ET, "kömür"), v_sh)
	game.j__etTon = 1.0
	return null

# art.js:3422
func f_fryBar(p_x0: Variant = null, p_y0: Variant = null, p_L: Variant = null, p_egim: Variant = null, p_buk: Variant = null, p_ust: Variant = null, p_govde: Variant = null, p_alt: Variant = null, p_ucC: Variant = null) -> Variant:
	var v_yarim: Variant = null
	var v_ilkY: Variant = null
	var v_sonY: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_cx: Variant = null
	var v_cy: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	var v_L: Variant = p_L
	var v_egim: Variant = p_egim
	var v_buk: Variant = p_buk
	var v_ust: Variant = p_ust
	var v_govde: Variant = p_govde
	var v_alt: Variant = p_alt
	var v_ucC: Variant = p_ucC
	v_yarim = (int(J.n(v_L)) >> int(J.n(1.0)))
	v_ilkY = 0.0
	v_sonY = 0.0
	v_q = 0.0
	while J.lt(v_q, v_L):
		v_u = ((float(v_q) / float((v_L - 1.0))) if J.gt(v_L, 1.0) else 0.5)
		v_cx = J.add((v_x0 - v_yarim), v_q)
		v_cy = J.add(v_y0, floor((((v_q - v_yarim) * v_egim) - (sin((v_u * J.getv({"PI": PI}, "PI"))) * v_buk)) + 0.5))
		if J.eq(v_q, 0.0):
			v_ilkY = v_cy
		if J.eq(v_q, (v_L - 1.0)):
			v_sonY = v_cy
		game.f_px(v_cx, (v_cy - 1.0), v_ust)
		game.f_px(v_cx, v_cy, v_govde)
		game.f_px(v_cx, J.add(v_cy, 1.0), v_alt)
		v_q = J.add(v_q, 1.0)
	game.f_px((v_x0 - v_yarim), v_ilkY, v_ucC)
	game.f_px((v_x0 - v_yarim), J.add(v_ilkY, 1.0), v_ucC)
	game.f_px((J.add((v_x0 - v_yarim), v_L) - 1.0), v_sonY, v_ucC)
	game.f_px((J.add((v_x0 - v_yarim), v_L) - 1.0), J.add(v_sonY, 1.0), v_ucC)
	return null

# art.js:3439
func f_fryStick(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdPatates(p_x, p_y, p_sh, p_k, p_sz): return null
	var v_L: Variant = null
	var v_ton: Variant = null
	var v_G: Variant = null
	var v_govde: Variant = null
	var v_ust: Variant = null
	var v_alt: Variant = null
	var v_ucC: Variant = null
	var v_mode: Variant = null
	var v_yon: Variant = null
	var v_hgt: Variant = null
	var v_q3: Variant = null
	var v_kay: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_sh: Variant = p_sh
	var v_k: Variant = p_k
	var v_sz: Variant = p_sz
	v_L = J.add(6.0, (int(J.n((v_sz * 7.0))) | int(J.n(0.0))))
	v_ton = game.f_hash1((v_k * 6.1))
	v_G = (J.getv(game.j_PT, "kizarmis") if J.gt(v_ton, 0.74) else (J.getv(game.j_PT, "acik") if J.lt(v_ton, 0.26) else J.getv(game.j_PT, "altin")))
	v_govde = game.character_draw.f_shadeCol(v_G, v_sh)
	v_ust = game.character_draw.f_shadeCol((J.getv(game.j_PT, "altin") if J.gt(v_ton, 0.74) else J.getv(game.j_PT, "isik")), v_sh)
	v_alt = game.character_draw.f_shadeCol(J.getv(game.j_PT, "koyu"), (v_sh * 0.96))
	v_ucC = game.character_draw.f_shadeCol(J.getv(game.j_PT, "uc"), (v_sh * 0.92))
	v_mode = game.f_hash1((v_k * 3.7))
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr((v_x - (int(J.n(v_L)) >> int(J.n(1.0)))), J.add(v_y, 2.0), v_L, 1.0, "#4a3208")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.lt(v_mode, 0.38):
		game.ingredient_pixels.f_fryBar(v_x, v_y, v_L, 0.0, J.add(0.8, (game.f_hash1((v_k * 4.3)) * 0.9)), v_ust, v_govde, v_alt, v_ucC)
	else:
		if J.lt(v_mode, 0.78):
			v_yon = (0.42 if J.gt(game.f_hash1((v_k * 8.3)), 0.5) else (-J.n(0.42)))
			game.ingredient_pixels.f_fryBar(v_x, v_y, v_L, v_yon, 0.5, v_ust, v_govde, v_alt, v_ucC)
		else:
			v_hgt = J.add(4.0, (int(J.n((v_sz * 5.0))) | int(J.n(0.0))))
			v_q3 = 0.0
			while J.lt(v_q3, v_hgt):
				v_kay = floor((sin(((float(v_q3) / float(v_hgt)) * J.getv({"PI": PI}, "PI"))) * 0.9) + 0.5)
				game.f_px(J.add((v_x - 1.0), v_kay), (v_y - v_q3), v_alt)
				game.f_px(J.add(v_x, v_kay), (v_y - v_q3), v_govde)
				game.f_px(J.add(J.add(v_x, 1.0), v_kay), (v_y - v_q3), v_ust)
				v_q3 = J.add(v_q3, 1.0)
			game.f_px((v_x - 1.0), (v_y - v_hgt), v_ucC)
			game.f_px(v_x, (v_y - v_hgt), v_ucC)
			game.f_px(J.add(v_x, 1.0), (v_y - v_hgt), game.character_draw.f_shadeCol(J.getv(game.j_PT, "uc"), (v_sh * 1.15)))
	if J.gt(game.f_hash1((v_k * 9.4)), 0.8):
		J.setv(game.j_ctx, "globalAlpha", 0.85)
		game.f_px((J.add(v_x, (int(J.n((game.f_hash1((v_k * 2.9)) * v_L))) | int(J.n(0.0)))) - (int(J.n(v_L)) >> int(J.n(1.0)))), (v_y - 2.0), J.getv(game.j_PT, "tuz"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:3484
func f_pileSpot(p_i: Variant = null, p_cx: Variant = null, p_halfW: Variant = null, p_baseY: Variant = null, p_pileH: Variant = null, p_seed: Variant = null) -> Variant:
	var v_h1: Variant = null
	var v_h2: Variant = null
	var v_h3: Variant = null
	var v_nx: Variant = null
	var v_mound: Variant = null
	var v_y: Variant = null
	var v_i: Variant = p_i
	var v_cx: Variant = p_cx
	var v_halfW: Variant = p_halfW
	var v_baseY: Variant = p_baseY
	var v_pileH: Variant = p_pileH
	var v_seed: Variant = p_seed
	v_h1 = game.f_hash1(J.add((v_i * 3.71), v_seed))
	v_h2 = game.f_hash1(J.add((v_i * 8.13), (v_seed * 2.1)))
	v_h3 = game.f_hash1(J.add((v_i * 1.97), (v_seed * 0.7)))
	v_nx = ((v_h1 * 2.0) - 1.0)
	v_nx = (v_nx * J.add(0.8, (0.2 * v_h3)))
	v_mound = pow((1.0 - (abs(v_nx) * 0.82)), 0.62)
	v_y = (v_baseY - ((v_mound * v_pileH) * J.add(0.18, (0.82 * v_h2))))
	return [floor(J.add(v_cx, (v_nx * v_halfW)) + 0.5), floor(v_y + 0.5), v_h3]
	return null

