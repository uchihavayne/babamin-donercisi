# Payment system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# Distribute an integer payment without rounding each coin independently.
# Collected money must equal the sale receipt and the day-end income total.
func coin_share(total: int, count: int, index: int) -> int:
	return int(total / count) + (1 if index < total % count else 0)

# game.js:2476
func f_updateCoins(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_c: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(J.getv(game.j_G, "coins"), "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_c = J.getv(J.getv(game.j_G, "coins"), v_i)
		J.setv(v_c, "t", J.add(J.getv(v_c, "t"), v_dt))
		if (not J.truth(J.getv(v_c, "landed"))):
			J.setv(v_c, "vy", J.add(J.getv(v_c, "vy"), (260.0 * v_dt)))
			J.setv(v_c, "x", J.add(J.getv(v_c, "x"), (J.getv(v_c, "vx") * v_dt)))
			J.setv(v_c, "y", J.add(J.getv(v_c, "y"), (J.getv(v_c, "vy") * v_dt)))
			if J.gt(J.getv(v_c, "y"), J.add(J.getv(game.j_LAY, "ledgeY"), 3.0)):
				J.setv(v_c, "y", J.add(J.getv(game.j_LAY, "ledgeY"), 3.0))
				J.setv(v_c, "landed", 1.0)
				J.setv(v_c, "vx", 0.0)
		else:
			J.setv(v_c, "life", J.add(J.getv(v_c, "life"), v_dt))
			if (J.truth(J.method(game.j_TUN, "autoCoin", [game.j_G])) or J.gt(J.getv(v_c, "life"), 10.0)):
				game.payment_system.f_collectCoin(v_i, true)
		v_i = (v_i - 1.0)
	return null

# game.js:2488
func f_collectCoin(p_i: Variant = null, p_auto: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_i: Variant = p_i
	var v_auto: Variant = p_auto
	v_c = J.getv(J.getv(game.j_G, "coins"), v_i)
	game.household_system.f_kasaEkle(J.getv(v_c, "v"))
	J.method(J.getv(game.j_G, "coins"), "splice", [v_i, 1.0])
	if (not J.truth(v_auto)):
		J.method(game.j_SFX, "coin", [])
	game.effects.f_burst(J.getv(v_c, "x"), J.getv(v_c, "y"), 4.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1")], {"spMax": 40.0, "up": 20.0, "sz": 1.0})
	if J.lt(J.getv(J.getv(game.j_G, "flyCoins"), "length"), 24.0):
		J.method(J.getv(game.j_G, "flyCoins"), "push", [{"x0": J.getv(v_c, "x"), "y0": J.getv(v_c, "y"), "t": 0.0, "v": J.getv(v_c, "v"), "ph": game.math_utils.f_rnd(0.0, 6.0)}])
	return null

# game.js:2498
func f_updateFlyCoins(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_hp: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(J.getv(game.j_G, "flyCoins"), "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_f = J.getv(J.getv(game.j_G, "flyCoins"), v_i)
		J.setv(v_f, "t", J.add(J.getv(v_f, "t"), (v_dt * 1.9)))
		if J.ge(J.getv(v_f, "t"), 1.0):
			J.method(J.getv(game.j_G, "flyCoins"), "splice", [v_i, 1.0])
			J.setv(game.j_G, "hudPop", 1.0)
			v_hp = game.hud_draw.f_hudCoinPos()
			game.effects.f_burst(J.getv(v_hp, 0.0), J.getv(v_hp, 1.0), 4.0, [J.getv(game.j_P, "au0"), "#fff"], {"spMax": 34.0, "up": 10.0, "sz": 1.0})
		v_i = (v_i - 1.0)
	if J.gt(J.getv(game.j_G, "hudPop"), 0.0):
		J.setv(game.j_G, "hudPop", max(0.0, (J.getv(game.j_G, "hudPop") - (v_dt * 4.0))))
	return null
