# Stock system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2022
func f_crateItems() -> Variant:
	var v_a: Variant = null
	v_a = [["pickle", "Turşu"], ["yogurt", "Yoğurt"]]
	if J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])):
		J.method(v_a, "push", [["ayran", "Ayran"]])
	if J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])):
		J.method(v_a, "push", [["sweet", "Tatlı"]])
	if J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])):
		J.method(v_a, "push", [["tomato", "Domates"]])
		J.method(v_a, "push", [["pepper", "Biber"]])
	return v_a
	return null

# game.js:2029
func f_crateMax(p_k: Variant = null) -> Variant:
	var v_k: Variant = p_k
	if J.eq(v_k, "ayran"):
		return J.method(game.j_TUN, "ayranMax", [game.j_G])
	if J.eq(v_k, "sweet"):
		return J.method(game.j_TUN, "sweetMax", [game.j_G])
	if (J.eq(v_k, "tomato") or J.eq(v_k, "pepper")):
		return J.method(game.j_TUN, "garnishMax", [game.j_G])
	return game.session_system.f_stMax()
	return null

# game.js:2035
func f_cratePanelRect() -> Variant:
	var v_n: Variant = null
	var v_h: Variant = null
	v_n = J.getv(game.stock_system.f_crateItems(), "length")
	v_h = J.add(J.add(18.0, (v_n * 22.0)), 12.0)
	return [(J.getv(J.getv(game.j_ST, "crate"), "x") - 88.0), J.add((J.getv(J.getv(game.j_ST, "crate"), "y") - v_h), 26.0), 116.0, v_h]
	return null

# game.js:2040
func f_crateSlotRect(p_i: Variant = null) -> Variant:
	var v_r: Variant = null
	var v_i: Variant = p_i
	v_r = game.stock_system.f_cratePanelRect()
	return [J.add(J.getv(v_r, 0.0), 6.0), J.add(J.add(J.getv(v_r, 1.0), 14.0), (v_i * 22.0)), 104.0, 20.0]
	return null

# game.js:2044
func f_crateClick(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_items: Variant = null
	var v_i: Variant = null
	var v_r: Variant = null
	var v_k: Variant = null
	var v_m: Variant = null
	var v_add: Variant = null
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	v_c = J.getv(game.j_G, "crate")
	if (not J.truth(J.getv(v_c, "open"))):
		J.setv(v_c, "open", true)
		J.setv(v_c, "t", 0.0)
		J.method(game.j_SFX, "drawer", [false])
		game.session_system.f_say("Kutu açık — tıklayarak doldur")
		return null
	v_items = game.stock_system.f_crateItems()
	v_i = 0.0
	while J.lt(v_i, J.getv(v_items, "length")):
		v_r = game.stock_system.f_crateSlotRect(v_i)
		if J.truth(game.math_utils.f_inRect(v_mx, v_my, J.getv(v_r, 0.0), J.getv(v_r, 1.0), J.getv(v_r, 2.0), J.getv(v_r, 3.0))):
			v_k = J.getv(J.getv(v_items, v_i), 0.0)
			v_m = game.stock_system.f_crateMax(v_k)
			if J.ge(J.getv(J.getv(game.j_G, "stock"), v_k), v_m):
				J.method(game.j_SFX, "bad", [])
				return null
			v_add = min(J.method(game.j_TUN, "refillPer", [game.j_G]), (v_m - J.getv(J.getv(game.j_G, "stock"), v_k)))
			J.setv(J.getv(game.j_G, "stock"), v_k, J.add(J.getv(J.getv(game.j_G, "stock"), v_k), v_add))
			J.setv(v_c, "popT", 0.2)
			J.method(game.j_SFX, "pick", [])
			game.drag_system.f_spawnFlyIng(v_k, max(2.0, v_add))
			return null
		v_i = J.add(v_i, 1.0)
	J.setv(v_c, "open", false)
	J.method(game.j_SFX, "drawer", [true])
	return null

# game.js:2063
func f_updateStock(p_dt: Variant = null) -> Variant:
	var v_m: Variant = null
	var v_dt: Variant = p_dt
	if ((J.truth(J.method(game.j_TUN, "autoTrash", [game.j_G])) and J.gt(J.getv(game.j_G, "trash"), 0.5)) and J.le(J.getv(game.j_G, "emptyT"), 0.0)):
		J.setv(game.j_G, "emptyT", 0.9)
		J.setv(game.j_G, "trash", 0.0)
		J.method(game.j_SFX, "pour", [])
		game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "trash"), "x"), 11.0), J.add(J.getv(J.getv(game.j_ST, "trash"), "y"), 4.0), 10.0, ["#6d6258", "#8a7a6a", "#4a423a"], {"spMax": 50.0, "up": 22.0})
	if (not J.truth(J.method(game.j_TUN, "autoStock", [game.j_G]))):
		return null
	J.setv(game.j_G, "autoT", J.add(J.getv(game.j_G, "autoT"), v_dt))
	if J.gt(J.getv(game.j_G, "autoT"), 1.1):
		J.setv(game.j_G, "autoT", 0.0)
		v_m = game.session_system.f_stMax()
		if J.lt(J.getv(J.getv(game.j_G, "stock"), "pickle"), (v_m * 0.6)):
			J.setv(J.getv(game.j_G, "stock"), "pickle", min(v_m, J.add(J.getv(J.getv(game.j_G, "stock"), "pickle"), 4.0)))
		else:
			if J.lt(J.getv(J.getv(game.j_G, "stock"), "yogurt"), (v_m * 0.6)):
				J.setv(J.getv(game.j_G, "stock"), "yogurt", min(v_m, J.add(J.getv(J.getv(game.j_G, "stock"), "yogurt"), 4.0)))
			else:
				if (J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])) and J.lt(J.getv(J.getv(game.j_G, "stock"), "ayran"), (J.method(game.j_TUN, "ayranMax", [game.j_G]) * 0.6))):
					J.setv(J.getv(game.j_G, "stock"), "ayran", min(J.method(game.j_TUN, "ayranMax", [game.j_G]), J.add(J.getv(J.getv(game.j_G, "stock"), "ayran"), 2.0)))
				else:
					if (J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])) and J.lt(J.getv(J.getv(game.j_G, "stock"), "sweet"), (J.method(game.j_TUN, "sweetMax", [game.j_G]) * 0.6))):
						J.setv(J.getv(game.j_G, "stock"), "sweet", min(J.method(game.j_TUN, "sweetMax", [game.j_G]), J.add(J.getv(J.getv(game.j_G, "stock"), "sweet"), 1.0)))
					else:
						if (J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and J.lt(J.getv(J.getv(game.j_G, "stock"), "tomato"), (J.method(game.j_TUN, "garnishMax", [game.j_G]) * 0.6))):
							J.setv(J.getv(game.j_G, "stock"), "tomato", min(J.method(game.j_TUN, "garnishMax", [game.j_G]), J.add(J.getv(J.getv(game.j_G, "stock"), "tomato"), 2.0)))
						else:
							if (J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and J.lt(J.getv(J.getv(game.j_G, "stock"), "pepper"), (J.method(game.j_TUN, "garnishMax", [game.j_G]) * 0.6))):
								J.setv(J.getv(game.j_G, "stock"), "pepper", min(J.method(game.j_TUN, "garnishMax", [game.j_G]), J.add(J.getv(J.getv(game.j_G, "stock"), "pepper"), 2.0)))
	return null
