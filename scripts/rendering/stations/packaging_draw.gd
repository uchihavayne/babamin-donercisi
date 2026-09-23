# Packaging draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:4532
func f_drawPaperStation(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_level: Variant = null, p_busy: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdKagit(p_x, p_y, p_w, p_h, p_level, p_busy, p_t): return null
	var v_rcx0: Variant = null
	var v_ry0: Variant = null
	var v_rw: Variant = null
	var v_rh: Variant = null
	var v_kx0: Variant = null
	var v_sy0: Variant = null
	var v_z: Variant = null
	var v_oto: Variant = null
	var v_mx: Variant = null
	var v_mw: Variant = null
	var v_my: Variant = null
	var v_mh: Variant = null
	var v_wa: Variant = null
	var v_pnx: Variant = null
	var v_pny: Variant = null
	var v_pnw: Variant = null
	var v_pnh: Variant = null
	var v_rcx: Variant = null
	var v_rcy: Variant = null
	var v_kby: Variant = null
	var v_d3: Variant = null
	var v_uz: Variant = null
	var v_z2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_level: Variant = p_level
	var v_busy: Variant = p_busy
	var v_t: Variant = p_t
	if J.eq(v_level, 0.0):
		v_rcx0 = floor(J.add(v_x, (float(v_w) / float(2.0))) + 0.5)
		v_ry0 = J.add(v_y, 15.0)
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 4.0), 3.0, 28.0, "#4e2e17")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 4.0), 2.0, 27.0, "#6b4122")
		game.f_hl(J.add(v_x, 1.0), J.add(v_y, 4.0), 2.0, "#8a5730")
		game.f_fr((J.add(v_x, v_w) - 4.0), J.add(v_y, 4.0), 3.0, 28.0, "#4e2e17")
		game.f_fr((J.add(v_x, v_w) - 4.0), J.add(v_y, 4.0), 2.0, 27.0, "#6b4122")
		game.f_hl((J.add(v_x, v_w) - 4.0), J.add(v_y, 4.0), 2.0, "#8a5730")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 30.0), (v_w - 2.0), 3.0, "#4e2e17")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 30.0), (v_w - 2.0), 2.0, "#6b4122")
		game.f_hl(J.add(v_x, 2.0), J.add(v_y, 30.0), (v_w - 4.0), "#8a5730")
		v_rw = 8.0
		v_rh = 7.0
		J.setv(game.j_ctx, "globalAlpha", 0.26)
		game.f_ell(v_rcx0, J.add(J.add(v_ry0, v_rh), 1.0), v_rw, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr((v_rcx0 - v_rw), (v_ry0 - v_rh), (v_rw * 2.0), (v_rh * 2.0), "#b9b3a2")
		game.f_fr((v_rcx0 - v_rw), (v_ry0 - v_rh), ((v_rw * 2.0) - 1.0), ((v_rh * 2.0) - 1.0), "#e8e4d6")
		game.f_fr((v_rcx0 - v_rw), (v_ry0 - v_rh), ((v_rw * 2.0) - 1.0), 3.0, "#f8f4e8")
		game.f_hl(J.add((v_rcx0 - v_rw), 1.0), (v_ry0 - v_rh), ((v_rw * 2.0) - 3.0), "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		game.f_fr((J.add(v_rcx0, v_rw) - 4.0), (v_ry0 - v_rh), 4.0, ((v_rh * 2.0) - 1.0), "#7a7466")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(J.add((v_rcx0 - v_rw), 1.0), (v_ry0 - 3.0), ((v_rw * 2.0) - 3.0), 2.0, "#b8302a")
		game.f_hl(J.add((v_rcx0 - v_rw), 1.0), (v_ry0 - 3.0), ((v_rw * 2.0) - 3.0), "#d8352c")
		game.f_fr(J.add((v_rcx0 - v_rw), 1.0), J.add(v_ry0, 2.0), ((v_rw * 2.0) - 3.0), 2.0, "#2c5369")
		game.f_hl(J.add((v_rcx0 - v_rw), 1.0), J.add(v_ry0, 2.0), ((v_rw * 2.0) - 3.0), "#2f5f9e")
		v_kx0 = (J.add(v_rcx0, v_rw) - 1.0)
		game.f_ell(v_kx0, v_ry0, 2.0, v_rh, "#cfc9b8")
		game.f_ell(v_kx0, v_ry0, 2.0, (v_rh - 1.0), "#f8f4e8")
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		game.f_ell(v_kx0, v_ry0, 2.0, (v_rh - 3.0), "#c8c0ac")
		game.f_ell(v_kx0, v_ry0, 1.0, (v_rh - 5.0), "#c8c0ac")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_px(v_kx0, v_ry0, "#b8302a")
		game.f_px(v_kx0, (v_ry0 - 1.0), "#8e1f18")
		v_sy0 = J.add(v_ry0, v_rh)
		game.f_fr((v_rcx0 - 5.0), v_sy0, 10.0, 9.0, "#b9b3a2")
		game.f_fr((v_rcx0 - 5.0), v_sy0, 9.0, 8.0, "#f8f4e8")
		game.f_vl((v_rcx0 - 5.0), v_sy0, 8.0, "#ffffff")
		game.f_hl((v_rcx0 - 4.0), J.add(v_sy0, 3.0), 7.0, "#d8352c")
		v_z = 0.0
		while J.lt(v_z, 10.0):
			game.f_px(J.add((v_rcx0 - 5.0), v_z), J.add(J.add(v_sy0, 8.0), (1.0 if J.eq(fmod(J.n(v_z), J.n(3.0)), 1.0) else 0.0)), "#cfc9b8")
			v_z = J.add(v_z, 1.0)
	else:
		v_oto = J.ge(v_level, 2.0)
		v_mx = J.add(v_x, 1.0)
		v_mw = (v_w - 2.0)
		v_my = J.add(v_y, 8.0)
		v_mh = (v_h - 12.0)
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr(J.add(v_mx, 1.0), J.add(v_my, 2.0), v_mw, v_mh, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(v_mx, v_my, v_mw, v_mh, "#232a31")
		game.f_fr(J.add(v_mx, 1.0), v_my, (v_mw - 2.0), (v_mh - 1.0), "#39424b")
		game.f_fr(J.add(v_mx, 1.0), v_my, 4.0, (v_mh - 1.0), "#5f6672")
		J.setv(game.j_ctx, "globalAlpha", 0.24)
		game.f_fr((J.add(v_mx, v_mw) - 5.0), v_my, 4.0, (v_mh - 1.0), "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr((v_mx - 1.0), (v_my - 5.0), J.add(v_mw, 2.0), 6.0, "#232a31")
		game.f_fr(v_mx, (v_my - 5.0), v_mw, 5.0, "#5f6672")
		game.f_hl(v_mx, (v_my - 5.0), v_mw, "#aeb5be")
		if J.truth(v_oto):
			game.f_fr(J.add(v_mx, 2.0), (v_my - 11.0), 9.0, 6.0, "#232a31")
			game.f_fr(J.add(v_mx, 3.0), (v_my - 11.0), 7.0, 5.0, "#5f6672")
			game.f_hl(J.add(v_mx, 3.0), (v_my - 11.0), 7.0, "#aeb5be")
			game.f_fr((J.add(v_mx, v_mw) - 8.0), (v_my - 10.0), 6.0, 5.0, "#232a31")
			game.f_fr((J.add(v_mx, v_mw) - 7.0), (v_my - 10.0), 4.0, 4.0, "#878e99")
			v_wa = (v_t * 8.0)
			game.f_px(floor(J.add((J.add(v_mx, v_mw) - 5.0), (cos(v_wa) * 1.4)) + 0.5), floor(J.add((v_my - 8.0), (sin(v_wa) * 1.4)) + 0.5), "#d3d8de")
		game.f_disc((J.add(v_mx, v_mw) - 4.0), (v_my - 3.0), 1.0, (("#7dff7a" if J.gt(sin((v_t * 16.0)), 0.0) else "#2a6a28") if (J.gt(v_busy, 0.0) or J.truth(v_oto)) else "#7a4040"))
		v_pnx = J.add(v_mx, 2.0)
		v_pny = J.add(v_my, 4.0)
		v_pnw = (v_mw - 4.0)
		v_pnh = 16.0
		game.f_fr((v_pnx - 1.0), (v_pny - 1.0), J.add(v_pnw, 2.0), J.add(v_pnh, 2.0), "#141a1f")
		game.f_fr(v_pnx, v_pny, v_pnw, v_pnh, "#1c242b")
		v_rcx = floor(J.add(v_pnx, (float(v_pnw) / float(2.0))) + 0.5)
		v_rcy = floor(J.add(v_pny, (float(v_pnh) / float(2.0))) + 0.5)
		game.f_ell(v_rcx, J.add(v_rcy, 1.0), 6.0, 6.0, "#b9b3a2")
		game.f_ell(v_rcx, v_rcy, 6.0, 6.0, "#e8e4d6")
		game.f_ell((v_rcx - 1.0), (v_rcy - 1.0), 4.0, 4.0, "#f8f4e8")
		J.setv(game.j_ctx, "globalAlpha", 0.45)
		game.f_ring(v_rcx, v_rcy, 4.0, "#c8c0ac")
		game.f_ring(v_rcx, v_rcy, 2.0, "#c8c0ac")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_px(v_rcx, v_rcy, "#b8302a")
		game.f_px(v_rcx, J.add(v_rcy, 1.0), "#8e1f18")
		J.setv(game.j_ctx, "globalAlpha", 0.14)
		game.f_fr(J.add(v_pnx, 1.0), J.add(v_pny, 1.0), 2.0, (v_pnh - 3.0), "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_kby = (J.add(v_my, v_mh) - 11.0)
		game.f_fr(J.add(v_mx, 1.0), v_kby, (v_mw - 2.0), 3.0, "#232a31")
		game.f_hl(J.add(v_mx, 1.0), v_kby, (v_mw - 2.0), "#878e99")
		v_d3 = 0.0
		while J.lt(v_d3, (v_mw - 3.0)):
			game.f_px(J.add(J.add(v_mx, 2.0), v_d3), J.add(v_kby, 3.0), "#d3d8de")
			v_d3 = J.add(v_d3, 2.0)
		v_uz = (floor((9.0 * (1.0 - v_busy)) + 0.5) if J.gt(v_busy, 0.0) else 0.0)
		if J.gt(v_uz, 0.0):
			game.f_fr(J.add(v_mx, 2.0), J.add(v_kby, 4.0), (v_mw - 4.0), v_uz, "#b9b3a2")
			game.f_fr(J.add(v_mx, 2.0), J.add(v_kby, 4.0), (v_mw - 5.0), (v_uz - 1.0), "#f8f4e8")
			game.f_hl(J.add(v_mx, 3.0), J.add(v_kby, 6.0), (v_mw - 7.0), "#d8352c")
			if J.gt(v_uz, 5.0):
				game.f_hl(J.add(v_mx, 3.0), J.add(v_kby, 9.0), (v_mw - 7.0), "#2f5f9e")
			v_z2 = 0.0
			while J.lt(v_z2, (v_mw - 4.0)):
				game.f_px(J.add(J.add(v_mx, 2.0), v_z2), J.add(J.add(J.add(v_kby, 3.0), v_uz), (1.0 if J.eq(fmod(J.n(v_z2), J.n(3.0)), 1.0) else 0.0)), "#cfc9b8")
				v_z2 = J.add(v_z2, 1.0)
			if J.truth(game.f_chance(0.3)):
				game.effects.f_part({"x": J.add(v_mx, game.math_utils.f_rnd(3.0, (v_mw - 3.0))), "y": J.add(v_kby, 4.0), "vx": game.math_utils.f_rnd((-J.n(8.0)), 8.0), "vy": game.math_utils.f_rnd((-J.n(16.0)), (-J.n(4.0))), "life": 0.3, "col": "#fdfaf0", "g": 90.0, "sz": 1.0})
		if J.ge(v_level, 2.0):
			game.text_draw.f_txt("OTO", J.add(v_x, (float(v_w) / float(2.0))), (J.add(v_y, v_h) - 6.0), J.getv(game.j_P, "ok"), {"align": "c", "outline": "rgba(0,0,0,.6)"})
	return null

# art.js:4649
func f_drawFboxStation(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_ready: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdKutu(p_x, p_y, p_w, p_h, p_ready, p_t): return null
	var v_cx: Variant = null
	var v_ry: Variant = null
	var v_i: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_kr: Variant = null
	var v_ku: Variant = null
	var v_kg: Variant = null
	var v_kx: Variant = null
	var v_n: Variant = null
	var v_r: Variant = null
	var v_fx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_ready: Variant = p_ready
	var v_t: Variant = p_t
	v_cx = J.add(v_x, (float(v_w) / float(2.0)))
	v_ry = J.add(v_y, 5.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 2.0), J.add(v_ry, 11.0), (v_w - 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(J.add(v_x, 1.0), J.add(v_ry, 11.0), (v_w - 2.0), 2.0, "#8e959d")
	game.f_hl(J.add(v_x, 1.0), J.add(v_ry, 11.0), (v_w - 2.0), "#c6ccd2")
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_bx = floor(J.add(J.add(v_x, 4.0), (v_i * 7.0)) + 0.5)
		v_by = (J.add(v_ry, 2.0) - fmod(J.n(v_i), J.n(2.0)))
		J.setv(game.j_ctx, "globalAlpha", 0.74)
		v_kr = 0.0
		while J.lt(v_kr, 9.0):
			v_ku = (float(v_kr) / float(8.0))
			v_kg = floor(J.add(9.0, ((6.0 - 9.0) * v_ku)) + 0.5)
			v_kx = J.add(v_bx, floor((float((9.0 - v_kg)) / float(2.0)) + 0.5))
			game.f_fr(v_kx, J.add(v_by, v_kr), v_kg, 1.0, "#8e1c14")
			game.f_fr(J.add(v_kx, 1.0), J.add(v_by, v_kr), (v_kg - 2.0), 1.0, ("#d8382a" if J.lt(v_ku, 0.2) else "#c02a20"))
			game.f_px(J.add(v_kx, 1.0), J.add(v_by, v_kr), "#e86a58")
			v_kr = J.add(v_kr, 1.0)
		game.f_fr(J.add(v_bx, 1.0), v_by, 7.0, 1.0, "#5e120d")
		game.f_fr(J.add(v_bx, 2.0), J.add(v_by, 3.0), 5.0, 2.0, "#f7d34a")
		game.f_hl(J.add(v_bx, 2.0), J.add(v_by, 3.0), 5.0, "#ffe98e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	v_n = min(2.0, (int(J.n(v_ready)) | int(J.n(0.0))))
	v_r = 0.0
	while J.lt(v_r, v_n):
		v_fx = floor(J.add(v_cx, (0.0 if J.eq(v_n, 1.0) else ((-J.n(8.0)) if J.eq(v_r, 0.0) else 8.0))) + 0.5)
		game.food_draw.f_drawFriesCup(v_fx, (J.add(v_y, v_h) - 14.0), "ok", J.add(v_t, v_r))
		v_r = J.add(v_r, 1.0)
	if (not J.truth(v_n)):
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		game.f_ell(v_cx, (J.add(v_y, v_h) - 5.0), 8.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_hl(J.add(v_x, 1.0), (J.add(v_y, v_h) - 4.0), (v_w - 2.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:4711
func f_drawTepsiKasasi(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_bolmeler: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdKasa(p_x, p_y, p_w, p_h): return null
	var v_i: Variant = null
	var v_bx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_bolmeler: Variant = p_bolmeler
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, v_h), v_w, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_x - 3.0), (v_y - 4.0), J.add(v_w, 6.0), J.add(v_h, 8.0), "#6f767e")
	game.f_fr((v_x - 2.0), (v_y - 3.0), J.add(v_w, 4.0), J.add(v_h, 6.0), "#8e959d")
	game.f_fr((v_x - 2.0), (v_y - 3.0), J.add(v_w, 4.0), 2.0, "#b8c0c8")
	game.f_fr((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), "#4a525a")
	v_i = 1.0
	while J.lt(v_i, v_bolmeler):
		v_bx = floor(J.add(v_x, ((float(v_w) / float(v_bolmeler)) * v_i)) + 0.5)
		game.f_fr((v_bx - 1.0), (v_y - 3.0), 2.0, J.add(v_h, 6.0), "#6f767e")
		game.f_vl((v_bx - 1.0), (v_y - 3.0), J.add(v_h, 6.0), "#b8c0c8")
		v_i = J.add(v_i, 1.0)
	game.f_fr((v_x - 3.0), J.add(J.add(v_y, v_h), 3.0), J.add(v_w, 6.0), 2.0, "#59636d")
	game.f_hl((v_x - 3.0), J.add(J.add(v_y, v_h), 3.0), J.add(v_w, 6.0), "#8e959d")
	return null

# art.js:4726
func f_drawTepsiCami(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdCam(p_x, p_y, p_w, p_h): return null
	var v_g: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.13)
	game.f_fr((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), "#cfe4f2")
	J.setv(game.j_ctx, "globalAlpha", 0.2)
	v_g = 0.0
	while J.lt(v_g, v_w):
		game.f_ln(J.add(v_x, v_g), J.add(v_y, v_h), J.add(J.add(v_x, v_g), 6.0), (v_y - 1.0), "#ffffff")
		v_g = J.add(v_g, 9.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rc((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), "rgba(180,210,230,.35)")
	return null

