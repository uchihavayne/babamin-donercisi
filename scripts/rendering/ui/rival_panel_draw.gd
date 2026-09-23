# Rival panel draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:2887
func f_drawBahisPanel(p_t: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_sy0: Variant = null
	var v_sh0: Variant = null
	var v_kalanO: Variant = null
	var v_t: Variant = p_t
	v_R = J.getv(game.j_G, "rakip")
	if ((not J.truth(v_R)) or not J.eq(J.getv(v_R, "faz"), "teklif")):
		return null
	v_pw = 230.0
	v_ph = 96.0
	v_px0 = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_py0 = 22.0
	game.interface_draw.f_panel(v_px0, v_py0, v_pw, v_ph)
	game.rival_panel_draw.f_rakipYuz(J.add(v_px0, 15.0), J.add(v_py0, 16.0))
	game.text_draw.f_txt(game.localization.f_T("KARŞIDAKİ DÖNERCİ"), J.add(v_px0, 30.0), J.add(v_py0, 8.0), J.getv(game.j_P, "red1"))
	game.text_draw.f_txt(game.localization.f_T(J.getv(v_R, "selam")), J.add(v_px0, 30.0), J.add(v_py0, 19.0), J.getv(game.j_P, "ui3"))
	v_sy0 = J.add(v_py0, 30.0)
	v_sh0 = 26.0
	game.f_rrect(J.add(v_px0, 8.0), v_sy0, (v_pw - 16.0), v_sh0, 3.0, J.getv(game.j_P, "ui2"))
	game.f_rrect(J.add(v_px0, 9.0), J.add(v_sy0, 1.0), (v_pw - 18.0), (v_sh0 - 2.0), 3.0, J.getv(game.j_P, "ui1"))
	game.f_hl(J.add(v_px0, 11.0), J.add(v_sy0, 1.0), (v_pw - 22.0), "#f2e3c2")
	game.text_draw.f_txt(game.rival_system.f_bahisMetni(v_R), J.add(v_px0, 13.0), J.add(v_sy0, 4.0), J.getv(game.j_P, "ui5"))
	game.text_draw.f_txt(J.add(J.add(game.localization.f_T("Kaybeden ötekine $"), game.math_utils.f_fmtMoney(J.getv(v_R, "para"))), game.localization.f_T(" verir.")), J.add(v_px0, 13.0), J.add(v_sy0, 15.0), J.getv(game.j_P, "red3"))
	v_kalanO = game.math_utils.f_clamp((1.0 - (float(J.getv(v_R, "t")) / float(20.0))), 0.0, 1.0)
	game.f_fr(J.add(v_px0, 10.0), J.add(v_py0, 62.0), (v_pw - 20.0), 2.0, "rgba(0,0,0,.45)")
	game.f_fr(J.add(v_px0, 10.0), J.add(v_py0, 62.0), floor(((v_pw - 20.0) * v_kalanO) + 0.5), 2.0, (J.getv(game.j_P, "bad") if J.lt(v_kalanO, 0.3) else J.getv(game.j_P, "ui3")))
	if J.lt(v_kalanO, 0.35):
		game.text_draw.f_txt(game.localization.f_T("...cevap bekliyor"), (float(game.j_W) / float(2.0)), J.add(v_py0, 66.0), J.getv(game.j_P, "ui4"), {"align": "c"})
	if J.truth(game.f_button(J.add(v_px0, 10.0), J.add(v_py0, 74.0), 100.0, 16.0, game.localization.f_T("Girdim bahse"), "#3f8a4a", true)):
		game.rival_system.f_rakipCevap(true)
	if J.truth(game.f_button((J.add(v_px0, v_pw) - 110.0), J.add(v_py0, 74.0), 100.0, 16.0, game.localization.f_T("Bugün olmaz"), "#6b4a3a", true)):
		game.rival_system.f_rakipCevap(false)
	return null

# ui.js:2925
func f_rakipYuz(p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	game.f_fr((v_x - 7.0), (v_y - 7.0), 14.0, 14.0, "#b98b6a")
	game.f_fr((v_x - 7.0), (v_y - 7.0), 14.0, 3.0, "#a87a54")
	game.f_fr((v_x - 8.0), (v_y - 9.0), 16.0, 4.0, "#2a2018")
	game.f_fr((v_x - 8.0), (v_y - 7.0), 2.0, 5.0, "#2a2018")
	game.f_fr(J.add(v_x, 6.0), (v_y - 7.0), 2.0, 5.0, "#2a2018")
	game.f_fr((v_x - 8.0), (v_y - 11.0), 16.0, 3.0, "#2f6a8a")
	game.f_px((v_x - 3.0), (v_y - 1.0), "#1a1410")
	game.f_px(J.add(v_x, 2.0), (v_y - 1.0), "#1a1410")
	game.f_fr((v_x - 4.0), (v_y - 3.0), 3.0, 1.0, "#2a2018")
	game.f_fr(J.add(v_x, 1.0), (v_y - 3.0), 3.0, 1.0, "#2a2018")
	game.f_fr((v_x - 2.0), J.add(v_y, 3.0), 5.0, 2.0, "#2a2018")
	return null

# ui.js:2937
func f_bahisSonucSatiri(p_y: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_ms: Variant = null
	var v_gost: Variant = null
	var v_y: Variant = p_y
	v_S = J.getv(game.j_G, "bahisSonuc")
	if (not J.truth(v_S)):
		return v_y
	v_ms = (J.add(game.localization.f_T("Bahsi kazandın! +$"), game.math_utils.f_fmtMoney(J.getv(v_S, "para"))) if J.truth(J.getv(v_S, "kazandi")) else J.add(game.localization.f_T("Bahsi kaybettin. -$"), game.math_utils.f_fmtMoney(J.getv(v_S, "para"))))
	game.text_draw.f_txt(v_ms, (float(game.j_W) / float(2.0)), v_y, (J.getv(game.j_P, "ok") if J.truth(J.getv(v_S, "kazandi")) else J.getv(game.j_P, "bad")), {"align": "c"})
	v_y = J.add(v_y, 11.0)
	v_gost = ((-J.n(J.getv(v_S, "deger"))) if J.eq(J.getv(v_S, "tip"), "kacan") else J.getv(v_S, "deger"))
	game.text_draw.f_txt(J.add(J.add(J.add(game.localization.f_T("hedef "), J.getv(v_S, "hedef")), game.localization.f_T("  •  senin: ")), v_gost), (float(game.j_W) / float(2.0)), v_y, J.getv(game.j_P, "ui3"), {"align": "c"})
	v_y = J.add(v_y, 12.0)
	if J.truth(J.getv(v_S, "kapandi")):
		game.text_draw.f_txt(game.localization.f_T("RAKİP DÜKKÂNI KAPATTI"), (float(game.j_W) / float(2.0)), v_y, J.getv(game.j_P, "au0"), {"align": "c"})
		v_y = J.add(v_y, 12.0)
	return v_y
	return null

