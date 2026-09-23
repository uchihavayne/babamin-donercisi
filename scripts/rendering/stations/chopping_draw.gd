# Chopping draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:3703
func f_slashCiz(p_x0: Variant = null, p_y0: Variant = null, p_dx: Variant = null, p_dy: Variant = null, p_boy: Variant = null, p_kalinlik: Variant = null, p_renk: Variant = null, p_alfa: Variant = null) -> Variant:
	var v_nx: Variant = null
	var v_ny: Variant = null
	var v_adim: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_k: Variant = null
	var v_kal: Variant = null
	var v_cx0: Variant = null
	var v_cy0: Variant = null
	var v_yar: Variant = null
	var v_o: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	var v_dx: Variant = p_dx
	var v_dy: Variant = p_dy
	var v_boy: Variant = p_boy
	var v_kalinlik: Variant = p_kalinlik
	var v_renk: Variant = p_renk
	var v_alfa: Variant = p_alfa
	v_nx = (-J.n(v_dy))
	v_ny = v_dx
	J.setv(game.j_ctx, "globalAlpha", v_alfa)
	v_adim = max(1.0, floor(v_boy + 0.5))
	v_q = 0.0
	while J.le(v_q, v_adim):
		v_u = (float(v_q) / float(v_adim))
		v_k = sin((v_u * J.getv({"PI": PI}, "PI")))
		v_kal = (v_k * v_kalinlik)
		if J.lt(v_kal, 0.35):
			v_q = J.add(v_q, 1.0)
			continue
		v_cx0 = J.add(v_x0, (v_dx * v_q))
		v_cy0 = J.add(v_y0, (v_dy * v_q))
		v_yar = max(0.0, floor(v_kal + 0.5))
		v_o = (-J.n(v_yar))
		while J.le(v_o, v_yar):
			game.f_px(floor(J.add(v_cx0, (v_nx * v_o)) + 0.5), floor(J.add(v_cy0, (v_ny * v_o)) + 0.5), v_renk)
			v_o = J.add(v_o, 1.0)
		v_q = J.add(v_q, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:3723
func f_drawSlash(p_C: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_s0: Variant = null
	var v_k: Variant = null
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_boy: Variant = null
	var v_x0: Variant = null
	var v_y0: Variant = null
	var v_a2: Variant = null
	var v_C: Variant = p_C
	if ((not J.truth(J.getv(v_C, "slash"))) or (not J.truth(J.getv(J.getv(v_C, "slash"), "length")))):
		return null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_C, "slash"), "length")):
		v_s0 = J.getv(J.getv(v_C, "slash"), v_i)
		v_k = game.math_utils.f_clamp(J.getv(v_s0, "t"), 0.0, 1.0)
		if J.le(v_k, 0.0):
			v_i = J.add(v_i, 1.0)
			continue
		v_dx = cos(J.getv(v_s0, "aci"))
		v_dy = sin(J.getv(v_s0, "aci"))
		v_boy = (J.getv(v_s0, "boy") * J.add(0.62, (0.38 * v_k)))
		v_x0 = (J.getv(v_s0, "x") - ((v_dx * v_boy) * 0.5))
		v_y0 = (J.getv(v_s0, "y") - ((v_dy * v_boy) * 0.5))
		game.chopping_draw.f_slashCiz(v_x0, v_y0, v_dx, v_dy, v_boy, (2.1 * v_k), "#ffe9a3", (0.1 * v_k))
		game.chopping_draw.f_slashCiz(v_x0, v_y0, v_dx, v_dy, v_boy, (1.15 * v_k), "#ffd27a", (0.4 * v_k))
		game.chopping_draw.f_slashCiz(v_x0, v_y0, v_dx, v_dy, v_boy, (0.55 * v_k), "#ffffff", (0.95 * v_k))
		if J.gt(v_k, 0.7):
			v_a2 = (float((v_k - 0.7)) / float(0.3))
			J.setv(game.j_ctx, "globalAlpha", (v_a2 * 0.9))
			game.f_px(floor(J.getv(v_s0, "x") + 0.5), floor(J.getv(v_s0, "y") + 0.5), "#ffffff")
			game.f_px(floor(J.add(J.getv(v_s0, "x"), (v_dx * 2.0)) + 0.5), floor(J.add(J.getv(v_s0, "y"), (v_dy * 2.0)) + 0.5), "#fff0c4")
			game.f_px(floor((J.getv(v_s0, "x") - (v_dx * 2.0)) + 0.5), floor((J.getv(v_s0, "y") - (v_dy * 2.0)) + 0.5), "#fff0c4")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# art.js:3753
func f_drawCutBoard(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_C: Variant = null, p_t: Variant = null) -> Variant:
	var v_g: Variant = null
	var v_s: Variant = null
	var v_cx: Variant = null
	var v_k: Variant = null
	var v_pw: Variant = null
	var v_slices: Variant = null
	var v_i: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_raw: Variant = null
	var v_r: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_C: Variant = p_C
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_rrect(J.add(v_x, 3.0), J.add(v_y, 8.0), (v_w - 4.0), (v_h - 12.0), 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(J.add(v_x, 2.0), J.add(v_y, 6.0), (v_w - 4.0), (v_h - 12.0), 3.0, "#7a5230")
	game.f_rrect(J.add(v_x, 2.0), J.add(v_y, 5.0), (v_w - 4.0), (v_h - 12.0), 3.0, "#c49a68")
	game.f_rrect(J.add(v_x, 4.0), J.add(v_y, 7.0), (v_w - 8.0), (v_h - 16.0), 2.0, "#dcb480")
	v_g = 0.0
	while J.lt(v_g, 5.0):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_hl(J.add(v_x, 5.0), J.add(J.add(v_y, 9.0), (v_g * 5.0)), (v_w - 10.0), "#c09660")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_g = J.add(v_g, 1.0)
	game.f_hl(J.add(v_x, 4.0), J.add(v_y, 6.0), (v_w - 8.0), "#eccb96")
	v_s = 0.0
	while J.lt(v_s, 6.0):
		J.setv(game.j_ctx, "globalAlpha", 0.25)
		game.f_ln(J.add(J.add(v_x, 8.0), (v_s * 6.0)), J.add(v_y, 12.0), J.add(J.add(v_x, 10.0), (v_s * 6.0)), J.add(v_y, 20.0), "#8a6a42")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_s = J.add(v_s, 1.0)
	v_cx = (J.add(v_x, (float(v_w) / float(2.0))) - 6.0)
	if J.truth(J.getv(v_C, "potato")):
		v_k = (1.0 - J.getv(v_C, "prog"))
		v_pw = max(2.0, floor((11.0 * v_k) + 0.5))
		game.f_ell(v_cx, J.add(v_y, 20.0), v_pw, 6.0, "#8a6432")
		game.f_ell(v_cx, J.add(v_y, 19.0), v_pw, 6.0, "#b98b46")
		game.f_ell((v_cx - 2.0), J.add(v_y, 17.0), max(1.0, (v_pw - 3.0)), 2.0, "#d8ab63")
		game.f_px(J.add(v_cx, 2.0), J.add(v_y, 18.0), "#6d4d24")
		v_slices = floor((J.getv(v_C, "prog") * 6.0))
		v_i = 0.0
		while J.lt(v_i, v_slices):
			game.f_fr(J.add(J.add(v_cx, 8.0), (v_i * 3.0)), J.add(v_y, 16.0), 2.0, 8.0, J.getv(game.j_P, "p4"))
			game.f_fr(J.add(J.add(v_cx, 8.0), (v_i * 3.0)), J.add(v_y, 16.0), 2.0, 7.0, "#f2e0a8")
			game.f_px(J.add(J.add(v_cx, 8.0), (v_i * 3.0)), J.add(v_y, 16.0), "#fff6d0")
			v_i = J.add(v_i, 1.0)
		game.chopping_draw.f_drawSlash(v_C)
		if (J.gt(J.getv(v_C, "prog"), 0.0) and J.lt(J.getv(v_C, "prog"), 1.0)):
			game.counter_draw.f_bar(J.add(v_x, 6.0), (v_y - 4.0), (v_w - 12.0), 5.0, J.getv(v_C, "prog"), J.getv(game.j_P, "p1"))
	else:
		game.text_draw.f_txt("PATATES", J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 20.0), "rgba(60,40,24,.45)", {"align": "c"})
	v_bx = (J.add(v_x, v_w) - 17.0)
	v_by = (J.add(v_y, v_h) - 22.0)
	game.f_fr(v_bx, v_by, 15.0, 14.0, "#8a929b")
	game.f_fr(J.add(v_bx, 1.0), J.add(v_by, 1.0), 13.0, 12.0, "#b6bec6")
	game.f_fr(J.add(v_bx, 1.0), J.add(v_by, 1.0), 13.0, 3.0, "#d6dee6")
	v_raw = min(10.0, J.getv(v_C, "raw"))
	v_r = 0.0
	while J.lt(v_r, v_raw):
		v_rx = J.add(J.add(v_bx, 2.0), (fmod(J.n(v_r), J.n(5.0)) * 2.4))
		v_ry = (J.add(v_by, 9.0) - (floor((float(v_r) / float(5.0))) * 4.0))
		game.f_fr(v_rx, v_ry, 2.0, 5.0, "#e8d59a")
		game.f_px(v_rx, v_ry, "#f8ecc0")
		v_r = J.add(v_r, 1.0)
	if J.gt(J.getv(v_C, "raw"), 0.0):
		game.text_draw.f_txt(J.add("", J.getv(v_C, "raw")), J.add(v_bx, 14.0), (v_by - 8.0), "#f8ecc0", {"align": "r", "outline": "rgba(0,0,0,.5)"})
	return null

