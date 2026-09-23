# Plate draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# food.js:223
func f_pideSerit(p_cx: Variant = null, p_q: Variant = null) -> Variant:
	var v_seg: Variant = null
	var v_rx: Variant = null
	var v_u: Variant = null
	var v_kk: Variant = null
	var v_d: Variant = null
	var v_h: Variant = null
	var v_cx: Variant = p_cx
	var v_q: Variant = p_q
	v_seg = J.add(game.j_PIDE_NEED, 1.0)
	v_rx = 24.0
	v_u = ((float(J.add(v_q, 0.5)) / float(v_seg)) - 0.5)
	v_kk = abs((v_u * 2.0))
	v_d = (game.j_PIDE_DER * sqrt(max(0.1, (1.0 - ((v_kk * v_kk) * 0.8)))))
	v_h = (game.j_PIDE_KAL * J.add(0.78, (0.22 * sqrt(max(0.0, (1.0 - (v_kk * v_kk)))))))
	return {"L": floor(J.add((v_cx - v_rx), (v_q * (float((v_rx * 2.0)) / float(v_seg)))) + 0.5), "R": floor(J.add((v_cx - v_rx), (J.add(v_q, 1.0) * (float((v_rx * 2.0)) / float(v_seg)))) + 0.5), "d": v_d, "h": max(2.0, floor(v_h + 0.5)), "geri": floor(J.add(v_h, (v_d * 2.0)) + 0.5)}
	return null

# food.js:241
func f_pideBicak(p_x: Variant = null, p_agizY: Variant = null) -> Variant:
	var v_bh: Variant = null
	var v_r: Variant = null
	var v_ww: Variant = null
	var v_x0: Variant = null
	var v_x: Variant = p_x
	var v_agizY: Variant = p_agizY
	v_bh = 10.0
	v_r = 0.0
	while J.lt(v_r, v_bh):
		v_ww = J.add(4.0, floor((float((4.0 * v_r)) / float((v_bh - 1.0))) + 0.5))
		v_x0 = J.add(J.add((v_x - v_ww), 2.0), floor((((v_bh - 1.0) - v_r) * 0.18) + 0.5))
		game.f_fr(v_x0, J.add((v_agizY - v_bh), v_r), v_ww, 1.0, "#aab4bd")
		game.f_hl(v_x0, J.add((v_agizY - v_bh), v_r), 2.0, "#dfe6ec")
		game.f_px((J.add(v_x0, v_ww) - 1.0), J.add((v_agizY - v_bh), v_r), "#6d7a86")
		v_r = J.add(v_r, 1.0)
	game.f_hl((v_x - 6.0), (v_agizY - 1.0), 8.0, "#ffffff")
	game.f_px((v_x - 7.0), (v_agizY - 1.0), "#dfe6ec")
	game.f_fr((v_x - 1.0), ((v_agizY - v_bh) - 2.0), 5.0, 2.0, "#8f979f")
	game.f_hl((v_x - 1.0), ((v_agizY - v_bh) - 2.0), 5.0, "#c3ccd3")
	v_r = 0.0
	while J.lt(v_r, 7.0):
		v_x0 = J.add(v_x, floor((v_r * 0.3) + 0.5))
		game.f_fr((v_x0 - 2.0), (((v_agizY - v_bh) - 3.0) - v_r), 6.0, 1.0, "#3a2718")
		game.f_fr((v_x0 - 1.0), (((v_agizY - v_bh) - 3.0) - v_r), 4.0, 1.0, "#7a5230")
		game.f_px((v_x0 - 1.0), (((v_agizY - v_bh) - 3.0) - v_r), "#a5733f")
		v_r = J.add(v_r, 1.0)
	game.f_px(J.add(v_x, 1.0), ((v_agizY - v_bh) - 6.0), "#c9a06a")
	return null

# food.js:266
func f_pideKup(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_hh: Variant = null, p_dd: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_hh: Variant = p_hh
	var v_dd: Variant = p_dd
	game.f_fr(v_x, (v_y - v_hh), v_w, v_hh, "#b8842c")
	game.f_fr(v_x, (v_y - 2.0), v_w, 2.0, "#8a5f2a")
	game.f_fr(v_x, ((v_y - v_hh) - v_dd), v_w, v_dd, "#e8bd72")
	game.f_hl(v_x, ((v_y - v_hh) - v_dd), v_w, "#f6dfa8")
	game.f_vl((J.add(v_x, v_w) - 1.0), J.add((v_y - v_hh), 1.0), (v_hh - 1.0), "#f0dcb0")
	return null

# food.js:274
func f_drawPideBoard(p_cx: Variant = null, p_cy: Variant = null, p_it: Variant = null, p_t: Variant = null, p_sc: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_ch: Variant = null
	var v_seg: Variant = null
	var v_taban: Variant = null
	var v_q: Variant = null
	var v_S: Variant = null
	var v_f: Variant = null
	var v_w: Variant = null
	var v_b: Variant = null
	var v_a: Variant = null
	var v_hs: Variant = null
	var v_kx: Variant = null
	var v_ust: Variant = null
	var v_on: Variant = null
	var v_sol: Variant = null
	var v_sag: Variant = null
	var v_gw: Variant = null
	var v_uc: Variant = null
	var v_cy0: Variant = null
	var v_e: Variant = null
	var v_bs: Variant = null
	var v_S2: Variant = null
	var v_kxp: Variant = null
	var v_lift: Variant = null
	var v_agiz: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_it: Variant = p_it
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	v_sc = (v_sc if J.truth(v_sc) else 1.0)
	J.method(game.j_ctx, "save", [])
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "translate", [v_cx, v_cy])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(v_cx)), (-J.n(v_cy))])
	v_n = min((J.getv(v_it, "n") if J.truth(J.getv(v_it, "n")) else 0.0), game.j_PIDE_NEED)
	v_ch = game.math_utils.f_clamp((J.getv(v_it, "chop") if J.truth(J.getv(v_it, "chop")) else 0.0), 0.0, 1.0)
	v_seg = J.add(game.j_PIDE_NEED, 1.0)
	v_taban = J.add(v_cy, 6.0)
	v_f = 0.0
	while J.lt(v_f, 12.0):
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_px(J.add((v_cx - 28.0), (game.f_hash1((v_f * 3.7)) * 56.0)), J.add(J.add(v_taban, 1.0), (game.f_hash1((v_f * 5.1)) * 4.0)), "#f4ead2")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_f = J.add(v_f, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_ell(v_cx, J.add(v_taban, 1.0), 25.0, 3.0, "#3a2a18")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi
	if not game.f_hdPideDilimler(v_cx, v_cy, v_n):
		v_q = 0.0
		while J.lt(v_q, v_seg):
			v_S = game.plate_draw.f_pideSerit(v_cx, v_q)
			v_w = (J.getv(v_S, "R") - J.getv(v_S, "L"))
			if J.lt(v_q, v_n):
				v_b = 1.0
				while J.ge(v_b, 0.0):
					v_a = 0.0
					while J.lt(v_a, 3.0):
						v_hs = game.f_hash1(J.add(J.add((v_q * 13.7), (v_a * 3.1)), (v_b * 7.7)))
						v_kx = J.add(J.add(J.add(J.getv(v_S, "L"), 1.0), (v_a * 3.0)), (1.0 if J.truth(v_b) else 0.0))
						if J.gt(J.add(v_kx, 3.0), J.getv(v_S, "R")):
							v_a = J.add(v_a, 1.0)
							continue
						game.plate_draw.f_pideKup(v_kx, ((v_taban - (v_b * 4.0)) - floor((v_hs * 1.4) + 0.5)), 3.0, 3.0, 2.0)
						v_a = J.add(v_a, 1.0)
					v_b = (v_b - 1.0)
				v_q = J.add(v_q, 1.0)
				continue
			v_ust = (v_taban - J.getv(v_S, "geri"))
			v_on = (v_taban - J.getv(v_S, "h"))
			v_sol = J.add(J.getv(v_S, "L"), (1.0 if J.eq(v_q, 0.0) else 0.0))
			v_sag = (J.getv(v_S, "R") - (1.0 if J.eq(v_q, (v_seg - 1.0)) else 0.0))
			v_gw = (v_sag - v_sol)
			game.f_fr(v_sol, v_on, v_gw, J.getv(v_S, "h"), "#a8762e")
			game.f_fr(v_sol, (v_taban - 2.0), v_gw, 2.0, "#7a4f22")
			game.f_hl(v_sol, (v_taban - 1.0), v_gw, "#5e3a12")
			if J.eq(v_q, 0.0):
				game.f_vl(J.getv(v_S, "L"), J.add(v_on, 1.0), (J.getv(v_S, "h") - 2.0), "#8a5f2a")
			if J.eq(v_q, (v_seg - 1.0)):
				game.f_vl((J.getv(v_S, "R") - 1.0), J.add(v_on, 1.0), (J.getv(v_S, "h") - 2.0), "#8a5f2a")
			v_uc = (1.0 if (J.eq(v_q, 0.0) or J.eq(v_q, (v_seg - 1.0))) else 0.0)
			game.f_fr(J.add(v_sol, (v_uc if J.eq(v_q, 0.0) else 0.0)), v_ust, (v_gw - v_uc), (v_on - v_ust), "#dcae55")
			game.f_hl(J.add(v_sol, (v_uc if J.eq(v_q, 0.0) else 0.0)), v_ust, (v_gw - v_uc), "#f0cd94")
			game.f_hl(v_sol, (v_on - 1.0), v_gw, "#c98f3c")
			v_cy0 = J.add(v_ust, 2.0)
			v_e = 0.0
			while J.lt(v_e, 3.0):
				if J.lt(J.add(v_cy0, v_e), (v_on - 1.0)):
					game.f_px(J.add(J.add(J.getv(v_S, "L"), 3.0), v_e), J.add(v_cy0, v_e), "#a8762e")
				v_e = J.add(v_e, 1.0)
			v_bs = game.f_hash1((v_q * 5.3))
			game.f_fr(J.add(J.add(J.getv(v_S, "L"), 2.0), floor((v_bs * (v_w - 6.0)) + 0.5)), J.add(v_ust, 1.0), 2.0, 1.0, "#b8842c")
			game.f_px(J.add(J.add(J.getv(v_S, "L"), 1.0), floor((game.f_hash1((v_q * 9.1)) * (v_w - 3.0)) + 0.5)), (v_on - 3.0), "#fce7bd")
			if (J.eq(v_q, v_n) and J.gt(v_n, 0.0)):
				game.f_vl(J.getv(v_S, "L"), J.add(v_on, 1.0), (J.getv(v_S, "h") - 2.0), "#f4e6c2")
			v_q = J.add(v_q, 1.0)
	if J.lt(v_n, game.j_PIDE_NEED):
		v_S = game.plate_draw.f_pideSerit(v_cx, v_n)
		v_S2 = game.plate_draw.f_pideSerit(v_cx, min(J.add(v_n, 1.0), (v_seg - 1.0)))
		v_kxp = J.getv(v_S, "R")
		v_lift = floor((8.0 * (1.0 - pow(v_ch, 0.55))) + 0.5)
		v_agiz = (J.add((v_taban - max(J.getv(v_S, "geri"), J.getv(v_S2, "geri"))), 1.0) - v_lift)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (0.16 * v_ch)))
		game.f_fr((v_kxp - 4.0), J.add(v_taban, 1.0), (8.0 - floor((v_lift * 0.25) + 0.5)), 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if not game.f_hdPideBicak(v_kxp, v_agiz): game.plate_draw.f_pideBicak(v_kxp, v_agiz)
		if J.gt(v_ch, 0.55):
			J.setv(game.j_ctx, "globalAlpha", ((v_ch - 0.55) * 1.4))
			game.f_hl((v_kxp - 8.0), (v_agiz - 1.0), 4.0, "#ffffff")
			game.f_hl(J.add(v_kxp, 2.0), (v_agiz - 1.0), 4.0, "#ffffff")
			game.f_px((v_kxp - 10.0), (v_agiz - 3.0), "#fff6dc")
			game.f_px(J.add(v_kxp, 6.0), (v_agiz - 4.0), "#fff6dc")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	return null

# food.js:371
func f_drawPlate(p_cx: Variant = null, p_cy: Variant = null, p_pl: Variant = null, p_t: Variant = null, p_sc: Variant = null) -> Variant:
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_amt: Variant = null
	var v_kat: Variant = null
	var v_kn: Variant = null
	var v_kry: Variant = null
	var v_kgen: Variant = null
	var v_i: Variant = null
	var v_a: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_mc: Variant = null
	var v_m: Variant = null
	var v_ma: Variant = null
	var v_mrr: Variant = null
	var v_mx0: Variant = null
	var v_my0: Variant = null
	var v_b: Variant = null
	var v_bx0: Variant = null
	var v_by0: Variant = null
	var v_b2: Variant = null
	var v_dx0: Variant = null
	var v_ti: Variant = null
	var v_pi2: Variant = null
	var v_yx: Variant = null
	var v_yy: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_pl: Variant = p_pl
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	v_sc = (v_sc if J.truth(v_sc) else 1.0)
	J.method(game.j_ctx, "save", [])
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "translate", [v_cx, v_cy])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(v_cx)), (-J.n(v_cy))])
	v_rx = 20.0
	v_ry = 8.0
	v_amt = 1.0
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_ell(v_cx, J.add(J.add(v_cy, v_ry), 1.0), v_rx, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi
	if not game.f_hdTabak(v_cx, v_cy):
		game.f_ell(v_cx, J.add(v_cy, 2.0), v_rx, v_ry, "#aeb6bd")
		game.f_ell(v_cx, J.add(v_cy, 1.0), v_rx, v_ry, "#e9eef2")
		game.f_ell(v_cx, v_cy, (v_rx - 1.0), (v_ry - 1.0), "#fbfdfe")
		game.f_ell(v_cx, J.add(v_cy, 1.0), (v_rx - 4.0), (v_ry - 2.0), "#d6dee4")
		game.f_ell(v_cx, v_cy, (v_rx - 4.0), (v_ry - 2.0), "#f2f6f9")
		J.setv(game.j_ctx, "globalAlpha", 0.5)
		game.f_ell(v_cx, (v_cy - 1.0), (v_rx - 2.0), (v_ry - 1.0), "#8fb4d8")
		game.f_ell(v_cx, (v_cy - 1.0), (v_rx - 3.0), (v_ry - 2.0), "#f2f6f9")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(J.getv(v_pl, "pide")):
		v_kat = 0.0
		while J.lt(v_kat, 3.0):
			v_kn = J.getv([9.0, 6.0, 3.0], v_kat)
			v_kry = J.getv([0.0, (-J.n(2.0)), (-J.n(4.0))], v_kat)
			v_kgen = J.getv([1.0, 0.66, 0.36], v_kat)
			v_i = 0.0
			while J.lt(v_i, v_kn):
				v_a = J.add(((float(v_i) / float(v_kn)) * game.j_TAU), (v_kat * 1.1))
				v_px0 = J.add(v_cx, ((cos(v_a) * (v_rx - 7.0)) * v_kgen))
				v_py0 = J.add(J.add((v_cy - 1.0), v_kry), ((sin(v_a) * (v_ry - 3.0)) * v_kgen))
				game.f_fr((v_px0 - 2.0), (v_py0 - 1.0), 4.0, 4.0, "#7a5228")
				game.f_fr((v_px0 - 2.0), (v_py0 - 1.0), 4.0, 3.0, ("#e0b478" if J.truth(v_kat) else "#d9a765"))
				game.f_px((v_px0 - 1.0), (v_py0 - 1.0), ("#fce7bd" if J.truth(v_kat) else "#f0cd94"))
				v_i = J.add(v_i, 1.0)
			v_kat = J.add(v_kat, 1.0)
	if J.gt(J.getv(v_pl, "meat"), 0.0):
		v_mc = max(0.0, floor(((min(J.getv(v_pl, "meat"), 6.0) * 1.6) * v_amt) + 0.5))
		v_m = 0.0
		while J.lt(v_m, v_mc):
			v_ma = J.add(((float(v_m) / float(max(1.0, v_mc))) * game.j_TAU), 0.7)
			v_mrr = J.add(0.22, (fmod(J.n(v_m), J.n(3.0)) * 0.26))
			v_mx0 = J.add(v_cx, ((cos(v_ma) * (v_rx - 8.0)) * v_mrr))
			v_my0 = J.add((v_cy - 5.0), ((sin(v_ma) * (v_ry - 4.0)) * v_mrr))
			game.f_fr((v_mx0 - 4.0), v_my0, 8.0, 4.0, "#7a4318")
			game.f_fr((v_mx0 - 4.0), v_my0, 8.0, 3.0, "#c98436")
			game.f_hl((v_mx0 - 3.0), v_my0, 6.0, "#eeb464")
			game.f_px(J.add(v_mx0, 3.0), J.add(v_my0, 2.0), "#9a5a20")
			v_m = J.add(v_m, 1.0)
	if J.truth(J.getv(v_pl, "butter")):
		J.setv(game.j_ctx, "globalAlpha", J.add((0.78 * v_amt), 0.22))
		v_b = 0.0
		while J.lt(v_b, 22.0):
			v_bx0 = J.add((v_cx - 14.0), (v_b * 1.35))
			v_by0 = J.add((v_cy - 7.0), (sin((v_b * 0.9)) * 2.4))
			game.f_fr(v_bx0, v_by0, 2.0, 3.0, "#a83a12")
			game.f_fr(v_bx0, v_by0, 2.0, 2.0, "#e2621c")
			if J.eq(fmod(J.n(v_b), J.n(4.0)), 0.0):
				game.f_px(v_bx0, v_by0, "#ffb45a")
			v_b = J.add(v_b, 1.0)
		v_b2 = 0.0
		while J.lt(v_b2, 4.0):
			v_dx0 = J.add((v_cx - 10.0), (v_b2 * 7.0))
			game.f_fr(v_dx0, J.add((v_cy - 2.0), fmod(J.n(v_b2), J.n(2.0))), 2.0, 3.0, "#c04a14")
			game.f_px(v_dx0, J.add((v_cy - 2.0), fmod(J.n(v_b2), J.n(2.0))), "#f07a2a")
			v_b2 = J.add(v_b2, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.truth(game.f_chance(0.1)):
			game.effects.f_part({"x": J.add(v_cx, game.math_utils.f_rnd((-J.n(10.0)), 10.0)), "y": (v_cy - 6.0), "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(16.0)), (-J.n(8.0))), "life": 0.6, "col": "rgba(255,220,180,.5)", "g": (-J.n(8.0)), "sz": 1.0})
	if J.truth(J.getv(v_pl, "tomato")):
		v_ti = 0.0
		while J.lt(v_ti, min(3.0, J.getv(v_pl, "tomato"))):
			game.garnish_draw.f_drawTomatoSlice(J.add((v_cx - 12.0), (v_ti * 7.0)), (J.add(v_cy, v_ry) - 5.0), 5.0)
			v_ti = J.add(v_ti, 1.0)
	if J.truth(J.getv(v_pl, "pepper")):
		v_pi2 = 0.0
		while J.lt(v_pi2, min(2.0, J.getv(v_pl, "pepper"))):
			game.garnish_draw.f_drawPepper(J.add(J.add(v_cx, 7.0), (v_pi2 * 7.0)), (v_cy - 1.0), 12.0, (1.0 if J.truth(v_pi2) else (-J.n(1.0))))
			v_pi2 = J.add(v_pi2, 1.0)
	if J.truth(J.getv(v_pl, "yogurt")):
		v_yx = J.add(v_cx, 11.0)
		v_yy = J.add(v_cy, 1.0)
		game.f_ell(v_yx, J.add(v_yy, 1.0), J.add((6.0 * v_amt), 1.0), J.add((3.2 * v_amt), 0.6), "#cfc9b4")
		game.f_ell(v_yx, v_yy, J.add((6.0 * v_amt), 1.0), J.add((3.2 * v_amt), 0.6), J.getv(game.j_P, "s0"))
		game.f_ell((v_yx - 1.0), (v_yy - 1.0), J.add((3.4 * v_amt), 0.5), J.add((1.6 * v_amt), 0.4), "#ffffff")
	J.method(game.j_ctx, "restore", [])
	return null

