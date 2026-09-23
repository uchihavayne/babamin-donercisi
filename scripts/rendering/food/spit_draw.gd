# Spit draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:2712
func f_drawKesimBicagi(p_ux: Variant = null, p_uy: Variant = null, p_yon: Variant = null, p_kademe: Variant = null) -> Variant:
	var _cells: Dictionary = {"K": [null], "ux": [p_ux], "d": [null], "uy": [p_uy]}
	var v_agizCiz: Variant = null
	var v_bx0: Variant = null
	var v_bh: Variant = null
	var v_s: Variant = null
	var v_sx: Variant = null
	var v_sv: Variant = null
	var v_sk: Variant = null
	var v_kanca: Variant = null
	var v_sy: Variant = null
	var v_pI: Variant = null
	var v_px0: Variant = null
	var v_yon: Variant = p_yon
	var v_kademe: Variant = p_kademe
	# REMAKE kancasi
	if game.f_hdBicak(p_ux, p_uy, p_yon, p_kademe): return null
	v_agizCiz = game.spit_draw._closure_75.bind({"257:K": _cells["K"], "257:ux": _cells["ux"], "257:d": _cells["d"], "257:uy": _cells["uy"]})
	_cells["d"][0] = (v_yon if J.truth(v_yon) else (-J.n(1.0)))
	_cells["K"][0] = J.getv(game.j_BICAK_KADEME, game.math_utils.f_clamp(floor((v_kademe if J.truth(v_kademe) else 0.0) + 0.5), 0.0, 3.0))
	_cells["ux"][0] = floor(_cells["ux"][0] + 0.5)
	_cells["uy"][0] = floor(_cells["uy"][0] + 0.5)
	if J.truth(J.getv(_cells["K"][0], "cift")):
		J.invoke(v_agizCiz, [(-J.n(2.0)), 0.0])
		J.invoke(v_agizCiz, [2.0, 0.0])
		game.f_fr((J.add(_cells["ux"][0], (_cells["d"][0] * (J.getv(_cells["K"][0], "boy") - 2.0))) - (3.0 if J.lt(_cells["d"][0], 0.0) else 0.0)), (_cells["uy"][0] - 2.0), 4.0, 5.0, J.getv(J.getv(_cells["K"][0], "celik"), 0.0))
		game.f_fr((J.add(_cells["ux"][0], (_cells["d"][0] * (J.getv(_cells["K"][0], "boy") - 2.0))) - (3.0 if J.lt(_cells["d"][0], 0.0) else 0.0)), (_cells["uy"][0] - 2.0), 4.0, 4.0, J.getv(J.getv(_cells["K"][0], "celik"), 1.0))
	else:
		J.invoke(v_agizCiz, [0.0, J.getv(_cells["K"][0], "yuk")])
	v_bx0 = J.add(_cells["ux"][0], (_cells["d"][0] * J.add(J.getv(_cells["K"][0], "boy"), 1.0)))
	v_bh = J.add(J.getv(_cells["K"][0], "sapKal"), 1.0)
	game.f_fr((v_bx0 - 1.0), (_cells["uy"][0] - v_bh), 3.0, J.add((v_bh * 2.0), 1.0), J.getv(_cells["K"][0], "bilezik"))
	game.f_fr((v_bx0 - 1.0), (_cells["uy"][0] - v_bh), 3.0, (v_bh * 2.0), J.getv(_cells["K"][0], "bilezikI"))
	game.f_px((v_bx0 - 1.0), (_cells["uy"][0] - v_bh), J.getv(_cells["K"][0], "bilezikI"))
	v_s = 0.0
	while J.lt(v_s, J.getv(_cells["K"][0], "sapUz")):
		v_sx = J.add(_cells["ux"][0], (_cells["d"][0] * J.add(J.add(J.getv(_cells["K"][0], "boy"), 3.0), v_s)))
		v_sv = sin(((float(J.add(v_s, 1.0)) / float(J.add(J.getv(_cells["K"][0], "sapUz"), 1.0))) * J.getv({"PI": PI}, "PI")))
		v_sk = J.add(J.getv(_cells["K"][0], "sapKal"), floor((v_sv * 0.9) + 0.5))
		v_kanca = ((-J.n(floor(((v_s - (J.getv(_cells["K"][0], "sapUz") * 0.62)) * 0.5) + 0.5))) if J.gt(v_s, (J.getv(_cells["K"][0], "sapUz") * 0.62)) else 0.0)
		v_sy = J.add(_cells["uy"][0], v_kanca)
		game.f_fr(v_sx, (v_sy - v_sk), 1.0, J.add((v_sk * 2.0), 1.0), J.getv(_cells["K"][0], "sapK"))
		game.f_fr(v_sx, J.add((v_sy - v_sk), 1.0), 1.0, ((v_sk * 2.0) - 1.0), J.getv(_cells["K"][0], "sapG"))
		game.f_px(v_sx, J.add((v_sy - v_sk), 1.0), J.getv(_cells["K"][0], "sapI"))
		v_s = J.add(v_s, 1.0)
	v_pI = 0.0
	while J.lt(v_pI, J.getv(_cells["K"][0], "percin")):
		v_px0 = J.add(_cells["ux"][0], (_cells["d"][0] * J.add(J.add(J.getv(_cells["K"][0], "boy"), 5.0), (v_pI * 2.0))))
		game.f_px(v_px0, _cells["uy"][0], J.getv(_cells["K"][0], "bilezikI"))
		game.f_px(v_px0, J.add(_cells["uy"][0], 1.0), J.getv(_cells["K"][0], "bilezik"))
		v_pI = J.add(v_pI, 1.0)
	return null

# art.js:2775
func f_drawEtDilimi(p_x: Variant = null, p_y: Variant = null, p_kv: Variant = null, p_k: Variant = null, p_sc: Variant = null) -> Variant:
	var v_boy: Variant = null
	var v_don: Variant = null
	var v_kabuk: Variant = null
	var v_koyu: Variant = null
	var v_govde: Variant = null
	var v_acik: Variant = null
	var v_isik: Variant = null
	var v_i: Variant = null
	var v_u: Variant = null
	var v_a: Variant = null
	var v_cx: Variant = null
	var v_cy: Variant = null
	var v_kal: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_kv: Variant = p_kv
	var v_k: Variant = p_k
	var v_sc: Variant = p_sc
	# REMAKE kancasi
	if game.f_hdEtDilimi(p_x, p_y, p_kv, p_k, p_sc): return null
	v_sc = (v_sc if J.truth(v_sc) else 1.0)
	v_boy = floor((J.add(5.0, (game.f_hash1((v_k * 3.1)) * 3.0)) * v_sc) + 0.5)
	v_don = ((game.f_hash1((v_k * 7.7)) * 0.9) - 0.45)
	v_kabuk = "#7e4412"
	v_koyu = "#9c5718"
	v_govde = "#bd7024"
	v_acik = "#eeb463"
	v_isik = "#ffd291"
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_i = 0.0
	while J.lt(v_i, v_boy):
		v_u = ((float(v_i) / float((v_boy - 1.0))) if J.gt(v_boy, 1.0) else 0.5)
		v_a = J.add((((v_u * J.getv({"PI": PI}, "PI")) * 1.35) * v_kv), v_don)
		v_cx = J.add(v_x, floor(((sin(v_a) * v_boy) * 0.55) + 0.5))
		v_cy = (J.add(v_y, floor((((1.0 - cos(v_a)) * v_boy) * 0.4) + 0.5)) - floor((v_boy * 0.2) + 0.5))
		v_kal = J.add(1.0, (1.0 if (J.gt(v_u, 0.18) and J.lt(v_u, 0.82)) else 0.0))
		game.f_fr(v_cx, v_cy, 1.0, J.add(v_kal, 1.0), v_kabuk)
		game.f_px(v_cx, v_cy, (v_govde if J.lt(v_u, 0.5) else v_koyu))
		if J.gt(v_kal, 1.0):
			game.f_px(v_cx, J.add(v_cy, 1.0), (v_acik if J.lt(v_u, 0.55) else v_govde))
		v_i = J.add(v_i, 1.0)
	game.f_px(J.add(v_x, floor(((sin(v_don) * v_boy) * 0.55) + 0.5)), (v_y - floor((v_boy * 0.2) + 0.5)), v_isik)
	return null

# art.js:2797
func f_drawSpit(p_sp: Variant = null, p_t: Variant = null) -> Variant:
	var v_cx: float = 0.0
	var v_top: float = 0.0
	var v_bot: float = 0.0
	var v_H0: float = 0.0
	var v_maxR: float = 0.0
	var v_hx: float = 0.0
	var v_hy: float = 0.0
	var v_hw: float = 0.0
	var v_hh: float = 0.0
	var v_i: float = 0.0
	var v_seg: float = 0.0
	var v_ey: float = 0.0
	var v_fl: float = 0.0
	var v_mass: float = 0.0
	var v_scaleR: float = 0.0
	var v_coneTop: float = 0.0
	var v_coneH: float = 0.0
	var v_y: float = 0.0
	var v_ty: float = 0.0
	var v_rjit: float = 0.0
	var v_r: float = 0.0
	var v_yy: float = 0.0
	var v_cutAmt: float = 0.0
	var v_lay: float = 0.0
	var v_layM: float = 0.0
	var v_runK: float = 0.0
	var v_runX: float = 0.0
	var v_x: float = 0.0
	var v_nx: float = 0.0
	var v_n01: float = 0.0
	var v_shade: float = 0.0
	var v_ang: float = 0.0
	var v_seam: float = 0.0
	var v_lroast: float = 0.0
	var v_k: float = 0.0
	var v_x2: float = 0.0
	var v_gx2: float = 0.0
	var v_bx2: float = 0.0
	var v_yc: float = 0.0
	var v_rr: float = 0.0
	var v_ca: float = 0.0
	var v_topR: float = 0.0
	var v_rx0: float = 0.0
	var v_rv: float = 0.0
	var v_wa: float = 0.0
	var v_ph: float = 0.0
	var v_tri: float = 0.0
	var v_cy2: float = 0.0
	var v_kt: float = 0.0
	var v_ky: float = 0.0
	var v_kx: float = 0.0
	var v_sp: Dictionary = p_sp
	var v_t: float = p_t
	v_cx = game.j_LAY["spit"]["cx"]
	v_top = game.j_LAY["spit"]["top"]
	v_bot = game.j_LAY["spit"]["bot"]
	v_H0 = (v_bot - v_top)
	v_maxR = 19.0
	v_hx = (v_cx + 19.0)
	v_hy = (v_top + 2.0)
	v_hw = 17.0
	v_hh = (v_H0 - 14.0)
	# REMAKE kancasi: HD isitici kasasi (Blender); kor elemanlar asagida
	var hd_isi := J.truth(game.f_hdIsiticiGovde(v_hx, v_hy))
	if not hd_isi:
		game.f_fr((v_hx - 1.0), (v_hy - 1.0), (v_hw + 2.0), (v_hh + 2.0), game.j_P["mt4"])
		game.f_fr(v_hx, v_hy, v_hw, v_hh, game.j_P["mt2"])
		game.f_fr((v_hx + 2.0), (v_hy + 2.0), (v_hw - 4.0), (v_hh - 4.0), "#241610")
		game.f_hl(v_hx, v_hy, v_hw, game.j_P["mt0"])
		game.f_vl(v_hx, v_hy, v_hh, game.j_P["mt1"])
		game.f_hl(v_hx, ((v_hy + v_hh) - 1.0), v_hw, game.j_P["mt5"])
	v_i = 0.0
	while (v_i < 6.0):
		v_seg = floor((float((v_hh - 8.0)) / float(6.0)))
		v_ey = ((v_hy + 4.0) + (v_i * v_seg))
		v_fl = (0.55 + (0.45 * sin(((v_t * 6.0) + (v_i * 1.9)))))
		if not (hd_isi and J.truth(game.f_hdIsiticiEleman((v_hx + 3.0), v_ey, v_fl))):
			game.f_fr((v_hx + 3.0), v_ey, (v_hw - 6.0), (v_seg - 3.0), "#6d1a08")
			game.f_fr((v_hx + 3.0), v_ey, (v_hw - 6.0), (v_seg - 4.0), ("#c8380f" if J.truth(fmod(J.n(v_i), J.n(2.0))) else "#e0500f"))
			J.setv(game.j_ctx, "globalAlpha", (0.3 + (0.4 * v_fl)))
			game.f_fr((v_hx + 4.0), (v_ey + 1.0), (v_hw - 8.0), max(1.0, (v_seg - 5.0)), "#ff9c2e")
			J.setv(game.j_ctx, "globalAlpha", (0.25 + (0.3 * v_fl)))
			game.f_fr((v_hx + 5.0), (v_ey + 1.0), (v_hw - 10.0), max(1.0, (v_seg - 6.0)), "#ffe08a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.truth(game.f_chance(0.014)):
			game.effects.f_part({"x": (v_hx + game.math_utils.f_rnd(3.0, (v_hw - 3.0))), "y": v_ey, "vx": game.math_utils.f_rnd((-J.n(4.0)), 2.0), "vy": game.math_utils.f_rnd((-J.n(30.0)), (-J.n(14.0))), "life": game.math_utils.f_rnd(0.3, 0.8), "col": game.math_utils.f_pick([game.j_P["f1"], game.j_P["f2"], game.j_P["f0"]]), "g": (-J.n(16.0)), "sz": 1.0})
		v_i = (v_i + 1.0)
	# REMAKE kancasi: duz turuncu kutu yerine isiticiya dogru artan sicak isik
	if not (hd_isi and J.truth(game.f_hdSicakIsik((v_cx - 4.0), v_top, (0.1 + (0.045 * sin((v_t * 5.0))))))):
		J.setv(game.j_ctx, "globalAlpha", (0.1 + (0.045 * sin((v_t * 5.0)))))
		game.f_fr((v_cx - 4.0), v_top, 26.0, v_H0, "#ff8a2a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.counter_draw.f_heatShimmer((v_cx + 8.0), (v_top + 6.0), 18.0, (v_H0 - 12.0), v_t)
	game.f_vl((v_cx - 1.0), (v_top - 12.0), (v_H0 + 16.0), game.j_P["mt4"])
	game.f_vl(v_cx, (v_top - 12.0), (v_H0 + 16.0), game.j_P["mt1"])
	game.f_vl((v_cx + 1.0), (v_top - 12.0), (v_H0 + 16.0), game.j_P["mt3"])
	game.f_fr((v_cx - 5.0), (v_top - 15.0), 11.0, 4.0, game.j_P["mt3"])
	game.f_hl((v_cx - 5.0), (v_top - 15.0), 11.0, game.j_P["mt0"])
	game.f_fr((v_cx - 8.0), (v_top - 19.0), 17.0, 4.0, game.j_P["mt2"])
	game.f_hl((v_cx - 8.0), (v_top - 19.0), 17.0, game.j_P["mt0"])
	game.f_hl((v_cx - 8.0), (v_top - 16.0), 17.0, game.j_P["mt4"])
	game.f_vl(v_cx, 0.0, (v_top - 18.0), game.j_P["mt3"])
	game.f_vl((v_cx + 1.0), 0.0, (v_top - 18.0), game.j_P["mt4"])
	v_mass = game.math_utils.f_clamp(v_sp["mass"], 0.0, 1.0)
	v_scaleR = (0.45 + (0.55 * v_mass))
	v_coneTop = (v_top + floor(((1.0 - v_mass) * 10.0) + 0.5))
	v_coneH = (v_H0 - floor(((1.0 - v_mass) * 18.0) + 0.5))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_ell((v_cx + 2.0), (v_bot + 3.0), 15.0, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi: HD koni shader'i cizerse prosedurel dongu ve kesim yuzu atlanir
	var v_hd: bool = game.f_sisHD(v_sp, v_cx, v_coneTop, v_coneH)
	v_y = (v_coneH if v_hd else 0.0)
	while (v_y < v_coneH):
		v_ty = (float(v_y) / float(v_coneH))
		v_rjit = ((1.0 if (sin(((v_y * 0.21) + (v_sp["rot"] * 1.3))) > 0.25) else 0.0) - (1.0 if (sin((((v_y * 0.29) + 2.1) + v_sp["rot"])) > 0.55) else 0.0))
		v_r = max(1.0, (floor(((v_maxR * v_scaleR) * game.f_coneProfile(v_ty)) + 0.5) + (v_rjit if ((v_ty > 0.06) and (v_ty < 0.95)) else 0.0)))
		v_yy = (v_coneTop + v_y)
		v_cutAmt = (floor((v_sp["cutDepth"] * (1.0 - abs((v_ty - 0.45)))) + 0.5) if (((v_sp["cutDepth"] > 0.0) and (v_y > 8.0)) and (v_y < (v_coneH * 0.8))) else 0.0)
		v_lay = sin(((v_y * 0.62) + (sin((v_y * 0.19)) * 1.6)))
		v_layM = (1.0 + (v_lay * 0.028))
		v_runK = (-J.n(1.0))
		v_runX = 0.0
		v_x = (-J.n(v_r))
		while (v_x <= v_r):
			if (((v_cutAmt > 0.0) and (v_x < 0.0)) and ((-J.n(v_x)) > (v_r - v_cutAmt))):
				v_x = (v_x + 1.0)
				continue
			v_nx = (float(v_x) / float(v_r))
			v_n01 = ((v_nx * 0.5) + 0.5)
			if (v_nx < (-J.n(0.78))):
				v_shade = 0.52
			else:
				if (v_nx < (-J.n(0.55))):
					v_shade = 0.66
				else:
					if (v_nx < (-J.n(0.25))):
						v_shade = 0.8
					else:
						if (v_nx < 0.1):
							v_shade = 0.95
						else:
							if (v_nx < 0.38):
								v_shade = 1.12
							else:
								if (v_nx < 0.62):
									v_shade = 1.3
								else:
									if (v_nx < 0.86):
										v_shade = 1.12
									else:
										v_shade = 0.86
			v_ang = game.f_asinF(v_nx)
			v_seam = (float(((v_ang * 1.9) + (v_sp["rot"] * 2.2))) / float({"PI": PI}["PI"]))
			v_seam = (v_seam - floor(v_seam))
			if (v_seam < 0.1):
				v_shade = (v_shade * 0.8)
			else:
				if (v_seam < 0.16):
					v_shade = (v_shade * 1.1)
			v_shade = (v_shade * v_layM)
			v_lroast = (v_sp["roast"] * (0.84 + (0.3 * v_n01)))
			if (v_ty < 0.05):
				v_lroast = (v_lroast * 0.82)
			v_k = (((int(J.n((v_lroast * 15.0))) | int(J.n(0.0))) * 40.0) + (int(J.n((v_shade * 12.0))) | int(J.n(0.0))))
			if (v_k != v_runK):
				if (v_runK >= 0.0):
					J.setv(game.j_ctx, "fillStyle", game.f_meatColQ(v_runK))
					game.draw_context.fillRect((v_cx + v_runX), v_yy, (v_x - v_runX), 1.0)
				v_runK = v_k
				v_runX = v_x
			v_x = (v_x + 1.0)
		if (v_runK >= 0.0):
			J.setv(game.j_ctx, "fillStyle", game.f_meatColQ(v_runK))
			game.draw_context.fillRect((v_cx + v_runX), v_yy, ((v_r + 1.0) - v_runX), 1.0)
		game.f_px((((v_cx - v_r) - 1.0) + v_cutAmt), v_yy, "rgba(30,18,10,.45)")
		game.f_px(((v_cx + v_r) + 1.0), v_yy, "rgba(30,18,10,.40)")
		game.f_px((v_cx + v_r), v_yy, game.f_meatCol((v_sp["roast"] * 1.05), 0.8))
		game.f_px(((v_cx + v_r) - 1.0), v_yy, game.f_meatCol((v_sp["roast"] * 1.0), 1.22))
		game.f_px(((v_cx - v_r) + v_cutAmt), v_yy, game.f_meatCol((v_sp["roast"] * 0.78), 0.6))
		if (v_cutAmt == 0.0):
			game.f_px(((v_cx - v_r) - 1.0), v_yy, "rgba(20,12,8,.35)")
		if (fmod(J.n((v_y + floor((v_sp["rot"] * 2.0)))), J.n(12.0)) == 0.0):
			v_x2 = (((-J.n(v_r)) + 2.0) + v_cutAmt)
			while (v_x2 < (v_r - 1.0)):
				if (game.f_hash1(((v_x2 * 3.1) + (v_y * 1.7))) > 0.38):
					game.f_px((v_cx + v_x2), v_yy, game.f_meatCol((v_sp["roast"] * 0.92), 0.78))
				v_x2 = (v_x2 + 1.0)
		if (game.f_hash1(((v_y * 4.7) + floor((v_sp["rot"] * 1.5)))) > 0.8):
			v_gx2 = floor(game.math_utils.f_rnd((v_r * 0.05), (v_r * 0.7)) + 0.5)
			game.f_px((v_cx + v_gx2), v_yy, game.f_meatCol((v_sp["roast"] * 0.9), 1.55))
			game.f_px((v_cx + v_gx2), (v_yy + 1.0), game.f_meatCol(v_sp["roast"], 1.25))
		if ((v_sp["roast"] > 1.02) and (game.f_hash1(((v_y * 2.3) + floor(v_sp["rot"]))) > 0.7)):
			v_bx2 = floor(game.math_utils.f_rnd(((-J.n(v_r)) * 0.3), (v_r * 0.9)) + 0.5)
			game.f_px((v_cx + v_bx2), v_yy, "#33231a")
			game.f_px(((v_cx + v_bx2) + 1.0), v_yy, "#4a3226")
		v_y = (v_y + 1.0)
	if (not v_hd) and (v_sp["cutDepth"] > 0.0):
		v_yc = 10.0
		while (v_yc < (v_coneH * 0.8)):
			v_rr = max(1.0, floor(((v_maxR * v_scaleR) * game.f_coneProfile((float(v_yc) / float(v_coneH)))) + 0.5))
			v_ca = floor((v_sp["cutDepth"] * (1.0 - abs(((float(v_yc) / float(v_coneH)) - 0.45)))) + 0.5)
			if (v_ca > 0.0):
				game.f_px(((v_cx - v_rr) + v_ca), (v_coneTop + v_yc), game.f_meatCol((v_sp["roast"] * 0.22), 1.15))
				game.f_px((((v_cx - v_rr) + v_ca) + 1.0), (v_coneTop + v_yc), game.f_meatCol((v_sp["roast"] * 0.34), 0.98))
			v_yc = (v_yc + 1.0)
	v_topR = floor(((v_maxR * v_scaleR) * game.f_coneProfile(0.02)) + 0.5)
	game.f_ell(v_cx, (v_coneTop + 1.0), (v_topR - 1.0), 3.0, "#a8302a")
	game.f_ell(v_cx, v_coneTop, (v_topR - 1.0), 3.0, "#d8443a")
	game.f_ell((v_cx - 2.0), (v_coneTop - 1.0), max(2.0, (v_topR - 5.0)), 1.0, "#f2887a")
	game.f_px((v_cx + 3.0), (v_coneTop - 2.0), game.j_P["g2"])
	game.f_px((v_cx + 4.0), (v_coneTop - 3.0), game.j_P["g1"])
	game.f_fr((v_cx - 9.0), (v_bot - 3.0), 19.0, 3.0, game.j_P["mt4"])
	game.f_hl((v_cx - 9.0), (v_bot - 3.0), 19.0, game.j_P["mt1"])
	game.f_ell(v_cx, (v_bot + 2.0), 13.0, 4.0, game.j_P["mt4"])
	game.f_ell(v_cx, (v_bot + 1.0), 13.0, 4.0, game.j_P["mt1"])
	game.f_ell(v_cx, (v_bot + 1.0), 10.0, 2.0, game.j_P["mt2"])
	game.f_ell((v_cx + 1.0), (v_bot + 2.0), 7.0, 1.0, "#9a6a1e")
	if J.truth(game.f_chance(0.02)):
		game.effects.f_part({"x": (v_cx + game.math_utils.f_rnd((-J.n(4.0)), 4.0)), "y": (v_bot - 4.0), "vx": 0.0, "vy": 20.0, "life": 0.5, "col": "#c08a2a", "g": 90.0, "sz": 1.0, "floor": (v_bot + 1.0)})
	if (((J.kind(game.j_TUN) != "undefined") and J.truth(game.j_G["up"])) and J.truth(J.method(game.j_TUN, "autoShave", [game.j_G]))):
		v_rx0 = ((v_cx - floor((v_maxR * v_scaleR) + 0.5)) - 12.0)
		# REMAKE kancasi
		if game.f_hdOtoTiras(v_rx0, v_top, v_t):
			game.f_hdOtoLed(v_rx0, v_top, J.truth(game.f_chance(0.5)))
		else:
			game.f_fr(v_rx0, (v_top - 6.0), 4.0, (v_H0 + 14.0), "#3a4048")
			game.f_fr((v_rx0 + 1.0), (v_top - 6.0), 2.0, (v_H0 + 14.0), "#6b737d")
			v_rv = 0.0
			while (v_rv < (v_H0 + 10.0)):
				game.f_px((v_rx0 + 1.0), ((v_top - 4.0) + v_rv), "#98a0a9")
				v_rv = (v_rv + 8.0)
			game.f_fr((v_rx0 - 7.0), (v_top - 16.0), 16.0, 12.0, "#2f3740")
			game.f_fr((v_rx0 - 6.0), (v_top - 16.0), 14.0, 11.0, "#59636d")
			game.f_hl((v_rx0 - 6.0), (v_top - 16.0), 14.0, "#8b959e")
			v_wa = (v_t * 9.0)
			game.f_disc((v_rx0 + 1.0), (v_top - 10.0), 4.0, "#3a4048")
			game.f_disc((v_rx0 + 1.0), (v_top - 10.0), 3.0, "#98a0a9")
			game.f_ln((v_rx0 + 1.0), (v_top - 10.0), ((v_rx0 + 1.0) + (cos(v_wa) * 3.0)), ((v_top - 10.0) + (sin(v_wa) * 3.0)), "#2f3740")
			game.f_px((v_rx0 - 4.0), (v_top - 13.0), ("#7dff7a" if J.truth(game.f_chance(0.5)) else "#2a6a28"))
		v_ph = ((float((game.j_G["shave"]["auto"] if J.truth(game.j_G["shave"]["auto"]) else 0.0)) / float(0.55)) if J.truth(game.j_G["shave"]) else 0.0)
		v_tri = ((v_ph * 2.0) if (v_ph < 0.5) else ((1.0 - v_ph) * 2.0))
		v_cy2 = floor(game.math_utils.f_lerp((v_top + 10.0), (v_bot - 18.0), game.math_utils.f_clamp(v_tri, 0.0, 1.0)) + 0.5)
		# REMAKE kancasi
		if not game.f_hdOtoAraba(v_rx0, v_cy2):
			game.f_fr((v_rx0 - 4.0), (v_cy2 - 5.0), 12.0, 11.0, "#59636d")
			game.f_fr((v_rx0 - 3.0), (v_cy2 - 5.0), 10.0, 10.0, "#8b959e")
			game.f_hl((v_rx0 - 3.0), (v_cy2 - 5.0), 10.0, "#c6ccd2")
			game.f_fr((v_rx0 - 5.0), (v_cy2 - 1.0), 3.0, 3.0, "#2f3740")
			game.f_fr((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, 3.0, "#c9d2da")
			game.f_fr((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, 2.0, "#eef4f8")
			game.f_hl((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, "#ffffff")
			game.f_px((v_rx0 + 21.0), v_cy2, "#ffffff")
		if J.truth(game.f_chance(0.25)):
			game.effects.f_part({"x": (v_rx0 + 20.0), "y": (v_cy2 + game.math_utils.f_rnd((-J.n(2.0)), 2.0)), "vx": game.math_utils.f_rnd((-J.n(26.0)), (-J.n(6.0))), "vy": game.math_utils.f_rnd((-J.n(18.0)), 4.0), "life": 0.35, "col": game.math_utils.f_pick(["#c98436", "#eeb464"]), "g": 240.0, "sz": 1.0, "floor": (game.j_ST["meat"]["y"] + game.math_utils.f_rnd(4.0, 12.0))})
	if (v_sp["sliceT"] > 0.0):
		v_kt = (1.0 - v_sp["sliceT"])
		v_ky = ((v_coneTop + 10.0) + (v_kt * (v_coneH - 26.0)))
		v_kx = ((v_cx - floor((v_maxR * v_scaleR) + 0.5)) - 3.0)
		# BIRLESIK: parilti + bicak game.f_drawSpitCutKnife'ta (platform katmani
		# elde tutulan bicak gorunurken gizler); game_sprites surumuyle ayni
		game.f_drawSpitCutKnife((v_kx + 4.0), (v_ky + 1.0), (game.equipment_system.f_UV(game.j_G, "knife") if (J.kind(J.ref(game.equipment_system.f_UV, 2)) == "function") else 0.0))
		if J.truth(game.f_chance(0.5)):
			game.effects.f_part({"x": (v_kx + 4.0), "y": (v_ky + game.math_utils.f_rnd((-J.n(2.0)), 2.0)), "vx": game.math_utils.f_rnd((-J.n(40.0)), (-J.n(10.0))), "vy": game.math_utils.f_rnd((-J.n(20.0)), 10.0), "life": 0.3, "col": "#ffffff", "g": 60.0, "sz": 1.0})
	return null

func _closure_75(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_i: Variant = null
	var v_u: Variant = null
	var v_bx: Variant = null
	var v_h: Variant = null
	var v_t: Variant = null
	var v_y0: Variant = null
	var v_oz: Variant = null
	var v_yuk: Variant = null
	v_oz = J.arg(_args, 0)
	v_yuk = J.arg(_args, 1)
	v_i = 0.0
	while J.lt(v_i, J.getv(_captures["257:K"][0], "boy")):
		v_u = ((float(v_i) / float((J.getv(_captures["257:K"][0], "boy") - 1.0))) if J.gt(J.getv(_captures["257:K"][0], "boy"), 1.0) else 0.0)
		v_bx = J.add(_captures["257:ux"][0], (_captures["257:d"][0] * v_i))
		v_h = v_yuk
		if J.gt(v_u, 0.86):
			v_t = (float((v_u - 0.86)) / float(0.14))
			v_h = floor((v_yuk * sqrt(max(0.0, (1.0 - (v_t * v_t))))) + 0.5)
		v_y0 = J.add(_captures["257:uy"][0], v_oz)
		game.f_fr(v_bx, (v_y0 - v_h), 1.0, J.add((v_h * 2.0), 1.0), J.getv(J.getv(_captures["257:K"][0], "celik"), 0.0))
		game.f_fr(v_bx, (v_y0 - v_h), 1.0, (v_h * 2.0), J.getv(J.getv(_captures["257:K"][0], "celik"), 1.0))
		game.f_px(v_bx, (v_y0 - v_h), J.getv(J.getv(_captures["257:K"][0], "celik"), 2.0))
		if J.gt(v_yuk, 1.0):
			game.f_px(v_bx, v_y0, J.getv(J.getv(_captures["257:K"][0], "celik"), 1.0))
		v_i = J.add(v_i, 1.0)
	return null
