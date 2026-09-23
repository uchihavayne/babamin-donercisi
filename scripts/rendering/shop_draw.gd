# Shop draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:1424
func f_bakeShop() -> Variant:
	var v_c: Variant = null
	var v_g: Variant = null
	var v_old: Variant = null
	var v_img: Variant = null
	var v_p: Variant = null
	var v_i: Variant = null
	var v_v: Variant = null
	v_c = Canvas.new()
	J.setv(v_c, "width", game.j_W)
	J.setv(v_c, "height", game.j_H)
	v_g = J.method(v_c, "getContext", ["2d"])
	J.setv(v_g, "imageSmoothingEnabled", false)
	v_old = game.j_ctx
	game.j_ctx = v_g
	J.setv(v_g, "fillStyle", "#000")
	J.method(v_g, "fillRect", [0.0, 0.0, game.j_W, game.j_H])
	game.interface_draw.f_drawShopStatic(0.0, true)
	game.j_ctx = v_old
	v_img = J.method(v_g, "getImageData", [0.0, 0.0, game.j_W, game.j_H])
	v_p = J.getv(v_img, "data")
	v_i = 0.0
	while J.lt(v_i, J.getv(v_p, "length")):
		v_v = J.add(J.add((J.getv(v_p, v_i) * 0.32), (J.getv(v_p, J.add(v_i, 1.0)) * 0.55)), (J.getv(v_p, J.add(v_i, 2.0)) * 0.13))
		v_v = J.add((v_v * 0.8), 44.0)
		J.setv(v_p, v_i, v_v)
		J.setv(v_p, J.add(v_i, 1.0), v_v)
		J.setv(v_p, J.add(v_i, 2.0), (v_v * 1.02))
		v_i = J.add(v_i, 4.0)
	J.method(v_g, "putImageData", [v_img, 0.0, 0.0])
	J.setv(game.j_SHOP, "bake", v_c)
	return null

# ui.js:1440
func f_upgLevel(p_id: Variant = null) -> Variant:
	var v_id: Variant = p_id
	return (J.getv(J.getv(game.j_G, "up"), v_id) if J.truth(J.getv(J.getv(game.j_G, "up"), v_id)) else 0.0)
	return null

# ui.js:1441
func f_upgPrice(p_u: Variant = null) -> Variant:
	return game.upgrade_system.price(p_u)

# ui.js:1452
func f_drawShop(p_t: Variant = null) -> Variant:
	var v_dersAcik: Variant = null
	var v_barAltR: Variant = null
	var v_ubR: Variant = null
	var v_guvenliUst: Variant = null
	var v_guvenliAlt: Variant = null
	var v_rozetler: Variant = null
	var v_i: Variant = null
	var v_yer: Variant = null
	var v_hoverU: Variant = null
	var v_hazir: Variant = null
	var v_r: Variant = null
	var v_R: Variant = null
	var v_uu: Variant = null
	var v_lvl0: Variant = null
	var v_fiyat: Variant = null
	var v_tam: Variant = null
	var v_kilit: Variant = null
	var v_alinir: Variant = null
	var v_ust0: Variant = null
	var v_secili: Variant = null
	var v_kartU: Variant = null
	var v_kart: Variant = null
	var v_kl: Variant = null
	var v_kf: Variant = null
	var v_kTam: Variant = null
	var v_kKilit: Variant = null
	var v_kAlinir: Variant = null
	var v_kw: Variant = null
	var v_kh: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_pn: Variant = null
	var v_q: Variant = null
	var v_px0: Variant = null
	var v_alinanRozet: Variant = null
	var v_z: Variant = null
	var v_barAlt: Variant = null
	var v_ub: Variant = null
	var v_Wr2: Variant = null
	var v_ms: Variant = null
	var v_subeVar: Variant = null
	var v_pz: Variant = null
	var v_hx: Variant = null
	var v_hy2: Variant = null
	var v_hpz: Variant = null
	var v_t: Variant = p_t
	# REMAKE kancasi
	if not game.f_hdDukkanArka():
		if (not J.truth(J.getv(game.j_SHOP, "bake"))):
			game.shop_draw.f_bakeShop()
		J.method(game.j_ctx, "drawImage", [J.getv(game.j_SHOP, "bake"), 0.0, 0.0])
	if (((((((((not J.truth(J.getv(game.j_G, "dersGorulmus"))) and (not J.truth(J.getv(game.j_G, "ders")))) and J.le(J.getv(game.j_G, "day"), 2.0)) and (not J.truth(J.getv(game.j_CUSTOM, "open")))) and (not J.truth(J.getv(game.j_STATS, "open")))) and (not J.truth(J.getv(game.j_BSP, "open")))) and (not J.truth(J.getv(game.j_SESP, "open")))) and (not J.truth(J.getv(game.j_BRP, "open")))) and (not J.truth(J.getv(game.j_PAYP, "open")))):
		J.setv(game.j_G, "ders", {"adim": 0.0, "t": 0.0, "verildi": false})
	if J.truth(J.getv(game.j_CUSTOM, "open")):
		game.settings_draw.f_drawCustomPanel(v_t)
		return null
	if J.truth(J.getv(game.j_BSP, "open")):
		game.achievement_draw.f_drawBasarimPanel(v_t)
		return null
	if J.truth(J.getv(game.j_STATS, "open")):
		game.achievement_draw.f_drawStatsPanel(v_t)
		return null
	if J.truth(J.getv(game.j_SESP, "open")):
		game.settings_draw.f_drawSesPanel(v_t)
		return null
	if J.truth(J.getv(game.j_BRP, "open")):
		game.branch_draw.f_drawBranchPanel(v_t)
		return null
	if J.truth(J.getv(game.j_PAYP, "open")):
		game.branch_draw.f_drawPayPanel(v_t)
		return null
	J.setv(game.j_ctx, "globalAlpha", 0.12)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#3a4a6a")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_dersAcik = (not (not J.truth(J.getv(game.j_G, "ders"))))
	if ((J.truth(J.getv(game.j_IN, "pressed")) and J.eq(J.kind(J.ref(game.interface_draw.f_devDugmeTik, 2)), "function")) and J.truth(game.interface_draw.f_devDugmeTik(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y")))):
		J.setv(game.j_IN, "pressed", false)
	v_barAltR = J.gt(J.getv(game.j_VIEW, "top"), 0.0)
	v_ubR = (((game.j_H - J.getv(game.j_VIEW, "bot")) - 25.0) if J.truth(v_barAltR) else J.getv(game.j_VIEW, "top"))
	v_guvenliUst = (J.add(J.getv(game.j_VIEW, "top"), 9.0) if J.truth(v_barAltR) else J.add(J.add(v_ubR, 25.0), 9.0))
	v_guvenliAlt = ((v_ubR - 9.0) if J.truth(v_barAltR) else ((game.j_H - J.getv(game.j_VIEW, "bot")) - 9.0))
	v_rozetler = []
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		v_yer = game.interface_draw.f_upgRozetYeri(J.getv(game.j_UPG, v_i))
		J.method(v_rozetler, "push", [{"u": J.getv(game.j_UPG, v_i), "x": J.getv(v_yer, 0.0), "y": J.getv(v_yer, 1.0)}])
		v_i = J.add(v_i, 1.0)
	v_hoverU = null
	v_hazir = 0.0
	v_r = 0.0
	while J.lt(v_r, J.getv(v_rozetler, "length")):
		v_R = J.getv(v_rozetler, v_r)
		v_uu = J.getv(v_R, "u")
		v_lvl0 = game.shop_draw.f_upgLevel(J.getv(v_uu, "id"))
		v_fiyat = game.shop_draw.f_upgPrice(v_uu)
		v_tam = J.eq(v_fiyat, null)
		v_kilit = (not (not (J.truth(J.getv(v_uu, "gerek")) and J.eq((J.getv(J.getv(game.j_G, "up"), J.getv(v_uu, "gerek")) if J.truth(J.getv(J.getv(game.j_G, "up"), J.getv(v_uu, "gerek"))) else 0.0), 0.0))))
		v_alinir = (J.ge(J.getv(game.j_G, "money"), v_fiyat) if ((not J.truth(v_tam)) and (not J.truth(v_kilit))) else ((not J.truth(v_kilit)) if (not J.truth(v_tam)) else (not J.truth(v_tam))))
		if J.truth(v_alinir):
			v_hazir = J.add(v_hazir, 1.0)
		v_ust0 = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.getv(v_R, "x") - 9.0), (J.getv(v_R, "y") - 9.0), 18.0, 18.0)
		if J.truth(v_ust0):
			v_hoverU = v_uu
		v_secili = J.eq(J.getv(game.j_SHOP, "sec"), J.getv(v_uu, "id"))
		game.interface_draw.f_rozetCiz(J.getv(v_R, "x"), J.getv(v_R, "y"), {"tam": v_tam, "kilit": v_kilit, "alinir": v_alinir, "vurgu": (v_ust0 if J.truth(v_ust0) else v_secili), "t": v_t})
		if ((J.truth(v_ust0) and J.truth(J.getv(game.j_IN, "pressed"))) and (not J.truth(v_dersAcik))):
			J.setv(game.j_SHOP, "sec", (null if J.eq(J.getv(game.j_SHOP, "sec"), J.getv(v_uu, "id")) else J.getv(v_uu, "id")))
			J.method(game.j_SFX, "ui", [])
			J.setv(game.j_IN, "pressed", false)
		v_r = J.add(v_r, 1.0)
	v_kartU = (v_hoverU if J.truth(v_hoverU) else (game.equipment_system.f_upgById(J.getv(game.j_SHOP, "sec")) if J.truth(J.getv(game.j_SHOP, "sec")) else null))
	v_kart = null
	if (J.truth(v_kartU) and (not J.truth(v_dersAcik))):
		v_kl = game.shop_draw.f_upgLevel(J.getv(v_kartU, "id"))
		v_kf = game.shop_draw.f_upgPrice(v_kartU)
		v_kTam = J.eq(v_kf, null)
		v_kKilit = (not (not (J.truth(J.getv(v_kartU, "gerek")) and J.eq((J.getv(J.getv(game.j_G, "up"), J.getv(v_kartU, "gerek")) if J.truth(J.getv(J.getv(game.j_G, "up"), J.getv(v_kartU, "gerek"))) else 0.0), 0.0))))
		v_kAlinir = (J.ge(J.getv(game.j_G, "money"), v_kf) if ((not J.truth(v_kTam)) and (not J.truth(v_kKilit))) else ((not J.truth(v_kKilit)) if (not J.truth(v_kTam)) else (not J.truth(v_kTam))))
		v_kw = 240.0
		v_kh = 54.0
		v_kx = floor(((float(game.j_W) / float(2.0)) - (float(v_kw) / float(2.0))) + 0.5)
		v_ky = (((v_ubR - v_kh) - 6.0) if J.truth(v_barAltR) else (((game.j_H - J.getv(game.j_VIEW, "bot")) - v_kh) - 8.0))
		v_kart = {"x": v_kx, "y": v_ky, "w": v_kw, "h": v_kh, "u": v_kartU, "lvl": v_kl, "fiyat": v_kf, "tam": v_kTam, "kilit": v_kKilit, "alinir": v_kAlinir}
		J.setv(game.j_ctx, "globalAlpha", 0.42)
		game.f_rrect(J.add(v_kx, 2.0), J.add(v_ky, 3.0), v_kw, v_kh, 4.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		# REMAKE kancasi: HD koyu kart (pahli 9 dilim)
		if not J.truth(game.f_hdKoyuKart(v_kx, v_ky, v_kw, v_kh)):
			game.f_rrect(v_kx, v_ky, v_kw, v_kh, 4.0, "#1d1611")
			game.f_rrect(v_kx, v_ky, v_kw, (v_kh - 2.0), 4.0, "#2b2119")
			game.f_hl(J.add(v_kx, 4.0), J.add(v_ky, 1.0), (v_kw - 8.0), "#4a3a2c")
		game.f_rrectOut(v_kx, v_ky, v_kw, v_kh, 4.0, (J.getv(game.j_P, "au2") if J.truth(v_kAlinir) else "#4a3f36"))
		game.f_fr(v_kx, J.add(v_ky, 4.0), 3.0, (v_kh - 8.0), ("#3f8a4a" if J.truth(v_kTam) else ("#6a5a4a" if J.truth(v_kKilit) else (J.getv(game.j_P, "au0") if J.truth(v_kAlinir) else "#7a4a4a"))))
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_kartU, "name")), J.add(v_kx, 10.0), J.add(v_ky, 7.0), J.getv(game.j_P, "au0"))
		v_pn = J.getv(J.getv(v_kartU, "lv"), "length")
		v_q = 0.0
		while J.lt(v_q, v_pn):
			v_px0 = ((J.add(v_kx, v_kw) - 10.0) - (((v_pn - 1.0) - v_q) * 7.0))
			if J.lt(v_q, v_kl):
				game.f_rrect((v_px0 - 3.0), J.add(v_ky, 7.0), 5.0, 6.0, 1.0, J.getv(game.j_P, "ok"))
			else:
				game.f_rrect((v_px0 - 3.0), J.add(v_ky, 7.0), 5.0, 6.0, 1.0, "#463a30")
			v_q = J.add(v_q, 1.0)
		game.text_draw.f_txt(game.upgrade_system.preview(v_kartU), J.add(v_kx, 10.0), J.add(v_ky, 19.0), game.j_KART_YAZI)
		if (((not J.truth(v_kTam)) and J.truth(J.getv(v_kartU, "lvName"))) and J.truth(J.getv(J.getv(v_kartU, "lvName"), v_kl))):
			game.text_draw.f_txt(game.localization.f_T(J.getv(J.getv(v_kartU, "lvName"), v_kl)), J.add(v_kx, 10.0), J.add(v_ky, 31.0), game.j_KART_YAZI)
		else:
			if J.truth(v_kTam):
				game.text_draw.f_txt(game.localization.f_T("En üst seviye"), J.add(v_kx, 10.0), J.add(v_ky, 31.0), game.j_KART_TAM)
		if J.truth(v_kKilit):
			game.text_draw.f_txt(J.add(game.localization.f_T(J.getv(game.equipment_system.f_upgById(J.getv(v_kartU, "gerek")), "name")), game.localization.f_T(" gerekli")), J.add(v_kx, 10.0), J.add(v_ky, 42.0), game.j_KART_KILIT)
		else:
			if (not J.truth(v_kTam)):
				game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(v_kf)), J.add(v_kx, 10.0), J.add(v_ky, 42.0), (J.getv(game.j_P, "au0") if J.truth(v_kAlinir) else game.j_KART_PAHALI), {"sc": 1.0})
				if J.truth(game.f_button((J.add(v_kx, v_kw) - 74.0), (J.add(v_ky, v_kh) - 19.0), 66.0, 15.0, game.upgrade_system.action_label(v_kartU), ("#3f8a4a" if J.truth(v_kAlinir) else "#5a4038"), v_kAlinir)):
					if not game.upgrade_system.buy(str(v_kartU.id)): return null
					J.method(game.j_SFX, "cash", [])
					J.setv(game.j_SHOP, "buyT", 1.0)
					J.setv(game.j_SHOP, "bake", null)
					v_alinanRozet = null
					v_z = 0.0
					while J.lt(v_z, J.getv(v_rozetler, "length")):
						if J.eq(J.getv(J.getv(J.getv(v_rozetler, v_z), "u"), "id"), J.getv(v_kartU, "id")):
							v_alinanRozet = J.getv(v_rozetler, v_z)
						v_z = J.add(v_z, 1.0)
					if J.truth(v_alinanRozet):
						game.effects.f_burst(J.getv(v_alinanRozet, "x"), J.getv(v_alinanRozet, "y"), 16.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 80.0, "type": "star", "sz": 2.0})
						game.effects.f_ftext(J.add(J.add(game.localization.f_T(J.getv(v_kartU, "name")), " "), J.add(v_kl, 1.0)), J.getv(v_alinanRozet, "x"), (J.getv(v_alinanRozet, "y") - 14.0), J.getv(game.j_P, "au0"), {"life": 1.4})
					game.effects.f_flash(0.2, "#ffe9a0")
	v_barAlt = J.gt(J.getv(game.j_VIEW, "top"), 0.0)
	v_ub = (((game.j_H - J.getv(game.j_VIEW, "bot")) - 25.0) if J.truth(v_barAlt) else J.getv(game.j_VIEW, "top"))
	v_Wr2 = (game.j_W - J.getv(game.j_VIEW, "right"))
	J.setv(game.j_ctx, "globalAlpha", 0.8)
	game.f_fr(0.0, v_ub, v_Wr2, 25.0, "#1a120e")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(0.0, (v_ub if J.truth(v_barAlt) else J.add(v_ub, 25.0)), v_Wr2, J.getv(game.j_P, "ui4"))
	v_ms = J.add("$", (game.math_utils.f_fmtShort(J.getv(game.j_G, "money")) if J.ge(J.getv(game.j_G, "money"), 1000000.0) else game.math_utils.f_fmtMoney(J.getv(game.j_G, "money"))))
	game.icon_draw.f_icon("coin", 14.0, J.add(v_ub, 12.0), v_t)
	game.text_draw.f_txt(v_ms, 24.0, J.add(v_ub, 8.0), J.getv(game.j_P, "au0"), {"sc": 1.0})
	if (J.gt(J.getv(game.j_G, "debt"), 0.0) and J.truth(game.f_button(104.0, J.add(v_ub, 4.0), 56.0, 17.0, "BORÇ ÖDE", "#a83a2a", J.ge(J.getv(game.j_G, "money"), 100.0)))):
		J.setv(game.j_PAYP, "open", true)
		J.method(game.j_SFX, "ui", [])
	v_subeVar = (J.ge(J.getv(game.j_G, "money"), J.getv(J.getv(game.j_BRANCH, (J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0)), "p")) if (J.lt((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), J.getv(game.j_BRANCH, "length")) and (not J.truth(game.progression_system.f_branchLocked((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), game.j_G)))) else ((not J.truth(game.progression_system.f_branchLocked((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), game.j_G))) if J.lt((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), J.getv(game.j_BRANCH, "length")) else J.lt((J.getv(game.j_G, "branch") if J.truth(J.getv(game.j_G, "branch")) else 0.0), J.getv(game.j_BRANCH, "length"))))
	if J.truth(game.f_button(164.0, J.add(v_ub, 4.0), 54.0, 17.0, "ŞUBELER", "#b0862a", v_subeVar)):
		J.setv(game.j_BRP, "open", true)
		J.method(game.j_SFX, "ui", [])
	if J.truth(v_subeVar):
		v_pz = J.add(0.5, (0.5 * sin((v_t * 6.0))))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (0.35 * v_pz)))
		game.f_disc(216.0, J.add(v_ub, 5.0), J.add(4.0, v_pz), "#ffd75e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_disc(216.0, J.add(v_ub, 5.0), 3.0, "#c8321e")
		game.text_draw.f_txt("!", 216.0, J.add(v_ub, 2.0), "#ffffff", {"align": "c"})
	if J.truth(game.f_button(222.0, J.add(v_ub, 4.0), 84.0, 17.0, "KİŞİSELLEŞTİR", "#7a5aa0")):
		J.setv(game.j_CUSTOM, "open", true)
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.f_button(310.0, J.add(v_ub, 4.0), 60.0, 17.0, "REKORLAR", "#3f6fbd")):
		J.setv(game.j_STATS, "open", true)
		J.method(game.j_SFX, "ui", [])
	if J.gt(v_hazir, 0.0):
		v_hx = (v_Wr2 - 84.0)
		v_hy2 = J.add(v_ub, 7.0)
		v_hpz = J.add(0.5, (0.5 * sin((v_t * 4.0))))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.2, (0.18 * v_hpz)))
		game.f_disc(J.add(v_hx, 5.0), J.add(v_hy2, 4.0), 8.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_hx, (v_hy2 - 1.0), 10.0, 11.0, 2.0, "#4a3812")
		game.f_rrectOut(v_hx, (v_hy2 - 1.0), 10.0, 11.0, 2.0, J.getv(game.j_P, "au0"))
		game.f_fr(J.add(v_hx, 2.0), J.add(v_hy2, 3.0), 6.0, 2.0, "#ffe9a0")
		game.f_fr(J.add(v_hx, 4.0), J.add(v_hy2, 1.0), 2.0, 6.0, "#ffe9a0")
		game.text_draw.f_txt(J.s(v_hazir), J.add(v_hx, 14.0), J.add(v_hy2, 1.0), J.getv(game.j_P, "au0"))
	if J.truth(game.f_button((v_Wr2 - 58.0), J.add(v_ub, 4.0), 54.0, 17.0, J.add(game.localization.f_T("GÜN "), J.add(J.getv(game.j_G, "day"), 1.0)), "#3f8a4a", true)):
		J.method(game.j_SFX, "bell", [])
		J.setv(game.j_G, "day", J.add(J.getv(game.j_G, "day"), 1.0))
		game.event_system.f_rollNight()
		J.setv(game.j_G, "scene", ("night" if J.truth(J.getv(game.j_G, "night")) else "intro"))
		J.setv(game.j_G, "sceneT", 0.0)
		J.setv(game.j_G, "best", max(J.getv(game.j_G, "best"), J.getv(game.j_G, "day")))
		game.save_system.f_saveAll()
	if J.truth(v_dersAcik):
		game.shop_draw.f_drawDers(v_t)
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	return null

# ui.js:1637
func f_dersHedefEtiket(p_id: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		if J.eq(J.getv(J.getv(game.j_UPG, v_i), "id"), v_id):
			return J.getv(game.j_UPG, v_i)
		v_i = J.add(v_i, 1.0)
	return null
	return null

# ui.js:1641
func f_drawDers(p_t: Variant = null) -> Variant:
	var v_D: Variant = null
	var v_A: Variant = null
	var v_hedef: Variant = null
	var v_yerH: Variant = null
	var v_hx: Variant = null
	var v_hy: Variant = null
	var v_pz: Variant = null
	var v_lv0: Variant = null
	var v_pr0: Variant = null
	var v_lb0: Variant = null
	var v_lw0: Variant = null
	var v_l0: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_pxx: Variant = null
	var v_alta: Variant = null
	var v_pyy: Variant = null
	var v_i: Variant = null
	var v_s0: Variant = null
	var v_son: Variant = null
	var v_yerS: Variant = null
	var v_sx0: Variant = null
	var v_sy0: Variant = null
	var v_t: Variant = p_t
	v_D = J.getv(game.j_G, "ders")
	J.setv(v_D, "t", J.add(J.getv(v_D, "t"), (float(1.0) / float(60.0))))
	v_A = J.getv(game.j_DERS_ADIM, J.getv(v_D, "adim"))
	v_hedef = (game.shop_draw.f_dersHedefEtiket(J.getv(v_A, "hedef")) if J.truth(J.getv(v_A, "hedef")) else null)
	J.setv(game.j_ctx, "globalAlpha", 0.62)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_hedef):
		v_yerH = game.interface_draw.f_upgRozetYeri(v_hedef)
		v_hx = J.getv(v_yerH, 0.0)
		v_hy = J.getv(v_yerH, 1.0)
		v_pz = J.add(0.5, (0.5 * sin((v_t * 5.0))))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.2, (0.16 * v_pz)))
		game.f_disc(v_hx, v_hy, J.add(22.0, (v_pz * 3.0)), "#ffe9a0")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.35 * v_pz)))
		game.f_ring(v_hx, v_hy, 15.0, "#ffd75e")
		game.f_ring(v_hx, v_hy, 16.0, "#ffd75e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_lv0 = game.shop_draw.f_upgLevel(J.getv(v_hedef, "id"))
		v_pr0 = game.shop_draw.f_upgPrice(v_hedef)
		v_lb0 = ("TAM" if J.eq(v_pr0, null) else J.add("$", game.math_utils.f_fmtShort(v_pr0)))
		v_lw0 = J.add(game.f_textW(v_lb0), 12.0)
		game.f_rrect((v_hx - (float(v_lw0) / float(2.0))), (v_hy - 6.0), v_lw0, 13.0, 3.0, "#1a4a8a")
		game.f_rrect((v_hx - (float(v_lw0) / float(2.0))), (v_hy - 6.0), v_lw0, 11.0, 3.0, "#2f6fbd")
		game.f_rrectOut((v_hx - (float(v_lw0) / float(2.0))), (v_hy - 6.0), v_lw0, 13.0, 3.0, J.getv(game.j_P, "au0"))
		game.text_draw.f_txt(v_lb0, v_hx, (v_hy - 3.0), J.getv(game.j_P, "au0"), {"align": "c", "shadow": 1.0})
		v_l0 = 0.0
		while J.lt(v_l0, J.getv(J.getv(v_hedef, "lv"), "length")):
			game.f_disc(J.add((v_hx - ((J.getv(J.getv(v_hedef, "lv"), "length") - 1.0) * 2.0)), (v_l0 * 4.0)), J.add(v_hy, 9.0), 1.0, (J.getv(game.j_P, "ok") if J.lt(v_l0, v_lv0) else "rgba(0,0,0,.4)"))
			v_l0 = J.add(v_l0, 1.0)
	v_pw = 200.0
	v_ph = 58.0
	v_pxx = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_alta = ((not J.truth(v_hedef)) if (not J.truth(v_hedef)) else J.lt(J.getv(game.interface_draw.f_upgRozetYeri(v_hedef), 1.0), (float(game.j_H) / float(2.0))))
	v_pyy = (((game.j_H - v_ph) - 26.0) if J.truth(v_alta) else 30.0)
	v_pyy = game.math_utils.f_clamp(v_pyy, J.add(J.getv(game.j_VIEW, "top"), 6.0), (((game.j_H - J.getv(game.j_VIEW, "bot")) - v_ph) - 24.0))
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_rrect(J.add(v_pxx, 2.0), J.add(v_pyy, 3.0), v_pw, v_ph, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_pxx, v_pyy, v_pw, v_ph, 4.0, J.getv(game.j_P, "ui0"))
	game.f_rrectOut(v_pxx, v_pyy, v_pw, v_ph, 4.0, J.getv(game.j_P, "au2"))
	game.f_fr(J.add(v_pxx, 4.0), J.add(v_pyy, 4.0), (v_pw - 8.0), 1.0, J.getv(game.j_P, "au2"))
	game.text_draw.f_txt(game.localization.f_T(J.getv(v_A, "bas")), J.add(v_pxx, (float(v_pw) / float(2.0))), J.add(v_pyy, 8.0), J.getv(game.j_P, "red1"), {"align": "c"})
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_A, "sat"), "length")):
		game.text_draw.f_txt(game.localization.f_T(J.getv(J.getv(v_A, "sat"), v_i)), J.add(v_pxx, (float(v_pw) / float(2.0))), J.add(J.add(v_pyy, 22.0), (v_i * 10.0)), J.getv(game.j_P, "ui4"), {"align": "c"})
		v_i = J.add(v_i, 1.0)
	v_s0 = 0.0
	while J.lt(v_s0, J.getv(game.j_DERS_ADIM, "length")):
		game.f_disc(J.add((J.add(v_pxx, (float(v_pw) / float(2.0))) - ((J.getv(game.j_DERS_ADIM, "length") - 1.0) * 4.0)), (v_s0 * 8.0)), (J.add(v_pyy, v_ph) - 10.0), 2.0, (J.getv(game.j_P, "au0") if J.eq(v_s0, J.getv(v_D, "adim")) else "rgba(0,0,0,.35)"))
		v_s0 = J.add(v_s0, 1.0)
	v_son = J.eq(J.getv(v_D, "adim"), (J.getv(game.j_DERS_ADIM, "length") - 1.0))
	if (J.gt(J.getv(v_D, "t"), 0.35) and J.truth(game.f_button((J.add(v_pxx, v_pw) - 62.0), (J.add(v_pyy, v_ph) - 17.0), 56.0, 15.0, (game.localization.f_T("AL") if J.truth(v_son) else game.localization.f_T("DEVAM")), ("#3f8a4a" if J.truth(v_son) else "#3f6fbd"), true))):
		J.method(game.j_SFX, "ui", [])
		if J.truth(v_son):
			if J.lt(game.shop_draw.f_upgLevel("store"), 1.0):
				J.setv(J.getv(game.j_G, "up"), "store", 1.0)
				J.setv(game.j_SHOP, "bake", null)
				J.method(game.j_SFX, "cash", [])
				J.method(game.j_SFX, "levelup", [])
				game.effects.f_flash(0.25, "#ffe9a0")
				v_yerS = game.interface_draw.f_upgRozetYeri(game.shop_draw.f_dersHedefEtiket("store"))
				v_sx0 = J.getv(v_yerS, 0.0)
				v_sy0 = J.getv(v_yerS, 1.0)
				game.effects.f_burst(v_sx0, v_sy0, 22.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 90.0, "type": "star", "sz": 2.0})
				game.effects.f_ftext(game.localization.f_T("DEPO HEDİYE!"), v_sx0, (v_sy0 - 18.0), J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
			J.setv(game.j_G, "ders", null)
			J.setv(game.j_G, "dersGorulmus", true)
			game.save_system.f_saveAll()
		else:
			J.setv(v_D, "adim", J.add(J.getv(v_D, "adim"), 1.0))
			J.setv(v_D, "t", 0.0)
	return null
