# Day end draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:936
func f_drawDayEnd(p_t: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_y: Variant = null
	var v_extraH: Variant = null
	var v_st: Variant = null
	var v_rows: Variant = null
	var v_i: Variant = null
	var v_ry: Variant = null
	var v_ly: Variant = null
	var v_dy2: Variant = null
	var v_t: Variant = p_t
	if J.truth(J.getv(game.j_G, "hesap")):
		game.household_draw.f_drawHesap(v_t)
		return null
	game.interface_draw.f_drawShopStatic(v_t, false)
	J.setv(game.j_ctx, "globalAlpha", 0.6)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#140a06")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_k = game.math_utils.f_clamp((J.getv(game.j_G, "sceneT") * 2.0), 0.0, 1.0)
	v_y = game.math_utils.f_lerp((-J.n(100.0)), 48.0, game.math_utils.f_easeOutBack(v_k))
	v_extraH = J.add(J.add(J.add((24.0 if J.gt(J.getv(J.getv(game.j_G, "stat"), "branch"), 0.0) else 0.0), (14.0 if J.gt(J.getv(J.getv(game.j_G, "stat"), "fine"), 0.0) else 0.0)), (12.0 if (J.truth(J.getv(game.j_G, "ferman")) and J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi"))) else 0.0)), ((36.0 if J.truth(J.getv(J.getv(game.j_G, "bahisSonuc"), "kapandi")) else 24.0) if J.truth(J.getv(game.j_G, "bahisSonuc")) else 0.0))
	game.interface_draw.f_panel(((float(game.j_W) / float(2.0)) - 108.0), v_y, 216.0, J.add(178.0, v_extraH), J.add(J.add(game.localization.f_T("GÜN "), J.getv(game.j_G, "day")), game.localization.f_T(" BİTTİ")))
	v_st = J.getv(game.j_G, "stat")
	v_rows = [["wrap", "Dürüm", J.getv(v_st, "wraps")]]
	if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])):
		J.method(v_rows, "push", [["iskender", "İskender", (J.getv(v_st, "isk") if J.truth(J.getv(v_st, "isk")) else 0.0)]])
	if (J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G])) or J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G]))):
		J.method(v_rows, "push", [["cola", "İçecek", J.getv(v_st, "drinks")]])
	if J.truth(J.method(game.j_TUN, "fboxOn", [game.j_G])):
		J.method(v_rows, "push", [["fbox", "Patates porsiyon", J.getv(v_st, "boxes")]])
	if J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])):
		J.method(v_rows, "push", [["sweet", "Tatlı", (J.getv(v_st, "sweets") if J.truth(J.getv(v_st, "sweets")) else 0.0)]])
	J.method(v_rows, "push", [[null, "Kaçan müşteri", J.getv(v_st, "lost")]])
	v_i = 0.0
	while J.lt(v_i, J.getv(v_rows, "length")):
		v_ry = J.add(J.add(v_y, 20.0), (v_i * 13.0))
		if J.lt((J.getv(game.j_G, "sceneT") * 3.0), J.add(v_i, 1.0)):
			v_i = J.add(v_i, 1.0)
			continue
		if J.truth(J.getv(J.getv(v_rows, v_i), 0.0)):
			game.icon_draw.f_icon(J.getv(J.getv(v_rows, v_i), 0.0), ((float(game.j_W) / float(2.0)) - 86.0), J.add(v_ry, 4.0), v_t)
		game.text_draw.f_txt(J.getv(J.getv(v_rows, v_i), 1.0), ((float(game.j_W) / float(2.0)) - 74.0), v_ry, J.getv(game.j_P, "ui4"))
		game.text_draw.f_txt(J.add("x", J.getv(J.getv(v_rows, v_i), 2.0)), J.add((float(game.j_W) / float(2.0)), 92.0), v_ry, (J.getv(game.j_P, "ink") if J.truth(J.getv(J.getv(v_rows, v_i), 0.0)) else J.getv(game.j_P, "ui3")), {"align": "r"})
		J.setv(game.j_ctx, "globalAlpha", 0.28)
		game.f_hl(((float(game.j_W) / float(2.0)) - 92.0), J.add(v_ry, 10.0), 184.0, J.getv(game.j_P, "ui2"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	v_ly = J.add(J.add(v_y, 24.0), (J.getv(v_rows, "length") * 13.0))
	if J.gt(J.getv(game.j_G, "sceneT"), 1.2):
		game.text_draw.f_txt("KAZANÇ", ((float(game.j_W) / float(2.0)) - 92.0), v_ly, J.getv(game.j_P, "ui5"))
		game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(J.getv(v_st, "earned"))), J.add((float(game.j_W) / float(2.0)), 92.0), (v_ly - 3.0), J.getv(game.j_P, "red1"), {"align": "r", "sc": 2.0})
	if J.gt(J.getv(game.j_G, "sceneT"), 1.6):
		game.text_draw.f_txt(J.add(J.add(game.localization.f_T("(bahşiş dahil $"), game.math_utils.f_fmtMoney(J.getv(v_st, "tips"))), ")"), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(v_ly, 14.0), J.getv(game.j_P, "ui3"), {"align": "r"})
	v_dy2 = 0.0
	if (J.gt(J.getv(v_st, "branch"), 0.0) and J.gt(J.getv(game.j_G, "sceneT"), 1.65)):
		game.text_draw.f_txt(J.add((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), game.localization.f_T(" ŞUBE GELİRİ")), ((float(game.j_W) / float(2.0)) - 92.0), J.add(v_ly, 26.0), J.getv(game.j_P, "au2"))
		game.text_draw.f_txt(J.add("+$", game.math_utils.f_fmtMoney(J.getv(v_st, "branch"))), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(v_ly, 26.0), J.getv(game.j_P, "au2"), {"align": "r"})
		game.text_draw.f_txt(J.add(game.localization.f_T("performans %"), floor(((J.getv(v_st, "brPerf") if J.truth(J.getv(v_st, "brPerf")) else 1.0) * 100.0) + 0.5)), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(v_ly, 36.0), J.getv(game.j_P, "ui3"), {"align": "r"})
		v_dy2 = 24.0
	if (J.gt(J.getv(game.j_G, "sceneT"), 1.68) and J.gt(J.getv(v_st, "fine"), 0.0)):
		game.text_draw.f_txt(game.localization.f_T("KESİLEN CEZA"), ((float(game.j_W) / float(2.0)) - 92.0), J.add(J.add(v_ly, 26.0), v_dy2), "#e2483a")
		game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_st, "fine"))), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(J.add(v_ly, 26.0), v_dy2), "#e2483a", {"align": "r"})
		v_dy2 = J.add(v_dy2, 14.0)
	if ((J.truth(J.getv(game.j_G, "ferman")) and J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi"))) and J.gt(J.getv(game.j_G, "sceneT"), 1.68)):
		game.text_draw.f_txt(game.localization.f_T("Ferman ihlali: dükkân erken kapatıldı."), (float(game.j_W) / float(2.0)), J.add(J.add(v_ly, 26.0), v_dy2), "#e2483a", {"align": "c"})
		v_dy2 = J.add(v_dy2, 12.0)
	if (J.gt(J.getv(game.j_G, "sceneT"), 1.69) and J.truth(J.getv(game.j_G, "bahisSonuc"))):
		v_dy2 = (game.rival_panel_draw.f_bahisSonucSatiri(J.add(J.add(v_ly, 26.0), v_dy2)) - J.add(v_ly, 26.0))
	if (J.gt(J.getv(game.j_G, "sceneT"), 1.7) and J.gt(J.getv(v_st, "debtPaid"), 0.0)):
		game.text_draw.f_txt("BORÇ TAKSİTİ", ((float(game.j_W) / float(2.0)) - 92.0), J.add(J.add(v_ly, 26.0), v_dy2), "#a83a2a")
		game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_st, "debtPaid"))), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(J.add(v_ly, 26.0), v_dy2), "#a83a2a", {"align": "r"})
		game.text_draw.f_txt(J.add(game.localization.f_T("kalan borç: $"), game.math_utils.f_fmtMoney(J.getv(game.j_G, "debt"))), J.add((float(game.j_W) / float(2.0)), 92.0), J.add(J.add(v_ly, 36.0), v_dy2), J.getv(game.j_P, "ui3"), {"align": "r"})
	if ((((not J.truth(J.getv(game.j_G, "tutanak"))) and J.gt(J.getv(game.j_G, "sceneT"), 1.9)) and (not J.truth(J.getv(game.j_G, "celeb")))) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 46.0), J.add(J.add(v_y, 156.0), v_extraH), 92.0, 18.0, "DÜKKÂNA GİT", J.getv(game.j_P, "red1"), true))):
		J.method(game.j_SFX, "ui", [])
		J.setv(game.j_G, "scene", "shop")
		J.setv(game.j_G, "sceneT", 0.0)
		J.setv(game.j_SHOP, "bake", null)
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	if J.truth(J.getv(game.j_G, "tutanak")):
		game.day_end_draw.f_drawTutanak(v_t)
	if J.truth(J.getv(game.j_G, "celeb")):
		game.title_draw.f_drawDebtFree(v_t)
	return null

# ui.js:1241
func f_drawTutanak(p_t: Variant = null) -> Variant:
	var v_TU: Variant = null
	var v_n: Variant = null
	var v_gorunen: Variant = null
	var v_a: Variant = null
	var v_satirH: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_kk2: Variant = null
	var v_px2: Variant = null
	var v_py2: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_ry: Variant = null
	var v_ka: Variant = null
	var v_rx: Variant = null
	var v_ay2: Variant = null
	var v_t: Variant = p_t
	v_TU = J.getv(game.j_G, "tutanak")
	J.setv(v_TU, "t", J.add(J.getv(v_TU, "t"), (float(1.0) / float(60.0))))
	v_n = J.getv(J.getv(v_TU, "kayit"), "length")
	v_gorunen = game.math_utils.f_clamp(floor((float((J.getv(v_TU, "t") - 0.55)) / float(0.55))), 0.0, v_n)
	if J.gt(v_gorunen, (J.getv(v_TU, "sayilan") if J.truth(J.getv(v_TU, "sayilan")) else 0.0)):
		J.setv(v_TU, "sayilan", v_gorunen)
		J.method(game.j_SFX, "bad", [])
		game.effects.f_shake(0.12)
	v_a = game.math_utils.f_clamp((J.getv(v_TU, "t") * 2.4), 0.0, 1.0)
	J.setv(game.j_ctx, "globalAlpha", (0.74 * v_a))
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_satirH = 11.0
	v_pw = 292.0
	v_ph = J.add(J.add(40.0, (v_n * v_satirH)), 34.0)
	v_kk2 = game.interface_draw.f_panelKutu(0.0, v_ph)
	v_ph = J.getv(v_kk2, 1.0)
	v_px2 = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_py2 = floor(game.math_utils.f_lerp((-J.n(v_ph)), J.getv(v_kk2, 0.0), game.math_utils.f_easeOutBack(v_a)) + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_fr(J.add(v_px2, 4.0), J.add(v_py2, 5.0), v_pw, v_ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_px2, v_py2, v_pw, v_ph, "#c0b89e")
	game.f_fr(J.add(v_px2, 1.0), J.add(v_py2, 1.0), (v_pw - 2.0), (v_ph - 2.0), "#ece5cf")
	game.f_hl(J.add(v_px2, 1.0), J.add(v_py2, 1.0), (v_pw - 2.0), "#f8f2dd")
	game.f_fr(v_px2, v_py2, v_pw, 3.0, "#8e1c14")
	game.text_draw.f_txt(game.localization.f_T("İHLAL TUTANAĞI"), J.add(v_px2, (float(v_pw) / float(2.0))), J.add(v_py2, 8.0), "#8e1c14", {"align": "c"})
	J.setv(game.j_ctx, "globalAlpha", 0.45)
	game.f_hl(J.add(v_px2, 12.0), J.add(v_py2, 20.0), (v_pw - 24.0), "#8a8370")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, v_gorunen):
		v_k = J.getv(J.getv(v_TU, "kayit"), v_i)
		v_ry = J.add(J.add(v_py2, 26.0), (v_i * v_satirH))
		v_ka = game.math_utils.f_clamp((((J.getv(v_TU, "t") - 0.55) - (v_i * 0.55)) * 5.0), 0.0, 1.0)
		J.setv(game.j_ctx, "globalAlpha", v_ka)
		v_rx = J.add(J.add(v_px2, 14.0), floor(((1.0 - v_ka) * 10.0) + 0.5))
		game.f_fr((v_rx - 4.0), J.add(v_ry, 1.0), 2.0, 7.0, "#b83228")
		game.day_end_draw.f_tutanakIkon(J.add(v_rx, 1.0), v_ry, J.getv(v_k, "nerede"))
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_k, "metin")), J.add(v_rx, 12.0), v_ry, "#3a3630")
		game.text_draw.f_txt(J.add("-$", game.math_utils.f_fmtMoney(J.getv(v_k, "para"))), (J.add(v_px2, v_pw) - 14.0), v_ry, "#a83a2a", {"align": "r"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	v_ay2 = (J.add(v_py2, v_ph) - 26.0)
	if J.ge(v_gorunen, v_n):
		J.setv(game.j_ctx, "globalAlpha", 0.45)
		game.f_hl(J.add(v_px2, 12.0), (v_ay2 - 6.0), (v_pw - 24.0), "#8a8370")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.text_draw.f_txt(J.add(game.localization.f_T("Toplam ceza: $"), game.math_utils.f_fmtMoney((v_n * game.j_FERMAN_CEZA_PARA))), J.add(v_px2, 14.0), (v_ay2 - 2.0), "#a83a2a")
		if J.truth(game.f_button((J.add(v_px2, v_pw) - 84.0), (v_ay2 - 4.0), 70.0, 16.0, game.localization.f_T("İMZALA"), "#8e2318", true)):
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_G, "tutanak", null)
	return null

# ui.js:1294
func f_tutanakIkon(p_x: Variant = null, p_y: Variant = null, p_nerede: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_nerede: Variant = p_nerede
	if J.eq(v_nerede, "telefon"):
		game.f_fr(v_x, J.add(v_y, 1.0), 8.0, 2.0, "#6a6455")
		game.f_fr(v_x, J.add(v_y, 3.0), 2.0, 2.0, "#6a6455")
		game.f_fr(J.add(v_x, 6.0), J.add(v_y, 3.0), 2.0, 2.0, "#6a6455")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 6.0), 6.0, 1.0, "#8a8370")
		return null
	if J.eq(v_nerede, "sokak"):
		game.f_fr(J.add(v_x, 3.0), J.add(v_y, 2.0), 1.0, 6.0, "#6a6455")
		game.f_fr(J.add(v_x, 1.0), v_y, 5.0, 3.0, "#8a8370")
		game.f_fr(J.add(v_x, 2.0), J.add(v_y, 1.0), 3.0, 1.0, "#d8c88a")
	else:
		game.f_rc(v_x, v_y, 8.0, 8.0, "#6a6455")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), 6.0, 6.0, "#b8cdd8")
		game.f_fr(J.add(v_x, 3.0), J.add(v_y, 1.0), 1.0, 6.0, "#6a6455")
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, 3.0), 6.0, 1.0, "#6a6455")
	return null

