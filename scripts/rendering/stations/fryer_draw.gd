# Fryer draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:3804
func f_drawFryer(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_F: Variant = null, p_t: Variant = null) -> Variant:
	var v_bodyY: Variant = null
	var v_panH: Variant = null
	var v_vatX: Variant = null
	var v_vatW: Variant = null
	var v_vatY: Variant = null
	var v_vatH: Variant = null
	var v_vatB: Variant = null
	var v_sp: Variant = null
	var v_bh0: Variant = null
	var v_oilY: Variant = null
	var v_oilH: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	var v_bx2: Variant = null
	var v_by2: Variant = null
	var v_rzY: Variant = null
	var v_rz: Variant = null
	var v_ry2: Variant = null
	var v_fkd0: Variant = null
	var v_bskH: Variant = null
	var v_bskY: Variant = null
	var v_sepetler: Variant = null
	var v_si: Variant = null
	var v_bskX: Variant = null
	var v_bskW: Variant = null
	var v_gx: Variant = null
	var v_golden: Variant = null
	var v_fcol: Variant = null
	var v_kont: Variant = null
	var v_adet: Variant = null
	var v_i2: Variant = null
	var v_yat: Variant = null
	var v_fw: Variant = null
	var v_fh: Variant = null
	var v_fx: Variant = null
	var v_fy: Variant = null
	var v_batUst: Variant = null
	var v_batAlt: Variant = null
	var v_yi: Variant = null
	var v_fb: Variant = null
	var v_fbx: Variant = null
	var v_fby: Variant = null
	var v_sj: Variant = null
	var v_sbX: Variant = null
	var v_sbW: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_q: Variant = null
	var v_qy: Variant = null
	var v_qx: Variant = null
	var v_gxT: Variant = null
	var v_gyT: Variant = null
	var v_pY: Variant = null
	var v_pX: Variant = null
	var v_pW: Variant = null
	var v_secs: Variant = null
	var v_ekran: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_ledOn: Variant = null
	var v_fkd: Variant = null
	var v_dvx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_F: Variant = p_F
	var v_t: Variant = p_t
	v_bodyY = J.add(v_y, 7.0)
	v_panH = 12.0
	v_vatX = J.add(v_x, 5.0)
	v_vatW = (v_w - 10.0)
	v_vatY = J.add(v_bodyY, 3.0)
	v_vatH = ((v_h - v_panH) - 13.0)
	v_vatB = J.add(v_vatY, v_vatH)
	game.f_fr(J.add(v_x, 3.0), v_y, (v_w - 6.0), (v_bodyY - v_y), "#356669")
	game.f_fr(J.add(v_x, 4.0), v_y, (v_w - 8.0), ((v_bodyY - v_y) - 1.0), "#5aa3a6")
	game.f_hl(J.add(v_x, 4.0), v_y, (v_w - 8.0), "#7cc4c6")
	v_sp = 0.0
	while J.lt(v_sp, 6.0):
		game.f_px(J.add(J.add(v_x, 8.0), (game.f_hash1((v_sp * 2.7)) * (v_w - 18.0))), J.add(J.add(v_y, 1.0), (game.f_hash1((v_sp * 5.1)) * 4.0)), "rgba(196,164,92,.45)")
		v_sp = J.add(v_sp, 1.0)
	v_bh0 = (v_h - (v_bodyY - v_y))
	game.f_fr(v_x, v_bodyY, v_w, v_bh0, "#3f7d80")
	game.f_fr(J.add(v_x, 1.0), J.add(v_bodyY, 1.0), (v_w - 2.0), (v_bh0 - 2.0), "#4e9295")
	game.f_hl(J.add(v_x, 1.0), v_bodyY, (v_w - 2.0), "#7cc4c6")
	game.f_hl(v_x, (J.add(v_y, v_h) - 1.0), v_w, "#24494b")
	game.f_vl(v_x, v_bodyY, v_bh0, "#356669")
	game.f_vl((J.add(v_x, v_w) - 1.0), v_bodyY, v_bh0, "#2b5a5c")
	game.f_fr((v_vatX - 1.0), (v_vatY - 1.0), J.add(v_vatW, 2.0), J.add(v_vatH, 2.0), "#24494b")
	game.f_hl((v_vatX - 1.0), (v_vatY - 1.0), J.add(v_vatW, 2.0), "#1b3739")
	game.f_fr(v_vatX, v_vatY, v_vatW, v_vatH, "#2a2317")
	v_oilY = J.add(v_vatY, 2.0)
	v_oilH = (v_vatB - v_oilY)
	game.f_fr(v_vatX, v_oilY, v_vatW, v_oilH, "#7a5a14")
	game.f_fr(J.add(v_vatX, 1.0), J.add(v_oilY, 1.0), (v_vatW - 2.0), (v_oilH - 3.0), "#a8811f")
	game.f_fr(J.add(v_vatX, 2.0), J.add(v_oilY, 2.0), (v_vatW - 4.0), (v_oilH - 6.0), "#bd932c")
	game.f_fr(J.add(v_vatX, 3.0), J.add(v_oilY, 2.0), (v_vatW - 6.0), 3.0, "#d0a93c")
	v_i = 0.0
	while J.lt(v_i, v_vatW):
		game.f_px(J.add(v_vatX, v_i), J.add(v_oilY, (sin(J.add((v_t * 3.0), (v_i * 0.4))) * 0.8)), "#c9a03a")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.15)
	game.f_fr(J.add(v_vatX, 4.0), J.add(v_oilY, 2.0), floor((v_vatW * 0.3) + 0.5), 2.0, "#fff8dc")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.eq(J.getv(v_F, "state"), "fry"):
		v_b = 0.0
		while J.lt(v_b, 12.0):
			v_bx2 = J.add(J.add(v_vatX, 1.0), (game.f_hash1((v_b * 3.1)) * (v_vatW - 3.0)))
			v_by2 = fmod(J.n(J.add((v_t * J.add(18.0, (v_b * 4.0))), (v_b * 9.0))), J.n((v_vatH - 4.0)))
			game.f_px(v_bx2, ((v_vatB - 1.0) - v_by2), "#e6c463")
			if J.truth(game.f_chance(0.006)):
				game.effects.f_part({"x": v_bx2, "y": v_oilY, "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(18.0)), (-J.n(8.0))), "life": 0.5, "col": "#ffe9a3", "g": 30.0, "sz": 1.0})
			v_b = J.add(v_b, 1.0)
	v_rzY = J.add(v_vatY, floor((v_vatH * 0.34) + 0.5))
	v_rz = 0.0
	while J.lt(v_rz, 2.0):
		v_ry2 = J.add(v_rzY, (v_rz * 4.0))
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		game.f_fr(J.add(v_vatX, 3.0), v_ry2, (v_vatW - 6.0), 2.0, "#8b949d")
		game.f_hl(J.add(v_vatX, 3.0), v_ry2, (v_vatW - 6.0), "#c6ced5")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_px(J.add(v_vatX, 3.0), v_ry2, "#6b737d")
		game.f_px((J.add(v_vatX, v_vatW) - 4.0), v_ry2, "#6b737d")
		v_rz = J.add(v_rz, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.55)
	game.f_fr((J.add(v_vatX, v_vatW) - 5.0), v_rzY, 2.0, 5.0, "#8b949d")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((J.add(v_vatX, v_vatW) - 10.0), (v_vatY - 2.0), 8.0, 2.0, "#9aa3ac")
	game.f_hl((J.add(v_vatX, v_vatW) - 10.0), (v_vatY - 2.0), 8.0, "#d6dde3")
	v_fkd0 = (game.equipment_system.f_UV(game.j_G, "fryer") if (J.eq(J.kind(J.ref(game.equipment_system.f_UV, 2)), "function") and not J.eq(J.kind(game.j_G), "undefined")) else 0.0)
	v_bskH = 13.0
	v_bskY = J.add((v_vatY - 2.0), (J.getv(v_F, "basketY") if J.truth(J.getv(v_F, "basketY")) else 0.0))
	v_sepetler = ([[J.add(v_vatX, 3.0), ((int(J.n(v_vatW)) >> int(J.n(1.0))) - 5.0)], [J.add(J.add(v_vatX, (int(J.n(v_vatW)) >> int(J.n(1.0)))), 2.0), ((int(J.n(v_vatW)) >> int(J.n(1.0))) - 5.0)]] if J.ge(v_fkd0, 3.0) else [[J.add(v_vatX, 4.0), (v_vatW - 8.0)]])
	v_si = 0.0
	while J.lt(v_si, J.getv(v_sepetler, "length")):
		v_bskX = J.getv(J.getv(v_sepetler, v_si), 0.0)
		v_bskW = J.getv(J.getv(v_sepetler, v_si), 1.0)
		if J.lt(J.add(v_bskY, v_bskH), v_vatB):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_fr(J.add(v_bskX, 1.0), J.add(v_bskY, v_bskH), (v_bskW - 2.0), min(2.0, (v_vatB - J.add(v_bskY, v_bskH))), "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(v_bskX, J.add(v_bskY, 1.0), v_bskW, (v_bskH - 1.0), "#3a424a")
		game.f_fr(J.add(v_bskX, 1.0), J.add(v_bskY, 2.0), (v_bskW - 2.0), (v_bskH - 3.0), "#2c333a")
		v_gx = 0.0
		while J.lt(v_gx, (v_bskW - 2.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.5)
			game.f_vl(J.add(J.add(v_bskX, 1.0), v_gx), J.add(v_bskY, 2.0), (v_bskH - 3.0), "#8b949d")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_gx = J.add(v_gx, 3.0)
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		game.f_hl(J.add(v_bskX, 1.0), J.add(v_bskY, 4.0), (v_bskW - 2.0), "#66707a")
		game.f_hl(J.add(v_bskX, 1.0), (J.add(v_bskY, v_bskH) - 3.0), (v_bskW - 2.0), "#66707a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(v_bskX, v_bskY, v_bskW, 2.0, "#9aa3ac")
		game.f_hl(v_bskX, v_bskY, v_bskW, "#e2e8ee")
		game.f_vl(v_bskX, v_bskY, v_bskH, "#b9c2ca")
		game.f_vl((J.add(v_bskX, v_bskW) - 1.0), v_bskY, v_bskH, "#8e97a0")
		if J.gt(J.getv(v_F, "load"), 0.0):
			v_golden = (J.eq(J.getv(v_F, "state"), "done") if J.eq(J.getv(v_F, "state"), "done") else J.gt(J.getv(v_F, "prog"), 0.6))
			v_fcol = ([J.getv(game.j_P, "p0"), J.getv(game.j_P, "p1"), J.getv(game.j_P, "p2")] if J.truth(v_golden) else ["#f5e3b0", "#e8d59a", "#cbb87e"])
			v_kont = ("#5a3f10" if J.truth(v_golden) else "#8d7c52")
			v_adet = min(16.0, J.add(3.0, (J.getv(v_F, "load") * 2.0)))
			v_i2 = 0.0
			while J.lt(v_i2, v_adet):
				v_yat = J.gt(game.f_hash1((v_i2 * 9.1)), 0.45)
				v_fw = (6.0 if J.truth(v_yat) else 2.0)
				v_fh = (2.0 if J.truth(v_yat) else 4.0)
				v_fx = J.add(J.add(v_bskX, 2.0), floor((game.f_hash1((v_i2 * 1.7)) * ((v_bskW - 5.0) - v_fw))))
				v_fy = J.add(J.add(v_bskY, 3.0), floor((game.f_hash1((v_i2 * 4.3)) * ((v_bskH - 5.0) - v_fh))))
				game.f_fr(J.add(v_fx, 1.0), J.add(v_fy, 1.0), v_fw, v_fh, v_kont)
				game.f_fr(v_fx, v_fy, v_fw, v_fh, J.getv(v_fcol, 2.0))
				game.f_fr(v_fx, v_fy, (v_fw - (1.0 if J.truth(v_yat) else 0.0)), (v_fh - (0.0 if J.truth(v_yat) else 1.0)), J.getv(v_fcol, 1.0))
				game.f_px(v_fx, v_fy, J.getv(v_fcol, 0.0))
				v_i2 = J.add(v_i2, 1.0)
		if ((J.gt(J.getv(v_F, "load"), 0.0) and J.lt(J.add(v_bskY, v_bskH), v_oilY)) and J.truth(game.f_chance(0.1))):
			game.effects.f_part({"x": J.add(v_bskX, game.math_utils.f_rnd(2.0, (v_bskW - 2.0))), "y": J.add(v_bskY, v_bskH), "vx": 0.0, "vy": game.math_utils.f_rnd(4.0, 12.0), "life": 0.35, "col": "#c9a03a", "g": 90.0, "sz": 1.0})
		v_batUst = max(v_bskY, v_oilY)
		v_batAlt = min(J.add(v_bskY, v_bskH), v_vatB)
		if J.gt(v_batAlt, v_batUst):
			J.setv(game.j_ctx, "globalAlpha", 0.36)
			game.f_fr((v_bskX - 1.0), v_batUst, J.add(v_bskW, 2.0), (v_batAlt - v_batUst), "#c9a03a")
			J.setv(game.j_ctx, "globalAlpha", 0.32)
			game.f_fr((v_bskX - 1.0), v_batUst, J.add(v_bskW, 2.0), 1.0, "#ffe9a3")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.lt(J.add(v_bskY, v_bskH), (v_vatB - 1.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_fr(v_bskX, max(J.add(v_oilY, 1.0), J.add(v_bskY, v_bskH)), v_bskW, min(3.0, ((v_vatB - 1.0) - J.add(v_bskY, v_bskH))), "#5a3f10")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_si = J.add(v_si, 1.0)
	v_yi = 0.0
	while J.lt(v_yi, v_vatW):
		game.f_px(J.add(v_vatX, v_yi), J.add(v_oilY, (sin(J.add((v_t * 3.0), (v_yi * 0.4))) * 0.8)), "#d8b44a")
		v_yi = J.add(v_yi, 1.0)
	if J.eq(J.getv(v_F, "state"), "fry"):
		v_fb = 0.0
		while J.lt(v_fb, 6.0):
			v_fbx = J.add(J.add(v_bskX, 1.0), (game.f_hash1((v_fb * 7.3)) * (v_bskW - 2.0)))
			v_fby = fmod(J.n(J.add((v_t * J.add(22.0, (v_fb * 5.0))), (v_fb * 13.0))), J.n(((v_vatB - v_oilY) - 2.0)))
			game.f_px(v_fbx, ((v_vatB - 2.0) - v_fby), "#ffe9a3")
			v_fb = J.add(v_fb, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.5)
	game.f_vl(v_vatX, v_vatY, v_vatH, "#4a3410")
	game.f_vl((J.add(v_vatX, v_vatW) - 1.0), v_vatY, v_vatH, "#4a3410")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_vatX - 1.0), (v_vatB - 2.0), J.add(v_vatW, 2.0), 2.0, "#24494b")
	game.f_hl((v_vatX - 1.0), (v_vatB - 2.0), J.add(v_vatW, 2.0), "#4e9295")
	v_sj = 0.0
	while J.lt(v_sj, J.getv(v_sepetler, "length")):
		v_sbX = J.getv(J.getv(v_sepetler, v_sj), 0.0)
		v_sbW = J.getv(J.getv(v_sepetler, v_sj), 1.0)
		v_ax = (J.add(v_sbX, v_sbW) - 5.0)
		v_ay = J.add(v_bskY, 1.0)
		game.f_disc(v_ax, J.add(v_ay, 1.0), 2.0, "#6e7780")
		game.f_disc(v_ax, J.add(v_ay, 1.0), 1.0, "#c8d0d8")
		v_q = 0.0
		while J.le(v_q, 8.0):
			v_qy = (v_ay - v_q)
			v_qx = J.add(v_ax, floor((v_q * 0.36) + 0.5))
			game.f_fr(v_qx, v_qy, 2.0, 1.0, "#8e97a0")
			game.f_px(v_qx, v_qy, "#d6dde3")
			v_q = J.add(v_q, 1.0)
		v_gxT = J.add(v_ax, 3.0)
		v_gyT = (v_ay - 12.0)
		game.f_fr((v_gxT - 5.0), v_gyT, 12.0, 5.0, "#1a2026")
		game.f_fr((v_gxT - 4.0), J.add(v_gyT, 1.0), 10.0, 3.0, "#39424b")
		game.f_hl((v_gxT - 4.0), J.add(v_gyT, 1.0), 10.0, "#5a656f")
		game.f_hl((v_gxT - 4.0), J.add(v_gyT, 3.0), 10.0, "#232a31")
		v_sj = J.add(v_sj, 1.0)
	v_pY = J.add(v_vatB, 3.0)
	v_pX = J.add(v_x, 3.0)
	v_pW = (v_w - 6.0)
	game.f_fr(v_pX, v_pY, v_pW, (v_panH - 3.0), "#2f3740")
	game.f_rc(v_pX, v_pY, v_pW, (v_panH - 3.0), "#59636d")
	game.f_fr(J.add(v_pX, 2.0), J.add(v_pY, 1.0), 22.0, 7.0, "#160c0c")
	v_secs = max(0.0, ceil((J.getv(v_F, "dur") - J.getv(v_F, "t"))))
	v_ekran = ("OK" if J.eq(J.getv(v_F, "state"), "done") else ("180" if J.eq(J.getv(v_F, "state"), "idle") else J.add("", v_secs)))
	game.text_draw.f_txt(v_ekran, J.add(v_pX, 13.0), J.add(v_pY, 1.0), ("#7dff7a" if J.eq(J.getv(v_F, "state"), "done") else ("#c08040" if J.eq(J.getv(v_F, "state"), "idle") else "#ff9a4a")), {"align": "c"})
	v_kx = (J.add(v_pX, v_pW) - 7.0)
	v_ky = J.add(v_pY, 4.0)
	game.f_disc(v_kx, v_ky, 3.0, "#8b959e")
	game.f_disc(v_kx, v_ky, 2.0, "#c8d0d8")
	game.f_ln(v_kx, v_ky, J.add(v_kx, (cos(v_t) * 2.0)), J.add(v_ky, (sin(v_t) * 2.0)), "#2f3740")
	v_ledOn = J.eq(J.getv(v_F, "state"), "fry")
	game.f_disc((v_kx - 9.0), v_ky, 2.0, "#1b2026")
	game.f_px((v_kx - 9.0), v_ky, ("#ff7a3a" if J.truth(v_ledOn) else "#4a2a22"))
	if J.truth(v_ledOn):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_disc((v_kx - 9.0), v_ky, 2.0, "#ff7a3a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (J.eq(J.getv(v_F, "state"), "fry") and J.truth(game.f_chance(0.07))):
		game.effects.f_smoke(J.add(v_vatX, game.math_utils.f_rnd(2.0, (v_vatW - 2.0))), v_vatY, 1.0, "rgba(255,240,210,.5)")
	v_fkd = (game.equipment_system.f_UV(game.j_G, "fryer") if (J.eq(J.kind(J.ref(game.equipment_system.f_UV, 2)), "function") and not J.eq(J.kind(game.j_G), "undefined")) else 0.0)
	if J.ge(v_fkd, 3.0):
		v_dvx = (J.add(v_vatX, (int(J.n(v_vatW)) >> int(J.n(1.0)))) - 1.0)
		game.f_fr(v_dvx, v_vatY, 2.0, v_vatH, "#24494b")
		game.f_fr(v_dvx, v_vatY, 1.0, v_vatH, "#5aa3a6")
		game.f_hl((v_dvx - 1.0), (v_vatY - 1.0), 4.0, "#7cc4c6")
	if J.ge(v_fkd, 4.0):
		game.f_fr((v_vatX - 2.0), (v_vatY - 8.0), J.add(v_vatW, 4.0), 2.0, "#8b949d")
		game.f_hl((v_vatX - 2.0), (v_vatY - 8.0), J.add(v_vatW, 4.0), "#d6dde3")
		game.f_fr((J.add(v_vatX, v_vatW) - 8.0), (v_vatY - 12.0), 8.0, 5.0, "#2f3740")
		game.f_fr((J.add(v_vatX, v_vatW) - 7.0), (v_vatY - 12.0), 6.0, 4.0, "#5f6672")
		game.f_disc((J.add(v_vatX, v_vatW) - 4.0), (v_vatY - 10.0), 1.0, ("#7dff7a" if J.gt(sin((v_t * 9.0)), 0.0) else "#2a6a28"))
	return null

