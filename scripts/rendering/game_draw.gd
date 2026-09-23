# Game draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:362
func f_drawFlyMeat(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_k: Variant = null
	var v_fx0: Variant = null
	var v_fy0: Variant = null
	var v_don: Variant = null
	var v_t: Variant = p_t
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "flyMeat"), "length")):
		v_f = J.getv(J.getv(game.j_G, "flyMeat"), v_i)
		v_k = game.math_utils.f_clamp(J.getv(v_f, "t"), 0.0, 1.0)
		v_fx0 = (game.math_utils.f_lerp(J.getv(v_f, "x0"), J.getv(v_f, "x1"), v_k) - (sin((v_k * J.getv({"PI": PI}, "PI"))) * J.getv(v_f, "savrul")))
		v_fy0 = (game.math_utils.f_lerp(J.getv(v_f, "y0"), J.getv(v_f, "y1"), v_k) - (sin((v_k * J.getv({"PI": PI}, "PI"))) * J.getv(v_f, "yay")))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (v_k * 0.22)))
		game.f_ell(J.getv(v_f, "x1"), J.add(J.getv(v_f, "y1"), 2.0), J.add(3.0, (v_k * 2.0)), 1.0, "#2a1808")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_don = abs(cos(J.getv(v_f, "don")))
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [floor(v_fx0 + 0.5), floor(v_fy0 + 0.5)])
		J.method(game.j_ctx, "scale", [1.0, max(0.3, v_don)])
		game.f_meatStrip(0.0, 0.0, J.add(0.92, (v_don * 0.1)), J.getv(v_f, "k"), J.getv(v_f, "sz"))
		J.method(game.j_ctx, "restore", [])
		v_i = J.add(v_i, 1.0)
	return null

# game.js:2511
func f_drawFlyCoins(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_k: Variant = null
	var v_ke: Variant = null
	var v_hp2: Variant = null
	var v_fx2: Variant = null
	var v_fy2: Variant = null
	var v_t: Variant = p_t
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "flyCoins"), "length")):
		v_f = J.getv(J.getv(game.j_G, "flyCoins"), v_i)
		v_k = game.math_utils.f_clamp(J.getv(v_f, "t"), 0.0, 1.0)
		v_ke = ((v_k * v_k) * (3.0 - (2.0 * v_k)))
		v_hp2 = game.hud_draw.f_hudCoinPos()
		v_fx2 = game.math_utils.f_lerp(J.getv(v_f, "x0"), J.getv(v_hp2, 0.0), v_ke)
		v_fy2 = (game.math_utils.f_lerp(J.getv(v_f, "y0"), J.getv(v_hp2, 1.0), v_ke) - (sin((v_k * J.getv({"PI": PI}, "PI"))) * 30.0))
		J.setv(game.j_ctx, "globalAlpha", (1.0 - (v_k * 0.25)))
		game.icon_draw.f_drawCoin(v_fx2, v_fy2, J.getv(v_f, "v"), v_t, J.getv(v_f, "ph"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# game.js:2740
func f_drawPlay(p_t: Variant = null) -> Variant:
	var _cells: Dictionary = {"t": [p_t]}
	var _v: Dictionary = {"pxd": null, "e": null, "i": null, "c": null, "co": null, "tkX": null, "tkW": null, "musluklar": null, "nb": null, "g2": null, "ci": null, "wsc": null, "b": null, "bcx": null, "bcy": null, "w": null, "pop": null, "yoff": null, "pn2": null, "lbl2": null, "lw3": null, "nx": null, "nw": null, "lbl": null, "lcol": null, "lw2": null, "ao": null, "axx": null, "aa": null, "sl": null, "hazirVarmi": null, "yanmaVarmi": null, "gi": null, "gs": null, "gsx": null, "gsy": null, "gj": null, "gp": null, "bw": null, "bekleyen": null, "gb": null, "gw2": null, "uc": null, "uygun": null, "fi2": null, "fg": null, "k2": null, "fgx": null, "fgy": null, "spin": null, "fp": null, "k": null, "fx": null, "fy": null, "lw": null, "lx": null, "ly": null, "ex2": null, "ey2": null, "ky3": null, "dx2": null, "dy2": null, "bi3": null, "nb3": null, "bw3": null, "j": null, "cc": null, "ey": null}
	if J.truth(game.shop_background.f_bgBayat()):
		game.shop_background.f_bakeBG(game.equipment_system.f_UV(game.j_G, "paint"))
	if J.eq(fmod(J.n(J.setv(game, "j__bgCheck", J.add(game.j__bgCheck, 1.0))), J.n(120.0)), 0.0):
		_v["pxd"] = J.getv(J.method(J.method(game.j_BG, "getContext", ["2d"]), "getImageData", [2.0, 2.0, 1.0, 1.0]), "data")
		if J.eq(J.getv(_v["pxd"], 3.0), 0.0):
			game.shop_background.f_bakeBG(game.equipment_system.f_UV(game.j_G, "paint"))
			game.j_CLAYER = null
			game.j_STONEFG = null
	J.method(game.j_ctx, "drawImage", [game.j_BG, 0.0, 0.0])
	game.decor_draw.f_drawWallDecor(_cells["t"][0])
	_v["i"] = 0.0
	while J.lt(_v["i"], J.getv(J.getv(game.j_G, "customers"), "length")):
		game.f_drawCustomer(J.getv(J.getv(game.j_G, "customers"), _v["i"]), _cells["t"][0])
		_v["i"] = J.add(_v["i"], 1.0)
	game.regulation_draw.f_drawInspector(_cells["t"][0])
	game.shop_background.f_drawStoneFG()
	if (J.truth(game.shop_background.f_dayiVar()) and ((not J.truth(J.getv(game.j_G, "courier"))) or J.eq(J.getv(J.getv(game.j_G, "courier"), "state"), "in"))):
		game.f_drawChef(J.getv(J.getv(game.j_LAY, "chef"), "x"), J.getv(J.getv(game.j_LAY, "chef"), "y"), J.getv(game.j_G, "chef"), _cells["t"][0])
	if (J.truth(game.helper_system.f_uncleReady()) and ((not J.truth(J.getv(game.j_G, "courier"))) or J.eq(J.getv(J.getv(game.j_G, "courier"), "state"), "in"))):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.35, (0.3 * sin((_cells["t"][0] * 7.0)))))
		game.f_rrectOut(J.getv(J.getv(game.j_ST, "uncle"), "x"), J.getv(J.getv(game.j_ST, "uncle"), "y"), J.getv(J.getv(game.j_ST, "uncle"), "w"), J.getv(J.getv(game.j_ST, "uncle"), "h"), 4.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 2.0), (J.getv(J.getv(game.j_ST, "uncle"), "y") - 13.0), 42.0, 12.0, 3.0, J.getv(game.j_P, "red1"))
		game.f_rrectOut(J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 2.0), (J.getv(J.getv(game.j_ST, "uncle"), "y") - 13.0), 42.0, 12.0, 3.0, J.getv(game.j_P, "ui5"))
		game.text_draw.f_txt(J.add(game.localization.f_T("DAYI x"), J.getv(J.getv(game.j_G, "uncle"), "left")), J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 23.0), (J.getv(J.getv(game.j_ST, "uncle"), "y") - 11.0), J.getv(game.j_P, "au0"), {"align": "c"})
	game.f_drawCounter()
	game.f_drawCounterProps(_cells["t"][0])
	_v["c"] = 0.0
	while J.lt(_v["c"], J.getv(J.getv(game.j_G, "coins"), "length")):
		_v["co"] = J.getv(J.getv(game.j_G, "coins"), _v["c"])
		game.icon_draw.f_drawCoin(J.getv(_v["co"], "x"), J.getv(_v["co"], "y"), J.getv(_v["co"], "v"), _cells["t"][0], J.getv(_v["co"], "ph"))
		if (J.truth(J.getv(_v["co"], "landed")) and J.gt(J.getv(_v["co"], "life"), 8.0)):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.5 * sin((_cells["t"][0] * 12.0)))))
			game.f_ring(J.getv(_v["co"], "x"), (J.getv(_v["co"], "y") - 1.0), 7.0, J.getv(game.j_P, "au0"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["c"] = J.add(_v["c"], 1.0)
	game.f_drawSpit(J.getv(game.j_G, "spit"), _cells["t"][0])
	game.f_drawShaveHint(_cells["t"][0])
	game.phone_draw.f_drawPhone(_cells["t"][0])
	game.regulation_draw.f_drawFerman(_cells["t"][0])
	game.regulation_draw.f_drawLider(_cells["t"][0])
	game.ingredient_draw.f_drawMeatTray(J.getv(J.getv(game.j_ST, "meat"), "x"), J.getv(J.getv(game.j_ST, "meat"), "y"), J.getv(J.getv(game.j_ST, "meat"), "w"), J.getv(J.getv(game.j_ST, "meat"), "h"), J.getv(game.j_G, "meat"), _cells["t"][0], J.getv(J.getv(game.j_G, "fxTray"), "meat"))
	_v["tkX"] = J.getv(J.getv(game.j_ST, "pickle"), "x")
	_v["tkW"] = (J.add(J.getv(J.getv(game.j_ST, "friesT"), "x"), J.getv(J.getv(game.j_ST, "friesT"), "w")) - J.getv(J.getv(game.j_ST, "pickle"), "x"))
	game.f_drawTepsiKasasi(_v["tkX"], J.getv(J.getv(game.j_ST, "pickle"), "y"), _v["tkW"], J.getv(J.getv(game.j_ST, "pickle"), "h"), 3.0)
	game.ingredient_draw.f_drawPickleTray(J.getv(J.getv(game.j_ST, "pickle"), "x"), J.getv(J.getv(game.j_ST, "pickle"), "y"), J.getv(J.getv(game.j_ST, "pickle"), "w"), J.getv(J.getv(game.j_ST, "pickle"), "h"), J.getv(J.getv(game.j_G, "stockAnim"), "pickle"), game.session_system.f_stMax(), _cells["t"][0], J.getv(J.getv(game.j_G, "fxTray"), "pickle"))
	game.f_drawYogurtTray(J.getv(J.getv(game.j_ST, "yogurt"), "x"), J.getv(J.getv(game.j_ST, "yogurt"), "y"), J.getv(J.getv(game.j_ST, "yogurt"), "w"), J.getv(J.getv(game.j_ST, "yogurt"), "h"), J.getv(J.getv(game.j_G, "stockAnim"), "yogurt"), game.session_system.f_stMax(), _cells["t"][0], J.getv(J.getv(game.j_G, "fxTray"), "yogurt"))
	game.ingredient_draw.f_drawFriesTray(J.getv(J.getv(game.j_ST, "friesT"), "x"), J.getv(J.getv(game.j_ST, "friesT"), "y"), J.getv(J.getv(game.j_ST, "friesT"), "w"), J.getv(J.getv(game.j_ST, "friesT"), "h"), J.getv(game.j_G, "friesTray"), J.method(game.j_TUN, "friesCap", []), _cells["t"][0], J.getv(J.getv(game.j_G, "fxTray"), "fries"))
	game.f_drawTepsiCami(_v["tkX"], J.getv(J.getv(game.j_ST, "pickle"), "y"), _v["tkW"], J.getv(J.getv(game.j_ST, "pickle"), "h"), _cells["t"][0])
	if J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])):
		game.garnish_draw.f_drawGarnishTray(J.getv(J.getv(game.j_ST, "garnish"), "x"), J.getv(J.getv(game.j_ST, "garnish"), "y"), J.getv(J.getv(game.j_ST, "garnish"), "w"), J.getv(J.getv(game.j_ST, "garnish"), "h"), J.getv(J.getv(game.j_G, "stockAnim"), "tomato"), J.getv(J.getv(game.j_G, "stockAnim"), "pepper"), J.method(game.j_TUN, "garnishMax", [game.j_G]), _cells["t"][0], max(J.getv(J.getv(game.j_G, "fxTray"), "tomato"), J.getv(J.getv(game.j_G, "fxTray"), "pepper")))
	else:
		game.f_lockedStation(J.getv(game.j_ST, "garnish"), "GARNİTÜR", _cells["t"][0])
	_v["musluklar"] = game.drink_system.f_icecekMusluklari()
	if J.truth(J.getv(_v["musluklar"], "length")):
		game.f_drawIcecekKasasi(J.getv(J.getv(game.j_ST, "drinkM"), "x"), J.getv(J.getv(game.j_ST, "drinkM"), "y"), J.getv(J.getv(game.j_ST, "drinkM"), "w"), 34.0, J.getv(_v["musluklar"], "length"), _cells["t"][0])
		if J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G])):
			game.f_drawDrinkMachine(J.getv(J.getv(game.j_ST, "drinkM"), "x"), J.getv(J.getv(game.j_ST, "drinkM"), "y"), (J.getv(J.getv(game.j_ST, "drinkM"), "w") - (J.getv(J.getv(game.j_ST, "ayran"), "w") if J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])) else 0.0)), 32.0, J.getv(game.j_G, "drinkM"), _cells["t"][0])
		if J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])):
			game.f_drawAyranTank(J.getv(J.getv(game.j_ST, "ayran"), "x"), J.getv(J.getv(game.j_ST, "ayran"), "y"), J.getv(J.getv(game.j_ST, "ayran"), "w"), (J.getv(J.getv(game.j_ST, "ayran"), "h") - 6.0), J.getv(J.getv(game.j_G, "stockAnim"), "ayran"), J.method(game.j_TUN, "ayranMax", [game.j_G]), {"pour": not J.eq(J.getv(J.getv(J.getv(game.j_G, "drinkM"), "pours"), "ayran"), null)}, _cells["t"][0])
		J.method(_v["musluklar"], "forEach", [game.game_draw._closure_250.bind({"721:t": _cells["t"]})])
	else:
		game.f_lockedStation(J.getv(game.j_ST, "drinkM"), "İÇECEK", _cells["t"][0])
	game.f_drawFryer(J.getv(J.getv(game.j_ST, "fryer"), "x"), J.getv(J.getv(game.j_ST, "fryer"), "y"), J.getv(J.getv(game.j_ST, "fryer"), "w"), J.getv(J.getv(game.j_ST, "fryer"), "h"), J.getv(game.j_G, "fryer"), _cells["t"][0])
	game.f_drawPotatoBin(J.getv(J.getv(game.j_ST, "potato"), "x"), J.getv(J.getv(game.j_ST, "potato"), "y"), J.getv(J.getv(game.j_ST, "potato"), "w"), J.getv(J.getv(game.j_ST, "potato"), "h"), _cells["t"][0])
	game.f_drawCrate(J.getv(J.getv(game.j_ST, "crate"), "x"), J.getv(J.getv(game.j_ST, "crate"), "y"), J.getv(J.getv(game.j_ST, "crate"), "w"), J.getv(J.getv(game.j_ST, "crate"), "h"), J.getv(J.getv(game.j_G, "crate"), "open"), _cells["t"][0], J.getv(J.getv(game.j_G, "crate"), "a"))
	if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])):
		game.f_drawPideStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"))
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [0.0, 12.0])
		game.f_drawBreadStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"), J.getv(J.getv(game.j_ST, "bread"), "h"), "")
		J.method(game.j_ctx, "restore", [])
		J.setv(game.j_ctx, "globalAlpha", 0.28)
		game.f_hl(J.add(J.getv(J.getv(game.j_ST, "bread"), "x"), 5.0), J.add(J.getv(J.getv(game.j_ST, "bread"), "y"), 15.0), (J.getv(J.getv(game.j_ST, "bread"), "w") - 10.0), "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		game.f_drawBreadStack(J.getv(J.getv(game.j_ST, "bread"), "x"), J.getv(J.getv(game.j_ST, "bread"), "y"), J.getv(J.getv(game.j_ST, "bread"), "w"), J.getv(J.getv(game.j_ST, "bread"), "h"))
	game.f_drawPreparation(_cells["t"][0])
	game.f_drawPaperStation(J.getv(J.getv(game.j_ST, "paper"), "x"), J.getv(J.getv(game.j_ST, "paper"), "y"), J.getv(J.getv(game.j_ST, "paper"), "w"), J.getv(J.getv(game.j_ST, "paper"), "h"), game.equipment_system.f_UV(game.j_G, "paper"), J.getv(J.getv(game.j_G, "paper"), "busy"), _cells["t"][0])
	if J.gt(J.getv(J.getv(game.j_G, "paper"), "busy"), 0.0):
		game.counter_draw.f_bar(J.add(J.getv(J.getv(game.j_ST, "paper"), "x"), 4.0), (J.getv(J.getv(game.j_ST, "paper"), "y") - 4.0), (J.getv(J.getv(game.j_ST, "paper"), "w") - 8.0), 5.0, (1.0 - J.getv(J.getv(game.j_G, "paper"), "busy")), J.getv(game.j_P, "ok"))
	if J.truth(J.method(game.j_TUN, "grillOn", [game.j_G])):
		game.f_drawGrill(J.getv(J.getv(game.j_ST, "grill"), "x"), J.getv(J.getv(game.j_ST, "grill"), "y"), J.getv(J.getv(game.j_ST, "grill"), "w"), J.getv(J.getv(game.j_ST, "grill"), "h"), J.getv(game.j_G, "grill"), _cells["t"][0], J.method(game.j_TUN, "grillCap", [game.j_G]))
		_v["sl"] = J.getv(J.getv(game.j_G, "grill"), "slots")
		_v["hazirVarmi"] = false
		_v["yanmaVarmi"] = 0.0
		_v["gi"] = 0.0
		while J.lt(_v["gi"], J.getv(_v["sl"], "length")):
			_v["gs"] = J.getv(_v["sl"], _v["gi"])
			_v["gsx"] = game.grill_system.f_grillSlotX(_v["gi"])
			_v["gsy"] = game.grill_system.f_grillSlotY(_v["gi"])
			_v["gj"] = (0.0 if J.truth(J.getv(_v["gs"], "done")) else (sin(J.add((_cells["t"][0] * 20.0), _v["gi"])) * 0.5))
			game.wrap_draw.f_drawWrapRolled(_v["gsx"], J.add(_v["gsy"], _v["gj"]), J.getv(_v["gs"], "w"), _cells["t"][0], game.grill_system.f_grillSlotSc())
			_v["gp"] = game.math_utils.f_clamp((float(J.getv(_v["gs"], "t")) / float(max(0.001, J.getv(_v["gs"], "dur")))), 0.0, 1.0)
			_v["bw"] = (floor((float((J.getv(J.getv(game.j_ST, "grill"), "w") - 10.0)) / float((J.method(game.j_TUN, "grillCap", [game.j_G]) if J.le(J.method(game.j_TUN, "grillCap", [game.j_G]), 2.0) else 2.0))) + 0.5) - 4.0)
			if (J.truth(J.getv(_v["gs"], "done")) and J.gt(J.getv(_v["gs"], "yan"), 0.0)):
				game.counter_draw.f_bar((_v["gsx"] - (float(_v["bw"]) / float(2.0))), (_v["gsy"] - 11.0), _v["bw"], 4.0, (1.0 - J.getv(_v["gs"], "yan")), (J.getv(game.j_P, "bad") if J.gt(J.getv(_v["gs"], "yan"), 0.6) else J.getv(game.j_P, "warn")))
				if J.gt(J.getv(_v["gs"], "yan"), _v["yanmaVarmi"]):
					_v["yanmaVarmi"] = J.getv(_v["gs"], "yan")
			else:
				game.counter_draw.f_bar((_v["gsx"] - (float(_v["bw"]) / float(2.0))), (_v["gsy"] - 11.0), _v["bw"], 4.0, _v["gp"], (J.getv(game.j_P, "ok") if J.ge(_v["gp"], 1.0) else J.getv(game.j_P, "warn")))
			if J.truth(J.getv(_v["gs"], "done")):
				_v["hazirVarmi"] = true
			_v["gi"] = J.add(_v["gi"], 1.0)
		if J.truth(_v["hazirVarmi"]):
			game.text_draw.f_txt((game.localization.f_T("YANIYOR!") if J.gt(_v["yanmaVarmi"], 0.35) else "AL!"), J.add(J.getv(J.getv(game.j_ST, "grill"), "x"), (float(J.getv(J.getv(game.j_ST, "grill"), "w")) / float(2.0))), (J.getv(J.getv(game.j_ST, "grill"), "y") - 18.0), (J.getv(game.j_P, "bad") if J.gt(_v["yanmaVarmi"], 0.35) else J.getv(game.j_P, "ok")), {"align": "c", "outline": true})
			game.counter_draw.f_glowRect(J.getv(J.getv(game.j_ST, "grill"), "x"), J.add(J.getv(J.getv(game.j_ST, "grill"), "y"), 8.0), J.getv(J.getv(game.j_ST, "grill"), "w"), (J.getv(J.getv(game.j_ST, "grill"), "h") - 8.0), (J.getv(game.j_P, "bad") if J.gt(_v["yanmaVarmi"], 0.35) else J.getv(game.j_P, "ok")), J.add(0.4, (0.3 * sin((_cells["t"][0] * (14.0 if J.gt(_v["yanmaVarmi"], 0.35) else 8.0))))))
		if (not J.truth(J.getv(_v["sl"], "length"))):
			_v["bekleyen"] = false
			_v["gb"] = 0.0
			while J.lt(_v["gb"], J.method(game.j_TUN, "boards", [game.j_G])):
				_v["gw2"] = J.getv(J.getv(game.j_G, "boards"), _v["gb"])
				if (((J.truth(_v["gw2"]) and J.eq(J.getv(_v["gw2"], "kind"), "wrap")) and J.eq(J.getv(_v["gw2"], "state"), "rolled")) and (not J.truth(J.getv(_v["gw2"], "grilled")))):
					_v["bekleyen"] = true
					break
				_v["gb"] = J.add(_v["gb"], 1.0)
			if (J.truth(_v["bekleyen"]) and (not J.truth(game.grill_system.f_grillDolu()))):
				game.text_draw.f_txt("KOY!", J.add(J.getv(J.getv(game.j_ST, "grill"), "x"), (float(J.getv(J.getv(game.j_ST, "grill"), "w")) / float(2.0))), (J.getv(J.getv(game.j_ST, "grill"), "y") - 18.0), J.getv(game.j_P, "warn"), {"align": "c", "outline": true})
				game.counter_draw.f_glowRect(J.getv(J.getv(game.j_ST, "grill"), "x"), J.add(J.getv(J.getv(game.j_ST, "grill"), "y"), 8.0), J.getv(J.getv(game.j_ST, "grill"), "w"), (J.getv(J.getv(game.j_ST, "grill"), "h") - 8.0), J.getv(game.j_P, "warn"), J.add(0.3, (0.25 * sin((_cells["t"][0] * 6.0)))))
	else:
		game.f_lockedStation(J.getv(game.j_ST, "grill"), "IZGARA", _cells["t"][0])
	game.f_drawCutBoard(J.getv(J.getv(game.j_ST, "cut"), "x"), J.getv(J.getv(game.j_ST, "cut"), "y"), J.getv(J.getv(game.j_ST, "cut"), "w"), J.getv(J.getv(game.j_ST, "cut"), "h"), J.getv(game.j_G, "cut"), _cells["t"][0])
	if (J.truth(J.method(game.j_TUN, "sauceOn", [game.j_G])) or J.truth(J.method(game.j_TUN, "iskOn", [game.j_G]))):
		game.f_drawSauceStation(J.getv(J.getv(game.j_ST, "sauce"), "x"), J.getv(J.getv(game.j_ST, "sauce"), "y"), J.getv(J.getv(game.j_ST, "sauce"), "w"), J.getv(J.getv(game.j_ST, "sauce"), "h"), J.method(game.j_TUN, "sauceOn", [game.j_G]), J.method(game.j_TUN, "iskOn", [game.j_G]), J.getv(game.j_G, "sauceFx"), _cells["t"][0])
	else:
		game.f_lockedStation(J.getv(game.j_ST, "sauce"), "SOS", _cells["t"][0])
	if J.truth(J.method(game.j_TUN, "fboxOn", [game.j_G])):
		game.packaging_draw.f_drawFboxStation(J.getv(J.getv(game.j_ST, "fbox"), "x"), J.getv(J.getv(game.j_ST, "fbox"), "y"), J.getv(J.getv(game.j_ST, "fbox"), "w"), J.getv(J.getv(game.j_ST, "fbox"), "h"), J.getv(J.getv(game.j_G, "fbox"), "ready"), _cells["t"][0])
		if (J.gt(J.getv(J.getv(game.j_G, "fbox"), "busy"), 0.0) and (not J.truth(J.getv(J.getv(game.j_G, "fbox"), "fly")))):
			game.counter_draw.f_bar(J.add(J.getv(J.getv(game.j_ST, "fbox"), "x"), 4.0), (J.getv(J.getv(game.j_ST, "fbox"), "y") - 4.0), (J.getv(J.getv(game.j_ST, "fbox"), "w") - 8.0), 5.0, (1.0 - J.getv(J.getv(game.j_G, "fbox"), "busy")), J.getv(game.j_P, "p1"))
		if J.gt(J.getv(J.getv(game.j_G, "fbox"), "ready"), 0.0):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.25 * sin((_cells["t"][0] * 7.0)))))
			game.f_rrectOut(J.getv(J.getv(game.j_ST, "fbox"), "x"), J.add(J.getv(J.getv(game.j_ST, "fbox"), "y"), 6.0), J.getv(J.getv(game.j_ST, "fbox"), "w"), (J.getv(J.getv(game.j_ST, "fbox"), "h") - 8.0), 3.0, J.getv(game.j_P, "ok"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["uc"] = game.fries_box_system.f_fboxUcusPos()
		if J.truth(_v["uc"]):
			game.food_draw.f_drawFriesCup(floor(J.getv(_v["uc"], "x") + 0.5), floor(J.getv(_v["uc"], "y") + 0.5), ("bos" if J.gt(J.getv(J.getv(game.j_G, "fbox"), "busy"), 0.0) else "ok"), _cells["t"][0])
			if J.truth(J.getv(_v["uc"], "dolum")):
				game.counter_draw.f_bar((J.getv(_v["uc"], "x") - 11.0), (J.getv(_v["uc"], "y") - 16.0), 22.0, 4.0, (1.0 - J.getv(J.getv(game.j_G, "fbox"), "busy")), J.getv(game.j_P, "p1"))
				if J.truth(game.f_chance(0.35)):
					game.effects.f_part({"x": J.add(J.getv(_v["uc"], "x"), game.math_utils.f_rnd((-J.n(7.0)), 7.0)), "y": (J.getv(_v["uc"], "y") - 8.0), "vx": game.math_utils.f_rnd((-J.n(10.0)), 10.0), "vy": game.math_utils.f_rnd((-J.n(26.0)), (-J.n(12.0))), "life": 0.5, "col": game.math_utils.f_pick(["#f0c24a", "#e0a828", "#fff0c0"]), "g": 200.0, "sz": 1.0})
		if (J.truth(J.getv(game.j_G, "drag")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "type"), "fbox")):
			game.food_draw.f_drawFriesCup(floor(J.getv(J.getv(game.j_G, "drag"), "x") + 0.5), floor(J.getv(J.getv(game.j_G, "drag"), "y") + 0.5), "bos", _cells["t"][0])
			_v["uygun"] = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.getv(J.getv(game.j_ST, "friesT"), "x") - 4.0), (J.getv(J.getv(game.j_ST, "friesT"), "y") - 6.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "w"), 8.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "h"), 12.0))
			J.setv(game.j_ctx, "globalAlpha", J.add(0.35, (0.25 * sin((_cells["t"][0] * 8.0)))))
			game.f_rrectOut((J.getv(J.getv(game.j_ST, "friesT"), "x") - 2.0), (J.getv(J.getv(game.j_ST, "friesT"), "y") - 3.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "w"), 4.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "h"), 6.0), 3.0, (J.getv(game.j_P, "ok") if J.truth(_v["uygun"]) else J.getv(game.j_P, "au0")))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		game.f_lockedStation(J.getv(game.j_ST, "fbox"), "KUTU", _cells["t"][0])
	if J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])):
		game.f_drawSweetTray(J.getv(J.getv(game.j_ST, "sweet"), "x"), J.getv(J.getv(game.j_ST, "sweet"), "y"), J.getv(J.getv(game.j_ST, "sweet"), "w"), J.getv(J.getv(game.j_ST, "sweet"), "h"), J.getv(J.getv(game.j_G, "stockAnim"), "sweet"), J.method(game.j_TUN, "sweetMax", [game.j_G]), _cells["t"][0], J.getv(J.getv(game.j_G, "fxTray"), "sweet"))
	else:
		game.f_lockedStation(J.getv(game.j_ST, "sweet"), "TATLI", _cells["t"][0])
	game.f_drawTrash(J.getv(J.getv(game.j_ST, "trash"), "x"), J.getv(J.getv(game.j_ST, "trash"), "y"), J.getv(J.getv(game.j_ST, "trash"), "w"), J.getv(J.getv(game.j_ST, "trash"), "h"), _cells["t"][0], (J.getv(game.j_G, "emptyT") if J.gt(J.getv(game.j_G, "emptyT"), 0.0) else 0.0), J.getv(game.j_G, "trash"))
	if J.ge(J.method(game.j_TUN, "secLevel", [game.j_G]), 3.0):
		game.window_draw.f_drawWallCam(_cells["t"][0], false)
	if J.eq(J.getv(J.getv(game.j_G, "fryer"), "state"), "done"):
		game.text_draw.f_txt("ÇIKAR!", J.add(J.getv(J.getv(game.j_ST, "fryer"), "x"), (float(J.getv(J.getv(game.j_ST, "fryer"), "w")) / float(2.0))), (J.getv(J.getv(game.j_ST, "fryer"), "y") - 8.0), J.getv(game.j_P, "ok"), {"align": "c", "outline": true})
		game.counter_draw.f_glowRect(J.getv(J.getv(game.j_ST, "fryer"), "x"), J.add(J.getv(J.getv(game.j_ST, "fryer"), "y"), 10.0), J.getv(J.getv(game.j_ST, "fryer"), "w"), (J.getv(J.getv(game.j_ST, "fryer"), "h") - 10.0), J.getv(game.j_P, "ok"), J.add(0.4, (0.3 * sin((_cells["t"][0] * 8.0)))))
	game.game_draw.f_drawFlyMeat(_cells["t"][0])
	_v["fi2"] = 0.0
	while J.lt(_v["fi2"], J.getv(J.getv(game.j_G, "flyIng"), "length")):
		_v["fg"] = J.getv(J.getv(game.j_G, "flyIng"), _v["fi2"])
		if J.lt(J.getv(_v["fg"], "t"), 0.0):
			_v["fi2"] = J.add(_v["fi2"], 1.0)
			continue
		_v["k2"] = game.math_utils.f_clamp(J.getv(_v["fg"], "t"), 0.0, 1.0)
		_v["fgx"] = game.math_utils.f_lerp(J.getv(_v["fg"], "x0"), J.getv(_v["fg"], "x1"), _v["k2"])
		_v["fgy"] = (game.math_utils.f_lerp(J.getv(_v["fg"], "y0"), J.getv(_v["fg"], "y1"), _v["k2"]) - (sin((_v["k2"] * J.getv({"PI": PI}, "PI"))) * 15.0))
		J.setv(game.j_ctx, "globalAlpha", 0.2)
		game.f_ell(_v["fgx"], J.add(J.getv(_v["fg"], "y1"), 2.0), 4.0, 1.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["spin"] = abs(sin(J.add(J.getv(_v["fg"], "rot"), (_v["k2"] * 7.0))))
		if J.eq(J.getv(_v["fg"], "kind"), "sweet"):
			game.f_ell(_v["fgx"], J.add(_v["fgy"], 1.0), 4.0, 3.0, "#8a4f14")
			game.f_ell(_v["fgx"], _v["fgy"], 4.0, 3.0, "#c9772a")
			game.f_ell(_v["fgx"], _v["fgy"], 2.0, 1.0, "#8a5a1e")
			game.f_px((_v["fgx"] - 2.0), (_v["fgy"] - 1.0), "#ffd07a")
		else:
			if J.eq(J.getv(_v["fg"], "kind"), "pickle"):
				game.f_ell(_v["fgx"], J.add(_v["fgy"], 1.0), J.add(3.0, _v["spin"]), 2.0, "#22350a")
				game.f_ell(_v["fgx"], _v["fgy"], J.add(3.0, _v["spin"]), 2.0, "#5f8322")
				game.f_ell(_v["fgx"], _v["fgy"], J.add(2.0, (_v["spin"] * 0.6)), 1.0, "#9dbe45")
				game.f_px((_v["fgx"] - 1.0), _v["fgy"], "#e2efa4")
				game.f_px(J.add(_v["fgx"], 1.0), _v["fgy"], "#e2efa4")
			else:
				if J.eq(J.getv(_v["fg"], "kind"), "tomato"):
					game.garnish_draw.f_drawTomatoSlice(floor(_v["fgx"] + 0.5), floor(_v["fgy"] + 0.5), 4.0)
				else:
					if J.eq(J.getv(_v["fg"], "kind"), "pepper"):
						game.garnish_draw.f_drawPepper(floor(_v["fgx"] + 0.5), J.add(floor(_v["fgy"] + 0.5), 5.0), 10.0, (1.0 if J.gt(_v["spin"], 0.5) else (-J.n(1.0))))
					else:
						if J.eq(J.getv(_v["fg"], "kind"), "ayran"):
							game.f_fr((_v["fgx"] - 2.0), (_v["fgy"] - 3.0), 5.0, 7.0, "#dfe7ec")
							game.f_fr((_v["fgx"] - 2.0), (_v["fgy"] - 2.0), 4.0, 6.0, "#f8f6ee")
							game.f_fr((_v["fgx"] - 2.0), (_v["fgy"] - 4.0), 5.0, 2.0, "#3f79c0")
							game.f_px((_v["fgx"] - 1.0), (_v["fgy"] - 1.0), "#ffffff")
						else:
							game.f_ell(_v["fgx"], J.add(_v["fgy"], 1.0), 3.0, 2.0, "#cfc4a6")
							game.f_ell(_v["fgx"], _v["fgy"], 3.0, 2.0, J.getv(game.j_P, "s0"))
							game.f_ell((_v["fgx"] - 1.0), (_v["fgy"] - 1.0), 2.0, 1.0, "#ffffff")
							if J.truth(game.f_chance(0.3)):
								game.effects.f_part({"x": _v["fgx"], "y": J.add(_v["fgy"], 2.0), "vx": 0.0, "vy": 8.0, "life": 0.3, "col": J.getv(game.j_P, "s1"), "g": 70.0, "sz": 1.0})
		_v["fi2"] = J.add(_v["fi2"], 1.0)
	if J.truth(J.getv(game.j_G, "flyP")):
		_v["fp"] = J.getv(game.j_G, "flyP")
		_v["k"] = J.getv(_v["fp"], "t")
		_v["fx"] = game.math_utils.f_lerp(J.getv(_v["fp"], "x0"), J.getv(_v["fp"], "x1"), _v["k"])
		_v["fy"] = (game.math_utils.f_lerp(J.getv(_v["fp"], "y0"), J.getv(_v["fp"], "y1"), _v["k"]) - (sin((_v["k"] * J.getv({"PI": PI}, "PI"))) * 26.0))
		J.setv(game.j_ctx, "globalAlpha", 0.25)
		game.f_ell(_v["fx"], J.add(J.getv(_v["fp"], "y1"), 4.0), 6.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_ell(_v["fx"], J.add(_v["fy"], 1.0), 6.0, 4.0, "#8a6432")
		game.f_ell(_v["fx"], _v["fy"], 6.0, 4.0, "#b98b46")
		game.f_ell((_v["fx"] - 1.0), (_v["fy"] - 1.0), 4.0, 2.0, "#d8ab63")
		game.f_px(J.add(_v["fx"], 2.0), _v["fy"], "#6d4d24")
	game.phone_draw.f_drawCourier(_cells["t"][0])
	game.phone_draw.f_drawMotoBadge(_cells["t"][0])
	if J.gt(J.getv(game.j_G, "luckMsg"), 0.0):
		_v["lw"] = J.add(max(game.f_textW("Yolda para buldum!"), 60.0), 14.0)
		_v["lx"] = 6.0
		_v["ly"] = 118.0
		J.setv(game.j_ctx, "globalAlpha", min(1.0, J.getv(game.j_G, "luckMsg")))
		game.f_rrect(_v["lx"], _v["ly"], _v["lw"], 24.0, 3.0, J.getv(game.j_P, "ui0"))
		game.f_rrectOut(_v["lx"], _v["ly"], _v["lw"], 24.0, 3.0, J.getv(game.j_P, "au2"))
		game.text_draw.f_txt("Yolda para buldum!", J.add(_v["lx"], 6.0), J.add(_v["ly"], 3.0), J.getv(game.j_P, "ink"))
		game.text_draw.f_txt(J.add("+$", game.math_utils.f_fmtMoney(J.getv(game.j_G, "luckAmt"))), J.add(_v["lx"], 6.0), J.add(_v["ly"], 14.0), J.getv(game.j_P, "ok"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.effects.f_psDraw()
	if (J.truth(J.getv(game.j_G, "drag")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "type"), "et")):
		_v["ex2"] = floor(J.getv(J.getv(game.j_G, "drag"), "x") + 0.5)
		_v["ey2"] = floor(J.getv(J.getv(game.j_G, "drag"), "y") + 0.5)
		if (J.truth(J.getv(game.j_G, "kedi")) and J.truth(game.event_system.f_kediHit(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y")))):
			_v["ky3"] = game.event_system.f_kediY()
			J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (sin((_cells["t"][0] * 8.0)) * 0.2)))
			game.f_ring(J.getv(J.getv(game.j_G, "kedi"), "x"), (_v["ky3"] - 8.0), 13.0, "#ffd257")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_ell(_v["ex2"], J.add(_v["ey2"], 6.0), 6.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_meatStrip(_v["ex2"], _v["ey2"], 0.9, 7.0, 0.5)
	if (J.truth(J.getv(game.j_G, "drag")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "type"), "paper")):
		_v["dx2"] = floor(J.getv(J.getv(game.j_G, "drag"), "x") + 0.5)
		_v["dy2"] = J.add(floor(J.getv(J.getv(game.j_G, "drag"), "y") + 0.5), 10.0)
		J.setv(game.j_ctx, "globalAlpha", 0.25)
		game.f_ell(_v["dx2"], J.add(_v["dy2"], 8.0), 12.0, 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr((_v["dx2"] - 12.0), (_v["dy2"] - 8.0), 24.0, 17.0, "#d8d2c2")
		game.f_fr((_v["dx2"] - 12.0), (_v["dy2"] - 9.0), 24.0, 17.0, "#fdfaf0")
		game.f_fr((_v["dx2"] - 10.0), (_v["dy2"] - 4.0), 20.0, 3.0, "#d8352c")
		game.f_fr((_v["dx2"] - 10.0), J.add(_v["dy2"], 1.0), 20.0, 3.0, "#2f5f9e")
		game.f_hl((_v["dx2"] - 12.0), (_v["dy2"] - 9.0), 24.0, "#ffffff")
		_v["bi3"] = game.drag_system.f_boardAt(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"))
		if ((J.ge(_v["bi3"], 0.0) and J.truth(J.getv(J.getv(game.j_G, "boards"), _v["bi3"]))) and J.eq(J.getv(J.getv(J.getv(game.j_G, "boards"), _v["bi3"]), "state"), "rolled")):
			_v["nb3"] = J.method(game.j_TUN, "boards", [game.j_G])
			_v["bw3"] = (float(J.getv(J.getv(game.j_ST, "board"), "w")) / float(_v["nb3"]))
			game.counter_draw.f_glowRect(J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), (_v["bw3"] * _v["bi3"])), 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 7.0), (_v["bw3"] - 4.0), 35.0, J.getv(game.j_P, "ok"), J.add(0.5, (0.3 * sin((_cells["t"][0] * 8.0)))))
	_v["j"] = 0.0
	while J.lt(_v["j"], J.getv(J.getv(game.j_G, "customers"), "length")):
		_v["cc"] = J.getv(J.getv(game.j_G, "customers"), _v["j"])
		if (J.eq(J.getv(_v["cc"], "state"), "wait") and J.lt(J.getv(_v["cc"], "patience"), 0.3)):
			_v["ey"] = J.add((J.getv(_v["cc"], "y") - 62.0), (sin((_cells["t"][0] * 9.0)) * 2.0))
			J.setv(game.j_ctx, "globalAlpha", J.add(0.6, (0.4 * sin((_cells["t"][0] * 9.0)))))
			game.f_fr(J.add(J.getv(_v["cc"], "x"), 20.0), _v["ey"], 3.0, 7.0, J.getv(game.j_P, "bad"))
			game.f_fr(J.add(J.getv(_v["cc"], "x"), 20.0), J.add(_v["ey"], 9.0), 3.0, 3.0, J.getv(game.j_P, "bad"))
			game.f_hl(J.add(J.getv(_v["cc"], "x"), 20.0), _v["ey"], 3.0, "#ff9a8a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_drawOrderBubble(_v["cc"], _cells["t"][0])
		_v["j"] = J.add(_v["j"], 1.0)
	# BIRLESIK: karsi dukkanin adami musteri sirasinda ama tezgahtan SONRA
	# ciziliyor; yeni tezgahin rafi (ledgeY 140) daha yukarida oldugu icin govde
	# tezgahin ustune biniyordu -> raf hizasinda kirpilir (tezgahin arkasinda)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [0.0, 0.0, game.j_W, J.getv(game.j_LAY, "ledgeY")])
	J.method(game.j_ctx, "clip", [])
	game.incident_draw.f_drawRakip(_cells["t"][0])
	J.method(game.j_ctx, "restore", [])
	game.weather_draw.f_drawWeather(_cells["t"][0])
	game.incident_draw.f_drawKesinti(_cells["t"][0])
	game.game_draw.f_drawFlyCoins(_cells["t"][0])
	game.effects.f_ftDraw()
	if J.truth(J.getv(J.getv(game.j_G, "crate"), "open")):
		game.preparation_draw.f_drawCratePanel(_cells["t"][0])
	game.hud_draw.f_drawHUD(_cells["t"][0])
	if J.eq(J.kind(J.ref(game.rival_panel_draw.f_drawBahisPanel, 1)), "function"):
		game.rival_panel_draw.f_drawBahisPanel(_cells["t"][0])
	game.tutorial_draw.f_drawTut(_cells["t"][0])
	game.f_drawHoverHint(_cells["t"][0])
	game.regulation_draw.f_drawFermanKagit(_cells["t"][0])
	return null

func _closure_250(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_cp: Variant = null
	var v_cu: Variant = null
	var v_ty: Variant = null
	v_ty = J.arg(_args, 0)
	v_cp = game.drink_system.f_cupPos(v_ty)
	v_cu = J.getv(J.getv(game.j_G, "cups"), v_ty)
	if J.truth(v_cu):
		game.food_draw.f_drawCup(J.getv(v_cp, 0.0), J.getv(v_cp, 1.0), v_ty, J.getv(v_cu, "fill"), _captures["721:t"][0])
		if J.ge(J.getv(v_cu, "fill"), 1.0):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.25 * sin((_captures["721:t"][0] * 7.0)))))
			game.f_ring(J.getv(v_cp, 0.0), (J.getv(v_cp, 1.0) - 2.0), 8.0, J.getv(game.j_P, "ok"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		J.setv(game.j_ctx, "globalAlpha", 0.25)
		game.f_ell(J.getv(v_cp, 0.0), J.add(J.getv(v_cp, 1.0), 9.0), 6.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null
