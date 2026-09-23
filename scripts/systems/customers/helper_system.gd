# Helper system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2372
func f_motoBroken() -> Variant:
	return (not (not (J.truth(J.getv(game.j_G, "moto")) and J.truth(J.getv(J.getv(game.j_G, "moto"), "broken")))))
	return null

# game.js:2373
func f_motoClick() -> Variant:
	var v_c: Variant = null
	if (not J.truth(game.helper_system.f_motoBroken())):
		return false
	v_c = J.getv(J.getv(game.j_G, "moto"), "cost")
	if J.gt(J.getv(J.getv(game.j_G, "moto"), "ask"), 0.0):
		if J.lt(J.getv(game.j_G, "money"), v_c):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say(J.add(J.add(game.localization.f_T("Para yetmiyor — $"), game.math_utils.f_fmtMoney(v_c)), game.localization.f_T(" lazım")))
			return true
		J.setv(game.j_G, "money", (J.getv(game.j_G, "money") - v_c))
		J.setv(J.getv(game.j_G, "moto"), "broken", false)
		J.setv(J.getv(game.j_G, "moto"), "ask", 0.0)
		J.setv(J.getv(game.j_G, "moto"), "fixT", 1.6)
		J.setv(J.getv(game.j_G, "stats"), "moto", J.add((J.getv(J.getv(game.j_G, "stats"), "moto") if J.truth(J.getv(J.getv(game.j_G, "stats"), "moto")) else 0.0), 1.0))
		J.method(game.j_SFX, "cash", [])
		J.method(game.j_SFX, "moto", [])
		game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 24.0), 214.0, 16.0, ["#9aa3ab", "#ffd75e", "#ffffff"], {"spMax": 70.0, "up": 26.0, "sz": 2.0})
		game.effects.f_ftext("MOTOR TAMİR!", J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 24.0), 190.0, J.getv(game.j_P, "ok"), {"sc": 1.0, "life": 1.6})
		game.session_system.f_say("Dayı yine yollarda")
		game.save_system.f_saveAll()
		return true
	J.setv(J.getv(game.j_G, "moto"), "ask", 3.0)
	J.method(game.j_SFX, "ui", [])
	game.session_system.f_say(J.add(J.add(game.localization.f_T("Motor bozuk — tamir $"), game.math_utils.f_fmtMoney(v_c)), game.localization.f_T(" (tekrar tıkla)")))
	return true
	return null

# game.js:2393
func f_updateMoto(p_dt: Variant = null) -> Variant:
	var v_dt: Variant = p_dt
	if (not J.truth(J.getv(game.j_G, "moto"))):
		return null
	if J.gt(J.getv(J.getv(game.j_G, "moto"), "ask"), 0.0):
		J.setv(J.getv(game.j_G, "moto"), "ask", (J.getv(J.getv(game.j_G, "moto"), "ask") - v_dt))
	if J.gt(J.getv(J.getv(game.j_G, "moto"), "fixT"), 0.0):
		J.setv(J.getv(game.j_G, "moto"), "fixT", (J.getv(J.getv(game.j_G, "moto"), "fixT") - v_dt))
	if J.gt(J.getv(J.getv(game.j_G, "moto"), "newT"), 0.0):
		J.setv(J.getv(game.j_G, "moto"), "newT", (J.getv(J.getv(game.j_G, "moto"), "newT") - v_dt))
		if J.le(J.getv(J.getv(game.j_G, "moto"), "newT"), 0.0):
			J.method(game.j_SFX, "fail", [])
			game.session_system.f_say(game.math_utils.f_pick(game.j_LINES_MOTO))
	if (J.truth(game.helper_system.f_motoBroken()) and J.truth(game.f_chance((v_dt * 1.4)))):
		game.effects.f_part({"x": J.add(J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 18.0), game.math_utils.f_rnd((-J.n(6.0)), 6.0)), "y": 214.0, "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(8.0))), "life": 0.9, "col": "rgba(90,90,96,.5)", "g": (-J.n(10.0)), "sz": 1.0})
	return null

# game.js:2442
func f_uncleReady() -> Variant:
	return (J.eq(J.getv(game.j_G, "scene"), "play") if (J.gt(J.getv(J.getv(game.j_G, "uncle"), "left"), 0.0) and J.le(J.getv(game.j_G, "timeLeft"), 20.0)) else (J.le(J.getv(game.j_G, "timeLeft"), 20.0) if J.gt(J.getv(J.getv(game.j_G, "uncle"), "left"), 0.0) else J.gt(J.getv(J.getv(game.j_G, "uncle"), "left"), 0.0)))
	return null

# game.js:2443
func f_uncleUse() -> Variant:
	var v_target: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	var v_it: Variant = null
	if (not J.truth(game.helper_system.f_uncleReady())):
		if J.eq(J.method(game.j_TUN, "uncleUses", [game.j_G]), 0.0):
			game.session_system.f_say("Dayı için upgrade al!")
		else:
			if J.le(J.getv(J.getv(game.j_G, "uncle"), "left"), 0.0):
				game.session_system.f_say("Dayının hakkı kalmadı")
			else:
				game.session_system.f_say("Dayı son 20 saniyede yardım eder")
		J.method(game.j_SFX, "bad", [])
		return null
	v_target = null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		if J.eq(J.getv(J.getv(J.getv(game.j_G, "customers"), v_i), "state"), "wait"):
			v_target = J.getv(J.getv(game.j_G, "customers"), v_i)
			break
		v_i = J.add(v_i, 1.0)
	if (not J.truth(v_target)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Bekleyen müşteri yok")
		return null
	J.setv(J.getv(game.j_G, "uncle"), "left", (J.getv(J.getv(game.j_G, "uncle"), "left") - 1.0))
	J.setv(J.getv(game.j_G, "uncle"), "flashT", 1.0)
	J.setv(J.getv(game.j_G, "stats"), "dayi", J.add((J.getv(J.getv(game.j_G, "stats"), "dayi") if J.truth(J.getv(J.getv(game.j_G, "stats"), "dayi")) else 0.0), 1.0))
	J.setv(J.getv(game.j_G, "chef"), "mode", "happy")
	J.setv(J.getv(game.j_G, "chef"), "armT", 0.0)
	v_j = 0.0
	while J.lt(v_j, J.getv(J.getv(v_target, "items"), "length")):
		if J.truth(J.getv(J.getv(v_target, "done"), v_j)):
			v_j = J.add(v_j, 1.0)
			continue
		J.setv(J.getv(v_target, "done"), v_j, true)
		v_it = J.getv(J.getv(v_target, "items"), v_j)
		J.setv(v_target, "earn", J.add((J.getv(v_target, "earn") if J.truth(J.getv(v_target, "earn")) else 0.0), game.recipe_system.f_itemPrice(({"kind": "wrap", "grilled": J.method(game.j_TUN, "grillOn", [game.j_G])} if J.eq(J.getv(v_it, "kind"), "wrap") else v_it), game.j_G)))
		if J.eq(J.getv(v_it, "kind"), "wrap"):
			J.setv(J.getv(game.j_G, "stat"), "wraps", J.add(J.getv(J.getv(game.j_G, "stat"), "wraps"), 1.0))
		else:
			if J.eq(J.getv(v_it, "kind"), "plate"):
				J.setv(J.getv(game.j_G, "stat"), "isk", J.add(J.getv(J.getv(game.j_G, "stat"), "isk"), 1.0))
			else:
				if J.eq(J.getv(v_it, "kind"), "drink"):
					J.setv(J.getv(game.j_G, "stat"), "drinks", J.add(J.getv(J.getv(game.j_G, "stat"), "drinks"), 1.0))
				else:
					if J.eq(J.getv(v_it, "kind"), "sweet"):
						J.setv(J.getv(game.j_G, "stat"), "sweets", J.add(J.getv(J.getv(game.j_G, "stat"), "sweets"), 1.0))
					else:
						J.setv(J.getv(game.j_G, "stat"), "boxes", J.add(J.getv(J.getv(game.j_G, "stat"), "boxes"), 1.0))
		J.setv(game.j_G, "totalSold", J.add(J.getv(game.j_G, "totalSold"), 1.0))
		v_j = J.add(v_j, 1.0)
	game.effects.f_burst(J.getv(v_target, "x"), (J.getv(v_target, "y") - 30.0), 20.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 90.0, "up": 30.0, "type": "star", "sz": 2.0})
	game.effects.f_flash(0.25, "#ffe9a0")
	game.effects.f_shake(3.0)
	game.effects.f_ftext("DAYI KURTARDI!", J.getv(v_target, "x"), (J.getv(v_target, "y") - 66.0), J.getv(game.j_P, "au0"), {"life": 1.6})
	game.customer_system.f_payCustomer(v_target)
	return null

