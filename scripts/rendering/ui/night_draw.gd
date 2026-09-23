# Night draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:2528
func f_drawThief(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_phase: Variant = null, p_running: Variant = null) -> Variant:
	var v_sway: Variant = null
	var v_bob: Variant = null
	var v_by: Variant = null
	var v_bw: Variant = null
	var v_hy: Variant = null
	var v_hw: Variant = null
	var v_C0: Variant = null
	var v_C1: Variant = null
	var v_C2: Variant = null
	var v_C3: Variant = null
	var v_ao: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_phase: Variant = p_phase
	var v_running: Variant = p_running
	v_sway = ((sin((v_t * 11.0)) * 1.2) if (J.eq(v_phase, 0.0) or J.truth(v_running)) else 0.0)
	v_bob = (sin((v_t * 2.2)) * 0.8)
	v_x = floor(J.add(v_x, v_sway) + 0.5)
	v_y = floor(J.add(v_y, v_bob) + 0.5)
	v_by = (v_y - 30.0)
	v_bw = 26.0
	v_hy = (v_y - 42.0)
	v_hw = 12.0
	v_C0 = "#171b22"
	v_C1 = "#262d39"
	v_C2 = "#333c4b"
	v_C3 = "#454f61"
	J.setv(game.j_ctx, "globalAlpha", 0.38)
	game.f_ell(v_x, J.add(v_y, 1.0), 14.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_x, J.add(v_by, 5.0), (float(v_bw) / float(2.0)), 7.0, v_C0)
	game.f_fr((v_x - (float(v_bw) / float(2.0))), J.add(v_by, 5.0), v_bw, 26.0, v_C0)
	game.f_ell(v_x, J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 1.0), 6.0, v_C1)
	game.f_fr(J.add((v_x - (float(v_bw) / float(2.0))), 1.0), J.add(v_by, 4.0), (v_bw - 2.0), 26.0, v_C1)
	game.f_fr(J.add((v_x - (float(v_bw) / float(2.0))), 1.0), J.add(v_by, 5.0), 7.0, 25.0, v_C2)
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_fr(J.add(v_x, 3.0), J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 3.0), 27.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_vl(v_x, J.add(v_by, 6.0), 24.0, "#12161c")
	game.f_fr((v_x - 9.0), J.add(v_by, 20.0), 6.0, 4.0, v_C0)
	game.f_fr(J.add(v_x, 4.0), J.add(v_by, 20.0), 6.0, 4.0, v_C0)
	v_ao = (floor((sin((v_t * 15.0)) * 2.0) + 0.5) if J.truth(v_running) else 0.0)
	game.f_fr(((v_x - (float(v_bw) / float(2.0))) - 3.0), J.add(J.add(v_by, 8.0), v_ao), 5.0, 22.0, v_C0)
	game.f_fr(((v_x - (float(v_bw) / float(2.0))) - 3.0), J.add(J.add(v_by, 8.0), v_ao), 4.0, 21.0, v_C1)
	game.f_fr((J.add(v_x, (float(v_bw) / float(2.0))) - 2.0), (J.add(v_by, 8.0) - v_ao), 5.0, 22.0, "#12161c")
	game.f_ell(((v_x - (float(v_bw) / float(2.0))) - 1.0), J.add(J.add(v_by, 29.0), v_ao), 3.0, 3.0, "#0f1218")
	game.f_ell(J.add(v_x, (float(v_bw) / float(2.0))), (J.add(v_by, 29.0) - v_ao), 3.0, 3.0, "#0f1218")
	game.f_ell(v_x, J.add(v_hy, 1.0), J.add(v_hw, 1.0), 12.0, v_C0)
	game.f_ell((v_x - 1.0), v_hy, v_hw, 11.0, v_C1)
	game.f_ell((v_x - 2.0), (v_hy - 2.0), (v_hw - 3.0), 8.0, v_C2)
	game.f_hl((v_x - 7.0), (v_hy - 10.0), 13.0, v_C3)
	game.f_fr((v_x - 8.0), J.add(v_hy, 9.0), 17.0, 6.0, v_C0)
	game.f_fr((v_x - 7.0), J.add(v_hy, 9.0), 15.0, 5.0, v_C1)
	game.f_ell(v_x, J.add(v_hy, 2.0), (v_hw - 4.0), 7.0, "#080a0e")
	J.setv(game.j_ctx, "globalAlpha", 0.9)
	game.f_fr((v_x - 6.0), v_hy, 4.0, 2.0, "#cfd8e2")
	game.f_fr(J.add(v_x, 3.0), v_hy, 4.0, 2.0, "#cfd8e2")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_px((v_x - 5.0), v_hy, "#ffffff")
	game.f_px(J.add(v_x, 4.0), v_hy, "#ffffff")
	game.f_px((v_x - 5.0), J.add(v_hy, 12.0), "#5a6474")
	game.f_px(J.add(v_x, 5.0), J.add(v_hy, 12.0), "#5a6474")
	game.f_px((v_x - 5.0), J.add(v_hy, 14.0), "#5a6474")
	game.f_px(J.add(v_x, 5.0), J.add(v_hy, 14.0), "#5a6474")
	v_sx = J.add(v_x, 20.0)
	v_sy = J.add((J.add(v_by, 8.0) - v_ao), floor((sin((v_t * 6.0)) * 1.2) + 0.5))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_ell(v_sx, J.add(v_sy, 15.0), 8.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_sx, J.add(v_sy, 11.0), 9.0, 8.0, "#5c4d31")
	game.f_ell(v_sx, J.add(v_sy, 9.0), 9.0, 8.0, "#8a7448")
	game.f_ell((v_sx - 2.0), J.add(v_sy, 7.0), 6.0, 5.0, "#a68d58")
	game.f_fr((v_sx - 4.0), (v_sy - 1.0), 9.0, 5.0, "#4e4128")
	game.f_fr((v_sx - 3.0), v_sy, 7.0, 3.0, "#6b5a3a")
	game.text_draw.f_txt("$", v_sx, J.add(v_sy, 6.0), "#f0d78a", {"align": "c", "sc": 1.0})
	game.f_fr((J.add(v_x, (float(v_bw) / float(2.0))) - 2.0), J.add(v_sy, 2.0), 9.0, 5.0, "#12161c")
	return null

# ui.js:2594
func f_drawSecCam(p_t: Variant = null, p_alert: Variant = null) -> Variant:
	var v_cx0: Variant = null
	var v_cy0: Variant = null
	var v_on: Variant = null
	var v_i: Variant = null
	var v_t: Variant = p_t
	var v_alert: Variant = p_alert
	v_cx0 = 424.0
	v_cy0 = 30.0
	game.f_fr(J.add(v_cx0, 10.0), (v_cy0 - 2.0), 5.0, 8.0, "#3a4149")
	game.f_hl(J.add(v_cx0, 10.0), (v_cy0 - 2.0), 5.0, "#5f6a75")
	game.f_fr(v_cx0, J.add(v_cy0, 3.0), 15.0, 8.0, "#2b3037")
	game.f_fr(J.add(v_cx0, 1.0), J.add(v_cy0, 4.0), 13.0, 6.0, "#4a545f")
	game.f_hl(J.add(v_cx0, 1.0), J.add(v_cy0, 4.0), 13.0, "#6d7a86")
	game.f_fr((v_cx0 - 4.0), J.add(v_cy0, 5.0), 5.0, 5.0, "#1b1f26")
	game.f_disc((v_cx0 - 2.0), J.add(v_cy0, 7.0), 2.0, "#0d1015")
	game.f_px((v_cx0 - 3.0), J.add(v_cy0, 6.0), "#8fb4d8")
	v_on = J.gt(sin((v_t * 6.0)), 0.0)
	game.f_disc(J.add(v_cx0, 12.0), J.add(v_cy0, 6.0), 1.0, ("#ff4a3a" if J.truth(v_on) else "#5a2a26"))
	if J.truth(v_on):
		J.setv(game.j_ctx, "globalAlpha", 0.16)
		game.f_disc(J.add(v_cx0, 12.0), J.add(v_cy0, 6.0), 5.0, "#ff4a3a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_alert):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.05, (0.03 * sin((v_t * 4.0)))))
		v_i = 0.0
		while J.lt(v_i, 46.0):
			game.f_fr(((v_cx0 - 4.0) - v_i), J.add(J.add(v_cy0, 6.0), floor((v_i * 0.55) + 0.5)), 2.0, J.add(2.0, (int(J.n(v_i)) >> int(J.n(2.0)))), "#cfe6f2")
			v_i = J.add(v_i, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# ui.js:2619
func f_drawNight(p_t: Variant = null) -> Variant:
	var v_N: Variant = null
	var v_mI: Variant = null
	var v_sec: Variant = null
	var v_al: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_lx: Variant = null
	var v_ly: Variant = null
	var v_ph: Variant = null
	var v_TY: Variant = null
	var v_tx: Variant = null
	var v_k2: Variant = null
	var v_fb: Variant = null
	var v_by2: Variant = null
	var v_bw2: Variant = null
	var v_bx2: Variant = null
	var v_t: Variant = p_t
	v_N = J.getv(game.j_G, "night")
	if (not J.truth(v_N)):
		J.setv(game.j_G, "scene", "intro")
		J.setv(game.j_G, "sceneT", 0.0)
		return null
	J.setv(v_N, "t", J.add(J.getv(v_N, "t"), (float(1.0) / float(60.0))))
	game.j_NOCHEF = true
	game.interface_draw.f_drawShopStatic(v_t, false)
	game.j_NOCHEF = false
	J.setv(game.j_ctx, "globalAlpha", 0.62)
	game.f_fr(0.0, 0.0, game.j_W, J.add(J.getv(game.j_LAY, "floorY"), 12.0), "#0a1030")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.16)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#000018")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.window_draw.f_drawShutter(1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.07)
	v_mI = 0.0
	while J.lt(v_mI, 60.0):
		game.f_fr(J.add(120.0, v_mI), J.add(30.0, v_mI), 34.0, 1.0, "#9fc8ff")
		v_mI = J.add(v_mI, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_sec = J.getv(v_N, "sec")
	if J.ge(v_sec, 3.0):
		game.window_draw.f_drawWallCam(v_t, J.ge(J.getv(v_N, "phase"), 1.0))
	if (J.ge(v_sec, 2.0) and J.ge(J.getv(v_N, "phase"), 1.0)):
		v_al = J.gt(sin((v_t * 14.0)), 0.0)
		v_ax = 108.0
		v_ay = 38.0
		game.f_fr(v_ax, v_ay, 12.0, 7.0, "#2f3740")
		game.f_fr(J.add(v_ax, 1.0), J.add(v_ay, 1.0), 10.0, 5.0, "#454b52")
		game.f_ell(J.add(v_ax, 6.0), v_ay, 6.0, 4.0, ("#ff3a2a" if J.truth(v_al) else "#6a2018"))
		if J.truth(v_al):
			J.setv(game.j_ctx, "globalAlpha", 0.18)
			game.f_disc(J.add(v_ax, 6.0), v_ay, 20.0, "#ff3a2a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			J.setv(game.j_ctx, "globalAlpha", 0.07)
			game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#ff2a1a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.ge(v_sec, 1.0):
		v_lx = (float(game.j_W) / float(2.0))
		v_ly = 112.0
		game.f_fr((v_lx - 4.0), v_ly, 9.0, 7.0, "#8a929b")
		game.f_fr((v_lx - 3.0), J.add(v_ly, 1.0), 7.0, 5.0, "#c7ced5")
		game.f_rc((v_lx - 3.0), (v_ly - 4.0), 7.0, 5.0, "#8a929b")
		game.f_px(v_lx, J.add(v_ly, 3.0), "#5a636b")
	v_ph = J.getv(v_N, "phase")
	if (J.eq(v_ph, 0.0) and J.gt(J.getv(v_N, "t"), 1.7)):
		J.setv(v_N, "phase", 1.0)
		J.method(game.j_SFX, "uiBack", [])
		if J.ge(v_sec, 2.0):
			J.method(game.j_SFX, "bell", [])
			game.effects.f_shake(2.0)
	if (J.eq(v_ph, 1.0) and J.gt(J.getv(v_N, "t"), 3.4)):
		J.setv(v_N, "phase", 2.0)
		if (J.truth(J.getv(v_N, "stole")) and (not J.truth(J.getv(v_N, "paid")))):
			J.setv(v_N, "paid", true)
			J.setv(game.j_G, "money", max(0.0, (J.getv(game.j_G, "money") - J.getv(v_N, "amount"))))
			J.setv(J.getv(game.j_G, "stats"), "stolen", J.add((J.getv(J.getv(game.j_G, "stats"), "stolen") if J.truth(J.getv(J.getv(game.j_G, "stats"), "stolen")) else 0.0), J.getv(v_N, "amount")))
			J.method(game.j_SFX, "fail", [])
			game.effects.f_shake(4.0)
			game.effects.f_flash(0.2, "#ff4a3a")
			game.save_system.f_saveAll()
		else:
			if (not J.truth(J.getv(v_N, "stole"))):
				J.method(game.j_SFX, "levelup", [])
	v_TY = J.getv(J.getv(J.getv(game.j_LAY, "custSlots"), 0.0), "y")
	if J.eq(J.getv(v_N, "phase"), 0.0):
		v_tx = game.math_utils.f_lerp((-J.n(34.0)), 236.0, game.math_utils.f_clamp((float(J.getv(v_N, "t")) / float(1.7)), 0.0, 1.0))
	else:
		if J.eq(J.getv(v_N, "phase"), 1.0):
			v_tx = J.add(236.0, (sin((J.getv(v_N, "t") * 3.0)) * 3.0))
		else:
			v_k2 = game.math_utils.f_clamp((float((J.getv(v_N, "t") - 3.4)) / float(1.5)), 0.0, 1.0)
			v_tx = (game.math_utils.f_lerp(236.0, J.add(game.j_W, 46.0), v_k2) if J.truth(J.getv(v_N, "stole")) else game.math_utils.f_lerp(236.0, (-J.n(46.0)), v_k2))
	if J.lt(J.getv(v_N, "phase"), 2.0):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (0.04 * sin((v_t * 9.0)))))
		v_fb = 0.0
		while J.lt(v_fb, 30.0):
			game.f_fr(J.add(J.add(v_tx, 8.0), v_fb), J.add((v_TY - 22.0), floor((v_fb * 0.5) + 0.5)), J.add(3.0, v_fb), 1.0, "#ffe9a0")
			v_fb = J.add(v_fb, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_px(J.add(v_tx, 8.0), (v_TY - 20.0), "#fff6c8")
	game.night_draw.f_drawThief(v_tx, v_TY, v_t, J.getv(v_N, "phase"), J.eq(J.getv(v_N, "phase"), 2.0))
	if ((J.eq(J.getv(v_N, "phase"), 2.0) and J.truth(J.getv(v_N, "stole"))) and J.truth(game.f_chance(0.35))):
		game.effects.f_part({"x": v_tx, "y": (v_TY - 20.0), "vx": game.math_utils.f_rnd((-J.n(24.0)), 24.0), "vy": game.math_utils.f_rnd((-J.n(44.0)), (-J.n(14.0))), "life": 0.9, "col": J.getv(game.j_P, "au0"), "g": 90.0, "sz": 2.0})
	game.effects.f_psDraw()
	J.setv(game.j_ctx, "globalAlpha", 0.55)
	game.f_fr(0.0, 0.0, game.j_W, 34.0, "#0a0a12")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.text_draw.f_txt(J.add(J.add(game.localization.f_T("GECE — GÜN "), (J.getv(game.j_G, "day") - 1.0)), game.localization.f_T(" BİTTİ")), (float(game.j_W) / float(2.0)), 6.0, J.getv(game.j_P, "ui1"), {"align": "c"})
	if J.ge(J.getv(v_N, "phase"), 1.0):
		game.text_draw.f_txt(("DÜKKÂNA GİREN VAR!" if J.truth(J.getv(v_N, "stole")) else "GÜVENLİK İŞ BAŞINDA"), (float(game.j_W) / float(2.0)), 18.0, (J.getv(game.j_P, "bad") if J.truth(J.getv(v_N, "stole")) else J.getv(game.j_P, "ok")), {"align": "c", "sc": 1.0})
	if (J.eq(J.getv(v_N, "phase"), 2.0) and J.gt(J.getv(v_N, "t"), 4.2)):
		v_by2 = 176.0
		v_bw2 = 250.0
		v_bx2 = ((float(game.j_W) / float(2.0)) - (float(v_bw2) / float(2.0)))
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_rrect(J.add(v_bx2, 2.0), J.add(v_by2, 3.0), v_bw2, 62.0, 4.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_bx2, v_by2, v_bw2, 62.0, 4.0, ("#5a1a14" if J.truth(J.getv(v_N, "stole")) else "#1a4a24"))
		game.f_rrect(J.add(v_bx2, 2.0), J.add(v_by2, 2.0), (v_bw2 - 4.0), 58.0, 3.0, J.getv(game.j_P, "ui0"))
		game.f_rrectOut(v_bx2, v_by2, v_bw2, 62.0, 4.0, J.getv(game.j_P, "ui5"))
		game.text_draw.f_txt(J.getv(v_N, "line"), (float(game.j_W) / float(2.0)), J.add(v_by2, 8.0), J.getv(game.j_P, "ink"), {"align": "c"})
		if J.truth(J.getv(v_N, "stole")):
			game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_N, "amount"))), (float(game.j_W) / float(2.0)), J.add(v_by2, 20.0), J.getv(game.j_P, "bad"), {"align": "c", "sc": 1.0})
			game.text_draw.f_txt((game.localization.f_T("Dükkânda hiç güvenlik yok.") if J.eq(J.getv(v_N, "sec"), 0.0) else J.add(game.localization.f_T(J.method(game.j_TUN, "secName", [game.j_G])), game.localization.f_T(" yetmedi."))), (float(game.j_W) / float(2.0)), J.add(v_by2, 34.0), J.getv(game.j_P, "ui3"), {"align": "c"})
		else:
			game.text_draw.f_txt((game.localization.f_T("Şansın varmış!") if J.eq(J.getv(v_N, "sec"), 0.0) else J.add(game.localization.f_T(J.method(game.j_TUN, "secName", [game.j_G])), game.localization.f_T(" işe yaradı."))), (float(game.j_W) / float(2.0)), J.add(v_by2, 22.0), J.getv(game.j_P, "ok"), {"align": "c"})
			game.text_draw.f_txt("Kasada tek kuruş eksilmedi.", (float(game.j_W) / float(2.0)), J.add(v_by2, 34.0), J.getv(game.j_P, "ui3"), {"align": "c"})
		if J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 46.0), J.add(v_by2, 42.0), 92.0, 16.0, J.add(game.localization.f_T("GÜN "), J.getv(game.j_G, "day")), "#3f8a4a", true)):
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_G, "night", null)
			J.setv(game.j_G, "scene", "intro")
			J.setv(game.j_G, "sceneT", 0.0)
	game.effects.f_ftDraw()
	return null

