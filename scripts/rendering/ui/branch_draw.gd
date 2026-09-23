# Branch draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:2244
func f_payDebt(p_amount: Variant = null) -> Variant:
	var v_amount: Variant = p_amount
	v_amount = min(min(floor(v_amount), J.getv(game.j_G, "money")), J.getv(game.j_G, "debt"))
	if J.le(v_amount, 0.0):
		J.method(game.j_SFX, "bad", [])
		return false
	J.setv(game.j_G, "money", (J.getv(game.j_G, "money") - v_amount))
	J.setv(game.j_G, "debt", (J.getv(game.j_G, "debt") - v_amount))
	J.setv(J.getv(game.j_G, "stats"), "debtPaid", J.add((J.getv(J.getv(game.j_G, "stats"), "debtPaid") if J.truth(J.getv(J.getv(game.j_G, "stats"), "debtPaid")) else 0.0), v_amount))
	J.method(game.j_SFX, "cash", [])
	game.effects.f_burst((float(game.j_W) / float(2.0)), 130.0, 22.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 90.0, "type": "star", "sz": 2.0})
	game.effects.f_ftext(J.add("-$", game.math_utils.f_fmtMoney(v_amount)), (float(game.j_W) / float(2.0)), 108.0, J.getv(game.j_P, "ok"), {"life": 1.6, "sc": 1.0})
	if J.le(J.getv(game.j_G, "debt"), 0.0):
		J.setv(game.j_G, "debt", 0.0)
		if (not J.truth(J.getv(game.j_G, "debtCleared"))):
			J.setv(game.j_G, "debtCleared", true)
			J.setv(game.j_G, "celeb", {"t": 0.0})
			J.method(game.j_SFX, "levelup", [])
	game.save_system.f_saveAll()
	return true
	return null

# ui.js:2261
func f_drawPayPanel(p_t: Variant = null) -> Variant:
	var v_x: Variant = null
	var v_y: Variant = null
	var v_w: Variant = null
	var v_h: Variant = null
	var v_pr: Variant = null
	var v_amts: Variant = null
	var v_i: Variant = null
	var v_bw: Variant = null
	var v_bx: Variant = null
	var v_v: Variant = null
	var v_can: Variant = null
	var v_t: Variant = p_t
	v_x = 96.0
	v_y = 46.0
	v_w = 288.0
	v_h = 176.0
	J.setv(game.j_ctx, "globalAlpha", 0.84)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "BORÇ ÖDE")
	game.text_draw.f_txt("Kasandaki para", J.add(v_x, 16.0), J.add(v_y, 18.0), J.getv(game.j_P, "ui4"))
	game.icon_draw.f_icon("coin", (J.add(v_x, v_w) - 92.0), J.add(v_y, 22.0), v_t)
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(J.getv(game.j_G, "money"))), (J.add(v_x, v_w) - 16.0), J.add(v_y, 15.0), "#8a6a10", {"align": "r", "sc": 1.0})
	game.text_draw.f_txt("Kalan borç", J.add(v_x, 16.0), J.add(v_y, 40.0), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(J.getv(game.j_G, "debt"))), (J.add(v_x, v_w) - 16.0), J.add(v_y, 37.0), "#a83a2a", {"align": "r", "sc": 1.0})
	v_pr = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "debt")) / float(game.j_DEBT_START)), 0.0, 1.0))
	game.counter_draw.f_bar(J.add(v_x, 16.0), J.add(v_y, 58.0), (v_w - 32.0), 9.0, v_pr, J.getv(game.j_P, "ok"))
	game.text_draw.f_txt(J.add("%", J.method((v_pr * 100.0), "toFixed", [(2.0 if (J.gt(v_pr, 0.0) and J.lt(v_pr, 0.01)) else 1.0)])), J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 59.0), "#ffffff", {"align": "c", "shadow": 1.0})
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl(J.add(v_x, 14.0), J.add(v_y, 76.0), (v_w - 28.0), J.getv(game.j_P, "ui2"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.text_draw.f_txt(J.add(J.add(game.localization.f_T("Gün sonunda kazancının %"), floor((game.j_DEBT_CUT * 100.0) + 0.5)), game.localization.f_T("'i zaten gider.")), J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 82.0), J.getv(game.j_P, "ui4"), {"align": "c"})
	game.text_draw.f_txt("Buradan istediğin kadarını hemen kapatabilirsin.", J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 92.0), J.getv(game.j_P, "ui4"), {"align": "c"})
	v_amts = [["%25", floor((J.getv(game.j_G, "money") * 0.25))], ["%50", floor((J.getv(game.j_G, "money") * 0.5))], ["TÜMÜ", J.getv(game.j_G, "money")]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_amts, "length")):
		v_bw = 76.0
		v_bx = J.add(J.add(v_x, 20.0), (v_i * J.add(v_bw, 12.0)))
		v_v = min(J.getv(J.getv(v_amts, v_i), 1.0), J.getv(game.j_G, "debt"))
		v_can = J.gt(v_v, 0.0)
		if J.truth(game.f_button(v_bx, J.add(v_y, 106.0), v_bw, 20.0, J.getv(J.getv(v_amts, v_i), 0.0), ("#3f8a4a" if J.truth(v_can) else "#4a4038"), v_can)):
			if J.truth(v_can):
				game.branch_draw.f_payDebt(J.getv(J.getv(v_amts, v_i), 1.0))
			else:
				J.method(game.j_SFX, "bad", [])
		game.text_draw.f_txt((J.add("$", game.math_utils.f_fmtShort(v_v)) if J.truth(v_can) else "—"), J.add(v_bx, (float(v_bw) / float(2.0))), J.add(v_y, 129.0), (J.getv(game.j_P, "au2") if J.truth(v_can) else J.getv(game.j_P, "ui3")), {"align": "c"})
		v_i = J.add(v_i, 1.0)
	if J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 40.0), (J.add(v_y, v_h) - 22.0), 80.0, 18.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
		J.setv(game.j_PAYP, "open", false)
		J.method(game.j_SFX, "uiBack", [])
	return null

# ui.js:2308
func f_branchIcon(p_x: Variant = null, p_y: Variant = null, p_owned: Variant = null, p_k: Variant = null) -> Variant:
	var v_wall: Variant = null
	var v_roof: Variant = null
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_owned: Variant = p_owned
	var v_k: Variant = p_k
	v_wall = ("#c8a25a" if J.truth(v_owned) else "#4a423a")
	v_roof = ("#a8342a" if J.truth(v_owned) else "#3a3230")
	game.f_fr((v_x - 8.0), (v_y - 4.0), 17.0, 12.0, game.character_draw.f_shadeCol(v_wall, 0.55))
	game.f_fr((v_x - 8.0), (v_y - 4.0), 16.0, 11.0, v_wall)
	game.f_hl((v_x - 7.0), (v_y - 4.0), 14.0, game.character_draw.f_shadeCol(v_wall, 1.3))
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.f_fr(J.add((v_x - 8.0), (v_i * 4.0)), (v_y - 8.0), 4.0, 4.0, (v_roof if J.truth(fmod(J.n(v_i), J.n(2.0))) else game.character_draw.f_shadeCol(v_roof, 1.35)))
		v_i = J.add(v_i, 1.0)
	game.f_fr((v_x - 8.0), (v_y - 9.0), 16.0, 2.0, game.character_draw.f_shadeCol(v_roof, 0.6))
	game.f_fr((v_x - 6.0), (v_y - 1.0), 6.0, 6.0, ("#2a1c14" if J.truth(v_owned) else "#241f1c"))
	if J.truth(v_owned):
		game.f_fr((v_x - 5.0), v_y, 4.0, 4.0, "#ffcf6a")
		game.f_fr(J.add(v_x, 3.0), (v_y - 2.0), 3.0, 7.0, "#7a4a1e")
		game.f_fr(J.add(v_x, 3.0), J.add((v_y - 2.0), fmod(J.n(v_k), J.n(2.0))), 3.0, 3.0, "#c8752a")
		game.f_px(J.add(v_x, 4.0), (v_y - 3.0), "#e8e2d0")
	else:
		game.f_fr((v_x - 1.0), J.add(v_y, 1.0), 5.0, 4.0, "#6a6058")
		game.f_fr(v_x, (v_y - 1.0), 3.0, 3.0, "#6a6058")
		game.f_px(J.add(v_x, 1.0), J.add(v_y, 2.0), "#2a2622")
	return null

# ui.js:2335
func f_sehreGit(p_i: Variant = null) -> Variant:
	var v_i: Variant = p_i
	if (not J.truth(game.city_system.f_sehirAcik(v_i))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(game.localization.f_T("Önce o şubeyi aç"))
		return null
	if J.eq(J.getv(game.j_G, "city"), v_i):
		return null
	J.setv(game.j_G, "city", v_i)
	if J.truth(game.progression_system.f_fermanSehri(game.j_G)):
		game.household_system.f_fermanEkonomiKur(false)
	game.game_loop.f_invalidateLayers()
	game.save_system.f_saveAll()
	J.method(game.j_SFX, "levelup", [])
	game.effects.f_ftext(game.city_system.f_sehirAdi(v_i), (float(game.j_W) / float(2.0)), 110.0, J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
	game.effects.f_flash(0.2, "#ffe9a0")
	return null

# ui.js:2348
func f_drawBranchPanel(p_t: Variant = null) -> Variant:
	var v_kk: Variant = null
	var v_y: Variant = null
	var v_h: Variant = null
	var v_x: Variant = null
	var v_w: Variant = null
	var v_owned: Variant = null
	var v_base: Variant = null
	var v_seviye: Variant = null
	var v_k: Variant = null
	var v_nList: Variant = null
	var v_modBandi: Variant = null
	var v_etk: Variant = null
	var v_darP: Variant = null
	var v_altAlan: Variant = null
	var v_ly: Variant = null
	var v_rowH: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	var v_have: Variant = null
	var v_isNext: Variant = null
	var v_ry: Variant = null
	var v_kilitli: Variant = null
	var v_afford: Variant = null
	var v_mi: Variant = null
	var v_mb: Variant = null
	var v_mby: Variant = null
	var v_mbw: Variant = null
	var v_acik: Variant = null
	var v_sirada: Variant = null
	var v_mKilit: Variant = null
	var v_alinabilir: Variant = null
	var v_fy: Variant = null
	var v_t: Variant = p_t
	v_kk = game.interface_draw.f_panelKutu(10.0, 262.0)
	v_y = J.getv(v_kk, 0.0)
	v_h = J.getv(v_kk, 1.0)
	v_x = 44.0
	v_w = 392.0
	J.setv(game.j_ctx, "globalAlpha", 0.84)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "ŞUBELER")
	v_owned = (J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0)
	v_base = game.progression_system.f_branchBase(game.j_G)
	v_seviye = game.equipment_system.f_upgTotalLv(game.j_G)
	v_k = floor((v_t * 4.0))
	v_nList = (J.getv(game.j_BRANCH, "length") - (1.0 if J.truth(J.getv(J.getv(game.j_BRANCH, (J.getv(game.j_BRANCH, "length") - 1.0)), "ferman")) else 0.0))
	v_modBandi = (22.0 if J.truth(J.getv(J.getv(game.j_BRANCH, (J.getv(game.j_BRANCH, "length") - 1.0)), "ferman")) else 0.0)
	game.text_draw.f_txt(J.add(J.add(J.add(J.add(J.add(game.localization.f_T("Açık şube: "), min(v_owned, v_nList)), "/"), v_nList), game.localization.f_T("    Dükkân seviyesi: ")), v_seviye), J.add(v_x, 14.0), J.add(v_y, 16.0), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add(game.localization.f_T("Günlük şube geliri: $"), game.math_utils.f_fmtMoney(v_base)), (J.add(v_x, v_w) - 14.0), J.add(v_y, 16.0), (J.getv(game.j_P, "au2") if J.gt(v_base, 0.0) else J.getv(game.j_P, "ui3")), {"align": "r"})
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl(J.add(v_x, 12.0), J.add(v_y, 26.0), (v_w - 24.0), J.getv(game.j_P, "ui2"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_etk = game.localization.f_T("Buradasın: ")
	game.text_draw.f_txt(v_etk, J.add(v_x, 14.0), J.add(v_y, 28.0), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(game.city_system.f_sehirAdi(), J.add(J.add(v_x, 14.0), game.f_textW(v_etk)), J.add(v_y, 28.0), ("#2f6a8a" if J.ge(J.getv(game.j_G, "city"), 0.0) else "#a8621f"))
	v_darP = J.lt(v_h, 240.0)
	v_altAlan = J.add((26.0 if J.truth(v_darP) else 40.0), v_modBandi)
	v_ly = J.add(v_y, 42.0)
	v_rowH = game.math_utils.f_clamp(floor((float(((v_h - 42.0) - v_altAlan)) / float(v_nList))), (14.0 if J.truth(v_darP) else 17.0), 25.0)
	v_i = 0.0
	while J.lt(v_i, v_nList):
		v_b = J.getv(game.j_BRANCH, v_i)
		v_have = J.lt(v_i, v_owned)
		v_isNext = J.eq(v_i, v_owned)
		v_ry = J.add(v_ly, (v_i * v_rowH))
		v_kilitli = (game.progression_system.f_branchLocked(v_i, game.j_G) if J.truth(v_isNext) else v_isNext)
		v_afford = (J.ge(J.getv(game.j_G, "money"), J.getv(v_b, "p")) if (J.truth(v_isNext) and (not J.truth(v_kilitli))) else ((not J.truth(v_kilitli)) if J.truth(v_isNext) else v_isNext))
		if J.truth(v_have):
			J.setv(game.j_ctx, "globalAlpha", 0.18)
			game.f_rrect(J.add(v_x, 12.0), (v_ry - 2.0), (v_w - 24.0), (v_rowH - 3.0), 3.0, J.getv(game.j_P, "ok"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.truth(v_isNext):
				J.setv(game.j_ctx, "globalAlpha", 0.16)
				game.f_rrect(J.add(v_x, 12.0), (v_ry - 2.0), (v_w - 24.0), (v_rowH - 3.0), 3.0, (J.getv(game.j_P, "au0") if J.truth(v_afford) else "#7a4a4a"))
				J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.branch_draw.f_branchIcon(J.add(v_x, 30.0), J.add(v_ry, 10.0), v_have, J.add(v_k, v_i))
		game.text_draw.f_txt(J.getv(v_b, "name"), J.add(v_x, 48.0), J.add(v_ry, (4.0 if J.truth(v_darP) else 2.0)), (J.getv(game.j_P, "ink") if J.truth(v_have) else (J.getv(game.j_P, "ink") if J.truth(v_isNext) else "#6a6058")))
		if (not J.truth(v_darP)):
			game.text_draw.f_txt((J.getv(v_b, "desc") if (J.truth(v_have) or J.truth(v_isNext)) else "???"), J.add(v_x, 48.0), J.add(v_ry, 12.0), (J.getv(game.j_P, "ui4") if J.truth(v_have) else "#5a5450"))
		game.text_draw.f_txt(J.add(J.add("+$", game.math_utils.f_fmtShort(J.getv(v_b, "inc"))), game.localization.f_T("/gün")), J.add(v_x, 250.0), J.add(v_ry, 6.0), (J.getv(game.j_P, "au2") if J.truth(v_have) else "#6a6058"), {"align": "r"})
		if J.truth(v_have):
			if J.eq(J.getv(game.j_G, "city"), v_i):
				game.text_draw.f_txt(game.localization.f_T("BURADASIN"), (J.add(v_x, v_w) - 20.0), J.add(v_ry, 6.0), J.getv(game.j_P, "au0"), {"align": "r", "outline": true})
			else:
				if J.truth(game.f_button((J.add(v_x, v_w) - 76.0), J.add(v_ry, 1.0), 56.0, 16.0, game.localization.f_T("GİT"), "#3a6a8a", true)):
					game.branch_draw.f_sehreGit(v_i)
		else:
			if (J.truth(v_isNext) and J.truth(v_kilitli)):
				game.text_draw.f_txt("DÜKKÂN SEVİYESİ", (J.add(v_x, v_w) - 20.0), J.add(v_ry, 1.0), "#a8763a", {"align": "r"})
				game.text_draw.f_txt(J.add(J.add(v_seviye, "/"), J.getv(v_b, "req")), (J.add(v_x, v_w) - 20.0), J.add(v_ry, 11.0), "#d8a84a", {"align": "r"})
			else:
				if J.truth(v_isNext):
					if J.truth(game.f_button((J.add(v_x, v_w) - 96.0), J.add(v_ry, 1.0), 76.0, 16.0, J.add("$", game.math_utils.f_fmtShort(J.getv(v_b, "p"))), ("#3f8a4a" if J.truth(v_afford) else "#6a3a3a"), v_afford)):
						if J.ge(J.getv(game.j_G, "money"), J.getv(v_b, "p")):
							J.setv(game.j_G, "money", (J.getv(game.j_G, "money") - J.getv(v_b, "p")))
							J.setv(game.j_G, "branch", J.add(v_owned, 1.0))
							J.method(game.j_SFX, "cash", [])
							J.method(game.j_SFX, "levelup", [])
							game.effects.f_burst(J.add(v_x, 30.0), J.add(v_ry, 10.0), 26.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 100.0, "type": "star", "sz": 2.0})
							game.effects.f_ftext(J.add(J.getv(v_b, "name"), game.localization.f_T(" ŞUBESİ AÇILDI!")), (float(game.j_W) / float(2.0)), 120.0, J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
							game.effects.f_flash(0.25, "#ffe9a0")
							game.effects.f_shake(0.3)
							game.save_system.f_saveAll()
						else:
							J.method(game.j_SFX, "bad", [])
							game.effects.f_ftext("Para yetmiyor!", (J.add(v_x, v_w) - 58.0), (v_ry - 4.0), J.getv(game.j_P, "bad"))
				else:
					game.text_draw.f_txt("KİLİTLİ", (J.add(v_x, v_w) - 20.0), J.add(v_ry, 6.0), "#5a5450", {"align": "r"})
		v_i = J.add(v_i, 1.0)
	if J.truth(v_modBandi):
		v_mi = (J.getv(game.j_BRANCH, "length") - 1.0)
		v_mb = J.getv(game.j_BRANCH, v_mi)
		v_mby = J.add(J.add(v_ly, (v_nList * v_rowH)), 4.0)
		v_mbw = (v_w - 24.0)
		v_acik = J.gt(v_owned, v_mi)
		v_sirada = J.eq(v_owned, v_mi)
		v_mKilit = (game.progression_system.f_branchLocked(v_mi, game.j_G) if J.truth(v_sirada) else v_sirada)
		v_alinabilir = (J.ge(J.getv(game.j_G, "money"), J.getv(v_mb, "p")) if (J.truth(v_sirada) and (not J.truth(v_mKilit))) else ((not J.truth(v_mKilit)) if J.truth(v_sirada) else v_sirada))
		if J.lt(v_owned, v_mi):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_rrect(J.add(v_x, 12.0), v_mby, v_mbw, 20.0, 3.0, "#2a2e34")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_rrectOut(J.add(v_x, 12.0), v_mby, v_mbw, 20.0, 3.0, "#4a4e54")
			game.text_draw.f_txt(game.localization.f_T("TÜM ŞUBELER AÇILINCA"), J.add(v_x, (float(v_w) / float(2.0))), J.add(v_mby, 6.0), "#7a7f86", {"align": "c"})
		else:
			game.f_rrect(J.add(v_x, 12.0), v_mby, v_mbw, 20.0, 3.0, ("#2f4a34" if J.truth(v_acik) else "#3a2422"))
			game.f_rrectOut(J.add(v_x, 12.0), v_mby, v_mbw, 20.0, 3.0, (J.getv(game.j_P, "ok") if J.truth(v_acik) else "#8e2318"))
			game.f_fr(J.add(v_x, 12.0), v_mby, 4.0, 20.0, "#b83228")
			game.text_draw.f_txt(game.localization.f_T(J.getv(v_mb, "name")), J.add(v_x, 30.0), J.add(v_mby, 2.0), (J.getv(game.j_P, "ok") if J.truth(v_acik) else "#e2604f"))
			game.text_draw.f_txt(game.localization.f_T("FERMAN MODU"), J.add(v_x, 30.0), J.add(v_mby, 11.0), "#9a8f80")
			if J.truth(v_acik):
				if J.eq(J.getv(game.j_G, "city"), v_mi):
					game.text_draw.f_txt(game.localization.f_T("BURADASIN"), (J.add(v_x, v_w) - 20.0), J.add(v_mby, 6.0), J.getv(game.j_P, "au0"), {"align": "r", "outline": true})
				else:
					if J.truth(game.f_button((J.add(v_x, v_w) - 76.0), J.add(v_mby, 2.0), 56.0, 16.0, game.localization.f_T("GİT"), "#8e2318", true)):
						game.branch_draw.f_sehreGit(v_mi)
			else:
				if J.truth(v_mKilit):
					game.text_draw.f_txt(J.add(J.add(v_seviye, "/"), J.getv(v_mb, "req")), (J.add(v_x, v_w) - 20.0), J.add(v_mby, 6.0), "#d8a84a", {"align": "r"})
				else:
					if J.truth(game.f_button((J.add(v_x, v_w) - 96.0), J.add(v_mby, 2.0), 76.0, 16.0, J.add("$", game.math_utils.f_fmtShort(J.getv(v_mb, "p"))), ("#3f8a4a" if J.truth(v_alinabilir) else "#6a3a3a"), v_alinabilir)):
						if J.ge(J.getv(game.j_G, "money"), J.getv(v_mb, "p")):
							J.setv(game.j_G, "money", (J.getv(game.j_G, "money") - J.getv(v_mb, "p")))
							J.setv(game.j_G, "branch", J.add(v_mi, 1.0))
							J.method(game.j_SFX, "cash", [])
							J.method(game.j_SFX, "levelup", [])
							game.effects.f_ftext(J.add(game.localization.f_T(J.getv(v_mb, "name")), game.localization.f_T(" AÇILDI!")), (float(game.j_W) / float(2.0)), 120.0, J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
							game.effects.f_flash(0.25, "#ffe9a0")
							game.effects.f_shake(0.3)
							game.save_system.f_saveAll()
						else:
							J.method(game.j_SFX, "bad", [])
	if (not J.truth(v_darP)):
		v_fy = max(J.add(J.add(J.add(v_ly, (v_nList * v_rowH)), 6.0), v_modBandi), (J.add(v_y, v_h) - 40.0))
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_hl(J.add(v_x, 12.0), (v_fy - 6.0), (v_w - 24.0), J.getv(game.j_P, "ui2"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.text_draw.f_txt((game.localization.f_T("Şube geliri o günkü satışına göre artar.") if J.ge(J.getv(game.j_G, "city"), 0.0) else game.localization.f_T("Yeni şube açmak için önce dükkânı geliştir.")), J.add(v_x, (float(v_w) / float(2.0))), v_fy, J.getv(game.j_P, "ui4"), {"align": "c"})
	if J.ge(J.getv(game.j_G, "city"), 0.0):
		if J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 132.0), (J.add(v_y, v_h) - 20.0), 124.0, 17.0, game.localization.f_T("BABANIN DÜKKÂNI"), "#6a4a2a", true)):
			game.branch_draw.f_sehreGit((-J.n(1.0)))
		if J.truth(game.f_button(J.add(J.add(v_x, (float(v_w) / float(2.0))), 12.0), (J.add(v_y, v_h) - 20.0), 80.0, 17.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
			J.setv(game.j_BRP, "open", false)
			J.method(game.j_SFX, "uiBack", [])
	else:
		if J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 40.0), (J.add(v_y, v_h) - 20.0), 80.0, 17.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
			J.setv(game.j_BRP, "open", false)
			J.method(game.j_SFX, "uiBack", [])
	return null
