# Building draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:98
func f_bldWindow(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_lit: Variant = null, p_trim: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_lit: Variant = p_lit
	var v_trim: Variant = p_trim
	game.f_fr(v_x, v_y, v_w, v_h, v_trim)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), ("#3a3226" if J.truth(v_lit) else "#33454f"))
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 3.0), ("#ffdf9a" if J.truth(v_lit) else "#7ea3b5"))
	if J.truth(v_lit):
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), 1.0, "#fff2c8")
		game.f_px(J.add(v_x, 2.0), (J.add(v_y, v_h) - 3.0), "#e8b45a")
	else:
		game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), "#a8c6d4")
		game.f_px((J.add(v_x, v_w) - 3.0), J.add(v_y, 2.0), "#dff0fa")
	game.f_vl(J.add(v_x, floor((float(v_w) / float(2.0)))), J.add(v_y, 1.0), (v_h - 2.0), v_trim)
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, floor((float(v_h) / float(2.0)))), (v_w - 2.0), v_trim)
	game.f_hl((v_x - 1.0), (J.add(v_y, v_h) - 1.0), J.add(v_w, 2.0), "#e8e2d4")
	game.f_hl((v_x - 1.0), J.add(v_y, v_h), J.add(v_w, 2.0), game.character_draw.f_shadeCol(v_trim, 0.7))
	return null

# art.js:117
func f_drawBuilding(p_bx: Variant = null, p_by: Variant = null, p_bw: Variant = null, p_bh: Variant = null, p_i: Variant = null, p_gy: Variant = null, p_tarz: Variant = null, p_rakip: Variant = null) -> Variant:
	var v_B: Variant = null
	var v_top: Variant = null
	var v_d: Variant = null
	var v_gv: Variant = null
	var v_ym: Variant = null
	var v_yk: Variant = null
	var v_cb: Variant = null
	var v_cd: Variant = null
	var v_mk: Variant = null
	var v_bk: Variant = null
	var v_bd: Variant = null
	var v_sl: Variant = null
	var v_slx: Variant = null
	var v_slh: Variant = null
	var v_ax: Variant = null
	var v_ah: Variant = null
	var v_pk: Variant = null
	var v_sy0: Variant = null
	var v_ay0: Variant = null
	var v_tb: Variant = null
	var v_tbx: Variant = null
	var v_tby: Variant = null
	var v_tbh: Variant = null
	var v_tc: Variant = null
	var v_tp: Variant = null
	var v_chx: Variant = null
	var v_wtx: Variant = null
	var v_stx: Variant = null
	var v_atx: Variant = null
	var v_lx0: Variant = null
	var v_lx1: Variant = null
	var v_cw2: Variant = null
	var v_cx3: Variant = null
	var v_cols: Variant = null
	var v_step: Variant = null
	var v_floors: Variant = null
	var v_f: Variant = null
	var v_wy: Variant = null
	var v_c: Variant = null
	var v_wx: Variant = null
	var v_lit: Variant = null
	var v_byy: Variant = null
	var v_rr: Variant = null
	var v_pb: Variant = null
	var v_ay: Variant = null
	var v_gyy: Variant = null
	var v_lg: Variant = null
	var v_lv: Variant = null
	var v_kepenk: Variant = null
	var v_kk2: Variant = null
	var v_rf: Variant = null
	var v_qx: Variant = null
	var v_lw: Variant = null
	var v_s: Variant = null
	var v_ay2: Variant = null
	var v_sx2: Variant = null
	var v_band: Variant = null
	var v_col: Variant = null
	var v_wv: Variant = null
	var v_vy: Variant = null
	var v_vh: Variant = null
	var v_q: Variant = null
	var v_m: Variant = null
	var v_mx: Variant = null
	var v_dx0: Variant = null
	var v_bx: Variant = p_bx
	var v_by: Variant = p_by
	var v_bw: Variant = p_bw
	var v_bh: Variant = p_bh
	var v_i: Variant = p_i
	var v_gy: Variant = p_gy
	var v_tarz: Variant = p_tarz
	var v_rakip: Variant = p_rakip
	v_tarz = (v_tarz if J.truth(v_tarz) else "dukkan")
	v_B = J.getv((game.j_BLD_BETON if J.eq(v_tarz, "beton") else game.j_BLD), fmod(J.n(v_i), J.n(J.getv(game.j_BLD, "length"))))
	v_top = (v_by - v_bh)
	game.f_fr(v_bx, v_top, v_bw, v_bh, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.78))
	game.f_fr(v_bx, v_top, (v_bw - 1.0), v_bh, J.getv(v_B, "wall"))
	v_d = 0.0
	while J.lt(v_d, 26.0):
		J.setv(game.j_ctx, "globalAlpha", 0.07)
		game.f_hl(J.add(J.add(v_bx, 2.0), (game.f_hash1(J.add((v_i * 7.0), (v_d * 3.1))) * (v_bw - 8.0))), J.add(J.add(v_top, 3.0), (game.f_hash1(J.add((v_i * 3.0), (v_d * 5.7))) * (v_bh - 8.0))), J.add(3.0, (game.f_hash1(v_d) * 6.0)), ("#ffffff" if J.truth(fmod(J.n(v_d), J.n(2.0))) else "#000000"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_d = J.add(v_d, 1.0)
	if J.eq(v_tarz, "gokdelen"):
		v_gv = 3.0
		while J.lt(v_gv, (v_bw - 2.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.16)
			game.f_vl(J.add(v_bx, v_gv), J.add(v_top, 2.0), (v_bh - 4.0), "#ffffff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_gv = J.add(v_gv, 5.0)
		if J.gt(game.f_hash1((v_i * 6.7)), 0.45):
			v_ym = J.add(J.add(v_bx, 2.0), floor((game.f_hash1((v_i * 2.1)) * (v_bw - 8.0))))
			v_yk = J.add(v_top, 6.0)
			while J.lt(v_yk, (v_by - 4.0)):
				J.setv(game.j_ctx, "globalAlpha", 0.55)
				game.f_hl(v_ym, v_yk, 7.0, "#3a3f46")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				game.f_px(v_ym, J.add(v_yk, 1.0), "#4a5058")
				game.f_px(J.add(v_ym, 6.0), J.add(v_yk, 1.0), "#4a5058")
				v_yk = J.add(v_yk, 7.0)
	else:
		if J.eq(v_tarz, "cam"):
			v_cb = J.add(v_top, 2.0)
			while J.lt(v_cb, (v_by - 2.0)):
				J.setv(game.j_ctx, "globalAlpha", 0.26)
				game.f_hl(J.add(v_bx, 1.0), v_cb, (v_bw - 3.0), "#bfe4f2")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				J.setv(game.j_ctx, "globalAlpha", 0.14)
				game.f_hl(J.add(v_bx, 1.0), J.add(v_cb, 1.0), (v_bw - 3.0), "#2f6a8a")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				v_cb = J.add(v_cb, 3.0)
			J.setv(game.j_ctx, "globalAlpha", 0.18)
			v_cd = 0.0
			while J.lt(v_cd, v_bh):
				game.f_px(J.add(J.add(v_bx, 2.0), fmod(J.n((v_cd * 3.0)), J.n(max(1.0, (v_bw - 5.0))))), J.add(v_top, v_cd), "#ffffff")
				v_cd = J.add(v_cd, 2.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.eq(v_tarz, "mansart"):
				v_mk = 0.0
				while J.lt(v_mk, 5.0):
					game.f_fr(J.add(v_bx, v_mk), ((v_top - 4.0) - v_mk), (v_bw - (v_mk * 2.0)), 1.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.62))
					v_mk = J.add(v_mk, 1.0)
				if J.gt(v_bw, 24.0):
					game.f_fr((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 3.0), (v_top - 7.0), 6.0, 4.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.5))
					game.f_fr((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 2.0), (v_top - 6.0), 4.0, 3.0, "#8fb4c8")
			else:
				if J.eq(v_tarz, "beton"):
					J.setv(game.j_ctx, "globalAlpha", 0.55)
					game.f_fr(v_bx, v_top, (v_bw - 1.0), v_bh, "#6e7278")
					J.setv(game.j_ctx, "globalAlpha", 1.0)
					v_bk = J.add(v_top, 4.0)
					while J.lt(v_bk, (v_by - 2.0)):
						J.setv(game.j_ctx, "globalAlpha", 0.22)
						game.f_hl(J.add(v_bx, 1.0), v_bk, (v_bw - 3.0), "#3e4248")
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						J.setv(game.j_ctx, "globalAlpha", 0.12)
						game.f_hl(J.add(v_bx, 1.0), J.add(v_bk, 1.0), (v_bw - 3.0), "#c8ccd0")
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						v_bk = J.add(v_bk, 7.0)
					v_bd = 6.0
					while J.lt(v_bd, (v_bw - 4.0)):
						J.setv(game.j_ctx, "globalAlpha", 0.16)
						game.f_vl(J.add(v_bx, v_bd), J.add(v_top, 2.0), (v_bh - 4.0), "#2e3238")
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						v_bd = J.add(v_bd, 12.0)
					v_sl = 0.0
					while J.lt(v_sl, 3.0):
						if J.lt(game.f_hash1(J.add((v_i * 9.1), (v_sl * 4.3))), 0.45):
							v_sl = J.add(v_sl, 1.0)
							continue
						v_slx = J.add(J.add(v_bx, 3.0), floor((game.f_hash1(J.add((v_i * 2.7), v_sl)) * (v_bw - 8.0))))
						v_slh = J.add(6.0, floor((game.f_hash1(J.add((v_i * 5.1), v_sl)) * 14.0)))
						J.setv(game.j_ctx, "globalAlpha", 0.17)
						game.f_fr(v_slx, J.add(v_top, 1.0), 2.0, min(v_slh, (v_bh - 3.0)), "#2a2e34")
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						v_sl = J.add(v_sl, 1.0)
					if (J.gt(game.f_hash1((v_i * 13.7)), 0.52) and J.ge(v_bw, 26.0)):
						v_ax = J.add(v_bx, floor((float((v_bw - 14.0)) / float(2.0))))
						v_ah = min((v_bh - 6.0), J.add(20.0, floor((game.f_hash1((v_i * 3.9)) * 8.0))))
						game.f_fr(v_ax, J.add(v_top, 2.0), 14.0, v_ah, "#6e1a12")
						game.f_fr(v_ax, J.add(v_top, 2.0), 13.0, (v_ah - 1.0), "#9e2016")
						game.f_hl(v_ax, J.add(v_top, 2.0), 13.0, "#c0342a")
						v_pk = 0.0
						while J.lt(v_pk, 13.0):
							game.f_px(J.add(v_ax, v_pk), J.add(J.add(v_top, 2.0), v_ah), "#6e1a12")
							v_pk = J.add(v_pk, 3.0)
						v_sy0 = J.add(v_top, 6.0)
						game.f_px(J.add(v_ax, 6.0), v_sy0, "#e8dcb0")
						game.f_fr(J.add(v_ax, 4.0), J.add(v_sy0, 1.0), 5.0, 1.0, "#e8dcb0")
						game.f_fr(J.add(v_ax, 5.0), J.add(v_sy0, 2.0), 3.0, 1.0, "#e8dcb0")
						game.f_px(J.add(v_ax, 4.0), J.add(v_sy0, 3.0), "#e8dcb0")
						game.f_px(J.add(v_ax, 8.0), J.add(v_sy0, 3.0), "#e8dcb0")
						v_ay0 = J.add(v_sy0, 6.0)
						while J.lt(v_ay0, (J.add(v_top, v_ah) - 2.0)):
							J.setv(game.j_ctx, "globalAlpha", 0.55)
							game.f_hl(J.add(v_ax, 3.0), v_ay0, 8.0, "#e8dcb0")
							J.setv(game.j_ctx, "globalAlpha", 1.0)
							v_ay0 = J.add(v_ay0, 3.0)
				else:
					if J.eq(v_tarz, "tabela"):
						v_tb = 0.0
						while J.lt(v_tb, 3.0):
							if J.lt(game.f_hash1(J.add((v_i * 5.3), (v_tb * 2.7))), 0.42):
								v_tb = J.add(v_tb, 1.0)
								continue
							v_tbx = J.add(J.add(v_bx, 3.0), (v_tb * max(6.0, (float((v_bw - 8.0)) / float(3.0)))))
							v_tby = J.add(J.add(v_top, 4.0), floor((game.f_hash1(J.add(v_i, v_tb)) * 6.0)))
							v_tbh = J.add(8.0, floor((game.f_hash1(J.add((v_i * 3.1), v_tb)) * 10.0)))
							if J.gt(J.add(v_tby, v_tbh), (v_by - 6.0)):
								v_tbh = max(6.0, ((v_by - 6.0) - v_tby))
							v_tc = J.getv(["#e2483a", "#f0b03a", "#3fa8c0", "#8ac04a"], fmod(J.n(J.add(v_i, v_tb)), J.n(4.0)))
							game.f_fr(v_tbx, v_tby, 5.0, v_tbh, game.character_draw.f_shadeCol(v_tc, 0.55))
							game.f_fr(v_tbx, v_tby, 4.0, (v_tbh - 1.0), v_tc)
							v_tp = 2.0
							while J.lt(v_tp, (v_tbh - 1.0)):
								game.f_px(J.add(v_tbx, 1.0), J.add(v_tby, v_tp), "#ffffff")
								v_tp = J.add(v_tp, 3.0)
							v_tb = J.add(v_tb, 1.0)
	game.f_fr((v_bx - 2.0), (v_top - 4.0), J.add(v_bw, 4.0), 4.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.85))
	game.f_fr((v_bx - 2.0), (v_top - 4.0), J.add(v_bw, 4.0), 3.0, J.getv(v_B, "trim"))
	game.f_hl((v_bx - 2.0), (v_top - 4.0), J.add(v_bw, 4.0), game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 1.5))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl((v_bx - 1.0), v_top, J.add(v_bw, 2.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(game.f_hash1((v_i * 11.3)), 0.5):
		v_chx = J.add(J.add(v_bx, 6.0), floor((game.f_hash1((v_i * 2.2)) * (v_bw - 16.0))))
		game.f_fr(v_chx, (v_top - 11.0), 6.0, 7.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.8))
		game.f_fr(v_chx, (v_top - 11.0), 5.0, 7.0, J.getv(v_B, "trim"))
		game.f_fr((v_chx - 1.0), (v_top - 12.0), 8.0, 2.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 1.2))
	if J.gt(game.f_hash1((v_i * 4.7)), 0.45):
		v_wtx = ((J.add(v_bx, v_bw) - 16.0) - floor((game.f_hash1((v_i * 3.3)) * 8.0)))
		game.f_fr(v_wtx, (v_top - 9.0), 8.0, 5.0, "#7a6a58")
		game.f_fr(v_wtx, (v_top - 9.0), 7.0, 4.0, "#9a8a72")
		game.f_hl(v_wtx, (v_top - 9.0), 7.0, "#b8a88e")
		game.f_vl(J.add(v_wtx, 1.0), (v_top - 4.0), 3.0, "#5a4a3a")
		game.f_vl(J.add(v_wtx, 6.0), (v_top - 4.0), 3.0, "#5a4a3a")
	if J.gt(game.f_hash1((v_i * 8.9)), 0.55):
		v_stx = J.add(J.add(v_bx, 8.0), floor((game.f_hash1((v_i * 6.7)) * (v_bw - 20.0))))
		game.f_ell(v_stx, (v_top - 6.0), 3.0, 3.0, "#c9ccd0")
		game.f_ell(v_stx, (v_top - 6.0), 2.0, 2.0, "#e6e9ec")
		game.f_vl(v_stx, (v_top - 4.0), 4.0, "#8f979f")
		game.f_px(J.add(v_stx, 2.0), (v_top - 7.0), "#5a636b")
	if J.gt(game.f_hash1((v_i * 12.1)), 0.6):
		v_atx = J.add(J.add(v_bx, 4.0), floor((game.f_hash1((v_i * 9.9)) * (v_bw - 10.0))))
		game.f_vl(v_atx, (v_top - 12.0), 12.0, "#8f979f")
		game.f_hl((v_atx - 2.0), (v_top - 10.0), 5.0, "#8f979f")
		game.f_hl((v_atx - 2.0), (v_top - 7.0), 5.0, "#8f979f")
	if J.gt(game.f_hash1((v_i * 15.7)), 0.66):
		v_lx0 = J.add(v_bx, 5.0)
		v_lx1 = (J.add(v_bx, v_bw) - 6.0)
		J.setv(game.j_ctx, "globalAlpha", 0.5)
		game.f_hl(v_lx0, (v_top - 3.0), (v_lx1 - v_lx0), "#d8d0b8")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_cw2 = 0.0
		while J.lt(v_cw2, 4.0):
			v_cx3 = J.add(J.add(v_lx0, 4.0), (v_cw2 * max(5.0, floor((float(((v_lx1 - v_lx0) - 8.0)) / float(3.0))))))
			if J.gt(v_cx3, (v_lx1 - 3.0)):
				break
			game.f_fr(v_cx3, (v_top - 3.0), 3.0, 4.0, J.getv(game.j_PED_SHIRT, fmod(J.n(J.add((v_i * 3.0), v_cw2)), J.n(J.getv(game.j_PED_SHIRT, "length")))))
			v_cw2 = J.add(v_cw2, 1.0)
	v_cols = max(2.0, floor((float((v_bw - 6.0)) / float(14.0))))
	v_step = (float((v_bw - 6.0)) / float(v_cols))
	v_floors = floor((float((v_bh - 20.0)) / float(13.0)))
	v_f = 0.0
	while J.lt(v_f, v_floors):
		v_wy = J.add(J.add(v_top, 5.0), (v_f * 13.0))
		if J.gt(J.add(v_wy, 10.0), (v_by - 15.0)):
			break
		v_c = 0.0
		while J.lt(v_c, v_cols):
			v_wx = J.add(J.add(J.add(v_bx, 3.0), floor((v_c * v_step) + 0.5)), floor((float((v_step - 9.0)) / float(2.0)) + 0.5))
			v_lit = J.gt(game.f_hash1(J.add(J.add((v_i * 13.0), (v_f * 5.3)), (v_c * 2.7))), 0.52)
			game.building_draw.f_bldWindow(v_wx, v_wy, 9.0, 10.0, v_lit, J.getv(v_B, "trim"))
			v_c = J.add(v_c, 1.0)
		if (J.eq(v_f, 0.0) and J.gt(game.f_hash1((v_i * 6.1)), 0.55)):
			v_byy = J.add(v_wy, 11.0)
			game.f_fr(J.add(v_bx, 3.0), v_byy, (v_bw - 7.0), 2.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 1.1))
			v_rr = J.add(v_bx, 4.0)
			while J.lt(v_rr, (J.add(v_bx, v_bw) - 5.0)):
				game.f_vl(v_rr, (v_byy - 4.0), 4.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.9))
				v_rr = J.add(v_rr, 3.0)
			game.f_hl(J.add(v_bx, 3.0), (v_byy - 4.0), (v_bw - 7.0), game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 1.3))
		v_f = J.add(v_f, 1.0)
	if J.gt(game.f_hash1((v_i * 4.9)), 0.45):
		game.f_vl((J.add(v_bx, v_bw) - 3.0), v_top, v_bh, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.6))
		game.f_vl((J.add(v_bx, v_bw) - 2.0), v_top, v_bh, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 1.15))
		v_pb = J.add(v_top, 8.0)
		while J.lt(v_pb, v_by):
			game.f_fr((J.add(v_bx, v_bw) - 4.0), v_pb, 3.0, 2.0, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.55))
			v_pb = J.add(v_pb, 14.0)
	if J.gt(game.f_hash1((v_i * 8.7)), 0.6):
		v_ax = J.add(v_bx, 4.0)
		v_ay = J.add(v_top, 20.0)
		game.f_fr(v_ax, v_ay, 7.0, 5.0, "#8f979f")
		game.f_fr(v_ax, v_ay, 6.0, 4.0, "#c2c9d0")
		game.f_vl(J.add(v_ax, 2.0), J.add(v_ay, 1.0), 3.0, "#8f979f")
		game.f_vl(J.add(v_ax, 4.0), J.add(v_ay, 1.0), 3.0, "#8f979f")
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr(v_ax, J.add(v_ay, 5.0), 7.0, 1.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_gyy = (v_by - 15.0)
	if (J.eq(v_tarz, "gokdelen") or J.eq(v_tarz, "cam")):
		game.f_fr(J.add(v_bx, 1.0), (v_by - 15.0), (v_bw - 2.0), 15.0, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.62))
		v_lg = 2.0
		while J.lt(v_lg, (v_bw - 3.0)):
			game.f_fr(J.add(v_bx, v_lg), (v_by - 13.0), 4.0, 12.0, "#2b3a44")
			game.f_fr(J.add(v_bx, v_lg), (v_by - 13.0), 3.0, 11.0, "#4a7a92")
			J.setv(game.j_ctx, "globalAlpha", 0.35)
			game.f_hl(J.add(v_bx, v_lg), (v_by - 13.0), 3.0, "#bfe4f2")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_lg = J.add(v_lg, 5.0)
		game.f_fr((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 5.0), (v_by - 16.0), 11.0, 2.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.8))
		game.f_hl((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 5.0), (v_by - 16.0), 11.0, game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 1.3))
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr(v_bx, (v_by - 1.0), v_bw, 1.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		return null
	if J.eq(v_tarz, "beton"):
		game.f_fr(J.add(v_bx, 1.0), (v_gyy - 6.0), (v_bw - 2.0), 21.0, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.72))
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 7.0), 5.0, "#3e4248")
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 8.0), 4.0, J.getv(v_B, "sign"))
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		v_lv = J.add(v_bx, 6.0)
		while J.lt(v_lv, (J.add(v_bx, v_bw) - 9.0)):
			game.f_fr(v_lv, (v_gyy - 4.0), 3.0, 1.0, "#c8ccd0")
			v_lv = J.add(v_lv, 5.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_kepenk = J.gt(game.f_hash1((v_i * 7.7)), 0.45)
		if J.truth(v_kepenk):
			game.f_fr(J.add(v_bx, 3.0), v_gyy, (v_bw - 7.0), 14.0, "#4e5258")
			v_kk2 = J.add(v_gyy, 1.0)
			while J.lt(v_kk2, J.add(v_gyy, 14.0)):
				J.setv(game.j_ctx, "globalAlpha", 0.35)
				game.f_hl(J.add(v_bx, 3.0), v_kk2, (v_bw - 8.0), "#2e3238")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				v_kk2 = J.add(v_kk2, 2.0)
			game.f_fr(J.add(v_bx, 3.0), J.add(v_gyy, 13.0), (v_bw - 7.0), 2.0, "#33373d")
			game.f_fr((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 1.0), J.add(v_gyy, 12.0), 3.0, 3.0, "#7a7e84")
		else:
			game.f_fr(J.add(v_bx, 3.0), v_gyy, (v_bw - 7.0), 14.0, "#242830")
			J.setv(game.j_ctx, "globalAlpha", 0.5)
			v_rf = J.add(v_gyy, 3.0)
			while J.lt(v_rf, J.add(v_gyy, 12.0)):
				game.f_hl(J.add(v_bx, 5.0), v_rf, (v_bw - 11.0), "#4a4e54")
				v_rf = J.add(v_rf, 4.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_fr(J.add(v_bx, 5.0), J.add(v_gyy, 4.0), 5.0, 11.0, "#33373d")
			game.f_fr(J.add(v_bx, 5.0), J.add(v_gyy, 4.0), 4.0, 10.0, "#454a50")
			v_qx = J.add(v_bx, 12.0)
			if J.lt(J.add(v_qx, 12.0), (J.add(v_bx, v_bw) - 4.0)):
				game.f_fr(v_qx, J.add(v_gyy, 9.0), 1.0, 6.0, "#6a6e74")
				game.f_fr(J.add(v_qx, 11.0), J.add(v_gyy, 9.0), 1.0, 6.0, "#6a6e74")
				game.f_fr(v_qx, J.add(v_gyy, 10.0), 12.0, 1.0, "#7a7e84")
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr(v_bx, (v_by - 1.0), v_bw, 1.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		return null
	if J.truth(v_rakip):
		game.rival_building.f_rakipZemin(v_bx, v_by, v_bw, v_gyy, v_B, v_rakip)
		return null
	game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 5.0), 6.0, game.character_draw.f_shadeCol(J.getv(v_B, "sign"), 0.7))
	game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 6.0), 5.0, J.getv(v_B, "sign"))
	game.f_hl(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 6.0), game.character_draw.f_shadeCol(J.getv(v_B, "sign"), 1.4))
	v_lw = 4.0
	v_s = J.add(v_bx, 5.0)
	while J.lt(v_s, (J.add(v_bx, v_bw) - 6.0)):
		game.f_fr(v_s, (v_gyy - 4.0), min(v_lw, ((J.add(v_bx, v_bw) - 7.0) - v_s)), 2.0, ("#ffd77a" if J.gt(game.f_hash1(J.add((v_s * 1.7), v_i)), 0.5) else "#f2ece0"))
		v_s = J.add(v_s, J.add(v_lw, 2.0))
	v_ay2 = v_gyy
	v_sx2 = 0.0
	while J.lt(v_sx2, (v_bw - 4.0)):
		v_band = (int(J.n((int(J.n((float(v_sx2) / float(6.0)))) | int(J.n(0.0))))) & int(J.n(1.0)))
		v_col = (J.getv(v_B, "awn") if J.truth(v_band) else "#f2ece0")
		game.f_fr(J.add(J.add(v_bx, 2.0), v_sx2), v_ay2, 1.0, 5.0, v_col)
		v_wv = (1.0 if J.lt(fmod(J.n(v_sx2), J.n(6.0)), 3.0) else 0.0)
		if J.truth(v_wv):
			game.f_px(J.add(J.add(v_bx, 2.0), v_sx2), J.add(v_ay2, 5.0), v_col)
		v_sx2 = J.add(v_sx2, 1.0)
	game.f_hl(J.add(v_bx, 2.0), v_ay2, (v_bw - 4.0), "rgba(255,255,255,.4)")
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_fr(J.add(v_bx, 2.0), J.add(v_ay2, 6.0), (v_bw - 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_vy = J.add(v_ay2, 7.0)
	v_vh = ((v_by - v_vy) - 1.0)
	game.f_fr(J.add(v_bx, 3.0), v_vy, (v_bw - 7.0), v_vh, "#2f3d47")
	game.f_fr(J.add(v_bx, 4.0), J.add(v_vy, 1.0), (v_bw - 9.0), (v_vh - 2.0), ("#9fc0d0" if J.gt(game.f_hash1((v_i * 2.9)), 0.5) else "#b8ccd6"))
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	v_q = 0.0
	while J.lt(v_q, (v_vh - 2.0)):
		game.f_fr(J.add(J.add(v_bx, 6.0), v_q), J.add(J.add(v_vy, 1.0), v_q), 4.0, 1.0, "#ffffff")
		v_q = J.add(v_q, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_m = 0.0
	while J.lt(v_m, 3.0):
		v_mx = J.add(J.add(v_bx, 6.0), (v_m * 7.0))
		if J.gt(J.add(v_mx, 3.0), (J.add(v_bx, v_bw) - 6.0)):
			break
		game.f_fr(v_mx, (v_by - 4.0), 3.0, 3.0, J.getv(["#c0281c", "#e0a83a", "#3f8a4a"], fmod(J.n(J.add(v_i, v_m)), J.n(3.0))))
		v_m = J.add(v_m, 1.0)
	v_dx0 = (J.add(v_bx, v_bw) - 12.0)
	game.f_fr(v_dx0, v_vy, 9.0, J.add(v_vh, 1.0), game.character_draw.f_shadeCol(J.getv(v_B, "trim"), 0.7))
	game.f_fr(J.add(v_dx0, 1.0), J.add(v_vy, 1.0), 7.0, v_vh, "#7a5f42")
	game.f_fr(J.add(v_dx0, 2.0), J.add(v_vy, 2.0), 5.0, 5.0, "#a8c6d4")
	game.f_px(J.add(v_dx0, 6.0), J.add(v_vy, floor((v_vh * 0.6) + 0.5)), "#f0d78a")
	game.f_fr(J.add(v_bx, 2.0), v_by, (v_bw - 4.0), 1.0, "#cdd4da")
	return null

