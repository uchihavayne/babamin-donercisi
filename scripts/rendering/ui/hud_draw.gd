# Hud draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:48
func f_hudSagKenar() -> Variant:
	return ((game.j_W - J.getv(game.j_VIEW, "right")) - (8.0 if J.truth(game.j_TOUCH) else 0.0))
	return null

# ui.js:49
func f_hudCoinPos() -> Variant:
	var v_ms: Variant = null
	var v_mw: Variant = null
	v_ms = J.add("$", game.math_utils.f_fmtMoney(J.getv(game.j_G, "money")))
	v_mw = J.add(game.f_textW(v_ms, 1.0, true), 26.0)
	return [J.add(((game.hud_draw.f_hudSagKenar() - 28.0) - v_mw), 9.0), J.add(12.0, J.getv(game.j_VIEW, "top"))]
	return null

# ui.js:54
func f_drawHUD(p_t: Variant = null) -> Variant:
	var v_kompakt: Variant = null
	var v_cx: Variant = null
	var v_cy: Variant = null
	var v_tx: Variant = null
	var v_th: Variant = null
	var v_ty0: Variant = null
	var v_tl: Variant = null
	var v_low: Variant = null
	var v_tcol: Variant = null
	var v_Wr: Variant = null
	var v_fk: Variant = null
	var v_mval: Variant = null
	var v_ms: Variant = null
	var v_mw: Variant = null
	var v_mx: Variant = null
	var v_mpop: Variant = null
	var v_wx: Variant = null
	var v_wy: Variant = null
	var v_ri: Variant = null
	var v_ry2: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_ki: Variant = null
	var v_ky2: Variant = null
	var v_sx4: Variant = null
	var v_sy4: Variant = null
	var v_si4: Variant = null
	var v_a4: Variant = null
	var v_mgw: Variant = null
	var v_mgx: Variant = null
	var v_mgy: Variant = null
	var v_ds: Variant = null
	var v_dw: Variant = null
	var v_dx: Variant = null
	var v_prog: Variant = null
	var v_sold: Variant = null
	var v_ss: Variant = null
	var v_sw: Variant = null
	var v_sx2: Variant = null
	var v_t: Variant = p_t
	J.method(game.j_ctx, "save", [])
	if J.truth(J.getv(game.j_VIEW, "top")):
		J.method(game.j_ctx, "translate", [0.0, J.getv(game.j_VIEW, "top")])
	v_kompakt = J.gt(J.getv(game.j_VIEW, "top"), 0.0)
	v_cx = 6.0
	v_cy = 3.0
	if J.truth(v_kompakt):
		# REMAKE kancasi: HD takvim kutusu
		if not J.truth(game.f_hdHudGun(v_cx, J.add(v_cy, 1.0), true)):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_rrect(J.add(v_cx, 1.0), J.add(v_cy, 3.0), 30.0, 16.0, 3.0, "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_rrect(v_cx, J.add(v_cy, 1.0), 30.0, 16.0, 3.0, "#f2ece0")
			game.f_rrect(v_cx, J.add(v_cy, 1.0), 30.0, 6.0, 3.0, "#c0281c")
		game.text_draw.f_txt(J.add("", J.getv(game.j_G, "day")), J.add(v_cx, 15.0), J.add(v_cy, 8.0), J.getv(game.j_P, "ink"), {"align": "c"})
		game.f_rrectOut(v_cx, J.add(v_cy, 1.0), 30.0, 16.0, 3.0, "#8a7a60")
	else:
		if not J.truth(game.f_hdHudGun(v_cx, v_cy, false)):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_rrect(J.add(v_cx, 1.0), J.add(v_cy, 2.0), 30.0, 26.0, 3.0, "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_rrect(v_cx, v_cy, 30.0, 26.0, 3.0, "#f2ece0")
			game.f_rrect(v_cx, v_cy, 30.0, 8.0, 3.0, "#c0281c")
			game.f_rrect(J.add(v_cx, 1.0), J.add(v_cy, 1.0), 28.0, 6.0, 2.0, "#e2483a")
		game.text_draw.f_txt("GÜN", J.add(v_cx, 15.0), J.add(v_cy, 1.0), J.getv(game.j_P, "white"), {"align": "c"})
		game.text_draw.f_txt(J.add("", J.getv(game.j_G, "day")), J.add(v_cx, 15.0), J.add(v_cy, 12.0), J.getv(game.j_P, "ink"), {"align": "c"})
		game.f_vl(J.add(v_cx, 6.0), (v_cy - 3.0), 4.0, "#8a8a90")
		game.f_vl(J.add(v_cx, 23.0), (v_cy - 3.0), 4.0, "#8a8a90")
		game.f_rrectOut(v_cx, v_cy, 30.0, 26.0, 3.0, "#8a7a60")
	v_tx = 40.0
	v_th = (16.0 if J.truth(v_kompakt) else 20.0)
	v_ty0 = (J.add(v_cy, 1.0) if J.truth(v_kompakt) else v_cy)
	# REMAKE kancasi: HD sure kasasi
	if not J.truth(game.f_hdHudSure(v_tx, v_ty0, v_kompakt)):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_rrect(J.add(v_tx, 1.0), J.add(v_ty0, 2.0), 42.0, v_th, 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_tx, v_ty0, 42.0, v_th, 3.0, "#7a5230")
		game.f_rrect(J.add(v_tx, 1.0), J.add(v_ty0, 1.0), 40.0, (v_th - 2.0), 3.0, "#9c6b3f")
		game.f_rrect(J.add(v_tx, 3.0), J.add(v_ty0, 3.0), 36.0, (v_th - 6.0), 2.0, "#241a14")
	v_tl = (J.getv(game.j_G, "timeLeft") if J.eq(J.getv(game.j_G, "scene"), "play") else 0.0)
	v_low = (J.gt(v_tl, 0.0) if J.lt(v_tl, 20.0) else J.lt(v_tl, 20.0))
	v_tcol = (("#ff5a3a" if J.gt(sin((v_t * 10.0)), 0.0) else "#a03020") if J.truth(v_low) else "#ff9a4a")
	game.text_draw.f_txt(game.math_utils.f_fmtTime(v_tl), J.add(v_tx, 21.0), J.add(v_ty0, (5.0 if J.truth(v_kompakt) else 6.0)), v_tcol, {"align": "c", "mono": true})
	if (not J.truth(v_kompakt)):
		game.f_vl(J.add(v_tx, 8.0), (v_cy - 3.0), 4.0, "#8a8a90")
		game.f_vl(J.add(v_tx, 33.0), (v_cy - 3.0), 4.0, "#8a8a90")
	v_Wr = game.hud_draw.f_hudSagKenar()
	# REMAKE kancasi: HD mola dugmesi
	if not J.truth(game.f_hdHudMola((v_Wr - 22.0), 4.0)):
		game.f_rrect((v_Wr - 22.0), 4.0, 18.0, 16.0, 3.0, "rgba(30,20,16,.75)")
		game.f_fr((v_Wr - 17.0), 8.0, 3.0, 8.0, J.getv(game.j_P, "ui0"))
		game.f_fr((v_Wr - 12.0), 8.0, 3.0, 8.0, J.getv(game.j_P, "ui0"))
	v_fk = (game.household_system.f_fkasaAcik() if J.eq(J.kind(J.ref(game.household_system.f_fkasaAcik, 0)), "function") else J.eq(J.kind(J.ref(game.household_system.f_fkasaAcik, 0)), "function"))
	v_mval = ((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0) if J.truth(v_fk) else J.getv(game.j_G, "money"))
	v_ms = J.add(("-" if J.lt(v_mval, 0.0) else ""), game.math_utils.f_fmtShort(abs(v_mval)))
	v_mw = J.add(game.f_textW(v_ms, 1.0, true), 26.0)
	v_mx = ((v_Wr - 28.0) - v_mw)
	v_mpop = (J.getv(game.j_G, "hudPop") if J.gt(J.getv(game.j_G, "hudPop"), 0.0) else 0.0)
	if J.gt(v_mpop, 0.0):
		J.setv(game.j_ctx, "globalAlpha", (v_mpop * 0.5))
		game.f_rrect((v_mx - 2.0), 2.0, J.add(v_mw, 4.0), 20.0, 5.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi: HD para plakasi
	if not J.truth(game.f_hdHudPara(v_mx, 4.0, v_mw, 16.0)):
		game.f_rrect(v_mx, 4.0, v_mw, 16.0, 4.0, "rgba(30,20,16,.78)")
		game.f_rrectOut(v_mx, 4.0, v_mw, 16.0, 4.0, (J.getv(game.j_P, "au0") if J.gt(v_mpop, 0.0) else "rgba(255,220,140,.35)"))
	elif J.gt(v_mpop, 0.0):
		game.f_rrectOut(v_mx, 4.0, v_mw, 16.0, 4.0, J.getv(game.j_P, "au0"))
	game.icon_draw.f_icon("coin", J.add(v_mx, 9.0), (12.0 - floor((v_mpop * 2.0) + 0.5)), v_t)
	game.text_draw.f_txt(v_ms, (J.add(v_mx, v_mw) - 5.0), (8.0 - floor((v_mpop * 2.0) + 0.5)), ("#ff6a56" if J.lt(v_mval, 0.0) else J.getv(game.j_P, "au0")), {"align": "r", "mono": true})
	if J.eq(J.getv(game.j_G, "weather"), "rain"):
		v_wx = 8.0
		v_wy = (22.0 if J.truth(v_kompakt) else 32.0)
		J.setv(game.j_ctx, "globalAlpha", 0.85)
		game.f_rrect((v_wx - 2.0), (v_wy - 2.0), 28.0, 14.0, 3.0, "rgba(30,40,60,.8)")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		# REMAKE kancasi: HD hava ikonu (Blender bulut/gunes, yarim piksel damla)
		if not J.truth(game.f_hdHava("rain", v_wx, v_wy, v_t)):
			game.f_ell(J.add(v_wx, 6.0), J.add(v_wy, 4.0), 5.0, 3.0, "#c6d4e2")
			game.f_ell(J.add(v_wx, 10.0), J.add(v_wy, 3.0), 4.0, 3.0, "#e2ecf6")
			v_ri = 0.0
			while J.lt(v_ri, 3.0):
				v_ry2 = J.add(J.add(v_wy, 6.0), fmod(J.n(J.add((v_t * 22.0), (v_ri * 4.0))), J.n(6.0)))
				game.f_px(J.add(J.add(v_wx, 3.0), (v_ri * 4.0)), v_ry2, "#6b9ad8")
				game.f_px(J.add(J.add(v_wx, 3.0), (v_ri * 4.0)), J.add(v_ry2, 1.0), "#8fb8e0")
				v_ri = J.add(v_ri, 1.0)
		game.text_draw.f_txt("YAĞMUR", J.add(v_wx, 28.0), J.add(v_wy, 1.0), "#8fb8e0")
	else:
		if J.eq(J.getv(game.j_G, "weather"), "kar"):
			v_kx = 8.0
			v_ky = (22.0 if J.truth(v_kompakt) else 32.0)
			J.setv(game.j_ctx, "globalAlpha", 0.85)
			game.f_rrect((v_kx - 2.0), (v_ky - 2.0), 28.0, 14.0, 3.0, "rgba(40,58,80,.8)")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			# REMAKE kancasi: HD hava ikonu (Blender bulut/gunes, yarim piksel damla)
			if not J.truth(game.f_hdHava("kar", v_kx, v_ky, v_t)):
				game.f_ell(J.add(v_kx, 6.0), J.add(v_ky, 4.0), 5.0, 3.0, "#dbe7f2")
				game.f_ell(J.add(v_kx, 10.0), J.add(v_ky, 3.0), 4.0, 3.0, "#f4f9ff")
				v_ki = 0.0
				while J.lt(v_ki, 3.0):
					v_ky2 = J.add(J.add(v_ky, 6.0), fmod(J.n(J.add((v_t * 12.0), (v_ki * 4.0))), J.n(6.0)))
					game.f_px(J.add(J.add(v_kx, 3.0), (v_ki * 4.0)), v_ky2, "#ffffff")
					game.f_px(J.add(J.add(v_kx, 4.0), (v_ki * 4.0)), J.add(v_ky2, 1.0), "#cfe2f4")
					v_ki = J.add(v_ki, 1.0)
			game.text_draw.f_txt("KAR", J.add(v_kx, 28.0), J.add(v_ky, 1.0), "#dbe7f2")
		else:
			if J.eq(J.getv(game.j_G, "weather"), "sicak"):
				v_sx4 = 8.0
				v_sy4 = (22.0 if J.truth(v_kompakt) else 32.0)
				J.setv(game.j_ctx, "globalAlpha", 0.85)
				game.f_rrect((v_sx4 - 2.0), (v_sy4 - 2.0), 28.0, 14.0, 3.0, "rgba(70,40,10,.8)")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				# REMAKE kancasi: HD hava ikonu (Blender bulut/gunes, yarim piksel damla)
				if not J.truth(game.f_hdHava("sicak", v_sx4, v_sy4, v_t)):
					game.f_disc(J.add(v_sx4, 7.0), J.add(v_sy4, 5.0), 4.0, "#ffd257")
					v_si4 = 0.0
					while J.lt(v_si4, 8.0):
						v_a4 = J.add((v_si4 * 0.785), (sin((v_t * 1.6)) * 0.12))
						game.f_px(J.add(J.add(v_sx4, 7.0), floor((cos(v_a4) * 6.0) + 0.5)), J.add(J.add(v_sy4, 5.0), floor((sin(v_a4) * 6.0) + 0.5)), "#ffb23c")
						v_si4 = J.add(v_si4, 1.0)
				game.text_draw.f_txt("SICAK", J.add(v_sx4, 28.0), J.add(v_sy4, 1.0), "#ffc86a")
	if (J.eq(J.kind(J.ref(game.weather_system.f_macDalgada, 0)), "function") and J.truth(game.weather_system.f_macDalgada())):
		v_mgw = J.add(game.f_textW(game.localization.f_T("MAÇ ÇIKIŞI")), 12.0)
		v_mgx = ((float(game.j_W) / float(2.0)) - (float(v_mgw) / float(2.0)))
		v_mgy = (22.0 if J.truth(v_kompakt) else 32.0)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.3 * sin((v_t * 6.0)))))
		game.f_rrect(v_mgx, v_mgy, v_mgw, 12.0, 3.0, "rgba(20,60,20,.85)")
		game.f_rrectOut(v_mgx, v_mgy, v_mgw, 12.0, 3.0, "#8ad86a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.text_draw.f_txt(game.localization.f_T("MAÇ ÇIKIŞI"), (float(game.j_W) / float(2.0)), J.add(v_mgy, 3.0), "#b8f09a", {"align": "c"})
	if J.gt(J.getv(game.j_G, "debt"), 0.0):
		v_ds = J.add("$", game.math_utils.f_fmtShort(J.getv(game.j_G, "debt")))
		v_dw = J.add(J.add(game.f_textW("BORÇ"), game.f_textW(v_ds)), 16.0)
		v_dx = 88.0
		game.f_rrect(v_dx, 4.0, v_dw, 16.0, 4.0, "rgba(60,16,12,.85)")
		game.f_rrectOut(v_dx, 4.0, v_dw, 16.0, 4.0, "#a83a2a")
		game.text_draw.f_txt("BORÇ", J.add(v_dx, 5.0), 8.0, "#ff9a8a")
		game.text_draw.f_txt(v_ds, (J.add(v_dx, v_dw) - 5.0), 8.0, "#ffd0c0", {"align": "r"})
		v_prog = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "debt")) / float(game.j_DEBT_START)), 0.0, 1.0))
		game.f_fr(J.add(v_dx, 2.0), 18.0, (v_dw - 4.0), 2.0, "rgba(0,0,0,.5)")
		game.f_fr(J.add(v_dx, 2.0), 18.0, floor(((v_dw - 4.0) * v_prog) + 0.5), 2.0, J.getv(game.j_P, "ok"))
	v_sold = (J.add(J.add(J.add(J.getv(J.getv(game.j_G, "stat"), "wraps"), J.getv(J.getv(game.j_G, "stat"), "drinks")), J.getv(J.getv(game.j_G, "stat"), "boxes")), (J.getv(J.getv(game.j_G, "stat"), "sweets") if J.truth(J.getv(J.getv(game.j_G, "stat"), "sweets")) else 0.0)) if J.truth(J.getv(game.j_G, "stat")) else 0.0)
	v_ss = J.add("", v_sold)
	v_sw = J.add(game.f_textW(v_ss, 1.0, true), 26.0)
	v_sx2 = ((v_mx - 4.0) - v_sw)
	game.f_rrect(v_sx2, 4.0, v_sw, 16.0, 4.0, "rgba(30,20,16,.78)")
	game.f_rrectOut(v_sx2, 4.0, v_sw, 16.0, 4.0, "rgba(255,220,140,.22)")
	game.icon_draw.f_icon("wrap", J.add(v_sx2, 10.0), 12.0, v_t)
	game.text_draw.f_txt(v_ss, (J.add(v_sx2, v_sw) - 5.0), 8.0, J.getv(game.j_P, "ui0"), {"align": "r", "mono": true})
	J.method(game.j_ctx, "restore", [])
	return null

