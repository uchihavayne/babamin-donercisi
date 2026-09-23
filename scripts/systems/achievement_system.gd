# Achievement system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# basarim.js:297
func f_bsSteamId(p_b: Variant = null) -> Variant:
	var v_b: Variant = p_b
	return J.add("ACH_", J.method(J.getv(v_b, "id"), "toUpperCase", []))
	return null

# basarim.js:298
func f_bsGcId(p_b: Variant = null) -> Variant:
	var v_b: Variant = p_b
	return J.add(J.add(game.j_BS_BUNDLE, ".ach."), J.getv(v_b, "id"))
	return null

# basarim.js:301
func f_bsAd(p_b: Variant = null) -> Variant:
	var v_b: Variant = p_b
	return game.localization.f_T(J.getv(v_b, "ad"))
	return null

# basarim.js:302
func f_bsAc(p_b: Variant = null) -> Variant:
	var v_b: Variant = p_b
	return game.localization.f_T(J.getv(v_b, "ac"))
	return null

# basarim.js:304
func f_bsIng(p_s: Variant = null) -> Variant:
	var v_s: Variant = p_s
	return ((J.getv(game.j_EN, v_s) if not J.eq(J.kind(game.j_EN), "undefined") else not J.eq(J.kind(game.j_EN), "undefined")) if (not J.eq(J.kind(game.j_EN), "undefined") and J.truth(J.getv(game.j_EN, v_s))) else v_s)
	return null

# basarim.js:305
func f_bsUpgTavan() -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_UPG, "length")):
		v_n = J.add(v_n, J.getv(J.getv(J.getv(game.j_UPG, v_i), "lv"), "length"))
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# basarim.js:310
func f_bsSehirSayisi(p_S: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_S: Variant = p_S
	v_a = (J.getv(v_S, "sehir") if J.truth(v_S) else v_S)
	return (J.getv(v_a, "length") if (J.truth(v_a) and J.truth(J.getv(v_a, "length"))) else 0.0)
	return null

# basarim.js:314
func f_basarimById(p_id: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = p_id
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_BASARIM, "length")):
		if J.eq(J.getv(J.getv(game.j_BASARIM, v_i), "id"), v_id):
			return J.getv(game.j_BASARIM, v_i)
		v_i = J.add(v_i, 1.0)
	return null
	return null

# basarim.js:318
func f_basarimAcik(p_id: Variant = null) -> Variant:
	var v_id: Variant = p_id
	return (not (not (J.truth(J.getv(game.j_G, "bs")) and J.truth(J.getv(J.getv(game.j_G, "bs"), v_id)))))
	return null

# basarim.js:319
func f_basarimSayisi() -> Variant:
	var v_n: Variant = null
	var v_i: Variant = null
	v_n = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_BASARIM, "length")):
		if J.truth(game.achievement_system.f_basarimAcik(J.getv(J.getv(game.j_BASARIM, v_i), "id"))):
			v_n = J.add(v_n, 1.0)
		v_i = J.add(v_i, 1.0)
	return v_n
	return null

# basarim.js:325
func f_basarimOran(p_b: Variant = null) -> Variant:
	var v_v: Variant = null
	var v_e: Variant = null
	var v_b: Variant = p_b
	if J.truth(game.achievement_system.f_basarimAcik(J.getv(v_b, "id"))):
		return 1.0
	v_v = 0.0
	v_v = (J.method(v_b, "oku", [(J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {}), game.j_G]) if J.truth(J.method(v_b, "oku", [(J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {}), game.j_G])) else 0.0)
	return game.math_utils.f_clamp((float(v_v) / float((J.getv(v_b, "hedef") if J.truth(J.getv(v_b, "hedef")) else 1.0))), 0.0, 1.0)
	return null

# basarim.js:335
func f_basarimAc(p_id: Variant = null, p_sessiz: Variant = null) -> Variant:
	var v_b: Variant = null
	var v_id: Variant = p_id
	var v_sessiz: Variant = p_sessiz
	v_b = game.achievement_system.f_basarimById(v_id)
	if ((not J.truth(v_b)) or J.truth(game.achievement_system.f_basarimAcik(v_id))):
		return false
	if (not J.truth(J.getv(game.j_G, "bs"))):
		J.setv(game.j_G, "bs", {})
	J.setv(J.getv(game.j_G, "bs"), v_id, (J.getv(game.j_G, "day") if J.truth(J.getv(game.j_G, "day")) else 1.0))
	if (not J.truth(v_sessiz)):
		J.method(J.getv(game.j_BSQ, "kuyruk"), "push", [{"b": v_b, "t": 0.0}])
		if (not J.eq(J.kind(game.j_SFX), "undefined") and J.truth(J.getv(game.j_SFX, "levelup"))):
			J.method(game.j_SFX, "levelup", [])
	game.achievement_system.f_basarimBildir(v_b)
	return true
	return null

# basarim.js:351
func f_basarimBildir(p_b: Variant = null) -> Variant:
	var v_yuk: Variant = null
	var v_e: Variant = null
	var v_b: Variant = p_b
	v_yuk = {"tip": "basarim", "id": J.getv(v_b, "id"), "ad": J.getv(v_b, "ad"), "en": game.achievement_system.f_bsIng(J.getv(v_b, "ad")), "steam": game.achievement_system.f_bsSteamId(v_b), "gc": game.achievement_system.f_bsGcId(v_b)}
	if (J.truth(J.getv(game.j_window, "__ACH")) and J.eq(J.kind(J.getv(J.getv(game.j_window, "__ACH"), "unlock")), "function")):
		J.method(J.getv(game.j_window, "__ACH"), "unlock", [v_yuk])
	if (J.truth(J.getv(game.j_window, "ReactNativeWebView")) and J.truth(J.getv(J.getv(game.j_window, "ReactNativeWebView"), "postMessage"))):
		J.method(J.getv(game.j_window, "ReactNativeWebView"), "postMessage", [JSON.stringify(v_yuk)])
	if (J.truth(J.getv(game.j_window, "steamworks")) and J.eq(J.kind(J.getv(J.getv(game.j_window, "steamworks"), "activateAchievement")), "function")):
		J.method(J.getv(game.j_window, "steamworks"), "activateAchievement", [J.getv(v_yuk, "steam")])
	if (J.truth(J.getv(game.j_window, "parent")) and not J.eq(J.getv(game.j_window, "parent"), game.j_window)):
		J.method(J.getv(game.j_window, "parent"), "postMessage", [v_yuk, "*"])
	return null

# basarim.js:371
func f_basarimTara(p_sessiz: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_acilan: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	var v_v: Variant = null
	var v_e: Variant = null
	var v_sessiz: Variant = p_sessiz
	if (not J.truth(J.getv(game.j_G, "bs"))):
		J.setv(game.j_G, "bs", {})
	v_S = (J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {})
	v_acilan = 0.0
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_BASARIM, "length")):
		v_b = J.getv(game.j_BASARIM, v_i)
		if J.truth(J.getv(J.getv(game.j_G, "bs"), J.getv(v_b, "id"))):
			v_i = J.add(v_i, 1.0)
			continue
		v_v = 0.0
		v_v = J.method(v_b, "oku", [v_S, game.j_G])
		if J.ge((v_v if J.truth(v_v) else 0.0), J.getv(v_b, "hedef")):
			if J.truth(game.achievement_system.f_basarimAc(J.getv(v_b, "id"), v_sessiz)):
				v_acilan = J.add(v_acilan, 1.0)
		v_i = J.add(v_i, 1.0)
	if J.truth(v_acilan):
		game.save_system.f_saveAll()
	return v_acilan
	return null

# basarim.js:388
func f_basarimBaslat(p_ilkKez: Variant = null) -> Variant:
	var v_ilkKez: Variant = p_ilkKez
	if (not J.truth(J.getv(game.j_G, "bs"))):
		J.setv(game.j_G, "bs", {})
		game.achievement_system.f_basarimTara(true)
		return null
	if J.truth(v_ilkKez):
		game.achievement_system.f_basarimTara(true)
	return null

