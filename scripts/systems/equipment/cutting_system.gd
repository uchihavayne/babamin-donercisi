# Cutting system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# Meat units per successful knife stroke; tray capacity still applies.
const MEAT_PER_CUT := 3

# game.js:246
func f_updateShave(p_dt: Variant = null) -> Variant:
	var v_sh: Variant = null
	var v_s: Variant = null
	var v_over: Variant = null
	var v_d: Variant = null
	var v_need: Variant = null
	var v_dt: Variant = p_dt
	v_sh = J.getv(game.j_G, "shave")
	v_s = J.getv(game.j_G, "spit")
	J.setv(v_s, "rot", J.add(J.getv(v_s, "rot"), (v_dt * 1.15)))
	if J.gt(J.getv(v_s, "sliceT"), 0.0):
		J.setv(v_s, "sliceT", max(0.0, (J.getv(v_s, "sliceT") - (v_dt * 5.0))))
	if J.truth(J.getv(v_s, "swipe")):
		J.setv(J.getv(v_s, "swipe"), "t", (J.getv(J.getv(v_s, "swipe"), "t") - (v_dt * 5.0)))
		if J.le(J.getv(J.getv(v_s, "swipe"), "t"), 0.0):
			J.setv(v_s, "swipe", null)
	if J.gt(J.getv(v_s, "cutDepth"), 0.0):
		J.setv(v_s, "cutDepth", max(0.0, (J.getv(v_s, "cutDepth") - (v_dt * 5.0))))
	if J.gt(J.getv(v_sh, "act"), 0.0):
		J.setv(v_sh, "act", (J.getv(v_sh, "act") - v_dt))
	if J.gt(J.getv(v_sh, "cd"), 0.0):
		J.setv(v_sh, "cd", (J.getv(v_sh, "cd") - v_dt))
	v_over = ((not J.truth(game.debug_draw.f_testPanelOpen())) if J.truth(game.f_hitST("spit")) else game.f_hitST("spit"))
	if J.truth(v_over):
		if J.ge(J.getv(v_sh, "lastY"), 0.0):
			v_d = abs((J.getv(game.j_IN, "y") - J.getv(v_sh, "lastY")))
			if J.gt(v_d, 0.4):
				J.setv(v_sh, "travel", J.add(J.getv(v_sh, "travel"), min(v_d, 55.0)))
				J.setv(v_sh, "act", 0.25)
				if J.truth(game.f_chance((v_d * 0.02))):
					game.effects.f_part({"x": (J.getv(J.getv(game.j_LAY, "spit"), "cx") - 14.0), "y": J.add(J.getv(game.j_IN, "y"), game.math_utils.f_rnd((-J.n(3.0)), 3.0)), "vx": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(6.0))), "vy": game.math_utils.f_rnd((-J.n(18.0)), 6.0), "life": 0.4, "col": "#e0a860", "g": 220.0, "sz": 1.0, "floor": J.add(J.getv(J.getv(game.j_ST, "meat"), "y"), game.math_utils.f_rnd(4.0, 12.0))})
		J.setv(v_sh, "lastY", J.getv(game.j_IN, "y"))
		v_need = J.method(game.j_TUN, "shaveDist", [game.j_G])
		if (J.ge(J.getv(v_sh, "travel"), v_need) and J.le(J.getv(v_sh, "cd"), 0.0)):
			J.setv(v_sh, "travel", (J.getv(v_sh, "travel") - v_need))
			J.setv(v_sh, "cd", J.method(game.j_TUN, "shaveCd", [game.j_G]))
			game.f_doSlice()
			if J.gt(J.getv(v_sh, "travel"), (v_need * 2.0)):
				J.setv(v_sh, "travel", (v_need * 2.0))
	else:
		J.setv(v_sh, "lastY", (-J.n(1.0)))
		J.setv(v_sh, "travel", (J.getv(v_sh, "travel") * pow(0.2, v_dt)))
	if (J.truth(J.method(game.j_TUN, "autoShave", [game.j_G])) and J.lt(J.getv(game.j_G, "meat"), J.method(game.j_TUN, "meatCap", []))):
		J.setv(v_sh, "auto", J.add(J.getv(v_sh, "auto"), v_dt))
		if J.gt(J.getv(v_sh, "auto"), J.method(game.j_TUN, "autoShaveCd", [])):
			J.setv(v_sh, "auto", 0.0)
			game.f_doSlice()
	return null

# game.js:285
func f_doSlice() -> Variant:
	var v_cx: Variant = null
	var v_sy: Variant = null
	var v_i: Variant = null
	var v_i2: Variant = null
	if J.ge(J.getv(game.j_G, "meat"), J.method(game.j_TUN, "meatCap", [])):
		J.setv(game.j_G, "meat", J.method(game.j_TUN, "meatCap", []))
		return null
	var cut_amount := minf(game.MEAT_PER_CUT, float(J.method(game.j_TUN, "meatCap", [])) - float(game.j_G.meat))
	game.j_G.meat += cut_amount
	J.setv(J.getv(game.j_G, "spit"), "sliceT", 1.0)
	J.setv(J.getv(game.j_G, "spit"), "cutDepth", 5.0)
	J.setv(J.getv(game.j_G, "spit"), "swipe", {"y": game.math_utils.f_clamp(J.getv(game.j_IN, "y"), J.add(J.getv(J.getv(game.j_LAY, "spit"), "top"), 8.0), (J.getv(J.getv(game.j_LAY, "spit"), "bot") - 12.0)), "t": 1.0})
	J.setv(J.getv(game.j_G, "chef"), "mode", "slice")
	J.setv(J.getv(game.j_G, "chef"), "armT", 0.0)
	J.method(game.j_SFX, "slice", [])
	v_cx = J.getv(J.getv(game.j_LAY, "spit"), "cx")
	v_sy = game.math_utils.f_clamp(J.getv(game.j_IN, "y"), J.add(J.getv(J.getv(game.j_LAY, "spit"), "top"), 12.0), (J.getv(J.getv(game.j_LAY, "spit"), "bot") - 20.0))
	# One knife stroke releases a small bundle; only actual stock flies to the tray.
	for strip in int(cut_amount):
		game.cutting_system.f_spawnFlyMeat(((v_cx - 18.0) - game.math_utils.f_rnd(0.0, 4.0)), v_sy + (strip - (cut_amount - 1.0) * 0.5) * 4.0)
	v_i = 0.0
	while J.lt(v_i, 2.0):
		game.effects.f_part({"x": (v_cx - 12.0), "y": J.add(v_sy, game.math_utils.f_rnd((-J.n(3.0)), 3.0)), "vx": game.math_utils.f_rnd((-J.n(30.0)), (-J.n(8.0))), "vy": game.math_utils.f_rnd((-J.n(26.0)), 2.0), "life": game.math_utils.f_rnd(0.42, 0.7), "type": "et", "k": game.math_utils.f_rnd(1.0, 900.0), "sc": game.math_utils.f_rnd(0.85, 1.15), "g": 300.0, "floor": J.add(J.getv(J.getv(game.j_ST, "meat"), "y"), game.math_utils.f_rnd(4.0, 14.0)), "bounce": 0.22})
		v_i = J.add(v_i, 1.0)
	v_i2 = 0.0
	while J.lt(v_i2, 2.0):
		game.effects.f_part({"x": (v_cx - 12.0), "y": J.add(v_sy, game.math_utils.f_rnd((-J.n(4.0)), 4.0)), "vx": game.math_utils.f_rnd((-J.n(34.0)), (-J.n(10.0))), "vy": game.math_utils.f_rnd((-J.n(30.0)), 2.0), "life": game.math_utils.f_rnd(0.3, 0.55), "col": game.math_utils.f_pick(["#c98436", "#eeb464", "#8a4f1e"]), "g": 320.0, "sz": 1.0, "floor": J.add(J.getv(J.getv(game.j_ST, "meat"), "y"), game.math_utils.f_rnd(4.0, 14.0)), "bounce": 0.25})
		v_i2 = J.add(v_i2, 1.0)
	if J.truth(game.f_chance(0.5)):
		game.effects.f_part({"x": (v_cx - 10.0), "y": v_sy, "vx": game.math_utils.f_rnd((-J.n(26.0)), (-J.n(6.0))), "vy": game.math_utils.f_rnd((-J.n(40.0)), (-J.n(18.0))), "life": 0.4, "col": "#ffe6ae", "g": 300.0, "sz": 1.0})
	return null

# game.js:327
func f_spawnFlyMeat(p_x0: Variant = null, p_y0: Variant = null) -> Variant:
	var v_hedefX: Variant = null
	var v_doluluk: Variant = null
	var v_hedefY: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	if J.gt(J.getv(J.getv(game.j_G, "flyMeat"), "length"), 14.0):
		return null
	v_hedefX = J.add(J.getv(J.getv(game.j_ST, "meat"), "x"), game.math_utils.f_rnd(7.0, (J.getv(J.getv(game.j_ST, "meat"), "w") - 8.0)))
	v_doluluk = game.math_utils.f_clamp((float(J.getv(game.j_G, "meat")) / float(J.method(game.j_TUN, "meatCap", []))), 0.0, 1.0)
	v_hedefY = ((J.add(J.getv(J.getv(game.j_ST, "meat"), "y"), J.getv(J.getv(game.j_ST, "meat"), "h")) - 9.0) - (v_doluluk * (J.getv(J.getv(game.j_ST, "meat"), "h") - 16.0)))
	J.method(J.getv(game.j_G, "flyMeat"), "push", [{"t": 0.0, "x0": v_x0, "y0": v_y0, "x1": v_hedefX, "y1": v_hedefY, "k": (int(J.n((game.random_unit() * 1000.0))) | int(J.n(0.0))), "sz": game.math_utils.f_rnd(0.35, 0.95), "don": game.math_utils.f_rnd(0.0, 6.28), "donHiz": game.math_utils.f_rnd((-J.n(9.0)), 9.0), "sp": game.math_utils.f_rnd(1.15, 1.5), "yay": game.math_utils.f_rnd(10.0, 18.0), "savrul": game.math_utils.f_rnd(9.0, 16.0)}])
	return null

# game.js:347
func f_updateFlyMeat(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(J.getv(game.j_G, "flyMeat"), "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_f = J.getv(J.getv(game.j_G, "flyMeat"), v_i)
		J.setv(v_f, "t", J.add(J.getv(v_f, "t"), (v_dt * J.getv(v_f, "sp"))))
		J.setv(v_f, "don", J.add(J.getv(v_f, "don"), (J.getv(v_f, "donHiz") * v_dt)))
		if J.ge(J.getv(v_f, "t"), 1.0):
			J.method(J.getv(game.j_G, "flyMeat"), "splice", [v_i, 1.0])
			J.setv(J.getv(game.j_G, "fxTray"), "meat", 1.0)
			J.method(game.j_SFX, "pop", [])
			game.effects.f_burst(J.getv(v_f, "x1"), J.getv(v_f, "y1"), 3.0, ["#c98436", "#eeb464", "#8a4f1e"], {"spMax": 22.0, "up": 10.0, "sz": 1.0, "lifeMax": 0.3})
		v_i = (v_i - 1.0)
	return null

