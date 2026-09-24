# Wrap system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:949
func f_emptyBoard(preferred: Variant = null) -> int:
	var count := int(J.method(game.j_TUN, "boards", [game.j_G]))
	if preferred != null:
		var index := int(preferred)
		return index if index >= 0 and index < count and game.j_G.boards[index] == null else -1
	for index in count:
		if game.j_G.boards[index] == null: return index
	return -1

func f_newWrap(preferred_board: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_idx: Variant = null
	var v_i: Variant = null
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	v_idx = game.wrap_system.f_emptyBoard(preferred_board)
	if J.lt(v_idx, 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Tezgâh dolu!")
		return null
	J.setv(J.getv(game.j_G, "boards"), v_idx, {"kind": "wrap", "meat": 0.0, "friesN": 0.0, "pickleN": 0.0, "yogurtN": 0.0, "grilled": false, "paper": false, "state": "open", "pop": 1.0, "roll": 0.0, "born": J.getv(game.j_G, "t")})
	J.setv(game.j_G, "act", v_idx)
	J.method(game.j_SFX, "wrap", [])
	game.session_system.f_say("Yeni lavaş — malzemeler buna gidiyor")
	return null

# game.js:965
func f_activeWrap(p_yerVar: Variant = null) -> Variant:
	var _cells: Dictionary = {"acik": [null], "yerVar": [p_yerVar]}
	var v_n: Variant = null
	var v_uygun: Variant = null
	var v_w: Variant = null
	var v_tur: Variant = null
	var v_best: Variant = null
	var v_bi: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	var v_j: Variant = null
	var v_k: Variant = null
	_cells["acik"][0] = game.wrap_system._closure_243.bind({})
	v_uygun = game.wrap_system._closure_244.bind({"634:acik": _cells["acik"], "634:yerVar": _cells["yerVar"]})
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	v_w = J.getv(J.getv(game.j_G, "boards"), J.getv(game.j_G, "act"))
	if J.truth(J.invoke(v_uygun, [v_w])):
		return v_w
	v_tur = (J.getv(v_w, "kind") if J.truth(J.invoke(_cells["acik"][0], [v_w])) else null)
	v_best = null
	v_bi = (-J.n(1.0))
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_b = J.getv(J.getv(game.j_G, "boards"), v_i)
		if (not J.truth(J.invoke(v_uygun, [v_b]))):
			v_i = J.add(v_i, 1.0)
			continue
		# BIRLESIK: tur kisiti yok (acik durum doluysa malzeme iskender tabagina da gidebilir)
		if ((not J.truth(v_best)) or J.gt(J.getv(v_b, "born"), J.getv(v_best, "born"))):
			v_best = v_b
			v_bi = v_i
		v_i = J.add(v_i, 1.0)
	if J.truth(v_best):
		J.setv(game.j_G, "act", v_bi)
		return v_best
	if (not J.truth(v_tur)):
		v_j = 0.0
		while J.lt(v_j, v_n):
			if J.truth(J.invoke(v_uygun, [J.getv(J.getv(game.j_G, "boards"), v_j)])):
				J.setv(game.j_G, "act", v_j)
				return J.getv(J.getv(game.j_G, "boards"), v_j)
			v_j = J.add(v_j, 1.0)
	if J.truth(J.invoke(_cells["acik"][0], [v_w])):
		return v_w
	v_k = 0.0
	while J.lt(v_k, v_n):
		if J.truth(J.invoke(_cells["acik"][0], [J.getv(J.getv(game.j_G, "boards"), v_k)])):
			J.setv(game.j_G, "act", v_k)
			return J.getv(J.getv(game.j_G, "boards"), v_k)
		v_k = J.add(v_k, 1.0)
	return null
	return null

# game.js:997
func f_selWrap(p_yerVar: Variant = null) -> Variant:
	var v_yerVar: Variant = p_yerVar
	return game.f_activeWrap(v_yerVar)
	return null

# game.js:999
func f_yerEt(p_b: Variant = null) -> Variant:
	var v_b: Variant = p_b
	if J.eq(J.getv(v_b, "kind"), "pide"):
		return false
	return J.lt(J.getv(v_b, "meat"), (J.method(game.j_TUN, "iskMeat", [game.j_G]) if J.eq(J.getv(v_b, "kind"), "plate") else game.j_MEAT_NEED))
	return null

# game.js:1003
func f_yerIng(p_k: Variant = null) -> Variant:
	var _cells: Dictionary = {"k": [p_k]}
	return game.wrap_system._closure_245.bind({"639:k": _cells["k"]})
	return null

# ---------------------------------------------------------------- akilli hedef
# BIRLESIK (4. tur, kullanici: "tahtada bolum secip malzeme ekliyoruz, ne kadar
# sacma; iskender tabagi varsa malzeme oraya, durum varsa oraya gitsin; siparis
# bitince bosta ne varsa ona gecelim"). Tiklanan malzeme ona GERCEKTEN ihtiyaci
# olan urune gider: once secili urun, sonra secili siparise bagli urun, sonra en
# eski urun. Siparisin istemedigi malzeme (yok listesi, farkli sos) o urune
# gitmez.
const MALZEME_ALANI := {"meat": "meat", "pickle": "pickleN", "yogurt": "yogurtN", "fries": "friesN", "tomato": "tomato", "pepper": "pepper"}

func f_malzemeIhtiyac(b: Variant, k: String) -> bool:
	if not (b is Dictionary) or b.get("kind") == "pide": return false
	var kind := str(b.get("kind"))
	var st := str(b.get("state"))
	var r: Variant = b.get("_order_recipe")
	if k in ["hot", "garlic"]:
		if kind != "wrap": return false
		if st != "open" and not (st == "rolled" and J.truth(J.method(game.j_TUN, "sauceLate", [game.j_G]))): return false
		if J.truth(b.get("sauce")): return false
		return not (r is Dictionary) or r.get("sauce") == k
	if st != "open": return false
	if k == "butter": return kind == "plate" and not J.truth(b.get("butter"))
	var alan: String = MALZEME_ALANI.get(k, "")
	if alan == "": return false
	var n := J.n(b.get(alan, 0.0))
	if kind == "plate":
		match k:
			"meat": return n < J.n(J.method(game.j_TUN, "iskMeat", [game.j_G]))
			"yogurt": return n < J.n(game.j_PLATE_YOGURT)
			"tomato": return J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and n < J.n(game.j_TOMATO_NEED)
			"pepper": return J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])) and n < J.n(game.j_PEPPER_NEED)
		return false
	if kind != "wrap" or k in ["tomato", "pepper"]: return false
	if r is Dictionary and k in r.get("yok", []): return false
	var gerek := {"meat": game.j_MEAT_NEED, "pickle": game.j_PICKLE_NEED, "yogurt": game.j_YOGURT_NEED, "fries": game.j_FRIES_NEED}
	return n < J.n(gerek[k])

func f_malzemeHedefi(k: String) -> int:
	var n := int(J.n(J.method(game.j_TUN, "boards", [game.j_G])))
	var act := int(J.n(game.j_G.act))
	if act >= 0 and act < n and f_malzemeIhtiyac(game.j_G.boards[act], k): return act
	var secili: Variant = game.get("chosen_order")
	var en := -1
	var en_puan := INF
	for i in n:
		var b: Variant = game.j_G.boards[i]
		if not f_malzemeIhtiyac(b, k): continue
		var puan := J.n(b.get("born", 0.0))
		if secili is Dictionary and not secili.is_empty() and is_same(b.get("_order_owner"), secili): puan -= 1.0e6
		if puan < en_puan:
			en_puan = puan
			en = i
	return en

func f_malzemeYonlendir(k: String) -> void:
	var h := f_malzemeHedefi(k)
	if h >= 0: game.j_G.act = float(h)

# secili urun tezgahtan ayrilinca (servis, izgara, alinan tabak) secim
# siradaki bekleyen urune gecer: acik urunler (en eski) > pide > sarili/hazir.
var _act_nesne: Variant = null
var _act_idx := -1

func f_actTakip() -> void:
	var n := int(J.n(J.method(game.j_TUN, "boards", [game.j_G])))
	var act := int(J.n(game.j_G.act))
	var simdi: Variant = game.j_G.boards[act] if act >= 0 and act < n else null
	# yalniz AYNI bolmedeki urun ayrildiysa gec; oyuncu bos bir bolme sectiyse dokunma
	if simdi == null and _act_nesne != null and act == _act_idx:
		var en := -1
		var en_puan := INF
		for i in n:
			var b: Variant = game.j_G.boards[i]
			if not (b is Dictionary): continue
			var puan := J.n(b.get("born", 0.0))
			if b.get("kind") == "pide": puan += 1.0e6
			elif b.get("state") != "open": puan += 2.0e6
			if puan < en_puan:
				en_puan = puan
				en = i
		if en >= 0:
			game.j_G.act = float(en)
			act = en
			simdi = game.j_G.boards[en]
	_act_nesne = simdi
	_act_idx = act

# game.js:1013
func f_boardCX(p_i: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_i: Variant = p_i
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	return floor(J.add(J.add(J.getv(J.getv(game.j_ST, "board"), "x"), 4.0), ((float((J.getv(J.getv(game.j_ST, "board"), "w") - 8.0)) / float(v_n)) * J.add(v_i, 0.5))) + 0.5)
	return null

# game.js:1014
func f_boardCY() -> Variant:
	return J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 25.0)
	return null

# game.js:1489
func f_finishRoll(p_idx: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_idx: Variant = p_idx
	v_w = J.getv(J.getv(game.j_G, "boards"), v_idx)
	if (not J.truth(v_w)):
		return null
	J.setv(v_w, "state", "rolled")
	J.setv(v_w, "roll", 1.0)
	J.setv(v_w, "pop", 1.0)
	J.setv(v_w, "quality", game.f_wrapQuality(v_w))
	J.method(game.j_SFX, "roll", [])
	game.effects.f_burst(game.wrap_system.f_boardCX(v_idx), game.wrap_system.f_boardCY(), 7.0, ["#f0d5a8", "#f8e6c4"], {"spMax": 45.0, "up": 16.0})
	game.equipment_system.f_checkAuto()
	return null

# game.js:1498
func f_applyPaper(p_idx: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_idx: Variant = p_idx
	v_w = J.getv(J.getv(game.j_G, "boards"), v_idx)
	if ((not J.truth(v_w)) or not J.eq(J.getv(v_w, "state"), "rolled")):
		return null
	J.setv(v_w, "paper", true)
	J.setv(v_w, "state", "ready")
	J.setv(v_w, "pop", 1.0)
	J.setv(v_w, "paperT", 1.0)
	game.effects.f_burst(game.wrap_system.f_boardCX(v_idx), game.wrap_system.f_boardCY(), 9.0, ["#fdfaf0", "#ffffff"], {"spMax": 50.0, "up": 15.0})
	J.method(game.j_SFX, "crinkle", [])
	return null

func _closure_243(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_b: Variant = null
	v_b = J.arg(_args, 0)
	return (J.eq(J.getv(v_b, "state"), "open") if (not (not J.truth(v_b))) else (not (not J.truth(v_b))))
	return null

func _closure_244(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_b: Variant = null
	v_b = J.arg(_args, 0)
	return (((not J.truth(_captures["634:yerVar"][0])) if (not J.truth(_captures["634:yerVar"][0])) else J.invoke(_captures["634:yerVar"][0], [v_b])) if J.truth(J.invoke(_captures["634:acik"][0], [v_b])) else J.invoke(_captures["634:acik"][0], [v_b]))
	return null

func _closure_245(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_b: Variant = null
	v_b = J.arg(_args, 0)
	if J.eq(J.getv(v_b, "kind"), "pide"):
		return false
	if J.eq(J.getv(v_b, "kind"), "plate"):
		return (J.lt((J.getv(v_b, "yogurtN") if J.truth(J.getv(v_b, "yogurtN")) else 0.0), game.j_PLATE_YOGURT) if J.eq(_captures["639:k"][0], "yogurt") else J.eq(_captures["639:k"][0], "yogurt"))
	if J.eq(_captures["639:k"][0], "fries"):
		return J.lt(J.getv(v_b, "friesN"), game.j_FRIES_NEED)
	if J.eq(_captures["639:k"][0], "pickle"):
		return J.lt(J.getv(v_b, "pickleN"), game.j_PICKLE_NEED)
	if J.eq(_captures["639:k"][0], "yogurt"):
		return J.lt(J.getv(v_b, "yogurtN"), game.j_YOGURT_NEED)
	return true
	return null
