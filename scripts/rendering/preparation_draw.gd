# Preparation draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func f_drawPreparation(p_t: Variant = null) -> Variant:
	var _cells: Dictionary = {"t": [p_t]}
	var _v: Dictionary = {}
	_v["nb"] = J.method(game.j_TUN, "boards", [game.j_G])
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 3.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 10.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 4.0), 34.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 8.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 4.0), 34.0, 3.0, "#7a5230")
	game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 7.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 4.0), 34.0, 3.0, "#c49a68")
	game.f_rrect(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 4.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 9.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 8.0), 30.0, 2.0, "#dcb480")
	_v["g2"] = 0.0
	while J.lt(_v["g2"], 6.0):
		J.setv(game.j_ctx, "globalAlpha", 0.32)
		game.f_hl(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 5.0), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 11.0), (_v["g2"] * 5.0)), (J.getv(J.getv(game.j_ST, "board"), "w") - 10.0), ("#c09660" if J.truth(fmod(J.n(_v["g2"]), J.n(2.0))) else "#cfa876"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["g2"] = J.add(_v["g2"], 1.0)
	game.f_rrectOut(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 4.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 9.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 8.0), 30.0, 2.0, "#b08a58")
	game.f_hl(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 4.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 8.0), (J.getv(J.getv(game.j_ST, "board"), "w") - 8.0), "#eccb96")
	_v["ci"] = 0.0
	while J.lt(_v["ci"], 7.0):
		J.setv(game.j_ctx, "globalAlpha", 0.18)
		game.f_ln(J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 8.0), (_v["ci"] * 12.0)), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 14.0), (fmod(J.n(_v["ci"]), J.n(3.0)) * 6.0)), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 13.0), (_v["ci"] * 12.0)), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 18.0), (fmod(J.n(_v["ci"]), J.n(3.0)) * 6.0)), "#8a6a42")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["ci"] = J.add(_v["ci"], 1.0)
	_v["wsc"] = (1.0 if J.eq(_v["nb"], 1.0) else (0.74 if J.eq(_v["nb"], 2.0) else 0.58))
	_v["b"] = 0.0
	while J.lt(_v["b"], _v["nb"]):
		_v["bcx"] = game.wrap_system.f_boardCX(_v["b"])
		_v["bcy"] = J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 24.0)
		_v["w"] = J.getv(J.getv(game.j_G, "boards"), _v["b"])
		if (not J.truth(_v["w"])):
			_v["b"] = J.add(_v["b"], 1.0)
			continue
		_v["pop"] = max(0.0, (J.getv(_v["w"], "pop") if J.truth(J.getv(_v["w"], "pop")) else 0.0))
		_v["yoff"] = ((-J.n(sin((_v["pop"] * J.getv({"PI": PI}, "PI"))))) * 3.0)
		if ((J.eq(J.getv(_v["w"], "state"), "open") and J.eq(_v["b"], J.getv(game.j_G, "act"))) and J.gt(_v["nb"], 1.0)):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.3 * sin((_cells["t"][0] * 5.0)))))
			game.f_hl((_v["bcx"] - (14.0 * _v["wsc"])), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 38.0), (28.0 * _v["wsc"]), J.getv(game.j_P, "au1"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.eq(J.getv(_v["w"], "kind"), "pide"):
			game.plate_draw.f_drawPideBoard(_v["bcx"], J.add(_v["bcy"], _v["yoff"]), _v["w"], _cells["t"][0], _v["wsc"])
			_v["pn2"] = min((J.getv(_v["w"], "n") if J.truth(J.getv(_v["w"], "n")) else 0.0), game.j_PIDE_NEED)
			_v["lbl2"] = J.add(J.add(J.add(game.localization.f_T("DOĞRA  "), _v["pn2"]), "/"), game.j_PIDE_NEED)
			_v["lw3"] = J.add(game.f_textW(_v["lbl2"]), 8.0)
			J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.3 * sin((_cells["t"][0] * 4.0)))))
			game.f_rrect((_v["bcx"] - (float(_v["lw3"]) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 34.0), _v["lw3"], 10.0, 3.0, "rgba(20,14,12,.8)")
			game.text_draw.f_txt(_v["lbl2"], _v["bcx"], J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 36.0), J.getv(game.j_P, "au0"), {"align": "c"})
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			_v["b"] = J.add(_v["b"], 1.0)
			continue
		if J.eq(J.getv(_v["w"], "kind"), "plate"):
			game.plate_draw.f_drawPlate(_v["bcx"], J.add(_v["bcy"], _v["yoff"]), _v["w"], _cells["t"][0], _v["wsc"])
			if J.eq(J.getv(_v["w"], "state"), "ready"):
				J.setv(game.j_ctx, "globalAlpha", J.add(0.35, (0.25 * sin((_cells["t"][0] * 7.0)))))
				game.f_rrectOut(((_v["bcx"] - (21.0 * _v["wsc"])) - 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 9.0), J.add((42.0 * _v["wsc"]), 4.0), 30.0, 3.0, J.getv(game.j_P, "ok"))
				J.setv(game.j_ctx, "globalAlpha", 1.0)
			else:
				_v["nx"] = ("DÖNER" if J.lt(J.getv(_v["w"], "meat"), J.method(game.j_TUN, "iskMeat", [game.j_G])) else ("TEREYAĞI" if (not J.truth(J.getv(_v["w"], "butter"))) else "YOĞURT"))
				_v["nw"] = J.add(game.f_textW(_v["nx"]), 8.0)
				J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.3 * sin((_cells["t"][0] * 4.0)))))
				game.f_rrect((_v["bcx"] - (float(_v["nw"]) / float(2.0))), (J.getv(J.getv(game.j_ST, "board"), "y") - 1.0), _v["nw"], 10.0, 3.0, "rgba(20,14,12,.8)")
				game.text_draw.f_txt(_v["nx"], _v["bcx"], J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 1.0), J.getv(game.j_P, "au0"), {"align": "c"})
				J.setv(game.j_ctx, "globalAlpha", 1.0)
			_v["b"] = J.add(_v["b"], 1.0)
			continue
		if J.eq(J.getv(_v["w"], "state"), "rolled"):
			game.wrap_draw.f_drawWrapRolled(_v["bcx"], J.add(_v["bcy"], _v["yoff"]), _v["w"], _cells["t"][0], _v["wsc"])
			game.legacy_order_draw.f_wrapEtiket(_v["bcx"], J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 30.0), _v["w"], J.gt(_v["nb"], 2.0))
			_v["lbl"] = null
			_v["lcol"] = J.getv(game.j_P, "ui0")
			if (J.truth(game.recipe_system.f_wrapNeedsGrill(_v["w"])) and (not J.truth(game.grill_system.f_grillDolu()))):
				_v["lbl"] = "IZGARAYA AT"
				_v["lcol"] = "#ffb45a"
			else:
				if (J.eq(game.equipment_system.f_UV(game.j_G, "paper"), 0.0) and (not (J.truth(J.getv(game.j_G, "drag")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "type"), "paper")))):
					_v["lbl"] = "KAĞIT SÜRÜKLE"
			if J.truth(_v["lbl"]):
				_v["lw2"] = J.add(game.f_textW(_v["lbl"]), 8.0)
				J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.3 * sin((_cells["t"][0] * 4.0)))))
				game.f_rrect((_v["bcx"] - (float(_v["lw2"]) / float(2.0))), (J.getv(J.getv(game.j_ST, "board"), "y") - 1.0), _v["lw2"], 10.0, 3.0, "rgba(20,14,12,.8)")
				game.text_draw.f_txt(_v["lbl"], _v["bcx"], J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 1.0), _v["lcol"], {"align": "c"})
				J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.eq(J.getv(_v["w"], "state"), "ready"):
				game.wrap_draw.f_drawWrapRolled(_v["bcx"], J.add(_v["bcy"], _v["yoff"]), _v["w"], _cells["t"][0], _v["wsc"])
				J.setv(game.j_ctx, "globalAlpha", J.add(0.35, (0.25 * sin((_cells["t"][0] * 7.0)))))
				game.f_rrectOut(((_v["bcx"] - (16.0 * _v["wsc"])) - 2.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 9.0), J.add((32.0 * _v["wsc"]), 4.0), 30.0, 3.0, J.getv(game.j_P, "ok"))
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				game.legacy_order_draw.f_wrapEtiket(_v["bcx"], J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 30.0), _v["w"], J.gt(_v["nb"], 2.0))
			else:
				game.wrap_draw.f_drawWrapOpen(_v["bcx"], J.add(_v["bcy"], _v["yoff"]), _v["w"], _cells["t"][0], _v["wsc"])
				if (J.truth(game.recipe_system.f_wrapAny(_v["w"])) and (not ((J.truth(J.getv(game.j_G, "drag")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "type"), "roll")) and J.eq(J.getv(J.getv(game.j_G, "drag"), "idx"), _v["b"])))):
					_v["ao"] = floor((sin((_cells["t"][0] * 4.0)) * 2.0) + 0.5)
					J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.3 * sin((_cells["t"][0] * 4.0)))))
					game.f_rrect((_v["bcx"] - 16.0), (J.getv(J.getv(game.j_ST, "board"), "y") - 1.0), 32.0, 10.0, 3.0, "rgba(20,14,12,.8)")
					game.text_draw.f_txt("SAR", (_v["bcx"] - 5.0), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 1.0), J.getv(game.j_P, "au0"), {"align": "c"})
					_v["axx"] = J.add(_v["bcx"], 8.0)
					_v["aa"] = 0.0
					while J.lt(_v["aa"], 6.0):
						game.f_px(_v["axx"], J.add((J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 6.0) - _v["aa"]), _v["ao"]), J.getv(game.j_P, "au0"))
						_v["aa"] = J.add(_v["aa"], 1.0)
					game.f_px((_v["axx"] - 1.0), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 2.0), _v["ao"]), J.getv(game.j_P, "au0"))
					game.f_px(J.add(_v["axx"], 1.0), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 2.0), _v["ao"]), J.getv(game.j_P, "au0"))
					game.f_px((_v["axx"] - 2.0), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 3.0), _v["ao"]), J.getv(game.j_P, "au0"))
					game.f_px(J.add(_v["axx"], 2.0), J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 3.0), _v["ao"]), J.getv(game.j_P, "au0"))
					J.setv(game.j_ctx, "globalAlpha", 1.0)
		_v["b"] = J.add(_v["b"], 1.0)
	return null

# game.js:3146
func f_lockedStation(p_s: Variant = null, p_label: Variant = null, p_t: Variant = null) -> Variant:
	var v_cx: Variant = null
	var v_cy: Variant = null
	var v_s: Variant = p_s
	var v_label: Variant = p_label
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.38)
	game.f_rrect(J.getv(v_s, "x"), J.add(J.getv(v_s, "y"), 8.0), J.getv(v_s, "w"), (J.getv(v_s, "h") - 10.0), 3.0, "#3a4048")
	J.setv(game.j_ctx, "globalAlpha", 0.55)
	game.f_rrectOut(J.getv(v_s, "x"), J.add(J.getv(v_s, "y"), 8.0), J.getv(v_s, "w"), (J.getv(v_s, "h") - 10.0), 3.0, "#5a626c")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_cx = J.add(J.getv(v_s, "x"), (float(J.getv(v_s, "w")) / float(2.0)))
	v_cy = J.add(J.getv(v_s, "y"), (float(J.getv(v_s, "h")) / float(2.0)))
	# REMAKE kancasi
	if not game.f_hdKilitIkon(v_cx, v_cy):
		game.f_fr((v_cx - 4.0), (v_cy - 1.0), 9.0, 7.0, "#8a929b")
		game.f_fr((v_cx - 3.0), v_cy, 7.0, 5.0, "#b6bec6")
		game.f_rc((v_cx - 3.0), (v_cy - 5.0), 7.0, 5.0, "#8a929b")
	game.text_draw.f_txt(v_label, v_cx, J.add(v_cy, 9.0), "rgba(255,255,255,.5)", {"align": "c"})
	return null

# game.js:3164
func f_drawDonerBicak(p_kx: Variant = null, p_ky: Variant = null) -> Variant:
	var v_kx: Variant = p_kx
	var v_ky: Variant = p_ky
	J.setv(game.j_ctx, "globalAlpha", 0.26)
	game.f_fr(J.add(v_kx, 1.0), J.add(v_ky, 3.0), 24.0, 1.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_drawKesimBicagi(J.add(v_kx, 25.0), v_ky, (-J.n(1.0)), game.equipment_system.f_UV(game.j_G, "knife"))
	return null

# game.js:3174
func f_drawShaveHint(p_t: Variant = null) -> Variant:
	var v_sh: Variant = null
	var v_sw: Variant = null
	var v_a: Variant = null
	var v_uz: Variant = null
	var v_i: Variant = null
	var v_u: Variant = null
	var v_xx: Variant = null
	var v_yy: Variant = null
	var v_kal: Variant = null
	var v_ky: Variant = null
	var v_kx: Variant = null
	var v_p: Variant = null
	var v_ar: Variant = null
	var v_t: Variant = p_t
	v_sh = J.getv(game.j_G, "shave")
	if J.truth(J.getv(J.getv(game.j_G, "spit"), "swipe")):
		v_sw = J.getv(J.getv(game.j_G, "spit"), "swipe")
		v_a = J.getv(v_sw, "t")
		J.setv(game.j_ctx, "globalAlpha", (v_a * 0.9))
		v_uz = 30.0
		v_i = 0.0
		while J.lt(v_i, v_uz):
			v_u = (float(v_i) / float((v_uz - 1.0)))
			v_xx = J.add((J.getv(J.getv(game.j_LAY, "spit"), "cx") - 24.0), floor((v_u * 30.0) + 0.5))
			v_yy = floor((J.add((J.getv(v_sw, "y") - 9.0), (v_u * 18.0)) - (sin((v_u * J.getv({"PI": PI}, "PI"))) * 3.0)) + 0.5)
			v_kal = J.add(1.0, floor((sin((v_u * J.getv({"PI": PI}, "PI"))) * 2.0) + 0.5))
			game.f_fr(v_xx, v_yy, 1.0, v_kal, ("#ffffff" if J.lt(v_u, 0.45) else "#ffe9c0"))
			if J.gt(v_kal, 2.0):
				game.f_px(v_xx, J.add(v_yy, v_kal), "rgba(255,230,170,.45)")
			v_i = J.add(v_i, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(game.f_hitST("spit")):
		v_ky = game.math_utils.f_clamp(J.getv(game.j_IN, "y"), J.add(J.getv(J.getv(game.j_LAY, "spit"), "top"), 8.0), (J.getv(J.getv(game.j_LAY, "spit"), "bot") - 12.0))
		v_kx = (J.getv(J.getv(game.j_LAY, "spit"), "cx") - 30.0)
		game.preparation_draw.f_drawDonerBicak(v_kx, v_ky)
		v_p = (float(J.getv(v_sh, "travel")) / float(J.method(game.j_TUN, "shaveDist", [game.j_G])))
		game.counter_draw.f_bar((J.getv(J.getv(game.j_LAY, "spit"), "cx") - 16.0), J.add(J.getv(J.getv(game.j_LAY, "spit"), "bot"), 8.0), 32.0, 5.0, v_p, J.getv(game.j_P, "au1"))
		if J.le(J.getv(v_sh, "act"), 0.0):
			game.text_draw.f_txt("YUKARI-AŞAĞI", J.getv(J.getv(game.j_LAY, "spit"), "cx"), (J.getv(J.getv(game.j_LAY, "spit"), "top") - 26.0), J.getv(game.j_P, "au0"), {"align": "c", "outline": true})
			v_ar = (sin((v_t * 6.0)) * 4.0)
			game.f_fr((J.getv(J.getv(game.j_LAY, "spit"), "cx") - 1.0), J.add((J.getv(J.getv(game.j_LAY, "spit"), "top") - 16.0), v_ar), 3.0, 8.0, J.getv(game.j_P, "au1"))
			game.f_fr((J.getv(J.getv(game.j_LAY, "spit"), "cx") - 2.0), J.add((J.getv(J.getv(game.j_LAY, "spit"), "top") - 16.0), v_ar), 5.0, 2.0, J.getv(game.j_P, "au1"))
	if J.ge(J.getv(game.j_G, "meat"), J.method(game.j_TUN, "meatCap", [])):
		game.text_draw.f_txt("TEPSİ DOLU", J.getv(J.getv(game.j_LAY, "spit"), "cx"), J.add(J.getv(J.getv(game.j_LAY, "spit"), "bot"), 16.0), J.getv(game.j_P, "warn"), {"align": "c", "outline": true})
	return null

# game.js:3207
func f_drawCratePanel(p_t: Variant = null) -> Variant:
	var v_r0: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_items: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_r: Variant = null
	var v_over: Variant = null
	var v_n: Variant = null
	var v_m: Variant = null
	var v_bc: Variant = null
	var v_t: Variant = p_t
	v_r0 = game.stock_system.f_cratePanelRect()
	v_px0 = J.getv(v_r0, 0.0)
	v_py0 = J.getv(v_r0, 1.0)
	v_pw = J.getv(v_r0, 2.0)
	v_ph = J.getv(v_r0, 3.0)
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_rrect(J.add(v_px0, 2.0), J.add(v_py0, 3.0), v_pw, v_ph, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(v_px0, v_py0, v_pw, v_ph, 4.0, J.getv(game.j_P, "ui4"))
	game.f_rrect(J.add(v_px0, 1.0), J.add(v_py0, 1.0), (v_pw - 2.0), (v_ph - 2.0), 3.0, J.getv(game.j_P, "ui0"))
	game.f_rrectOut(v_px0, v_py0, v_pw, v_ph, 4.0, J.getv(game.j_P, "ui5"))
	game.text_draw.f_txt("DEPO", J.add(v_px0, (float(v_pw) / float(2.0))), J.add(v_py0, 4.0), J.getv(game.j_P, "ui4"), {"align": "c"})
	v_items = game.stock_system.f_crateItems()
	v_i = 0.0
	while J.lt(v_i, J.getv(v_items, "length")):
		v_k = J.getv(J.getv(v_items, v_i), 0.0)
		v_r = game.stock_system.f_crateSlotRect(v_i)
		v_over = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), J.getv(v_r, 0.0), J.getv(v_r, 1.0), J.getv(v_r, 2.0), J.getv(v_r, 3.0))
		game.f_rrect(J.getv(v_r, 0.0), J.getv(v_r, 1.0), J.getv(v_r, 2.0), J.getv(v_r, 3.0), 3.0, ("#f2e6c6" if J.truth(v_over) else J.getv(game.j_P, "ui1")))
		game.f_rrectOut(J.getv(v_r, 0.0), J.getv(v_r, 1.0), J.getv(v_r, 2.0), J.getv(v_r, 3.0), 3.0, J.getv(game.j_P, "ui3"))
		if J.eq(v_k, "pickle"):
			game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 11.0), 5.0, 3.0, J.getv(game.j_P, "g3"))
			game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 5.0, 3.0, J.getv(game.j_P, "g2"))
			game.f_px(J.add(J.getv(v_r, 0.0), 8.0), J.add(J.getv(v_r, 1.0), 8.0), J.getv(game.j_P, "g0"))
		else:
			if J.eq(v_k, "yogurt"):
				game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 11.0), 5.0, 3.0, J.getv(game.j_P, "s3"))
				game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 5.0, 3.0, J.getv(game.j_P, "s0"))
				game.f_px(J.add(J.getv(v_r, 0.0), 8.0), J.add(J.getv(v_r, 1.0), 8.0), "#ffffff")
			else:
				if J.eq(v_k, "ayran"):
					game.f_fr(J.add(J.getv(v_r, 0.0), 7.0), J.add(J.getv(v_r, 1.0), 5.0), 7.0, 11.0, "#dfe7ec")
					game.f_fr(J.add(J.getv(v_r, 0.0), 8.0), J.add(J.getv(v_r, 1.0), 7.0), 5.0, 8.0, "#f8f6ee")
					game.f_fr(J.add(J.getv(v_r, 0.0), 7.0), J.add(J.getv(v_r, 1.0), 4.0), 7.0, 2.0, "#3f79c0")
				else:
					if J.eq(v_k, "tomato"):
						game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 11.0), 5.0, 4.0, "#8e1c14")
						game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 5.0, 4.0, "#d8352c")
						game.f_ell(J.add(J.getv(v_r, 0.0), 9.0), J.add(J.getv(v_r, 1.0), 9.0), 2.0, 1.0, "#ff8a72")
						game.f_px(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 6.0), "#3f7a2a")
						game.f_px(J.add(J.getv(v_r, 0.0), 9.0), J.add(J.getv(v_r, 1.0), 6.0), "#4f8f33")
						game.f_px(J.add(J.getv(v_r, 0.0), 11.0), J.add(J.getv(v_r, 1.0), 6.0), "#4f8f33")
						game.f_px(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 5.0), "#5aa03a")
					else:
						if J.eq(v_k, "pepper"):
							game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 3.0, 5.0, "#2f6a24")
							game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 9.0), 3.0, 5.0, "#4f9330")
							game.f_px(J.add(J.getv(v_r, 0.0), 9.0), J.add(J.getv(v_r, 1.0), 8.0), "#8ec95a")
							game.f_px(J.add(J.getv(v_r, 0.0), 9.0), J.add(J.getv(v_r, 1.0), 9.0), "#8ec95a")
							game.f_px(J.add(J.getv(v_r, 0.0), 11.0), J.add(J.getv(v_r, 1.0), 13.0), "#2f6a24")
							game.f_px(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 14.0), "#2f6a24")
							game.f_px(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 5.0), "#6b4a1e")
							game.f_px(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 4.0), "#8a6428")
						else:
							game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 11.0), 5.0, 4.0, "#8a4f14")
							game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 5.0, 4.0, "#c9772a")
							game.f_ell(J.add(J.getv(v_r, 0.0), 10.0), J.add(J.getv(v_r, 1.0), 10.0), 2.0, 1.0, "#8a5a1e")
		game.text_draw.f_txt(J.getv(J.getv(v_items, v_i), 1.0), J.add(J.getv(v_r, 0.0), 20.0), J.add(J.getv(v_r, 1.0), 3.0), J.getv(game.j_P, "ui5"))
		v_n = J.getv(J.getv(game.j_G, "stock"), v_k)
		v_m = game.stock_system.f_crateMax(v_k)
		game.text_draw.f_txt(J.add(J.add(v_n, "/"), v_m), J.add(J.getv(v_r, 0.0), 100.0), J.add(J.getv(v_r, 1.0), 3.0), (J.getv(game.j_P, "bad") if J.lt(v_n, (v_m * 0.25)) else J.getv(game.j_P, "ui4")), {"align": "r"})
		v_bc = (J.getv(game.j_P, "g2") if J.eq(v_k, "pickle") else (J.getv(game.j_P, "s3") if J.eq(v_k, "yogurt") else ("#6b9ad8" if J.eq(v_k, "ayran") else ("#d8352c" if J.eq(v_k, "tomato") else ("#4f9330" if J.eq(v_k, "pepper") else "#c9772a")))))
		game.counter_draw.f_bar(J.add(J.getv(v_r, 0.0), 20.0), J.add(J.getv(v_r, 1.0), 13.0), 80.0, 5.0, (float(v_n) / float(max(1.0, v_m))), (J.getv(game.j_P, "bad") if J.lt(v_n, (v_m * 0.25)) else v_bc))
		v_i = J.add(v_i, 1.0)
	game.text_draw.f_txt(J.add(J.add(game.localization.f_T("tıkla: +"), J.method(game.j_TUN, "refillPer", [game.j_G])), game.localization.f_T("   çekmece: kapat")), J.add(v_px0, (float(v_pw) / float(2.0))), (J.add(v_py0, v_ph) - 9.0), J.getv(game.j_P, "ui3"), {"align": "c"})
	return null

