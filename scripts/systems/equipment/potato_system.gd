# Potato system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1556
func f_potatoTake() -> Variant:
	if (J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) or J.truth(J.getv(game.j_G, "flyP"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Tahtada patates var")
		return null
	J.setv(game.j_G, "flyP", {"t": 0.0, "x0": J.add(J.getv(J.getv(game.j_ST, "potato"), "x"), 14.0), "y0": J.add(J.getv(J.getv(game.j_ST, "potato"), "y"), 8.0), "x1": (J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), (float(J.getv(J.getv(game.j_ST, "cut"), "w")) / float(2.0))) - 6.0), "y1": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 19.0)})
	J.method(game.j_SFX, "sack", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "potato"), "x"), 14.0), J.add(J.getv(J.getv(game.j_ST, "potato"), "y"), 8.0), 4.0, ["#b98b46", "#d8ab63"], {"spMax": 30.0, "up": 12.0})
	return null

# game.js:1564
func f_slashAt() -> Variant:
	var v_c: Variant = null
	var v_mx: Variant = null
	var v_taban: Variant = null
	var v_i: Variant = null
	v_c = J.getv(game.j_G, "cut")
	if (not J.truth(J.getv(v_c, "slash"))):
		J.setv(v_c, "slash", [])
	v_mx = (J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), (float(J.getv(J.getv(game.j_ST, "cut"), "w")) / float(2.0))) - 6.0)
	J.setv(v_c, "yon", ((-J.n(1.0)) if J.eq(J.getv(v_c, "yon"), 1.0) else 1.0))
	v_taban = ((-J.n(0.72)) if J.gt(J.getv(v_c, "yon"), 0.0) else (-J.n(2.42)))
	J.method(J.getv(v_c, "slash"), "push", [{"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(6.0)), 8.0)), "y": J.add(J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 18.0), game.math_utils.f_rnd((-J.n(3.0)), 3.0)), "aci": J.add(v_taban, game.math_utils.f_rnd((-J.n(0.26)), 0.26)), "boy": game.math_utils.f_rnd(24.0, 34.0), "t": 1.0}])
	J.setv(v_c, "sayac", J.add((J.getv(v_c, "sayac") if J.truth(J.getv(v_c, "sayac")) else 0.0), 1.0))
	if J.eq(fmod(J.n(J.getv(v_c, "sayac")), J.n(3.0)), 0.0):
		J.method(J.getv(v_c, "slash"), "push", [{"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(4.0)), 6.0)), "y": J.add(J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 18.0), game.math_utils.f_rnd((-J.n(2.0)), 2.0)), "aci": J.add(((-J.n(2.42)) if J.gt(J.getv(v_c, "yon"), 0.0) else (-J.n(0.72))), game.math_utils.f_rnd((-J.n(0.2)), 0.2)), "boy": game.math_utils.f_rnd(20.0, 28.0), "t": 0.88}])
	while J.gt(J.getv(J.getv(v_c, "slash"), "length"), 8.0):
		J.method(J.getv(v_c, "slash"), "shift", [])
	game.effects.f_shake(0.1)
	J.method(game.j_SFX, "potato", [])
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.effects.f_part({"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(4.0)), 8.0)), "y": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 17.0), "vx": game.math_utils.f_rnd((-J.n(46.0)), 46.0), "vy": game.math_utils.f_rnd((-J.n(58.0)), (-J.n(20.0))), "life": game.math_utils.f_rnd(0.28, 0.5), "col": game.math_utils.f_pick(["#f2e0a8", "#ffe9a3", "#dba53a", "#b98b46"]), "g": 320.0, "sz": 1.0, "floor": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 25.0), "bounce": 0.2})
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1607
func f_cutClick() -> Variant:
	var v_c: Variant = null
	v_c = J.getv(game.j_G, "cut")
	if (not J.truth(J.getv(v_c, "potato"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce çuvaldan patates al")
		return null
	J.setv(v_c, "cutting", true)
	J.setv(v_c, "hold", 0.25)
	game.potato_system.f_slashAt()
	return null

# game.js:1613
func f_updateCut(p_dt: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_si: Variant = null
	var v_dt: Variant = p_dt
	v_c = J.getv(game.j_G, "cut")
	if J.gt(J.getv(v_c, "hold"), 0.0):
		J.setv(v_c, "hold", (J.getv(v_c, "hold") - v_dt))
	else:
		J.setv(v_c, "cutting", false)
	if J.truth(J.getv(v_c, "slash")):
		v_si = (J.getv(J.getv(v_c, "slash"), "length") - 1.0)
		while J.ge(v_si, 0.0):
			J.setv(J.getv(J.getv(v_c, "slash"), v_si), "t", (J.getv(J.getv(J.getv(v_c, "slash"), v_si), "t") - (v_dt * 6.5)))
			if J.le(J.getv(J.getv(J.getv(v_c, "slash"), v_si), "t"), 0.0):
				J.method(J.getv(v_c, "slash"), "splice", [v_si, 1.0])
			v_si = (v_si - 1.0)
	if ((J.truth(J.getv(game.j_IN, "down")) and J.truth(game.f_hitST("cut"))) and J.truth(J.getv(v_c, "potato"))):
		J.setv(v_c, "cutting", true)
		J.setv(v_c, "hold", 0.12)
		J.setv(v_c, "chopT", ((J.getv(v_c, "chopT") if J.truth(J.getv(v_c, "chopT")) else 0.0) - v_dt))
		if J.le(J.getv(v_c, "chopT"), 0.0):
			J.setv(v_c, "chopT", 0.17)
			game.potato_system.f_slashAt()
	if (J.truth(J.getv(v_c, "potato")) and J.truth(J.getv(v_c, "cutting"))):
		J.setv(v_c, "prog", J.add(J.getv(v_c, "prog"), (float(v_dt) / float(J.method(game.j_TUN, "cutTime", [game.j_G])))))
		if J.ge(J.getv(v_c, "prog"), 1.0):
			J.setv(v_c, "prog", 0.0)
			J.setv(v_c, "potato", false)
			J.setv(v_c, "cutting", false)
			J.setv(v_c, "raw", J.add(J.getv(v_c, "raw"), J.method(game.j_TUN, "cutYield", [game.j_G])))
			game.event_system.f_addTrash(game.j_TRASH_PER_PEEL)
			game.event_system.f_copaAt(J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), (float(J.getv(J.getv(game.j_ST, "cut"), "w")) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 16.0), ["#b98b46", "#8a6432", "#d8ab63"])
			J.method(game.j_SFX, "drop", [])
			game.effects.f_burst((J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), J.getv(J.getv(game.j_ST, "cut"), "w")) - 10.0), J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 26.0), 8.0, ["#f2e0a8", "#ffe9a3"], {"spMax": 50.0, "up": 20.0})
			game.equipment_system.f_checkAuto()
	if J.truth(J.method(game.j_TUN, "autoCut", [game.j_G])):
		J.setv(v_c, "autoT", J.add(J.getv(v_c, "autoT"), v_dt))
		if J.gt(J.getv(v_c, "autoT"), 0.35):
			J.setv(v_c, "autoT", 0.0)
			if ((not J.truth(J.getv(v_c, "potato"))) and J.lt(J.getv(v_c, "raw"), (J.method(game.j_TUN, "fryCap", [game.j_G]) * 2.0))):
				J.setv(v_c, "potato", true)
				J.setv(v_c, "prog", 0.0)
				J.method(game.j_SFX, "sack", [])
			else:
				if J.truth(J.getv(v_c, "potato")):
					J.setv(v_c, "cutting", true)
					J.setv(v_c, "hold", 0.2)
					game.potato_system.f_slashAt()
	return null

# game.js:1654
func f_fryerClick() -> Variant:
	var v_f: Variant = null
	var v_n: Variant = null
	v_f = J.getv(game.j_G, "fryer")
	if (J.truth(game.event_system.f_kesintiVarMi()) and not J.eq(J.getv(v_f, "state"), "done")):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Elektrik yok — fritöz çalışmıyor")
		return null
	if J.eq(J.getv(v_f, "state"), "done"):
		game.potato_system.f_fryTake()
		return null
	if J.eq(J.getv(v_f, "state"), "fry"):
		game.session_system.f_say("Kızarıyor…")
		return null
	if J.le(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Doğranmış patates yok!")
		return null
	v_n = min(J.method(game.j_TUN, "fryCap", [game.j_G]), J.getv(J.getv(game.j_G, "cut"), "raw"))
	J.setv(J.getv(game.j_G, "cut"), "raw", (J.getv(J.getv(game.j_G, "cut"), "raw") - v_n))
	J.setv(v_f, "state", "fry")
	J.setv(v_f, "t", 0.0)
	J.setv(v_f, "dur", J.method(game.j_TUN, "fryTime", [game.j_G]))
	J.setv(v_f, "load", v_n)
	J.setv(v_f, "prog", 0.0)
	J.method(game.j_SFX, "basket", [])
	return null

# game.js:1667
func f_fryTake() -> Variant:
	var v_f: Variant = null
	var v_n: Variant = null
	v_f = J.getv(game.j_G, "fryer")
	v_n = min(J.getv(v_f, "load"), (J.method(game.j_TUN, "friesCap", []) - J.getv(game.j_G, "friesTray")))
	J.setv(game.j_G, "friesTray", J.add(J.getv(game.j_G, "friesTray"), v_n))
	J.setv(v_f, "state", "idle")
	J.setv(v_f, "load", 0.0)
	J.setv(v_f, "t", 0.0)
	J.method(game.j_SFX, "drop", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "fryer"), "x"), 20.0), J.add(J.getv(J.getv(game.j_ST, "fryer"), "y"), 14.0), 10.0, [J.getv(game.j_P, "p0"), J.getv(game.j_P, "p1"), "#fff"], {"spMax": 60.0, "up": 20.0})
	game.equipment_system.f_checkAuto()
	return null

# game.js:1676
func f_updateFryer(p_dt: Variant = null) -> Variant:
	var v_f: Variant = null
	var v_dt: Variant = p_dt
	v_f = J.getv(game.j_G, "fryer")
	if J.truth(game.event_system.f_kesintiVarMi()):
		if J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function"):
			game.f_sndLoop("fry", false)
		return null
	if J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function"):
		game.f_sndLoop("fry", (J.eq(J.getv(game.j_G, "scene"), "play") if J.eq(J.getv(v_f, "state"), "fry") else J.eq(J.getv(v_f, "state"), "fry")))
	J.setv(v_f, "basketY", game.math_utils.f_approach(J.getv(v_f, "basketY"), ((-J.n(5.0)) if J.eq(J.getv(v_f, "state"), "idle") else 7.0), (v_dt * 26.0)))
	if J.eq(J.getv(v_f, "state"), "idle"):
		if ((J.truth(J.method(game.j_TUN, "autoFry", [game.j_G])) and J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0)) and J.lt(J.getv(game.j_G, "friesTray"), J.method(game.j_TUN, "friesCap", []))):
			game.potato_system.f_fryerClick()
		return null
	J.setv(v_f, "t", J.add(J.getv(v_f, "t"), v_dt))
	J.setv(v_f, "prog", game.math_utils.f_clamp((float(J.getv(v_f, "t")) / float(J.getv(v_f, "dur"))), 0.0, 1.0))
	if J.eq(J.getv(v_f, "state"), "fry"):
		if J.truth(game.f_chance((v_dt * 14.0))):
			game.effects.f_part({"x": J.add(J.add(J.getv(J.getv(game.j_ST, "fryer"), "x"), 12.0), game.math_utils.f_rnd(0.0, (J.getv(J.getv(game.j_ST, "fryer"), "w") - 24.0))), "y": J.add(J.getv(J.getv(game.j_ST, "fryer"), "y"), 20.0), "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(8.0))), "life": 0.55, "col": "rgba(255,240,200,.45)", "g": (-J.n(14.0)), "sz": 1.0})
		if (not (J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function") and J.truth(game.f_sndLoop("fry", true)))):
			J.setv(v_f, "sz", J.add((J.getv(v_f, "sz") if J.truth(J.getv(v_f, "sz")) else 0.0), v_dt))
			if J.gt(J.getv(v_f, "sz"), 1.4):
				J.setv(v_f, "sz", 0.0)
				J.method(game.j_SFX, "fry", [])
	if (J.eq(J.getv(v_f, "state"), "fry") and J.ge(J.getv(v_f, "t"), J.getv(v_f, "dur"))):
		J.setv(v_f, "state", "done")
		J.method(game.j_SFX, "bell", [])
	if (J.eq(J.getv(v_f, "state"), "done") and J.truth(J.method(game.j_TUN, "autoFry", [game.j_G]))):
		game.potato_system.f_fryTake()
	return null

