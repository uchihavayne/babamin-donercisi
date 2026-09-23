# Fries box system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1813
func f_fboxClick() -> Variant:
	var v_old3: Variant = null
	if (not J.truth(J.method(game.j_TUN, "fboxOn", [game.j_G]))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Porsiyon kutusu kapalı")
		return null
	if J.gt(J.getv(J.getv(game.j_G, "fbox"), "ready"), 0.0):
		v_old3 = J.getv(game.j_G, "hand")
		if (J.truth(v_old3) and (not J.truth(game.drag_system.f_returnItem(v_old3)))):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Yer yok!")
			return null
		J.setv(J.getv(game.j_G, "fbox"), "ready", (J.getv(J.getv(game.j_G, "fbox"), "ready") - 1.0))
		J.setv(game.j_G, "hand", {"kind": "fbox"})
		J.method(game.j_SFX, "pick", [])
		return null
	if (J.gt(J.getv(J.getv(game.j_G, "fbox"), "busy"), 0.0) or J.truth(J.getv(J.getv(game.j_G, "fbox"), "fly"))):
		return null
	if J.truth(J.method(game.j_TUN, "autoBox", [game.j_G])):
		game.session_system.f_say("Kutu kendi dolduruyor")
		return null
	J.method(game.j_SFX, "ui", [])
	game.session_system.f_say("Kutuyu patates tepsisine sürükle")
	return null

# game.js:1829
func f_fboxDoldur(p_ucarak: Variant = null) -> Variant:
	var v_ucarak: Variant = p_ucarak
	if J.lt(J.getv(game.j_G, "friesTray"), 2.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Yeterli patates yok")
		return false
	J.setv(game.j_G, "friesTray", (J.getv(game.j_G, "friesTray") - 2.0))
	J.setv(J.getv(game.j_G, "fbox"), "busy", 1.0)
	J.setv(J.getv(game.j_G, "fxTray"), "fries", 1.0)
	J.method(game.j_SFX, "pick", [])
	if (not J.truth(v_ucarak)):
		game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "friesT"), "x"), (float(J.getv(J.getv(game.j_ST, "friesT"), "w")) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "friesT"), "y"), 10.0), 7.0, ["#f0c24a", "#e0a828", "#fff0c0"], {"spMax": 44.0, "up": 16.0})
	return true
	return null

# game.js:1839
func f_updateFbox(p_dt: Variant = null) -> Variant:
	var v_f: Variant = null
	var v_need: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_j: Variant = null
	var v_k: Variant = null
	var v_dt: Variant = p_dt
	v_f = J.getv(game.j_G, "fbox")
	if J.gt(J.getv(v_f, "busy"), 0.0):
		J.setv(v_f, "busy", (J.getv(v_f, "busy") - (float(v_dt) / float(J.method(game.j_TUN, "fboxTime", [game.j_G])))))
		if J.le(J.getv(v_f, "busy"), 0.0):
			J.setv(v_f, "busy", 0.0)
			if J.truth(J.getv(v_f, "fly")):
				J.setv(J.getv(v_f, "fly"), "faz", "donus")
				J.setv(J.getv(v_f, "fly"), "t", 0.0)
			else:
				J.setv(v_f, "ready", min(3.0, J.add(J.getv(v_f, "ready"), 1.0)))
				J.method(game.j_SFX, "pop", [])
	if J.truth(J.getv(v_f, "fly")):
		J.setv(J.getv(v_f, "fly"), "t", J.add(J.getv(J.getv(v_f, "fly"), "t"), (float(v_dt) / float(0.42))))
		if J.ge(J.getv(J.getv(v_f, "fly"), "t"), 1.0):
			if J.eq(J.getv(J.getv(v_f, "fly"), "faz"), "gidis"):
				J.setv(J.getv(v_f, "fly"), "t", 0.0)
				J.setv(J.getv(v_f, "fly"), "faz", "dolum")
				if (not J.truth(game.fries_box_system.f_fboxDoldur(true))):
					J.setv(v_f, "fly", null)
			else:
				if J.eq(J.getv(J.getv(v_f, "fly"), "faz"), "donus"):
					J.setv(v_f, "fly", null)
					J.setv(v_f, "ready", min(3.0, J.add(J.getv(v_f, "ready"), 1.0)))
					J.method(game.j_SFX, "pop", [])
					game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "fbox"), "x"), (float(J.getv(J.getv(game.j_ST, "fbox"), "w")) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "fbox"), "y"), 14.0), 6.0, ["#f7d34a", "#e2382a"], {"spMax": 40.0, "up": 14.0})
		return null
	if (((J.truth(J.method(game.j_TUN, "autoBox", [game.j_G])) and J.eq(J.getv(v_f, "busy"), 0.0)) and J.lt(J.getv(v_f, "ready"), 2.0)) and J.ge(J.getv(game.j_G, "friesTray"), 4.0)):
		v_need = false
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
			v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
			if not J.eq(J.getv(v_c, "state"), "wait"):
				v_i = J.add(v_i, 1.0)
				continue
			v_j = 0.0
			while J.lt(v_j, J.getv(J.getv(v_c, "items"), "length")):
				if ((not J.truth(J.getv(J.getv(v_c, "done"), v_j))) and J.eq(J.getv(J.getv(J.getv(v_c, "items"), v_j), "kind"), "fbox")):
					v_need = true
				v_j = J.add(v_j, 1.0)
			v_i = J.add(v_i, 1.0)
		if ((not J.truth(v_need)) and J.truth(game.phone_system.f_phoneOpen())):
			v_k = 0.0
			while J.lt(v_k, J.getv(J.getv(J.getv(game.j_G, "phone"), "order"), "length")):
				if ((not J.truth(J.getv(J.getv(J.getv(game.j_G, "phone"), "done"), v_k))) and J.eq(J.getv(J.getv(J.getv(J.getv(game.j_G, "phone"), "order"), v_k), "kind"), "fbox")):
					v_need = true
				v_k = J.add(v_k, 1.0)
		if J.truth(v_need):
			J.setv(v_f, "fly", {"t": 0.0, "faz": "gidis"})
			J.method(game.j_SFX, "pick", [])
	return null

# game.js:1881
func f_fboxUcusPos() -> Variant:
	var v_f: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_k: Variant = null
	var v_u: Variant = null
	v_f = J.getv(game.j_G, "fbox")
	if (not J.truth(J.getv(v_f, "fly"))):
		return null
	v_ax = J.add(J.getv(J.getv(game.j_ST, "fbox"), "x"), (float(J.getv(J.getv(game.j_ST, "fbox"), "w")) / float(2.0)))
	v_ay = J.add(J.getv(J.getv(game.j_ST, "fbox"), "y"), 14.0)
	v_bx = J.add(J.getv(J.getv(game.j_ST, "friesT"), "x"), (float(J.getv(J.getv(game.j_ST, "friesT"), "w")) / float(2.0)))
	v_by = J.add(J.add(J.getv(J.getv(game.j_ST, "friesT"), "y"), J.getv(J.getv(game.j_ST, "friesT"), "h")), 6.0)
	v_k = game.math_utils.f_clamp(J.getv(J.getv(v_f, "fly"), "t"), 0.0, 1.0)
	if J.eq(J.getv(J.getv(v_f, "fly"), "faz"), "dolum"):
		return {"x": v_bx, "y": v_by, "dolum": true}
	v_u = (game.math_utils.f_easeOut(v_k) if J.eq(J.getv(J.getv(v_f, "fly"), "faz"), "gidis") else (1.0 - game.math_utils.f_easeOut(v_k)))
	return {"x": game.math_utils.f_lerp(v_ax, v_bx, v_u), "y": (game.math_utils.f_lerp(v_ay, v_by, v_u) - (sin((v_u * J.getv({"PI": PI}, "PI"))) * 18.0)), "dolum": false}
	return null

