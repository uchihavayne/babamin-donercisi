# Appearance system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:323
func f_yeniTip(p_r: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_r: Variant = p_r
	v_a = J.invoke(v_r, [])
	return ("adam" if J.lt(v_a, 0.42) else ("kadin" if J.lt(v_a, 0.8) else "cocuk"))
	return null

# chars.js:327
func f_yeniYuz(p_r: Variant = null) -> Variant:
	var v_y: Variant = null
	var v_r: Variant = p_r
	v_y = J.invoke(v_r, [])
	return {"sekil": floor((J.invoke(v_r, []) * 5.0)), "goz": floor((J.invoke(v_r, []) * 6.0)), "gozR": floor((J.invoke(v_r, []) * 4.0)), "burun": floor((J.invoke(v_r, []) * 5.0)), "kas": floor((J.invoke(v_r, []) * 5.0)), "agiz": floor((J.invoke(v_r, []) * 5.0)), "gozB": floor((J.invoke(v_r, []) * 6.0)), "oran": floor((J.invoke(v_r, []) * 3.0)), "aralik": floor((J.invoke(v_r, []) * 3.0)), "agizU": floor((J.invoke(v_r, []) * 3.0)), "kulak": floor((J.invoke(v_r, []) * 3.0)), "cene": floor((J.invoke(v_r, []) * 3.0)), "yas": (0.0 if J.lt(v_y, 0.58) else (1.0 if J.lt(v_y, 0.82) else 2.0)), "yanak": J.lt(J.invoke(v_r, []), 0.28), "cil": J.lt(J.invoke(v_r, []), 0.17), "ben": (J.add(1.0, floor((J.invoke(v_r, []) * 3.0))) if J.lt(J.invoke(v_r, []), 0.15) else 0.0)}
	return null

# chars.js:418
func f_yuzKimlik(p_L: Variant = null) -> Variant:
	var v_h: Variant = null
	var v_F: Variant = null
	var v_yv: Variant = null
	var v_L: Variant = p_L
	v_h = (J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0)
	v_F = J.getv(v_L, "yuz")
	if (not J.truth(v_F)):
		v_F = {}
	if J.eq(J.getv(v_F, "sekil"), null):
		J.setv(v_F, "sekil", floor((game.f_hash1((v_h * 1.3)) * 5.0)))
	if J.eq(J.getv(v_F, "goz"), null):
		J.setv(v_F, "goz", floor((game.f_hash1((v_h * 1.7)) * 6.0)))
	if J.eq(J.getv(v_F, "gozR"), null):
		J.setv(v_F, "gozR", floor((game.f_hash1((v_h * 2.1)) * 4.0)))
	if J.eq(J.getv(v_F, "burun"), null):
		J.setv(v_F, "burun", floor((game.f_hash1((v_h * 3.1)) * 5.0)))
	if J.eq(J.getv(v_F, "kas"), null):
		J.setv(v_F, "kas", floor((game.f_hash1((v_h * 5.3)) * 5.0)))
	if J.eq(J.getv(v_F, "agiz"), null):
		J.setv(v_F, "agiz", floor((game.f_hash1((v_h * 7.9)) * 5.0)))
	if J.eq(J.getv(v_F, "gozB"), null):
		J.setv(v_F, "gozB", floor((game.f_hash1((v_h * 2.7)) * 6.0)))
	if J.eq(J.getv(v_F, "oran"), null):
		J.setv(v_F, "oran", floor((game.f_hash1((v_h * 4.1)) * 3.0)))
	if J.eq(J.getv(v_F, "aralik"), null):
		J.setv(v_F, "aralik", floor((game.f_hash1((v_h * 6.7)) * 3.0)))
	if J.eq(J.getv(v_F, "agizU"), null):
		J.setv(v_F, "agizU", floor((game.f_hash1((v_h * 8.3)) * 3.0)))
	if J.eq(J.getv(v_F, "kulak"), null):
		J.setv(v_F, "kulak", floor((game.f_hash1((v_h * 9.1)) * 3.0)))
	if J.eq(J.getv(v_F, "cene"), null):
		J.setv(v_F, "cene", floor((game.f_hash1((v_h * 13.7)) * 3.0)))
	if J.eq(J.getv(v_F, "yas"), null):
		v_yv = game.f_hash1((v_h * 17.3))
		J.setv(v_F, "yas", (0.0 if J.lt(v_yv, 0.58) else (1.0 if J.lt(v_yv, 0.82) else 2.0)))
	if J.eq(J.getv(v_F, "yanak"), null):
		J.setv(v_F, "yanak", J.lt(game.f_hash1((v_h * 11.3)), 0.28))
	if J.eq(J.getv(v_F, "cil"), null):
		J.setv(v_F, "cil", J.lt(game.f_hash1((v_h * 19.1)), 0.17))
	if J.eq(J.getv(v_F, "ben"), null):
		J.setv(v_F, "ben", (J.add(1.0, floor((game.f_hash1((v_h * 29.3)) * 3.0))) if J.lt(game.f_hash1((v_h * 23.9)), 0.15) else 0.0))
	J.setv(v_L, "yuz", v_F)
	return v_F
	return null

# chars.js:452
func f_fermanGorunum(p_L: Variant = null) -> Variant:
	var v_KK: Variant = null
	var v_yk: Variant = null
	var v_L: Variant = p_L
	if (((J.truth(J.getv(v_L, "kalip")) and not J.eq(J.getv(v_L, "kalip"), "yok")) and J.truth(J.getv(game.appearance_system.f_kalipById(J.getv(v_L, "kalip")), "baslik"))) and ((J.eq(J.getv(v_L, "acc"), "cap") or J.eq(J.getv(v_L, "acc"), "kufiya")) or J.eq(J.getv(v_L, "acc"), "band"))):
		J.setv(v_L, "acc", "none")
	if (J.truth(J.getv(v_L, "kalip")) and J.truth(J.getv(game.j_OZEL_KALIP, J.getv(v_L, "kalip")))):
		J.setv(v_L, "acc", "none")
		J.setv(v_L, "mustache", false)
		J.setv(v_L, "hair", (-J.n(1.0)))
		if (J.eq(J.getv(v_L, "kalip"), "cirak") or J.eq(J.getv(v_L, "kalip"), "kimyager")):
			J.setv(v_L, "acc", "glasses")
			J.setv(v_L, "glTip", 1.0)
		v_KK = J.getv(game.j_KALIP_KIMLIK, J.getv(v_L, "kalip"))
		if J.truth(v_KK):
			J.setv(v_L, "tip", J.getv(v_KK, "tip"))
			J.setv(v_L, "skin", J.getv(v_KK, "skin"))
			J.setv(v_L, "big", J.getv(v_KK, "big"))
			if (not J.truth(J.getv(v_L, "yuz"))):
				J.setv(v_L, "yuz", game.appearance_system.f_yeniYuz(J.ref(game.random_unit, 0)))
			for _key_81 in J.keys(J.getv(v_KK, "yuz")):
				v_yk = _key_81
				if J.truth(J.method(J.getv(v_KK, "yuz"), "hasOwnProperty", [v_yk])):
					J.setv(J.getv(v_L, "yuz"), v_yk, J.getv(J.getv(v_KK, "yuz"), v_yk))
	if not J.eq(J.kind(J.ref(game.progression_system.f_fermanDunya, 1)), "function"):
		return v_L
	if J.truth(game.progression_system.f_fermanDunya("tekTip")):
		J.setv(v_L, "shirtCol", game.j_FERMAN_TULUM)
		J.setv(v_L, "shirt", 0.0)
	if (J.truth(game.progression_system.f_fermanDunya("bassiz")) and ((J.eq(J.getv(v_L, "acc"), "cap") or J.eq(J.getv(v_L, "acc"), "kufiya")) or J.eq(J.getv(v_L, "acc"), "band"))):
		J.setv(v_L, "acc", "none")
	if J.truth(game.progression_system.f_fermanDunya("tras")):
		J.setv(v_L, "mustache", false)
		if J.eq(J.getv(v_L, "acc"), "beard"):
			J.setv(v_L, "acc", "none")
	return v_L
	return null

# chars.js:491
func f_newCustomerLook(p_seed: Variant = null) -> Variant:
	var _cells: Dictionary = {"r": [null], "a0": [null], "t0": [null]}
	var v_P: Variant = null
	var v_tm: Variant = null
	var v_sec: Variant = null
	var v_a: Variant = null
	var v_acc: Variant = null
	var v_esik: Variant = null
	var v_K: Variant = null
	var v_sira: Variant = null
	var v_i: Variant = null
	var v_tp: Variant = null
	var v_tenI: Variant = null
	var v_seed: Variant = p_seed
	v_sec = game.appearance_system._closure_82.bind({"358:r": _cells["r"]})
	_cells["r"][0] = J.ref(game.random_unit, 0)
	v_P = null
	if J.eq(J.kind(J.ref(game.city_system.f_sehirTema, 0)), "function"):
		v_tm = game.city_system.f_sehirTema()
		if (J.truth(v_tm) and J.truth(J.getv(v_tm, "musteri"))):
			v_P = J.getv(v_tm, "musteri")
	if (not J.truth(v_P)):
		_cells["a0"][0] = J.invoke(_cells["r"][0], [])
		_cells["t0"][0] = game.appearance_system.f_yeniTip(_cells["r"][0])
		return game.appearance_system.f_fermanGorunum({"skin": floor((J.invoke(_cells["r"][0], []) * J.getv(game.j_SKINS, "length"))), "hair": (J.add(8.0, floor((J.invoke(_cells["r"][0], []) * 3.0))) if J.eq(_cells["t0"][0], "kadin") else floor((J.invoke(_cells["r"][0], []) * 8.0))), "hairCol": floor((J.invoke(_cells["r"][0], []) * J.getv(game.j_HAIRCOLS, "length"))), "shirt": floor((J.invoke(_cells["r"][0], []) * J.getv(game.j_SHIRTS, "length"))), "acc": J.invoke(game.appearance_system._closure_83.bind({"358:a0": _cells["a0"], "358:t0": _cells["t0"]}), []), "mustache": (J.lt(J.invoke(_cells["r"][0], []), 0.38) if J.eq(_cells["t0"][0], "adam") else J.eq(_cells["t0"][0], "adam")), "big": (false if J.eq(_cells["t0"][0], "cocuk") else J.lt(J.invoke(_cells["r"][0], []), 0.32)), "yuz": game.appearance_system.f_yeniYuz(_cells["r"][0]), "kalip": (game.appearance_system.f_kalipSec(_cells["r"][0], _cells["t0"][0], true) if J.truth(game.j_KALIP_ACIK) else "yok"), "tip": _cells["t0"][0], "seed": v_seed})
	v_a = J.invoke(_cells["r"][0], [])
	v_acc = "none"
	v_esik = 0.0
	v_K = J.getv(v_P, "aks")
	v_sira = ["glasses", "cap", "kufiya", "band", "beard"]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_sira, "length")):
		v_esik = J.add(v_esik, (J.getv(v_K, J.getv(v_sira, v_i)) if J.truth(J.getv(v_K, J.getv(v_sira, v_i))) else 0.0))
		if J.lt(v_a, v_esik):
			v_acc = J.getv(v_sira, v_i)
			break
		v_i = J.add(v_i, 1.0)
	v_tp = game.appearance_system.f_yeniTip(_cells["r"][0])
	v_tenI = (floor((J.invoke(_cells["r"][0], []) * J.getv(game.j_SKINS, "length"))) if J.lt(J.invoke(_cells["r"][0], []), 0.22) else J.invoke(v_sec, [J.getv(v_P, "ten")]))
	return game.appearance_system.f_fermanGorunum({"skin": game.math_utils.f_clamp(v_tenI, 0.0, (J.getv(game.j_SKINS, "length") - 1.0)), "hair": (J.add(8.0, floor((J.invoke(_cells["r"][0], []) * 3.0))) if J.eq(v_tp, "kadin") else floor((J.invoke(_cells["r"][0], []) * 8.0))), "hairCol": game.math_utils.f_clamp(J.invoke(v_sec, [J.getv(v_P, "sac")]), 0.0, (J.getv(game.j_HAIRCOLS, "length") - 1.0)), "shirt": floor((J.invoke(_cells["r"][0], []) * J.getv(game.j_SHIRTS, "length"))), "shirtCol": J.invoke(v_sec, [J.getv(v_P, "gomlek")]), "acc": (v_acc if J.eq(v_tp, "adam") else ("none" if (J.eq(v_acc, "beard") or J.eq(v_acc, "kufiya")) else v_acc)), "mustache": (J.lt(J.invoke(_cells["r"][0], []), (0.38 if J.eq(J.getv(v_P, "biyik"), null) else J.getv(v_P, "biyik"))) if J.eq(v_tp, "adam") else J.eq(v_tp, "adam")), "big": (false if J.eq(v_tp, "cocuk") else J.lt(J.invoke(_cells["r"][0], []), 0.32)), "yuz": game.appearance_system.f_yeniYuz(_cells["r"][0]), "kalip": (game.appearance_system.f_kalipSec(_cells["r"][0], v_tp, true) if J.truth(game.j_KALIP_ACIK) else "yok"), "tip": v_tp, "seed": v_seed})
	return null

# chars.js:1043
func f_ozelKalipSec(p_tip: Variant = null) -> Variant:
	var _cells: Dictionary = {"gec": [null]}
	var _v: Dictionary = {"aday": null, "i": null, "tip": p_tip}
	if (not J.truth(game.j_OZEL_ACIK)):
		return null
	if (J.eq(J.kind(game.j_G), "undefined") or (not J.truth(game.j_G))):
		return null
	if J.truth(J.getv(game.j_G, "ozelBugun")):
		return null
	if J.lt((J.getv(game.j_G, "day") if J.truth(J.getv(game.j_G, "day")) else 1.0), (J.getv(game.j_G, "ozelHedef") if J.truth(J.getv(game.j_G, "ozelHedef")) else game.j_OZEL_ILK_MIN)):
		return null
	_v["aday"] = []
	_v["i"] = 0.0
	while J.lt(_v["i"], J.getv(game.j_KALIP, "length")):
		if J.truth(J.getv(game.j_OZEL_KALIP, J.getv(J.getv(game.j_KALIP, _v["i"]), "id"))):
			J.method(_v["aday"], "push", [J.getv(J.getv(game.j_KALIP, _v["i"]), "id")])
		_v["i"] = J.add(_v["i"], 1.0)
	if (not J.truth(J.getv(_v["aday"], "length"))):
		return null
	_cells["gec"][0] = (J.getv(game.j_G, "ozelGecmis") if J.truth(J.getv(game.j_G, "ozelGecmis")) else J.setv(game.j_G, "ozelGecmis", {}))
	J.method(_v["aday"], "sort", [game.appearance_system._closure_85.bind({"365:gec": _cells["gec"]})])
	return J.getv(_v["aday"], floor((game.random_unit() * min(2.0, J.getv(_v["aday"], "length")))))
	return null

# chars.js:1066
func f_ozelKalipIsaretle(p_id: Variant = null, p_r: Variant = null) -> Variant:
	var v_ek: Variant = null
	var v_id: Variant = p_id
	var v_r: Variant = p_r
	if (J.eq(J.kind(game.j_G), "undefined") or (not J.truth(game.j_G))):
		return null
	J.setv(game.j_G, "ozelBugun", true)
	if (not J.truth(J.getv(game.j_G, "ozelGecmis"))):
		J.setv(game.j_G, "ozelGecmis", {})
	J.setv(J.getv(game.j_G, "ozelGecmis"), v_id, (J.getv(game.j_G, "day") if J.truth(J.getv(game.j_G, "day")) else 1.0))
	v_ek = J.add(game.j_OZEL_ARA_MIN, floor(((J.invoke(v_r, []) if J.truth(v_r) else game.random_unit()) * J.add((game.j_OZEL_ARA_MAK - game.j_OZEL_ARA_MIN), 1.0))))
	J.setv(game.j_G, "ozelHedef", J.add((J.getv(game.j_G, "day") if J.truth(J.getv(game.j_G, "day")) else 1.0), v_ek))
	return null

# chars.js:1125
func f_kalipById(p_id: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_KALIP, "length")):
		if J.eq(J.getv(J.getv(game.j_KALIP, v_i), "id"), v_id):
			return J.getv(game.j_KALIP, v_i)
		v_i = J.add(v_i, 1.0)
	return J.getv(game.j_KALIP, 0.0)
	return null

# chars.js:1129
func f_kalipSec(p_r: Variant = null, p_tip: Variant = null, p_ozelOlabilir: Variant = null) -> Variant:
	var _v: Dictionary = {"OZ": null, "oz": null, "uygun": null, "top": null, "i": null, "k": null, "a": null, "j": null, "r": p_r, "tip": p_tip, "ozelOlabilir": p_ozelOlabilir}
	if (J.truth(game.j_KALIP_TEST) and J.truth(game.j_OZEL_ACIK)):
		if J.eq(_v["tip"], "cocuk"):
			return "cirak"
		_v["OZ"] = ["kuzeyli", "kimyager", "cirak", "kralice", "bilge"]
		return J.getv(_v["OZ"], fmod(J.n((J.setv(game, "j__kalipSira", J.add(game.j__kalipSira, 1.0)) - 1.0)), J.n(J.getv(_v["OZ"], "length"))))
	if J.truth(_v["ozelOlabilir"]):
		_v["oz"] = game.appearance_system.f_ozelKalipSec(_v["tip"])
		if (J.truth(_v["oz"]) and J.lt(J.invoke(_v["r"], []), game.j_OZEL_SANS)):
			game.appearance_system.f_ozelKalipIsaretle(_v["oz"], _v["r"])
			return _v["oz"]
	_v["uygun"] = []
	_v["top"] = 0.0
	_v["i"] = 0.0
	while J.lt(_v["i"], J.getv(game.j_KALIP, "length")):
		_v["k"] = J.getv(game.j_KALIP, _v["i"])
		if J.le(J.getv(_v["k"], "w"), 0.0):
			_v["i"] = J.add(_v["i"], 1.0)
			continue
		if (J.eq(J.getv(_v["k"], "tip"), "buyuk") and J.eq(_v["tip"], "cocuk")):
			_v["i"] = J.add(_v["i"], 1.0)
			continue
		if ((not J.eq(J.getv(_v["k"], "tip"), "hepsi") and not J.eq(J.getv(_v["k"], "tip"), "buyuk")) and not J.eq(J.getv(_v["k"], "tip"), _v["tip"])):
			_v["i"] = J.add(_v["i"], 1.0)
			continue
		J.method(_v["uygun"], "push", [_v["k"]])
		_v["top"] = J.add(_v["top"], J.getv(_v["k"], "w"))
		_v["i"] = J.add(_v["i"], 1.0)
	_v["a"] = (J.invoke(_v["r"], []) * _v["top"])
	_v["j"] = 0.0
	while J.lt(_v["j"], J.getv(_v["uygun"], "length")):
		_v["a"] = (_v["a"] - J.getv(J.getv(_v["uygun"], _v["j"]), "w"))
		if J.le(_v["a"], 0.0):
			return J.getv(J.getv(_v["uygun"], _v["j"]), "id")
		_v["j"] = J.add(_v["j"], 1.0)
	return "yok"
	return null

# chars.js:1156
func f_kalipKimlik(p_L: Variant = null) -> Variant:
	var _cells: Dictionary = {"i": [null], "h": [null]}
	var v_L: Variant = p_L
	if (not J.truth(game.j_KALIP_ACIK)):
		return "yok"
	if J.truth(J.getv(v_L, "kalip")):
		return J.getv(v_L, "kalip")
	_cells["h"][0] = ((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0) * 37.7)
	_cells["i"][0] = 0.0
	J.setv(v_L, "kalip", game.appearance_system.f_kalipSec(game.appearance_system._closure_86.bind({"370:i": _cells["i"], "370:h": _cells["h"]}), (J.getv(v_L, "tip") if J.truth(J.getv(v_L, "tip")) else "adam")))
	return J.getv(v_L, "kalip")
	return null

# chars.js:1185
func f_kalipAna(p_id: Variant = null, p_seed: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_id: Variant = p_id
	var v_seed: Variant = p_seed
	v_R = J.getv(game.j_KALIP_RENK, v_id)
	if (not J.truth(v_R)):
		return null
	return J.getv(J.getv(v_R, "ana"), floor((game.f_hash1(((v_seed if J.truth(v_seed) else 1.0) * 5.9)) * J.getv(J.getv(v_R, "ana"), "length"))))
	return null

# chars.js:1195
func f_kalipZemin(p_x: Variant = null, p_by: Variant = null, p_bw: Variant = null, p_ana: Variant = null, p_kolAtla: Variant = null) -> Variant:
	var v_sol: Variant = null
	var v_sag: Variant = null
	var v_x: Variant = p_x
	var v_by: Variant = p_by
	var v_bw: Variant = p_bw
	var v_ana: Variant = p_ana
	var v_kolAtla: Variant = p_kolAtla
	v_sol = floor((v_x - (float(v_bw) / float(2.0))) + 0.5)
	v_sag = floor(J.add(v_x, (float(v_bw) / float(2.0))) + 0.5)
	game.f_ell(v_x, J.add(v_by, 5.0), (float(v_bw) / float(2.0)), 7.0, game.character_draw.f_shadeCol(v_ana, 0.72))
	game.f_fr(v_sol, J.add(v_by, 5.0), v_bw, 26.0, game.character_draw.f_shadeCol(v_ana, 0.72))
	game.f_ell(v_x, J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 1.0), 6.0, v_ana)
	game.f_fr(J.add(v_sol, 1.0), J.add(v_by, 4.0), (v_bw - 2.0), 26.0, v_ana)
	game.f_fr(J.add(v_sol, 1.0), J.add(v_by, 5.0), 7.0, 25.0, game.character_draw.f_shadeCol(v_ana, 1.14))
	J.setv(game.j_ctx, "globalAlpha", 0.2)
	game.f_fr(J.add(v_x, 3.0), J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 3.0), 27.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (not J.truth(v_kolAtla)):
		game.f_fr((v_sol - 3.0), J.add(v_by, 8.0), 5.0, 22.0, game.character_draw.f_shadeCol(v_ana, 0.8))
		game.f_fr((v_sol - 3.0), J.add(v_by, 8.0), 4.0, 21.0, game.character_draw.f_shadeCol(v_ana, 0.92))
		game.f_fr((v_sag - 2.0), J.add(v_by, 8.0), 5.0, 22.0, game.character_draw.f_shadeCol(v_ana, 0.66))
	return null

# chars.js:1211
func f_kalipYaka(p_x: Variant = null, p_by: Variant = null, p_sh: Variant = null, p_s: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_by: Variant = p_by
	var v_sh: Variant = p_sh
	var v_s: Variant = p_s
	game.f_fr((v_x - 6.0), J.add(v_by, 2.0), 12.0, 4.0, game.character_draw.f_shadeCol(v_sh, 0.62))
	game.f_fr((v_x - 3.0), J.add(v_by, 1.0), 6.0, 5.0, J.getv(v_s, 1.0))
	return null

func _closure_82(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_dizi: Variant = null
	v_dizi = J.arg(_args, 0)
	return J.getv(v_dizi, floor((J.invoke(_captures["358:r"][0], []) * J.getv(v_dizi, "length"))))
	return null

func _closure_83(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_a: Variant = null
	v_a = ("glasses" if J.lt(_captures["358:a0"][0], 0.15) else ("cap" if J.lt(_captures["358:a0"][0], 0.28) else ("kufiya" if J.lt(_captures["358:a0"][0], 0.4) else ("band" if J.lt(_captures["358:a0"][0], 0.5) else ("beard" if J.lt(_captures["358:a0"][0], 0.62) else "none")))))
	if (not J.eq(_captures["358:t0"][0], "adam") and (J.eq(v_a, "beard") or J.eq(v_a, "kufiya"))):
		v_a = "none"
	return v_a
	return null

func _closure_85(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_a: Variant = null
	var v_b: Variant = null
	v_a = J.arg(_args, 0)
	v_b = J.arg(_args, 1)
	return ((J.getv(_captures["365:gec"][0], v_a) if J.truth(J.getv(_captures["365:gec"][0], v_a)) else (-J.n(9999.0))) - (J.getv(_captures["365:gec"][0], v_b) if J.truth(J.getv(_captures["365:gec"][0], v_b)) else (-J.n(9999.0))))
	return null

func _closure_86(_args: Array, _captures: Dictionary = {}) -> Variant:
	_captures["370:i"][0] = J.add(_captures["370:i"][0], 1.0)
	return game.f_hash1(J.add(_captures["370:h"][0], (_captures["370:i"][0] * 1.7)))
	return null
