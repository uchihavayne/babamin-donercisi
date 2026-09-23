# Drag system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1372
func f_boardAt(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	if (not J.truth(game.math_utils.f_inRect(v_mx, v_my, J.getv(J.getv(game.j_ST, "board"), "x"), J.getv(J.getv(game.j_ST, "board"), "y"), J.getv(J.getv(game.j_ST, "board"), "w"), J.getv(J.getv(game.j_ST, "board"), "h")))):
		return (-J.n(1.0))
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	return game.math_utils.f_clamp(floor((float(((v_mx - J.getv(J.getv(game.j_ST, "board"), "x")) - 4.0)) / float((float((J.getv(J.getv(game.j_ST, "board"), "w") - 8.0)) / float(v_n))))), 0.0, (v_n - 1.0))
	return null

# game.js:1378
func f_returnItem(p_it: Variant = null) -> Variant:
	var v_v: Variant = null
	var v_i: Variant = null
	var v_it: Variant = p_it
	if (not J.truth(v_it)):
		return true
	if J.eq(J.getv(v_it, "kind"), "drink"):
		v_v = J.getv(J.getv(game.j_G, "cups"), J.getv(v_it, "type"))
		if (not J.truth(v_v)):
			J.setv(J.getv(game.j_G, "cups"), J.getv(v_it, "type"), v_it)
			return true
		if J.gt((J.getv(v_it, "fill") if J.truth(J.getv(v_it, "fill")) else 0.0), (J.getv(v_v, "fill") if J.truth(J.getv(v_v, "fill")) else 0.0)):
			J.setv(J.getv(game.j_G, "cups"), J.getv(v_it, "type"), v_it)
		return true
	if J.eq(J.getv(v_it, "kind"), "fbox"):
		if J.ge(J.getv(J.getv(game.j_G, "fbox"), "ready"), 3.0):
			return false
		J.setv(J.getv(game.j_G, "fbox"), "ready", J.add(J.getv(J.getv(game.j_G, "fbox"), "ready"), 1.0))
		return true
	if J.eq(J.getv(v_it, "kind"), "sweet"):
		if J.ge(J.getv(J.getv(game.j_G, "stock"), "sweet"), J.method(game.j_TUN, "sweetMax", [game.j_G])):
			return false
		J.setv(J.getv(game.j_G, "stock"), "sweet", J.add(J.getv(J.getv(game.j_G, "stock"), "sweet"), 1.0))
		return true
	if (J.eq(J.getv(v_it, "kind"), "wrap") or J.eq(J.getv(v_it, "kind"), "plate")):
		v_i = 0.0
		while J.lt(v_i, J.method(game.j_TUN, "boards", [game.j_G])):
			if (not J.truth(J.getv(J.getv(game.j_G, "boards"), v_i))):
				J.setv(J.getv(game.j_G, "boards"), v_i, v_it)
				return true
			v_i = J.add(v_i, 1.0)
		return false
	return false
	return null

# game.js:1403
func f_updateDrag(p_dt: Variant = null) -> Variant:
	var _v: Dictionary = {"d": null, "bi": null, "w": null, "w2": null, "dy": null, "bi2": null, "w3": null, "w4": null, "dt": p_dt}
	_v["d"] = J.getv(game.j_G, "drag")
	if (J.truth(J.getv(game.j_IN, "pressed")) and (not J.truth(_v["d"]))):
		if J.truth(game.debug_draw.f_testHit(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"))):
			return false
		_v["bi"] = game.drag_system.f_boardAt(J.getv(game.j_IN, "downX"), J.getv(game.j_IN, "downY"))
		if J.ge(_v["bi"], 0.0):
			_v["w"] = J.getv(J.getv(game.j_G, "boards"), _v["bi"])
			if (((J.truth(_v["w"]) and not J.eq(J.getv(_v["w"], "kind"), "plate")) and J.eq(J.getv(_v["w"], "state"), "open")) and J.truth(game.recipe_system.f_wrapAny(_v["w"]))):
				J.setv(game.j_G, "drag", J.setv(_v, "d", {"type": "roll", "idx": _v["bi"], "x0": J.getv(game.j_IN, "downX"), "y0": J.getv(game.j_IN, "downY"), "moved": 0.0}))
		if (((((not J.truth(_v["d"])) and J.truth(J.getv(game.j_G, "kedi"))) and (J.eq(J.getv(J.getv(game.j_G, "kedi"), "faz"), "bekle") or J.eq(J.getv(J.getv(game.j_G, "kedi"), "faz"), "gelis"))) and J.gt(J.getv(game.j_G, "meat"), 0.0)) and J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "downX"), J.getv(game.j_IN, "downY"), J.getv(J.getv(game.j_ST, "meat"), "x"), J.getv(J.getv(game.j_ST, "meat"), "y"), J.getv(J.getv(game.j_ST, "meat"), "w"), J.getv(J.getv(game.j_ST, "meat"), "h")))):
			J.setv(game.j_G, "drag", J.setv(_v, "d", {"type": "et", "x": J.getv(game.j_IN, "x"), "y": J.getv(game.j_IN, "y"), "x0": game.j_IN.downX, "y0": game.j_IN.downY, "moved": 0.0}))
			J.method(game.j_SFX, "pick", [])
		if (((not J.truth(_v["d"])) and J.eq(game.equipment_system.f_UV(game.j_G, "paper"), 0.0)) and J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "downX"), J.getv(game.j_IN, "downY"), J.getv(J.getv(game.j_ST, "paper"), "x"), J.getv(J.getv(game.j_ST, "paper"), "y"), J.getv(J.getv(game.j_ST, "paper"), "w"), J.getv(J.getv(game.j_ST, "paper"), "h")))):
			J.setv(game.j_G, "drag", J.setv(_v, "d", {"type": "paper", "x": J.getv(game.j_IN, "x"), "y": J.getv(game.j_IN, "y"), "moved": 0.0}))
			J.method(game.j_SFX, "pick", [])
		if (((((((not J.truth(_v["d"])) and J.truth(J.method(game.j_TUN, "fboxOn", [game.j_G]))) and (not J.truth(J.method(game.j_TUN, "autoBox", [game.j_G])))) and J.eq(J.getv(J.getv(game.j_G, "fbox"), "ready"), 0.0)) and J.eq(J.getv(J.getv(game.j_G, "fbox"), "busy"), 0.0)) and (not J.truth(J.getv(J.getv(game.j_G, "fbox"), "fly")))) and J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "downX"), J.getv(game.j_IN, "downY"), J.getv(J.getv(game.j_ST, "fbox"), "x"), J.getv(J.getv(game.j_ST, "fbox"), "y"), J.getv(J.getv(game.j_ST, "fbox"), "w"), J.getv(J.getv(game.j_ST, "fbox"), "h")))):
			J.setv(game.j_G, "drag", J.setv(_v, "d", {"type": "fbox", "x": J.getv(game.j_IN, "x"), "y": J.getv(game.j_IN, "y"), "moved": 0.0}))
			J.method(game.j_SFX, "pick", [])
		if (J.truth(_v["d"]) and (not J.truth(J.getv(game.j_IN, "released")))):
			return true
	if (not J.truth(_v["d"])):
		return false
	if J.eq(J.getv(_v["d"], "type"), "roll"):
		_v["w2"] = J.getv(J.getv(game.j_G, "boards"), J.getv(_v["d"], "idx"))
		if ((not J.truth(_v["w2"])) or not J.eq(J.getv(_v["w2"], "state"), "open")):
			J.setv(game.j_G, "drag", null)
			return false
		_v["dy"] = (J.getv(_v["d"], "y0") - J.getv(game.j_IN, "y"))
		J.setv(_v["d"], "moved", max(J.getv(_v["d"], "moved"), abs(_v["dy"])))
		J.setv(_v["w2"], "roll", game.math_utils.f_clamp((float(_v["dy"]) / float(26.0)), 0.0, 1.0))
		if (J.gt(J.getv(_v["w2"], "roll"), 0.0) and J.truth(game.f_chance((_v["dt"] * 8.0)))):
			game.effects.f_part({"x": J.add(game.wrap_system.f_boardCX(J.getv(_v["d"], "idx")), game.math_utils.f_rnd((-J.n(14.0)), 14.0)), "y": (game.wrap_system.f_boardCY() - 4.0), "vx": game.math_utils.f_rnd((-J.n(8.0)), 8.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(6.0))), "life": 0.35, "col": "#f0d5a8", "g": 120.0, "sz": 1.0})
		if J.ge(J.getv(_v["w2"], "roll"), 1.0):
			game.f_finishRoll(J.getv(_v["d"], "idx"))
			J.setv(game.j_G, "drag", null)
	else:
		if ((J.eq(J.getv(_v["d"], "type"), "paper") or J.eq(J.getv(_v["d"], "type"), "fbox")) or J.eq(J.getv(_v["d"], "type"), "et")):
			J.setv(_v["d"], "x", J.getv(game.j_IN, "x"))
			J.setv(_v["d"], "y", J.getv(game.j_IN, "y"))
			if _v["d"].type == "et":
				# A stationary click is not a drag, regardless of duration or FPS.
				var distance := Vector2(game.j_IN.x,game.j_IN.y).distance_to(Vector2(_v["d"].x0,_v["d"].y0))
				_v["d"].moved = maxf(_v["d"].moved,distance)
			else: J.setv(_v["d"], "moved", J.add(J.getv(_v["d"], "moved"), 1.0))
	if J.truth(J.getv(game.j_IN, "released")):
		if J.eq(J.getv(_v["d"], "type"), "et"):
			if J.truth(game.event_system.f_kediHit(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"))):
				game.event_system.f_kediBesle()
			else:
				if J.lt(J.getv(_v["d"], "moved"), 4.0):
					game.assembly_system.f_addMeat()
				else:
					J.method(game.j_SFX, "uiBack", [])
					game.session_system.f_say("Eti kedinin üstüne bırak")
			J.setv(game.j_G, "drag", null)
			return true
		if J.eq(J.getv(_v["d"], "type"), "paper"):
			_v["bi2"] = game.drag_system.f_boardAt(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"))
			_v["w3"] = (J.getv(J.getv(game.j_G, "boards"), _v["bi2"]) if J.ge(_v["bi2"], 0.0) else null)
			if ((J.truth(_v["w3"]) and J.eq(J.getv(_v["w3"], "state"), "rolled")) and J.truth(J.getv(_v["w3"], "burnt"))):
				J.method(game.j_SFX, "bad", [])
				game.session_system.f_say("Yanmış dürüm satılmaz — çöpe at")
			else:
				if ((((J.truth(_v["w3"]) and J.eq(J.getv(_v["w3"], "state"), "rolled")) and J.truth(J.method(game.j_TUN, "grillOn", [game.j_G]))) and (not J.truth(J.getv(_v["w3"], "grilled")))) and (not J.truth(game.grill_system.f_grillTikali()))):
					J.method(game.j_SFX, "bad", [])
					game.session_system.f_say("Önce ızgaraya at — kâğıt sonra")
				else:
					if (J.truth(_v["w3"]) and J.eq(J.getv(_v["w3"], "state"), "rolled")):
						game.wrap_system.f_applyPaper(_v["bi2"])
					else:
						J.method(game.j_SFX, "uiBack", [])
						game.session_system.f_say("Kağıdı sarılmış dürümün üstüne bırak")
		else:
			if J.eq(J.getv(_v["d"], "type"), "fbox"):
				if J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.getv(J.getv(game.j_ST, "friesT"), "x") - 4.0), (J.getv(J.getv(game.j_ST, "friesT"), "y") - 6.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "w"), 8.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "h"), 12.0))):
					game.fries_box_system.f_fboxDoldur(false)
				else:
					J.method(game.j_SFX, "uiBack", [])
					game.session_system.f_say("Kutuyu patates tepsisine bırak")
			else:
				if J.eq(J.getv(_v["d"], "type"), "roll"):
					_v["w4"] = J.getv(J.getv(game.j_G, "boards"), J.getv(_v["d"], "idx"))
					if (J.truth(_v["w4"]) and J.eq(J.getv(_v["w4"], "state"), "open")):
						J.setv(_v["w4"], "roll", 0.0)
						if J.lt(J.getv(_v["d"], "moved"), 4.0):
							J.method(game.j_SFX, "ui", [])
						else:
							game.session_system.f_say("Sarmak için yukarı doğru sürükle")
		J.setv(game.j_G, "drag", null)
	return true
	return null

# game.js:1983
func f_spawnFlyIng(p_kind: Variant = null, p_n: Variant = null) -> Variant:
	var v_dst: Variant = null
	var v_i: Variant = null
	var v_kind: Variant = p_kind
	var v_n: Variant = p_n
	v_dst = (J.getv(game.j_ST, "pickle") if J.eq(v_kind, "pickle") else (J.getv(game.j_ST, "yogurt") if J.eq(v_kind, "yogurt") else (J.getv(game.j_ST, "ayran") if J.eq(v_kind, "ayran") else (J.getv(game.j_ST, "garnish") if (J.eq(v_kind, "tomato") or J.eq(v_kind, "pepper")) else J.getv(game.j_ST, "sweet")))))
	v_i = 0.0
	while (J.lt(v_i, v_n) and J.lt(J.getv(J.getv(game.j_G, "flyIng"), "length"), 24.0)):
		J.method(J.getv(game.j_G, "flyIng"), "push", [{"kind": v_kind, "t": ((-J.n(v_i)) * 0.09), "x0": J.add(J.add(J.getv(J.getv(game.j_ST, "crate"), "x"), 10.0), game.math_utils.f_rnd((-J.n(5.0)), 5.0)), "y0": J.add(J.getv(J.getv(game.j_ST, "crate"), "y"), 4.0), "x1": J.add(J.getv(v_dst, "x"), game.math_utils.f_rnd(7.0, (J.getv(v_dst, "w") - 9.0))), "y1": J.add(J.getv(v_dst, "y"), game.math_utils.f_rnd(10.0, 20.0)), "sp": game.math_utils.f_rnd(0.9, 1.15), "rot": game.math_utils.f_rnd(0.0, 6.0)}])
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1997
func f_updateFly(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_bc: Variant = null
	var v_ks: Variant = null
	var v_k: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(J.getv(game.j_G, "flyIng"), "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_f = J.getv(J.getv(game.j_G, "flyIng"), v_i)
		J.setv(v_f, "t", J.add(J.getv(v_f, "t"), ((v_dt * 2.1) * J.getv(v_f, "sp"))))
		if J.ge(J.getv(v_f, "t"), 1.0):
			J.method(J.getv(game.j_G, "flyIng"), "splice", [v_i, 1.0])
			J.setv(J.getv(game.j_G, "fxTray"), J.getv(v_f, "kind"), 1.0)
			J.method(game.j_SFX, "pop", [])
			v_bc = ([J.getv(game.j_P, "g1"), J.getv(game.j_P, "g0")] if J.eq(J.getv(v_f, "kind"), "pickle") else (["#e89a3c", "#ffd07a"] if J.eq(J.getv(v_f, "kind"), "sweet") else (["#e2483a", "#f07a68"] if J.eq(J.getv(v_f, "kind"), "tomato") else (["#5d9a24", "#8fc93a"] if J.eq(J.getv(v_f, "kind"), "pepper") else [J.getv(game.j_P, "s0"), "#ffffff"]))))
			game.effects.f_burst(J.getv(v_f, "x1"), J.getv(v_f, "y1"), 3.0, v_bc, {"spMax": 26.0, "up": 12.0, "sz": 1.0, "lifeMax": 0.35})
		v_i = (v_i - 1.0)
	v_ks = ["pickle", "yogurt", "fries", "meat", "ayran", "sweet", "tomato", "pepper"]
	v_k = 0.0
	while J.lt(v_k, J.getv(v_ks, "length")):
		if J.gt(J.getv(J.getv(game.j_G, "fxTray"), J.getv(v_ks, v_k)), 0.0):
			J.setv(J.getv(game.j_G, "fxTray"), J.getv(v_ks, v_k), max(0.0, (J.getv(J.getv(game.j_G, "fxTray"), J.getv(v_ks, v_k)) - (v_dt * 3.2))))
		v_k = J.add(v_k, 1.0)
	J.setv(J.getv(game.j_G, "stockAnim"), "pickle", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "pickle"), J.getv(J.getv(game.j_G, "stock"), "pickle"), (v_dt * 22.0)))
	J.setv(J.getv(game.j_G, "stockAnim"), "yogurt", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "yogurt"), J.getv(J.getv(game.j_G, "stock"), "yogurt"), (v_dt * 22.0)))
	J.setv(J.getv(game.j_G, "stockAnim"), "ayran", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "ayran"), J.getv(J.getv(game.j_G, "stock"), "ayran"), (v_dt * 22.0)))
	J.setv(J.getv(game.j_G, "stockAnim"), "sweet", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "sweet"), J.getv(J.getv(game.j_G, "stock"), "sweet"), (v_dt * 22.0)))
	J.setv(J.getv(game.j_G, "stockAnim"), "tomato", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "tomato"), J.getv(J.getv(game.j_G, "stock"), "tomato"), (v_dt * 22.0)))
	J.setv(J.getv(game.j_G, "stockAnim"), "pepper", game.math_utils.f_approach(J.getv(J.getv(game.j_G, "stockAnim"), "pepper"), J.getv(J.getv(game.j_G, "stock"), "pepper"), (v_dt * 22.0)))
	return null
