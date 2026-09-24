# Interface draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:8
func f_panel(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_title: Variant = null) -> Variant:
	var v_tw: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_title: Variant = p_title
	# REMAKE kancasi: HD panel (9 dilim cerceve + kagit dolgu + baslik levhasi)
	if J.truth(game.f_hdPanel(v_x, v_y, v_w, v_h, v_title)): return null
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_rrect(J.add(v_x, 2.0), J.add(v_y, 3.0), v_w, v_h, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_x, v_y, v_w, v_h, 4.0, J.getv(game.j_P, "ui4"))
	game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), 3.0, J.getv(game.j_P, "ui1"))
	game.f_rrect(J.add(v_x, 2.0), J.add(v_y, 2.0), (v_w - 4.0), (v_h - 4.0), 3.0, J.getv(game.j_P, "ui0"))
	game.f_hl(J.add(v_x, 3.0), J.add(v_y, 2.0), (v_w - 6.0), "#ffffff")
	game.f_rrectOut(v_x, v_y, v_w, v_h, 4.0, J.getv(game.j_P, "ui5"))
	if J.truth(v_title):
		v_tw = J.add(game.f_textW(v_title), 12.0)
		game.f_rrect((J.add(v_x, (float(v_w) / float(2.0))) - (float(v_tw) / float(2.0))), (v_y - 6.0), v_tw, 13.0, 3.0, J.getv(game.j_P, "red2"))
		game.f_rrect(J.add((J.add(v_x, (float(v_w) / float(2.0))) - (float(v_tw) / float(2.0))), 1.0), (v_y - 5.0), (v_tw - 2.0), 11.0, 3.0, J.getv(game.j_P, "red1"))
		game.text_draw.f_txt(v_title, J.add(v_x, (float(v_w) / float(2.0))), (v_y - 3.0), J.getv(game.j_P, "ui0"), {"align": "c", "shadow": 1.0})
	return null

# ui.js:22
func f_button(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null, p_col: Variant = null, p_hot: Variant = null) -> Variant:
	var v_over: Variant = null
	var v_c0: Variant = null
	var v_c1: Variant = null
	var v_c2: Variant = null
	var v_off: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_label: Variant = p_label
	var v_col: Variant = p_col
	var v_hot: Variant = p_hot
	v_over = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), v_x, v_y, v_w, v_h)
	v_c0 = (v_col if J.truth(v_col) else J.getv(game.j_P, "red1"))
	v_c1 = game.character_draw.f_shadeCol(v_c0, (1.22 if J.truth(v_over) else 1.0))
	v_c2 = game.character_draw.f_shadeCol(v_c0, 0.62)
	v_off = (1.0 if (J.truth(v_over) and J.truth(J.getv(game.j_IN, "down"))) else 0.0)
	# REMAKE kancasi: HD dugme (notr 9 dilim, c1/c2 ile modulate)
	if not J.truth(game.f_hdDugme(v_x, v_y, v_w, v_h, v_c1, v_c2, v_off)):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 3.0), v_w, v_h, 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_x, J.add(v_y, v_off), v_w, v_h, 3.0, v_c2)
		game.f_rrect(v_x, J.add(v_y, v_off), v_w, (v_h - 2.0), 3.0, v_c1)
	game.f_hl(J.add(v_x, 3.0), J.add(J.add(v_y, 1.0), v_off), (v_w - 6.0), game.character_draw.f_shadeCol(v_c0, 1.5))
	game.f_rrectOut(v_x, J.add(v_y, v_off), v_w, v_h, 3.0, J.getv(game.j_P, "ui5"))
	game.text_draw.f_txt(v_label, J.add(v_x, (float(v_w) / float(2.0))), J.add(J.add(v_y, v_off), (float((v_h - 8.0)) / float(2.0))), J.getv(game.j_P, "ui0"), {"align": "c", "shadow": 1.0})
	if (J.truth(v_hot) and (not J.truth(v_over))):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.25 * sin((J.getv(game.j_G, "t") * 6.0)))))
		game.f_rrectOut((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), 4.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return (J.getv(game.j_IN, "pressed") if J.truth(v_over) else v_over)
	return null

# ui.js:38
func f_panelKutu(p_istenenY: Variant = null, p_istenenH: Variant = null) -> Variant:
	var v_ust: Variant = null
	var v_alt: Variant = null
	var v_h: Variant = null
	var v_y: Variant = null
	var v_istenenY: Variant = p_istenenY
	var v_istenenH: Variant = p_istenenH
	v_ust = J.add(J.getv(game.j_VIEW, "top"), 4.0)
	v_alt = ((game.j_H - J.getv(game.j_VIEW, "bot")) - 4.0)
	v_h = min(v_istenenH, (v_alt - v_ust))
	v_y = max(v_ust, min(v_istenenY, (v_alt - v_h)))
	return [v_y, v_h]
	return null

# ui.js:1378
func f_drawShopStatic(p_t: Variant = null, p_mono: Variant = null) -> Variant:
	var v_t: Variant = p_t
	var v_mono: Variant = p_mono
	if J.truth(game.shop_background.f_bgBayat()):
		game.shop_background.f_bakeBG(game.equipment_system.f_UV(game.j_G, "paint"))
	J.method(game.j_ctx, "drawImage", [game.j_BG, 0.0, 0.0])
	game.decor_draw.f_drawWallDecor(v_t)
	if J.truth(game.shop_background.f_dayiVar()):
		game.f_drawChef(J.getv(J.getv(game.j_LAY, "chef"), "x"), J.getv(J.getv(game.j_LAY, "chef"), "y"), {"mode": "idle", "armT": 0.0}, v_t)
	game.f_drawCounter()
	game.f_drawCounterProps(v_t)
	game.f_drawSpit({"rot": v_t, "roast": 0.85, "mass": 1.0, "sliceT": 0.0, "cutDepth": 0.0}, v_t)
	game.ingredient_draw.f_drawMeatTray(J.getv(J.getv(game.j_ST, "meat"), "x"), J.getv(J.getv(game.j_ST, "meat"), "y"), J.getv(J.getv(game.j_ST, "meat"), "w"), J.getv(J.getv(game.j_ST, "meat"), "h"), 3.0, v_t)
	game.ingredient_draw.f_drawPickleTray(J.getv(J.getv(game.j_ST, "pickle"), "x"), J.getv(J.getv(game.j_ST, "pickle"), "y"), J.getv(J.getv(game.j_ST, "pickle"), "w"), J.getv(J.getv(game.j_ST, "pickle"), "h"), 12.0, 16.0, v_t)
	game.f_drawYogurtTray(J.getv(J.getv(game.j_ST, "yogurt"), "x"), J.getv(J.getv(game.j_ST, "yogurt"), "y"), J.getv(J.getv(game.j_ST, "yogurt"), "w"), J.getv(J.getv(game.j_ST, "yogurt"), "h"), 12.0, 16.0, v_t)
	game.ingredient_draw.f_drawFriesTray(J.getv(J.getv(game.j_ST, "friesT"), "x"), J.getv(J.getv(game.j_ST, "friesT"), "y"), J.getv(J.getv(game.j_ST, "friesT"), "w"), J.getv(J.getv(game.j_ST, "friesT"), "h"), 4.0, 16.0, v_t)
	if J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])):
		game.garnish_draw.f_drawGarnishTray(J.getv(J.getv(game.j_ST, "garnish"), "x"), J.getv(J.getv(game.j_ST, "garnish"), "y"), J.getv(J.getv(game.j_ST, "garnish"), "w"), J.getv(J.getv(game.j_ST, "garnish"), "h"), J.method(game.j_TUN, "garnishMax", [game.j_G]), J.method(game.j_TUN, "garnishMax", [game.j_G]), J.method(game.j_TUN, "garnishMax", [game.j_G]), v_t, 0.0)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "garnish"), "GARNİTÜR", v_t)
	if J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G])):
		game.f_drawDrinkMachine(J.getv(J.getv(game.j_ST, "drinkM"), "x"), J.getv(J.getv(game.j_ST, "drinkM"), "y"), J.getv(J.getv(game.j_ST, "drinkM"), "w"), 32.0, {"pour": (-J.n(1.0))}, v_t)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "drinkM"), "İÇECEK", v_t)
	game.f_drawFryer(J.getv(J.getv(game.j_ST, "fryer"), "x"), J.getv(J.getv(game.j_ST, "fryer"), "y"), J.getv(J.getv(game.j_ST, "fryer"), "w"), J.getv(J.getv(game.j_ST, "fryer"), "h"), {"state": "idle", "t": 0.0, "dur": 0.0, "load": 0.0, "basketY": (-J.n(5.0))}, v_t)
	game.f_drawPotatoBin(J.getv(J.getv(game.j_ST, "potato"), "x"), J.getv(J.getv(game.j_ST, "potato"), "y"), J.getv(J.getv(game.j_ST, "potato"), "w"), J.getv(J.getv(game.j_ST, "potato"), "h"), v_t)
	game.f_drawCrate(J.getv(J.getv(game.j_ST, "crate"), "x"), J.getv(J.getv(game.j_ST, "crate"), "y"), J.getv(J.getv(game.j_ST, "crate"), "w"), J.getv(J.getv(game.j_ST, "crate"), "h"), false, v_t)
	if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])):
		game.f_drawPideStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"))
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [0.0, 12.0])
		game.f_drawBreadStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"), J.getv(J.getv(game.j_ST, "bread"), "h"), "")
		J.method(game.j_ctx, "restore", [])
	else:
		game.f_drawBreadStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"), J.getv(J.getv(game.j_ST, "bread"), "h"))
	# REMAKE kancasi
	if not game.f_hdTahta(false):
		game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 8.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 4.0), 34.0, 3.0, "#7a5230")
		game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 7.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 4.0), 34.0, 3.0, "#c49a68")
		game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 4.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 9.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 8.0), 30.0, 2.0, "#dcb480")
	game.f_drawPaperStation(J.getv(J.getv(game.j_ST, "paper"), "x"), J.getv(J.getv(game.j_ST, "paper"), "y"), J.getv(J.getv(game.j_ST, "paper"), "w"), J.getv(J.getv(game.j_ST, "paper"), "h"), game.equipment_system.f_UV(game.j_G, "paper"), 0.0, v_t)
	if J.truth(J.method(game.j_TUN, "grillOn", [game.j_G])):
		game.f_drawGrill(J.getv(J.getv(game.j_ST, "grill"), "x"), J.getv(J.getv(game.j_ST, "grill"), "y"), J.getv(J.getv(game.j_ST, "grill"), "w"), J.getv(J.getv(game.j_ST, "grill"), "h"), {"slots": []}, v_t, J.method(game.j_TUN, "grillCap", [game.j_G]))
	else:
		game.f_lockedStation(J.getv(game.j_ST, "grill"), "IZGARA", v_t)
	game.f_drawCutBoard(J.getv(J.getv(game.j_ST, "cut"), "x"), J.getv(J.getv(game.j_ST, "cut"), "y"), J.getv(J.getv(game.j_ST, "cut"), "w"), J.getv(J.getv(game.j_ST, "cut"), "h"), {"potato": false, "prog": 0.0, "raw": 2.0, "cutting": false}, v_t)
	if J.truth(J.method(game.j_TUN, "fboxOn", [game.j_G])):
		game.packaging_draw.f_drawFboxStation(J.getv(J.getv(game.j_ST, "fbox"), "x"), J.getv(J.getv(game.j_ST, "fbox"), "y"), J.getv(J.getv(game.j_ST, "fbox"), "w"), J.getv(J.getv(game.j_ST, "fbox"), "h"), 1.0, v_t)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "fbox"), "KUTU", v_t)
	if J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])):
		game.f_drawAyranTank(J.getv(J.getv(game.j_ST, "ayran"), "x"), J.getv(J.getv(game.j_ST, "ayran"), "y"), J.getv(J.getv(game.j_ST, "ayran"), "w"), J.getv(J.getv(game.j_ST, "ayran"), "h"), J.method(game.j_TUN, "ayranMax", [game.j_G]), J.method(game.j_TUN, "ayranMax", [game.j_G]), {"pour": false}, v_t)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "ayran"), "AYRAN", v_t)
	if J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])):
		game.f_drawSweetTray(J.getv(J.getv(game.j_ST, "sweet"), "x"), J.getv(J.getv(game.j_ST, "sweet"), "y"), J.getv(J.getv(game.j_ST, "sweet"), "w"), J.getv(J.getv(game.j_ST, "sweet"), "h"), J.method(game.j_TUN, "sweetMax", [game.j_G]), J.method(game.j_TUN, "sweetMax", [game.j_G]), v_t, 0.0)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "sweet"), "TATLI", v_t)
	if (J.truth(J.method(game.j_TUN, "sauceOn", [game.j_G])) or J.truth(J.method(game.j_TUN, "iskOn", [game.j_G]))):
		game.f_drawSauceStation(J.getv(J.getv(game.j_ST, "sauce"), "x"), J.getv(J.getv(game.j_ST, "sauce"), "y"), J.getv(J.getv(game.j_ST, "sauce"), "w"), J.getv(J.getv(game.j_ST, "sauce"), "h"), J.method(game.j_TUN, "sauceOn", [game.j_G]), J.method(game.j_TUN, "iskOn", [game.j_G]), null, v_t)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "sauce"), "SOS", v_t)
	if J.ge(J.method(game.j_TUN, "secLevel", [game.j_G]), 3.0):
		game.window_draw.f_drawWallCam(v_t, false)
	game.f_drawTrash(J.getv(J.getv(game.j_ST, "trash"), "x"), J.getv(J.getv(game.j_ST, "trash"), "y"), J.getv(J.getv(game.j_ST, "trash"), "w"), J.getv(J.getv(game.j_ST, "trash"), "h"), v_t, 0.0)
	return null

# ui.js:1709
func f_devDugmeKutu() -> Variant:
	if J.truth(J.getv(game.j_G, "test")):
		return [(J.add(J.getv(game.j_TESTP, "x"), J.getv(game.j_TESTP, "w")) - 24.0), (J.add(J.getv(game.j_TESTP, "y"), J.getv(game.j_TESTP, "h")) - 17.0), 18.0, 13.0]
	return [(game.hud_draw.f_hudSagKenar() - 22.0), J.add(J.getv(game.j_VIEW, "top"), 24.0), 18.0, 13.0]
	return null

# ui.js:1717
func f_drawDevDugme(p_t: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_ust: Variant = null
	var v_t: Variant = p_t
	if (not J.truth(J.getv(game.j_window, "__DEV_BUILD"))):
		return null
	if ((not J.eq(J.getv(game.j_G, "scene"), "play") and not J.eq(J.getv(game.j_G, "scene"), "shop")) and not J.eq(J.getv(game.j_G, "scene"), "pause")):
		return null
	v_k = game.interface_draw.f_devDugmeKutu()
	v_ust = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.getv(v_k, 0.0) - 2.0), (J.getv(v_k, 1.0) - 2.0), J.add(J.getv(v_k, 2.0), 4.0), J.add(J.getv(v_k, 3.0), 4.0))
	J.setv(game.j_ctx, "globalAlpha", (0.95 if J.truth(J.getv(game.j_G, "test")) else 0.58))
	game.f_rrect(J.getv(v_k, 0.0), J.getv(v_k, 1.0), J.getv(v_k, 2.0), J.getv(v_k, 3.0), 2.0, ("#2f6a3a" if J.truth(J.getv(game.j_G, "test")) else "#3a3f46"))
	game.f_rrect(J.getv(v_k, 0.0), J.getv(v_k, 1.0), J.getv(v_k, 2.0), (J.getv(v_k, 3.0) - 2.0), 2.0, ("#3f8a4a" if J.truth(J.getv(game.j_G, "test")) else ("#5a6068" if J.truth(v_ust) else "#4a5058")))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrectOut(J.getv(v_k, 0.0), J.getv(v_k, 1.0), J.getv(v_k, 2.0), J.getv(v_k, 3.0), 2.0, (J.getv(game.j_P, "au0") if J.truth(J.getv(game.j_G, "test")) else "#6a7078"))
	game.text_draw.f_txt("DEV", J.add(J.getv(v_k, 0.0), (float(J.getv(v_k, 2.0)) / float(2.0))), J.add(J.getv(v_k, 1.0), 3.0), ("#ffffff" if J.truth(J.getv(game.j_G, "test")) else "#c8ccd0"), {"align": "c"})
	return null

# ui.js:1729
func f_devDugmeTik(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	if (not J.truth(J.getv(game.j_window, "__DEV_BUILD"))):
		return false
	if ((not J.eq(J.getv(game.j_G, "scene"), "play") and not J.eq(J.getv(game.j_G, "scene"), "shop")) and not J.eq(J.getv(game.j_G, "scene"), "pause")):
		return false
	v_k = game.interface_draw.f_devDugmeKutu()
	if (not J.truth(game.math_utils.f_inRect(v_mx, v_my, (J.getv(v_k, 0.0) - 2.0), (J.getv(v_k, 1.0) - 2.0), J.add(J.getv(v_k, 2.0), 4.0), J.add(J.getv(v_k, 3.0), 4.0)))):
		return false
	J.setv(game.j_G, "test", (not J.truth(J.getv(game.j_G, "test"))))
	J.method(game.j_SFX, "ui", [])
	# BIRLESIK (7. tur, kullanici: "DEV yazisina tiklayinca bazen gun bitiyor"):
	# panel ekranin neredeyse tamamini kaplar ve AYNI karede acilir; tiklama
	# tuketilmezse imlecin altina denk gelen panel dugmesi (gunu bitir) de basilir.
	J.setv(game.j_IN, "pressed", false)
	return true
	return null

# ui.js:1742
func f_upgRozetYeri(p_u: Variant = null) -> Variant:
	var v_barAlt: Variant = null
	var v_ub: Variant = null
	var v_ustS: Variant = null
	var v_altS: Variant = null
	var v_sira: Variant = null
	var v_i: Variant = null
	var v_st0: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_ofs: Variant = null
	var v_u: Variant = p_u
	v_barAlt = J.gt(J.getv(game.j_VIEW, "top"), 0.0)
	v_ub = (((game.j_H - J.getv(game.j_VIEW, "bot")) - 25.0) if J.truth(v_barAlt) else J.getv(game.j_VIEW, "top"))
	v_ustS = (J.add(J.getv(game.j_VIEW, "top"), 9.0) if J.truth(v_barAlt) else J.add(J.add(v_ub, 25.0), 9.0))
	v_altS = ((v_ub - 9.0) if J.truth(v_barAlt) else ((game.j_H - J.getv(game.j_VIEW, "bot")) - 9.0))
	v_sira = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		if J.eq(J.getv(J.getv(game.j_UPG, v_i), "id"), J.getv(v_u, "id")):
			break
		if J.eq(J.getv(J.getv(game.j_UPG, v_i), "st"), J.getv(v_u, "st")):
			v_sira = J.add(v_sira, 1.0)
		v_i = J.add(v_i, 1.0)
	v_st0 = J.getv(game.j_ST, J.getv(v_u, "st"))
	if J.truth(v_st0):
		v_rx = ((J.add(J.getv(v_st0, "x"), J.getv(v_st0, "w")) - 8.0) - (v_sira * 13.0))
		v_ry = J.add(J.getv(v_st0, "y"), 8.0)
	else:
		v_rx = J.add(J.getv(J.getv(v_u, "tag"), 0.0), (v_sira * 13.0))
		v_ry = J.getv(J.getv(v_u, "tag"), 1.0)
	v_ofs = J.getv(game.j_ROZET_OFSET, J.getv(v_u, "st"))
	if J.truth(v_ofs):
		v_rx = J.add(v_rx, J.getv(v_ofs, 0.0))
		v_ry = J.add(v_ry, J.getv(v_ofs, 1.0))
	return [floor(game.math_utils.f_clamp(v_rx, 9.0, ((game.j_W - J.getv(game.j_VIEW, "right")) - 9.0)) + 0.5), floor(game.math_utils.f_clamp(v_ry, v_ustS, v_altS) + 0.5)]
	return null

# ui.js:1764
func f_rozetCiz(p_x: Variant = null, p_y: Variant = null, p_o: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_yx: Variant = null
	var v_yy: Variant = null
	var v_pz: Variant = null
	var v_zemin: Variant = null
	var v_kenar: Variant = null
	var v_mur: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_o: Variant = p_o
	v_d = 11.0
	v_yx = (v_x - 5.0)
	v_yy = (v_y - 5.0)
	v_pz = J.add(0.5, (0.5 * sin((J.getv(v_o, "t") * 4.0))))
	if J.truth(J.getv(v_o, "tam")):
		v_zemin = "#26382a"
		v_kenar = "#3f8a4a"
		v_mur = "#6ac07a"
	else:
		if J.truth(J.getv(v_o, "kilit")):
			v_zemin = "#2e2822"
			v_kenar = "#5a4e42"
			v_mur = "#8a7a68"
		else:
			if J.truth(J.getv(v_o, "alinir")):
				v_zemin = "#4a3812"
				v_kenar = J.getv(game.j_P, "au0")
				v_mur = "#ffe9a0"
			else:
				v_zemin = "#2a2b30"
				v_kenar = "#5a5f68"
				v_mur = "#8a9098"
	if J.truth(J.getv(v_o, "vurgu")):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.18, (0.18 * v_pz)))
		game.f_disc(v_x, v_y, J.add(9.0, (v_pz * 2.0)), (J.getv(game.j_P, "au0") if J.truth(J.getv(v_o, "alinir")) else "#c8ccd0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_rrect(J.add(v_yx, 1.0), J.add(v_yy, 2.0), v_d, v_d, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_yx, v_yy, v_d, v_d, 3.0, v_zemin)
	game.f_rrectOut(v_yx, v_yy, v_d, v_d, 3.0, ("#ffffff" if J.truth(J.getv(v_o, "vurgu")) else v_kenar))
	if J.truth(J.getv(v_o, "tam")):
		game.f_fr((v_x - 2.0), J.add(v_y, 1.0), 1.0, 2.0, v_mur)
		game.f_fr((v_x - 1.0), J.add(v_y, 2.0), 1.0, 1.0, v_mur)
		game.f_fr(v_x, v_y, 1.0, 2.0, v_mur)
		game.f_fr(J.add(v_x, 1.0), (v_y - 2.0), 1.0, 3.0, v_mur)
	else:
		if J.truth(J.getv(v_o, "kilit")):
			game.f_fr((v_x - 2.0), (v_y - 3.0), 4.0, 1.0, v_mur)
			game.f_px((v_x - 3.0), (v_y - 2.0), v_mur)
			game.f_px(J.add(v_x, 2.0), (v_y - 2.0), v_mur)
			game.f_fr((v_x - 3.0), (v_y - 1.0), 7.0, 5.0, v_mur)
			game.f_px(v_x, J.add(v_y, 1.0), v_zemin)
		else:
			game.f_fr((v_x - 3.0), (v_y - 1.0), 7.0, 2.0, v_mur)
			game.f_fr((v_x - 1.0), (v_y - 3.0), 2.0, 7.0, v_mur)
	return null

# ui.js:1798
func f_arrowTo(p_x0: Variant = null, p_y0: Variant = null, p_x1: Variant = null, p_y1: Variant = null, p_col: Variant = null) -> Variant:
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_len: Variant = null
	var v_steps: Variant = null
	var v_nx: Variant = null
	var v_ny: Variant = null
	var v_bend: Variant = null
	var v_last: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_i: Variant = null
	var v_sp: Variant = null
	var v_b: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_a2: Variant = null
	var v_k: Variant = null
	var v_hx: Variant = null
	var v_hy: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	var v_x1: Variant = p_x1
	var v_y1: Variant = p_y1
	var v_col: Variant = p_col
	v_dx = (v_x1 - v_x0)
	v_dy = (v_y1 - v_y0)
	v_len = sqrt(J.add((v_dx * v_dx), (v_dy * v_dy)))
	if J.lt(v_len, 6.0):
		return null
	v_steps = floor((float(v_len) / float(2.0)))
	v_nx = (float((-J.n(v_dy))) / float(v_len))
	v_ny = (float(v_dx) / float(v_len))
	v_bend = min(16.0, (v_len * 0.24))
	v_last = null
	v_ax = 0.0
	v_ay = 0.0
	v_i = 0.0
	while J.le(v_i, (v_steps * 0.82)):
		v_sp = (float(v_i) / float(v_steps))
		v_b = (sin((v_sp * J.getv({"PI": PI}, "PI"))) * v_bend)
		v_x = floor(J.add(J.add(v_x0, (v_dx * v_sp)), (v_nx * v_b)) + 0.5)
		v_y = floor(J.add(J.add(v_y0, (v_dy * v_sp)), (v_ny * v_b)) + 0.5)
		if (J.truth(v_last) and (not J.eq(J.getv(v_last, 0.0), v_x) or not J.eq(J.getv(v_last, 1.0), v_y))):
			game.f_px(v_x, v_y, v_col)
			game.f_px(J.add(v_x, 1.0), v_y, v_col)
			game.f_px(v_x, J.add(v_y, 1.0), "#7a1a14")
		v_last = [v_x, v_y]
		v_ax = v_x
		v_ay = v_y
		v_i = J.add(v_i, 1.0)
	v_a2 = atan2((v_y1 - v_ay), (v_x1 - v_ax))
	v_k = 0.0
	while J.lt(v_k, 6.0):
		v_hx = J.add(v_ax, (cos(v_a2) * v_k))
		v_hy = J.add(v_ay, (sin(v_a2) * v_k))
		game.f_px(v_hx, v_hy, v_col)
		game.f_px(J.add(v_hx, 1.0), v_hy, v_col)
		game.f_px(J.add(v_ax, (cos((v_a2 - 2.4)) * v_k)), J.add(v_ay, (sin((v_a2 - 2.4)) * v_k)), v_col)
		game.f_px(J.add(v_ax, (cos(J.add(v_a2, 2.4)) * v_k)), J.add(v_ay, (sin(J.add(v_a2, 2.4)) * v_k)), v_col)
		game.f_px(J.add(J.add(v_ax, (cos((v_a2 - 2.4)) * v_k)), 1.0), J.add(v_ay, (sin((v_a2 - 2.4)) * v_k)), v_col)
		game.f_px(J.add(J.add(v_ax, (cos(J.add(v_a2, 2.4)) * v_k)), 1.0), J.add(v_ay, (sin(J.add(v_a2, 2.4)) * v_k)), v_col)
		v_k = J.add(v_k, 1.0)
	return null

# ui.js:1828
func f_drawPause(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	game.f_drawPlay(v_t)
	if J.truth(J.getv(game.j_BSP, "open")):
		game.achievement_draw.f_drawBasarimPanel(v_t)
		return null
	if J.truth(J.getv(game.j_STATS, "open")):
		game.achievement_draw.f_drawStatsPanel(v_t)
		return null
	if J.truth(J.getv(game.j_SESP, "open")):
		game.settings_draw.f_drawSesPanel(v_t)
		return null
	J.setv(game.j_ctx, "globalAlpha", 0.62)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#140a06")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(((float(game.j_W) / float(2.0)) - 70.0), 58.0, 140.0, 140.0, "MOLA")
	if J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 50.0), 76.0, 100.0, 20.0, "DEVAM ET", "#3f8a4a", true)):
		J.method(game.j_SFX, "ui", [])
		J.setv(game.j_G, "scene", "play")
	if J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 50.0), 100.0, 100.0, 20.0, "SES AYARLARI", "#3f6fbd")):
		J.method(game.j_SFX, "ui", [])
		J.setv(game.j_SESP, "open", true)
	if ((not J.truth(game.j_TOUCH)) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 50.0), 124.0, 100.0, 20.0, ("TAM EKRAN: AÇIK" if J.truth(game.f_fsOn()) else "TAM EKRAN"), "#7a5aa0"))):
		J.method(game.j_SFX, "ui", [])
		game.f_fsToggle()
	if J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 50.0), 148.0, 48.0, 20.0, "REKOR", "#3f6fbd")):
		J.method(game.j_SFX, "ui", [])
		J.setv(game.j_STATS, "open", true)
	if J.truth(game.f_button(J.add((float(game.j_W) / float(2.0)), 2.0), 148.0, 48.0, 20.0, "BAŞARIM", "#b0862a")):
		J.method(game.j_SFX, "ui", [])
		J.setv(game.j_BSP, "open", true)
	if J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 50.0), 172.0, 100.0, 20.0, "ANA MENÜ", "#8a4a4a")):
		J.method(game.j_SFX, "uiBack", [])
		J.setv(game.j_G, "scene", "title")
	return null

