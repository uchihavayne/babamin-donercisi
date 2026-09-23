# Household system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:389
func f_fkasaAcik() -> Variant:
	return game.progression_system.f_fermanSehri(game.j_G)
	return null

# game.js:390
func f_kasaOku() -> Variant:
	return ((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0) if J.truth(game.household_system.f_fkasaAcik()) else J.getv(game.j_G, "money"))
	return null

# game.js:391
func f_kasaEkle(p_n: Variant = null) -> Variant:
	var v_n: Variant = p_n
	if J.truth(game.household_system.f_fkasaAcik()):
		J.setv(game.j_G, "fpara", J.add((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0), v_n))
	else:
		J.setv(game.j_G, "money", J.add(J.getv(game.j_G, "money"), v_n))
	return null

# game.js:395
func f_kasaDus(p_n: Variant = null) -> Variant:
	var v_n: Variant = p_n
	if J.truth(game.household_system.f_fkasaAcik()):
		J.setv(game.j_G, "fpara", ((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0) - v_n))
	else:
		J.setv(game.j_G, "money", max(0.0, (J.getv(game.j_G, "money") - v_n)))
	return null

# game.js:400
func f_fermanEkonomiKur(p_zorla: Variant = null) -> Variant:
	var v_zorla: Variant = p_zorla
	if ((((not J.truth(v_zorla)) and J.truth(J.getv(game.j_G, "hane"))) and J.truth(J.getv(J.getv(game.j_G, "hane"), "length"))) and J.gt(game.progression_system.f_haneCanli(J.getv(game.j_G, "hane")), 0.0)):
		return null
	J.setv(game.j_G, "fpara", game.j_FP_BASLANGIC)
	J.setv(game.j_G, "fgun", 0.0)
	J.setv(game.j_G, "hane", game.progression_system.f_haneKur())
	J.setv(game.j_G, "fbatik", 0.0)
	J.setv(game.j_G, "ev", 0.0)
	return null

# game.js:411
func f_eveTasin(p_i: Variant = null) -> Variant:
	var v_e: Variant = null
	var v_i: Variant = p_i
	if (not J.eq(v_i, J.add((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), 1.0)) or J.ge(v_i, J.getv(game.j_EVLER, "length"))):
		return false
	v_e = J.getv(game.j_EVLER, v_i)
	if J.lt((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0), J.getv(v_e, "pesinat")):
		J.method(game.j_SFX, "bad", [])
		return false
	J.setv(game.j_G, "fpara", (J.getv(game.j_G, "fpara") - J.getv(v_e, "pesinat")))
	J.setv(game.j_G, "ev", v_i)
	J.method(game.j_SFX, "cash", [])
	J.method(game.j_SFX, "levelup", [])
	game.save_system.f_saveAll()
	return true
	return null

# game.js:585
func f_hesapKur() -> Variant:
	var v_kisi: Variant = null
	var v_hasta: Variant = null
	var v_kalem: Variant = null
	var v_sec: Variant = null
	var v_i: Variant = null
	var v_g: Variant = null
	var v_tutar: Variant = null
	if ((not J.truth(J.getv(game.j_G, "hane"))) or (not J.truth(J.getv(J.getv(game.j_G, "hane"), "length")))):
		game.household_system.f_fermanEkonomiKur(true)
	v_kisi = game.progression_system.f_haneCanli(J.getv(game.j_G, "hane"))
	v_hasta = game.progression_system.f_haneHasta(J.getv(game.j_G, "hane"))
	v_kalem = []
	v_sec = {}
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_GIDER, "length")):
		v_g = J.getv(game.j_GIDER, v_i)
		if (J.truth(J.getv(v_g, "hastaGerek")) and J.eq(v_hasta, 0.0)):
			v_i = J.add(v_i, 1.0)
			continue
		v_tutar = game.progression_system.f_giderTutar(v_g, (J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0), (v_kisi if J.eq(J.getv(v_g, "id"), "yemek") else (v_hasta if J.truth(v_hasta) else 1.0)))
		if J.eq(J.getv(v_g, "id"), "ilac"):
			v_tutar = (game.progression_system.f_giderTutar(v_g, (J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0)) * v_hasta)
		J.method(v_kalem, "push", [{"id": J.getv(v_g, "id"), "ad": J.getv(v_g, "ad"), "zorunlu": J.getv(v_g, "zorunlu"), "tutar": v_tutar}])
		J.setv(v_sec, J.getv(v_g, "id"), true)
		v_i = J.add(v_i, 1.0)
	return {"kalem": v_kalem, "sec": v_sec, "t": 0.0, "kisi": v_kisi, "hasta": v_hasta, "gelir": (J.getv(J.getv(game.j_G, "stat"), "earned") if J.truth(J.getv(J.getv(game.j_G, "stat"), "earned")) else 0.0), "ceza": (J.getv(J.getv(game.j_G, "stat"), "fine") if J.truth(J.getv(J.getv(game.j_G, "stat"), "fine")) else 0.0), "kapandi": false, "oncekiKasa": (J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0), "sonKasa": null}
	return null

# game.js:604
func f_hesapToplam(p_H: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_H: Variant = p_H
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_H, "kalem"), "length")):
		if J.truth(J.getv(J.getv(v_H, "sec"), J.getv(J.getv(J.getv(v_H, "kalem"), v_i), "id"))):
			v_n = J.add(v_n, J.getv(J.getv(J.getv(v_H, "kalem"), v_i), "tutar"))
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# game.js:609
func f_hesapKalan(p_H: Variant = null) -> Variant:
	var v_H: Variant = p_H
	return ((J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0) - game.household_system.f_hesapToplam(v_H))
	return null

# game.js:612
func f_hesapKapat() -> Variant:
	var v_H: Variant = null
	var v_olay: Variant = null
	var v_canli: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	var v_soguk: Variant = null
	var v_k: Variant = null
	var v_a: Variant = null
	var v_b: Variant = null
	var v_c: Variant = null
	v_H = J.getv(game.j_G, "hesap")
	if ((not J.truth(v_H)) or J.truth(J.getv(v_H, "kapandi"))):
		return null
	if ((not J.truth(J.getv(game.j_G, "hane"))) or (not J.truth(J.getv(J.getv(game.j_G, "hane"), "length")))):
		J.setv(game.j_G, "hane", game.progression_system.f_haneKur())
	J.setv(v_H, "kapandi", true)
	J.setv(v_H, "oncekiKasa", (J.getv(game.j_G, "fpara") if J.truth(J.getv(game.j_G, "fpara")) else 0.0))
	J.setv(game.j_G, "fpara", game.household_system.f_hesapKalan(v_H))
	J.setv(v_H, "sonKasa", J.getv(game.j_G, "fpara"))
	v_olay = []
	v_canli = J.method(J.getv(game.j_G, "hane"), "filter", [game.household_system._closure_240.bind({})])
	if (not J.truth(J.getv(J.getv(v_H, "sec"), "yemek"))):
		v_i = 0.0
		while J.lt(v_i, J.getv(v_canli, "length")):
			J.setv(J.getv(v_canli, v_i), "ac", J.add(J.getv(J.getv(v_canli, v_i), "ac"), 1.0))
			v_i = J.add(v_i, 1.0)
		J.method(v_olay, "push", [{"tip": "ac", "ek": "Ailen aç yattı"}])
	else:
		v_j = 0.0
		while J.lt(v_j, J.getv(v_canli, "length")):
			J.setv(J.getv(v_canli, v_j), "ac", 0.0)
			v_j = J.add(v_j, 1.0)
	v_soguk = (J.eq(J.getv(game.j_G, "weather"), "rain") if J.eq(J.getv(game.j_G, "weather"), "rain") else J.eq(fmod(J.n((J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0)), J.n(3.0)), 1.0))
	if ((((not J.truth(J.getv(J.getv(v_H, "sec"), "isinma"))) and J.truth(v_soguk)) and J.truth(J.getv(v_canli, "length"))) and J.truth(game.f_chance(game.math_utils.f_clamp((0.62 * J.getv(game.progression_system.f_evSimdiki(), "hasta")), 0.0, 1.0)))):
		v_k = J.getv(v_canli, floor((game.random_unit() * J.getv(v_canli, "length"))))
		J.setv(v_k, "hasta", J.add(J.getv(v_k, "hasta"), 1.0))
		J.method(v_olay, "push", [{"tip": "hasta", "ad": J.getv(v_k, "ad"), "ek": " soğuktan hastalandı"}])
	v_a = 0.0
	while J.lt(v_a, J.getv(v_canli, "length")):
		if J.ge(J.getv(J.getv(v_canli, v_a), "ac"), 3.0):
			J.setv(J.getv(v_canli, v_a), "ac", 1.0)
			J.setv(J.getv(v_canli, v_a), "hasta", J.add(J.getv(J.getv(v_canli, v_a), "hasta"), 1.0))
			J.method(v_olay, "push", [{"tip": "hasta", "ad": J.getv(J.getv(v_canli, v_a), "ad"), "ek": " açlıktan hastalandı"}])
		v_a = J.add(v_a, 1.0)
	if J.truth(J.getv(J.getv(v_H, "sec"), "ilac")):
		v_b = 0.0
		while J.lt(v_b, J.getv(v_canli, "length")):
			if J.gt(J.getv(J.getv(v_canli, v_b), "hasta"), 0.0):
				J.setv(J.getv(v_canli, v_b), "hasta", (J.getv(J.getv(v_canli, v_b), "hasta") - 1.0))
			v_b = J.add(v_b, 1.0)
		J.method(v_olay, "push", [{"tip": "iyi", "ek": "İlaç alındı"}])
	v_c = 0.0
	while J.lt(v_c, J.getv(v_canli, "length")):
		if J.ge(J.getv(J.getv(v_canli, v_c), "hasta"), 3.0):
			J.setv(J.getv(v_canli, v_c), "gitti", true)
			J.method(v_olay, "push", [{"tip": "kotu", "ad": J.getv(J.getv(v_canli, v_c), "ad"), "ek": " hastaneye götürüldü"}])
		v_c = J.add(v_c, 1.0)
	if J.lt(J.getv(game.j_G, "fpara"), 0.0):
		J.setv(game.j_G, "fbatik", J.add((J.getv(game.j_G, "fbatik") if J.truth(J.getv(game.j_G, "fbatik")) else 0.0), 1.0))
	else:
		J.setv(game.j_G, "fbatik", 0.0)
	if J.ge(J.getv(game.j_G, "fbatik"), game.j_FP_BATIK_SINIR):
		J.method(v_olay, "push", [{"tip": "kotu", "ek": "Kira ödenmedi — tahliye"}])
	if J.eq(game.progression_system.f_haneCanli(J.getv(game.j_G, "hane")), 0.0):
		J.method(v_olay, "push", [{"tip": "kotu", "ek": "Evde kimse kalmadı"}])
	J.setv(v_H, "olay", v_olay)
	J.setv(game.j_G, "fgun", J.add((J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0), 1.0))
	game.save_system.f_saveAll()
	return null

func _closure_240(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_u: Variant = null
	v_u = J.arg(_args, 0)
	return (not J.truth(J.getv(v_u, "gitti")))
	return null
