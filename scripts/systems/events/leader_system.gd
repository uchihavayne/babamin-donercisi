# Leader system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:496
func f_liderIstekYap() -> Variant:
	var v_secim: Variant = null
	v_secim = [{"kind": "wrap"}]
	if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])):
		J.method(v_secim, "push", [{"kind": "plate"}])
	if J.truth(J.method(game.j_TUN, "drinkOn", [game.j_G])):
		J.method(v_secim, "push", [{"kind": "drink", "type": "cola"}])
	if J.truth(J.method(game.j_TUN, "sweetOn", [game.j_G])):
		J.method(v_secim, "push", [{"kind": "sweet"}])
	return game.math_utils.f_pick(v_secim)
	return null

# game.js:503
func f_updateLider(p_dt: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_ci: Variant = null
	var v_cc: Variant = null
	var v_dt: Variant = p_dt
	v_L = J.getv(game.j_G, "lider")
	if (((not J.truth(v_L)) or (not J.truth(J.getv(game.j_G, "ferman")))) or J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi"))):
		return null
	J.setv(v_L, "t", (J.getv(v_L, "t") - v_dt))
	if J.eq(J.getv(v_L, "state"), "bekle"):
		if J.le(J.getv(v_L, "t"), 0.0):
			J.setv(v_L, "state", "geliyor")
			J.setv(v_L, "istek", game.leader_system.f_liderIstekYap())
			v_ci = 0.0
			while J.lt(v_ci, J.getv(J.getv(game.j_G, "customers"), "length")):
				v_cc = J.getv(J.getv(game.j_G, "customers"), v_ci)
				if (J.eq(J.getv(v_cc, "state"), "wait") or J.eq(J.getv(v_cc, "state"), "walkin")):
					J.setv(v_cc, "state", "leave")
					J.setv(v_cc, "leaveDir", (1.0 if J.gt(J.getv(v_cc, "x"), (float(game.j_W) / float(2.0))) else (-J.n(1.0))))
					J.setv(v_cc, "mood", "wait")
				v_ci = J.add(v_ci, 1.0)
			J.setv(game.j_G, "spawnT", 999.0)
			J.method(game.j_SFX, "bell", [])
			game.effects.f_shake(0.4)
			game.effects.f_ftext(game.localization.f_T("LİDER GELİYOR"), (float(game.j_W) / float(2.0)), 96.0, "#e2483a", {"life": 2.2, "sc": 1.0})
		return null
	if J.eq(J.getv(v_L, "state"), "geliyor"):
		J.setv(v_L, "x", game.math_utils.f_approach(J.getv(v_L, "x"), J.getv(v_L, "tx"), (v_dt * 70.0)))
		if J.lt(abs((J.getv(v_L, "x") - J.getv(v_L, "tx"))), 1.0):
			J.setv(v_L, "state", "bekliyor")
			J.setv(v_L, "sabir", 1.0)
		return null
	if J.eq(J.getv(v_L, "state"), "bekliyor"):
		J.setv(v_L, "sabir", (J.getv(v_L, "sabir") - (float(v_dt) / float(26.0))))
		if J.le(J.getv(v_L, "sabir"), 0.0):
			game.leader_system.f_liderSonuc(false, "bekletildi")
		return null
	if J.eq(J.getv(v_L, "state"), "gidiyor"):
		J.setv(v_L, "x", J.add(J.getv(v_L, "x"), (v_dt * 90.0)))
		if J.gt(J.getv(v_L, "x"), J.add(game.j_W, 60.0)):
			J.setv(game.j_G, "lider", null)
			J.setv(game.j_G, "spawnT", 2.5)
	return null

# game.js:541
func f_liderBekliyor() -> Variant:
	return (not (not (J.truth(J.getv(game.j_G, "lider")) and J.eq(J.getv(J.getv(game.j_G, "lider"), "state"), "bekliyor"))))
	return null

# game.js:544
func f_liderSonuc(p_iyi: Variant = null, p_sebep: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_i: Variant = null
	var v_lf: Variant = null
	var v_iyi: Variant = p_iyi
	var v_sebep: Variant = p_sebep
	v_L = J.getv(game.j_G, "lider")
	if ((not J.truth(v_L)) or J.truth(J.getv(v_L, "sonuc"))):
		return null
	J.setv(v_L, "sonuc", ("iyi" if J.truth(v_iyi) else "kotu"))
	J.setv(v_L, "state", "gidiyor")
	if J.truth(v_iyi):
		game.household_system.f_kasaEkle(game.j_LIDER_ODUL)
		J.setv(J.getv(game.j_G, "stats"), "lider", J.add((J.getv(J.getv(game.j_G, "stats"), "lider") if J.truth(J.getv(J.getv(game.j_G, "stats"), "lider")) else 0.0), 1.0))
		if (J.truth(J.getv(game.j_G, "ferman")) and J.gt(J.getv(J.getv(game.j_G, "ferman"), "ceza"), 0.0)):
			J.setv(J.getv(game.j_G, "ferman"), "ceza", (J.getv(J.getv(game.j_G, "ferman"), "ceza") - 1.0))
			if (J.truth(J.getv(J.getv(game.j_G, "ferman"), "kayit")) and J.truth(J.getv(J.getv(J.getv(game.j_G, "ferman"), "kayit"), "length"))):
				J.method(J.getv(J.getv(game.j_G, "ferman"), "kayit"), "pop", [])
		J.method(game.j_SFX, "cash", [])
		J.method(game.j_SFX, "levelup", [])
		game.effects.f_flash(0.25, "#ffe9a0")
		game.effects.f_burst(J.getv(v_L, "x"), (J.getv(v_L, "y") - 30.0), 22.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 90.0, "type": "star", "sz": 2.0})
		game.effects.f_ftext(J.add("+$", game.math_utils.f_fmtMoney(game.j_LIDER_ODUL)), J.getv(v_L, "x"), (J.getv(v_L, "y") - 62.0), J.getv(game.j_P, "au0"), {"life": 2.0, "sc": 1.0})
	else:
		v_i = 0.0
		while J.lt(v_i, game.j_LIDER_CEZA):
			v_lf = {"id": "lider", "metin": ("Lider bekletildi" if J.eq(v_sebep, "bekletildi") else "Lidere yanlış ürün verildi")}
			game.regulation_system.f_fermanIhlal(v_lf, J.getv(v_L, "x"), ((J.getv(v_L, "y") - 60.0) - (v_i * 8.0)), "lider")
			v_i = J.add(v_i, 1.0)
		J.method(game.j_SFX, "bad", [])
		game.effects.f_shake(0.6)
		game.effects.f_flash(0.3, "#e2483a")
	return null

# game.js:570
func f_liderVer(p_it: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_d: Variant = null
	var v_uygun: Variant = null
	var v_it: Variant = p_it
	v_L = J.getv(game.j_G, "lider")
	if (((not J.truth(v_L)) or not J.eq(J.getv(v_L, "state"), "bekliyor")) or (not J.truth(v_it))):
		return false
	v_d = J.getv(v_L, "istek")
	v_uygun = ((not J.eq(J.getv(v_d, "kind"), "drink") if not J.eq(J.getv(v_d, "kind"), "drink") else J.eq(J.getv(v_it, "type"), J.getv(v_d, "type"))) if J.eq(J.getv(v_it, "kind"), J.getv(v_d, "kind")) else J.eq(J.getv(v_it, "kind"), J.getv(v_d, "kind")))
	if (J.eq(J.getv(v_it, "kind"), "wrap") and J.truth(J.getv(v_it, "burnt"))):
		v_uygun = false
	J.setv(game.j_G, "hand", null)
	game.leader_system.f_liderSonuc(v_uygun, ("tamam" if J.truth(v_uygun) else "yanlis"))
	return true
	return null

