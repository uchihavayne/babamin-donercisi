# Garnish draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:4295
func f_drawBaklava(p_cx: Variant = null, p_cy: Variant = null) -> Variant:
	var v_GEN: Variant = null
	var v_r: Variant = null
	var v_hw: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_cx, J.add(v_cy, 9.0), 6.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_cx - 5.0), J.add(v_cy, 4.0), 10.0, 3.0, "#8a5a1a")
	game.f_hl((v_cx - 5.0), J.add(v_cy, 5.0), 10.0, "#a8762a")
	game.f_vl((v_cx - 6.0), J.add(v_cy, 4.0), 3.0, "#6b4212")
	game.f_vl(J.add(v_cx, 5.0), J.add(v_cy, 4.0), 3.0, "#6b4212")
	game.f_hl((v_cx - 5.0), J.add(v_cy, 6.0), 10.0, "#6b4212")
	v_GEN = [2.0, 4.0, 6.0, 4.0, 2.0]
	v_r = 0.0
	while J.lt(v_r, 5.0):
		v_hw = J.getv(v_GEN, v_r)
		game.f_fr((v_cx - v_hw), J.add(v_cy, v_r), (v_hw * 2.0), 1.0, ("#e8bd62" if J.lt(v_r, 2.0) else "#cf9c47"))
		v_r = J.add(v_r, 1.0)
	game.f_hl((v_cx - 2.0), v_cy, 4.0, "#ffdf9a")
	game.f_px((v_cx - 6.0), J.add(v_cy, 2.0), "#8a5a1a")
	game.f_px(J.add(v_cx, 5.0), J.add(v_cy, 2.0), "#8a5a1a")
	game.f_px((v_cx - 1.0), J.add(v_cy, 2.0), "#6b9440")
	game.f_px(J.add(v_cx, 1.0), J.add(v_cy, 2.0), "#47692c")
	game.f_px(v_cx, J.add(v_cy, 1.0), "#93bd63")
	return null

# art.js:4322
func f_drawSweetTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	var v_bump: Variant = null
	var v_cnt: Variant = null
	var v_i: Variant = null
	var v_col: Variant = null
	var v_row: Variant = null
	var v_cx: Variant = null
	var v_cy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_n: Variant = p_n
	var v_max: Variant = p_max
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 8.0), (v_w - 2.0), (v_h - 14.0), "#dff0f4")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, (J.add(v_y, v_h) - 8.0), v_w, 6.0, "#8a929b")
	game.f_fr(J.add(v_x, 1.0), (J.add(v_y, v_h) - 8.0), (v_w - 2.0), 5.0, "#c6ccd2")
	game.f_rc(v_x, J.add(v_y, 6.0), v_w, (v_h - 12.0), "#7fa5ad")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 7.0), (v_w - 2.0), "#e8f6fa")
	game.f_fr(J.add(v_x, 2.0), (J.add(v_y, v_h) - 14.0), (v_w - 4.0), 5.0, "#8a5a2a")
	game.f_fr(J.add(v_x, 2.0), (J.add(v_y, v_h) - 14.0), (v_w - 4.0), 4.0, "#c08a3a")
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	v_cnt = min(4.0, ceil((game.math_utils.f_clamp((float(v_n) / float(max(1.0, v_max))), 0.0, 1.0) * 4.0)))
	v_i = 0.0
	while J.lt(v_i, v_cnt):
		v_col = fmod(J.n(v_i), J.n(2.0))
		v_row = (int(J.n((float(v_i) / float(2.0)))) | int(J.n(0.0)))
		v_cx = J.add(J.add(v_x, 10.0), (v_col * 14.0))
		v_cy = (((J.add(v_y, v_h) - 22.0) - (v_row * 8.0)) - v_bump)
		game.garnish_draw.f_drawBaklava(v_cx, v_cy)
		v_i = J.add(v_i, 1.0)
	game.text_draw.f_txt("TATLI", J.add(v_x, (float(v_w) / float(2.0))), (J.add(v_y, v_h) - 7.0), J.getv(game.j_P, "au1"), {"align": "c", "outline": "rgba(0,0,0,.6)"})
	return null

# art.js:4741
func f_drawPepper(p_x: Variant = null, p_y: Variant = null, p_h: Variant = null, p_flip: Variant = null) -> Variant:
	var v_wMax: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_w: Variant = null
	var v_iw: Variant = null
	var v_bend: Variant = null
	var v_yy: Variant = null
	var v_cx2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_h: Variant = p_h
	var v_flip: Variant = p_flip
	v_h = (v_h if J.truth(v_h) else 13.0)
	v_flip = (v_flip if J.truth(v_flip) else 1.0)
	v_wMax = max(2.0, floor((v_h * 0.26) + 0.5))
	J.setv(game.j_ctx, "globalAlpha", 0.26)
	game.f_ell(v_x, J.add(v_y, 1.0), J.add(v_wMax, 1.0), 2.0, "#1c2f08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_q = 0.0
	while J.lt(v_q, v_h):
		v_u = (float(v_q) / float((v_h - 1.0)))
		if J.lt(v_u, 0.22):
			v_w = (v_wMax * J.add(0.62, ((float(v_u) / float(0.22)) * 0.38)))
		else:
			v_w = (v_wMax * pow((1.0 - (float((v_u - 0.22)) / float(0.78))), 0.62))
		v_iw = floor(max(0.0, v_w) + 0.5)
		if (J.lt(v_iw, 1.0) and J.gt(v_u, 0.9)):
			break
		v_iw = max(1.0, v_iw)
		v_bend = floor(((sin((v_u * 1.45)) * 2.0) * v_flip) + 0.5)
		v_yy = J.add(J.add((v_y - v_h), v_q), 1.0)
		v_cx2 = J.add(v_x, v_bend)
		game.f_fr((v_cx2 - v_iw), v_yy, J.add((v_iw * 2.0), 1.0), 1.0, "#2c4a10")
		game.f_fr((v_cx2 - v_iw), v_yy, (v_iw * 2.0), 1.0, "#48731a")
		if J.gt(v_iw, 1.0):
			game.f_fr((v_cx2 - v_iw), v_yy, v_iw, 1.0, "#6d9c28")
		if ((J.gt(v_iw, 1.0) and J.gt(v_u, 0.1)) and J.lt(v_u, 0.78)):
			game.f_px(J.add((v_cx2 - v_iw), 1.0), v_yy, "#a4cc4a")
		if ((J.gt(v_iw, 2.0) and J.gt(v_u, 0.18)) and J.lt(v_u, 0.62)):
			game.f_px(J.add((v_cx2 - v_iw), 2.0), v_yy, "#d8ee8a")
		if (J.gt(v_iw, 2.0) and J.eq(fmod(J.n(v_q), J.n(3.0)), 1.0)):
			game.f_px((J.add(v_cx2, v_iw) - 2.0), v_yy, "#356312")
		v_q = J.add(v_q, 1.0)
	game.f_fr((v_x - 3.0), J.add((v_y - v_h), 1.0), 7.0, 2.0, "#3d5219")
	game.f_fr((v_x - 3.0), J.add((v_y - v_h), 1.0), 6.0, 1.0, "#5b7726")
	game.f_px((v_x - 4.0), J.add((v_y - v_h), 2.0), "#2c5210")
	game.f_px(J.add(v_x, 4.0), J.add((v_y - v_h), 2.0), "#2c5210")
	game.f_fr((v_x - 1.0), ((v_y - v_h) - 3.0), 3.0, 4.0, "#3d5219")
	game.f_fr((v_x - 1.0), ((v_y - v_h) - 3.0), 2.0, 3.0, "#5b7726")
	game.f_px(v_x, ((v_y - v_h) - 4.0), "#7fa138")
	return null

# art.js:4778
func f_drawTomatoSlice(p_x: Variant = null, p_y: Variant = null, p_r: Variant = null) -> Variant:
	var v_ry2: Variant = null
	var v_i: Variant = null
	var v_a: Variant = null
	var v_ex: Variant = null
	var v_ey: Variant = null
	var v_s: Variant = null
	var v_sa: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_r: Variant = p_r
	v_r = max(4.0, (v_r if J.truth(v_r) else 6.0))
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_ry2 = max(3.0, (v_r - 1.0))
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_x, J.add(v_y, 2.0), v_r, 2.0, "#4a1008")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_x, J.add(v_y, 1.0), v_r, v_ry2, "#8e2018")
	game.f_ell(v_x, v_y, v_r, v_ry2, "#b8302a")
	game.f_ell(v_x, v_y, (v_r - 1.0), (v_ry2 - 1.0), "#d8443a")
	game.f_ell(v_x, v_y, (v_r - 2.0), max(1.0, (v_ry2 - 2.0)), "#e2564a")
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_a = J.add((float((-J.n(J.getv({"PI": PI}, "PI")))) / float(2.0)), (v_i * (float((J.getv({"PI": PI}, "PI") * 2.0)) / float(3.0))))
		v_ex = J.add(v_x, (cos(v_a) * (v_r - 2.2)))
		v_ey = J.add(v_y, (sin(v_a) * (v_ry2 - 1.6)))
		game.f_ln(v_x, v_y, floor(v_ex + 0.5), floor(v_ey + 0.5), "#ffc0a8")
		game.f_ln(J.add(v_x, (0.0 if J.gt(abs(cos(v_a)), 0.5) else 1.0)), J.add(v_y, (1.0 if J.gt(abs(cos(v_a)), 0.5) else 0.0)), floor(v_ex + 0.5), floor(v_ey + 0.5), "#f5a894")
		v_i = J.add(v_i, 1.0)
	game.f_px(v_x, v_y, "#ffd2b8")
	v_s = 0.0
	while J.lt(v_s, 3.0):
		v_sa = J.add(J.add((float((-J.n(J.getv({"PI": PI}, "PI")))) / float(2.0)), (v_s * (float((J.getv({"PI": PI}, "PI") * 2.0)) / float(3.0)))), (float(J.getv({"PI": PI}, "PI")) / float(3.0)))
		game.f_px(floor(J.add(v_x, (cos(v_sa) * (v_r - 2.4))) + 0.5), floor(J.add(v_y, (sin(v_sa) * (v_ry2 - 1.6))) + 0.5), "#f7e6b0")
		v_s = J.add(v_s, 1.0)
	game.f_px((v_x - 1.0), J.add((v_y - v_ry2), 1.0), "#f2887a")
	return null

# art.js:4807
func f_drawGarnishTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_tn: Variant = null, p_pn: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	var v_bump: Variant = null
	var v_midX: Variant = null
	var v_tl: Variant = null
	var v_rows: Variant = null
	var v_rI: Variant = null
	var v_ry2: Variant = null
	var v_c: Variant = null
	var v_cx2: Variant = null
	var v_pl2: Variant = null
	var v_pc: Variant = null
	var v_pI: Variant = null
	var v_col: Variant = null
	var v_row: Variant = null
	var v_bx2: Variant = null
	var v_by2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_tn: Variant = p_tn
	var v_pn: Variant = p_pn
	var v_max: Variant = p_max
	var v_t: Variant = p_t
	var v_fx: Variant = p_fx
	v_fx = (v_fx if J.truth(v_fx) else 0.0)
	game.f_trayBase(v_x, v_y, v_w, v_h)
	v_bump = floor((sin((v_fx * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5)
	v_midX = J.add(v_x, floor((v_w * 0.52) + 0.5))
	game.f_fr((v_midX - 1.0), J.add(v_y, 4.0), 2.0, (v_h - 10.0), "#8a929b")
	game.f_vl((v_midX - 1.0), J.add(v_y, 4.0), (v_h - 10.0), "#c7ced5")
	v_tl = game.math_utils.f_clamp((float(v_tn) / float(max(1.0, v_max))), 0.0, 1.0)
	if J.gt(v_tn, 0.0):
		v_rows = max(1.0, floor(J.add(1.0, (v_tl * 2.2)) + 0.5))
		v_rI = (v_rows - 1.0)
		while J.ge(v_rI, 0.0):
			v_ry2 = (((J.add(v_y, v_h) - 10.0) - (v_rI * 4.0)) - v_bump)
			v_c = 0.0
			while J.lt(v_c, 3.0):
				v_cx2 = J.add(J.add(J.add(v_x, 8.0), (v_c * 6.0)), (fmod(J.n(v_rI), J.n(2.0)) * 2.0))
				if J.gt(v_cx2, (v_midX - 7.0)):
					v_c = J.add(v_c, 1.0)
					continue
				game.garnish_draw.f_drawTomatoSlice(v_cx2, v_ry2, 6.0)
				v_c = J.add(v_c, 1.0)
			v_rI = (v_rI - 1.0)
		if J.truth(game.f_chance(0.04)):
			game.effects.f_part({"x": J.add(J.add(v_x, 6.0), game.math_utils.f_rnd(0.0, 12.0)), "y": (J.add(v_y, v_h) - 11.0), "vx": 0.0, "vy": 10.0, "life": 0.3, "col": "#e2483a", "g": 60.0, "sz": 1.0, "floor": (J.add(v_y, v_h) - 8.0)})
	else:
		pass
	v_pl2 = game.math_utils.f_clamp((float(v_pn) / float(max(1.0, v_max))), 0.0, 1.0)
	if J.gt(v_pn, 0.0):
		v_pc = max(1.0, floor(J.add(1.0, (v_pl2 * 3.2)) + 0.5))
		v_pI = (v_pc - 1.0)
		while J.ge(v_pI, 0.0):
			v_col = fmod(J.n(v_pI), J.n(2.0))
			v_row = (int(J.n((float(v_pI) / float(2.0)))) | int(J.n(0.0)))
			v_bx2 = J.add(J.add(v_midX, 5.0), (v_col * 7.0))
			v_by2 = (((J.add(v_y, v_h) - 8.0) - (v_row * 3.0)) - v_bump)
			if J.gt(v_bx2, (J.add(v_x, v_w) - 4.0)):
				v_pI = (v_pI - 1.0)
				continue
			game.garnish_draw.f_drawPepper(v_bx2, v_by2, J.add(12.0, fmod(J.n(v_pI), J.n(3.0))), (1.0 if J.truth(v_col) else (-J.n(1.0))))
			v_pI = (v_pI - 1.0)
	else:
		pass
	game.f_trayInnerShade(v_x, v_y, v_w, v_h)
	game.f_trayFlash(v_x, v_y, v_w, v_h, v_fx)
	return null

