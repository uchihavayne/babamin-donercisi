# Equipment draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:4036
func f_drawPotato(p_cx: Variant = null, p_cy: Variant = null, p_r: Variant = null, p_k: Variant = null) -> Variant:
	var v_h: Variant = null
	var v_rw: Variant = null
	var v_rh: Variant = null
	var v_yat: Variant = null
	var v_t0: Variant = null
	var v_g: Variant = null
	var v_a: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_r: Variant = p_r
	var v_k: Variant = p_k
	v_h = game.f_hash1((v_k * 3.7))
	v_rw = max(3.0, floor((v_r * J.add(0.92, (v_h * 0.26))) + 0.5))
	v_rh = max(3.0, floor((v_r * J.add(0.78, (game.f_hash1((v_k * 1.9)) * 0.22))) + 0.5))
	v_yat = J.gt(game.f_hash1((v_k * 5.3)), 0.55)
	if J.truth(v_yat):
		v_t0 = v_rw
		v_rw = J.add(v_rh, 1.0)
		v_rh = (v_t0 - 1.0)
	v_cx = floor(v_cx + 0.5)
	v_cy = floor(v_cy + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_cx, (J.add(v_cy, v_rh) - 1.0), v_rw, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_cx, v_cy, v_rw, v_rh, "#54390f")
	game.f_ell(v_cx, v_cy, (v_rw - 1.0), (v_rh - 1.0), "#9c6f2e")
	game.f_ell(v_cx, (v_cy - 1.0), (v_rw - 1.0), (v_rh - 1.0), "#b98b46")
	game.f_ell((v_cx - 1.0), (v_cy - 1.0), max(1.0, (v_rw - 2.0)), max(1.0, (v_rh - 2.0)), "#c99a52")
	game.f_ell((v_cx - floor((v_rw * 0.35) + 0.5)), (v_cy - floor((v_rh * 0.45) + 0.5)), max(1.0, floor((v_rw * 0.42) + 0.5)), max(1.0, floor((v_rh * 0.32) + 0.5)), "#dcb271")
	game.f_px((v_cx - floor((v_rw * 0.4) + 0.5)), (v_cy - floor((v_rh * 0.5) + 0.5)), "#eec98d")
	v_g = 0.0
	while J.lt(v_g, 3.0):
		v_a = (game.f_hash1(J.add((v_k * 7.1), (v_g * 2.3))) * 6.28)
		v_bx = J.add(v_cx, floor(((cos(v_a) * v_rw) * 0.45) + 0.5))
		v_by = J.add(v_cy, floor(((sin(v_a) * v_rh) * 0.45) + 0.5))
		if J.gt(game.f_hash1(J.add(v_k, v_g)), 0.45):
			game.f_px(v_bx, v_by, "#7a5424")
		v_g = J.add(v_g, 1.0)
	return null

# art.js:4068
func f_drawPotatoBin(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null) -> Variant:
	var v_oc: Variant = null
	var v_eskiCtx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_t: Variant = p_t
	if ((J.truth(game.j_POTBIN) and J.eq(J.getv(game.j_POTBIN, "w"), v_w)) and J.eq(J.getv(game.j_POTBIN, "h"), v_h)):
		J.method(game.j_ctx, "drawImage", [J.getv(game.j_POTBIN, "c"), ((int(J.n(v_x)) | int(J.n(0.0))) - 2.0), ((int(J.n(v_y)) | int(J.n(0.0))) - 2.0)])
		return null
	v_oc = Canvas.new()
	J.setv(v_oc, "width", J.add(v_w, 6.0))
	J.setv(v_oc, "height", J.add(v_h, 6.0))
	v_eskiCtx = game.j_ctx
	game.j_ctx = J.method(v_oc, "getContext", ["2d"])
	J.setv(game.j_ctx, "imageSmoothingEnabled", false)
	game.f_potBinPaint(2.0, 2.0, v_w, v_h)
	game.j_ctx = v_eskiCtx
	game.j_POTBIN = {"c": v_oc, "w": v_w, "h": v_h}
	J.method(game.j_ctx, "drawImage", [v_oc, ((int(J.n(v_x)) | int(J.n(0.0))) - 2.0), ((int(J.n(v_y)) | int(J.n(0.0))) - 2.0)])
	return null

# art.js:4083
func f_potBinPaint(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_sx: Variant = null
	var v_sw: Variant = null
	var v_sy: Variant = null
	var v_sh: Variant = null
	var v_cx: Variant = null
	var v_baseY: Variant = null
	var v_halfW: Variant = null
	var v_items: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_oy: Variant = null
	var v_oh: Variant = null
	var v_gy: Variant = null
	var v_gx: Variant = null
	var v_rx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	game.f_fr(v_x, v_y, v_w, v_h, "#3a2a12")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), "#4e3a18")
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_sx = J.add(v_x, 2.0)
	v_sw = (v_w - 4.0)
	v_sy = J.add(v_y, 5.0)
	v_sh = (v_h - 8.0)
	game.f_fr(v_sx, v_sy, v_sw, v_sh, "#5b4420")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_fr(J.add(v_sx, 1.0), J.add(v_sy, 1.0), (v_sw - 2.0), 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_cx = J.add(v_x, (float(v_w) / float(2.0)))
	v_baseY = (J.add(v_sy, v_sh) - 9.0)
	v_halfW = ((float(v_sw) / float(2.0)) - 4.0)
	v_items = []
	v_i = 0.0
	while J.lt(v_i, 19.0):
		J.method(v_items, "push", [game.ingredient_pixels.f_pileSpot(v_i, v_cx, v_halfW, v_baseY, 15.0, 7.0)])
		v_i = J.add(v_i, 1.0)
	J.method(v_items, "sort", [game.equipment_draw._closure_76.bind({})])
	v_k = 0.0
	while J.lt(v_k, J.getv(v_items, "length")):
		game.equipment_draw.f_drawPotato(J.getv(J.getv(v_items, v_k), 0.0), J.getv(J.getv(v_items, v_k), 1.0), J.add(5.0, (1.0 if J.gt(J.getv(J.getv(v_items, v_k), 2.0), 0.6) else 0.0)), J.add((v_k * 1.7), 0.3))
		v_k = J.add(v_k, 1.0)
	v_oy = J.add(v_sy, floor((v_sh * 0.42) + 0.5))
	v_oh = (J.add(v_sy, v_sh) - v_oy)
	v_gy = 0.0
	while J.lt(v_gy, v_oh):
		game.f_fr(v_sx, J.add(v_oy, v_gy), v_sw, 2.0, "#7a5a2c")
		game.f_hl(v_sx, J.add(v_oy, v_gy), v_sw, "#a5813f")
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_hl(v_sx, J.add(J.add(v_oy, v_gy), 1.0), v_sw, "#4e3a18")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_gy = J.add(v_gy, 3.0)
	v_gx = 0.0
	while J.lt(v_gx, v_sw):
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		game.f_vl(J.add(v_sx, v_gx), v_oy, v_oh, "#6d5228")
		J.setv(game.j_ctx, "globalAlpha", 0.32)
		game.f_vl(J.add(J.add(v_sx, v_gx), 1.0), v_oy, v_oh, "#c09a52")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_gx = J.add(v_gx, 4.0)
	game.f_fr((v_sx - 1.0), v_sy, J.add(v_sw, 2.0), 3.0, "#8a6a3a")
	game.f_fr((v_sx - 1.0), v_sy, J.add(v_sw, 2.0), 2.0, "#a5813f")
	game.f_hl((v_sx - 1.0), v_sy, J.add(v_sw, 2.0), "#c9a45e")
	v_rx = 0.0
	while J.lt(v_rx, J.add(v_sw, 2.0)):
		J.setv(game.j_ctx, "globalAlpha", 0.4)
		game.f_px(J.add((v_sx - 1.0), v_rx), J.add(v_sy, 1.0), "#6d5228")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_rx = J.add(v_rx, 3.0)
	game.f_fr((v_sx - 1.0), (J.add(v_sy, v_sh) - 2.0), J.add(v_sw, 2.0), 2.0, "#5b4420")
	game.f_hl((v_sx - 1.0), (J.add(v_sy, v_sh) - 2.0), J.add(v_sw, 2.0), "#7a5a2c")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_fr(J.add(v_x, 1.0), (J.add(v_y, v_h) - 3.0), (v_w - 2.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rc(v_x, v_y, v_w, v_h, "#2e2010")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), "#6d5228")
	game.f_vl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_h - 2.0), "#5b4420")
	return null

# art.js:4428
func f_drawGrill(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_Gr: Variant = null, p_t: Variant = null, p_cap: Variant = null) -> Variant:
	var v_gy0: Variant = null
	var v_gy1: Variant = null
	var v_ly: Variant = null
	var v_e: Variant = null
	var v_ex: Variant = null
	var v_ey: Variant = null
	var v_i: Variant = null
	var v_bx2: Variant = null
	var v_sut: Variant = null
	var v_satir: Variant = null
	var v_gen: Variant = null
	var v_sy: Variant = null
	var v_sx: Variant = null
	var v_n: Variant = null
	var v_cx2: Variant = null
	var v_cy2: Variant = null
	var v_yw: Variant = null
	var v_yh: Variant = null
	var v_e2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_Gr: Variant = p_Gr
	var v_t: Variant = p_t
	var v_cap: Variant = p_cap
	v_gy0 = J.add(v_y, 13.0)
	v_gy1 = J.add(v_y, 24.0)
	v_ly = (v_y - 4.0)
	game.f_fr(J.add(v_x, 1.0), v_ly, (v_w - 2.0), 8.0, J.getv(game.j_P, "mt3"))
	game.f_fr(J.add(v_x, 2.0), v_ly, (v_w - 4.0), 7.0, J.getv(game.j_P, "mt1"))
	game.f_hl(J.add(v_x, 2.0), v_ly, (v_w - 4.0), J.getv(game.j_P, "mt0"))
	game.f_hl(J.add(v_x, 1.0), J.add(v_ly, 7.0), (v_w - 2.0), J.getv(game.j_P, "mt5"))
	game.f_fr((J.add(v_x, (int(J.n(v_w)) >> int(J.n(1.0)))) - 7.0), (v_ly - 4.0), 14.0, 4.0, "#2a2a32")
	game.f_fr((J.add(v_x, (int(J.n(v_w)) >> int(J.n(1.0)))) - 6.0), (v_ly - 4.0), 12.0, 3.0, "#454e58")
	game.f_fr(v_x, J.add(v_y, 4.0), v_w, (v_h - 4.0), J.getv(game.j_P, "mt3"))
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 5.0), (v_w - 2.0), (v_h - 6.0), "#6f767e")
	game.f_vl(J.add(v_x, 1.0), J.add(v_y, 5.0), (v_h - 6.0), "#a8b0b8")
	game.f_vl((J.add(v_x, v_w) - 2.0), J.add(v_y, 5.0), (v_h - 6.0), "#565d65")
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 4.0), (v_w - 6.0), ((v_gy1 - v_y) - 4.0), "#20242a")
	v_e = 0.0
	while J.lt(v_e, 14.0):
		v_ex = J.add(J.add(v_x, 5.0), (game.f_hash1((v_e * 3.1)) * (v_w - 12.0)))
		v_ey = J.add(J.add(v_gy0, 1.0), (game.f_hash1((v_e * 7.7)) * ((v_gy1 - v_gy0) - 3.0)))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (0.35 * sin(J.add((v_t * 3.0), (v_e * 1.7))))))
		game.f_fr(v_ex, v_ey, 2.0, 2.0, "#e0500f")
		game.f_px(v_ex, v_ey, "#ff7a2a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_e = J.add(v_e, 1.0)
	v_i = 0.0
	while J.lt(v_i, (v_w - 8.0)):
		v_bx2 = J.add(J.add(v_x, 4.0), v_i)
		game.f_fr(v_bx2, v_gy0, 2.0, (v_gy1 - v_gy0), "#727d88")
		game.f_vl(v_bx2, v_gy0, (v_gy1 - v_gy0), "#98a4b0")
		game.f_vl(J.add(v_bx2, 1.0), v_gy0, (v_gy1 - v_gy0), "#525b64")
		v_i = J.add(v_i, 4.0)
	game.f_hl(J.add(v_x, 3.0), v_gy0, (v_w - 6.0), "#8f9aa4")
	game.f_hl(J.add(v_x, 3.0), (v_gy1 - 1.0), (v_w - 6.0), "#3d444c")
	game.f_fr(J.add(v_x, 5.0), (J.add(v_y, v_h) - 9.0), (v_w - 10.0), 2.0, "#8f9aa4")
	game.f_fr(J.add(v_x, 5.0), (J.add(v_y, v_h) - 10.0), 2.0, 4.0, "#727d88")
	game.f_fr((J.add(v_x, v_w) - 7.0), (J.add(v_y, v_h) - 10.0), 2.0, 4.0, "#727d88")
	game.f_disc(J.add(v_x, 13.0), (J.add(v_y, v_h) - 15.0), 2.0, "#3c4650")
	game.f_px(J.add(v_x, 13.0), (J.add(v_y, v_h) - 16.0), "#98a4b0")
	game.f_disc((J.add(v_x, v_w) - 13.0), (J.add(v_y, v_h) - 15.0), 2.0, "#3c4650")
	game.f_px((J.add(v_x, v_w) - 13.0), (J.add(v_y, v_h) - 16.0), "#98a4b0")
	v_cap = (v_cap if J.truth(v_cap) else 1.0)
	v_sut = (v_cap if J.le(v_cap, 2.0) else 2.0)
	v_satir = (1.0 if J.le(v_cap, 2.0) else 2.0)
	v_gen = (v_w - 8.0)
	v_sy = 0.0
	while J.lt(v_sy, v_satir):
		v_sx = 0.0
		while J.lt(v_sx, v_sut):
			v_n = J.add((v_sy * v_sut), v_sx)
			if J.ge(v_n, v_cap):
				break
			v_cx2 = floor(J.add(J.add(v_x, 4.0), ((float(v_gen) / float(v_sut)) * J.add(v_sx, 0.5))) + 0.5)
			v_cy2 = floor(J.add(v_y, (23.0 if J.eq(v_satir, 1.0) else J.add(15.0, (v_sy * 16.0)))) + 0.5)
			v_yw = (floor((float(v_gen) / float(v_sut)) + 0.5) - 4.0)
			v_yh = (16.0 if J.eq(v_satir, 1.0) else 13.0)
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_fr((v_cx2 - (float(v_yw) / float(2.0))), (v_cy2 - (float(v_yh) / float(2.0))), v_yw, v_yh, "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_rc((v_cx2 - (float(v_yw) / float(2.0))), (v_cy2 - (float(v_yh) / float(2.0))), v_yw, v_yh, "#8a929a")
			v_e2 = 0.0
			while J.lt(v_e2, 3.0):
				J.setv(game.j_ctx, "globalAlpha", J.add(0.22, (0.18 * sin(J.add(J.add((v_t * 3.4), (v_n * 2.1)), v_e2)))))
				game.f_px(J.add((v_cx2 - 4.0), (v_e2 * 4.0)), J.add(v_cy2, (2.0 if J.truth(fmod(J.n(v_e2), J.n(2.0))) else (-J.n(2.0)))), "#ff7a2a")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				v_e2 = J.add(v_e2, 1.0)
			v_sx = J.add(v_sx, 1.0)
		v_sy = J.add(v_sy, 1.0)
	game.text_draw.f_txt("IZGARA", J.add(v_x, (float(v_w) / float(2.0))), (J.add(v_y, v_h) - 7.0), "rgba(255,255,255,.5)", {"align": "c", "outline": "rgba(0,0,0,.45)"})
	if ((J.truth(J.getv(v_Gr, "slots")) and J.truth(J.getv(J.getv(v_Gr, "slots"), "length"))) and J.truth(game.f_chance(0.1))):
		game.effects.f_smoke(J.add(v_x, game.math_utils.f_rnd(6.0, (v_w - 6.0))), J.add(v_y, 10.0), 1.0, "rgba(255,245,225,.45)")
	return null

# art.js:4500
func f_drawBreadStack(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_yy: Variant = null
	var v_s: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_label: Variant = p_label
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 22.0), 18.0, 7.0, "#c9cfd6")
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 21.0), 18.0, 7.0, "#e8edf2")
	game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 20.0), 15.0, 5.0, "#d3dae0")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		v_yy = (J.add(v_y, 18.0) - (v_i * 3.0))
		game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), v_yy, (14.0 - v_i), 4.0, "#d8b581")
		game.f_ell(J.add(v_x, (float(v_w) / float(2.0))), (v_yy - 1.0), (14.0 - v_i), 4.0, "#f0d5a8")
		game.f_ell((J.add(v_x, (float(v_w) / float(2.0))) - 2.0), (v_yy - 2.0), 9.0, 2.0, "#f8e6c4")
		v_s = 0.0
		while J.lt(v_s, 5.0):
			game.f_px(J.add(J.add(J.add(v_x, 6.0), (v_s * 6.0)), (v_i * 2.0)), J.add((v_yy - 1.0), fmod(J.n(v_s), J.n(2.0))), "#c39a63")
			v_s = J.add(v_s, 1.0)
		v_i = J.add(v_i, 1.0)
	if not J.eq(v_label, ""):
		game.text_draw.f_txt((v_label if J.truth(v_label) else "LAVAŞ"), J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 30.0), "rgba(255,255,255,.55)", {"align": "c", "outline": "rgba(0,0,0,.4)"})
	return null

# art.js:4514
func f_drawPideStack(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null) -> Variant:
	var v_cx: Variant = null
	var v_i: Variant = null
	var v_yy: Variant = null
	var v_s: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	v_cx = J.add(v_x, (float(v_w) / float(2.0)))
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_ell(v_cx, J.add(v_y, 11.0), 14.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_yy = (J.add(v_y, 9.0) - (v_i * 3.0))
		game.f_ell(v_cx, v_yy, (13.0 - v_i), 4.0, "#a06a2e")
		game.f_ell(v_cx, (v_yy - 1.0), (13.0 - v_i), 4.0, "#d9a765")
		game.f_ell((v_cx - 1.0), (v_yy - 2.0), 8.0, 2.0, "#eec78c")
		v_s = 0.0
		while J.lt(v_s, 4.0):
			game.f_px(J.add(J.add((v_cx - 7.0), (v_s * 5.0)), v_i), J.add((v_yy - 1.0), fmod(J.n(v_s), J.n(2.0))), "#8a5f31")
			v_s = J.add(v_s, 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# art.js:4851
func f_drawCrate(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_open: Variant = null, p_t: Variant = null, p_acik: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_kay: Variant = null
	var v_i: Variant = null
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_dw: Variant = null
	var v_dh: Variant = null
	var v_v: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_open: Variant = p_open
	var v_t: Variant = p_t
	var v_acik: Variant = p_acik
	v_k = game.math_utils.f_clamp(((1.0 if J.truth(v_open) else 0.0) if J.eq(v_acik, null) else v_acik), 0.0, 1.0)
	v_kay = floor((v_k * 22.0) + 0.5)
	game.f_fr((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), "#171310")
	v_i = 0.0
	while J.lt(v_i, v_h):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.14, ((1.0 - (float(v_i) / float(v_h))) * 0.28)))
		game.f_hl(v_x, J.add(v_y, v_i), v_w, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	game.f_rc((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), "#5b544c")
	v_dx = (v_x - v_kay)
	v_dy = J.add(v_y, 2.0)
	v_dw = v_w
	v_dh = (v_h - 4.0)
	if J.gt(v_kay, 0.0):
		game.f_fr(J.add(v_dx, v_dw), J.add(v_dy, 2.0), v_kay, (v_dh - 4.0), "#4e3a18")
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_fr(J.add(v_dx, v_dw), J.add(v_dy, 2.0), v_kay, 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_hl(J.add(v_dx, v_dw), J.add(v_dy, 2.0), v_kay, "#6d5228")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_dx, 1.0), J.add(v_dy, v_dh), v_dw, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_dx, v_dy, v_dw, v_dh, "#5b4420")
	game.f_fr(J.add(v_dx, 1.0), J.add(v_dy, 1.0), (v_dw - 2.0), (v_dh - 2.0), "#7a5a2c")
	v_v = 0.0
	while J.lt(v_v, (v_dh - 2.0)):
		J.setv(game.j_ctx, "globalAlpha", 0.2)
		game.f_hl(J.add(v_dx, 1.0), J.add(J.add(v_dy, 1.0), v_v), (v_dw - 2.0), "#5b4420")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_v = J.add(v_v, 4.0)
	game.f_hl(J.add(v_dx, 1.0), J.add(v_dy, 1.0), (v_dw - 2.0), "#a5813f")
	if J.gt(v_k, 0.25):
		J.setv(game.j_ctx, "globalAlpha", min(1.0, (float((v_k - 0.25)) / float(0.5))))
		game.f_fr(J.add(v_dx, 3.0), J.add(v_dy, 3.0), (v_dw - 6.0), (v_dh - 7.0), "#3a2a16")
		game.f_ell(J.add(v_dx, 9.0), (J.add(v_dy, v_dh) - 8.0), 6.0, 4.0, J.getv(game.j_P, "g3"))
		game.f_ell(J.add(v_dx, 9.0), (J.add(v_dy, v_dh) - 9.0), 6.0, 4.0, J.getv(game.j_P, "g2"))
		game.f_ell((J.add(v_dx, v_dw) - 10.0), (J.add(v_dy, v_dh) - 7.0), 6.0, 4.0, "#c9cfd6")
		game.f_ell((J.add(v_dx, v_dw) - 10.0), (J.add(v_dy, v_dh) - 8.0), 6.0, 4.0, "#eef2f5")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_dx, v_dy, 5.0, v_dh, "#4e3a18")
	game.f_fr(v_dx, v_dy, 4.0, (v_dh - 1.0), "#6d5228")
	game.f_vl(v_dx, v_dy, (v_dh - 1.0), "#a5813f")
	game.f_fr(J.add(v_dx, 1.0), (J.add(v_dy, (float(v_dh) / float(2.0))) - 6.0), 2.0, 12.0, "#8a8278")
	game.f_vl(J.add(v_dx, 1.0), (J.add(v_dy, (float(v_dh) / float(2.0))) - 6.0), 12.0, "#c0b8ac")
	game.f_px(J.add(v_dx, 1.0), (J.add(v_dy, (float(v_dh) / float(2.0))) - 7.0), "#6e675e")
	game.f_px(J.add(v_dx, 1.0), J.add(J.add(v_dy, (float(v_dh) / float(2.0))), 6.0), "#6e675e")
	game.text_draw.f_txt("STOK", J.add(J.add(v_dx, 5.0), (float((v_dw - 5.0)) / float(2.0))), J.add(v_dy, 3.0), "rgba(255,240,210,.55)", {"align": "c"})
	if J.lt(v_k, 0.1):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (0.12 * sin((v_t * 3.0)))))
		game.f_rc(v_x, v_y, v_w, v_h, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

func _closure_76(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_a: Variant = null
	var v_b: Variant = null
	v_a = J.arg(_args, 0)
	v_b = J.arg(_args, 1)
	return (J.getv(v_a, 1.0) - J.getv(v_b, 1.0))
	return null
