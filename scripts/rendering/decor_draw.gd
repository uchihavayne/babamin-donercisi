# Decor draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:3257
func f_tabelaAd() -> Variant:
	return ((J.getv(J.getv(game.j_G, "custom"), "sign") if J.truth(J.getv(game.j_G, "custom")) else J.getv(game.j_G, "custom")) if (J.truth(J.getv(game.j_G, "custom")) and J.truth(J.getv(J.getv(game.j_G, "custom"), "sign"))) else "USTA DÖNER")
	return null

# game.js:3258
func f_tabelaAlt() -> Variant:
	return ((J.getv(J.getv(game.j_G, "custom"), "sub") if J.truth(J.getv(game.j_G, "custom")) else J.getv(game.j_G, "custom")) if (J.truth(J.getv(game.j_G, "custom")) and J.truth(J.getv(J.getv(game.j_G, "custom"), "sub"))) else "")
	return null

# game.js:3259
func f_tabelaGen() -> Variant:
	return max(max(88.0, J.add(game.f_textW(game.decor_draw.f_tabelaAd()), 14.0)), J.add(game.f_textW(game.decor_draw.f_tabelaAlt()), 14.0))
	return null

# game.js:3263
func f_drawTabela(p_sx: Variant = null, p_sy: Variant = null, p_t: Variant = null) -> Variant:
	var v_name: Variant = null
	var v_sub: Variant = null
	var v_sw: Variant = null
	var v_i: Variant = null
	var v_on: Variant = null
	var v_sx: Variant = p_sx
	var v_sy: Variant = p_sy
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdTabela(p_sx, p_sy, p_t): return null
	v_name = game.decor_draw.f_tabelaAd()
	v_sub = game.decor_draw.f_tabelaAlt()
	v_sw = game.decor_draw.f_tabelaGen()
	game.f_rrect((v_sx - 2.0), (v_sy - 2.0), J.add(v_sw, 4.0), 30.0, 3.0, "#3a2a1e")
	game.f_rrect(v_sx, v_sy, v_sw, 26.0, 2.0, "#c0281c")
	game.f_rrect(J.add(v_sx, 2.0), J.add(v_sy, 2.0), (v_sw - 4.0), 22.0, 2.0, "#e2483a")
	game.text_draw.f_txt(v_name, J.add(v_sx, (float(v_sw) / float(2.0))), J.add(v_sy, 5.0), J.getv(game.j_P, "au0"), {"align": "c", "outline": "#8e1c14"})
	if J.truth(v_sub):
		game.text_draw.f_txt(v_sub, J.add(v_sx, (float(v_sw) / float(2.0))), J.add(v_sy, 15.0), J.getv(game.j_P, "white"), {"align": "c"})
	v_i = 0.0
	while J.lt(v_i, floor((float(v_sw) / float(14.0)))):
		v_on = J.gt(sin(J.add((v_t * 4.0), v_i)), (-J.n(0.3)))
		game.f_disc(J.add(J.add(v_sx, 8.0), (v_i * 14.0)), J.add(v_sy, 27.0), 2.0, (J.getv(game.j_P, "au0") if J.truth(v_on) else "#8a7a4a"))
		if J.truth(v_on):
			J.setv(game.j_ctx, "globalAlpha", 0.25)
			game.f_disc(J.add(J.add(v_sx, 8.0), (v_i * 14.0)), J.add(v_sy, 27.0), 4.0, J.getv(game.j_P, "au1"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# game.js:3278
func f_drawPoster(p_kind: Variant = null, p_t: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_kw: Variant = null
	var v_kh: Variant = null
	var v_f: Variant = null
	var v_b: Variant = null
	var v_mcx: Variant = null
	var v_mcy: Variant = null
	var v_d1: Variant = null
	var v_g1: Variant = null
	var v_d2: Variant = null
	var v_g2: Variant = null
	var v_sd: Variant = null
	var v_sxx: Variant = null
	var v_d4: Variant = null
	var v_g4: Variant = null
	var v_pcx: Variant = null
	var v_cx2: Variant = null
	var v_i: Variant = null
	var v_rr: Variant = null
	var v_px2: Variant = null
	var v_py2: Variant = null
	var v_kind: Variant = p_kind
	var v_t: Variant = p_t
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	# REMAKE kancasi
	if game.f_hdAfis(p_kind, p_x, p_y): return null
	v_x = (106.0 if J.eq(v_x, null) else v_x)
	v_y = (50.0 if J.eq(v_y, null) else v_y)
	if J.eq(v_kind, 1.0):
		v_kw = 42.0
		v_kh = 30.0
		v_f = 0.0
		while J.lt(v_f, v_kw):
			game.f_px(J.add(v_x, v_f), (v_y - 2.0), "#e8dcc0")
			game.f_px(J.add(v_x, v_f), (v_y - 1.0), "#cfc3a6")
			game.f_px(J.add(v_x, v_f), J.add(v_y, v_kh), "#e8dcc0")
			game.f_px(J.add(v_x, v_f), J.add(J.add(v_y, v_kh), 1.0), "#cfc3a6")
			v_f = J.add(v_f, 2.0)
		game.f_fr(v_x, v_y, v_kw, v_kh, "#6b1a14")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_kw - 2.0), (v_kh - 2.0), "#a8321f")
		game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_kw - 2.0), "#c9553a")
		game.f_rc(J.add(v_x, 2.0), J.add(v_y, 2.0), (v_kw - 4.0), (v_kh - 4.0), "#1f4f6a")
		v_b = 5.0
		while J.lt(v_b, (v_kw - 5.0)):
			game.f_px(J.add(v_x, v_b), J.add(v_y, 3.0), "#e2a83a")
			game.f_px(J.add(J.add(v_x, v_b), 1.0), J.add(v_y, 4.0), "#e2a83a")
			game.f_px(J.add(v_x, v_b), (J.add(v_y, v_kh) - 4.0), "#e2a83a")
			game.f_px(J.add(J.add(v_x, v_b), 1.0), (J.add(v_y, v_kh) - 5.0), "#e2a83a")
			v_b = J.add(v_b, 4.0)
		game.f_fr(J.add(v_x, 5.0), J.add(v_y, 6.0), (v_kw - 10.0), (v_kh - 12.0), "#8e2418")
		v_mcx = floor(J.add(v_x, (float(v_kw) / float(2.0))) + 0.5)
		v_mcy = floor(J.add(v_y, (float(v_kh) / float(2.0))) + 0.5)
		v_d1 = (-J.n(5.0))
		while J.le(v_d1, 5.0):
			v_g1 = (9.0 - (abs(v_d1) * 2.0))
			if J.gt(v_g1, 0.0):
				game.f_fr((v_mcx - v_g1), J.add(v_mcy, v_d1), (v_g1 * 2.0), 1.0, "#1f4f6a")
			v_d1 = J.add(v_d1, 1.0)
		v_d2 = (-J.n(3.0))
		while J.le(v_d2, 3.0):
			v_g2 = (6.0 - (abs(v_d2) * 2.0))
			if J.gt(v_g2, 0.0):
				game.f_fr((v_mcx - v_g2), J.add(v_mcy, v_d2), (v_g2 * 2.0), 1.0, "#e2a83a")
			v_d2 = J.add(v_d2, 1.0)
		game.f_px(v_mcx, v_mcy, "#8e2418")
		v_sd = (-J.n(1.0))
		while J.le(v_sd, 1.0):
			v_sxx = J.add(v_mcx, (v_sd * 14.0))
			v_d4 = (-J.n(2.0))
			while J.le(v_d4, 2.0):
				v_g4 = (3.0 - abs(v_d4))
				if J.gt(v_g4, 0.0):
					game.f_fr((v_sxx - v_g4), J.add(v_mcy, v_d4), (v_g4 * 2.0), 1.0, "#e2a83a")
				v_d4 = J.add(v_d4, 1.0)
			v_sd = J.add(v_sd, 2.0)
	else:
		if J.eq(v_kind, 2.0):
			game.f_rrect(v_x, v_y, 40.0, 36.0, 2.0, "#2b2018")
			game.f_rrect(J.add(v_x, 2.0), J.add(v_y, 2.0), 36.0, 32.0, 2.0, "#f2e2b8")
			v_pcx = J.add(v_x, 20.0)
			game.text_draw.f_txt("DÖNER", v_pcx, J.add(v_y, 4.0), "#c0281c", {"align": "c"})
			v_cx2 = v_pcx
			game.f_vl(v_cx2, J.add(v_y, 12.0), 13.0, "#9aa3ab")
			v_i = 0.0
			while J.lt(v_i, 11.0):
				v_rr = J.add(2.0, floor((sin(((float(v_i) / float(11.0)) * J.getv({"PI": PI}, "PI"))) * 4.0) + 0.5))
				game.f_fr((v_cx2 - v_rr), J.add(J.add(v_y, 13.0), v_i), (v_rr * 2.0), 1.0, ("#e2483a" if J.lt(v_i, 2.0) else ("#a8621f" if J.eq(fmod(J.n(v_i), J.n(4.0)), 0.0) else "#c98436")))
				v_i = J.add(v_i, 1.0)
			game.text_draw.f_txt("TAZE", v_pcx, J.add(v_y, 25.0), "#2f5f9e", {"align": "c"})
		else:
			if J.eq(v_kind, 3.0):
				game.f_rrect(J.add(v_x, 4.0), v_y, 32.0, 34.0, 2.0, "#6d4a22")
				game.f_rrect(J.add(v_x, 6.0), J.add(v_y, 2.0), 28.0, 30.0, 2.0, "#c9a06a")
				game.f_rrect(J.add(v_x, 7.0), J.add(v_y, 3.0), 26.0, 24.0, 1.0, "#8aa8b8")
				v_px2 = J.add(v_x, 20.0)
				v_py2 = J.add(v_y, 18.0)
				game.f_ell(v_px2, v_py2, 7.0, 8.0, "#f0bd8a")
				game.f_fr((v_px2 - 8.0), J.add(v_py2, 6.0), 16.0, 9.0, "#c33c2c")
				game.f_fr((v_px2 - 6.0), (v_py2 - 9.0), 13.0, 6.0, J.getv(game.j_P, "red2"))
				game.f_fr((v_px2 - 5.0), (v_py2 - 9.0), 11.0, 5.0, J.getv(game.j_P, "red1"))
				game.f_fr((v_px2 - 5.0), J.add(v_py2, 2.0), 11.0, 2.0, "#efefe9")
				game.f_fr((v_px2 - 4.0), (v_py2 - 2.0), 3.0, 2.0, "#2b2018")
				game.f_fr(J.add(v_px2, 2.0), (v_py2 - 2.0), 3.0, 2.0, "#2b2018")
				game.f_ln(J.add(v_x, 4.0), J.add(v_y, 8.0), J.add(v_x, 12.0), v_y, "#2b2018")
				game.f_ln(J.add(v_x, 5.0), J.add(v_y, 9.0), J.add(v_x, 13.0), J.add(v_y, 1.0), "#2b2018")
				game.text_draw.f_txt("BABA", J.add(v_x, 20.0), J.add(v_y, 28.0), "#5a3a1e", {"align": "c"})
	return null

# game.js:3347
func f_drawWallDecor(p_t: Variant = null) -> Variant:
	var v_dayK: Variant = null
	var v_cinfo: Variant = null
	var v_cu: Variant = null
	var v_ct: Variant = null
	var v_shutK: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_sw0: Variant = null
	var v_r: Variant = null
	var v_t: Variant = p_t
	v_dayK = 0.0
	if ((J.eq(J.getv(game.j_G, "scene"), "play") and J.truth(J.getv(game.j_G, "cfg"))) and J.truth(J.getv(J.getv(game.j_G, "cfg"), "len"))):
		v_dayK = game.math_utils.f_clamp((1.0 - (float(J.getv(game.j_G, "timeLeft")) / float(J.getv(J.getv(game.j_G, "cfg"), "len")))), 0.0, 1.0)
		v_dayK = game.math_utils.f_clamp((float((v_dayK - 0.45)) / float(0.55)), 0.0, 1.0)
	v_cinfo = null
	v_cu = J.getv(game.j_G, "courier")
	if (J.truth(v_cu) and J.eq(J.getv(v_cu, "state"), "away")):
		v_ct = game.math_utils.f_clamp((float(J.getv(v_cu, "t")) / float(max(0.001, J.method(game.j_TUN, "courierTime", [game.j_G])))), 0.0, 1.0)
		if J.lt(v_ct, 0.2):
			v_cinfo = {"out": (float(v_ct) / float(0.2)), "dir": (-J.n(1.0))}
		else:
			if J.gt(v_ct, 0.76):
				v_cinfo = {"out": (float((v_ct - 0.76)) / float(0.24)), "dir": 1.0}
	game.street_draw.f_drawStreet(v_t, v_dayK, (game.weather_system.f_isRain() if J.eq(J.getv(game.j_G, "scene"), "play") else J.eq(J.getv(game.j_G, "scene"), "play")), v_cinfo)
	v_shutK = 0.0
	if J.eq(J.getv(game.j_G, "scene"), "play"):
		v_shutK = J.getv(game.j_G, "shutT")
	else:
		if J.eq(J.getv(game.j_G, "scene"), "dayend"):
			v_shutK = game.math_utils.f_clamp((float(J.getv(game.j_G, "sceneT")) / float(1.1)), 0.0, 1.0)
	if J.gt(v_shutK, 0.0):
		game.window_draw.f_drawShutter(v_shutK)
	v_sx = 168.0
	v_sy = 2.0
	if J.gt(game.equipment_system.f_UV(game.j_G, "sign"), 0.0):
		v_sw0 = game.decor_draw.f_tabelaGen()
		v_sx = floor((J.add(J.getv(J.getv(game.j_LAY, "win"), "x"), (float(J.getv(J.getv(game.j_LAY, "win"), "w")) / float(2.0))) - (float(v_sw0) / float(2.0))) + 0.5)
		game.decor_draw.f_drawTabela(v_sx, v_sy, v_t)
	if J.gt(game.equipment_system.f_UV(game.j_G, "paint"), 0.0):
		# REMAKE kancasi
		if not game.f_hdLamba():
			game.f_vl(120.0, 0.0, 14.0, "#3a2a1e")
			game.f_rrect(112.0, 14.0, 17.0, 7.0, 2.0, "#c9a04a")
			game.f_rrect(113.0, 14.0, 15.0, 5.0, 2.0, "#e8c46a")
			J.setv(game.j_ctx, "globalAlpha", 0.13)
			v_r = 0.0
			while J.lt(v_r, 26.0):
				game.f_fr(((120.0 - 3.0) - v_r), J.add(21.0, v_r), J.add(7.0, (v_r * 2.0)), 1.0, "#ffe9a0")
				v_r = J.add(v_r, 1.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_disc(120.0, 21.0, 2.0, "#fff6c0")
	game.f_drawPoster(((J.getv(J.getv(game.j_G, "custom"), "poster") if J.truth(J.getv(game.j_G, "custom")) else J.getv(game.j_G, "custom")) if (J.truth(J.getv(game.j_G, "custom")) and J.truth(J.getv(J.getv(game.j_G, "custom"), "poster"))) else 0.0), v_t)
	return null

