# Rival system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:4747
func f_rakipGunBasi() -> Variant:
	var v_t: Variant = null
	var v_ilk: Variant = null
	if J.lt(J.getv(game.j_G, "day"), game.j_RAKIP_GUN):
		J.setv(game.j_G, "rakipAcik", false)
		J.setv(game.j_G, "rakip", null)
		return null
	J.setv(game.j_G, "rakipAcik", true)
	if J.truth(J.getv(game.j_G, "rakipKapandi")):
		J.setv(game.j_G, "rakip", null)
		return null
	if (not J.truth(J.getv(game.j_G, "rakipHedef"))):
		J.setv(game.j_G, "rakipHedef", J.add(J.getv(game.j_G, "day"), 1.0))
	if J.lt(J.getv(game.j_G, "day"), J.getv(game.j_G, "rakipHedef")):
		J.setv(game.j_G, "rakip", null)
		return null
	J.setv(game.j_G, "rakipHedef", J.add(J.add(J.getv(game.j_G, "day"), game.j_RAKIP_ARA_MIN), floor((game.random_unit() * J.add((game.j_RAKIP_ARA_MAK - game.j_RAKIP_ARA_MIN), 1.0)))))
	v_t = J.getv(game.j_BAHIS, floor((game.random_unit() * J.getv(game.j_BAHIS, "length"))))
	v_ilk = (not J.truth(J.getv(game.j_G, "rakipTanisti")))
	J.setv(game.j_G, "rakip", {"faz": "yok", "t": 0.0, "girisT": game.math_utils.f_rnd(14.0, 34.0), "x": J.add(game.j_W, 24.0), "tip": J.getv(v_t, "id"), "hedef": J.method(v_t, "hedef", [game.j_G]), "para": game.progression_system.f_bahisPara(game.j_G), "selam": game.math_utils.f_pick((game.j_RAKIP_SELAM_ILK if J.truth(v_ilk) else game.j_RAKIP_SELAM)), "ilk": v_ilk})
	J.setv(game.j_G, "rakipTanisti", true)
	return null

# game.js:4766
func f_rakipGuncelle(p_dt: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_hx: Variant = null
	var v_dt: Variant = p_dt
	v_R = J.getv(game.j_G, "rakip")
	if ((not J.truth(v_R)) or not J.eq(J.getv(game.j_G, "scene"), "play")):
		return null
	J.setv(v_R, "t", J.add(J.getv(v_R, "t"), v_dt))
	v_hx = (J.add(J.getv(J.getv(J.getv(game.j_LAY, "custSlots"), 0.0), "x"), 34.0) if J.truth(J.getv(J.getv(game.j_LAY, "custSlots"), 0.0)) else (game.j_W * 0.62))
	if J.eq(J.getv(v_R, "faz"), "yok"):
		if J.ge(J.getv(v_R, "t"), J.getv(v_R, "girisT")):
			J.setv(v_R, "faz", "gelis")
			J.setv(v_R, "t", 0.0)
		return null
	if J.eq(J.getv(v_R, "faz"), "gelis"):
		J.setv(v_R, "x", game.math_utils.f_approach(J.getv(v_R, "x"), v_hx, (v_dt * 110.0)))
		if J.lt(abs((J.getv(v_R, "x") - v_hx)), 1.0):
			J.setv(v_R, "faz", "teklif")
			J.setv(v_R, "t", 0.0)
			J.method(game.j_SFX, "door", [])
		return null
	if J.eq(J.getv(v_R, "faz"), "teklif"):
		if J.gt(J.getv(v_R, "t"), 20.0):
			game.rival_system.f_rakipCevap(false, true)
		return null
	if J.eq(J.getv(v_R, "faz"), "gidis"):
		if J.gt(J.getv(v_R, "sonT"), 0.0):
			J.setv(v_R, "sonT", (J.getv(v_R, "sonT") - v_dt))
			return null
		J.setv(v_R, "x", game.math_utils.f_approach(J.getv(v_R, "x"), J.add(game.j_W, 30.0), (v_dt * 110.0)))
		if J.gt(J.getv(v_R, "x"), J.add(game.j_W, 28.0)):
			J.setv(game.j_G, "rakip", null)
	return null

# game.js:4795
func f_bahisMetni(p_R: Variant = null) -> Variant:
	var v_b: Variant = null
	var v_sayi: Variant = null
	var v_R: Variant = p_R
	v_b = game.progression_system.f_bahisTip(J.getv(v_R, "tip"))
	if (not J.truth(v_b)):
		return ""
	if (not J.truth(J.getv(v_b, "on"))):
		return game.localization.f_T(J.getv(v_b, "son"))
	v_sayi = (J.add("$", game.math_utils.f_fmtMoney(J.getv(v_R, "hedef"))) if J.truth(J.getv(v_b, "para")) else J.s(J.getv(v_R, "hedef")))
	return J.add(J.add(J.add(J.add(game.localization.f_T(J.getv(v_b, "on")), " "), v_sayi), " "), game.localization.f_T(J.getv(v_b, "son")))
	return null

# game.js:4803
func f_rakipCevap(p_kabul: Variant = null, p_sessiz: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_kabul: Variant = p_kabul
	var v_sessiz: Variant = p_sessiz
	v_R = J.getv(game.j_G, "rakip")
	if ((not J.truth(v_R)) or not J.eq(J.getv(v_R, "faz"), "teklif")):
		return null
	J.setv(v_R, "faz", "gidis")
	J.setv(v_R, "t", 0.0)
	if (not J.truth(v_kabul)):
		J.setv(v_R, "son", game.math_utils.f_pick((game.j_RAKIP_CEKIL if J.truth(v_sessiz) else game.j_RAKIP_RET)))
		J.setv(v_R, "sonT", 2.6)
		if (not J.truth(v_sessiz)):
			J.method(game.j_SFX, "uiBack", [])
		J.setv(game.j_G, "bahis", null)
		return null
	J.setv(v_R, "son", game.math_utils.f_pick(game.j_RAKIP_KABUL))
	J.setv(v_R, "sonT", 2.6)
	J.method(game.j_SFX, "levelup", [])
	J.setv(game.j_G, "bahis", {"tip": J.getv(v_R, "tip"), "hedef": J.getv(v_R, "hedef"), "para": J.getv(v_R, "para"), "gun": J.getv(game.j_G, "day")})
	game.effects.f_ftext(game.localization.f_T("EL SIKIŞTINIZ"), (float(game.j_W) / float(2.0)), 100.0, J.getv(game.j_P, "au0"), {"sc": 2.0, "life": 1.6})
	return null

# game.js:4822
func f_bahisCoz() -> Variant:
	var v_B: Variant = null
	var v_b: Variant = null
	var v_deger: Variant = null
	var v_kazandi: Variant = null
	v_B = J.getv(game.j_G, "bahis")
	if ((not J.truth(v_B)) or not J.eq(J.getv(v_B, "gun"), J.getv(game.j_G, "day"))):
		J.setv(game.j_G, "bahisSonuc", null)
		return null
	v_b = game.progression_system.f_bahisTip(J.getv(v_B, "tip"))
	if (not J.truth(v_b)):
		J.setv(game.j_G, "bahis", null)
		J.setv(game.j_G, "bahisSonuc", null)
		return null
	v_deger = J.method(v_b, "olc", [game.j_G])
	v_kazandi = J.ge(v_deger, J.getv(v_B, "hedef"))
	J.setv(game.j_G, "money", J.add(J.getv(game.j_G, "money"), (J.getv(v_B, "para") if J.truth(v_kazandi) else (-J.n(J.getv(v_B, "para"))))))
	if J.lt(J.getv(game.j_G, "money"), 0.0):
		J.setv(game.j_G, "money", 0.0)
	J.setv(J.getv(game.j_G, "stats"), "bahisKazan", J.add((J.getv(J.getv(game.j_G, "stats"), "bahisKazan") if J.truth(J.getv(J.getv(game.j_G, "stats"), "bahisKazan")) else 0.0), (1.0 if J.truth(v_kazandi) else 0.0)))
	J.setv(J.getv(game.j_G, "stats"), "bahisKayip", J.add((J.getv(J.getv(game.j_G, "stats"), "bahisKayip") if J.truth(J.getv(J.getv(game.j_G, "stats"), "bahisKayip")) else 0.0), (0.0 if J.truth(v_kazandi) else 1.0)))
	J.setv(game.j_G, "rakipSeri", (J.add((J.getv(game.j_G, "rakipSeri") if J.truth(J.getv(game.j_G, "rakipSeri")) else 0.0), 1.0) if J.truth(v_kazandi) else 0.0))
	if J.ge(J.getv(game.j_G, "rakipSeri"), game.j_RAKIP_PES):
		J.setv(game.j_G, "rakipKapandi", true)
		J.setv(game.j_G, "rakip", null)
	J.setv(game.j_G, "bahisSonuc", {"kazandi": v_kazandi, "para": J.getv(v_B, "para"), "hedef": J.getv(v_B, "hedef"), "deger": v_deger, "tip": J.getv(v_B, "tip"), "kapandi": (not (not J.truth(J.getv(game.j_G, "rakipKapandi"))))})
	J.setv(game.j_G, "bahis", null)
	return null

func _closure_87(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return max(4.0, floor(J.add(6.0, (J.getv(v_G, "day") * 0.22)) + 0.5))
	return null

func _closure_88(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (J.getv(J.getv(v_G, "stat"), "wraps") if J.truth(J.getv(J.getv(v_G, "stat"), "wraps")) else 0.0)
	return null

func _closure_89(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (floor((float(J.add(160.0, (J.getv(v_G, "day") * 26.0))) / float(10.0)) + 0.5) * 10.0)
	return null

func _closure_90(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return ((J.getv(J.getv(v_G, "stat"), "earned") if J.truth(J.getv(J.getv(v_G, "stat"), "earned")) else 0.0) - (J.getv(J.getv(v_G, "stat"), "branch") if J.truth(J.getv(J.getv(v_G, "stat"), "branch")) else 0.0))
	return null

func _closure_91(_args: Array, _captures: Dictionary = {}) -> Variant:
	return 0.0
	return null

func _closure_92(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (-J.n((J.getv(J.getv(v_G, "stat"), "lost") if J.truth(J.getv(J.getv(v_G, "stat"), "lost")) else 0.0)))
	return null

func _closure_93(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (floor((float(J.add(30.0, (J.getv(v_G, "day") * 6.0))) / float(5.0)) + 0.5) * 5.0)
	return null

func _closure_94(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (J.getv(J.getv(v_G, "stat"), "tips") if J.truth(J.getv(J.getv(v_G, "stat"), "tips")) else 0.0)
	return null

