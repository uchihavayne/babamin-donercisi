# Wrap draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# food.js:10
func f_drawWrapOpen(p_cx: Variant = null, p_cy: Variant = null, p_wrap: Variant = null, p_t: Variant = null, p_sc: Variant = null) -> Variant:
	var v_roll: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_frontY: Variant = null
	var v_tubeH: Variant = null
	var v_topCut: Variant = null
	var v_i: Variant = null
	var v_a: Variant = null
	var v_r0: Variant = null
	var v_mn: Variant = null
	var v_fn: Variant = null
	var v_by: Variant = null
	var v_mOran: Variant = null
	var v_chunks: Variant = null
	var v_mGen: Variant = null
	var v_m: Variant = null
	var v_mu: Variant = null
	var v_mrnd: Variant = null
	var v_mx: Variant = null
	var v_kub: Variant = null
	var v_my: Variant = null
	var v_mw: Variant = null
	var v_fOran: Variant = null
	var v_fc: Variant = null
	var v_fGen: Variant = null
	var v_f: Variant = null
	var v_t0: Variant = null
	var v_fu: Variant = null
	var v_fx: Variant = null
	var v_fy: Variant = null
	var v_fL: Variant = null
	var v_aci: Variant = null
	var v_tk: Variant = null
	var v_acik: Variant = null
	var v_govde: Variant = null
	var v_kenar: Variant = null
	var v_ustC: Variant = null
	var v_g0: Variant = null
	var v_q0: Variant = null
	var v_qy: Variant = null
	var v_uc: Variant = null
	var v_q1: Variant = null
	var v_pkN: Variant = null
	var v_pOran: Variant = null
	var v_pc: Variant = null
	var v_pGen: Variant = null
	var v_k: Variant = null
	var v_pu: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_ygN: Variant = null
	var v_yOran: Variant = null
	var v_yGen: Variant = null
	var v_yKal: Variant = null
	var v_y0: Variant = null
	var v_z0: Variant = null
	var v_zy0: Variant = null
	var v_z1: Variant = null
	var v_zx1: Variant = null
	var v_zy1: Variant = null
	var v_sc0: Variant = null
	var v_sc1: Variant = null
	var v_z: Variant = null
	var v_zx: Variant = null
	var v_zy: Variant = null
	var v_th: Variant = null
	var v_ty: Variant = null
	var v_tw: Variant = null
	var v_tx: Variant = null
	var v_rr: Variant = null
	var v_scroll: Variant = null
	var v_ri: Variant = null
	var v_sxp: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_wrap: Variant = p_wrap
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	v_sc = (v_sc if J.truth(v_sc) else 1.0)
	v_roll = game.math_utils.f_clamp((J.getv(v_wrap, "roll") if J.truth(J.getv(v_wrap, "roll")) else 0.0), 0.0, 1.0)
	J.method(game.j_ctx, "save", [])
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "translate", [v_cx, v_cy])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(v_cx)), (-J.n(v_cy))])
	v_rx = 22.0
	v_ry = 9.0
	v_frontY = game.math_utils.f_lerp(J.add(J.add(v_cy, v_ry), 2.0), v_cy, v_roll)
	v_tubeH = game.math_utils.f_lerp(3.0, 13.0, v_roll)
	v_topCut = (v_frontY - (float(v_tubeH) / float(2.0)))
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	# BIRLESIK: kirpma sarma animasyonu icin (on kenar tupun altinda kalir).
	# Sarma baslamamisken HD lavasin alt kenarini duz bir cizgiyle kesiyordu
	# (kullanici: "ekmek kesik gibi, yarim gibi"); o durumda HD'de kirpma yok.
	var v_kirpH: float = max(0.0, (v_topCut - (v_cy - 26.0)))
	if J.le(v_roll, 0.0) and game.hd_gpu():
		v_kirpH = 60.0
	J.method(game.j_ctx, "rect", [(v_cx - 34.0), (v_cy - 26.0), 68.0, v_kirpH])
	J.method(game.j_ctx, "clip", [])
	# BIRLESIK: HD'de golge lavasin hemen altina yapisik (temas golgesi). Eski
	# elips lavasin 1-3 px ASAGISINA dusuyordu; kirpma kalkinca tahtanin on
	# kenarindan sarkan bir hilal olarak gorundu, lavas havada duruyordu.
	if game.hd_gpu():
		J.setv(game.j_ctx, "globalAlpha", 0.2)
		game.f_ell(J.add(v_cx, 0.5), J.add(v_cy, 1.0), J.add(v_rx, 0.4), J.add(v_ry, 0.3), "#3a2410")
	else:
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		game.f_ell(v_cx, (J.add(v_cy, v_ry) - 1.0), v_rx, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi
	if not game.f_hdLavasAcik(v_cx, v_cy):
		game.f_ell(v_cx, v_cy, v_rx, v_ry, "#c9a06a")
		game.f_ell(v_cx, (v_cy - 1.0), v_rx, v_ry, "#f0d5a8")
		game.f_ell((v_cx - 2.0), (v_cy - 3.0), (v_rx - 6.0), (v_ry - 4.0), "#f8e6c4")
		v_i = 0.0
		while J.lt(v_i, 16.0):
			v_a = (game.f_hash1((v_i * 3.1)) * game.j_TAU)
			v_r0 = game.f_hash1((v_i * 7.3))
			game.f_px(J.add(v_cx, (((cos(v_a) * v_rx) * v_r0) * 0.9)), J.add((v_cy - 1.0), (((sin(v_a) * v_ry) * v_r0) * 0.9)), ("#c39a63" if J.gt(game.f_hash1(v_i), 0.5) else "#e0bd85"))
			v_i = J.add(v_i, 1.0)
		game.f_ell(v_cx, (J.add(v_cy, v_ry) - 3.0), (v_rx - 1.0), 2.0, "#dcbb8b")
	v_mn = (J.getv(v_wrap, "meat") if J.truth(J.getv(v_wrap, "meat")) else 0.0)
	v_fn = (J.getv(v_wrap, "friesN") if J.truth(J.getv(v_wrap, "friesN")) else 0.0)
	v_by = (v_cy - 3.0)
	# BIRLESIK: et + patates + tursu tek HD parca (birbirine karisan dolgu)
	var v_dolgu: bool = game.f_hdSargiDolgu(v_mn, v_fn, J.getv(v_wrap, "pickleN"), v_cx, v_cy)
	# REMAKE kancalari: malzeme katmanlari HD (blender/models/sargi_hd.py, ayni hash yerlesimi)
	if J.gt(v_mn, 0.0) and not v_dolgu and not game.f_hdSargiUst("et", v_mn, v_cx, v_cy):
		v_mOran = game.math_utils.f_clamp((float(v_mn) / float(game.j_MEAT_NEED)), 0.0, 1.0)
		v_chunks = max(5.0, floor(J.add(5.0, (v_mOran * 9.0)) + 0.5))
		v_mGen = J.add(16.0, (v_mOran * 18.0))
		v_m = 0.0
		while J.lt(v_m, v_chunks):
			v_mu = (0.5 if J.eq(v_chunks, 1.0) else (float(v_m) / float((v_chunks - 1.0))))
			v_mrnd = game.f_hash1((v_m * 2.1))
			v_mx = floor(J.add(J.add((v_cx - (float(v_mGen) / float(2.0))), (v_mu * v_mGen)), ((v_mrnd * 3.0) - 1.5)) + 0.5)
			v_kub = (sin((v_mu * J.getv({"PI": PI}, "PI"))) * J.add(2.2, (v_mOran * 2.4)))
			v_my = floor(J.add((J.add(v_by, 1.0) - v_kub), ((game.f_hash1((v_m * 5.3)) * 2.4) - 1.2)) + 0.5)
			v_mw = J.add(4.0, (int(J.n((v_mrnd * 2.4))) | int(J.n(0.0))))
			J.setv(game.j_ctx, "globalAlpha", 0.34)
			game.f_fr((v_mx - 1.0), J.add(v_my, 2.0), J.add(v_mw, 2.0), 2.0, "#2a1808")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_fr(v_mx, J.add(v_my, 1.0), v_mw, 2.0, "#7e4412")
			game.f_fr(v_mx, v_my, v_mw, 1.0, "#bd7024")
			game.f_px(J.add(v_mx, 1.0), (v_my - 1.0), "#eeb463")
			if J.gt(game.f_hash1((v_m * 7.7)), 0.55):
				game.f_px((J.add(v_mx, v_mw) - 2.0), (v_my - 1.0), "#ffd291")
			game.f_px(v_mx, v_my, "#9c5718")
			v_m = J.add(v_m, 1.0)
	if J.gt(v_fn, 0.0) and not v_dolgu and not game.f_hdSargiUst("patates", v_fn, v_cx, v_cy):
		v_fOran = game.math_utils.f_clamp((float(v_fn) / float(game.j_FRIES_NEED)), 0.0, 1.0)
		v_fc = max(4.0, floor(J.add(4.0, (v_fOran * 7.0)) + 0.5))
		v_fGen = J.add(16.0, (v_fOran * 18.0))
		v_f = 0.0
		while J.lt(v_f, v_fc):
			v_t0 = J.add((v_f * 3.77), 1.3)
			v_fu = (float(J.add(v_f, (game.f_hash1(v_t0) * 0.9))) / float(v_fc))
			v_fx = floor(J.add((v_cx - (float(v_fGen) / float(2.0))), (v_fu * v_fGen)) + 0.5)
			v_fy = floor(J.add(v_by, ((game.f_hash1((v_t0 * 1.9)) * 5.0) - 2.0)) + 0.5)
			v_fL = J.add(4.0, (int(J.n((game.f_hash1((v_t0 * 2.7)) * 5.0))) | int(J.n(0.0))))
			v_aci = (((game.f_hash1((v_t0 * 4.1)) * 2.0) - 1.0) * 0.5)
			v_tk = game.f_hash1((v_t0 * 5.3))
			v_acik = J.gt(v_tk, 0.66)
			v_govde = ("#f0d271" if J.truth(v_acik) else ("#b8801f" if J.lt(v_tk, 0.3) else "#dcae42"))
			v_kenar = ("#a8791c" if J.truth(v_acik) else ("#5e3f0c" if J.lt(v_tk, 0.3) else "#8a6218"))
			v_ustC = ("#fff0b8" if J.truth(v_acik) else ("#d9a03a" if J.lt(v_tk, 0.3) else "#f0d271"))
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			v_g0 = 0.0
			while J.lt(v_g0, v_fL):
				game.f_px(J.add(v_fx, v_g0), J.add(J.add(v_fy, floor(((v_g0 - (float(v_fL) / float(2.0))) * v_aci) + 0.5)), 2.0), "#6a4a12")
				v_g0 = J.add(v_g0, 1.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_q0 = 0.0
			while J.lt(v_q0, v_fL):
				v_qy = J.add(v_fy, floor(((v_q0 - (float(v_fL) / float(2.0))) * v_aci) + 0.5))
				v_uc = (J.eq(v_q0, 0.0) if J.eq(v_q0, 0.0) else J.eq(v_q0, (v_fL - 1.0)))
				game.f_px(J.add(v_fx, v_q0), J.add(v_qy, 1.0), v_kenar)
				game.f_px(J.add(v_fx, v_q0), v_qy, (v_kenar if J.truth(v_uc) else v_govde))
				v_q0 = J.add(v_q0, 1.0)
			if J.gt(v_fL, 3.0):
				v_q1 = 1.0
				while J.lt(v_q1, (v_fL - 1.0)):
					if J.lt(game.f_hash1(J.add(v_t0, v_q1)), 0.35):
						v_q1 = J.add(v_q1, 1.0)
						continue
					game.f_px(J.add(v_fx, v_q1), (J.add(v_fy, floor(((v_q1 - (float(v_fL) / float(2.0))) * v_aci) + 0.5)) - 1.0), v_ustC)
					v_q1 = J.add(v_q1, 1.0)
			v_f = J.add(v_f, 1.0)
	v_pkN = (J.getv(v_wrap, "pickleN") if J.truth(J.getv(v_wrap, "pickleN")) else 0.0)
	if J.gt(v_pkN, 0.0) and not v_dolgu and not game.f_hdSargiUst("tursu", v_pkN, v_cx, v_cy):
		v_pOran = game.math_utils.f_clamp((float(v_pkN) / float(game.j_PICKLE_NEED)), 0.0, 1.0)
		v_pc = max(3.0, floor(J.add(3.0, (v_pOran * 5.0)) + 0.5))
		v_pGen = J.add(14.0, (v_pOran * 16.0))
		v_k = 0.0
		while J.lt(v_k, v_pc):
			v_pu = (0.5 if J.eq(v_pc, 1.0) else (float(v_k) / float((v_pc - 1.0))))
			v_kx = floor(J.add((v_cx - (float(v_pGen) / float(2.0))), (v_pu * v_pGen)) + 0.5)
			v_ky = floor(J.add((v_by - 3.0), (int(J.n((game.f_hash1((v_k * 4.1)) * 3.0))) | int(J.n(0.0)))) + 0.5)
			J.setv(game.j_ctx, "globalAlpha", 0.32)
			game.f_ell(v_kx, J.add(v_ky, 2.0), 4.0, 2.0, "#12200a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_ell(v_kx, J.add(v_ky, 1.0), 4.0, 2.0, "#2c4410")
			game.f_ell(v_kx, v_ky, 4.0, 2.0, "#6e9128")
			game.f_ell((v_kx - 1.0), (v_ky - 1.0), 2.0, 1.0, "#a8ca52")
			game.f_px(J.add(v_kx, 1.0), v_ky, "#c4dc74")
			v_k = J.add(v_k, 1.0)
	v_ygN = (J.getv(v_wrap, "yogurtN") if J.truth(J.getv(v_wrap, "yogurtN")) else 0.0)
	if J.gt(v_ygN, 0.0) and not game.f_hdSargiYogurt(v_ygN, v_mn, v_cx, v_cy) and not game.f_hdSargiUst("yogurt", v_ygN, v_cx, v_cy):
		v_yOran = game.math_utils.f_clamp((float(v_ygN) / float(game.j_YOGURT_NEED)), 0.0, 1.0)
		v_yGen = floor(J.add(14.0, (v_yOran * 20.0)) + 0.5)
		v_yKal = J.add(1.0, floor((v_yOran * 1.6) + 0.5))
		v_y0 = (v_cx - (float(v_yGen) / float(2.0)))
		v_z0 = 0.0
		while J.le(v_z0, v_yGen):
			v_zy0 = J.add((v_by - 5.0), (sin(J.add((v_z0 * 0.42), 1.1)) * 2.1))
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_fr(floor(J.add(v_y0, v_z0) + 0.5), J.add(floor(v_zy0 + 0.5), v_yKal), 1.0, 2.0, "#6a6252")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_z0 = J.add(v_z0, 1.0)
		v_z1 = 0.0
		while J.le(v_z1, v_yGen):
			v_zx1 = floor(J.add(v_y0, v_z1) + 0.5)
			v_zy1 = floor(J.add((v_by - 5.0), (sin(J.add((v_z1 * 0.42), 1.1)) * 2.1)) + 0.5)
			game.f_fr(v_zx1, v_zy1, 1.0, v_yKal, "#cfc4a6")
			game.f_px(v_zx1, v_zy1, "#f8f4e6")
			if J.eq(fmod(J.n(v_z1), J.n(5.0)), 2.0):
				game.f_px(v_zx1, (v_zy1 - 1.0), "#ffffff")
			v_z1 = J.add(v_z1, 1.0)
	if J.truth(J.getv(v_wrap, "sauce")) and not game.f_hdSargiSosDok(J.getv(v_wrap, "sauce"), v_mn, v_cx, v_cy) and not game.f_hdSargiSos(J.getv(v_wrap, "sauce"), v_cx, v_cy):
		v_sc0 = ("#b3241a" if J.eq(J.getv(v_wrap, "sauce"), "hot") else "#e6dfc8")
		v_sc1 = ("#f04a34" if J.eq(J.getv(v_wrap, "sauce"), "hot") else "#fdfaf0")
		v_z = 0.0
		while J.lt(v_z, 26.0):
			v_zx = J.add((v_cx - 17.0), (v_z * 1.35))
			v_zy = J.add((v_by - 6.0), (sin((v_z * 1.35)) * 3.0))
			game.f_px(v_zx, J.add(v_zy, 1.0), v_sc0)
			game.f_px(v_zx, v_zy, v_sc1)
			v_z = J.add(v_z, 1.0)
		if J.eq(J.getv(v_wrap, "sauce"), "hot"):
			game.f_px((v_cx - 9.0), (v_by - 8.0), "#ff8a70")
			game.f_px(J.add(v_cx, 7.0), (v_by - 9.0), "#ff8a70")
		else:
			game.f_px((v_cx - 6.0), (v_by - 9.0), "#ffffff")
			game.f_px(J.add(v_cx, 9.0), (v_by - 8.0), "#ffffff")
	J.method(game.j_ctx, "restore", [])
	if J.gt(v_roll, 0.0):
		v_th = max(3.0, floor(v_tubeH + 0.5))
		v_ty = floor((v_frontY - (float(v_th) / float(2.0))) + 0.5)
		v_tw = floor(((v_rx * 2.0) * J.add(0.88, (0.12 * v_roll))) + 0.5)
		v_tx = floor((v_cx - (float(v_tw) / float(2.0))) + 0.5)
		v_rr = min(5.0, floor((float(v_th) / float(2.0))))
		J.setv(game.j_ctx, "globalAlpha", 0.26)
		game.f_ell(v_cx, J.add(J.add(v_cy, v_ry), 1.0), (float(v_tw) / float(2.0)), 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_tx, v_ty, v_tw, v_th, v_rr, "#b98d5c")
		game.f_rrect(v_tx, v_ty, v_tw, max(1.0, (v_th - 2.0)), v_rr, "#e8c99a")
		if J.gt(v_th, 5.0):
			game.f_rrect(J.add(v_tx, 4.0), J.add(v_ty, 1.0), (v_tw - 9.0), max(1.0, floor((v_th * 0.22) + 0.5)), 1.0, "#f8e6c4")
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_hl(J.add(v_tx, 3.0), (J.add(v_ty, v_th) - 2.0), (v_tw - 6.0), "#a8814e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_scroll = fmod(J.n((v_roll * 40.0)), J.n(9.0))
		v_ri = (-J.n(9.0))
		while J.lt(v_ri, v_tw):
			v_sxp = J.add(J.add(v_tx, v_ri), v_scroll)
			if (J.lt(v_sxp, J.add(v_tx, 2.0)) or J.gt(v_sxp, (J.add(v_tx, v_tw) - 2.0))):
				v_ri = J.add(v_ri, 9.0)
				continue
			J.setv(game.j_ctx, "globalAlpha", 0.28)
			game.f_ln(v_sxp, J.add(v_ty, 1.0), J.add(v_sxp, max(1.0, floor((v_th * 0.3) + 0.5))), (J.add(v_ty, v_th) - 2.0), "#b98d5c")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_ri = J.add(v_ri, 9.0)
		if J.gt(v_th, 6.0):
			game.f_ell(J.add(v_tx, 2.0), J.add(v_ty, (float(v_th) / float(2.0))), 2.0, ((float(v_th) / float(2.0)) - 1.0), "#dcbb8b")
			game.f_ell((J.add(v_tx, v_tw) - 3.0), J.add(v_ty, (float(v_th) / float(2.0))), 2.0, ((float(v_th) / float(2.0)) - 1.0), "#dcbb8b")
			game.f_px(J.add(v_tx, 2.0), (J.add(v_ty, floor((float(v_th) / float(2.0)) + 0.5)) - 1.0), "#f0d5a8")
			game.f_px((J.add(v_tx, v_tw) - 3.0), (J.add(v_ty, floor((float(v_th) / float(2.0)) + 0.5)) - 1.0), "#f0d5a8")
		J.setv(game.j_ctx, "globalAlpha", 0.4)
		game.f_hl(J.add(v_tx, 2.0), v_ty, (v_tw - 4.0), "#a8814e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_hl(J.add(v_tx, 3.0), J.add(v_ty, 1.0), (v_tw - 6.0), "#fff0d0")
		if (J.lt(v_roll, 1.0) and J.truth(game.f_chance(0.3))):
			game.effects.f_part({"x": J.add(v_cx, game.math_utils.f_rnd((-J.n(16.0)), 16.0)), "y": v_ty, "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(6.0))), "life": 0.35, "col": "#f8e6c4", "g": 90.0, "sz": 1.0})
	J.method(game.j_ctx, "restore", [])
	return null

# food.js:459
func f_sauceBadge(p_cx: Variant = null, p_cy: Variant = null, p_sauce: Variant = null) -> Variant:
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_aci: Variant = null
	var v_gov: Variant = null
	var v_i: Variant = null
	var v_dy: Variant = null
	var v_x0: Variant = null
	var v_gw: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_sauce: Variant = p_sauce
	if (not J.truth(v_sauce)):
		return null
	v_bx = floor(v_cx + 0.5)
	v_by = floor(v_cy + 0.5)
	v_aci = J.eq(v_sauce, "hot")
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_disc(v_bx, J.add(v_by, 2.0), 7.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_disc(v_bx, v_by, 7.0, "#15100c")
	game.f_disc(v_bx, v_by, 6.0, ("#6e1108" if J.truth(v_aci) else "#5a5340"))
	game.f_disc(v_bx, v_by, 5.0, ("#a52014" if J.truth(v_aci) else "#7d7458"))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl((v_bx - 2.0), (v_by - 4.0), 5.0, "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_aci):
		v_gov = [[(-J.n(3.0)), 0.0, 2.0], [(-J.n(2.0)), 0.0, 3.0], [(-J.n(1.0)), 0.0, 3.0], [0.0, 0.0, 3.0], [1.0, 1.0, 2.0], [2.0, 1.0, 2.0], [3.0, 2.0, 1.0]]
		v_i = 0.0
		while J.lt(v_i, J.getv(v_gov, "length")):
			v_dy = J.getv(J.getv(v_gov, v_i), 0.0)
			v_x0 = (J.getv(J.getv(v_gov, v_i), 1.0) - 1.0)
			v_gw = J.getv(J.getv(v_gov, v_i), 2.0)
			game.f_fr(J.add(v_bx, v_x0), J.add(v_by, v_dy), v_gw, 1.0, "#7a0f06")
			game.f_fr(J.add(v_bx, v_x0), J.add(v_by, v_dy), (v_gw - (1.0 if J.gt(v_gw, 1.0) else 0.0)), 1.0, "#e8321c")
			game.f_px(J.add(v_bx, v_x0), J.add(v_by, v_dy), "#ff8a6a")
			v_i = J.add(v_i, 1.0)
		game.f_px((v_bx - 1.0), (v_by - 4.0), "#3f6d18")
		game.f_px(v_bx, (v_by - 5.0), "#548f22")
		game.f_px(J.add(v_bx, 1.0), (v_by - 6.0), "#6bab2e")
	else:
		game.f_fr((v_bx - 3.0), v_by, 7.0, 3.0, "#efe9d6")
		game.f_fr((v_bx - 2.0), (v_by - 2.0), 5.0, 2.0, "#f8f4e6")
		game.f_px((v_bx - 3.0), J.add(v_by, 3.0), "#d8d0b8")
		game.f_px(J.add(v_bx, 3.0), J.add(v_by, 3.0), "#d8d0b8")
		game.f_fr((v_bx - 2.0), J.add(v_by, 3.0), 5.0, 1.0, "#e4dcc4")
		game.f_vl((v_bx - 1.0), (v_by - 1.0), 4.0, "#c9c0a4")
		game.f_vl(J.add(v_bx, 1.0), (v_by - 1.0), 4.0, "#c9c0a4")
		game.f_px(v_bx, (v_by - 3.0), "#cdc4a6")
		game.f_px(v_bx, (v_by - 4.0), "#a89a78")
		game.f_px(v_bx, (v_by - 5.0), "#8a7c5c")
		game.f_px((v_bx - 2.0), v_by, "#ffffff")
		game.f_px((v_bx - 2.0), J.add(v_by, 1.0), "#ffffff")
	return null

# food.js:507
func f_drawWrapRolled(p_cx: Variant = null, p_cy: Variant = null, p_wrap: Variant = null, p_t: Variant = null, p_sc: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_h: Variant = null
	var v_grilled: Variant = null
	var v_kiz: Variant = null
	var v_base: Variant = null
	var v_shade: Variant = null
	var v_lite: Variant = null
	var v_pt: Variant = null
	var v_po: Variant = null
	var v_pl: Variant = null
	var v_pw: Variant = null
	var v_si: Variant = null
	var v_izGuc: Variant = null
	var v_gi: Variant = null
	var v_izK: Variant = null
	var v_kb: Variant = null
	var v_ph: Variant = null
	var v_pty: Variant = null
	var v_alpha: Variant = null
	var v_yy: Variant = null
	var v_tt: Variant = null
	var v_inset: Variant = null
	var v_rowX: Variant = null
	var v_rowR: Variant = null
	var v_rowW: Variant = null
	var v_col: Variant = null
	var v_fi: Variant = null
	var v_b1y: Variant = null
	var v_b2y: Variant = null
	var v_di: Variant = null
	var v_sy2: Variant = null
	var v_sr: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_wrap: Variant = p_wrap
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	v_sc = (v_sc if J.truth(v_sc) else 1.0)
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [v_cx, v_cy])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(v_cx)), (-J.n(v_cy))])
	v_w = 40.0
	v_h = 13.0
	v_grilled = (not (not J.truth(J.getv(v_wrap, "grilled"))))
	v_kiz = (1.0 if J.truth(v_grilled) else game.math_utils.f_clamp((J.getv(v_wrap, "kizarma") if J.truth(J.getv(v_wrap, "kizarma")) else 0.0), 0.0, 1.0))
	v_base = ("#f0d5a8" if J.le(v_kiz, 0.0) else game.street_background.f_mixHex("#f0d5a8", "#d9a765", v_kiz))
	v_shade = ("#c9a06a" if J.le(v_kiz, 0.0) else game.street_background.f_mixHex("#c9a06a", "#a87a41", v_kiz))
	v_lite = ("#f8e6c4" if J.le(v_kiz, 0.0) else game.street_background.f_mixHex("#f8e6c4", "#f0c68e", v_kiz))
	if J.truth(J.getv(v_wrap, "burnt")):
		v_base = "#3f3129"
		v_shade = "#241c17"
		v_lite = "#544234"
	v_pt = (J.getv(v_wrap, "paperT") if J.gt(J.getv(v_wrap, "paperT"), 0.0) else 0.0)
	v_po = floor(((v_pt * v_pt) * 10.0) + 0.5)
	v_pl = ((v_cx - (float(v_w) / float(2.0))) - 1.0)
	v_pw = 21.0
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_ell(v_cx, J.add(v_cy, 8.0), (float(v_w) / float(2.0)), 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(J.getv(v_wrap, "paper")):
		# REMAKE kancasi
		if not game.f_hdKagitArka(v_cx, v_cy, v_po, v_pt):
			J.setv(game.j_ctx, "globalAlpha", (1.0 - (v_pt * 0.3)))
			game.f_rrect((v_pl - 1.0), J.add(((v_cy - (float(v_h) / float(2.0))) - 1.0), v_po), J.add(v_pw, 3.0), J.add(v_h, 2.0), 5.0, "#cfc9b8")
			game.f_rrect((v_pl - 1.0), J.add(((v_cy - (float(v_h) / float(2.0))) - 1.0), v_po), J.add(v_pw, 3.0), J.add(v_h, 1.0), 5.0, "#e8e4d6")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi
	if not game.f_hdDurumGovde(v_cx, v_cy, v_kiz, J.getv(v_wrap, "burnt")):
		game.f_rrect((v_cx - (float(v_w) / float(2.0))), (v_cy - (float(v_h) / float(2.0))), v_w, v_h, 5.0, v_shade)
		game.f_rrect((v_cx - (float(v_w) / float(2.0))), (v_cy - (float(v_h) / float(2.0))), v_w, (v_h - 2.0), 5.0, v_base)
		game.f_rrect(J.add((v_cx - (float(v_w) / float(2.0))), 3.0), J.add((v_cy - (float(v_h) / float(2.0))), 1.0), (v_w - 8.0), 4.0, 2.0, v_lite)
		game.f_ell(J.add((v_cx - (float(v_w) / float(2.0))), 2.0), v_cy, 3.0, ((float(v_h) / float(2.0)) - 1.0), v_shade)
		game.f_ell((J.add(v_cx, (float(v_w) / float(2.0))) - 2.0), v_cy, 3.0, ((float(v_h) / float(2.0)) - 1.0), v_shade)
		game.f_px(J.add((v_cx - (float(v_w) / float(2.0))), 2.0), v_cy, v_base)
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 2.0), v_cy, v_base)
		v_si = 0.0
		while J.lt(v_si, 4.0):
			J.setv(game.j_ctx, "globalAlpha", 0.22)
			game.f_ln(J.add(J.add((v_cx - (float(v_w) / float(2.0))), 8.0), (v_si * 8.0)), (v_cy - 5.0), J.add(J.add((v_cx - (float(v_w) / float(2.0))), 10.0), (v_si * 8.0)), J.add(v_cy, 5.0), v_shade)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_si = J.add(v_si, 1.0)
		if J.gt(v_kiz, 0.18):
			v_izGuc = game.math_utils.f_clamp((float((v_kiz - 0.18)) / float(0.82)), 0.0, 1.0)
			v_gi = 0.0
			while J.lt(v_gi, 5.0):
				v_izK = game.math_utils.f_clamp((float((v_izGuc - (v_gi * 0.11))) / float(0.45)), 0.0, 1.0)
				if J.le(v_izK, 0.0):
					v_gi = J.add(v_gi, 1.0)
					continue
				J.setv(game.j_ctx, "globalAlpha", (0.55 * v_izK))
				game.f_ln(J.add((v_cx - 14.0), (v_gi * 7.0)), (v_cy - 4.0), J.add((v_cx - 11.0), (v_gi * 7.0)), J.add(v_cy, 4.0), "#8a5a2a")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				v_gi = J.add(v_gi, 1.0)
			if J.gt(v_kiz, 0.62):
				J.setv(game.j_ctx, "globalAlpha", (0.4 * game.math_utils.f_clamp((float((v_kiz - 0.62)) / float(0.38)), 0.0, 1.0)))
				v_kb = 0.0
				while J.lt(v_kb, 6.0):
					game.f_px(floor(J.add((v_cx - 15.0), (game.f_hash1((v_kb * 3.7)) * 30.0)) + 0.5), floor(J.add((v_cy - 4.0), (game.f_hash1((v_kb * 8.3)) * 8.0)) + 0.5), "#6b3f18")
					v_kb = J.add(v_kb, 1.0)
				J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.truth(v_grilled):
			pass
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 4.0), (v_cy - 2.0), "#c98436")
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 5.0), J.add(v_cy, 1.0), "#8a4f1e")
	if J.truth(J.getv(v_wrap, "pickle")):
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 6.0), (v_cy - 3.0), J.getv(game.j_P, "g1"))
	if J.truth(J.getv(v_wrap, "yogurt")):
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 3.0), J.add(v_cy, 2.0), J.getv(game.j_P, "s0"))
	if J.gt(J.getv(v_wrap, "friesN"), 0.0):
		game.f_px((J.add(v_cx, (float(v_w) / float(2.0))) - 7.0), J.add(v_cy, 2.0), J.getv(game.j_P, "p1"))
	if J.truth(J.getv(v_wrap, "paper")):
		# REMAKE kancasi
		if not game.f_hdKagitOn(v_cx, v_cy, v_po, v_pt):
			v_ph = v_h
			v_pty = floor(J.add((v_cy - (float(v_ph) / float(2.0))), v_po) + 0.5)
			v_alpha = (1.0 - (v_pt * 0.15))
			J.setv(game.j_ctx, "globalAlpha", v_alpha)
			v_yy = 0.0
			while J.lt(v_yy, v_ph):
				v_tt = (float(v_yy) / float((v_ph - 1.0)))
				v_inset = (3.0 if (J.eq(v_yy, 0.0) or J.eq(v_yy, (v_ph - 1.0))) else (1.0 if (J.eq(v_yy, 1.0) or J.eq(v_yy, (v_ph - 2.0))) else 0.0))
				v_rowX = J.add(v_pl, v_inset)
				v_rowR = J.add((J.add(v_pl, v_pw) - 5.0), floor((v_tt * 6.0) + 0.5))
				v_rowW = (v_rowR - v_rowX)
				if J.lt(v_rowW, 2.0):
					v_yy = J.add(v_yy, 1.0)
					continue
				if J.eq(v_yy, 0.0):
					v_col = "#fdfaf0"
				else:
					if J.lt(v_yy, 3.0):
						v_col = "#f8f5ea"
					else:
						if J.lt(v_yy, (v_ph - 4.0)):
							v_col = "#f2eee0"
						else:
							if J.lt(v_yy, (v_ph - 2.0)):
								v_col = "#e2ddcc"
							else:
								v_col = "#cfc8b4"
				game.f_fr(v_rowX, J.add(v_pty, v_yy), v_rowW, 1.0, v_col)
				game.f_px((v_rowR - 1.0), J.add(v_pty, v_yy), ("#ffffff" if J.lt(v_yy, 3.0) else "#e8e2d0"))
				game.f_px(v_rowR, J.add(v_pty, v_yy), "rgba(120,112,94,.45)")
				v_yy = J.add(v_yy, 1.0)
			v_fi = 0.0
			while J.lt(v_fi, 3.0):
				J.setv(game.j_ctx, "globalAlpha", (v_alpha * J.add(0.28, (v_fi * 0.07))))
				game.f_ln(J.add(J.add(v_pl, 2.0), (v_fi * 2.0)), J.add(v_pty, 2.0), J.add(J.add(v_pl, 4.0), (v_fi * 2.0)), (J.add(v_pty, v_ph) - 3.0), "#d2ccb8")
				v_fi = J.add(v_fi, 1.0)
			J.setv(game.j_ctx, "globalAlpha", v_alpha)
			v_b1y = floor(J.add(v_pty, (v_ph * 0.32)) + 0.5)
			v_b2y = floor(J.add(v_pty, (v_ph * 0.62)) + 0.5)
			game.f_fr(J.add(v_pl, 4.0), v_b1y, (v_pw - 10.0), 2.0, "#d8352c")
			game.f_px(J.add(v_pl, 3.0), J.add(v_b1y, 1.0), "#b02a22")
			game.f_fr(J.add(v_pl, 4.0), v_b2y, (v_pw - 9.0), 2.0, "#2f5f9e")
			game.f_px(J.add(v_pl, 3.0), J.add(v_b2y, 1.0), "#26477a")
			v_di = 0.0
			while J.lt(v_di, 4.0):
				game.f_px(J.add(J.add(v_pl, 5.0), (v_di * 4.0)), J.add(v_pty, 2.0), ("#2f5f9e" if J.truth(fmod(J.n(v_di), J.n(2.0))) else "#d8352c"))
				v_di = J.add(v_di, 1.0)
			J.setv(game.j_ctx, "globalAlpha", (v_alpha * 0.35))
			v_sy2 = 2.0
			while J.lt(v_sy2, (v_ph - 2.0)):
				v_sr = J.add((J.add(v_pl, v_pw) - 5.0), floor(((float(v_sy2) / float((v_ph - 1.0))) * 6.0) + 0.5))
				game.f_px((v_sr - 2.0), J.add(v_pty, v_sy2), "#8a8474")
				v_sy2 = J.add(v_sy2, 1.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (J.truth(J.getv(v_wrap, "hot")) and J.truth(game.f_chance(0.04))):
		game.effects.f_smoke(J.add(v_cx, game.math_utils.f_rnd((-J.n(10.0)), 10.0)), (v_cy - 7.0), 1.0, "rgba(255,250,240,.4)")
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "restore", [])
	if J.truth(J.getv(v_wrap, "sauce")):
		game.wrap_draw.f_sauceBadge(J.add(v_cx, 13.0), (v_cy - 6.0), J.getv(v_wrap, "sauce"))
	return null

