# Settings draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:2029
func f_drawCustomPanel(p_t: Variant = null) -> Variant:
	var v_x: Variant = null
	var v_y: Variant = null
	var v_w: Variant = null
	var v_h: Variant = null
	var v_fx: Variant = null
	var v_fy: Variant = null
	var v_fw: Variant = null
	var v_nm: Variant = null
	var v_subs: Variant = null
	var v_si: Variant = null
	var v_pvx: Variant = null
	var v_pvy: Variant = null
	var v_pvw: Variant = null
	var v_pvh: Variant = null
	var v_TM: Variant = null
	var v_DP: Variant = null
	var v_ty2: Variant = null
	var v_tx2: Variant = null
	var v_hs: Variant = null
	var v_sgw: Variant = null
	var v_sgx: Variant = null
	var v_sus: Variant = null
	var v_CP: Variant = null
	var v_t: Variant = p_t
	v_x = 60.0
	v_y = 34.0
	v_w = 360.0
	v_h = 200.0
	J.setv(game.j_ctx, "globalAlpha", 0.8)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "DÜKKÂNI KİŞİSELLEŞTİR")
	game.text_draw.f_txt("Tabela adı", J.add(v_x, 14.0), J.add(v_y, 16.0), J.getv(game.j_P, "ui4"))
	v_fx = J.add(v_x, 14.0)
	v_fy = J.add(v_y, 26.0)
	v_fw = 118.0
	game.f_rrect(v_fx, v_fy, v_fw, 16.0, 3.0, ("#fffdf0" if J.truth(J.getv(game.j_CUSTOM, "edit")) else J.getv(game.j_P, "ui1")))
	game.f_rrectOut(v_fx, v_fy, v_fw, 16.0, 3.0, (J.getv(game.j_P, "au2") if J.truth(J.getv(game.j_CUSTOM, "edit")) else J.getv(game.j_P, "ui3")))
	v_nm = (J.getv(game.j_TEXTIN, "value") if J.truth(J.getv(game.j_CUSTOM, "edit")) else J.getv(J.getv(game.j_G, "custom"), "sign"))
	game.text_draw.f_txt(v_nm, J.add(v_fx, 5.0), J.add(v_fy, 4.0), J.getv(game.j_P, "ink"))
	if (J.truth(J.getv(game.j_CUSTOM, "edit")) and J.gt(sin((v_t * 8.0)), 0.0)):
		game.f_fr(J.add(J.add(v_fx, 6.0), game.f_textW(v_nm)), J.add(v_fy, 3.0), 1.0, 10.0, J.getv(game.j_P, "ink"))
	if ((not J.truth(J.getv(game.j_CUSTOM, "edit"))) and J.truth(game.f_button(J.add(J.add(v_fx, v_fw), 6.0), v_fy, 52.0, 16.0, "DEĞİŞTİR", "#3f6fbd"))):
		J.setv(game.j_CUSTOM, "edit", true)
		game.effects.f_textStart(J.getv(J.getv(game.j_G, "custom"), "sign"), 14.0)
		J.method(game.j_SFX, "ui", [])
	if J.truth(J.getv(game.j_CUSTOM, "edit")):
		game.text_draw.f_txt("Enter=kaydet", J.add(J.add(v_fx, v_fw), 8.0), J.add(v_fy, 1.0), J.getv(game.j_P, "ui3"))
		game.text_draw.f_txt("Esc=vazgeç", J.add(J.add(v_fx, v_fw), 8.0), J.add(v_fy, 10.0), J.getv(game.j_P, "ui3"))
		if J.truth(J.getv(game.j_TEXTIN, "done")):
			J.setv(J.getv(game.j_G, "custom"), "sign", (J.method(J.getv(game.j_TEXTIN, "value"), "trim", []) if J.truth(J.method(J.getv(game.j_TEXTIN, "value"), "trim", [])) else "USTA DÖNER"))
			J.setv(game.j_CUSTOM, "edit", false)
			game.effects.f_textStop()
			J.method(game.j_SFX, "ding", [])
			game.save_system.f_saveAll()
		if J.truth(J.getv(game.j_TEXTIN, "cancel")):
			J.setv(game.j_CUSTOM, "edit", false)
			game.effects.f_textStop()
			J.method(game.j_SFX, "uiBack", [])
	game.text_draw.f_txt("Alt yazı", J.add(v_x, 14.0), J.add(v_y, 48.0), J.getv(game.j_P, "ui4"))
	v_subs = ["EFSANE LEZZET", "BABADAN OĞULA", "1985 TEN BERİ", "TAM DÖNER", ""]
	v_si = J.method(v_subs, "indexOf", [J.getv(J.getv(game.j_G, "custom"), "sub")])
	if J.lt(v_si, 0.0):
		v_si = 0.0
	if J.truth(game.f_button(J.add(v_x, 14.0), J.add(v_y, 58.0), 16.0, 16.0, "<", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "sub", J.getv(v_subs, fmod(J.n((J.add(v_si, J.getv(v_subs, "length")) - 1.0)), J.n(J.getv(v_subs, "length")))))
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	if J.truth(game.f_button(J.add(v_x, 164.0), J.add(v_y, 58.0), 16.0, 16.0, ">", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "sub", J.getv(v_subs, fmod(J.n(J.add(v_si, 1.0)), J.n(J.getv(v_subs, "length")))))
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	game.f_rrect(J.add(v_x, 32.0), J.add(v_y, 58.0), 130.0, 16.0, 3.0, J.getv(game.j_P, "ui1"))
	game.text_draw.f_txt((J.getv(J.getv(game.j_G, "custom"), "sub") if J.truth(J.getv(J.getv(game.j_G, "custom"), "sub")) else "(yok)"), J.add(v_x, 97.0), J.add(v_y, 62.0), J.getv(game.j_P, "ink"), {"align": "c"})
	game.text_draw.f_txt("Duvar süsü", J.add(v_x, 14.0), J.add(v_y, 82.0), J.getv(game.j_P, "ui4"))
	if J.truth(game.f_button(J.add(v_x, 14.0), J.add(v_y, 92.0), 16.0, 16.0, "<", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "poster", fmod(J.n((J.add(J.getv(J.getv(game.j_G, "custom"), "poster"), J.getv(game.j_POSTERS, "length")) - 1.0)), J.n(J.getv(game.j_POSTERS, "length"))))
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	if J.truth(game.f_button(J.add(v_x, 164.0), J.add(v_y, 92.0), 16.0, 16.0, ">", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "poster", fmod(J.n(J.add(J.getv(J.getv(game.j_G, "custom"), "poster"), 1.0)), J.n(J.getv(game.j_POSTERS, "length"))))
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	game.f_rrect(J.add(v_x, 32.0), J.add(v_y, 92.0), 130.0, 16.0, 3.0, J.getv(game.j_P, "ui1"))
	game.text_draw.f_txt(J.getv(game.j_POSTERS, J.getv(J.getv(game.j_G, "custom"), "poster")), J.add(v_x, 97.0), J.add(v_y, 96.0), J.getv(game.j_P, "ink"), {"align": "c"})
	game.text_draw.f_txt("Tezgâh rengi", J.add(v_x, 14.0), J.add(v_y, 116.0), J.getv(game.j_P, "ui4"))
	if J.truth(game.f_button(J.add(v_x, 14.0), J.add(v_y, 126.0), 16.0, 16.0, "<", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "counter", fmod(J.n((J.add(J.getv(J.getv(game.j_G, "custom"), "counter"), J.getv(game.j_COUNTER_STYLES, "length")) - 1.0)), J.n(J.getv(game.j_COUNTER_STYLES, "length"))))
		game.j_CLAYER = null
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	if J.truth(game.f_button(J.add(v_x, 164.0), J.add(v_y, 126.0), 16.0, 16.0, ">", "#7a6040")):
		J.setv(J.getv(game.j_G, "custom"), "counter", fmod(J.n(J.add(J.getv(J.getv(game.j_G, "custom"), "counter"), 1.0)), J.n(J.getv(game.j_COUNTER_STYLES, "length"))))
		game.j_CLAYER = null
		J.method(game.j_SFX, "ui", [])
		game.save_system.f_saveAll()
	game.f_rrect(J.add(v_x, 32.0), J.add(v_y, 126.0), 130.0, 16.0, 3.0, J.getv(game.j_P, "ui1"))
	game.text_draw.f_txt(J.getv(game.j_COUNTER_STYLES, J.getv(J.getv(game.j_G, "custom"), "counter")), J.add(v_x, 97.0), J.add(v_y, 130.0), J.getv(game.j_P, "ink"), {"align": "c"})
	v_pvx = J.add(v_x, 200.0)
	v_pvy = J.add(v_y, 20.0)
	v_pvw = 146.0
	v_pvh = 120.0
	game.f_rrect(v_pvx, v_pvy, v_pvw, v_pvh, 3.0, "#2b241c")
	game.f_rrectOut(v_pvx, v_pvy, v_pvw, v_pvh, 3.0, J.getv(game.j_P, "ui3"))
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [J.add(v_pvx, 2.0), J.add(v_pvy, 2.0), (v_pvw - 4.0), (v_pvh - 4.0)])
	J.method(game.j_ctx, "clip", [])
	v_TM = game.city_system.f_sehirTema()
	v_DP = game.city_system.f_duvarPaleti(v_TM, game.equipment_system.f_UV(game.j_G, "paint"))
	game.f_fr(J.add(v_pvx, 2.0), J.add(v_pvy, 2.0), (v_pvw - 4.0), (v_pvh - 4.0), J.getv(v_DP, 3.0))
	v_ty2 = J.add(v_pvy, 2.0)
	while J.lt(v_ty2, (J.add(v_pvy, v_pvh) - 2.0)):
		v_tx2 = J.add(v_pvx, 2.0)
		while J.lt(v_tx2, (J.add(v_pvx, v_pvw) - 2.0)):
			v_hs = game.f_hash1(J.add((v_tx2 * 0.37), (v_ty2 * 1.13)))
			game.f_fr(J.add(v_tx2, 1.0), J.add(v_ty2, 1.0), 11.0, 11.0, (J.getv(v_DP, 0.0) if J.lt(v_hs, 0.18) else (J.getv(v_DP, 1.0) if J.lt(v_hs, 0.62) else J.getv(v_DP, 2.0))))
			game.f_hl(J.add(v_tx2, 1.0), J.add(v_ty2, 1.0), 11.0, J.getv(v_DP, 0.0))
			v_tx2 = J.add(v_tx2, 12.0)
		v_ty2 = J.add(v_ty2, 12.0)
	J.setv(game.j_ctx, "globalAlpha", 0.18)
	game.f_fr(J.add(v_pvx, 2.0), J.add(v_pvy, 2.0), (v_pvw - 4.0), (v_pvh - 4.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(game.equipment_system.f_UV(game.j_G, "sign"), 0.0):
		v_sgw = game.decor_draw.f_tabelaGen()
		v_sgx = floor((J.add(v_pvx, (float(v_pvw) / float(2.0))) - (float(v_sgw) / float(2.0))) + 0.5)
		J.method(game.j_ctx, "save", [])
		if J.gt(v_sgw, (v_pvw - 10.0)):
			J.method(game.j_ctx, "beginPath", [])
			J.method(game.j_ctx, "rect", [J.add(v_pvx, 4.0), J.add(v_pvy, 4.0), (v_pvw - 8.0), 34.0])
			J.method(game.j_ctx, "clip", [])
		game.decor_draw.f_drawTabela(v_sgx, J.add(v_pvy, 8.0), v_t)
		J.method(game.j_ctx, "restore", [])
	else:
		game.text_draw.f_txt(game.localization.f_T("Tabela kapalı"), J.add(v_pvx, (float(v_pvw) / float(2.0))), J.add(v_pvy, 16.0), J.getv(game.j_P, "ui3"), {"align": "c"})
	v_sus = ((J.getv(J.getv(game.j_G, "custom"), "poster") if J.truth(J.getv(game.j_G, "custom")) else J.getv(game.j_G, "custom")) if (J.truth(J.getv(game.j_G, "custom")) and J.truth(J.getv(J.getv(game.j_G, "custom"), "poster"))) else 0.0)
	if J.gt(v_sus, 0.0):
		game.f_drawPoster(v_sus, v_t, floor((J.add(v_pvx, (float(v_pvw) / float(2.0))) - 21.0) + 0.5), J.add(v_pvy, 44.0))
	else:
		game.text_draw.f_txt(game.localization.f_T("Süs yok"), J.add(v_pvx, (float(v_pvw) / float(2.0))), J.add(v_pvy, 56.0), J.getv(game.j_P, "ui3"), {"align": "c"})
	J.method(game.j_ctx, "restore", [])
	v_CP = J.getv(game.j_COUNTER_PAL, fmod(J.n(J.getv(J.getv(game.j_G, "custom"), "counter")), J.n(J.getv(game.j_COUNTER_PAL, "length"))))
	game.f_fr(J.add(v_pvx, 8.0), (J.add(v_pvy, v_pvh) - 34.0), (v_pvw - 16.0), 18.0, J.getv(v_CP, "base"))
	game.f_hl(J.add(v_pvx, 8.0), (J.add(v_pvy, v_pvh) - 34.0), (v_pvw - 16.0), J.getv(v_CP, "edge"))
	game.f_fr(J.add(v_pvx, 8.0), (J.add(v_pvy, v_pvh) - 16.0), (v_pvw - 16.0), 6.0, J.getv(v_CP, "lip"))
	game.text_draw.f_txt("önizleme", J.add(v_pvx, (float(v_pvw) / float(2.0))), (J.add(v_pvy, v_pvh) - 9.0), J.getv(game.j_P, "ui3"), {"align": "c"})
	if ((not J.truth(J.getv(game.j_CUSTOM, "edit"))) and J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 40.0), (J.add(v_y, v_h) - 22.0), 80.0, 18.0, "KAPAT", "#3f8a4a", true))):
		J.setv(game.j_CUSTOM, "open", false)
		J.method(game.j_SFX, "uiBack", [])
		game.save_system.f_saveAll()
	return null

# ui.js:2129
func f_simgeNota(p_x: Variant = null, p_y: Variant = null, p_sesli: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_c2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_sesli: Variant = p_sesli
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_c = ("#8fc4e8" if J.truth(v_sesli) else "#6a6a6a")
	v_c2 = ("#d8ecf8" if J.truth(v_sesli) else "#8a8a8a")
	game.f_fr(J.add(v_x, 2.0), (v_y - 6.0), 2.0, 9.0, v_c)
	game.f_hl(J.add(v_x, 2.0), (v_y - 6.0), 2.0, v_c2)
	game.f_fr(J.add(v_x, 4.0), (v_y - 6.0), 3.0, 2.0, v_c)
	game.f_fr(J.add(v_x, 5.0), (v_y - 4.0), 2.0, 2.0, v_c)
	game.f_ell(v_x, J.add(v_y, 3.0), 3.0, 2.0, v_c)
	game.f_ell((v_x - 1.0), J.add(v_y, 2.0), 2.0, 1.0, v_c2)
	return null

# ui.js:2145
func f_simgeHoparlor(p_x: Variant = null, p_y: Variant = null, p_seviye: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_c2: Variant = null
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_seviye: Variant = p_seviye
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_c = ("#e8c07a" if J.gt(v_seviye, 0.0) else "#6a6a6a")
	v_c2 = ("#fff0c8" if J.gt(v_seviye, 0.0) else "#8a8a8a")
	game.f_fr((v_x - 5.0), (v_y - 2.0), 3.0, 5.0, v_c)
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.f_fr(J.add((v_x - 2.0), v_i), ((v_y - 3.0) - v_i), 1.0, J.add(7.0, (v_i * 2.0)), v_c)
		v_i = J.add(v_i, 1.0)
	game.f_hl((v_x - 5.0), (v_y - 2.0), 3.0, v_c2)
	if J.gt(v_seviye, 20.0):
		game.f_fr(J.add(v_x, 3.0), (v_y - 2.0), 1.0, 5.0, v_c2)
	if J.gt(v_seviye, 55.0):
		game.f_fr(J.add(v_x, 5.0), (v_y - 4.0), 1.0, 9.0, v_c2)
	if J.gt(v_seviye, 85.0):
		game.f_fr(J.add(v_x, 7.0), (v_y - 6.0), 1.0, 13.0, v_c2)
	if J.eq(v_seviye, 0.0):
		game.f_ln(J.add(v_x, 3.0), (v_y - 3.0), J.add(v_x, 8.0), J.add(v_y, 3.0), "#c0392b")
		game.f_ln(J.add(v_x, 3.0), J.add(v_y, 3.0), J.add(v_x, 8.0), (v_y - 3.0), "#c0392b")
	return null

# ui.js:2169
func f_volSlider(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_deger: Variant = null, p_tur: Variant = null, p_renk: Variant = null, p_t: Variant = null) -> Variant:
	var v_h: Variant = null
	var v_uzeri: Variant = null
	var v_dw: Variant = null
	var v_hx: Variant = null
	var v_yeni: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_deger: Variant = p_deger
	var v_tur: Variant = p_tur
	var v_renk: Variant = p_renk
	var v_t: Variant = p_t
	v_h = 9.0
	v_uzeri = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (v_x - 4.0), (v_y - 5.0), J.add(v_w, 8.0), J.add(v_h, 10.0))
	game.f_rrect(v_x, v_y, v_w, v_h, 3.0, "#241c16")
	game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), 2.0, "#3a3028")
	v_dw = floor((float(((v_w - 2.0) * game.math_utils.f_clamp(v_deger, 0.0, 100.0))) / float(100.0)) + 0.5)
	if J.gt(v_dw, 0.0):
		game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), v_dw, (v_h - 2.0), 2.0, game.character_draw.f_shadeCol(v_renk, 0.68))
		game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), v_dw, (v_h - 3.0), 2.0, v_renk)
		game.f_hl(J.add(v_x, 2.0), J.add(v_y, 1.0), max(0.0, (v_dw - 2.0)), game.character_draw.f_shadeCol(v_renk, 1.45))
	v_hx = J.add(J.add(v_x, 1.0), v_dw)
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_rrect((v_hx - 3.0), (v_y - 2.0), 7.0, J.add(v_h, 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect((v_hx - 3.0), (v_y - 3.0), 7.0, J.add(v_h, 4.0), 2.0, ("#fff4d8" if J.truth(v_uzeri) else "#e8e2d0"))
	game.f_rrect((v_hx - 2.0), (v_y - 2.0), 5.0, J.add(v_h, 2.0), 2.0, ("#ffffff" if J.truth(v_uzeri) else "#f6f2e6"))
	game.f_vl(v_hx, (v_y - 1.0), J.add(v_h, 1.0), game.character_draw.f_shadeCol(v_renk, 0.8))
	if (not J.truth(J.getv(game.j_IN, "down"))):
		if J.eq(J.getv(game.j_SESP, "tutulan"), v_tur):
			J.setv(game.j_SESP, "tutulan", null)
		return v_uzeri
	if not J.eq(J.getv(game.j_SESP, "tutulan"), v_tur):
		if (not ((J.truth(v_uzeri) and J.truth(J.getv(game.j_IN, "pressed"))) and J.eq(J.getv(game.j_SESP, "tutulan"), null))):
			return v_uzeri
		J.setv(game.j_SESP, "tutulan", v_tur)
	v_yeni = floor(((float(((J.getv(game.j_IN, "x") - v_x) - 1.0)) / float((v_w - 2.0))) * 100.0) + 0.5)
	if not J.eq(v_yeni, J.getv(game.j_VOL, v_tur)):
		game.effects.f_volAyarla(v_tur, v_yeni)
		if (J.eq(v_tur, "sfx") and J.truth(game.f_chance(0.35))):
			J.method(game.j_SFX, "pop", [])
	return v_uzeri
	return null

# ui.js:2209
func f_drawSesPanel(p_t: Variant = null) -> Variant:
	var v_x: Variant = null
	var v_y: Variant = null
	var v_w: Variant = null
	var v_h: Variant = null
	var v_t: Variant = p_t
	v_x = 128.0
	v_y = 52.0
	v_w = 224.0
	v_h = 152.0
	J.setv(game.j_ctx, "globalAlpha", 0.84)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "SES")
	game.settings_draw.f_simgeNota(J.add(v_x, 20.0), J.add(v_y, 26.0), ((not J.truth(game.j_MUTED)) if J.gt(J.getv(game.j_VOL, "mus"), 0.0) else J.gt(J.getv(game.j_VOL, "mus"), 0.0)))
	game.text_draw.f_txt("MÜZİK", J.add(v_x, 32.0), J.add(v_y, 22.0), J.getv(game.j_P, "ink"))
	game.text_draw.f_txt(J.add("", J.getv(game.j_VOL, "mus")), (J.add(v_x, v_w) - 18.0), J.add(v_y, 22.0), ("#2f6a9a" if J.gt(J.getv(game.j_VOL, "mus"), 0.0) else "#9a9288"), {"align": "r"})
	game.f_volSlider(J.add(v_x, 18.0), J.add(v_y, 34.0), (v_w - 36.0), J.getv(game.j_VOL, "mus"), "mus", "#3f8ac0", v_t)
	game.settings_draw.f_simgeHoparlor(J.add(v_x, 22.0), J.add(v_y, 74.0), (0.0 if J.truth(game.j_MUTED) else J.getv(game.j_VOL, "sfx")))
	game.text_draw.f_txt("SES EFEKTLERİ", J.add(v_x, 32.0), J.add(v_y, 70.0), J.getv(game.j_P, "ink"))
	game.text_draw.f_txt(J.add("", J.getv(game.j_VOL, "sfx")), (J.add(v_x, v_w) - 18.0), J.add(v_y, 70.0), ("#8a6210" if J.gt(J.getv(game.j_VOL, "sfx"), 0.0) else "#9a9288"), {"align": "r"})
	game.f_volSlider(J.add(v_x, 18.0), J.add(v_y, 82.0), (v_w - 36.0), J.getv(game.j_VOL, "sfx"), "sfx", "#c08a2a", v_t)
	if J.truth(game.f_button(J.add(v_x, 18.0), J.add(v_y, 104.0), (v_w - 36.0), 20.0, ("SESİ AÇ" if J.truth(game.j_MUTED) else "HEPSİNİ SUSTUR"), ("#3f8a4a" if J.truth(game.j_MUTED) else "#8a4a4a"))):
		game.effects.f_sesKis(game.j_MUTED)
		if (not J.truth(game.j_MUTED)):
			J.method(game.j_SFX, "ui", [])
	if (not J.truth(J.getv(game.j_IN, "down"))):
		J.setv(game.j_SESP, "tutulan", null)
	if J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 40.0), (J.add(v_y, v_h) - 24.0), 80.0, 18.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
		J.setv(game.j_SESP, "open", false)
		J.setv(game.j_SESP, "tutulan", null)
		J.method(game.j_SFX, "uiBack", [])
	return null

