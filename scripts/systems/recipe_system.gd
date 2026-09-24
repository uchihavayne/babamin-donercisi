# Recipe system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# Recipe portions and base prices. Machine capacity/timing live in equipment_tuning.gd.
const PRICE = {"wrap": 20.0, "grillBonus": 8.0, "sauceBonus": 5.0, "drink": 13.0, "fbox": 15.0, "ayran": 12.0, "sweet": 18.0, "iskender": 37.0, "tomato": 6.0, "pepper": 8.0}
const MEAT_NEED = 4.0
const FRIES_NEED = 4.0
const PICKLE_NEED = 4.0
const YOGURT_NEED = 4.0
const PLATE_YOGURT = 3.0
const PIDE_NEED = 4.0
const TOMATO_NEED = 3.0
const PEPPER_NEED = 2.0
const ISK_MEAT = 5.0

# data.js:456
func f_orderWrap(p_G: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_havuz: Variant = null
	var v_kac: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	var v_G: Variant = p_G
	v_w = {"kind": "wrap"}
	if (J.truth(J.method(game.j_TUN, "sauceOn", [v_G])) and J.truth(game.f_chance(0.45))):
		J.setv(v_w, "sauce", ("hot" if J.truth(game.f_chance(0.6)) else "garlic"))
	if (J.truth(J.method(game.j_TUN, "secimOn", [v_G])) and J.truth(game.f_chance(0.55))):
		v_havuz = J.method(game.j_SECIM_MALZEME, "slice", [])
		v_kac = 1.0
		if (J.gt(J.method(game.j_TUN, "secimEnCok", [v_G]), 1.0) and J.truth(game.f_chance(0.3))):
			v_kac = 2.0
		J.setv(v_w, "yok", [])
		v_i = 0.0
		while (J.lt(v_i, v_kac) and J.truth(J.getv(v_havuz, "length"))):
			v_j = floor((game.random_unit() * J.getv(v_havuz, "length")))
			J.method(J.getv(v_w, "yok"), "push", [J.getv(J.method(v_havuz, "splice", [v_j, 1.0]), 0.0)])
			v_i = J.add(v_i, 1.0)
	return v_w
	return null

# data.js:475
func f_siparisIstemez(p_ord: Variant = null, p_m: Variant = null) -> Variant:
	var v_ord: Variant = p_ord
	var v_m: Variant = p_m
	return (not (not ((J.truth(v_ord) and J.truth(J.getv(v_ord, "yok"))) and J.ge(J.method(J.getv(v_ord, "yok"), "indexOf", [v_m]), 0.0))))
	return null

# data.js:478
func f_makeOrder(p_G: Variant = null) -> Variant:
	var v_items: Variant = null
	var v_drinks: Variant = null
	var v_icOran: Variant = null
	var v_G: Variant = p_G
	if (J.eq(J.kind(J.ref(game.progression_system.f_fermanDunya, 1)), "function") and J.truth(game.progression_system.f_fermanDunya("karne"))):
		return [{"kind": "wrap", "sauce": null}]
	v_items = [({"kind": "plate"} if (J.truth(J.method(game.j_TUN, "iskOn", [v_G])) and J.truth(game.f_chance(0.26))) else game.recipe_system.f_orderWrap(v_G))]
	v_drinks = []
	if J.truth(J.method(game.j_TUN, "drinkOn", [v_G])):
		J.method(v_drinks, "push", ["cola"])
		J.method(v_drinks, "push", ["fanta"])
	if J.truth(J.method(game.j_TUN, "ayranOn", [v_G])):
		J.method(v_drinks, "push", ["ayran"])
	v_icOran = (0.78 if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "sicak")) else (0.7 if (J.truth(v_G) and J.truth(J.getv(v_G, "macDalga"))) else 0.4))
	if (J.truth(J.getv(v_drinks, "length")) and J.truth(game.f_chance(v_icOran))):
		J.method(v_items, "push", [{"kind": "drink", "type": game.math_utils.f_pick(v_drinks)}])
	if (J.truth(J.method(game.j_TUN, "fboxOn", [v_G])) and J.truth(game.f_chance(0.3))):
		J.method(v_items, "push", [{"kind": "fbox"}])
	if ((J.truth(J.method(game.j_TUN, "sweetOn", [v_G])) and J.truth(game.f_chance(0.26))) and J.lt(J.getv(v_items, "length"), 3.0)):
		J.method(v_items, "push", [{"kind": "sweet"}])
	return v_items
	return null

# data.js:495
func f_makePhoneOrder(p_G: Variant = null) -> Variant:
	var v_items: Variant = null
	var v_drinks: Variant = null
	var v_G: Variant = p_G
	v_items = [({"kind": "plate"} if (J.truth(J.method(game.j_TUN, "iskOn", [v_G])) and J.truth(game.f_chance(0.22))) else game.recipe_system.f_orderWrap(v_G))]
	if J.truth(game.f_chance(0.55)):
		J.method(v_items, "push", [game.recipe_system.f_orderWrap(v_G)])
	v_drinks = []
	if J.truth(J.method(game.j_TUN, "drinkOn", [v_G])):
		J.method(v_drinks, "push", ["cola"])
		J.method(v_drinks, "push", ["fanta"])
	if J.truth(J.method(game.j_TUN, "ayranOn", [v_G])):
		J.method(v_drinks, "push", ["ayran"])
	if (J.truth(J.getv(v_drinks, "length")) and J.truth(game.f_chance((0.88 if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "sicak")) else 0.6)))):
		J.method(v_items, "push", [{"kind": "drink", "type": game.math_utils.f_pick(v_drinks)}])
	if (J.truth(J.method(game.j_TUN, "fboxOn", [v_G])) and J.truth(game.f_chance(0.4))):
		J.method(v_items, "push", [{"kind": "fbox"}])
	if (J.truth(J.method(game.j_TUN, "sweetOn", [v_G])) and J.truth(game.f_chance(0.3))):
		J.method(v_items, "push", [{"kind": "sweet"}])
	return v_items
	return null

# BIRLESIK (6. tur): toplu paket — n standart durum (is yeri siparisi: yok /
# ozel sos yok, fisin iki sutununa sigar) + icecek standi varsa yari olasilikla bir icecek.
func f_makeTopluOrder(p_G: Variant = null, p_n: Variant = null) -> Variant:
	var items: Array = []
	for i in int(J.n(p_n) if J.truth(p_n) else 4.0):
		items.append({"kind": "wrap", "sauce": null})
	if J.truth(J.method(game.j_TUN, "drinkOn", [p_G])) and J.truth(game.f_chance(0.5)):
		var drinks: Array = ["cola", "fanta"]
		if J.truth(J.method(game.j_TUN, "ayranOn", [p_G])): drinks.append("ayran")
		items.append({"kind": "drink", "type": game.math_utils.f_pick(drinks)})
	return items

# data.js:506
func f_itemPrice(p_it: Variant = null, p_G: Variant = null) -> Variant:
	var v_v: Variant = null
	var v_it: Variant = p_it
	var v_G: Variant = p_G
	v_v = 0.0
	if J.eq(J.getv(v_it, "kind"), "wrap"):
		v_v = J.add(J.add(J.getv(game.j_PRICE, "wrap"), (J.getv(game.j_PRICE, "grillBonus") if J.truth(J.getv(v_it, "grilled")) else 0.0)), (J.getv(game.j_PRICE, "sauceBonus") if J.truth(J.getv(v_it, "sauce")) else 0.0))
		v_v = J.add(v_v, J.method(game.j_TUN, "secimZam", [v_G]))
	else:
		if J.eq(J.getv(v_it, "kind"), "plate"):
			v_v = J.getv(game.j_PRICE, "iskender")
			if J.truth(J.getv(v_it, "tomato")):
				v_v = J.add(v_v, J.getv(game.j_PRICE, "tomato"))
			if J.truth(J.getv(v_it, "pepper")):
				v_v = J.add(v_v, J.getv(game.j_PRICE, "pepper"))
		else:
			if J.eq(J.getv(v_it, "kind"), "drink"):
				v_v = (J.getv(game.j_PRICE, "ayran") if J.eq(J.getv(v_it, "type"), "ayran") else J.getv(game.j_PRICE, "drink"))
			else:
				if J.eq(J.getv(v_it, "kind"), "fbox"):
					v_v = J.getv(game.j_PRICE, "fbox")
				else:
					if J.eq(J.getv(v_it, "kind"), "sweet"):
						v_v = J.getv(game.j_PRICE, "sweet")
	return floor((v_v * J.method(game.j_TUN, "priceMul", [v_G])) + 0.5)
	return null

# game.js:835
func f_wrapFull(p_w: Variant = null) -> Variant:
	var v_tamVeyaBos: Variant = null
	var v_w: Variant = p_w
	if ((not J.truth(v_w)) or J.lt(J.getv(v_w, "meat"), game.j_MEAT_NEED)):
		return false
	if (not J.truth(J.method(game.j_TUN, "secimOn", [game.j_G]))):
		return (J.ge(J.getv(v_w, "friesN"), game.j_FRIES_NEED) if (J.ge(J.getv(v_w, "pickleN"), game.j_PICKLE_NEED) and J.ge(J.getv(v_w, "yogurtN"), game.j_YOGURT_NEED)) else (J.ge(J.getv(v_w, "yogurtN"), game.j_YOGURT_NEED) if J.ge(J.getv(v_w, "pickleN"), game.j_PICKLE_NEED) else J.ge(J.getv(v_w, "pickleN"), game.j_PICKLE_NEED)))
	v_tamVeyaBos = game.recipe_system._closure_241.bind({})
	return (J.invoke(v_tamVeyaBos, [(J.getv(v_w, "friesN") if J.truth(J.getv(v_w, "friesN")) else 0.0), game.j_FRIES_NEED]) if (J.truth(J.invoke(v_tamVeyaBos, [(J.getv(v_w, "pickleN") if J.truth(J.getv(v_w, "pickleN")) else 0.0), game.j_PICKLE_NEED])) and J.truth(J.invoke(v_tamVeyaBos, [(J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), game.j_YOGURT_NEED]))) else (J.invoke(v_tamVeyaBos, [(J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), game.j_YOGURT_NEED]) if J.truth(J.invoke(v_tamVeyaBos, [(J.getv(v_w, "pickleN") if J.truth(J.getv(v_w, "pickleN")) else 0.0), game.j_PICKLE_NEED])) else J.invoke(v_tamVeyaBos, [(J.getv(v_w, "pickleN") if J.truth(J.getv(v_w, "pickleN")) else 0.0), game.j_PICKLE_NEED])))
	return null

# game.js:846
func f_wrapVar(p_w: Variant = null, p_m: Variant = null) -> Variant:
	var v_w: Variant = p_w
	var v_m: Variant = p_m
	if J.eq(v_m, "pickle"):
		return J.ge((J.getv(v_w, "pickleN") if J.truth(J.getv(v_w, "pickleN")) else 0.0), game.j_PICKLE_NEED)
	if J.eq(v_m, "yogurt"):
		return J.ge((J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), game.j_YOGURT_NEED)
	if J.eq(v_m, "fries"):
		return J.ge((J.getv(v_w, "friesN") if J.truth(J.getv(v_w, "friesN")) else 0.0), game.j_FRIES_NEED)
	return false
	return null

# game.js:853
func f_secimUyuyor(p_w: Variant = null, p_ord: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_m: Variant = null
	var v_w: Variant = p_w
	var v_ord: Variant = p_ord
	if ((not J.truth(J.method(game.j_TUN, "secimOn", [game.j_G]))) or (not J.truth(v_ord))):
		return true
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_SECIM_MALZEME, "length")):
		v_m = J.getv(game.j_SECIM_MALZEME, v_i)
		if not J.eq(game.recipe_system.f_siparisIstemez(v_ord, v_m), (not J.truth(game.recipe_system.f_wrapVar(v_w, v_m)))):
			return false
		v_i = J.add(v_i, 1.0)
	return true
	return null

# game.js:867
func f_wrapKimlik(p_w: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_i: Variant = null
	var v_m: Variant = null
	var v_w: Variant = p_w
	if ((not J.truth(v_w)) or not J.eq(J.getv(v_w, "kind"), "wrap")):
		return null
	v_d = []
	if J.truth(J.method(game.j_TUN, "secimOn", [game.j_G])):
		v_i = 0.0
		while J.lt(v_i, J.getv(game.j_SECIM_MALZEME, "length")):
			v_m = J.getv(game.j_SECIM_MALZEME, v_i)
			if (not J.truth(game.recipe_system.f_wrapVar(v_w, v_m))):
				J.method(v_d, "push", [{"tip": "yok", "m": v_m}])
			v_i = J.add(v_i, 1.0)
	if J.truth(J.getv(v_w, "sauce")):
		J.method(v_d, "push", [{"tip": "sos", "m": J.getv(v_w, "sauce")}])
	return v_d
	return null

# game.js:879
func f_wrapAny(p_w: Variant = null) -> Variant:
	var v_w: Variant = p_w
	return ((((J.gt(J.getv(v_w, "meat"), 0.0) if J.gt(J.getv(v_w, "meat"), 0.0) else J.gt(J.getv(v_w, "pickleN"), 0.0)) if (J.gt(J.getv(v_w, "meat"), 0.0) or J.gt(J.getv(v_w, "pickleN"), 0.0)) else J.gt(J.getv(v_w, "yogurtN"), 0.0)) if ((J.gt(J.getv(v_w, "meat"), 0.0) or J.gt(J.getv(v_w, "pickleN"), 0.0)) or J.gt(J.getv(v_w, "yogurtN"), 0.0)) else J.gt(J.getv(v_w, "friesN"), 0.0)) if J.truth(v_w) else v_w)
	return null

# game.js:880
func f_wrapQuality(p_w: Variant = null) -> Variant:
	var _cells: Dictionary = {"esnek": [null]}
	var v_pay: Variant = null
	var v_q: Variant = null
	var v_w: Variant = p_w
	if (not J.truth(v_w)):
		return 0.0
	if J.truth(J.getv(v_w, "burnt")):
		return 0.15
	_cells["esnek"][0] = J.method(game.j_TUN, "secimOn", [game.j_G])
	v_pay = game.recipe_system._closure_242.bind({"625:esnek": _cells["esnek"]})
	v_q = ((float(min(J.getv(v_w, "meat"), game.j_MEAT_NEED)) / float(game.j_MEAT_NEED)) * 0.4)
	v_q = J.add(v_q, J.invoke(v_pay, [J.getv(v_w, "pickleN"), game.j_PICKLE_NEED, 0.16]))
	v_q = J.add(v_q, J.invoke(v_pay, [J.getv(v_w, "yogurtN"), game.j_YOGURT_NEED, 0.16]))
	v_q = J.add(v_q, J.invoke(v_pay, [J.getv(v_w, "friesN"), game.j_FRIES_NEED, 0.28]))
	return game.math_utils.f_clamp(v_q, 0.0, 1.0)
	return null

# game.js:899
func f_wrapNeedsGrill(p_w: Variant = null) -> Variant:
	var v_w: Variant = p_w
	return ((not J.truth(J.getv(v_w, "grilled"))) if (not J.eq(J.getv(v_w, "kind"), "plate") and J.truth(J.method(game.j_TUN, "grillOn", [game.j_G]))) else (J.method(game.j_TUN, "grillOn", [game.j_G]) if not J.eq(J.getv(v_w, "kind"), "plate") else not J.eq(J.getv(v_w, "kind"), "plate")))
	return null

# game.js:903
func f_plateFull(p_p: Variant = null) -> Variant:
	var v_p: Variant = p_p
	if ((((not J.truth(v_p)) or J.lt(J.getv(v_p, "meat"), J.method(game.j_TUN, "iskMeat", [game.j_G]))) or (not J.truth(J.getv(v_p, "butter")))) or (not J.truth(J.getv(v_p, "yogurt")))):
		return false
	if J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])):
		if J.lt((J.getv(v_p, "tomato") if J.truth(J.getv(v_p, "tomato")) else 0.0), game.j_TOMATO_NEED):
			return false
		if J.lt((J.getv(v_p, "pepper") if J.truth(J.getv(v_p, "pepper")) else 0.0), game.j_PEPPER_NEED):
			return false
	return true
	return null

# game.js:911
func f_plateAny(p_p: Variant = null) -> Variant:
	var v_p: Variant = p_p
	return (((J.gt(J.getv(v_p, "meat"), 0.0) if J.gt(J.getv(v_p, "meat"), 0.0) else J.getv(v_p, "butter")) if (J.gt(J.getv(v_p, "meat"), 0.0) or J.truth(J.getv(v_p, "butter"))) else J.getv(v_p, "yogurt")) if J.truth(v_p) else v_p)
	return null

# game.js:912
func f_plateQuality(p_p: Variant = null) -> Variant:
	var v_q0: Variant = null
	var v_q: Variant = null
	var v_p: Variant = p_p
	if (not J.truth(v_p)):
		return 0.0
	if (not J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G]))):
		v_q0 = ((float(min(J.getv(v_p, "meat"), J.method(game.j_TUN, "iskMeat", [game.j_G]))) / float(J.method(game.j_TUN, "iskMeat", [game.j_G]))) * 0.55)
		if J.truth(J.getv(v_p, "butter")):
			v_q0 = J.add(v_q0, 0.25)
		if J.truth(J.getv(v_p, "yogurt")):
			v_q0 = J.add(v_q0, 0.2)
		return game.math_utils.f_clamp(v_q0, 0.0, 1.0)
	v_q = ((float(min(J.getv(v_p, "meat"), J.method(game.j_TUN, "iskMeat", [game.j_G]))) / float(J.method(game.j_TUN, "iskMeat", [game.j_G]))) * 0.4)
	if J.truth(J.getv(v_p, "butter")):
		v_q = J.add(v_q, 0.18)
	if J.truth(J.getv(v_p, "yogurt")):
		v_q = J.add(v_q, 0.17)
	v_q = J.add(v_q, ((float(min((J.getv(v_p, "tomato") if J.truth(J.getv(v_p, "tomato")) else 0.0), game.j_TOMATO_NEED)) / float(game.j_TOMATO_NEED)) * 0.13))
	v_q = J.add(v_q, ((float(min((J.getv(v_p, "pepper") if J.truth(J.getv(v_p, "pepper")) else 0.0), game.j_PEPPER_NEED)) / float(game.j_PEPPER_NEED)) * 0.12))
	return game.math_utils.f_clamp(v_q, 0.0, 1.0)
	return null

# game.js:929
func f_newPide(p_otomatik: Variant = null, preferred_board: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_idx: Variant = null
	var v_i: Variant = null
	var v_otomatik: Variant = p_otomatik
	if (not J.truth(J.method(game.j_TUN, "iskOn", [game.j_G]))):
		if (not J.truth(v_otomatik)):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("İskender kapalı — dükkândan aç")
		return null
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	v_idx = game.wrap_system.f_emptyBoard(preferred_board)
	if J.lt(v_idx, 0.0):
		if (not J.truth(v_otomatik)):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Tezgâh dolu!")
		return null
	J.setv(J.getv(game.j_G, "boards"), v_idx, {"kind": "pide", "n": 0.0, "chop": 0.0, "state": "open", "pop": 1.0, "born": J.getv(game.j_G, "t")})
	if (not J.truth(v_otomatik)):
		J.setv(game.j_G, "act", v_idx)
	J.method(game.j_SFX, "wrap", [])
	game.effects.f_burst(game.wrap_system.f_boardCX(v_idx), game.wrap_system.f_boardCY(), 6.0, ["#f4ead2", "#ffffff"], {"spMax": 34.0, "up": 12.0, "sz": 1.0})
	if (not J.truth(v_otomatik)):
		game.session_system.f_say("Pideyi doğra — tahtaya tıkla")
	return null

# game.js:942
func f_finishPlate(p_idx: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_idx: Variant = p_idx
	v_p = J.getv(J.getv(game.j_G, "boards"), v_idx)
	if ((((not J.truth(v_p)) or not J.eq(J.getv(v_p, "kind"), "plate")) or not J.eq(J.getv(v_p, "state"), "open")) or (not J.truth(game.recipe_system.f_plateFull(v_p)))):
		return null
	J.setv(v_p, "state", "ready")
	J.setv(v_p, "pop", 1.0)
	J.setv(v_p, "quality", game.recipe_system.f_plateQuality(v_p))
	J.method(game.j_SFX, "plate", [])
	game.effects.f_burst(game.wrap_system.f_boardCX(v_idx), game.wrap_system.f_boardCY(), 10.0, ["#ffd77a", "#e2621c", "#ffffff"], {"spMax": 55.0, "up": 18.0})
	return null

func _closure_241(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_n: Variant = null
	var v_need: Variant = null
	v_n = J.arg(_args, 0)
	v_need = J.arg(_args, 1)
	return (J.eq(v_n, 0.0) if J.eq(v_n, 0.0) else J.ge(v_n, v_need))
	return null

func _closure_242(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_n: Variant = null
	var v_need: Variant = null
	var v_agirlik: Variant = null
	v_n = J.arg(_args, 0)
	v_need = J.arg(_args, 1)
	v_agirlik = J.arg(_args, 2)
	if (J.truth(_captures["625:esnek"][0]) and J.eq((v_n if J.truth(v_n) else 0.0), 0.0)):
		return v_agirlik
	return ((float(min((v_n if J.truth(v_n) else 0.0), v_need)) / float(v_need)) * v_agirlik)
	return null

