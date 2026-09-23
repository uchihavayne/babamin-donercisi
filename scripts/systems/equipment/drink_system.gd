# Drink system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1704
func f_icecekMusluklari() -> Variant:
	var v_m: Variant = null
	v_m = []
	if J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G])):
		J.method(v_m, "push", ["fanta"])
		J.method(v_m, "push", ["cola"])
	if J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G])):
		J.method(v_m, "push", ["ayran"])
	return v_m
	return null

# game.js:1711
func f_cupPos(p_type: Variant = null) -> Variant:
	var v_m: Variant = null
	var v_i: Variant = null
	var v_gen: Variant = null
	var v_type: Variant = p_type
	v_m = game.drink_system.f_icecekMusluklari()
	v_i = J.method(v_m, "indexOf", [v_type])
	if J.lt(v_i, 0.0):
		v_i = 0.0
	v_gen = (float(J.getv(J.getv(game.j_ST, "drinkM"), "w")) / float(max(1.0, J.getv(v_m, "length"))))
	return [floor(J.add(J.getv(J.getv(game.j_ST, "drinkM"), "x"), (v_gen * J.add(v_i, 0.5))) + 0.5), J.add(J.getv(J.getv(game.j_ST, "drinkM"), "y"), 42.0)]
	return null

# game.js:1718
func f_pourStart(p_type: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_type: Variant = p_type
	if J.eq(v_type, "ayran"):
		if (not J.truth(J.method(game.j_TUN, "ayranOn", [game.j_G]))):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Ayran kazanı yok")
			return null
		if J.le(J.getv(J.getv(game.j_G, "stock"), "ayran"), 0.0):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Ayran bitti — kutudan doldur!")
			return null
	else:
		if (not J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G]))):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("İçecek standı kapalı")
			return null
	v_d = J.getv(game.j_G, "drinkM")
	if not J.eq(J.getv(J.getv(v_d, "pours"), v_type), null):
		J.method(game.j_SFX, "bad", [])
		return null
	if J.truth(J.getv(J.getv(game.j_G, "cups"), v_type)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Bardak zaten dolu")
		return null
	if J.eq(v_type, "ayran"):
		J.setv(J.getv(game.j_G, "stock"), "ayran", (J.getv(J.getv(game.j_G, "stock"), "ayran") - 1.0))
		J.setv(J.getv(game.j_G, "fxTray"), "ayran", 1.0)
	J.setv(J.getv(game.j_G, "cups"), v_type, {"kind": "drink", "type": v_type, "fill": 0.0})
	J.setv(J.getv(v_d, "pours"), v_type, 0.0)
	J.setv(v_d, "pour", v_type)
	J.setv(v_d, "t", 0.0)
	game.f_pourSndStart(v_type)
	return null

# game.js:1734
func f_takeCup(p_type: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_old: Variant = null
	var v_type: Variant = p_type
	v_c = J.getv(J.getv(game.j_G, "cups"), v_type)
	if (not J.truth(v_c)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Bardak yok")
		return null
	if J.lt(J.getv(v_c, "fill"), 1.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Daha doluyor…")
		return null
	v_old = J.getv(game.j_G, "hand")
	if (J.truth(v_old) and (not J.truth(game.drag_system.f_returnItem(v_old)))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Yer yok!")
		return null
	J.setv(game.j_G, "hand", v_c)
	J.setv(J.getv(game.j_G, "cups"), v_type, null)
	J.method(game.j_SFX, "pick", [])
	return null

# game.js:1743
func f_updateDrink(p_dt: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_sure: Variant = null
	var v_akan: Variant = null
	var v_enDolu: Variant = null
	var v_biten: Variant = null
	var v_ty: Variant = null
	var v_c: Variant = null
	var v_ty2: Variant = null
	var v_want: Variant = null
	var v_pq: Variant = null
	var v_k: Variant = null
	var v_i: Variant = null
	var v_c2: Variant = null
	var v_j: Variant = null
	var v_dt: Variant = p_dt
	v_d = J.getv(game.j_G, "drinkM")
	v_sure = J.method(game.j_TUN, "pourTime", [game.j_G])
	v_akan = 0.0
	v_enDolu = 0.0
	v_biten = false
	for _key_246 in J.keys(J.getv(v_d, "pours")):
		v_ty = _key_246
		v_c = J.getv(J.getv(game.j_G, "cups"), v_ty)
		if (not J.truth(v_c)):
			J.delv(J.getv(v_d, "pours"), v_ty)
			continue
		J.setv(J.getv(v_d, "pours"), v_ty, J.add(J.getv(J.getv(v_d, "pours"), v_ty), v_dt))
		J.setv(v_c, "fill", game.math_utils.f_clamp((float(J.getv(J.getv(v_d, "pours"), v_ty)) / float(v_sure)), 0.0, 1.0))
		if J.ge(J.getv(v_c, "fill"), 1.0):
			J.delv(J.getv(v_d, "pours"), v_ty)
			v_biten = true
			J.method(game.j_SFX, "glass", [])
			continue
		v_akan = J.add(v_akan, 1.0)
		if J.gt(J.getv(v_c, "fill"), v_enDolu):
			v_enDolu = J.getv(v_c, "fill")
		if J.eq(J.getv(v_d, "pour"), v_ty):
			J.setv(v_d, "t", J.getv(J.getv(v_d, "pours"), v_ty))
	if J.gt(v_akan, 0.0):
		if J.eq(J.getv(J.getv(v_d, "pours"), J.getv(v_d, "pour")), null):
			for _key_247 in J.keys(J.getv(v_d, "pours")):
				v_ty2 = _key_247
				J.setv(v_d, "pour", v_ty2)
				J.setv(v_d, "t", J.getv(J.getv(v_d, "pours"), v_ty2))
				break
		game.f_pourSndLevel(v_enDolu)
		return null
	J.setv(v_d, "pour", null)
	if J.truth(v_biten):
		game.f_pourSndStop(true)
	if J.truth(J.method(game.j_TUN, "autoDrink", [game.j_G])):
		v_want = null
		if J.truth(game.phone_system.f_phoneOpen()):
			v_pq = J.getv(game.j_G, "phone")
			v_k = 0.0
			while (J.lt(v_k, J.getv(J.getv(v_pq, "order"), "length")) and (not J.truth(v_want))):
				if (J.truth(J.getv(J.getv(v_pq, "done"), v_k)) or not J.eq(J.getv(J.getv(J.getv(v_pq, "order"), v_k), "kind"), "drink")):
					v_k = J.add(v_k, 1.0)
					continue
				if (not J.truth(J.getv(J.getv(game.j_G, "cups"), J.getv(J.getv(J.getv(v_pq, "order"), v_k), "type")))):
					v_want = J.getv(J.getv(J.getv(v_pq, "order"), v_k), "type")
				v_k = J.add(v_k, 1.0)
		v_i = 0.0
		while (J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")) and (not J.truth(v_want))):
			v_c2 = J.getv(J.getv(game.j_G, "customers"), v_i)
			if not J.eq(J.getv(v_c2, "state"), "wait"):
				v_i = J.add(v_i, 1.0)
				continue
			v_j = 0.0
			while J.lt(v_j, J.getv(J.getv(v_c2, "items"), "length")):
				if (J.truth(J.getv(J.getv(v_c2, "done"), v_j)) or not J.eq(J.getv(J.getv(J.getv(v_c2, "items"), v_j), "kind"), "drink")):
					v_j = J.add(v_j, 1.0)
					continue
				v_ty = J.getv(J.getv(J.getv(v_c2, "items"), v_j), "type")
				if (not J.truth(J.getv(J.getv(game.j_G, "cups"), v_ty))):
					v_want = v_ty
					break
				v_j = J.add(v_j, 1.0)
			v_i = J.add(v_i, 1.0)
		if ((J.truth(J.getv(game.j_G, "hand")) and J.eq(J.getv(J.getv(game.j_G, "hand"), "kind"), "drink")) and J.eq(J.getv(J.getv(game.j_G, "hand"), "type"), v_want)):
			v_want = null
		if (J.truth(v_want) and (not J.eq(v_want, "ayran") or J.gt(J.getv(J.getv(game.j_G, "stock"), "ayran"), 0.0))):
			game.drink_system.f_pourStart(v_want)
	return null

# game.js:1796
func f_pouringAny() -> Variant:
	var v_k: Variant = null
	for _key_248 in J.keys(J.getv(J.getv(game.j_G, "drinkM"), "pours")):
		v_k = _key_248
		return true
	return false
	return null

