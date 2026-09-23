# Debug draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:1845
func f_testPanelOpen() -> Variant:
	return (not (not J.truth(J.getv(game.j_G, "test"))))
	return null

# ui.js:1846
func f_testHit(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	return (game.math_utils.f_inRect(v_mx, v_my, J.getv(game.j_TESTP, "x"), J.getv(game.j_TESTP, "y"), J.getv(game.j_TESTP, "w"), J.getv(game.j_TESTP, "h")) if J.truth(game.debug_draw.f_testPanelOpen()) else game.debug_draw.f_testPanelOpen())
	return null

# ui.js:1847
func f_tinyBtn(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null, p_col: Variant = null) -> Variant:
	var v_over: Variant = null
	var v_c1: Variant = null
	var v_c2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_label: Variant = p_label
	var v_col: Variant = p_col
	v_over = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), v_x, v_y, v_w, v_h)
	v_c1 = game.character_draw.f_shadeCol(v_col, (1.3 if J.truth(v_over) else 1.0))
	v_c2 = game.character_draw.f_shadeCol(v_col, 0.6)
	game.f_rrect(v_x, v_y, v_w, v_h, 2.0, v_c2)
	game.f_rrect(v_x, v_y, v_w, (v_h - 1.0), 2.0, v_c1)
	game.f_rrectOut(v_x, v_y, v_w, v_h, 2.0, J.getv(game.j_P, "ui5"))
	game.text_draw.f_txt(v_label, J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, (float((v_h - 8.0)) / float(2.0))), J.getv(game.j_P, "ui0"), {"align": "c"})
	return (J.getv(game.j_IN, "pressed") if J.truth(v_over) else v_over)
	return null

# ui.js:1856
func f_setUp(p_id: Variant = null, p_lvl: Variant = null) -> Variant:
	var v_u: Variant = null
	var v_m: Variant = null
	var v_i: Variant = null
	var v_id: Variant = p_id
	var v_lvl: Variant = p_lvl
	v_u = game.equipment_system.f_upgById(v_id)
	if (not J.truth(v_u)):
		return null
	J.setv(J.getv(game.j_G, "up"), v_id, game.math_utils.f_clamp(v_lvl, 0.0, J.getv(J.getv(v_u, "lv"), "length")))
	if J.eq(J.getv(J.getv(game.j_G, "up"), v_id), 0.0):
		J.delv(J.getv(game.j_G, "up"), v_id)
	if J.eq(v_id, "paint"):
		game.j_BG = null
	if (J.eq(v_id, "expand") and J.truth(J.getv(game.j_G, "cfg"))):
		J.setv(J.getv(game.j_G, "cfg"), "slots", J.method(game.j_TUN, "slots", [game.j_G]))
	if (J.eq(v_id, "uncle") and J.truth(J.getv(game.j_G, "uncle"))):
		J.setv(J.getv(game.j_G, "uncle"), "left", J.method(game.j_TUN, "uncleUses", [game.j_G]))
	if J.eq(v_id, "store"):
		v_m = J.method(game.j_TUN, "stockMax", [game.j_G])
		J.setv(J.getv(game.j_G, "stock"), "pickle", min(J.getv(J.getv(game.j_G, "stock"), "pickle"), v_m))
		J.setv(J.getv(game.j_G, "stock"), "yogurt", min(J.getv(J.getv(game.j_G, "stock"), "yogurt"), v_m))
	if (J.eq(v_id, "phone") and (not J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G])))):
		game.phone_system.f_phoneReset()
	if J.eq(v_id, "board"):
		v_i = J.method(game.j_TUN, "boards", [game.j_G])
		while J.lt(v_i, 3.0):
			J.setv(J.getv(game.j_G, "boards"), v_i, null)
			v_i = J.add(v_i, 1.0)
		J.setv(game.j_G, "sel", min(J.getv(game.j_G, "sel"), (J.method(game.j_TUN, "boards", [game.j_G]) - 1.0)))
	game.save_system.f_saveAll()
	return null

# ui.js:1878
func f_drawTestPanel(p_t: Variant = null) -> Variant:
	var v_P0: Variant = null
	var v_by: Variant = null
	var v_bx: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	var v_dby: Variant = null
	var v_rowH: Variant = null
	var v_colW: Variant = null
	var v_top: Variant = null
	var v_SATIR: Variant = null
	var v_SAYFADA: Variant = null
	var v_sayfaAdet: Variant = null
	var v_bas: Variant = null
	var v_k: Variant = null
	var v_u: Variant = null
	var v_yer: Variant = null
	var v_col: Variant = null
	var v_row: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_lvl: Variant = null
	var v_max: Variant = null
	var v_sub: Variant = null
	var v_d: Variant = null
	var v_dx: Variant = null
	var v_ey: Variant = null
	var v_ebx: Variant = null
	var v_eby: Variant = null
	var v_M0: Variant = null
	var v_gecen: Variant = null
	var v_eskiGun: Variant = null
	var v_HAVALAR: Variant = null
	var v_hi: Variant = null
	var v_son: Variant = null
	var v_q: Variant = null
	var v_t: Variant = p_t
	v_P0 = game.j_TESTP
	J.setv(game.j_ctx, "globalAlpha", 0.82)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(J.getv(v_P0, "x"), J.getv(v_P0, "y"), J.getv(v_P0, "w"), J.getv(v_P0, "h"), 4.0, J.getv(game.j_P, "ui5"))
	game.f_rrect(J.add(J.getv(v_P0, "x"), 1.0), J.add(J.getv(v_P0, "y"), 1.0), (J.getv(v_P0, "w") - 2.0), (J.getv(v_P0, "h") - 2.0), 4.0, "#241c16")
	game.f_rrectOut(J.getv(v_P0, "x"), J.getv(v_P0, "y"), J.getv(v_P0, "w"), J.getv(v_P0, "h"), 4.0, J.getv(game.j_P, "au2"))
	game.text_draw.f_txt("TEST PANELİ", J.add(J.getv(v_P0, "x"), 8.0), J.add(J.getv(v_P0, "y"), 5.0), J.getv(game.j_P, "au0"))
	game.text_draw.f_txt("T = kapat", (J.add(J.getv(v_P0, "x"), J.getv(v_P0, "w")) - 8.0), J.add(J.getv(v_P0, "y"), 5.0), J.getv(game.j_P, "ui2"), {"align": "r"})
	v_by = J.add(J.getv(v_P0, "y"), 16.0)
	v_bx = J.add(J.getv(v_P0, "x"), 6.0)
	if J.truth(game.f_tinyBtn(v_bx, v_by, 62.0, 14.0, "HEPSİ MAX", "#3f8a4a")):
		v_i = 0.0
		while J.lt(v_i, J.getv(game.j_UPG, "length")):
			game.debug_draw.f_setUp(J.getv(J.getv(game.j_UPG, v_i), "id"), J.getv(J.getv(J.getv(game.j_UPG, v_i), "lv"), "length"))
			v_i = J.add(v_i, 1.0)
		J.method(game.j_SFX, "levelup", [])
	if J.truth(game.f_tinyBtn(J.add(v_bx, 66.0), v_by, 56.0, 14.0, "SIFIRLA", "#8a4a4a")):
		v_j = 0.0
		while J.lt(v_j, J.getv(game.j_UPG, "length")):
			game.debug_draw.f_setUp(J.getv(J.getv(game.j_UPG, v_j), "id"), 0.0)
			v_j = J.add(v_j, 1.0)
		J.method(game.j_SFX, "uiBack", [])
	if J.truth(game.f_tinyBtn(J.add(v_bx, 126.0), v_by, 44.0, 14.0, "+$5M", "#b0862a")):
		J.setv(game.j_G, "money", J.add(J.getv(game.j_G, "money"), 5000000.0))
		J.method(game.j_SFX, "cash", [])
	if J.truth(game.f_tinyBtn(J.add(v_bx, 174.0), v_by, 48.0, 14.0, "STOK", "#3f6fbd")):
		J.setv(J.getv(game.j_G, "stock"), "pickle", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stock"), "yogurt", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stockAnim"), "pickle", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stockAnim"), "yogurt", game.session_system.f_stMax())
		J.setv(game.j_G, "meat", J.method(game.j_TUN, "meatCap", []))
		J.setv(game.j_G, "friesTray", J.method(game.j_TUN, "friesCap", []))
		J.setv(J.getv(game.j_G, "cut"), "raw", 10.0)
		J.method(game.j_SFX, "pop", [])
	if J.truth(game.f_tinyBtn(J.add(v_bx, 226.0), v_by, 60.0, 14.0, "TELEFON", "#8a5aa0")):
		if (not J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G]))):
			game.debug_draw.f_setUp("phone", 1.0)
		J.setv(J.getv(game.j_G, "phone"), "state", "ring")
		J.setv(J.getv(game.j_G, "phone"), "ringT", 0.0)
		J.setv(J.getv(game.j_G, "phone"), "beep", 0.0)
	if J.truth(game.f_tinyBtn(J.add(v_bx, 290.0), v_by, 54.0, 14.0, "MÜŞTERİ", "#3f8a8a")):
		game.customer_system.f_spawnCustomer()
	if J.truth(game.f_tinyBtn(J.add(v_bx, 348.0), v_by, 42.0, 14.0, "GÜN +1", "#b0602a")):
		J.setv(game.j_G, "day", J.add(J.getv(game.j_G, "day"), 1.0))
		game.f_startDay()
		J.setv(game.j_G, "test", true)
		J.method(game.j_SFX, "bell", [])
	if J.truth(game.f_tinyBtn(J.add(v_bx, 394.0), v_by, 56.0, 14.0, "GÜN BİT", "#8a3a3a")):
		J.setv(game.j_G, "timeLeft", 0.01)
		J.setv(game.j_G, "test", false)
	v_dby = J.add(v_by, 16.0)
	game.text_draw.f_txt(J.add(game.localization.f_T("BORÇ: $"), game.math_utils.f_fmtShort(J.getv(game.j_G, "debt"))), J.add(v_bx, 2.0), J.add(v_dby, 3.0), "#ff9a8a")
	if J.truth(game.f_tinyBtn(J.add(v_bx, 84.0), v_dby, 40.0, 12.0, "-500K", "#3f7a4a")):
		J.setv(game.j_G, "debt", max(0.0, (J.getv(game.j_G, "debt") - 500000.0)))
		game.save_system.f_saveAll()
	if J.truth(game.f_tinyBtn(J.add(v_bx, 128.0), v_dby, 40.0, 12.0, "+500K", "#7a4040")):
		J.setv(game.j_G, "debt", J.add(J.getv(game.j_G, "debt"), 500000.0))
		game.save_system.f_saveAll()
	if J.truth(game.f_tinyBtn(J.add(v_bx, 172.0), v_dby, 44.0, 12.0, "SIFIR", "#b0862a")):
		J.setv(game.j_G, "debt", 0.0)
		J.setv(game.j_G, "debtCleared", true)
		game.save_system.f_saveAll()
	v_rowH = 20.0
	v_colW = 226.0
	v_top = J.add(J.getv(v_P0, "y"), 48.0)
	v_SATIR = 6.0
	v_SAYFADA = (v_SATIR * 2.0)
	v_sayfaAdet = ceil((float(J.getv(game.j_UPG, "length")) / float(v_SAYFADA)))
	if J.ge(J.getv(v_P0, "page"), v_sayfaAdet):
		J.setv(v_P0, "page", 0.0)
	if (J.gt(v_sayfaAdet, 1.0) and J.truth(game.f_tinyBtn((J.add(J.getv(v_P0, "x"), J.getv(v_P0, "w")) - 122.0), J.add(J.getv(v_P0, "y"), 4.0), 58.0, 11.0, J.add(J.add(J.add(game.localization.f_T("SAYFA "), J.add(J.getv(v_P0, "page"), 1.0)), "/"), v_sayfaAdet), "#4a5a7a"))):
		J.setv(v_P0, "page", fmod(J.n(J.add(J.getv(v_P0, "page"), 1.0)), J.n(v_sayfaAdet)))
		J.method(game.j_SFX, "ui", [])
	v_bas = (J.getv(v_P0, "page") * v_SAYFADA)
	v_k = v_bas
	while J.lt(v_k, min(J.add(v_bas, v_SAYFADA), J.getv(game.j_UPG, "length"))):
		v_u = J.getv(game.j_UPG, v_k)
		v_yer = (v_k - v_bas)
		v_col = fmod(J.n(v_yer), J.n(2.0))
		v_row = (int(J.n((float(v_yer) / float(2.0)))) | int(J.n(0.0)))
		v_rx = J.add(J.add(J.getv(v_P0, "x"), 5.0), (v_col * v_colW))
		v_ry = J.add(v_top, (v_row * v_rowH))
		v_lvl = (J.getv(J.getv(game.j_G, "up"), J.getv(v_u, "id")) if J.truth(J.getv(J.getv(game.j_G, "up"), J.getv(v_u, "id"))) else 0.0)
		v_max = J.getv(J.getv(v_u, "lv"), "length")
		game.f_rrect(v_rx, v_ry, (v_colW - 6.0), (v_rowH - 3.0), 2.0, ("#33291f" if J.gt(v_lvl, 0.0) else "#2b241c"))
		if J.ge(v_lvl, v_max):
			game.f_rrectOut(v_rx, v_ry, (v_colW - 6.0), (v_rowH - 3.0), 2.0, "#4a7a3a")
		game.text_draw.f_txt(J.getv(v_u, "name"), J.add(v_rx, 4.0), J.add(v_ry, 2.0), (J.getv(game.j_P, "au0") if J.gt(v_lvl, 0.0) else J.getv(game.j_P, "ui1")))
		v_sub = ((J.getv(J.getv(v_u, "lvName"), (min(v_lvl, J.getv(J.getv(v_u, "lvName"), "length")) - 1.0)) if J.truth(J.getv(v_u, "lvName")) else J.add("sv ", v_lvl)) if J.gt(v_lvl, 0.0) else "kapalı")
		game.text_draw.f_txt(v_sub, J.add(v_rx, 4.0), J.add(v_ry, 11.0), (J.getv(game.j_P, "ui1") if J.gt(v_lvl, 0.0) else J.getv(game.j_P, "ui3")))
		v_d = 0.0
		while J.lt(v_d, v_max):
			v_dx = J.add((J.add(v_rx, v_colW) - 66.0), (v_d * 6.0))
			game.f_disc(v_dx, J.add(v_ry, 6.0), 2.0, (J.getv(game.j_P, "ok") if J.lt(v_d, v_lvl) else "rgba(255,255,255,.18)"))
			v_d = J.add(v_d, 1.0)
		game.text_draw.f_txt(J.add(J.add(v_lvl, "/"), v_max), (J.add(v_rx, v_colW) - 66.0), J.add(v_ry, 11.0), J.getv(game.j_P, "ui2"))
		if J.truth(game.f_tinyBtn((J.add(v_rx, v_colW) - 40.0), J.add(v_ry, 2.0), 14.0, 14.0, "-", "#7a4040")):
			game.debug_draw.f_setUp(J.getv(v_u, "id"), (v_lvl - 1.0))
			J.method(game.j_SFX, "uiBack", [])
		if J.truth(game.f_tinyBtn((J.add(v_rx, v_colW) - 23.0), J.add(v_ry, 2.0), 14.0, 14.0, "+", "#3f7a4a")):
			if J.lt(v_lvl, v_max):
				game.debug_draw.f_setUp(J.getv(v_u, "id"), J.add(v_lvl, 1.0))
				J.method(game.j_SFX, "ui", [])
			else:
				J.method(game.j_SFX, "bad", [])
		v_k = J.add(v_k, 1.0)
	v_ey = J.add(J.add(v_top, (v_SATIR * v_rowH)), 6.0)
	v_ebx = J.add(J.getv(v_P0, "x"), 6.0)
	game.text_draw.f_txt("YENİ ETKİNLİKLER", v_ebx, v_ey, J.getv(game.j_P, "au1"))
	v_eby = J.add(v_ey, 11.0)
	if J.truth(game.f_tinyBtn(v_ebx, v_eby, 44.0, 14.0, "KEDİ", "#7a6a3a")):
		v_M0 = game.street_background.f_stM()
		J.setv(game.j_G, "kedi", {"faz": "gelis", "t": 0.0, "girisT": 0.0, "x": J.add(J.add(J.getv(v_M0, "gx"), J.getv(v_M0, "gw")), 20.0), "doydu": false, "miyav": 0.0})
		J.setv(game.j_G, "meat", max(J.getv(game.j_G, "meat"), 4.0))
		J.setv(game.j_G, "test", false)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 48.0), v_eby, 58.0, 14.0, "ELEKTRİK", "#3f5a8a")):
		v_gecen = ((1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "timeLeft")) / float(J.getv(J.getv(game.j_G, "cfg"), "len"))), 0.0, 1.0)) if J.truth(J.getv(game.j_G, "cfg")) else 0.0)
		J.setv(game.j_G, "kesinti", {"faz": "bekle", "t": 0.0, "basla": J.add(v_gecen, 0.01), "sure": J.method(game.j_TUN, "kesintiSure", [game.j_G]), "uyari": 0.0})
		J.setv(game.j_G, "test", false)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 110.0), v_eby, 48.0, 14.0, "RAKİP", "#8a4a3a")):
		J.setv(game.j_G, "rakipKapandi", false)
		J.setv(game.j_G, "rakipHedef", J.getv(game.j_G, "day"))
		v_eskiGun = J.getv(game.j_G, "day")
		if J.lt(J.getv(game.j_G, "day"), game.j_RAKIP_GUN):
			J.setv(game.j_G, "day", game.j_RAKIP_GUN)
		game.rival_system.f_rakipGunBasi()
		J.setv(game.j_G, "day", v_eskiGun)
		if J.truth(J.getv(game.j_G, "rakip")):
			J.setv(J.getv(game.j_G, "rakip"), "girisT", 0.0)
			J.setv(J.getv(game.j_G, "rakip"), "t", 0.0)
		J.setv(game.j_G, "test", false)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 162.0), v_eby, 46.0, 14.0, "MAÇ", "#3f8a5a")):
		J.setv(game.j_G, "macGun", true)
		if J.truth(J.getv(game.j_G, "cfg")):
			J.setv(game.j_G, "timeLeft", (J.getv(J.getv(game.j_G, "cfg"), "len") * (1.0 - (float(J.add(game.j_MAC_BAS, game.j_MAC_BIT)) / float(2.0)))))
		J.setv(game.j_G, "test", false)
		J.method(game.j_SFX, "ui", [])
	v_HAVALAR = ["sun", "rain", "kar", "sicak"]
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 212.0), v_eby, 96.0, 14.0, J.add(game.localization.f_T("HAVA: "), J.getv(game.j_G, "weather")), "#5a5a7a")):
		v_hi = J.method(v_HAVALAR, "indexOf", [J.getv(game.j_G, "weather")])
		J.setv(game.j_G, "weather", J.getv(v_HAVALAR, fmod(J.n(J.add(v_hi, 1.0)), J.n(J.getv(v_HAVALAR, "length")))))
		game.game_loop.f_invalidateLayers()
		if J.eq(J.kind(J.ref(game.shop_background.f_bgBayat, 0)), "function"):
			game.shop_background.f_bgBayat()
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 312.0), v_eby, 66.0, 14.0, "SEÇİM+MÜŞ", "#3f8a8a")):
		game.debug_draw.f_setUp("secim", 2.0)
		J.setv(J.getv(game.j_G, "stock"), "pickle", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stock"), "yogurt", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stockAnim"), "pickle", game.session_system.f_stMax())
		J.setv(J.getv(game.j_G, "stockAnim"), "yogurt", game.session_system.f_stMax())
		J.setv(game.j_G, "meat", J.method(game.j_TUN, "meatCap", []))
		J.setv(game.j_G, "friesTray", J.method(game.j_TUN, "friesCap", []))
		game.customer_system.f_spawnCustomer()
		v_son = J.getv(J.getv(game.j_G, "customers"), (J.getv(J.getv(game.j_G, "customers"), "length") - 1.0))
		if (J.truth(v_son) and J.truth(J.getv(v_son, "items"))):
			v_q = 0.0
			while J.lt(v_q, J.getv(J.getv(v_son, "items"), "length")):
				if (J.eq(J.getv(J.getv(J.getv(v_son, "items"), v_q), "kind"), "wrap") and (not J.truth(J.getv(J.getv(J.getv(v_son, "items"), v_q), "yok")))):
					J.setv(J.getv(J.getv(v_son, "items"), v_q), "yok", ["pickle"])
				v_q = J.add(v_q, 1.0)
		J.setv(game.j_G, "test", false)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_tinyBtn(J.add(v_ebx, 382.0), v_eby, 62.0, 14.0, "BAHİS ÇÖZ", "#8a6a3a")):
		if J.truth(J.getv(game.j_G, "bahis")):
			game.rival_system.f_bahisCoz()
			J.method(game.j_SFX, "ui", [])
		else:
			J.method(game.j_SFX, "bad", [])
	game.text_draw.f_txt("SEÇİM+MÜŞ: müşteri \"turşusuz\" ister — turşu koyarsan kızar", v_ebx, J.add(v_eby, 18.0), J.getv(game.j_P, "ui2"))
	game.text_draw.f_txt("Kısayollar oyunu görebilmek için paneli kapatır (T ile geri aç)", v_ebx, J.add(v_eby, 28.0), J.getv(game.j_P, "ui3"))
	return null

