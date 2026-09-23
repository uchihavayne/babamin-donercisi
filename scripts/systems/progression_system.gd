# Progression system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# data.js:64
func f_secimReplik(p_ord: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_i: Variant = null
	var v_ord: Variant = p_ord
	if (((not J.truth(v_ord)) or (not J.truth(J.getv(v_ord, "yok")))) or (not J.truth(J.getv(J.getv(v_ord, "yok"), "length")))):
		return ""
	v_p = []
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_ord, "yok"), "length")):
		J.method(v_p, "push", [game.localization.f_T(J.getv(game.j_SECIM_AD, J.getv(J.getv(v_ord, "yok"), v_i)))])
		v_i = J.add(v_i, 1.0)
	return J.add(J.method(v_p, "join", [", "]), game.localization.f_T(", lütfen."))
	return null

# data.js:100
func f_bahisTip(p_id: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_BAHIS, "length")):
		if J.eq(J.getv(J.getv(game.j_BAHIS, v_i), "id"), v_id):
			return J.getv(game.j_BAHIS, v_i)
		v_i = J.add(v_i, 1.0)
	return null
	return null

# data.js:102
func f_bahisPara(p_G: Variant = null) -> Variant:
	var v_G: Variant = p_G
	return (floor((float(J.add(200.0, (J.getv(v_G, "day") * 34.0))) / float(10.0)) + 0.5) * 10.0)
	return null

# data.js:447
func f_dayCfg(p_d: Variant = null, p_G: Variant = null) -> Variant:
	var v_len: Variant = null
	var v_rate: Variant = null
	var v_d: Variant = p_d
	var v_G: Variant = p_G
	v_len = min(210.0, J.add(J.add(60.0, (v_d * 2.0)), (game.equipment_system.f_upgTotalLv(v_G) * 2.0)))
	v_rate = (float(max(2.0, (6.8 - (v_d * 0.22)))) / float(J.method(game.j_TUN, "custMul", [v_G])))
	return {"len": v_len, "rate": v_rate, "slots": J.method(game.j_TUN, "slots", [v_G])}
	return null

# data.js:607
func f_branchLocked(p_i: Variant = null, p_g: Variant = null) -> Variant:
	var v_i: Variant = p_i
	var v_g: Variant = p_g
	return J.lt(game.equipment_system.f_upgTotalLv(v_g), J.getv(J.getv(game.j_BRANCH, v_i), "req"))
	return null

# data.js:736
func f_liderSozu(p_gun: Variant = null) -> Variant:
	var v_gun: Variant = p_gun
	return J.getv(game.j_LIDER_SOZ, floor((game.f_hash1(J.add((v_gun * 9.13), 2.7)) * J.getv(game.j_LIDER_SOZ, "length"))))
	return null

# data.js:742
func f_gazeteHava(p_gun: Variant = null) -> Variant:
	var v_gun: Variant = p_gun
	return J.getv(game.j_GAZETE_HAVA, floor((game.f_hash1(J.add((v_gun * 4.41), 1.3)) * J.getv(game.j_GAZETE_HAVA, "length"))))
	return null

# data.js:745
func f_gazeteDerece(p_gun: Variant = null) -> Variant:
	var v_gun: Variant = p_gun
	return J.add((-J.n(6.0)), floor((game.f_hash1(J.add((v_gun * 6.19), 5.5)) * 18.0)))
	return null

# data.js:751
func f_haberEtki(p_etki: Variant = null, p_gun: Variant = null) -> Variant:
	var v_g: Variant = null
	var v_h: Variant = null
	var v_i: Variant = null
	var v_etki: Variant = p_etki
	var v_gun: Variant = p_gun
	v_g = (J.getv(game.j_G, "day") if (J.eq(v_gun, null) and not J.eq(J.kind(game.j_G), "undefined")) else v_gun)
	v_h = game.progression_system.f_haberSec(v_g, 3.0)
	v_i = 0.0
	while J.lt(v_i, J.getv(v_h, "length")):
		if J.eq(J.getv(J.getv(v_h, v_i), 2.0), v_etki):
			return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# data.js:758
func f_haberSec(p_gun: Variant = null, p_adet: Variant = null) -> Variant:
	var _v: Dictionary = {"out": null, "kul": null, "i": null, "idx": null, "g": null, "gun": p_gun, "adet": p_adet}
	_v["adet"] = (_v["adet"] if J.truth(_v["adet"]) else 3.0)
	_v["out"] = []
	_v["kul"] = {}
	_v["i"] = 0.0
	while J.lt(_v["i"], _v["adet"]):
		_v["idx"] = floor((game.f_hash1(J.add((_v["gun"] * 3.11), (_v["i"] * 13.7))) * J.getv(game.j_FERMAN_HABER, "length")))
		_v["g"] = 0.0
		while (J.truth(J.getv(_v["kul"], _v["idx"])) and J.lt((J.setv(_v, "g", J.add(_v["g"], 1.0)) - 1.0), J.getv(game.j_FERMAN_HABER, "length"))):
			_v["idx"] = fmod(J.n(J.add(_v["idx"], 1.0)), J.n(J.getv(game.j_FERMAN_HABER, "length")))
		J.setv(_v["kul"], _v["idx"], 1.0)
		J.method(_v["out"], "push", [J.getv(game.j_FERMAN_HABER, _v["idx"])])
		_v["i"] = J.add(_v["i"], 1.0)
	return _v["out"]
	return null

# data.js:772
func f_fermanAdet(p_fgun: Variant = null, p_gun: Variant = null) -> Variant:
	var v_fgun: Variant = p_fgun
	var v_gun: Variant = p_gun
	v_fgun = (v_fgun if J.truth(v_fgun) else 0.0)
	if J.lt(v_fgun, 3.0):
		return 1.0
	if J.lt(v_fgun, 8.0):
		return (2.0 if J.eq(fmod(J.n(v_gun), J.n(2.0)), 0.0) else 1.0)
	if J.lt(v_fgun, 16.0):
		return (3.0 if J.eq(fmod(J.n(v_gun), J.n(3.0)), 0.0) else (1.0 if J.truth(fmod(J.n(v_gun), J.n(2.0))) else 2.0))
	return (3.0 if J.eq(fmod(J.n(v_gun), J.n(3.0)), 0.0) else 2.0)
	return null

# data.js:781
func f_fermanSec(p_gun: Variant = null, p_adet: Variant = null) -> Variant:
	var _cells: Dictionary = {"dunyaVar": [null], "out": [null]}
	var _v: Dictionary = {"n": null, "kullanildi": null, "uygun": null, "i": null, "idx": null, "guard": null, "gun": p_gun, "adet": p_adet}
	_v["uygun"] = game.progression_system._closure_174.bind({"484:dunyaVar": _cells["dunyaVar"], "484:out": _cells["out"]})
	_v["n"] = (_v["adet"] if J.truth(_v["adet"]) else game.progression_system.f_fermanAdet((J.getv(game.j_G, "fgun") if not J.eq(J.kind(game.j_G), "undefined") else 0.0), _v["gun"]))
	_cells["out"][0] = []
	_v["kullanildi"] = {}
	_cells["dunyaVar"][0] = false
	_v["i"] = 0.0
	while J.lt(_v["i"], _v["n"]):
		_v["idx"] = floor((game.f_hash1(J.add((_v["gun"] * 7.3), (_v["i"] * 19.7))) * J.getv(game.j_FERMANLAR, "length")))
		_v["guard"] = 0.0
		while ((J.truth(J.getv(_v["kullanildi"], _v["idx"])) or (not J.truth(J.invoke(_v["uygun"], [J.getv(game.j_FERMANLAR, _v["idx"])])))) and J.lt((J.setv(_v, "guard", J.add(_v["guard"], 1.0)) - 1.0), J.getv(game.j_FERMANLAR, "length"))):
			_v["idx"] = fmod(J.n(J.add(_v["idx"], 1.0)), J.n(J.getv(game.j_FERMANLAR, "length")))
		if (J.truth(J.getv(_v["kullanildi"], _v["idx"])) or (not J.truth(J.invoke(_v["uygun"], [J.getv(game.j_FERMANLAR, _v["idx"])])))):
			_v["i"] = J.add(_v["i"], 1.0)
			continue
		J.setv(_v["kullanildi"], _v["idx"], 1.0)
		if J.eq(J.getv(J.getv(game.j_FERMANLAR, _v["idx"]), "tip"), "dunya"):
			_cells["dunyaVar"][0] = true
		J.method(_cells["out"][0], "push", [J.getv(game.j_FERMANLAR, _v["idx"])])
		_v["i"] = J.add(_v["i"], 1.0)
	return _cells["out"][0]
	return null

# data.js:809
func f_fermanDunya(p_id: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_F = (J.getv(game.j_G, "ferman") if not J.eq(J.kind(game.j_G), "undefined") else not J.eq(J.kind(game.j_G), "undefined"))
	if (not J.truth(v_F)):
		return false
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_F, "liste"), "length")):
		if J.eq(J.getv(J.getv(J.getv(v_F, "liste"), v_i), "id"), v_id):
			return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# data.js:827
func f_liderGunu(p_fgun: Variant = null, p_gun: Variant = null) -> Variant:
	var v_fgun: Variant = p_fgun
	var v_gun: Variant = p_gun
	if J.lt((v_fgun if J.truth(v_fgun) else 0.0), game.j_LIDER_ILK_GUN):
		return false
	return J.lt(game.f_hash1(J.add((v_gun * 5.77), 3.1)), 0.09)
	return null

# data.js:850
func f_evSimdiki() -> Variant:
	return J.getv(game.j_EVLER, game.math_utils.f_clamp((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), 0.0, (J.getv(game.j_EVLER, "length") - 1.0)))
	return null

# data.js:855
func f_fgunEtki(p_fgun: Variant = null) -> Variant:
	var v_fgun: Variant = p_fgun
	return min((v_fgun if J.truth(v_fgun) else 0.0), game.j_FGUN_TAVAN)
	return null

# data.js:858
func f_evKira() -> Variant:
	return J.getv(game.progression_system.f_evSimdiki(), "kira")
	return null

# data.js:885
func f_giderTutar(p_g: Variant = null, p_fgun: Variant = null, p_kisi: Variant = null) -> Variant:
	var v_t: Variant = null
	var v_g: Variant = p_g
	var v_fgun: Variant = p_fgun
	var v_kisi: Variant = p_kisi
	if J.truth(J.getv(v_g, "evBagli")):
		return game.progression_system.f_evKira()
	v_t = J.add(J.getv(v_g, "temel"), floor((J.getv(v_g, "artis") * game.progression_system.f_fgunEtki(v_fgun)) + 0.5))
	if J.eq(J.getv(v_g, "id"), "isinma"):
		v_t = floor((v_t * J.getv(game.progression_system.f_evSimdiki(), "isinma")) + 0.5)
	if J.truth(J.getv(v_g, "kisiBasi")):
		v_t = (v_t * max(0.0, (v_kisi if J.truth(v_kisi) else 0.0)))
	return v_t
	return null

# data.js:893
func f_haneKur() -> Variant:
	return J.method(game.j_HANE_UYE, "map", [game.progression_system._closure_175.bind({})])
	return null

# data.js:896
func f_haneCanli(p_h: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_h: Variant = p_h
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv((v_h if J.truth(v_h) else []), "length")):
		if (not J.truth(J.getv(J.getv(v_h, v_i), "gitti"))):
			v_n = J.add(v_n, 1.0)
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# data.js:901
func f_haneHasta(p_h: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	var v_h: Variant = p_h
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv((v_h if J.truth(v_h) else []), "length")):
		if ((not J.truth(J.getv(J.getv(v_h, v_i), "gitti"))) and J.gt(J.getv(J.getv(v_h, v_i), "hasta"), 0.0)):
			v_n = J.add(v_n, 1.0)
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# data.js:906
func f_fermanSehri(p_g: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_g: Variant = p_g
	v_i = (J.getv(v_g, "city") if (J.truth(v_g) and J.eq(J.kind(J.getv(v_g, "city")), "number")) else (-J.n(1.0)))
	return ((not (not J.truth(J.getv(J.getv(game.j_BRANCH, v_i), "ferman")))) if (J.ge(v_i, 0.0) and J.lt(v_i, J.getv(game.j_BRANCH, "length"))) else (J.lt(v_i, J.getv(game.j_BRANCH, "length")) if J.ge(v_i, 0.0) else J.ge(v_i, 0.0)))
	return null

# data.js:914
func f_nextBranch(p_g: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_g: Variant = p_g
	v_n = (J.getv(v_g, "branch") if J.truth(J.getv(v_g, "branch")) else 0.0)
	return (J.getv(game.j_BRANCH, v_n) if J.lt(v_n, J.getv(game.j_BRANCH, "length")) else null)
	return null

# data.js:919
func f_branchBase(p_g: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_t: Variant = null
	var v_i: Variant = null
	var v_g: Variant = p_g
	v_n = (J.getv(v_g, "branch") if J.truth(J.getv(v_g, "branch")) else 0.0)
	v_t = 0.0
	v_i = 0.0
	while (J.lt(v_i, v_n) and J.lt(v_i, J.getv(game.j_BRANCH, "length"))):
		v_t = J.add(v_t, J.getv(J.getv(game.j_BRANCH, v_i), "inc"))
		v_i = J.add(v_i, 1.0)
	return v_t
	return null

# data.js:928
func f_branchPerf(p_served: Variant = null, p_lost: Variant = null, p_day: Variant = null, p_g: Variant = null) -> Variant:
	var v_tot: Variant = null
	var v_memnun: Variant = null
	var v_hacim: Variant = null
	var v_cfg: Variant = null
	var v_hedef: Variant = null
	var v_served: Variant = p_served
	var v_lost: Variant = p_lost
	var v_day: Variant = p_day
	var v_g: Variant = p_g
	v_tot = J.add(v_served, v_lost)
	v_memnun = ((float(v_served) / float(v_tot)) if J.gt(v_tot, 0.0) else 0.0)
	v_hacim = v_memnun
	if J.truth(v_day):
		v_cfg = game.progression_system.f_dayCfg(v_day, (v_g if J.truth(v_g) else {"up": {}}))
		v_hedef = max(5.0, floor(((float((J.getv(v_cfg, "len") - 25.0)) / float(J.getv(v_cfg, "rate"))) * 0.35)))
		v_hacim = game.math_utils.f_clamp((float(v_served) / float(v_hedef)), 0.0, 1.0)
	return J.add(game.j_BR_MIN, (((game.j_BR_MAX - game.j_BR_MIN) * v_hacim) * J.add(0.55, (0.45 * v_memnun))))
	return null

func _closure_174(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	var v_q: Variant = null
	var v_f: Variant = null
	v_f = J.arg(_args, 0)
	if (J.eq(J.getv(v_f, "tip"), "dunya") and J.truth(_captures["484:dunyaVar"][0])):
		return false
	v_c = J.getv(game.j_FERMAN_CAKISMA, J.getv(v_f, "id"))
	if (not J.truth(v_c)):
		return true
	v_q = 0.0
	while J.lt(v_q, J.getv(_captures["484:out"][0], "length")):
		if J.ge(J.method(v_c, "indexOf", [J.getv(J.getv(_captures["484:out"][0], v_q), "id")]), 0.0):
			return false
		v_q = J.add(v_q, 1.0)
	return true
	return null

func _closure_175(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_u: Variant = null
	v_u = J.arg(_args, 0)
	return {"id": J.getv(v_u, "id"), "ad": J.getv(v_u, "ad"), "ac": 0.0, "hasta": 0.0, "gitti": false}
	return null

