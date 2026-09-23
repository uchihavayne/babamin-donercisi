# Ingredient draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:3497
func f_drawMeatTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	var v_kap: Variant = null
	var v_lvl: Variant = null
	var v_bump: Variant = null
	var v_topY: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	v_kap = (J.method(game.j_TUN, "meatCap", []) if (not J.eq(J.kind(game.j_TUN), "undefined") and J.truth(J.getv(game.j_TUN, "meatCap"))) else 16.0)
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(v_kap)), 0.0, 1.0)
	game.f_trayBase(v_x, v_y, v_w, v_h)
	if J.le(v_n, 0.0):
		game.f_trayInnerShade(v_x, v_y, v_w, v_h)
		return null
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	v_topY = game.f_drawFill(v_x, (v_y - v_bump), v_w, v_h, v_lvl, 1.3, J.ref(game.f_meatStrip, 5))
	J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (v_lvl * 0.12)))
	game.f_fr(J.add(v_x, 2.0), (v_topY - 1.0), (v_w - 4.0), 2.0, "#e8a850")
	J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (v_lvl * 0.08)))
	game.f_vl(J.add(v_x, 2.0), v_topY, ((J.add(v_y, v_h) - 4.0) - v_topY), "#d89440")
	game.f_vl((J.add(v_x, v_w) - 3.0), v_topY, ((J.add(v_y, v_h) - 4.0) - v_topY), "#d89440")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_trayInnerShade(v_x, v_y, v_w, v_h)
	if J.truth(game.f_chance(J.add(0.1, (v_lvl * 0.2)))):
		game.effects.f_part({"x": J.add(J.add(v_x, 6.0), game.math_utils.f_rnd(0.0, (v_w - 12.0))), "y": v_topY, "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(16.0)), (-J.n(7.0))), "life": 0.9, "col": "rgba(246,238,224,.34)", "g": (-J.n(14.0)), "sz": 1.0})
	if J.truth(game.f_chance(J.add(0.03, (v_lvl * 0.05)))):
		game.effects.f_part({"x": J.add(J.add(v_x, 5.0), game.math_utils.f_rnd(0.0, (v_w - 10.0))), "y": J.add(v_topY, 2.0), "vx": game.math_utils.f_rnd((-J.n(10.0)), 10.0), "vy": game.math_utils.f_rnd((-J.n(22.0)), (-J.n(10.0))), "life": 0.35, "col": "#ffd79a", "g": 180.0, "sz": 1.0})
	game.f_trayFlash(v_x, v_y, v_w, v_h, v_fx)
	return null

# art.js:3540
func f_drawPickleTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	var v_lvl: Variant = null
	var v_bump: Variant = null
	var v_topY: Variant = null
	var v_g2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	game.f_trayBase(v_x, v_y, v_w, v_h)
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(v_max)), 0.0, 1.0)
	if J.le(v_n, 0.0):
		game.f_trayInnerShade(v_x, v_y, v_w, v_h)
		return null
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.38)
	game.f_fr(J.add(v_x, 3.0), (J.add(v_y, v_h) - 11.0), (v_w - 6.0), 5.0, "#9dbe45")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl(J.add(v_x, 4.0), (J.add(v_y, v_h) - 11.0), (v_w - 8.0), "#e2efa4")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_topY = game.f_drawFill(v_x, (v_y - v_bump), v_w, v_h, v_lvl, 4.7, J.ref(game.f_pickleSlice, 5))
	v_g2 = 0.0
	while J.lt(v_g2, 6.0):
		J.setv(game.j_ctx, "globalAlpha", 0.5)
		game.f_px(J.add(J.add(v_x, 5.0), (game.f_hash1((v_g2 * 3.9)) * (v_w - 10.0))), J.add(J.add(v_topY, 1.0), floor((sin(J.add((v_t * 2.0), v_g2)) * 0.6) + 0.5)), "#eaf6b8")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_g2 = J.add(v_g2, 1.0)
	game.f_trayInnerShade(v_x, v_y, v_w, v_h)
	game.f_trayFlash(v_x, v_y, v_w, v_h, v_fx)
	return null

# art.js:3565
func f_drawFriesTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	var v_lvl: Variant = null
	var v_bump: Variant = null
	var v_topY: Variant = null
	var v_sI: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	game.f_trayBase(v_x, v_y, v_w, v_h)
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(v_max)), 0.0, 1.0)
	if J.le(v_n, 0.0):
		game.f_trayInnerShade(v_x, v_y, v_w, v_h)
		return null
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	v_topY = game.f_drawFill(v_x, (v_y - v_bump), v_w, v_h, v_lvl, 9.2, J.ref(game.f_fryStick, 5))
	game.f_trayInnerShade(v_x, v_y, v_w, v_h)
	v_sI = 0.0
	while J.lt(v_sI, 8.0):
		J.setv(game.j_ctx, "globalAlpha", 0.5)
		game.f_px(J.add(J.add(v_x, 5.0), (game.f_hash1((v_sI * 5.9)) * (v_w - 10.0))), J.add(J.add(v_topY, 1.0), (game.f_hash1((v_sI * 2.3)) * 4.0)), "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_sI = J.add(v_sI, 1.0)
	game.f_trayFlash(v_x, v_y, v_w, v_h, v_fx)
	return null

# art.js:3584
func f_drawYogurtTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdYogurtTepsi(p_x, p_y, p_w, p_h, p_n, p_max, p_t, p_fx): return null
	var v_lvl: Variant = null
	var v_F: Variant = null
	var v_zh: Variant = null
	var v_e0: Variant = null
	var v_bump: Variant = null
	var v_kaplama: Variant = null
	var v_kabarma: Variant = null
	var v_arka: Variant = null
	var v_ustSinir: Variant = null
	var v_kutle: Variant = null
	var v_cukurlar: Variant = null
	var v_c: Variant = null
	var v_u: Variant = null
	var v_kenar: Variant = null
	var v_oyuk: Variant = null
	var v_ci: Variant = null
	var v_cu: Variant = null
	var v_d: Variant = null
	var v_puruz: Variant = null
	var v_cTop: Variant = null
	var v_yy: Variant = null
	var v_v: Variant = null
	var v_col: Variant = null
	var v_solFark: Variant = null
	var v_oncekiTop: Variant = null
	var v_f: Variant = null
	var v_ci2: Variant = null
	var v_cc: Variant = null
	var v_cxx: Variant = null
	var v_cyy: Variant = null
	var v_sI: Variant = null
	var v_swY: Variant = null
	var v_qq: Variant = null
	var v_wy: Variant = null
	var v_bI: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	game.f_trayBase(v_x, v_y, v_w, v_h)
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(v_max)), 0.0, 1.0)
	v_F = game.tray_draw.f_trayFloor(v_x, v_y, v_w, v_h)
	v_zh = (J.getv(v_F, "on") - J.getv(v_F, "zemin"))
	if J.le(v_n, 0.0):
		J.setv(game.j_ctx, "globalAlpha", 0.42)
		v_e0 = 0.0
		while J.lt(v_e0, 6.0):
			game.f_ell(J.add(J.add(J.getv(v_F, "ix"), 5.0), (v_e0 * 7.0)), ((J.getv(v_F, "on") - 2.0) - (fmod(J.n(v_e0), J.n(2.0)) * 3.0)), 3.0, 1.0, "#cfc7b0")
			v_e0 = J.add(v_e0, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_trayInnerShade(v_x, v_y, v_w, v_h)
		return null
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	v_kaplama = J.add(0.1, (0.9 * v_lvl))
	v_kabarma = floor((v_lvl * 6.0) + 0.5)
	v_arka = max((J.getv(v_F, "arka") - v_kabarma), J.add(v_y, 2.0))
	v_ustSinir = (max(v_arka, (J.getv(v_F, "on") - floor((v_zh * v_kaplama) + 0.5))) - v_bump)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [(J.getv(v_F, "ix") - 1.0), v_y, J.add(J.getv(v_F, "iw"), 2.0), (J.add(J.getv(v_F, "on"), 2.0) - v_y)])
	J.method(game.j_ctx, "clip", [])
	v_kutle = (J.getv(v_F, "on") - v_ustSinir)
	v_cukurlar = [{"p": 0.7, "g": 8.0, "d": max(1.0, floor((v_kutle * 0.26) + 0.5))}, {"p": 0.28, "g": 6.0, "d": max(1.0, floor((v_kutle * 0.15) + 0.5))}]
	v_c = 0.0
	while J.lt(v_c, J.getv(v_F, "iw")):
		v_u = (float(v_c) / float((J.getv(v_F, "iw") - 1.0)))
		v_kenar = floor((pow((abs((v_u - 0.5)) * 2.0), 2.4) * max(1.0, (v_kutle * 0.16))) + 0.5)
		v_oyuk = 0.0
		v_ci = 0.0
		while J.lt(v_ci, J.getv(v_cukurlar, "length")):
			v_cu = J.getv(v_cukurlar, v_ci)
			v_d = abs((v_c - (J.getv(v_cu, "p") * J.getv(v_F, "iw"))))
			if J.lt(v_d, J.getv(v_cu, "g")):
				v_oyuk = J.add(v_oyuk, floor((cos((((float(v_d) / float(J.getv(v_cu, "g"))) * J.getv({"PI": PI}, "PI")) * 0.5)) * J.getv(v_cu, "d")) + 0.5))
			v_ci = J.add(v_ci, 1.0)
		v_puruz = floor(((game.f_hash1(J.add((v_c * 0.9), 3.1)) - 0.5) * 1.6) + 0.5)
		v_cTop = J.add(J.add(J.add(v_ustSinir, v_kenar), v_oyuk), v_puruz)
		if J.gt(v_cTop, (J.getv(v_F, "on") - 1.0)):
			v_cTop = (J.getv(v_F, "on") - 1.0)
		v_yy = v_cTop
		while J.lt(v_yy, J.getv(v_F, "on")):
			v_v = (float((v_yy - v_cTop)) / float(max(1.0, (J.getv(v_F, "on") - v_cTop))))
			v_col = ("#efe8d6" if J.lt(v_v, 0.16) else ("#ded6c0" if J.lt(v_v, 0.45) else ("#c9c0a9" if J.lt(v_v, 0.78) else "#b0a790")))
			game.f_px(J.add(J.getv(v_F, "ix"), v_c), v_yy, v_col)
			v_yy = J.add(v_yy, 1.0)
		game.f_px(J.add(J.getv(v_F, "ix"), v_c), v_cTop, "#fbf7ea")
		v_solFark = (0.0 if J.gt(v_c, 0.0) else 0.0)
		if J.gt(v_c, 0.0):
			v_oncekiTop = J.add(v_ustSinir, floor((pow((abs(((float((v_c - 1.0)) / float((J.getv(v_F, "iw") - 1.0))) - 0.5)) * 2.0), 2.4) * max(1.0, (v_kutle * 0.16))) + 0.5))
			if J.gt(v_cTop, J.add(v_oncekiTop, 1.0)):
				J.setv(game.j_ctx, "globalAlpha", 0.26)
				v_f = 0.0
				while J.lt(v_f, min((v_cTop - v_oncekiTop), 3.0)):
					game.f_px(J.add(J.getv(v_F, "ix"), v_c), (v_cTop - v_f), "#8d8574")
					v_f = J.add(v_f, 1.0)
				J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_c = J.add(v_c, 1.0)
	v_ci2 = 0.0
	while J.lt(v_ci2, J.getv(v_cukurlar, "length")):
		v_cc = J.getv(v_cukurlar, v_ci2)
		v_cxx = floor(J.add(J.getv(v_F, "ix"), (J.getv(v_cc, "p") * J.getv(v_F, "iw"))) + 0.5)
		v_cyy = J.add(J.add(v_ustSinir, J.getv(v_cc, "d")), 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_ell(v_cxx, J.add(v_cyy, 1.0), floor((J.getv(v_cc, "g") * 0.5) + 0.5), 2.0, "#9a9280")
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		game.f_ell((v_cxx - 1.0), v_cyy, floor((J.getv(v_cc, "g") * 0.3) + 0.5), 1.0, "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_ci2 = J.add(v_ci2, 1.0)
	v_sI = 0.0
	while J.lt(v_sI, 3.0):
		v_swY = J.add(J.add(v_ustSinir, 3.0), (v_sI * 4.0))
		if J.gt(v_swY, (J.getv(v_F, "on") - 2.0)):
			break
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		v_qq = 0.0
		while J.lt(v_qq, (J.getv(v_F, "iw") - 6.0)):
			v_wy = J.add(v_swY, floor((sin(J.add((v_qq * 0.3), (v_sI * 1.7))) * 1.1) + 0.5))
			game.f_px(J.add(J.add(J.getv(v_F, "ix"), 3.0), v_qq), v_wy, ("#ffffff" if J.truth(fmod(J.n(v_sI), J.n(2.0))) else "#c9c1ab"))
			v_qq = J.add(v_qq, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_sI = J.add(v_sI, 1.0)
	v_bI = 0.0
	while J.lt(v_bI, 5.0):
		J.setv(game.j_ctx, "globalAlpha", 0.5)
		game.f_px(floor(J.add(J.add(J.getv(v_F, "ix"), 3.0), (game.f_hash1((v_bI * 3.3)) * (J.getv(v_F, "iw") - 6.0))) + 0.5), floor(J.add(J.add(v_ustSinir, 2.0), (game.f_hash1((v_bI * 5.7)) * (v_zh * 0.5))) + 0.5), "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_bI = J.add(v_bI, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.12)
	game.f_fr(J.getv(v_F, "ix"), (v_ustSinir - 1.0), J.getv(v_F, "iw"), 1.0, "#8a8272")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	game.f_trayInnerShade(v_x, v_y, v_w, v_h)
	game.f_trayFlash(v_x, v_y, v_w, v_h, v_fx)
	return null

