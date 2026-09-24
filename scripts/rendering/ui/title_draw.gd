# Title draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:513
func f_drawTitle(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_t: Variant = p_t
	if J.eq(J.kind(J.ref(game.logo_draw.f_logoGiris, 1)), "function"):
		game.logo_draw.f_logoGiris(v_t)
	game.interface_draw.f_drawShopStatic(v_t, false)
	if J.truth(J.getv(game.j_BSP, "open")):
		game.achievement_draw.f_drawBasarimPanel(v_t)
		return null
	if J.truth(J.getv(game.j_STATS, "open")):
		game.achievement_draw.f_drawStatsPanel(v_t)
		return null
	if J.truth(J.getv(game.j_SESP, "open")):
		game.settings_draw.f_drawSesPanel(v_t)
		return null
	J.setv(game.j_ctx, "globalAlpha", 0.52)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#180d07")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 60.0):
		J.setv(game.j_ctx, "globalAlpha", (float((0.012 * (60.0 - v_i))) / float(6.0)))
		game.f_rrectOut((-J.n(v_i)), (-J.n(v_i)), J.add(game.j_W, (v_i * 2.0)), J.add(game.j_H, (v_i * 2.0)), 8.0, "#000")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (not J.eq(J.kind(J.ref(game.logo_draw.f_logoCiz, 3)), "function") or (not J.truth(game.logo_draw.f_logoCiz(v_t, (float(game.j_W) / float(2.0)), game.title_draw.f_baslikLogoUst())))):
		game.title_draw.f_eskiTabela(v_t)
	game.effects.f_psDraw()
	game.title_draw.f_drawTitleMenu(v_t)
	return null

# ui.js:539
func f_baslikLogoUst() -> Variant:
	return (J.add(J.getv(game.j_VIEW, "top"), 1.0) if J.truth(J.getv(game.j_VIEW, "top")) else 24.0)
	return null

# ui.js:540
func f_baslikLogoAlt() -> Variant:
	return J.add(game.title_draw.f_baslikLogoUst(), (game.logo_draw.f_logoYukseklik() if J.eq(J.kind(J.ref(game.logo_draw.f_logoYukseklik, 0)), "function") else 56.0))
	return null

# ui.js:546
func f_eskiTabela(p_t: Variant = null) -> Variant:
	var v_ly: Variant = null
	var v_lw: Variant = null
	var v_b2: Variant = null
	var v_on: Variant = null
	var v_bx2: Variant = null
	var v_t: Variant = p_t
	v_ly = J.add((J.add(J.getv(game.j_VIEW, "top"), 6.0) if J.truth(J.getv(game.j_VIEW, "top")) else 34.0), (sin((v_t * 1.6)) * 2.0))
	v_lw = 258.0
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), 3.0), J.add(v_ly, 4.0), v_lw, 56.0, 6.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), v_ly, v_lw, 56.0, 6.0, J.getv(game.j_P, "red3"))
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), 2.0), J.add(v_ly, 2.0), (v_lw - 4.0), 52.0, 5.0, J.getv(game.j_P, "red1"))
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), 4.0), J.add(v_ly, 4.0), (v_lw - 8.0), 48.0, 4.0, J.getv(game.j_P, "red0"))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), 4.0), J.add(v_ly, 4.0), (v_lw - 8.0), 16.0, 4.0, "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrectOut(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), v_ly, v_lw, 56.0, 6.0, J.getv(game.j_P, "ui5"))
	v_b2 = 0.0
	while J.lt(v_b2, 11.0):
		v_on = J.gt(sin(J.add((v_t * 5.0), (v_b2 * 0.7))), (-J.n(0.35)))
		v_bx2 = J.add(J.add(((float(game.j_W) / float(2.0)) - (float(v_lw) / float(2.0))), 10.0), (v_b2 * 24.0))
		game.f_disc(v_bx2, (v_ly - 1.0), 2.0, (J.getv(game.j_P, "au0") if J.truth(v_on) else "#7a6a3a"))
		game.f_disc(v_bx2, J.add(v_ly, 55.0), 2.0, (J.getv(game.j_P, "au0") if J.truth(v_on) else "#7a6a3a"))
		if J.truth(v_on):
			J.setv(game.j_ctx, "globalAlpha", 0.22)
			game.f_disc(v_bx2, (v_ly - 1.0), 4.0, J.getv(game.j_P, "au1"))
			game.f_disc(v_bx2, J.add(v_ly, 55.0), 4.0, J.getv(game.j_P, "au1"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_b2 = J.add(v_b2, 1.0)
	game.text_draw.f_txt("BABAMIN", (float(game.j_W) / float(2.0)), J.add(v_ly, 8.0), J.getv(game.j_P, "white"), {"align": "c", "sc": 2.0, "outline": J.getv(game.j_P, "ui5")})
	game.text_draw.f_txt("DÖNERCİSİ", (float(game.j_W) / float(2.0)), J.add(v_ly, 30.0), J.getv(game.j_P, "au0"), {"align": "c", "sc": 3.0, "outline": J.getv(game.j_P, "ui5")})
	game.icon_draw.f_icon("wrap", ((float(game.j_W) / float(2.0)) - 108.0), J.add(v_ly, 30.0), v_t)
	game.icon_draw.f_icon("wrap", J.add((float(game.j_W) / float(2.0)), 108.0), J.add(v_ly, 30.0), v_t)
	if J.truth(game.f_chance(0.25)):
		game.effects.f_part({"x": game.math_utils.f_rnd(((float(game.j_W) / float(2.0)) - 130.0), J.add((float(game.j_W) / float(2.0)), 130.0)), "y": J.add(v_ly, 58.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(28.0)), (-J.n(12.0))), "life": game.math_utils.f_rnd(0.5, 1.0), "col": game.math_utils.f_pick([J.getv(game.j_P, "f1"), J.getv(game.j_P, "f2"), J.getv(game.j_P, "f0")]), "g": (-J.n(10.0)), "sz": 1.0})
	return null

# ui.js:572
func f_drawTitleMenu(p_t: Variant = null) -> Variant:
	var v_hasSave: Variant = null
	var v_yigin: Variant = null
	var v_ust: Variant = null
	var v_sy: Variant = null
	var v_sh: Variant = null
	var v_bw: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_yy: Variant = null
	var v_kx3: Variant = null
	var v_t: Variant = p_t
	v_hasSave = (not (not J.truth(game.f_loadGame())))
	v_yigin = (76.0 if J.truth(v_hasSave) else 54.0)
	v_ust = J.add(game.title_draw.f_baslikLogoAlt(), 3.0)
	v_sy = (((game.j_H - J.getv(game.j_VIEW, "bot")) - 38.0) - 24.0)
	v_sh = 22.0
	if J.gt(J.add(v_ust, v_yigin), (v_sy - 2.0)):
		v_sy = J.add(v_sy, 10.0)
		v_sh = 12.0
	v_bw = 132.0
	v_bx = floor(((float(game.j_W) / float(2.0)) - (float(v_bw) / float(2.0))) + 0.5)
	v_by = max(v_ust, floor(J.add(v_ust, (float((((v_sy - 2.0) - v_ust) - v_yigin)) / float(2.0))) + 0.5))
	if J.truth(v_hasSave):
		if J.truth(game.f_button(v_bx, v_by, v_bw, 26.0, "DEVAM ET", "#3f8a4a", true)):
			J.method(game.j_SFX, "ui", [])
			game.save_system.f_loadAndGo()
		if J.truth(game.f_button(v_bx, J.add(v_by, 30.0), v_bw, 22.0, "YENİ OYUN", J.getv(game.j_P, "red1"))):
			J.method(game.j_SFX, "ui", [])
			game.f_clearSave()
			game.session_system.f_resetProgress()
			game.session_system.f_goIntro()
	else:
		if J.truth(game.f_button(v_bx, v_by, v_bw, 30.0, "BAŞLA", J.getv(game.j_P, "red1"), true)):
			J.method(game.j_SFX, "ui", [])
			game.session_system.f_goIntro()
	v_yy = J.add(v_by, (56.0 if J.truth(v_hasSave) else 34.0))
	v_kx3 = floor(((float(game.j_W) / float(2.0)) - 78.0) + 0.5)
	if J.truth(game.f_button(v_kx3, v_yy, 50.0, 20.0, "SES", "#3f8ac0")):
		J.setv(game.j_SESP, "open", true)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_button(J.add(v_kx3, 53.0), v_yy, 50.0, 20.0, "REKOR", "#3f6fbd")):
		J.setv(game.j_STATS, "open", true)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_button(J.add(v_kx3, 106.0), v_yy, 50.0, 20.0, "BAŞARIM", "#b0862a")):
		J.setv(game.j_BSP, "open", true)
		J.method(game.j_SFX, "ui", [])
	if ((not J.truth(game.j_TOUCH)) and J.truth(game.f_button(8.0, 246.0, 84.0, 18.0, ("PENCERE" if J.truth(game.f_fsOn()) else "TAM EKRAN"), "#7a5aa0"))):
		J.method(game.j_SFX, "ui", [])
		game.f_fsToggle()
	J.setv(game.j_ctx, "globalAlpha", 0.7)
	game.f_rrect(((float(game.j_W) / float(2.0)) - 140.0), v_sy, 280.0, v_sh, 4.0, "rgba(20,12,8,.75)")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(v_sh, 12.0):
		game.text_draw.f_txt(J.add(game.localization.f_T("En iyi: Gün "), (J.getv(game.j_G, "best") if J.truth(J.getv(game.j_G, "best")) else 1.0)), (float(game.j_W) / float(2.0)), J.add(v_sy, 2.0), J.getv(game.j_P, "au1"), {"align": "c"})
		game.text_draw.f_txt(J.getv(game.j_TIPS_LOAD, fmod(J.n(floor((float(v_t) / float(4.0)))), J.n(J.getv(game.j_TIPS_LOAD, "length")))), (float(game.j_W) / float(2.0)), J.add(v_sy, 12.0), J.getv(game.j_P, "ui1"), {"align": "c"})
	else:
		if J.eq(fmod(J.n(floor((float(v_t) / float(4.0)))), J.n(2.0)), 0.0):
			game.text_draw.f_txt(J.add(game.localization.f_T("En iyi: Gün "), (J.getv(game.j_G, "best") if J.truth(J.getv(game.j_G, "best")) else 1.0)), (float(game.j_W) / float(2.0)), J.add(v_sy, 2.0), J.getv(game.j_P, "au1"), {"align": "c"})
		else:
			game.text_draw.f_txt(J.getv(game.j_TIPS_LOAD, fmod(J.n(floor((float(v_t) / float(8.0)))), J.n(J.getv(game.j_TIPS_LOAD, "length")))), (float(game.j_W) / float(2.0)), J.add(v_sy, 2.0), J.getv(game.j_P, "ui1"), {"align": "c"})
	game.f_langButtons(((float(game.j_W) / float(2.0)) - 86.0), ((game.j_H - J.getv(game.j_VIEW, "bot")) - 38.0))
	game.effects.f_ftDraw()
	return null

# ui.js:622
func f_drawTitleBasarim(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	if J.truth(J.getv(game.j_BSP, "open")):
		game.achievement_draw.f_drawBasarimPanel(v_t)
	return null

# ui.js:651
func f_drawIntro(p_t: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_sy: Variant = null
	var v_yagmur: Variant = null
	var v_havaVar: Variant = null
	var v_satir: Variant = null
	var v_ph: Variant = null
	var v_y: Variant = null
	var v_cfg: Variant = null
	var v_sy2: Variant = null
	var v_t: Variant = p_t
	game.interface_draw.f_drawShopStatic(v_t, false)
	J.setv(game.j_ctx, "globalAlpha", 0.55)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#140a06")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_k = game.math_utils.f_clamp((J.getv(game.j_G, "sceneT") * 2.2), 0.0, 1.0)
	if J.eq(J.getv(game.j_G, "day"), 1.0):
		v_sy = game.math_utils.f_lerp((-J.n(120.0)), 40.0, game.math_utils.f_easeOutBack(v_k))
		game.interface_draw.f_panel(((float(game.j_W) / float(2.0)) - 120.0), v_sy, 240.0, 122.0, "USTA DÖNER")
		game.text_draw.f_txt("Baban vefat etti.", (float(game.j_W) / float(2.0)), J.add(v_sy, 12.0), J.getv(game.j_P, "ink"), {"align": "c"})
		game.text_draw.f_txt("Dükkân sana kaldı…", (float(game.j_W) / float(2.0)), J.add(v_sy, 24.0), J.getv(game.j_P, "ink"), {"align": "c"})
		game.text_draw.f_txt("ama üzerinde ağır bir borç var:", (float(game.j_W) / float(2.0)), J.add(v_sy, 40.0), J.getv(game.j_P, "ui4"), {"align": "c"})
		game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(game.j_DEBT_START)), (float(game.j_W) / float(2.0)), J.add(v_sy, 52.0), "#a83a2a", {"align": "c", "sc": 2.0})
		game.text_draw.f_txt("Tezgâhta kazan, dükkânı büyüt,", (float(game.j_W) / float(2.0)), J.add(v_sy, 74.0), J.getv(game.j_P, "ui4"), {"align": "c"})
		game.text_draw.f_txt("şehre şube aç. Borcu kapat,", (float(game.j_W) / float(2.0)), J.add(v_sy, 84.0), J.getv(game.j_P, "ui4"), {"align": "c"})
		game.text_draw.f_txt("babanın dükkânını kurtar!", (float(game.j_W) / float(2.0)), J.add(v_sy, 94.0), J.getv(game.j_P, "ui4"), {"align": "c"})
		if (J.gt(J.getv(game.j_G, "sceneT"), 0.5) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 46.0), J.add(v_sy, 104.0), 92.0, 16.0, "DÜKKÂNI AÇ", "#3f8a4a", true))):
			J.method(game.j_SFX, "bell", [])
			game.f_startDay()
		game.effects.f_psDraw()
		game.effects.f_ftDraw()
		return null
	if J.truth(game.progression_system.f_fermanSehri(game.j_G)):
		game.newspaper_draw.f_drawGazete(v_t, v_k)
		return null
	v_yagmur = J.eq(J.getv(game.j_G, "weather"), "rain")
	v_havaVar = ((v_yagmur if J.truth(v_yagmur) else J.eq(J.getv(game.j_G, "weather"), "kar")) if (J.truth(v_yagmur) or J.eq(J.getv(game.j_G, "weather"), "kar")) else J.eq(J.getv(game.j_G, "weather"), "sicak"))
	v_satir = J.add((1.0 if J.truth(v_havaVar) else 0.0), (1.0 if J.truth(J.getv(game.j_G, "macGun")) else 0.0))
	v_ph = J.add(84.0, (v_satir * 24.0))
	v_y = game.math_utils.f_lerp((-J.n(60.0)), ((68.0 - ((v_satir - 1.0) * 8.0)) if J.truth(v_satir) else 80.0), game.math_utils.f_easeOutBack(v_k))
	game.interface_draw.f_panel(((float(game.j_W) / float(2.0)) - 96.0), v_y, 192.0, v_ph)
	game.text_draw.f_txt(J.add(game.localization.f_T("GÜN "), J.getv(game.j_G, "day")), (float(game.j_W) / float(2.0)), J.add(v_y, 10.0), J.getv(game.j_P, "red1"), {"align": "c", "sc": 2.0})
	v_cfg = game.progression_system.f_dayCfg(J.getv(game.j_G, "day"), game.j_G)
	v_sy2 = J.add(v_y, 34.0)
	game.text_draw.f_txt(J.add(J.add(J.add(game.localization.f_T("Süre: "), game.math_utils.f_fmtTime(J.getv(v_cfg, "len"))), game.localization.f_T("    Sıra: ")), J.getv(v_cfg, "slots")), (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ui3"), {"align": "c"})
	v_sy2 = J.add(v_sy2, 12.0)
	if J.gt(J.getv(game.j_G, "debt"), 0.0):
		game.text_draw.f_txt(J.add(J.add(game.localization.f_T("Kalan borç: $"), game.math_utils.f_fmtMoney(J.getv(game.j_G, "debt"))), (J.add(J.add("   •   ", J.getv(game.j_G, "branch")), game.localization.f_T(" şube")) if J.truth(J.getv(game.j_G, "branch")) else "")), (float(game.j_W) / float(2.0)), v_sy2, "#a83a2a", {"align": "c"})
	else:
		game.text_draw.f_txt("Borç bitti — dükkân tamamen senin!", (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ok"), {"align": "c"})
	v_sy2 = J.add(v_sy2, 12.0)
	if J.truth(v_yagmur):
		game.text_draw.f_txt("☂ YAĞMURLU GÜN", (float(game.j_W) / float(2.0)), v_sy2, "#6b9ad8", {"align": "c"})
		v_sy2 = J.add(v_sy2, 10.0)
		game.text_draw.f_txt("az müşteri • bol paket sipariş", (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ui3"), {"align": "c"})
		v_sy2 = J.add(v_sy2, 12.0)
	else:
		if J.eq(J.getv(game.j_G, "weather"), "kar"):
			game.text_draw.f_txt("KARLI GÜN", (float(game.j_W) / float(2.0)), v_sy2, "#dbe7f2", {"align": "c"})
			v_sy2 = J.add(v_sy2, 10.0)
			game.text_draw.f_txt("seyrek müşteri • sabırlı • bahşiş bol", (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ui3"), {"align": "c"})
			v_sy2 = J.add(v_sy2, 12.0)
		else:
			if J.eq(J.getv(game.j_G, "weather"), "sicak"):
				game.text_draw.f_txt("SICAK DALGASI", (float(game.j_W) / float(2.0)), v_sy2, "#ffc86a", {"align": "c"})
				v_sy2 = J.add(v_sy2, 10.0)
				game.text_draw.f_txt("herkes içecek ister • sabır az • ızgara çabuk yakar", (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ui3"), {"align": "c"})
				v_sy2 = J.add(v_sy2, 12.0)
	if J.truth(J.getv(game.j_G, "macGun")):
		game.text_draw.f_txt("MAÇ GÜNÜ", (float(game.j_W) / float(2.0)), v_sy2, "#8ad86a", {"align": "c"})
		v_sy2 = J.add(v_sy2, 10.0)
		game.text_draw.f_txt("gün ortasında taraftar akını — acele ederler, bahşiş bol", (float(game.j_W) / float(2.0)), v_sy2, J.getv(game.j_P, "ui3"), {"align": "c"})
		v_sy2 = J.add(v_sy2, 12.0)
	if (J.gt(J.getv(game.j_G, "sceneT"), 0.4) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 46.0), J.add(v_sy2, 2.0), 92.0, 18.0, "DÜKKÂNI AÇ", "#3f8a4a", true))):
		J.method(game.j_SFX, "bell", [])
		game.f_startDay()
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	return null

# ui.js:1318
func f_drawDebtFree(p_t: Variant = null) -> Variant:
	var v_C: Variant = null
	var v_k: Variant = null
	var v_yy: Variant = null
	var v_bw: Variant = null
	var v_bx: Variant = null
	var v_px2: Variant = null
	var v_py2: Variant = null
	var v_fx2: Variant = null
	var v_fy2: Variant = null
	var v_t: Variant = p_t
	v_C = J.getv(game.j_G, "celeb")
	J.setv(v_C, "t", J.add(J.getv(v_C, "t"), (float(1.0) / float(60.0))))
	if J.lt(J.getv(v_C, "t"), 0.05):
		J.method(game.j_SFX, "fanfare", [])
		game.effects.f_flash(0.5, "#ffe9a0")
		game.effects.f_shake(4.0)
	J.setv(game.j_ctx, "globalAlpha", 0.72)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#140a06")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (J.lt(J.getv(v_C, "t"), 4.5) and J.truth(game.f_chance(0.75))):
		game.effects.f_part({"x": game.math_utils.f_rnd(0.0, game.j_W), "y": (-J.n(4.0)), "vx": game.math_utils.f_rnd((-J.n(26.0)), 26.0), "vy": game.math_utils.f_rnd(24.0, 70.0), "life": 3.4, "col": game.math_utils.f_pick([J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#e2483a", "#3f8a4a", "#3f6fbd", "#ffffff"]), "g": 26.0, "sz": 2.0, "drag": 0.3})
	v_k = game.math_utils.f_clamp((J.getv(v_C, "t") * 1.6), 0.0, 1.0)
	v_yy = game.math_utils.f_lerp((-J.n(70.0)), 54.0, game.math_utils.f_easeOutBack(v_k))
	v_bw = 300.0
	v_bx = ((float(game.j_W) / float(2.0)) - (float(v_bw) / float(2.0)))
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_rrect(J.add(v_bx, 3.0), J.add(v_yy, 4.0), v_bw, 116.0, 5.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_bx, v_yy, v_bw, 116.0, 5.0, "#8e1c14")
	game.f_rrect(J.add(v_bx, 2.0), J.add(v_yy, 2.0), (v_bw - 4.0), 112.0, 4.0, J.getv(game.j_P, "ui0"))
	game.f_rrectOut(v_bx, v_yy, v_bw, 116.0, 5.0, J.getv(game.j_P, "au2"))
	J.setv(game.j_ctx, "globalAlpha", J.add(0.35, (0.3 * sin((v_t * 5.0)))))
	game.f_rrectOut((v_bx - 2.0), (v_yy - 2.0), J.add(v_bw, 4.0), 120.0, 6.0, J.getv(game.j_P, "au0"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.text_draw.f_txt("BORÇ BİTTİ!", (float(game.j_W) / float(2.0)), J.add(v_yy, 12.0), J.getv(game.j_P, "red1"), {"align": "c", "sc": 2.0, "shadow": 1.0})
	if J.gt(J.getv(v_C, "t"), 0.5):
		game.text_draw.f_txt("Babanın borcunu son kuruşuna kadar ödedin.", (float(game.j_W) / float(2.0)), J.add(v_yy, 40.0), J.getv(game.j_P, "ink"), {"align": "c"})
	if J.gt(J.getv(v_C, "t"), 0.9):
		game.text_draw.f_txt("Dükkân artık tamamen senin.", (float(game.j_W) / float(2.0)), J.add(v_yy, 52.0), J.getv(game.j_P, "ink"), {"align": "c"})
	if J.gt(J.getv(v_C, "t"), 1.3):
		game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(game.j_DEBT_START)), (float(game.j_W) / float(2.0)), J.add(v_yy, 66.0), J.getv(game.j_P, "ok"), {"align": "c", "sc": 1.0})
		game.text_draw.f_txt("ödendi", (float(game.j_W) / float(2.0)), J.add(v_yy, 80.0), J.getv(game.j_P, "ui3"), {"align": "c"})
	if J.gt(J.getv(v_C, "t"), 1.7):
		v_px2 = ((float(game.j_W) / float(2.0)) - 128.0)
		v_py2 = J.add(v_yy, 34.0)
		game.f_rrect(v_px2, v_py2, 34.0, 40.0, 2.0, "#6d4a22")
		game.f_rrect(J.add(v_px2, 2.0), J.add(v_py2, 2.0), 30.0, 36.0, 2.0, "#c9a06a")
		game.f_rrect(J.add(v_px2, 3.0), J.add(v_py2, 3.0), 28.0, 28.0, 1.0, "#8aa8b8")
		v_fx2 = J.add(v_px2, 17.0)
		v_fy2 = J.add(v_py2, 20.0)
		game.f_ell(v_fx2, v_fy2, 7.0, 8.0, "#f0bd8a")
		game.f_fr((v_fx2 - 8.0), J.add(v_fy2, 6.0), 16.0, 8.0, "#c33c2c")
		game.f_fr((v_fx2 - 6.0), (v_fy2 - 9.0), 13.0, 6.0, J.getv(game.j_P, "red2"))
		game.f_fr((v_fx2 - 5.0), (v_fy2 - 9.0), 11.0, 5.0, J.getv(game.j_P, "red1"))
		game.f_fr((v_fx2 - 5.0), J.add(v_fy2, 2.0), 11.0, 2.0, "#efefe9")
		game.f_fr((v_fx2 - 4.0), (v_fy2 - 2.0), 3.0, 2.0, "#2b2018")
		game.f_fr(J.add(v_fx2, 2.0), (v_fy2 - 2.0), 3.0, 2.0, "#2b2018")
		game.text_draw.f_txt("BABA", J.add(v_px2, 17.0), J.add(v_py2, 32.0), "#5a3a1e", {"align": "c"})
		if J.truth(game.f_chance(0.1)):
			game.effects.f_part({"x": J.add(v_px2, game.math_utils.f_rnd(0.0, 34.0)), "y": J.add(v_py2, game.math_utils.f_rnd(0.0, 40.0)), "vx": game.math_utils.f_rnd((-J.n(8.0)), 8.0), "vy": game.math_utils.f_rnd((-J.n(18.0)), (-J.n(6.0))), "life": 0.8, "col": J.getv(game.j_P, "au0"), "g": (-J.n(6.0)), "sz": 1.0, "type": "star"})
	if (J.gt(J.getv(v_C, "t"), 2.4) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 52.0), J.add(v_yy, 92.0), 104.0, 18.0, "DEVAM ET", "#3f8a4a", true))):
		J.setv(game.j_G, "celeb", null)
		J.method(game.j_SFX, "ui", [])
		# BIRLESIK (6. tur): kutlamadan sonra kapanis hikayesi
		game.story_draw.f_epiStart()
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	return null

