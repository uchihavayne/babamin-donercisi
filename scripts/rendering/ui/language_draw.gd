# Language draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:349
func f_bayrakCiz(p_kod: Variant = null, p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_b: Variant = null
	var v_cy: Variant = null
	var v_r: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_d: Variant = null
	var v_c: Variant = null
	var v_mx: Variant = null
	var v_my: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_yy: Variant = null
	var v_t2: Variant = null
	var v_ww: Variant = null
	var v_kod: Variant = p_kod
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	v_b = max(1.0, floor((float(v_h) / float(3.0)) + 0.5))
	if J.eq(v_kod, "tr"):
		game.f_fr(v_x, v_y, v_w, v_h, "#c0281c")
		v_cy = J.add(v_y, (float(v_h) / float(2.0)))
		v_r = max(2.0, floor((v_h * 0.32) + 0.5))
		game.f_ell(J.add(v_x, (v_w * 0.38)), v_cy, v_r, v_r, "#ffffff")
		game.f_ell(J.add(J.add(v_x, (v_w * 0.38)), max(1.0, (v_r * 0.35))), v_cy, (v_r * 0.78), (v_r * 0.78), "#c0281c")
		v_sx = floor(J.add(v_x, (v_w * 0.62)) + 0.5)
		v_sy = floor(v_cy + 0.5)
		game.f_px(v_sx, (v_sy - 1.0), "#ffffff")
		game.f_px((v_sx - 1.0), v_sy, "#ffffff")
		game.f_px(v_sx, v_sy, "#ffffff")
		game.f_px(J.add(v_sx, 1.0), v_sy, "#ffffff")
		game.f_px(v_sx, J.add(v_sy, 1.0), "#ffffff")
	else:
		if J.eq(v_kod, "gb"):
			game.f_fr(v_x, v_y, v_w, v_h, "#1a2a6c")
			v_d = 0.0
			while J.lt(v_d, v_h):
				game.f_px(J.add(v_x, floor((float((v_d * (v_w - 1.0))) / float((v_h - 1.0))) + 0.5)), J.add(v_y, v_d), "#ffffff")
				game.f_px(((J.add(v_x, v_w) - 1.0) - floor((float((v_d * (v_w - 1.0))) / float((v_h - 1.0))) + 0.5)), J.add(v_y, v_d), "#ffffff")
				v_d = J.add(v_d, 1.0)
			game.f_fr(v_x, (J.add(v_y, floor((float(v_h) / float(2.0)) + 0.5)) - 1.0), v_w, 2.0, "#ffffff")
			game.f_fr((J.add(v_x, floor((float(v_w) / float(2.0)) + 0.5)) - 1.0), v_y, 2.0, v_h, "#ffffff")
			game.f_fr(v_x, J.add(v_y, floor((float(v_h) / float(2.0)) + 0.5)), v_w, 1.0, "#c0281c")
			game.f_fr(J.add(v_x, floor((float(v_w) / float(2.0)) + 0.5)), v_y, 1.0, v_h, "#c0281c")
		else:
			if J.eq(v_kod, "de"):
				game.f_fr(v_x, v_y, v_w, v_b, "#141414")
				game.f_fr(v_x, J.add(v_y, v_b), v_w, v_b, "#c0281c")
				game.f_fr(v_x, J.add(v_y, (v_b * 2.0)), v_w, (v_h - (v_b * 2.0)), "#e8b800")
			else:
				if J.eq(v_kod, "es"):
					game.f_fr(v_x, v_y, v_w, v_h, "#c8102e")
					game.f_fr(v_x, J.add(v_y, v_b), v_w, (v_h - (v_b * 2.0)), "#f0c020")
					game.f_fr(J.add(v_x, floor((v_w * 0.26) + 0.5)), J.add(J.add(v_y, v_b), 1.0), 2.0, max(1.0, ((v_h - (v_b * 2.0)) - 2.0)), "#a8202a")
				else:
					if J.eq(v_kod, "fr"):
						v_c = floor((float(v_w) / float(3.0)) + 0.5)
						game.f_fr(v_x, v_y, v_c, v_h, "#1a3a8c")
						game.f_fr(J.add(v_x, v_c), v_y, (v_w - (v_c * 2.0)), v_h, "#ffffff")
						game.f_fr((J.add(v_x, v_w) - v_c), v_y, v_c, v_h, "#c8102e")
					else:
						if J.eq(v_kod, "br"):
							game.f_fr(v_x, v_y, v_w, v_h, "#1a8a3c")
							v_mx = J.add(v_x, (float(v_w) / float(2.0)))
							v_my = J.add(v_y, (float(v_h) / float(2.0)))
							v_rx = (v_w * 0.38)
							v_ry = (v_h * 0.38)
							v_yy = 0.0
							while J.lt(v_yy, v_h):
								v_t2 = (1.0 - (float(abs((J.add(v_yy, 0.5) - (float(v_h) / float(2.0))))) / float(v_ry)))
								if J.le(v_t2, 0.0):
									v_yy = J.add(v_yy, 1.0)
									continue
								v_ww = max(1.0, floor(((v_rx * v_t2) * 2.0) + 0.5))
								game.f_fr(floor((v_mx - (float(v_ww) / float(2.0))) + 0.5), J.add(v_y, v_yy), v_ww, 1.0, "#f0d020")
								v_yy = J.add(v_yy, 1.0)
							game.f_ell(v_mx, v_my, max(2.0, (v_h * 0.2)), max(2.0, (v_h * 0.2)), "#1a3a8c")
	game.f_rc(v_x, v_y, v_w, v_h, "rgba(0,0,0,.55)")
	return null

# ui.js:401
func f_dilOk(p_cx: Variant = null, p_cy: Variant = null, p_yon: Variant = null, p_col: Variant = null) -> Variant:
	var v_r: Variant = null
	var v_w: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_yon: Variant = p_yon
	var v_col: Variant = p_col
	v_r = (-J.n(3.0))
	while J.le(v_r, 3.0):
		v_w = (4.0 - abs(v_r))
		if J.le(v_w, 0.0):
			v_r = J.add(v_r, 1.0)
			continue
		game.f_hl(((v_cx - 2.0) if J.gt(v_yon, 0.0) else (J.add(v_cx, 3.0) - v_w)), J.add(v_cy, v_r), v_w, v_col)
		v_r = J.add(v_r, 1.0)
	return null

# ui.js:409
func f_langButtons(p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_kod: Variant = null
	var v_simdi: Variant = null
	var v_t: Variant = null
	var v_dt: Variant = null
	var v_k: Variant = null
	var v_s: Variant = null
	var v_SW: Variant = null
	var v_SH: Variant = null
	var v_ADIM: Variant = null
	var v_x0: Variant = null
	var v_y0: Variant = null
	var v_cx: Variant = null
	var v_hx: Variant = null
	var v_gx0: Variant = null
	var v_gw: Variant = null
	var v_tiklanan: Variant = null
	var v_dx: Variant = null
	var v_yak: Variant = null
	var v_fw: Variant = null
	var v_fh: Variant = null
	var v_fx: Variant = null
	var v_fy: Variant = null
	var v_pul: Variant = null
	var v_otur: Variant = null
	var v_ad: Variant = null
	var v_solVar: Variant = null
	var v_sagVar: Variant = null
	var v_solUz: Variant = null
	var v_sagUz: Variant = null
	var v_yeni: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	v_n = J.getv(game.j_DILLER, "length")
	v_simdi = 0.0
	v_i = 0.0
	while J.lt(v_i, v_n):
		if J.eq(J.getv(J.getv(game.j_DILLER, v_i), "kod"), game.j_LANG):
			v_simdi = v_i
		v_i = J.add(v_i, 1.0)
	if J.lt(J.getv(game.j_DILUI, "anim"), 0.0):
		J.setv(game.j_DILUI, "anim", v_simdi)
		J.setv(game.j_DILUI, "hedef", v_simdi)
	if (not J.eq(J.getv(game.j_DILUI, "hedef"), v_simdi) and J.lt(abs((J.getv(game.j_DILUI, "anim") - J.getv(game.j_DILUI, "hedef"))), 0.01)):
		J.setv(game.j_DILUI, "hedef", v_simdi)
	v_t = (float(game.clock_ms) / float(1000.0))
	v_dt = (0.0 if J.lt(J.getv(game.j_DILUI, "son"), 0.0) else min(0.05, (v_t - J.getv(game.j_DILUI, "son"))))
	J.setv(game.j_DILUI, "son", v_t)
	v_k = 190.0
	v_s = 24.0
	J.setv(game.j_DILUI, "hiz", J.add(J.getv(game.j_DILUI, "hiz"), ((((J.getv(game.j_DILUI, "hedef") - J.getv(game.j_DILUI, "anim")) * v_k) - (J.getv(game.j_DILUI, "hiz") * v_s)) * v_dt)))
	J.setv(game.j_DILUI, "anim", J.add(J.getv(game.j_DILUI, "anim"), (J.getv(game.j_DILUI, "hiz") * v_dt)))
	if (J.lt(abs((J.getv(game.j_DILUI, "hedef") - J.getv(game.j_DILUI, "anim"))), 0.002) and J.lt(abs(J.getv(game.j_DILUI, "hiz")), 0.02)):
		J.setv(game.j_DILUI, "anim", J.getv(game.j_DILUI, "hedef"))
		J.setv(game.j_DILUI, "hiz", 0.0)
	J.setv(game.j_DILUI, "parla", max(0.0, (J.getv(game.j_DILUI, "parla") - (v_dt * 3.2))))
	v_SW = 172.0
	v_SH = 34.0
	v_ADIM = 30.0
	v_x0 = floor(v_x + 0.5)
	v_y0 = floor(v_y + 0.5)
	v_cx = J.add(v_x0, (float(v_SW) / float(2.0)))
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_rrect(J.add(v_x0, 1.0), J.add(v_y0, 2.0), v_SW, v_SH, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_x0, v_y0, v_SW, v_SH, 4.0, "#241b15")
	game.f_rrect(J.add(v_x0, 1.0), J.add(v_y0, 1.0), (v_SW - 2.0), (v_SH - 3.0), 4.0, "#171009")
	game.f_rrectOut(v_x0, v_y0, v_SW, v_SH, 4.0, J.getv(game.j_P, "ui5"))
	v_i = 0.0
	while J.lt(v_i, 11.0):
		v_hx = J.add(J.add(v_x0, 8.0), (v_i * 15.0))
		game.f_fr(v_hx, J.add(v_y0, 2.0), 3.0, 2.0, "#0c0805")
		game.f_fr(v_hx, (J.add(v_y0, v_SH) - 4.0), 3.0, 2.0, "#0c0805")
		v_i = J.add(v_i, 1.0)
	v_gx0 = J.add(v_x0, 15.0)
	v_gw = (v_SW - 30.0)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [v_gx0, J.add(v_y0, 4.0), v_gw, (v_SH - 8.0)])
	J.method(game.j_ctx, "clip", [])
	v_tiklanan = (-J.n(1.0))
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_dx = ((v_i - J.getv(game.j_DILUI, "anim")) * v_ADIM)
		if J.gt(abs(v_dx), J.add((float(v_gw) / float(2.0)), v_ADIM)):
			v_i = J.add(v_i, 1.0)
			continue
		v_yak = game.math_utils.f_clamp((1.0 - (float(abs(v_dx)) / float(v_ADIM))), 0.0, 1.0)
		v_fw = floor(J.add(13.0, (9.0 * v_yak)) + 0.5)
		v_fh = floor(J.add(9.0, (5.0 * v_yak)) + 0.5)
		v_fx = floor((J.add(v_cx, v_dx) - (float(v_fw) / float(2.0))) + 0.5)
		v_fy = floor(J.add(J.add(v_y0, 6.0), ((1.0 - v_yak) * 3.0)) + 0.5)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.34, (0.66 * v_yak)))
		if J.gt(v_yak, 0.55):
			J.setv(game.j_ctx, "globalAlpha", (float((0.3 * (v_yak - 0.55))) / float(0.45)))
			game.f_rrect((v_fx - 2.0), (v_fy - 2.0), J.add(v_fw, 4.0), J.add(v_fh, 4.0), 2.0, J.getv(game.j_P, "au0"))
			J.setv(game.j_ctx, "globalAlpha", J.add(0.34, (0.66 * v_yak)))
		game.language_draw.f_bayrakCiz(J.getv(J.getv(game.j_DILLER, v_i), "bayrak"), v_fx, v_fy, v_fw, v_fh)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.lt(v_yak, 0.5):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.5 * v_yak)))
			game.text_draw.f_txt(J.method(J.getv(J.getv(game.j_DILLER, v_i), "kod"), "toUpperCase", []), floor(J.add(v_cx, v_dx) + 0.5), J.add(J.add(v_fy, v_fh), 2.0), J.getv(game.j_P, "ui1"), {"align": "c"})
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if ((J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.add(v_cx, v_dx) - (float(v_ADIM) / float(2.0))), v_y0, v_ADIM, v_SH)) and J.gt(J.getv(game.j_IN, "x"), v_gx0)) and J.lt(J.getv(game.j_IN, "x"), J.add(v_gx0, v_gw))):
			v_tiklanan = v_i
		v_i = J.add(v_i, 1.0)
	J.method(game.j_ctx, "restore", [])
	v_pul = J.add(0.55, (0.25 * sin((v_t * 3.4))))
	J.setv(game.j_ctx, "globalAlpha", v_pul)
	game.f_rrectOut(floor((v_cx - 14.0) + 0.5), J.add(v_y0, 4.0), 28.0, 18.0, 3.0, J.getv(game.j_P, "au0"))
	J.setv(game.j_ctx, "globalAlpha", min(1.0, J.add((v_pul * 0.5), J.getv(game.j_DILUI, "parla"))))
	game.f_rrectOut(floor((v_cx - 15.0) + 0.5), J.add(v_y0, 3.0), 30.0, 20.0, 4.0, J.getv(game.j_P, "au1"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(J.getv(game.j_DILUI, "parla"), 0.0):
		J.setv(game.j_ctx, "globalAlpha", (J.getv(game.j_DILUI, "parla") * 0.5))
		game.f_rrect(floor((v_cx - 14.0) + 0.5), J.add(v_y0, 4.0), 28.0, 18.0, 3.0, "#fff4c8")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_otur = game.math_utils.f_clamp((1.0 - (abs((J.getv(game.j_DILUI, "hedef") - J.getv(game.j_DILUI, "anim"))) * 1.8)), 0.0, 1.0)
	v_ad = J.getv(J.getv(game.j_DILLER, game.math_utils.f_clamp(floor(J.getv(game.j_DILUI, "anim") + 0.5), 0.0, (v_n - 1.0))), "ad")
	J.setv(game.j_ctx, "globalAlpha", v_otur)
	game.text_draw.f_txt(v_ad, v_cx, (J.add(v_y0, v_SH) - 10.0), "#fff2cc", {"align": "c", "shadow": 1.0})
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_solVar = J.gt(J.getv(game.j_DILUI, "hedef"), 0.0)
	v_sagVar = J.lt(J.getv(game.j_DILUI, "hedef"), (v_n - 1.0))
	v_solUz = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), v_x0, v_y0, 15.0, v_SH)
	v_sagUz = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.add(v_x0, v_SW) - 15.0), v_y0, 15.0, v_SH)
	game.language_draw.f_dilOk(J.add(v_x0, 8.0), (J.add(v_y0, (float(v_SH) / float(2.0))) - 1.0), (-J.n(1.0)), ("#4a3f34" if (not J.truth(v_solVar)) else ("#fff2cc" if J.truth(v_solUz) else J.getv(game.j_P, "au1"))))
	game.language_draw.f_dilOk((J.add(v_x0, v_SW) - 8.0), (J.add(v_y0, (float(v_SH) / float(2.0))) - 1.0), 1.0, ("#4a3f34" if (not J.truth(v_sagVar)) else ("#fff2cc" if J.truth(v_sagUz) else J.getv(game.j_P, "au1"))))
	if J.truth(J.getv(game.j_IN, "pressed")):
		v_yeni = (-J.n(1.0))
		if (J.truth(v_solUz) and J.truth(v_solVar)):
			v_yeni = (J.getv(game.j_DILUI, "hedef") - 1.0)
		else:
			if (J.truth(v_sagUz) and J.truth(v_sagVar)):
				v_yeni = J.add(J.getv(game.j_DILUI, "hedef"), 1.0)
			else:
				if J.ge(v_tiklanan, 0.0):
					v_yeni = v_tiklanan
		if (J.ge(v_yeni, 0.0) and not J.eq(v_yeni, v_simdi)):
			J.setv(game.j_DILUI, "hedef", v_yeni)
			J.setv(game.j_DILUI, "parla", 1.0)
			game.localization.f_setLang(J.getv(J.getv(game.j_DILLER, v_yeni), "kod"))
			J.method(game.j_SFX, "ui", [])
	return null

