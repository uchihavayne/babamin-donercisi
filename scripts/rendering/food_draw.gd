# Food draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# food.js:632
func f_drawFriesCup(p_cx: Variant = null, p_cy: Variant = null, p_q: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdPatatesKutusu(p_cx, p_cy, p_q, p_t): return null
	var v_bos: Variant = null
	var v_koyuUc: Variant = null
	var v_govdeler: Variant = null
	var v_sira: Variant = null
	var v_adet: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_boy: Variant = null
	var v_egim: Variant = null
	var v_fx: Variant = null
	var v_taban: Variant = null
	var v_tepe: Variant = null
	var v_gc: Variant = null
	var v_q: Variant = p_q
	var v_u: Variant = null
	var v_xx: Variant = null
	var v_yy: Variant = null
	var v_ustG: Variant = null
	var v_altG: Variant = null
	var v_gy: Variant = null
	var v_gh: Variant = null
	var v_r2: Variant = null
	var v_u2: Variant = null
	var v_gen: Variant = null
	var v_x0: Variant = null
	var v_agz: Variant = null
	var v_kapY: Variant = null
	var v_kapH: Variant = null
	var v_r3: Variant = null
	var v_u3: Variant = null
	var v_g3: Variant = null
	var v_xk: Variant = null
	var v_yk: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_t: Variant = p_t
	v_bos = J.eq(v_q, "bos")
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_ell(v_cx, J.add(v_cy, 9.0), 8.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_koyuUc = "#8a5a12"
	v_govdeler = ["#f0c24a", "#e0a828", "#f8d874"]
	v_sira = 0.0
	while J.lt(v_sira, (0.0 if J.truth(v_bos) else 2.0)):
		v_adet = (6.0 if J.eq(v_sira, 0.0) else 5.0)
		v_i = 0.0
		while J.lt(v_i, v_adet):
			v_k = J.add((v_sira * 7.0), v_i)
			v_boy = J.add(7.0, floor((game.f_hash1((v_k * 4.3)) * 5.0) + 0.5))
			v_egim = floor(((game.f_hash1((v_k * 2.9)) - 0.5) * 3.0) + 0.5)
			v_fx = J.add(J.add((v_cx - 6.0), (v_i * (2.4 if J.eq(v_sira, 0.0) else 2.8))), (1.0 if J.truth(v_sira) else 0.0))
			v_taban = J.add(v_cy, (1.0 if J.eq(v_sira, 0.0) else 3.0))
			v_tepe = (v_taban - v_boy)
			v_gc = J.getv(v_govdeler, fmod(J.n(J.add(v_k, v_sira)), J.n(J.getv(v_govdeler, "length"))))
			if J.eq(v_sira, 0.0):
				J.setv(game.j_ctx, "globalAlpha", 0.78)
			v_q = 0.0
			while J.lt(v_q, v_boy):
				v_u = (float(v_q) / float(max(1.0, (v_boy - 1.0))))
				v_xx = floor(J.add(v_fx, (v_egim * v_u)) + 0.5)
				v_yy = (v_taban - v_q)
				game.f_px(v_xx, v_yy, (v_koyuUc if J.eq(v_q, (v_boy - 1.0)) else v_gc))
				game.f_px(J.add(v_xx, 1.0), v_yy, (v_koyuUc if J.eq(v_q, (v_boy - 1.0)) else game.character_draw.f_shadeCol(v_gc, 0.82)))
				v_q = J.add(v_q, 1.0)
			game.f_px(floor(J.add(v_fx, v_egim) + 0.5), J.add(v_tepe, 1.0), "#fff0c0")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_i = J.add(v_i, 1.0)
		v_sira = J.add(v_sira, 1.0)
	v_ustG = (19.0 if J.truth(v_bos) else 21.0)
	v_altG = 11.0
	v_gy = (v_cy - 3.0)
	v_gh = 14.0
	v_r2 = 0.0
	while J.lt(v_r2, v_gh):
		v_u2 = (float(v_r2) / float((v_gh - 1.0)))
		v_gen = floor(J.add(v_ustG, ((v_altG - v_ustG) * v_u2)) + 0.5)
		v_x0 = floor((v_cx - (float(v_gen) / float(2.0))) + 0.5)
		v_yy = J.add(v_gy, v_r2)
		game.f_fr(v_x0, v_yy, v_gen, 1.0, "#7d1610")
		game.f_fr(J.add(v_x0, 1.0), v_yy, (v_gen - 2.0), 1.0, ("#e8483a" if J.lt(v_u2, 0.14) else "#c22a20"))
		game.f_px(J.add(v_x0, 1.0), v_yy, "#ff7f6c")
		game.f_px(J.add(v_x0, 2.0), v_yy, "#e8483a")
		game.f_px((J.add(v_x0, v_gen) - 2.0), v_yy, "#5e120d")
		v_r2 = J.add(v_r2, 1.0)
	v_agz = floor((v_ustG - 3.0) + 0.5)
	game.f_fr((v_cx - (float(v_agz) / float(2.0))), v_gy, v_agz, 2.0, "#5e120d")
	game.f_hl((v_cx - (float(v_agz) / float(2.0))), v_gy, v_agz, ("#7d1610" if J.truth(v_bos) else "#8e1c14"))
	game.f_hl(J.add((v_cx - (float(v_ustG) / float(2.0))), 1.0), v_gy, (v_ustG - 2.0), "#ff7f6c")
	v_kapY = J.add(v_gy, 4.0)
	v_kapH = 6.0
	v_r3 = 0.0
	while J.lt(v_r3, v_kapH):
		v_u3 = (float(J.add(v_r3, 4.0)) / float((v_gh - 1.0)))
		v_g3 = (floor(J.add(v_ustG, ((v_altG - v_ustG) * v_u3)) + 0.5) - 4.0)
		v_xk = floor((v_cx - (float(v_g3) / float(2.0))) + 0.5)
		v_yk = J.add(v_kapY, v_r3)
		game.f_fr(v_xk, v_yk, v_g3, 1.0, ("#ffe98e" if J.eq(v_r3, 0.0) else ("#f7d34a" if J.lt(v_r3, 3.0) else ("#e0be32" if J.lt(v_r3, 5.0) else "#c9a41c"))))
		game.f_px(v_xk, v_yk, "#c9a41c")
		game.f_px((J.add(v_xk, v_g3) - 1.0), v_yk, "#a88a14")
		v_r3 = J.add(v_r3, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_hl(floor((v_cx - (float((v_ustG - 6.0)) / float(2.0))) + 0.5), J.add(v_kapY, v_kapH), (v_ustG - 6.0), "#5e120d")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_vl(J.add(floor((v_cx - (float(v_ustG) / float(2.0))) + 0.5), 3.0), J.add(v_gy, 2.0), (v_gh - 3.0), "#5e120d")
	game.f_vl((floor(J.add(v_cx, (float(v_ustG) / float(2.0))) + 0.5) - 4.0), J.add(v_gy, 2.0), (v_gh - 3.0), "#5e120d")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl(J.add(floor((v_cx - (float(v_altG) / float(2.0))) + 0.5), 1.0), (J.add(v_gy, v_gh) - 1.0), (v_altG - 2.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_bos):
		game.f_fr(J.add((v_cx - (float(v_agz) / float(2.0))), 1.0), J.add(v_gy, 1.0), (v_agz - 2.0), 3.0, "#6b1710")
		game.f_px(J.add((v_cx - (float(v_agz) / float(2.0))), 2.0), v_gy, "#c22a20")
		game.f_px((J.add(v_cx, (float(v_agz) / float(2.0))) - 3.0), v_gy, "#c22a20")
	return null

# food.js:717
func f_drawSweetPlate(p_cx: Variant = null, p_cy: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdTatliTabagi(p_cx, p_cy, p_t): return null
	var v_i: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_ell(v_cx, J.add(v_cy, 6.0), 12.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_cx, J.add(v_cy, 4.0), 13.0, 4.0, "#c9cfd6")
	game.f_ell(v_cx, J.add(v_cy, 3.0), 13.0, 4.0, "#eef2f5")
	game.f_ell(v_cx, J.add(v_cy, 2.0), 10.0, 3.0, "#d7dde3")
	game.f_ell(v_cx, J.add(v_cy, 2.0), 9.0, 2.0, "#c98a2a")
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_rx = J.add((v_cx - 7.0), (v_i * 7.0))
		v_ry = ((v_cy - 5.0) - (fmod(J.n(v_i), J.n(2.0)) * 2.0))
		game.garnish_draw.f_drawBaklava(v_rx, v_ry)
		v_i = J.add(v_i, 1.0)
	return null

# food.js:730
func f_drawCup(p_cx: Variant = null, p_cy: Variant = null, p_kind: Variant = null, p_fill: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdKupa(p_cx, p_cy, p_kind, p_fill, p_t): return null
	var v_col0: Variant = null
	var v_col1: Variant = null
	var v_y: Variant = null
	var v_w: Variant = null
	var v_lh: Variant = null
	var v_y2: Variant = null
	var v_yy: Variant = null
	var v_w2: Variant = null
	var v_b: Variant = null
	var v_y3: Variant = null
	var v_w3: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_kind: Variant = p_kind
	var v_fill: Variant = p_fill
	var v_t: Variant = p_t
	if J.eq(v_kind, "cola"):
		v_col0 = "#8a3a20"
		v_col1 = "#4a1c10"
	else:
		if (J.eq(v_kind, "orange") or J.eq(v_kind, "fanta")):
			v_col0 = J.getv(game.j_P, "or0")
			v_col1 = J.getv(game.j_P, "or1")
		else:
			v_col0 = "#ffffff"
			v_col1 = "#e4e2d8"
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_ell(v_cx, J.add(v_cy, 10.0), 6.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_y = 0.0
	while J.lt(v_y, 16.0):
		v_w = J.add(5.0, floor((v_y * 0.12) + 0.5))
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr((v_cx - v_w), J.add((v_cy - 6.0), v_y), (v_w * 2.0), 1.0, "#dfeaf0")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_y = J.add(v_y, 1.0)
	v_lh = floor((14.0 * game.math_utils.f_clamp(v_fill, 0.0, 1.0)) + 0.5)
	v_y2 = 0.0
	while J.lt(v_y2, v_lh):
		v_yy = (J.add(v_cy, 8.0) - v_y2)
		v_w2 = J.add(5.0, floor(((15.0 - v_y2) * 0.12) + 0.5))
		game.f_fr(J.add((v_cx - v_w2), 1.0), v_yy, ((v_w2 * 2.0) - 2.0), 1.0, (v_col0 if J.eq(v_y2, (v_lh - 1.0)) else v_col1))
		v_y2 = J.add(v_y2, 1.0)
	if J.gt(v_lh, 0.0):
		game.f_hl((v_cx - 4.0), J.add((J.add(v_cy, 8.0) - v_lh), 1.0), 8.0, v_col0)
	if (J.eq(v_kind, "cola") and J.gt(v_lh, 3.0)):
		v_b = 0.0
		while J.lt(v_b, 4.0):
			game.f_px(J.add((v_cx - 3.0), (v_b * 2.0)), (J.add(v_cy, 6.0) - (int(J.n((game.f_hash1((int(J.n(J.add((v_b * 3.1), v_t))) | int(J.n(0.0)))) * v_lh))) | int(J.n(0.0)))), "#a9713f")
			v_b = J.add(v_b, 1.0)
	v_y3 = 0.0
	while J.lt(v_y3, 16.0):
		v_w3 = J.add(5.0, floor((v_y3 * 0.12) + 0.5))
		game.f_px((v_cx - v_w3), J.add((v_cy - 6.0), v_y3), "rgba(255,255,255,.75)")
		game.f_px((J.add(v_cx, v_w3) - 1.0), J.add((v_cy - 6.0), v_y3), "rgba(200,220,230,.85)")
		v_y3 = J.add(v_y3, 1.0)
	game.f_hl((v_cx - 5.0), (v_cy - 6.0), 11.0, "#ffffff")
	game.f_ell(v_cx, J.add(v_cy, 9.0), 6.0, 2.0, "rgba(220,235,242,.8)")
	game.f_ln(J.add(v_cx, 2.0), (v_cy - 10.0), J.add(v_cx, 4.0), (v_cy - 3.0), ("#e2382a" if J.eq(v_kind, "cola") else "#3f79c0"))
	game.f_ln(J.add(v_cx, 3.0), (v_cy - 10.0), J.add(v_cx, 5.0), (v_cy - 3.0), "#ffffff")
	return null

# food.js:771
func f_drawItem(p_it: Variant = null, p_x: Variant = null, p_y: Variant = null, p_t: Variant = null) -> Variant:
	var v_it: Variant = p_it
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	if (not J.truth(v_it)):
		return null
	if J.eq(J.getv(v_it, "kind"), "wrap"):
		if J.eq(J.getv(v_it, "state"), "open"):
			game.wrap_draw.f_drawWrapOpen(v_x, v_y, v_it, v_t)
		else:
			game.wrap_draw.f_drawWrapRolled(v_x, v_y, v_it, v_t)
	else:
		if J.eq(J.getv(v_it, "kind"), "fries"):
			game.food_draw.f_drawFriesCup(v_x, v_y, J.getv(v_it, "q"), v_t)
		else:
			if J.eq(J.getv(v_it, "kind"), "fbox"):
				game.food_draw.f_drawFriesCup(v_x, v_y, "ok", v_t)
			else:
				if J.eq(J.getv(v_it, "kind"), "sweet"):
					game.food_draw.f_drawSweetPlate(v_x, v_y, v_t)
				else:
					if J.eq(J.getv(v_it, "kind"), "drink"):
						game.food_draw.f_drawCup(v_x, v_y, J.getv(v_it, "type"), (1.0 if J.eq(J.getv(v_it, "fill"), null) else J.getv(v_it, "fill")), v_t)
					else:
						if J.eq(J.getv(v_it, "kind"), "plate"):
							game.plate_draw.f_drawPlate(v_x, v_y, v_it, v_t, 0.85)
						else:
							if J.eq(J.getv(v_it, "kind"), "pide"):
								game.plate_draw.f_drawPideBoard(v_x, v_y, v_it, v_t, 0.85)
	return null

# food.js:1019
func f_drawCursor(p_x: Variant = null, p_y: Variant = null, p_mode: Variant = null, p_held: Variant = null, p_t: Variant = null) -> Variant:
	var v_pat: Variant = null
	var v_j: Variant = null
	var v_i: Variant = null
	var v_j2: Variant = null
	var v_i2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_mode: Variant = p_mode
	var v_held: Variant = p_held
	var v_t: Variant = p_t
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	if J.truth(v_held):
		J.setv(game.j_ctx, "globalAlpha", 0.95)
		game.food_draw.f_drawItem(v_held, J.add(v_x, 2.0), J.add(v_y, 16.0), v_t)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if ((J.eq(J.getv(v_held, "kind"), "wrap") and not J.eq(J.getv(v_held, "state"), "open")) and J.eq(J.kind(J.ref(game.legacy_order_draw.f_wrapEtiket, 4)), "function")):
			game.legacy_order_draw.f_wrapEtiket(J.add(v_x, 2.0), J.add(v_y, 28.0), v_held, false)
	# REMAKE kancasi
	if game.f_hdImlec(v_x, v_y, v_mode): return null
	if J.eq(v_mode, "knife"):
		game.f_fr((v_x - 1.0), (v_y - 2.0), 3.0, 14.0, "#2b2018")
		game.f_fr(v_x, (v_y - 1.0), 2.0, 12.0, "#e8eef4")
		game.f_fr(v_x, (v_y - 1.0), 1.0, 12.0, "#ffffff")
		game.f_fr((v_x - 2.0), J.add(v_y, 11.0), 5.0, 5.0, J.getv(game.j_P, "wd2"))
		game.f_hl((v_x - 2.0), J.add(v_y, 11.0), 5.0, J.getv(game.j_P, "wd1"))
		return null
	v_pat = (["..##....", ".#..#...", ".#..#.##", ".#..#.##", ".#....##", "#......#", "#......#", ".#....#.", "..####.."] if J.eq(v_mode, "grab") else [".#......", ".##.....", ".#.#....", ".#..#...", ".#...#..", ".#....#.", ".#..###.", ".#.##...", ".##.....", ".#......"])
	v_j = 0.0
	while J.lt(v_j, J.getv(v_pat, "length")):
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(v_pat, v_j), "length")):
			if J.eq(J.getv(J.getv(v_pat, v_j), v_i), "#"):
				game.f_fr(J.add(v_x, v_i), J.add(v_y, v_j), 1.0, 1.0, J.getv(game.j_P, "ink"))
			v_i = J.add(v_i, 1.0)
		v_j = J.add(v_j, 1.0)
	if not J.eq(v_mode, "grab"):
		v_j2 = 1.0
		while J.lt(v_j2, 9.0):
			v_i2 = 2.0
			while J.lt(v_i2, 7.0):
				if (((J.truth(J.getv(v_pat, v_j2)) and J.eq(J.getv(J.getv(v_pat, v_j2), v_i2), ".")) and J.ge(J.method(J.method(J.getv(v_pat, v_j2), "slice", [0.0, v_i2]), "indexOf", ["#"]), 0.0)) and J.ge(J.method(J.method(J.getv(v_pat, v_j2), "slice", [v_i2]), "indexOf", ["#"]), 0.0)):
					game.f_fr(J.add(v_x, v_i2), J.add(v_y, v_j2), 1.0, 1.0, "#ffffff")
				v_i2 = J.add(v_i2, 1.0)
			v_j2 = J.add(v_j2, 1.0)
	else:
		game.f_fr(J.add(v_x, 2.0), J.add(v_y, 1.0), 2.0, 4.0, "#ffffff")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 5.0), 6.0, 3.0, "#ffffff")
		game.f_fr(J.add(v_x, 6.0), J.add(v_y, 2.0), 2.0, 3.0, "#ffffff")
	return null
