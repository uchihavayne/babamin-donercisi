# Legacy order draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:186
func f_drawOrderBubble(p_c: Variant = null, p_t: Variant = null) -> Variant:
	var v_items: Variant = null
	var v_yokListe: Variant = null
	var v_yokKalem: Variant = null
	var v_yv: Variant = null
	var v_yy: Variant = null
	var v_yj: Variant = null
	var v_yokVar: Variant = null
	var v_yokCokKalem: Variant = null
	var v_YS: Variant = null
	var v_cw: Variant = null
	var v_bw: Variant = null
	var v_enGenis: Variant = null
	var v_yg: Variant = null
	var v_g: Variant = null
	var v_bh: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_sc: Variant = null
	var v_urgent: Variant = null
	var v_tailX: Variant = null
	var v_q: Variant = null
	var v_i2: Variant = null
	var v_it: Variant = null
	var v_cxx: Variant = null
	var v_iy: Variant = null
	var v_done: Variant = null
	var v_sbx: Variant = null
	var v_sby: Variant = null
	var v_sy: Variant = null
	var v_sh: Variant = null
	var v_ys: Variant = null
	var v_e: Variant = null
	var v_ry2: Variant = null
	var v_rx2: Variant = null
	var v_ik: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_pv: Variant = null
	var v_pc: Variant = null
	var v_ph: Variant = null
	var v_lw: Variant = null
	var v_lx: Variant = null
	var v_ly: Variant = null
	var v_c: Variant = p_c
	var v_t: Variant = p_t
	if J.le(J.getv(v_c, "bubble"), 0.02):
		return null
	v_items = J.getv(v_c, "items")
	v_yokListe = []
	v_yokKalem = {}
	v_yv = 0.0
	while J.lt(v_yv, J.getv(v_items, "length")):
		v_yy = J.getv(J.getv(v_items, v_yv), "yok")
		if ((not J.truth(v_yy)) or (not J.truth(J.getv(v_yy, "length")))):
			v_yv = J.add(v_yv, 1.0)
			continue
		J.setv(v_yokKalem, v_yv, 1.0)
		v_yj = 0.0
		while J.lt(v_yj, J.getv(v_yy, "length")):
			J.method(v_yokListe, "push", [{"kalem": v_yv, "m": J.getv(v_yy, v_yj)}])
			v_yj = J.add(v_yj, 1.0)
		v_yv = J.add(v_yv, 1.0)
	v_yokVar = J.gt(J.getv(v_yokListe, "length"), 0.0)
	v_yokCokKalem = J.gt(J.getv(J.keys(v_yokKalem), "length"), 1.0)
	v_YS = 14.0
	v_cw = 22.0
	v_bw = J.add((J.getv(v_items, "length") * v_cw), 8.0)
	if J.truth(v_yokVar):
		v_enGenis = 0.0
		v_yg = 0.0
		while J.lt(v_yg, J.getv(v_yokListe, "length")):
			v_g = J.add(J.add(17.0, game.f_textW(J.getv(game.j_SECIM_KISA, J.getv(J.getv(v_yokListe, v_yg), "m")))), (13.0 if J.truth(v_yokCokKalem) else 0.0))
			if J.gt(v_g, v_enGenis):
				v_enGenis = v_g
			v_yg = J.add(v_yg, 1.0)
		v_bw = max(v_bw, J.add(v_enGenis, 8.0))
	v_bh = (J.add(24.0, (J.getv(v_yokListe, "length") * v_YS)) if J.truth(v_yokVar) else 26.0)
	v_bx = floor((J.getv(v_c, "x") - (float(v_bw) / float(2.0))) + 0.5)
	v_by = floor(((J.getv(v_c, "y") - 56.0) - v_bh) + 0.5)
	v_bx = game.math_utils.f_clamp(v_bx, 2.0, ((game.j_W - v_bw) - 2.0))
	v_by = max(v_by, J.add(J.getv(game.j_VIEW, "top"), 3.0))
	v_sc = game.math_utils.f_easeOutBack(game.math_utils.f_clamp(J.getv(v_c, "bubble"), 0.0, 1.0))
	if J.lt(v_sc, 0.99):
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [J.add(v_bx, (float(v_bw) / float(2.0))), J.add(v_by, v_bh)])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(J.add(v_bx, (float(v_bw) / float(2.0))))), (-J.n(J.add(v_by, v_bh)))])
	v_urgent = J.lt(J.getv(v_c, "patience"), 0.3)
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_rrect(J.add(v_bx, 1.0), J.add(v_by, 3.0), v_bw, v_bh, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_bx, v_by, v_bw, v_bh, 4.0, (J.getv(game.j_P, "bad") if J.truth(v_urgent) else J.getv(game.j_P, "ui4")))
	game.f_rrect(J.add(v_bx, 1.0), J.add(v_by, 1.0), (v_bw - 2.0), (v_bh - 2.0), 3.0, ("#f7ded6" if J.truth(v_urgent) else J.getv(game.j_P, "ui0")))
	game.f_hl(J.add(v_bx, 4.0), J.add(v_by, 2.0), (v_bw - 8.0), "#ffffff")
	v_tailX = game.math_utils.f_clamp(J.getv(v_c, "x"), J.add(v_bx, 6.0), (J.add(v_bx, v_bw) - 8.0))
	v_q = 0.0
	while J.lt(v_q, 5.0):
		game.f_fr(J.add((v_tailX - 3.0), v_q), J.add((J.add(v_by, v_bh) - 1.0), v_q), (6.0 - v_q), 1.0, ("#f7ded6" if J.truth(v_urgent) else J.getv(game.j_P, "ui0")))
		game.f_px(J.add((v_tailX - 3.0), v_q), J.add((J.add(v_by, v_bh) - 1.0), v_q), (J.getv(game.j_P, "bad") if J.truth(v_urgent) else J.getv(game.j_P, "ui4")))
		game.f_px(J.add(v_tailX, 2.0), J.add((J.add(v_by, v_bh) - 1.0), v_q), (J.getv(game.j_P, "bad") if J.truth(v_urgent) else J.getv(game.j_P, "ui4")))
		v_q = J.add(v_q, 1.0)
	v_i2 = 0.0
	while J.lt(v_i2, J.getv(v_items, "length")):
		v_it = J.getv(v_items, v_i2)
		v_cxx = (J.add(J.add(J.add(v_bx, 4.0), (v_i2 * v_cw)), (float(v_cw) / float(2.0))) - 1.0)
		v_iy = J.add(v_by, (13.0 if J.truth(v_yokVar) else J.add((float(v_bh) / float(2.0)), 1.0)))
		v_done = J.getv(J.getv(v_c, "done"), v_i2)
		if J.gt(v_i2, 0.0):
			J.setv(game.j_ctx, "globalAlpha", 0.25)
			game.f_vl((J.add(J.add(v_bx, 4.0), (v_i2 * v_cw)) - 2.0), J.add(v_by, 5.0), (v_bh - 10.0), J.getv(game.j_P, "ui2"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.truth(v_done):
			J.setv(game.j_ctx, "globalAlpha", 0.28)
		if J.eq(J.getv(v_it, "kind"), "wrap"):
			game.icon_draw.f_icon("wrap", v_cxx, v_iy, v_t)
		else:
			if J.eq(J.getv(v_it, "kind"), "plate"):
				game.icon_draw.f_icon("iskender", v_cxx, v_iy, v_t)
			else:
				if J.eq(J.getv(v_it, "kind"), "drink"):
					game.icon_draw.f_icon(J.getv(v_it, "type"), v_cxx, v_iy, v_t)
				else:
					if J.eq(J.getv(v_it, "kind"), "fbox"):
						game.icon_draw.f_icon("fbox", v_cxx, (v_iy - 1.0), v_t)
					else:
						if J.eq(J.getv(v_it, "kind"), "sweet"):
							game.icon_draw.f_icon("sweet", v_cxx, v_iy, v_t)
		if (J.eq(J.getv(v_it, "kind"), "wrap") and J.truth(J.getv(v_it, "sauce"))):
			v_sbx = J.add(v_cxx, 7.0)
			v_sby = (v_iy - 7.0)
			game.f_disc(v_sbx, v_sby, 5.0, "#2a2018")
			game.f_disc(v_sbx, v_sby, 4.0, ("#c0281c" if J.eq(J.getv(v_it, "sauce"), "hot") else "#e6dfc8"))
			if J.eq(J.getv(v_it, "sauce"), "hot"):
				game.f_ell(v_sbx, J.add(v_sby, 1.0), 2.0, 3.0, "#8e1c14")
				game.f_ell((v_sbx - 1.0), J.add(v_sby, 1.0), 2.0, 3.0, "#ff7a62")
				game.f_px(v_sbx, (v_sby - 3.0), "#5a8a2a")
				game.f_px(J.add(v_sbx, 1.0), (v_sby - 4.0), "#4a7a20")
			else:
				game.f_ell(v_sbx, J.add(v_sby, 1.0), 3.0, 3.0, "#ffffff")
				game.f_px((v_sbx - 1.0), v_sby, "#cfc7b2")
				game.f_px((v_sbx - 1.0), J.add(v_sby, 1.0), "#cfc7b2")
				game.f_px(J.add(v_sbx, 1.0), v_sby, "#cfc7b2")
				game.f_px(J.add(v_sbx, 1.0), J.add(v_sby, 1.0), "#cfc7b2")
				game.f_px(v_sbx, (v_sby - 3.0), "#a89a78")
				game.f_px(v_sbx, (v_sby - 4.0), "#8a8060")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.truth(v_done):
			game.icon_draw.f_drawCheck(v_cxx, v_iy, J.getv(game.j_P, "ok"))
		v_i2 = J.add(v_i2, 1.0)
	if J.truth(v_yokVar):
		v_sy = J.add(v_by, 22.0)
		v_sh = (J.getv(v_yokListe, "length") * v_YS)
		game.f_fr(J.add(v_bx, 3.0), (v_sy - 2.0), (v_bw - 6.0), 1.0, "rgba(90,60,40,.35)")
		game.f_rrect(J.add(v_bx, 3.0), v_sy, (v_bw - 6.0), v_sh, 2.0, "#8e1c14")
		game.f_rrect(J.add(v_bx, 3.0), v_sy, (v_bw - 6.0), (v_sh - 1.0), 2.0, "#b02a1e")
		game.f_hl(J.add(v_bx, 5.0), J.add(v_sy, 1.0), (v_bw - 10.0), "#d24a38")
		v_ys = 0.0
		while J.lt(v_ys, J.getv(v_yokListe, "length")):
			v_e = J.getv(v_yokListe, v_ys)
			v_ry2 = (J.add(J.add(v_sy, (v_ys * v_YS)), (float(v_YS) / float(2.0))) - 1.0)
			v_rx2 = J.add(v_bx, 11.0)
			if J.truth(v_yokCokKalem):
				v_ik = J.getv(v_items, J.getv(v_e, "kalem"))
				game.icon_draw.f_icon(("iskender" if J.eq(J.getv(v_ik, "kind"), "plate") else (J.getv(v_ik, "type") if J.eq(J.getv(v_ik, "kind"), "drink") else J.getv(v_ik, "kind"))), v_rx2, v_ry2, v_t)
				v_rx2 = J.add(v_rx2, 13.0)
			game.legacy_order_draw.f_yokRozet(v_rx2, v_ry2, J.getv(v_e, "m"))
			game.text_draw.f_txt(J.getv(game.j_SECIM_KISA, J.getv(v_e, "m")), J.add(v_rx2, 9.0), (v_ry2 - 4.0), "#ffe0d4", {"shadow": 1.0})
			v_ys = J.add(v_ys, 1.0)
	if J.lt(v_sc, 0.99):
		J.method(game.j_ctx, "restore", [])
	v_px0 = (J.getv(v_c, "x") - 26.0)
	v_py0 = (J.getv(v_c, "y") - 52.0)
	v_pv = game.math_utils.f_clamp(J.getv(v_c, "patience"), 0.0, 1.0)
	v_pc = (J.getv(game.j_P, "ok") if J.gt(v_pv, 0.5) else (J.getv(game.j_P, "warn") if J.gt(v_pv, 0.25) else J.getv(game.j_P, "bad")))
	game.f_rrect((v_px0 - 1.0), (v_py0 - 1.0), 7.0, 26.0, 2.0, "rgba(20,14,12,.65)")
	v_ph = floor((23.0 * v_pv) + 0.5)
	game.f_fr(J.add(v_px0, 1.0), (J.add(v_py0, 23.0) - v_ph), 4.0, v_ph, v_pc)
	game.f_hl(J.add(v_px0, 1.0), (J.add(v_py0, 23.0) - v_ph), 4.0, "rgba(255,255,255,.55)")
	game.icon_draw.f_drawHeart(J.add(v_px0, 2.0), J.add(v_py0, 28.0), 1.0, ("#e2483a" if J.gt(v_pv, 0.25) else ("#ff8a7a" if J.gt(sin((v_t * 12.0)), 0.0) else "#8a2018")))
	if J.gt(J.getv(v_c, "lineT"), 0.0):
		v_lw = J.add(game.f_textW(J.getv(v_c, "line")), 8.0)
		v_lx = game.math_utils.f_clamp((J.getv(v_c, "x") - (float(v_lw) / float(2.0))), 2.0, ((game.j_W - v_lw) - 2.0))
		v_ly = (J.getv(v_c, "y") - 74.0)
		J.setv(game.j_ctx, "globalAlpha", min(1.0, (J.getv(v_c, "lineT") * 2.0)))
		game.f_rrect(v_lx, v_ly, v_lw, 12.0, 3.0, (J.getv(game.j_P, "bad") if J.eq(J.getv(v_c, "mood"), "angry") else J.getv(game.j_P, "white")))
		game.f_rrectOut(v_lx, v_ly, v_lw, 12.0, 3.0, J.getv(game.j_P, "ui5"))
		game.text_draw.f_txt(J.getv(v_c, "line"), J.add(v_lx, 4.0), J.add(v_ly, 2.0), (J.getv(game.j_P, "white") if J.eq(J.getv(v_c, "mood"), "angry") else J.getv(game.j_P, "ink")))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(J.getv(v_c, "wrongT"), 0.0):
		J.setv(game.j_ctx, "globalAlpha", min(1.0, (J.getv(v_c, "wrongT") * 2.0)))
		game.icon_draw.f_drawX(J.getv(v_c, "x"), (J.getv(v_c, "y") - 32.0), J.getv(game.j_P, "bad"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# ui.js:319
func f_iconChip(p_kind: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_col: Variant = null
	var v_col2: Variant = null
	var v_kind: Variant = p_kind
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	if J.eq(v_kind, "pickle"):
		v_col = J.getv(game.j_P, "g2")
		v_col2 = J.getv(game.j_P, "g0")
	else:
		if J.eq(v_kind, "sauce"):
			v_col = "#e8e2cc"
			v_col2 = "#ffffff"
		else:
			if J.eq(v_kind, "hot"):
				v_col = "#d8352c"
				v_col2 = "#ff7a60"
			else:
				if J.eq(v_kind, "fries"):
					v_col = J.getv(game.j_P, "p2")
					v_col2 = J.getv(game.j_P, "p0")
				else:
					v_col = J.getv(game.j_P, "m3")
					v_col2 = J.getv(game.j_P, "m1")
	game.f_rrect((v_x - 4.0), (v_y - 4.0), 8.0, 8.0, 2.0, J.getv(game.j_P, "ui4"))
	game.f_rrect((v_x - 3.0), (v_y - 3.0), 6.0, 6.0, 2.0, v_col)
	if J.eq(v_kind, "pickle"):
		game.f_px((v_x - 1.0), (v_y - 1.0), v_col2)
		game.f_px(J.add(v_x, 1.0), v_y, v_col2)
		game.f_px(v_x, J.add(v_y, 1.0), v_col2)
	else:
		if J.eq(v_kind, "sauce"):
			game.f_hl((v_x - 2.0), (v_y - 1.0), 4.0, v_col2)
			game.f_px((v_x - 1.0), J.add(v_y, 1.0), v_col2)
		else:
			if J.eq(v_kind, "hot"):
				game.f_px(v_x, (v_y - 2.0), v_col2)
				game.f_px((v_x - 1.0), v_y, v_col2)
				game.f_px(J.add(v_x, 1.0), J.add(v_y, 1.0), v_col2)
			else:
				if J.eq(v_kind, "fries"):
					game.f_vl((v_x - 1.0), (v_y - 2.0), 4.0, v_col2)
					game.f_vl(J.add(v_x, 1.0), (v_y - 1.0), 3.0, v_col2)
				else:
					game.f_hl((v_x - 2.0), (v_y - 1.0), 4.0, v_col2)
	return null

# ui.js:2966
func f_yokCip(p_x: Variant = null, p_y: Variant = null, p_m: Variant = null) -> Variant:
	var v_renk: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_m: Variant = p_m
	v_renk = ("#5a9a2c" if J.eq(v_m, "pickle") else ("#f4f8fb" if J.eq(v_m, "yogurt") else "#f0c04a"))
	game.f_disc(v_x, v_y, 4.0, "#c0281c")
	game.f_disc(v_x, v_y, 3.0, v_renk)
	if J.eq(v_m, "pickle"):
		game.f_px((v_x - 1.0), (v_y - 1.0), "#bfe07a")
		game.f_px(J.add(v_x, 1.0), v_y, "#bfe07a")
	else:
		if J.eq(v_m, "yogurt"):
			game.f_px((v_x - 1.0), J.add(v_y, 1.0), "#cdd8e2")
		else:
			game.f_px((v_x - 1.0), (v_y - 1.0), "#ffe6a0")
			game.f_px(J.add(v_x, 1.0), J.add(v_y, 1.0), "#d99a2e")
	game.f_ln((v_x - 3.0), (v_y - 3.0), J.add(v_x, 3.0), J.add(v_y, 3.0), "#c0281c")
	game.f_px((v_x - 3.0), (v_y - 3.0), "#e2483a")
	game.f_px(J.add(v_x, 3.0), J.add(v_y, 3.0), "#e2483a")
	return null

# ui.js:2976
func f_sosCip(p_x: Variant = null, p_y: Variant = null, p_tip: Variant = null) -> Variant:
	var v_renk: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_tip: Variant = p_tip
	v_renk = ("#d8352c" if J.eq(v_tip, "hot") else ("#efe7d2" if J.eq(v_tip, "garlic") else "#f0b83c"))
	game.f_disc(v_x, v_y, 4.0, "#2a2018")
	game.f_disc(v_x, v_y, 3.0, v_renk)
	game.f_px((v_x - 1.0), (v_y - 1.0), ("#ff8a70" if J.eq(v_tip, "hot") else "#ffffff"))
	game.f_px(J.add(v_x, 1.0), J.add(v_y, 1.0), ("#8e1c14" if J.eq(v_tip, "hot") else "#c9bfa4"))
	return null

# ui.js:2983
func f_wrapEtiket(p_cx: Variant = null, p_y: Variant = null, p_w: Variant = null, p_dar: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_ad: Variant = null
	var v_tw: Variant = null
	var v_x0: Variant = null
	var v_i: Variant = null
	var v_cxi: Variant = null
	var v_cx: Variant = p_cx
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_dar: Variant = p_dar
	v_d = (game.f_wrapKimlik(v_w) if J.eq(J.kind(J.ref(game.f_wrapKimlik, 1)), "function") else null)
	if ((not J.truth(v_d)) or (not J.truth(J.getv(v_d, "length")))):
		return null
	v_ad = (9.0 if J.truth(v_dar) else 11.0)
	v_tw = J.add((J.getv(v_d, "length") * v_ad), 3.0)
	v_x0 = floor((v_cx - (float(v_tw) / float(2.0))) + 0.5)
	game.f_rrect(v_x0, v_y, v_tw, 11.0, 3.0, "rgba(18,12,9,.88)")
	game.f_rrectOut(v_x0, v_y, v_tw, 11.0, 3.0, "rgba(255,220,140,.30)")
	v_i = 0.0
	while J.lt(v_i, J.getv(v_d, "length")):
		v_cxi = J.add(J.add(J.add(v_x0, 2.0), (v_i * v_ad)), (float((v_ad - 1.0)) / float(2.0)))
		if J.eq(J.getv(J.getv(v_d, v_i), "tip"), "sos"):
			game.legacy_order_draw.f_sosCip(v_cxi, J.add(v_y, 5.0), J.getv(J.getv(v_d, v_i), "m"))
		else:
			game.legacy_order_draw.f_yokCip(v_cxi, J.add(v_y, 5.0), J.getv(J.getv(v_d, v_i), "m"))
		v_i = J.add(v_i, 1.0)
	return null

# ui.js:3004
func f_yokRozet(p_x: Variant = null, p_y: Variant = null, p_m: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_m: Variant = p_m
	game.f_disc(v_x, v_y, 6.0, "#c0281c")
	game.f_disc(v_x, v_y, 4.0, "#f7efdc")
	if J.eq(v_m, "pickle"):
		game.f_ell(v_x, v_y, 4.0, 3.0, "#4a7a22")
		game.f_ell(v_x, v_y, 3.0, 2.0, "#6aa032")
		game.f_px((v_x - 1.0), (v_y - 1.0), "#bfe07a")
		game.f_px(J.add(v_x, 1.0), v_y, "#bfe07a")
		game.f_px(v_x, J.add(v_y, 1.0), "#bfe07a")
	else:
		if J.eq(v_m, "yogurt"):
			game.f_ell(v_x, J.add(v_y, 1.0), 4.0, 2.0, "#e8eef4")
			game.f_ell(v_x, (v_y - 1.0), 3.0, 2.0, "#ffffff")
			game.f_px((v_x - 2.0), J.add(v_y, 1.0), "#cdd8e2")
			game.f_px(J.add(v_x, 2.0), J.add(v_y, 1.0), "#cdd8e2")
		else:
			game.f_fr((v_x - 3.0), (v_y - 2.0), 2.0, 5.0, "#d99a2e")
			game.f_fr(v_x, (v_y - 3.0), 2.0, 6.0, "#f4cc60")
			game.f_fr(J.add(v_x, 2.0), (v_y - 1.0), 2.0, 4.0, "#e8b64a")
			game.f_px(v_x, (v_y - 3.0), "#ffe6a0")
	game.f_ln((v_x - 4.0), (v_y - 4.0), J.add(v_x, 4.0), J.add(v_y, 4.0), "#c0281c")
	game.f_ln((v_x - 3.0), (v_y - 4.0), J.add(v_x, 4.0), J.add(v_y, 3.0), "#e2483a")
	game.f_ring(v_x, v_y, 6.0, "#8e1c14")
	return null
