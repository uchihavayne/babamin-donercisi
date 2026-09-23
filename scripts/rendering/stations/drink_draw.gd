# Drink draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:4147
func f_drawDrinkMachine(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_D: Variant = null, p_t: Variant = null) -> Variant:
	var v_kd: Variant = null
	var v_yari: Variant = null
	var v_pH: Variant = null
	var v_pY: Variant = null
	var v_i: Variant = null
	var v_pX: Variant = null
	var v_pW: Variant = null
	var v_ic: Variant = null
	var v_ac: Variant = null
	var v_pr: Variant = null
	var v_bx: Variant = null
	var v_gv: Variant = null
	var v_gi: Variant = null
	var v_oY: Variant = null
	var v_oH: Variant = null
	var v_m: Variant = null
	var v_mx: Variant = null
	var v_tip: Variant = null
	var v_s: Variant = null
	var v_yy: Variant = null
	var v_dY: Variant = null
	var v_gx: Variant = null
	var v_sx: Variant = null
	var v_s2: Variant = null
	var v_tx: Variant = null
	var v_dx: Variant = null
	var v_d: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_D: Variant = p_D
	var v_t: Variant = p_t
	v_kd = (game.math_utils.f_clamp(game.equipment_system.f_UV(game.j_G, "drink"), 1.0, 4.0) if (J.eq(J.kind(J.ref(game.equipment_system.f_UV, 2)), "function") and not J.eq(J.kind(game.j_G), "undefined")) else 1.0)
	v_yari = (int(J.n(v_w)) >> int(J.n(1.0)))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 2.0), v_w, v_h, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, v_y, v_w, v_h, "#6f777f")
	game.f_fr(J.add(v_x, 1.0), v_y, (v_w - 2.0), (v_h - 1.0), "#b8c0c7")
	game.f_fr(J.add(v_x, 1.0), v_y, 4.0, (v_h - 1.0), "#dde3e8")
	J.setv(game.j_ctx, "globalAlpha", 0.2)
	game.f_fr((J.add(v_x, v_w) - 5.0), v_y, 4.0, (v_h - 1.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_x - 1.0), (v_y - 3.0), J.add(v_w, 2.0), 5.0, "#2b3138")
	game.f_fr(v_x, (v_y - 3.0), v_w, 4.0, "#3f454e")
	game.f_hl(v_x, (v_y - 3.0), v_w, "#7d868e")
	game.f_fr((v_x - 1.0), (J.add(v_y, v_h) - 3.0), J.add(v_w, 2.0), 5.0, "#2b3138")
	game.f_fr(v_x, (J.add(v_y, v_h) - 3.0), v_w, 4.0, "#3f454e")
	game.f_hl(v_x, (J.add(v_y, v_h) - 3.0), v_w, "#5b626a")
	v_pH = 11.0
	v_pY = J.add(v_y, 2.0)
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_pX = J.add(J.add(v_x, 2.0), (v_i * (v_yari - 1.0)))
		v_pW = (v_yari - 3.0)
		if J.lt(v_pW, 6.0):
			v_i = J.add(v_i, 1.0)
			continue
		game.f_fr((v_pX - 1.0), (v_pY - 1.0), J.add(v_pW, 2.0), J.add(v_pH, 2.0), "#2b3138")
		v_ic = ("#d8641c" if J.eq(v_i, 0.0) else "#8e1c14")
		v_ac = ("#f0821c" if J.eq(v_i, 0.0) else "#c0281c")
		v_pr = ("#ffb03c" if J.eq(v_i, 0.0) else "#e05a48")
		game.f_fr(v_pX, v_pY, v_pW, v_pH, v_ic)
		game.f_fr(v_pX, v_pY, (v_pW - 1.0), (v_pH - 1.0), v_ac)
		game.f_hl(J.add(v_pX, 1.0), v_pY, (v_pW - 3.0), v_pr)
		v_bx = (J.add(v_pX, (int(J.n(v_pW)) >> int(J.n(1.0)))) - 1.0)
		v_gv = ("#e8dcc0" if J.eq(v_i, 0.0) else "#4a1c10")
		v_gi = ("#fffdf2" if J.eq(v_i, 0.0) else "#8a3a20")
		game.f_fr((v_bx - 2.0), J.add(v_pY, 4.0), 5.0, 7.0, "#2a1408")
		game.f_fr((v_bx - 2.0), J.add(v_pY, 4.0), 4.0, 6.0, v_gv)
		game.f_vl((v_bx - 2.0), J.add(v_pY, 4.0), 6.0, v_gi)
		game.f_fr((v_bx - 1.0), J.add(v_pY, 2.0), 3.0, 3.0, v_gv)
		game.f_px((v_bx - 1.0), J.add(v_pY, 2.0), v_gi)
		game.f_fr((v_bx - 1.0), J.add(v_pY, 1.0), 3.0, 1.0, ("#d8641c" if J.eq(v_i, 0.0) else "#c0281c"))
		v_i = J.add(v_i, 1.0)
	v_oY = J.add(J.add(v_pY, v_pH), 1.0)
	v_oH = ((v_h - (v_oY - v_y)) - 4.0)
	if J.gt(v_oH, 6.0):
		game.f_fr(J.add(v_x, 3.0), v_oY, (v_w - 6.0), v_oH, "#232a31")
		game.f_fr(J.add(v_x, 4.0), J.add(v_oY, 1.0), (v_w - 8.0), (v_oH - 2.0), "#3f454e")
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_fr(J.add(v_x, 4.0), J.add(v_oY, 1.0), (v_w - 8.0), 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(J.add(v_x, 3.0), v_oY, (v_w - 6.0), 2.0, "#2b3138")
		game.f_hl(J.add(v_x, 4.0), v_oY, (v_w - 8.0), "#5b626a")
		v_m = 0.0
		while J.lt(v_m, 2.0):
			v_mx = J.add(J.add(v_x, 7.0), (v_m * (v_w - 15.0)))
			game.f_fr((v_mx - 2.0), J.add(v_oY, 1.0), 5.0, 4.0, "#8b939b")
			game.f_fr((v_mx - 2.0), J.add(v_oY, 1.0), 4.0, 3.0, "#dde3e8")
			game.f_fr((v_mx - 1.0), J.add(v_oY, 5.0), 2.0, 2.0, "#6f777f")
			game.f_fr(J.add(v_mx, 2.0), J.add(v_oY, 2.0), 1.0, 4.0, "#2b3138")
			v_tip = ("fanta" if J.eq(v_m, 0.0) else "cola")
			if ((J.truth(v_D) and J.truth(J.getv(v_D, "pours"))) and not J.eq(J.getv(J.getv(v_D, "pours"), v_tip), null)):
				v_s = 0.0
				while J.lt(v_s, (v_oH - 8.0)):
					v_yy = J.add(J.add(v_oY, 7.0), v_s)
					game.f_px(J.add((v_mx - 1.0), (0.0 if J.gt(sin(J.add((v_t * 20.0), v_s)), 0.0) else 1.0)), v_yy, ("#d8641c" if J.eq(v_m, 0.0) else "#8e1c14"))
					game.f_px(v_mx, v_yy, ("#f0821c" if J.eq(v_m, 0.0) else "#c0281c"))
					v_s = J.add(v_s, 1.0)
				if J.truth(game.f_chance(0.4)):
					game.effects.f_part({"x": v_mx, "y": (J.add(v_oY, v_oH) - 2.0), "vx": game.math_utils.f_rnd((-J.n(8.0)), 8.0), "vy": game.math_utils.f_rnd((-J.n(16.0)), (-J.n(4.0))), "life": 0.3, "col": ("#ffb03c" if J.eq(v_m, 0.0) else "#e05a48"), "g": 120.0, "sz": 1.0})
			v_m = J.add(v_m, 1.0)
		v_dY = (J.add(v_oY, v_oH) - 3.0)
		game.f_fr(J.add(v_x, 5.0), v_dY, (v_w - 10.0), 3.0, "#2b3138")
		game.f_hl(J.add(v_x, 5.0), v_dY, (v_w - 10.0), "#8b939b")
		v_gx = 0.0
		while J.lt(v_gx, (v_w - 12.0)):
			game.f_px(J.add(J.add(v_x, 6.0), v_gx), J.add(v_dY, 1.0), "#b8c0c7")
			v_gx = J.add(v_gx, 2.0)
	if J.ge(v_kd, 2.0):
		v_sx = J.add(v_x, (int(J.n(v_w)) >> int(J.n(1.0))))
		game.f_disc(v_sx, (v_y - 5.0), 3.0, "#6f777f")
		game.f_disc(v_sx, (v_y - 5.0), 2.0, "#dde3e8")
		game.f_ln(v_sx, (v_y - 5.0), J.add(v_sx, floor((cos((v_t * 2.0)) * 2.0) + 0.5)), J.add((v_y - 5.0), floor((sin((v_t * 2.0)) * 2.0) + 0.5)), "#c0281c")
	if J.ge(v_kd, 3.0):
		v_s2 = 0.0
		while J.lt(v_s2, 2.0):
			v_tx = (J.add(v_x, v_w) if J.truth(v_s2) else (v_x - 4.0))
			game.f_fr(v_tx, J.add(v_y, 3.0), 4.0, (v_h - 8.0), "#6f777f")
			game.f_fr(v_tx, J.add(v_y, 3.0), 3.0, (v_h - 9.0), "#b8c0c7")
			game.f_hl(v_tx, J.add(v_y, 3.0), 3.0, "#dde3e8")
			game.f_fr(v_tx, J.add(v_y, 1.0), 4.0, 2.0, "#3f454e")
			v_s2 = J.add(v_s2, 1.0)
	if J.ge(v_kd, 4.0):
		v_dx = (J.add(v_x, (int(J.n(v_w)) >> int(J.n(1.0)))) - 8.0)
		game.f_fr(v_dx, (v_y - 8.0), 16.0, 5.0, "#2b3138")
		game.f_fr(J.add(v_dx, 1.0), (v_y - 8.0), 14.0, 4.0, "#141a1f")
		v_d = 0.0
		while J.lt(v_d, 5.0):
			game.f_px(J.add(J.add(v_dx, 3.0), (v_d * 2.0)), (v_y - 6.0), ("#7dff7a" if J.gt(sin(J.add((v_t * 4.0), v_d)), 0.0) else "#2a6a28"))
			v_d = J.add(v_d, 1.0)
	return null

# art.js:4254
func f_drawAyran(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_pour: Variant = null, p_t: Variant = null) -> Variant:
	var v_ix: Variant = null
	var v_iy: Variant = null
	var v_ih: Variant = null
	var v_lvl: Variant = null
	var v_fh: Variant = null
	var v_s2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_pour: Variant = p_pour
	var v_t: Variant = p_t
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 6.0), (v_w - 2.0), (v_h - 10.0), "#8a929b")
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 6.0), (v_w - 4.0), (v_h - 11.0), "#c6ccd2")
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 7.0), 5.0, (v_h - 13.0), "#eef2f6")
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_fr((J.add(v_x, v_w) - 8.0), J.add(v_y, 6.0), 6.0, (v_h - 11.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 6.0), ((float(v_w) / float(2.0)) - 1.0), 4.0, "#9aa3ab")
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 5.0), ((float(v_w) / float(2.0)) - 1.0), 4.0, "#dfe5ea")
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 4.0), 4.0, 2.0, "#8a929b")
	v_ix = (J.add(v_x, v_w) - 7.0)
	v_iy = J.add(v_y, 10.0)
	v_ih = (v_h - 18.0)
	game.f_fr(v_ix, v_iy, 4.0, v_ih, "#3f454e")
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(max(1.0, v_max))), 0.0, 1.0)
	v_fh = floor(((v_ih - 2.0) * v_lvl) + 0.5)
	game.f_fr(J.add(v_ix, 1.0), J.add(J.add(v_iy, 1.0), ((v_ih - 2.0) - v_fh)), 2.0, v_fh, "#f6f4ea")
	if J.gt(v_fh, 2.0):
		game.f_px(J.add(v_ix, 1.0), J.add(J.add(v_iy, 1.0), ((v_ih - 2.0) - v_fh)), "#ffffff")
	game.f_fr(J.add(v_x, 4.0), (J.add(v_y, v_h) - 8.0), 6.0, 4.0, "#7d868e")
	game.f_fr(J.add(v_x, 5.0), (J.add(v_y, v_h) - 8.0), 4.0, 3.0, "#e6ebef")
	game.f_fr(J.add(v_x, 6.0), (J.add(v_y, v_h) - 5.0), 2.0, 3.0, "#9aa3ab")
	game.f_fr(J.add(v_x, 4.0), J.add(v_y, 12.0), (v_w - 12.0), 8.0, "#3f79c0")
	game.text_draw.f_txt("AYRAN", J.add(J.add(v_x, 4.0), (float((v_w - 12.0)) / float(2.0))), J.add(v_y, 14.0), "#ffffff", {"align": "c"})
	if J.truth(v_pour):
		v_s2 = 0.0
		while J.lt(v_s2, 7.0):
			game.f_px(J.add(v_x, 6.0), J.add((J.add(v_y, v_h) - 2.0), v_s2), "#ffffff")
			game.f_px(J.add(v_x, 7.0), J.add((J.add(v_y, v_h) - 2.0), v_s2), "#e4e2d8")
			v_s2 = J.add(v_s2, 1.0)
		if J.truth(game.f_chance(0.4)):
			game.effects.f_part({"x": J.add(v_x, 7.0), "y": J.add(J.add(v_y, v_h), 4.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(12.0)), (-J.n(2.0))), "life": 0.3, "col": "#ffffff", "g": 120.0, "sz": 1.0})
	if J.le(v_n, 0.0):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.5 * sin((J.getv(game.j_G, "t") * 8.0)))))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:4353
func f_drawAyranTank(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_A: Variant = null, p_t: Variant = null) -> Variant:
	var v_lvl: Variant = null
	var v_buyuk: Variant = null
	var v_cx: Variant = null
	var v_r: Variant = null
	var v_by: Variant = null
	var v_bh: Variant = null
	var v_ey: Variant = null
	var v_eh: Variant = null
	var v_gx: Variant = null
	var v_wx: Variant = null
	var v_wy: Variant = null
	var v_wh: Variant = null
	var v_fh: Variant = null
	var v_tx: Variant = null
	var v_ty: Variant = null
	var v_s: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_A: Variant = p_A
	var v_t: Variant = p_t
	v_lvl = game.math_utils.f_clamp((float(v_n) / float(max(1.0, v_max))), 0.0, 1.0)
	v_buyuk = (J.ge(game.equipment_system.f_UV(game.j_G, "ayran"), 2.0) if (J.eq(J.kind(J.ref(game.equipment_system.f_UV, 2)), "function") and not J.eq(J.kind(game.j_G), "undefined")) else false)
	v_cx = floor(J.add(v_x, (float(v_w) / float(2.0))) + 0.5)
	v_r = floor((((float(v_w) / float(2.0)) - 2.0) * (1.0 if J.truth(v_buyuk) else 0.86)) + 0.5)
	v_by = J.add(v_y, 8.0)
	v_bh = (v_h - 18.0)
	game.f_fr(J.add((v_cx - v_r), 2.0), J.add(v_by, v_bh), 3.0, 4.0, "#2f3740")
	game.f_fr((J.add(v_cx, v_r) - 5.0), J.add(v_by, v_bh), 3.0, 4.0, "#2f3740")
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_cx, J.add(J.add(v_by, v_bh), 4.0), v_r, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_cx - v_r), v_by, (v_r * 2.0), v_bh, "#5f6672")
	game.f_fr(J.add((v_cx - v_r), 1.0), v_by, ((v_r * 2.0) - 2.0), (v_bh - 1.0), "#aeb5be")
	game.f_fr(J.add((v_cx - v_r), 1.0), v_by, 4.0, (v_bh - 1.0), "#f2f4f6")
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_fr((J.add(v_cx, v_r) - 5.0), v_by, 4.0, (v_bh - 1.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_cx, (J.add(v_by, v_bh) - 1.0), (v_r - 1.0), 2.0, "#878e99")
	game.f_ell(v_cx, v_by, v_r, 5.0, "#5f6672")
	game.f_ell(v_cx, (v_by - 1.0), v_r, 5.0, "#aeb5be")
	game.f_ell((v_cx - 2.0), (v_by - 3.0), (v_r - 4.0), 2.0, "#f2f4f6")
	game.f_fr((v_cx - 2.0), (v_by - 7.0), 4.0, 5.0, "#2f3740")
	game.f_fr((v_cx - 1.0), (v_by - 8.0), 2.0, 2.0, "#6b737d")
	v_ey = J.add(v_by, 5.0)
	v_eh = 11.0
	game.f_fr(J.add((v_cx - v_r), 1.0), v_ey, ((v_r * 2.0) - 2.0), v_eh, "#1c3a66")
	game.f_fr(J.add((v_cx - v_r), 1.0), v_ey, ((v_r * 2.0) - 2.0), (v_eh - 1.0), "#3f79c0")
	game.f_hl(J.add((v_cx - v_r), 2.0), v_ey, ((v_r * 2.0) - 4.0), "#6b9ad8")
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_fr((J.add(v_cx, v_r) - 5.0), v_ey, 4.0, (v_eh - 1.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_gx = (v_cx - 2.0)
	game.f_fr(v_gx, J.add(v_ey, 2.0), 5.0, 7.0, "#cfcabc")
	game.f_fr(v_gx, J.add(v_ey, 3.0), 4.0, 6.0, "#f6f4ea")
	game.f_hl(v_gx, J.add(v_ey, 2.0), 5.0, "#ffffff")
	game.f_px(J.add(v_gx, 4.0), J.add(v_ey, 5.0), "#a8c8ee")
	v_wx = J.add((v_cx - v_r), 4.0)
	v_wy = J.add(J.add(v_ey, v_eh), 2.0)
	v_wh = ((J.add(v_by, v_bh) - v_wy) - 3.0)
	if J.gt(v_wh, 4.0):
		game.f_fr(v_wx, v_wy, 4.0, v_wh, "#1b2126")
		game.f_fr(v_wx, v_wy, 3.0, (v_wh - 1.0), "#2f3740")
		v_fh = max(0.0, floor(((v_wh - 2.0) * v_lvl) + 0.5))
		game.f_fr(J.add(v_wx, 1.0), J.add(J.add(v_wy, 1.0), ((v_wh - 2.0) - v_fh)), 2.0, v_fh, "#f6f4ea")
		if J.gt(v_fh, 1.0):
			game.f_px(J.add(v_wx, 1.0), J.add(J.add(v_wy, 1.0), ((v_wh - 2.0) - v_fh)), "#ffffff")
		game.f_vl(v_wx, v_wy, v_wh, "#6b737d")
	v_tx = (J.add(v_cx, v_r) - 7.0)
	v_ty = (J.add(v_by, v_bh) - 9.0)
	game.f_fr((v_tx - 2.0), v_ty, 6.0, 4.0, "#5f6672")
	game.f_fr((v_tx - 2.0), v_ty, 5.0, 3.0, "#d3d8de")
	game.f_fr(v_tx, J.add(v_ty, 4.0), 2.0, 3.0, "#878e99")
	game.f_fr((v_tx - 4.0), (v_ty - 3.0), 2.0, 5.0, "#2f3740")
	if (J.truth(v_A) and J.truth(J.getv(v_A, "pour"))):
		v_s = 0.0
		while J.lt(v_s, 8.0):
			game.f_px(J.add(v_tx, (0.0 if J.gt(sin(J.add((v_t * 22.0), v_s)), 0.0) else 1.0)), J.add(J.add(v_ty, 7.0), v_s), "#e8e4d8")
			game.f_px(J.add(v_tx, 1.0), J.add(J.add(v_ty, 7.0), v_s), "#ffffff")
			v_s = J.add(v_s, 1.0)
		if J.truth(game.f_chance(0.35)):
			game.effects.f_part({"x": J.add(v_tx, 1.0), "y": J.add(v_ty, 15.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(14.0)), (-J.n(4.0))), "life": 0.3, "col": "#ffffff", "g": 110.0, "sz": 1.0})
	return null

# art.js:4691
func f_drawIcecekKasasi(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_bolme: Variant = null, p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_bx: Variant = null
	var v_dy: Variant = null
	var v_g: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_bolme: Variant = p_bolme
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 1.0), J.add(J.add(v_y, v_h), 14.0), v_w, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_x - 2.0), (v_y - 4.0), J.add(v_w, 4.0), J.add(v_h, 6.0), "#59636d")
	game.f_fr((v_x - 1.0), (v_y - 3.0), J.add(v_w, 2.0), J.add(v_h, 4.0), "#7a838c")
	game.f_hl((v_x - 1.0), (v_y - 3.0), J.add(v_w, 2.0), "#b8c0c8")
	v_i = 1.0
	while J.lt(v_i, v_bolme):
		v_bx = floor(J.add(v_x, ((float(v_w) / float(v_bolme)) * v_i)) + 0.5)
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		game.f_vl(v_bx, (v_y - 3.0), J.add(v_h, 4.0), "#4a525a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_vl(J.add(v_bx, 1.0), (v_y - 3.0), J.add(v_h, 4.0), "#98a1aa")
		v_i = J.add(v_i, 1.0)
	v_dy = J.add(J.add(v_y, v_h), 6.0)
	game.f_fr((v_x - 2.0), v_dy, J.add(v_w, 4.0), 5.0, "#4a525a")
	game.f_fr((v_x - 1.0), v_dy, J.add(v_w, 2.0), 4.0, "#6f767e")
	v_g = 0.0
	while J.lt(v_g, v_w):
		game.f_px(J.add(v_x, v_g), J.add(v_dy, 1.0), "#59636d")
		v_g = J.add(v_g, 3.0)
	game.f_hl((v_x - 1.0), v_dy, J.add(v_w, 2.0), "#98a1aa")
	return null

