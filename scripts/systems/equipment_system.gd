# Equipment system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# data.js:310
func f_upgById(p_id: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		if J.eq(J.getv(J.getv(game.j_UPG, v_i), "id"), v_id):
			return J.getv(game.j_UPG, v_i)
		v_i = J.add(v_i, 1.0)
	return null
	return null

# data.js:313
func f_UV(p_G: Variant = null, p_id: Variant = null) -> Variant:
	var v_G: Variant = p_G
	var v_id: Variant = p_id
	return (J.getv(J.getv(v_G, "up"), v_id) if J.truth(J.getv(J.getv(v_G, "up"), v_id)) else 0.0)
	return null

# data.js:314
func f_LV(p_arr: Variant = null, p_n: Variant = null) -> Variant:
	var v_arr: Variant = p_arr
	var v_n: Variant = p_n
	return J.getv(v_arr, min(v_n, (J.getv(v_arr, "length") - 1.0)))
	return null

# data.js:602
func f_upgTotalLv(p_g: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_g: Variant = p_g
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		v_n = J.add(v_n, (J.getv(J.getv(v_g, "up"), J.getv(J.getv(game.j_UPG, v_i), "id")) if J.truth(J.getv(J.getv(v_g, "up"), J.getv(J.getv(game.j_UPG, v_i), "id"))) else 0.0))
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# game.js:1197
func f_updateSauce(p_dt: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_i: Variant = null
	var v_dt: Variant = p_dt
	v_k = ["hot", "garlic", "butter"]
	v_i = 0.0
	while J.lt(v_i, 3.0):
		if J.gt(J.getv(J.getv(game.j_G, "sauceFx"), J.getv(v_k, v_i)), 0.0):
			J.setv(J.getv(game.j_G, "sauceFx"), J.getv(v_k, v_i), max(0.0, (J.getv(J.getv(game.j_G, "sauceFx"), J.getv(v_k, v_i)) - (v_dt * 3.6))))
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1802
func f_sweetClick() -> Variant:
	var v_old: Variant = null
	if (not J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G]))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Tatlı tepsisi yok — dükkândan al")
		return null
	if J.le(J.getv(J.getv(game.j_G, "stock"), "sweet"), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Tatlı bitti — kutudan doldur!")
		return null
	v_old = J.getv(game.j_G, "hand")
	if (J.truth(v_old) and (not J.truth(game.drag_system.f_returnItem(v_old)))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Yer yok!")
		return null
	J.setv(J.getv(game.j_G, "stock"), "sweet", (J.getv(J.getv(game.j_G, "stock"), "sweet") - 1.0))
	J.setv(J.getv(game.j_G, "fxTray"), "sweet", 1.0)
	J.setv(game.j_G, "hand", {"kind": "sweet"})
	J.method(game.j_SFX, "pick", [])
	return null

# game.js:1893
func f_checkAuto() -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_w: Variant = null
	var v_ay: Variant = null
	var v_at: Variant = null
	var v_ap: Variant = null
	var v_istenen: Variant = null
	var v_mevcut: Variant = null
	var v_bosTahta: Variant = null
	var v_bb: Variant = null
	var v_cc: Variant = null
	var v_j: Variant = null
	var v_pp: Variant = null
	var v_gerekliBos: Variant = null
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_w = J.getv(J.getv(game.j_G, "boards"), v_i)
		if ((not J.truth(v_w)) or J.eq(J.getv(v_w, "state"), "ready")):
			v_i = J.add(v_i, 1.0)
			continue
		if J.eq(J.getv(v_w, "kind"), "pide"):
			v_i = J.add(v_i, 1.0)
			continue
		if J.eq(J.getv(v_w, "kind"), "plate"):
			if (J.truth(J.method(game.j_TUN, "autoIsk", [game.j_G])) and J.ge(J.getv(v_w, "meat"), J.method(game.j_TUN, "iskMeat", [game.j_G]))):
				if (not J.truth(J.getv(v_w, "butter"))):
					J.setv(v_w, "butter", true)
					J.setv(J.getv(game.j_G, "sauceFx"), "butter", 1.0)
				else:
					if ((not J.truth(J.getv(v_w, "yogurt"))) and J.gt(J.getv(J.getv(game.j_G, "stock"), "yogurt"), 0.0)):
						v_ay = min((game.j_PLATE_YOGURT - (J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0)), J.getv(J.getv(game.j_G, "stock"), "yogurt"))
						J.setv(J.getv(game.j_G, "stock"), "yogurt", (J.getv(J.getv(game.j_G, "stock"), "yogurt") - v_ay))
						J.setv(v_w, "yogurtN", J.add((J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), v_ay))
						J.setv(v_w, "yogurt", J.ge(J.getv(v_w, "yogurtN"), game.j_PLATE_YOGURT))
						J.setv(J.getv(game.j_G, "fxTray"), "yogurt", 1.0)
					else:
						if ((J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and J.lt((J.getv(v_w, "tomato") if J.truth(J.getv(v_w, "tomato")) else 0.0), game.j_TOMATO_NEED)) and J.gt(J.getv(J.getv(game.j_G, "stock"), "tomato"), 0.0)):
							v_at = min((game.j_TOMATO_NEED - (J.getv(v_w, "tomato") if J.truth(J.getv(v_w, "tomato")) else 0.0)), J.getv(J.getv(game.j_G, "stock"), "tomato"))
							J.setv(J.getv(game.j_G, "stock"), "tomato", (J.getv(J.getv(game.j_G, "stock"), "tomato") - v_at))
							J.setv(v_w, "tomato", J.add((J.getv(v_w, "tomato") if J.truth(J.getv(v_w, "tomato")) else 0.0), v_at))
							J.setv(J.getv(game.j_G, "fxTray"), "tomato", 1.0)
						else:
							if ((J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and J.lt((J.getv(v_w, "pepper") if J.truth(J.getv(v_w, "pepper")) else 0.0), game.j_PEPPER_NEED)) and J.gt(J.getv(J.getv(game.j_G, "stock"), "pepper"), 0.0)):
								v_ap = min((game.j_PEPPER_NEED - (J.getv(v_w, "pepper") if J.truth(J.getv(v_w, "pepper")) else 0.0)), J.getv(J.getv(game.j_G, "stock"), "pepper"))
								J.setv(J.getv(game.j_G, "stock"), "pepper", (J.getv(J.getv(game.j_G, "stock"), "pepper") - v_ap))
								J.setv(v_w, "pepper", J.add((J.getv(v_w, "pepper") if J.truth(J.getv(v_w, "pepper")) else 0.0), v_ap))
								J.setv(J.getv(game.j_G, "fxTray"), "pepper", 1.0)
			game.recipe_system.f_finishPlate(v_i)
			v_i = J.add(v_i, 1.0)
			continue
		if J.eq(J.getv(v_w, "state"), "rolled"):
			if J.truth(game.recipe_system.f_wrapNeedsGrill(v_w)):
				if (J.truth(J.method(game.j_TUN, "autoGrill", [game.j_G])) and (not J.truth(game.grill_system.f_grillDolu()))):
					game.grill_system.f_grillPut(v_i)
			else:
				if (J.truth(J.method(game.j_TUN, "autoPaper", [game.j_G])) and J.eq(J.getv(J.getv(game.j_G, "paper"), "busy"), 0.0)):
					game.paper_system.f_startPaper(v_i)
			v_i = J.add(v_i, 1.0)
			continue
		if (not J.truth(game.f_wrapFull(v_w))):
			v_i = J.add(v_i, 1.0)
			continue
		v_i = J.add(v_i, 1.0)
	if J.truth(J.method(game.j_TUN, "autoIsk", [game.j_G])):
		v_istenen = 0.0
		v_mevcut = 0.0
		v_bosTahta = 0.0
		v_i = 0.0
		while J.lt(v_i, v_n):
			v_bb = J.getv(J.getv(game.j_G, "boards"), v_i)
			if (not J.truth(v_bb)):
				v_bosTahta = J.add(v_bosTahta, 1.0)
				v_i = J.add(v_i, 1.0)
				continue
			if (J.eq(J.getv(v_bb, "kind"), "plate") or J.eq(J.getv(v_bb, "kind"), "pide")):
				v_mevcut = J.add(v_mevcut, 1.0)
			v_i = J.add(v_i, 1.0)
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
			v_cc = J.getv(J.getv(game.j_G, "customers"), v_i)
			if not J.eq(J.getv(v_cc, "state"), "wait"):
				v_i = J.add(v_i, 1.0)
				continue
			v_j = 0.0
			while J.lt(v_j, J.getv(J.getv(v_cc, "items"), "length")):
				if ((not J.truth(J.getv(J.getv(v_cc, "done"), v_j))) and J.eq(J.getv(J.getv(J.getv(v_cc, "items"), v_j), "kind"), "plate")):
					v_istenen = J.add(v_istenen, 1.0)
				v_j = J.add(v_j, 1.0)
			v_i = J.add(v_i, 1.0)
		if J.truth(game.phone_system.f_phoneOpen()):
			v_pp = J.getv(game.j_G, "phone")
			v_i = 0.0
			while J.lt(v_i, J.getv(J.getv(v_pp, "order"), "length")):
				if ((not J.truth(J.getv(J.getv(v_pp, "done"), v_i))) and J.eq(J.getv(J.getv(J.getv(v_pp, "order"), v_i), "kind"), "plate")):
					v_istenen = J.add(v_istenen, 1.0)
				v_i = J.add(v_i, 1.0)
		if (J.truth(J.getv(game.j_G, "hand")) and J.eq(J.getv(J.getv(game.j_G, "hand"), "kind"), "plate")):
			v_mevcut = J.add(v_mevcut, 1.0)
		v_gerekliBos = (2.0 if (J.truth(J.getv(J.getv(game.j_G, "grill"), "slots")) and J.truth(J.getv(J.getv(J.getv(game.j_G, "grill"), "slots"), "length"))) else 1.0)
		if (J.gt(v_istenen, v_mevcut) and J.ge(v_bosTahta, v_gerekliBos)):
			game.recipe_system.f_newPide(true)
		v_i = 0.0
		while J.lt(v_i, v_n):
			if (J.truth(J.getv(J.getv(game.j_G, "boards"), v_i)) and J.eq(J.getv(J.getv(J.getv(game.j_G, "boards"), v_i), "kind"), "pide")):
				game.assembly_system.f_pideChop(v_i, true)
			v_i = J.add(v_i, 1.0)
	return null

