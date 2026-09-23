# Household draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:1010
func f_drawHesap(p_t: Variant = null) -> Variant:
	var v_HS: Variant = null
	var v_a: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_kk: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_ry: Variant = null
	var v_i: Variant = null
	var v_g: Variant = null
	var v_acik: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_ust: Variant = null
	var v_ad: Variant = null
	var v_ustTasin: Variant = null
	var v_once: Variant = null
	var v_kalan: Variant = null
	var v_hy: Variant = null
	var v_oy: Variant = null
	var v_o: Variant = null
	var v_ol: Variant = null
	var v_rnk: Variant = null
	var v_bitti: Variant = null
	var v_t: Variant = p_t
	v_HS = J.getv(game.j_G, "hesap")
	J.setv(v_HS, "t", J.add(J.getv(v_HS, "t"), (float(1.0) / float(60.0))))
	if J.truth(J.getv(game.j_EVP, "open")):
		game.interface_draw.f_drawShopStatic(v_t, true)
		game.household_draw.f_drawEvPaneli(v_t)
		game.effects.f_psDraw()
		game.effects.f_ftDraw()
		return null
	game.interface_draw.f_drawShopStatic(v_t, true)
	J.setv(game.j_ctx, "globalAlpha", 0.8)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0b0a09")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_a = game.math_utils.f_clamp((J.getv(v_HS, "t") * 2.2), 0.0, 1.0)
	v_pw = 268.0
	v_ph = J.add(J.add(J.add(74.0, (J.getv(J.getv(v_HS, "kalem"), "length") * 13.0)), 44.0), (32.0 if J.truth(J.getv(v_HS, "kapandi")) else 0.0))
	v_kk = game.interface_draw.f_panelKutu(0.0, v_ph)
	v_ph = J.getv(v_kk, 1.0)
	v_x = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_y = floor(game.math_utils.f_lerp((-J.n(v_ph)), J.getv(v_kk, 0.0), game.math_utils.f_easeOutBack(v_a)) + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_fr(J.add(v_x, 4.0), J.add(v_y, 5.0), v_pw, v_ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, v_y, v_pw, v_ph, "#b9b096")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), (v_ph - 2.0), "#e8e0c6")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), "#f6efd8")
	game.f_fr(v_x, v_y, v_pw, 3.0, "#4a4e54")
	game.text_draw.f_txt(game.localization.f_T("GÜN SONU HESABI"), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_y, 8.0), "#2a2620", {"align": "c"})
	game.text_draw.f_txt(J.add(J.add(J.add(game.localization.f_T("Demirkent — gün "), J.add((J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0), 1.0)), "  -  "), game.localization.f_T(J.getv(game.progression_system.f_evSimdiki(), "ad"))), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_y, 19.0), "#7a7360", {"align": "c"})
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_hl(J.add(v_x, 12.0), J.add(v_y, 30.0), (v_pw - 24.0), "#8a8370")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_ry = J.add(v_y, 34.0)
	game.text_draw.f_txt(game.localization.f_T("BUGÜN"), J.add(v_x, 14.0), v_ry, "#8a8370")
	v_ry = J.add(v_ry, 11.0)
	game.text_draw.f_txt(game.localization.f_T("Tezgâh geliri"), J.add(v_x, 14.0), v_ry, "#3a3630")
	game.text_draw.f_txt(J.add("+$", game.math_utils.f_fmtMoney(J.getv(v_HS, "gelir"))), (J.add(v_x, v_pw) - 14.0), v_ry, "#2f6a3a", {"align": "r"})
	v_ry = J.add(v_ry, 12.0)
	if J.gt(J.getv(v_HS, "ceza"), 0.0):
		game.text_draw.f_txt(game.localization.f_T("Ferman cezası"), J.add(v_x, 14.0), v_ry, "#3a3630")
		game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_HS, "ceza"))), (J.add(v_x, v_pw) - 14.0), v_ry, "#a83a2a", {"align": "r"})
		v_ry = J.add(v_ry, 12.0)
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_hl(J.add(v_x, 12.0), (v_ry - 2.0), (v_pw - 24.0), "#8a8370")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_ry = J.add(v_ry, 4.0)
	game.text_draw.f_txt(game.localization.f_T("GİDERLER"), J.add(v_x, 14.0), v_ry, "#8a8370")
	v_ry = J.add(v_ry, 11.0)
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_HS, "kalem"), "length")):
		v_g = J.getv(J.getv(v_HS, "kalem"), v_i)
		v_acik = J.getv(J.getv(v_HS, "sec"), J.getv(v_g, "id"))
		v_kx = J.add(v_x, 14.0)
		v_ky = (v_ry - 1.0)
		v_ust = (game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (v_kx - 2.0), (v_ky - 2.0), (v_pw - 26.0), 12.0) if ((not J.truth(J.getv(v_HS, "kapandi"))) and (not J.truth(J.getv(v_g, "zorunlu")))) else ((not J.truth(J.getv(v_g, "zorunlu"))) if (not J.truth(J.getv(v_HS, "kapandi"))) else (not J.truth(J.getv(v_HS, "kapandi")))))
		game.f_rrect(v_kx, v_ky, 9.0, 9.0, 2.0, ("#8a8370" if J.truth(J.getv(v_g, "zorunlu")) else ("#c8a23a" if J.truth(v_ust) else "#6a6455")))
		game.f_rrect(J.add(v_kx, 1.0), J.add(v_ky, 1.0), 7.0, 7.0, 2.0, (("#7a6a3a" if J.truth(J.getv(v_g, "zorunlu")) else "#3f8a4a") if J.truth(v_acik) else "#e8e0c6"))
		if J.truth(v_acik):
			game.f_fr(J.add(v_kx, 3.0), J.add(v_ky, 4.0), 1.0, 3.0, "#ffffff")
			game.f_fr(J.add(v_kx, 4.0), J.add(v_ky, 5.0), 3.0, 1.0, "#ffffff")
			game.f_fr(J.add(v_kx, 5.0), J.add(v_ky, 3.0), 1.0, 3.0, "#ffffff")
		v_ad = game.localization.f_T(J.getv(v_g, "ad"))
		if J.eq(J.getv(v_g, "id"), "yemek"):
			v_ad = J.add(v_ad, J.add(J.add(" (", J.getv(v_HS, "kisi")), ")"))
		if J.eq(J.getv(v_g, "id"), "ilac"):
			v_ad = J.add(v_ad, J.add(J.add(" (", J.getv(v_HS, "hasta")), ")"))
		game.text_draw.f_txt(v_ad, J.add(v_x, 28.0), v_ry, ("#3a3630" if J.truth(v_acik) else "#9a9282"))
		if J.eq(J.getv(v_g, "id"), "ev"):
			v_ustTasin = (J.lt((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), (J.getv(game.j_EVLER, "length") - 1.0)) if (not J.truth(J.getv(v_HS, "kapandi"))) else (not J.truth(J.getv(v_HS, "kapandi"))))
			if (J.truth(v_ustTasin) and J.truth(game.f_button((J.add(v_x, v_pw) - 124.0), (v_ry - 2.0), 54.0, 12.0, game.localization.f_T("TAŞIN"), "#3f6fbd", true))):
				J.setv(game.j_EVP, "open", true)
				J.method(game.j_SFX, "ui", [])
				J.setv(game.j_IN, "pressed", false)
			else:
				if (not J.truth(v_ustTasin)):
					game.text_draw.f_txt(game.localization.f_T("zorunlu"), (J.add(v_x, v_pw) - 66.0), v_ry, "#9a9282", {"align": "r"})
		else:
			if J.truth(J.getv(v_g, "zorunlu")):
				game.text_draw.f_txt(game.localization.f_T("zorunlu"), (J.add(v_x, v_pw) - 66.0), v_ry, "#9a9282", {"align": "r"})
		game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_g, "tutar"))), (J.add(v_x, v_pw) - 14.0), v_ry, ("#a83a2a" if J.truth(v_acik) else "#9a9282"), {"align": "r"})
		if (J.truth(v_ust) and J.truth(J.getv(game.j_IN, "pressed"))):
			J.setv(J.getv(v_HS, "sec"), J.getv(v_g, "id"), (not J.truth(v_acik)))
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_IN, "pressed", false)
		v_ry = J.add(v_ry, 13.0)
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_hl(J.add(v_x, 12.0), v_ry, (v_pw - 24.0), "#8a8370")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_ry = J.add(v_ry, 5.0)
	v_once = (J.getv(v_HS, "oncekiKasa") if J.truth(J.getv(v_HS, "kapandi")) else (J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0))
	v_kalan = (J.getv(v_HS, "sonKasa") if J.truth(J.getv(v_HS, "kapandi")) else game.household_system.f_hesapKalan(v_HS))
	game.text_draw.f_txt(game.localization.f_T("KASA"), J.add(v_x, 14.0), v_ry, "#2a2620")
	game.text_draw.f_txt(J.add(J.add(("-$" if J.lt(v_once, 0.0) else "$"), game.math_utils.f_fmtMoney(abs(v_once))), "  >"), (J.add(v_x, v_pw) - 76.0), v_ry, "#7a7360", {"align": "r"})
	game.text_draw.f_txt(J.add(("-$" if J.lt(v_kalan, 0.0) else "$"), game.math_utils.f_fmtMoney(abs(v_kalan))), (J.add(v_x, v_pw) - 14.0), v_ry, ("#c8321e" if J.lt(v_kalan, 0.0) else "#2f6a3a"), {"align": "r"})
	v_hy = J.add(v_ry, 14.0)
	game.household_draw.f_haneCiz(J.add(v_x, 14.0), v_hy, v_t)
	if (not J.truth(J.getv(v_HS, "kapandi"))):
		if J.truth(game.f_button((J.add(v_x, v_pw) - 86.0), (v_hy - 2.0), 72.0, 17.0, game.localization.f_T("GÜNÜ KAPAT"), "#8e2318", true)):
			J.method(game.j_SFX, "ui", [])
			game.household_system.f_hesapKapat()
	else:
		v_oy = J.add(v_hy, 16.0)
		v_o = 0.0
		while (J.lt(v_o, J.getv((J.getv(v_HS, "olay") if J.truth(J.getv(v_HS, "olay")) else []), "length")) and J.lt(v_o, 3.0)):
			v_ol = J.getv(J.getv(v_HS, "olay"), v_o)
			v_rnk = ("#2f6a3a" if J.eq(J.getv(v_ol, "tip"), "iyi") else ("#c8321e" if J.eq(J.getv(v_ol, "tip"), "kotu") else "#a86a20"))
			game.text_draw.f_txt(J.add(J.add("- ", (game.localization.f_T(J.getv(v_ol, "ad")) if J.truth(J.getv(v_ol, "ad")) else "")), game.localization.f_T(J.getv(v_ol, "ek"))), J.add(v_x, 14.0), v_oy, v_rnk)
			v_oy = J.add(v_oy, 10.0)
			v_o = J.add(v_o, 1.0)
		v_bitti = game.regulation_system.f_fermanBitti()
		if ((not J.truth(v_bitti)) and J.truth(game.f_button(J.add(v_x, 14.0), (J.add(v_y, v_ph) - 22.0), 78.0, 17.0, game.localization.f_T("EVE DÖN"), "#6a4a2a", true))):
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_G, "hesap", null)
			J.setv(game.j_G, "day", J.add(J.getv(game.j_G, "day"), 1.0))
			game.branch_draw.f_sehreGit((-J.n(1.0)))
			J.setv(game.j_G, "scene", "shop")
			J.setv(game.j_G, "sceneT", 0.0)
			J.setv(game.j_SHOP, "bake", null)
			game.save_system.f_saveAll()
		if J.truth(game.f_button((J.add(v_x, v_pw) - 94.0), (J.add(v_y, v_ph) - 22.0), 80.0, 17.0, (game.localization.f_T("EVE DÖN") if J.truth(v_bitti) else game.localization.f_T("ERTESİ GÜN")), ("#6a4a2a" if J.truth(v_bitti) else "#3f8a4a"), true)):
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_G, "hesap", null)
			if J.truth(v_bitti):
				game.household_system.f_fermanEkonomiKur(true)
				J.setv(game.j_G, "day", J.add(J.getv(game.j_G, "day"), 1.0))
				game.branch_draw.f_sehreGit((-J.n(1.0)))
				J.setv(game.j_G, "scene", "shop")
				J.setv(game.j_G, "sceneT", 0.0)
				J.setv(game.j_SHOP, "bake", null)
				game.save_system.f_saveAll()
			else:
				J.setv(game.j_G, "day", J.add(J.getv(game.j_G, "day"), 1.0))
				game.event_system.f_rollNight()
				J.setv(game.j_G, "scene", ("night" if J.truth(J.getv(game.j_G, "night")) else "intro"))
				J.setv(game.j_G, "sceneT", 0.0)
				game.save_system.f_saveAll()
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	if J.truth(J.getv(game.j_G, "tutanak")):
		game.day_end_draw.f_drawTutanak(v_t)
	return null

# ui.js:1146
func f_drawEvPaneli(p_t: Variant = null) -> Variant:
	var v_pw: Variant = null
	var v_satirH: Variant = null
	var v_ph: Variant = null
	var v_kk: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_i: Variant = null
	var v_e: Variant = null
	var v_ry: Variant = null
	var v_simdi: Variant = null
	var v_gecmis: Variant = null
	var v_sonraki: Variant = null
	var v_alinir: Variant = null
	var v_zemin: Variant = null
	var v_b: Variant = null
	var v_t: Variant = p_t
	v_pw = 292.0
	v_satirH = 24.0
	v_ph = J.add(J.add(34.0, (J.getv(game.j_EVLER, "length") * v_satirH)), 26.0)
	v_kk = game.interface_draw.f_panelKutu(0.0, v_ph)
	v_ph = J.getv(v_kk, 1.0)
	v_x = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_y = J.getv(v_kk, 0.0)
	J.setv(game.j_ctx, "globalAlpha", 0.7)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0b0a09")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_fr(J.add(v_x, 4.0), J.add(v_y, 5.0), v_pw, v_ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, v_y, v_pw, v_ph, "#b9b096")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), (v_ph - 2.0), "#e8e0c6")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), "#f6efd8")
	game.f_fr(v_x, v_y, v_pw, 3.0, "#3f6fbd")
	game.text_draw.f_txt(game.localization.f_T("KONUT DAİRESİ"), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_y, 8.0), "#2a2620", {"align": "c"})
	game.text_draw.f_txt(J.add(game.localization.f_T("Kasa: $"), game.math_utils.f_fmtMoney((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0))), (J.add(v_x, v_pw) - 14.0), J.add(v_y, 20.0), "#7a7360", {"align": "r"})
	game.text_draw.f_txt(game.localization.f_T("Yükseldikçe yalıtım iyi, hastalık az."), J.add(v_x, 14.0), J.add(v_y, 20.0), "#8a8370")
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_EVLER, "length")):
		v_e = J.getv(game.j_EVLER, v_i)
		v_ry = J.add(J.add(v_y, 32.0), (v_i * v_satirH))
		v_simdi = J.eq((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), v_i)
		v_gecmis = J.lt(v_i, (J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0))
		v_sonraki = J.eq(v_i, J.add((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), 1.0))
		v_alinir = (J.ge((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0), J.getv(v_e, "pesinat")) if J.truth(v_sonraki) else v_sonraki)
		v_zemin = ("#d8e2c8" if J.truth(v_simdi) else ("#ddd6c0" if J.truth(v_gecmis) else "#e8e0c6"))
		game.f_fr(J.add(v_x, 10.0), (v_ry - 2.0), (v_pw - 20.0), (v_satirH - 3.0), v_zemin)
		game.f_rc(J.add(v_x, 10.0), (v_ry - 2.0), (v_pw - 20.0), (v_satirH - 3.0), ("#3f8a4a" if J.truth(v_simdi) else "#c2baa2"))
		v_b = 0.0
		while J.le(v_b, v_i):
			game.f_fr(J.add(v_x, 13.0), (J.add(v_ry, 11.0) - (v_b * 2.0)), 3.0, 1.0, ("#3f8a4a" if J.truth(v_simdi) else "#8a8370"))
			v_b = J.add(v_b, 1.0)
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_e, "ad")), J.add(v_x, 22.0), v_ry, ("#25301f" if J.truth(v_simdi) else ("#9a9282" if J.truth(v_gecmis) else "#3a3630")))
		game.text_draw.f_txt(J.add(game.localization.f_T("kira $"), game.math_utils.f_fmtMoney(J.getv(v_e, "kira"))), J.add(v_x, 22.0), J.add(v_ry, 10.0), "#7a7360")
		if J.truth(v_simdi):
			game.text_draw.f_txt(game.localization.f_T("OTURUYORSUN"), (J.add(v_x, v_pw) - 18.0), J.add(v_ry, 4.0), "#2f6a3a", {"align": "r"})
		else:
			if J.truth(v_gecmis):
				game.text_draw.f_txt(game.localization.f_T("geride kaldı"), (J.add(v_x, v_pw) - 18.0), J.add(v_ry, 4.0), "#9a9282", {"align": "r"})
			else:
				if J.truth(v_sonraki):
					game.text_draw.f_txt(J.add(game.localization.f_T("peşinat $"), game.math_utils.f_fmtMoney(J.getv(v_e, "pesinat"))), (J.add(v_x, v_pw) - 74.0), J.add(v_ry, 4.0), ("#3a3630" if J.truth(v_alinir) else "#a83a2a"), {"align": "r"})
					if J.truth(game.f_button((J.add(v_x, v_pw) - 66.0), J.add(v_ry, 1.0), 52.0, 15.0, game.localization.f_T("TAŞIN"), ("#3f8a4a" if J.truth(v_alinir) else "#6a6455"), v_alinir)):
						if J.truth(game.household_system.f_eveTasin(v_i)):
							game.effects.f_ftext(J.add(game.localization.f_T("YENİ EV: "), game.localization.f_T(J.getv(v_e, "ad"))), (float(game.j_W) / float(2.0)), 96.0, J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
							game.effects.f_flash(0.22, "#ffe9a0")
							J.setv(game.j_EVP, "open", false)
							if (J.truth(J.getv(game.j_G, "hesap")) and (not J.truth(J.getv(J.getv(game.j_G, "hesap"), "kapandi")))):
								J.setv(game.j_G, "hesap", game.household_system.f_hesapKur())
				else:
					game.text_draw.f_txt(game.localization.f_T("sırası gelmedi"), (J.add(v_x, v_pw) - 18.0), J.add(v_ry, 4.0), "#b0a894", {"align": "r"})
		v_i = J.add(v_i, 1.0)
	if J.truth(game.f_button((J.add(v_x, (float(v_pw) / float(2.0))) - 34.0), (J.add(v_y, v_ph) - 20.0), 68.0, 16.0, game.localization.f_T("KAPAT"), "#8a4a4a", true)):
		J.setv(game.j_EVP, "open", false)
		J.method(game.j_SFX, "uiBack", [])
	return null

# ui.js:1204
func f_haneCiz(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null) -> Variant:
	var v_h: Variant = null
	var v_i: Variant = null
	var v_u: Variant = null
	var v_ux: Variant = null
	var v_ten: Variant = null
	var v_gy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	v_h = (J.getv(game.j_G, "hane") if J.truth(J.getv(game.j_G, "hane")) else [])
	v_i = 0.0
	while J.lt(v_i, J.getv(v_h, "length")):
		v_u = J.getv(v_h, v_i)
		v_ux = J.add(v_x, (v_i * 13.0))
		if J.truth(J.getv(v_u, "gitti")):
			J.setv(game.j_ctx, "globalAlpha", 0.35)
			game.f_rc(v_ux, v_y, 10.0, 10.0, "#8a8370")
			game.f_fr(J.add(v_ux, 2.0), J.add(v_y, 4.0), 6.0, 1.0, "#8a8370")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_i = J.add(v_i, 1.0)
			continue
		v_ten = ("#c8bfa8" if J.gt(J.getv(v_u, "hasta"), 0.0) else ("#d6b48a" if J.gt(J.getv(v_u, "ac"), 0.0) else "#e0b98c"))
		game.f_fr(v_ux, v_y, 10.0, 10.0, v_ten)
		game.f_fr(v_ux, v_y, 10.0, 1.0, game.character_draw.f_shadeCol(v_ten, 1.12))
		v_gy = J.add(v_y, 4.0)
		if J.gt(J.getv(v_u, "hasta"), 0.0):
			game.f_fr(J.add(v_ux, 2.0), v_gy, 2.0, 1.0, "#6a5a4a")
			game.f_fr(J.add(v_ux, 6.0), v_gy, 2.0, 1.0, "#6a5a4a")
		else:
			game.f_px(J.add(v_ux, 2.0), v_gy, "#3a2e24")
			game.f_px(J.add(v_ux, 7.0), v_gy, "#3a2e24")
		if J.gt(J.getv(v_u, "hasta"), 0.0):
			game.f_fr(J.add(v_ux, 3.0), J.add(v_y, 7.0), 4.0, 1.0, "#8a4a3a")
		else:
			if J.gt(J.getv(v_u, "ac"), 0.0):
				game.f_fr(J.add(v_ux, 3.0), J.add(v_y, 8.0), 4.0, 1.0, "#8a6a4a")
				game.f_px(J.add(v_ux, 2.0), J.add(v_y, 7.0), "#8a6a4a")
				game.f_px(J.add(v_ux, 7.0), J.add(v_y, 7.0), "#8a6a4a")
			else:
				game.f_fr(J.add(v_ux, 3.0), J.add(v_y, 7.0), 4.0, 1.0, "#8a6a4a")
				game.f_px(J.add(v_ux, 2.0), J.add(v_y, 6.0), "#8a6a4a")
				game.f_px(J.add(v_ux, 7.0), J.add(v_y, 6.0), "#8a6a4a")
		if J.gt(J.getv(v_u, "hasta"), 0.0):
			J.setv(game.j_ctx, "globalAlpha", 0.7)
			game.f_px(J.add(v_ux, 4.0), J.add(v_y, 1.0), "#8fc4e0")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.gt(J.getv(v_u, "ac"), 0.0):
			J.setv(game.j_ctx, "globalAlpha", 0.35)
			game.f_fr(J.add(v_ux, 1.0), J.add(v_y, 5.0), 1.0, 2.0, "#8a6a4a")
			game.f_fr(J.add(v_ux, 8.0), J.add(v_y, 5.0), 1.0, 2.0, "#8a6a4a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

