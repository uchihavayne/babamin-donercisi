# Phone system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2191
func f_phoneOpen() -> Variant:
	var v_p: Variant = null
	v_p = J.getv(game.j_G, "phone")
	return (not (not (((J.truth(v_p) and J.eq(J.getv(v_p, "state"), "order")) and J.truth(J.getv(v_p, "order"))) and J.truth(game.phone_system.f_phoneActive()))))
	return null

# game.js:3616
func f_phoneReset() -> Variant:
	J.setv(game.j_G, "phone", {"state": "idle", "t": 20.0, "ringT": 0.0, "order": null, "done": [], "beep": 0.0, "kind": "order"})
	J.setv(game.j_G, "courier", {"state": "in", "t": 0.0, "x": 0.0, "pay": 0.0})
	return null

# game.js:3621
func f_fermanKuryeYasak() -> Variant:
	if (J.eq(J.kind(J.ref(game.progression_system.f_fermanDunya, 1)), "function") and J.truth(game.progression_system.f_fermanDunya("kurye"))):
		return true
	if ((J.truth(game.progression_system.f_fermanSehri(game.j_G)) and J.eq(J.kind(J.ref(game.progression_system.f_haberEtki, 2)), "function")) and J.truth(game.progression_system.f_haberEtki("telefonKapali"))):
		return true
	return false
	return null

# game.js:3630
func f_fermanTelefonZorunlu() -> Variant:
	return (game.progression_system.f_fermanDunya("telefon") if J.eq(J.kind(J.ref(game.progression_system.f_fermanDunya, 1)), "function") else J.eq(J.kind(J.ref(game.progression_system.f_fermanDunya, 1)), "function"))
	return null

# game.js:3633
func f_phoneActive() -> Variant:
	return ((not J.truth(game.phone_system.f_fermanKuryeYasak())) if (J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G])) and (not (J.truth(J.getv(game.j_G, "moto")) and J.truth(J.getv(J.getv(game.j_G, "moto"), "broken"))))) else ((not (J.truth(J.getv(game.j_G, "moto")) and J.truth(J.getv(J.getv(game.j_G, "moto"), "broken")))) if J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G])) else J.method(game.j_TUN, "phoneOn", [game.j_G])))
	return null

# game.js:3636
func f_updatePhone(p_dt: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_c: Variant = null
	var v_kYavas: Variant = null
	var v_found: Variant = null
	var v_tf: Variant = null
	var v_ti: Variant = null
	var v_dt: Variant = p_dt
	if (not J.truth(game.phone_system.f_phoneActive())):
		return null
	v_p = J.getv(game.j_G, "phone")
	v_c = J.getv(game.j_G, "courier")
	v_kYavas = J.method(game.j_TUN, "courierYavas", [game.j_G])
	if J.eq(J.getv(v_c, "state"), "leaving"):
		J.setv(v_c, "t", J.add(J.getv(v_c, "t"), (float(v_dt) / float((1.1 * v_kYavas)))))
		J.setv(v_c, "x", game.math_utils.f_lerp(24.0, (-J.n(60.0)), game.math_utils.f_easeIn(game.math_utils.f_clamp(J.getv(v_c, "t"), 0.0, 1.0))))
		if J.ge(J.getv(v_c, "t"), 1.0):
			J.setv(v_c, "state", "away")
			J.setv(v_c, "t", 0.0)
	else:
		if J.eq(J.getv(v_c, "state"), "away"):
			J.setv(v_c, "t", J.add(J.getv(v_c, "t"), v_dt))
			if J.ge(J.getv(v_c, "t"), J.method(game.j_TUN, "courierTime", [game.j_G])):
				J.setv(v_c, "state", "back")
				J.setv(v_c, "t", 0.0)
				J.method(game.j_SFX, "moto", [])
				if (J.gt((J.getv(game.j_G, "luck") if J.truth(J.getv(game.j_G, "luck")) else 0.0), 0.0) and J.truth(game.f_chance(min(0.34, (J.getv(game.j_G, "luck") * 0.055))))):
					v_found = (floor((float(game.math_utils.f_rnd(game.j_LUCK_FIND_MIN, game.j_LUCK_FIND_MAX)) / float(10.0)) + 0.5) * 10.0)
					J.setv(v_c, "pay", J.add(J.getv(v_c, "pay"), v_found))
					J.setv(game.j_G, "luckMsg", 3.0)
					J.setv(game.j_G, "luckAmt", v_found)
					J.setv(J.getv(game.j_G, "stats"), "found", J.add((J.getv(J.getv(game.j_G, "stats"), "found") if J.truth(J.getv(J.getv(game.j_G, "stats"), "found")) else 0.0), v_found))
					J.method(game.j_SFX, "coin", [])
				game.household_system.f_kasaEkle(J.getv(v_c, "pay"))
				J.setv(J.getv(game.j_G, "stat"), "earned", J.add(J.getv(J.getv(game.j_G, "stat"), "earned"), J.getv(v_c, "pay")))
				game.effects.f_ftext(J.add("+$", game.math_utils.f_fmtMoney(J.getv(v_c, "pay"))), 40.0, 150.0, J.getv(game.j_P, "au0"), {"sc": 2.0, "life": 1.6})
				J.method(game.j_SFX, "cash", [])
				game.effects.f_flash(0.12, "#ffe9a0")
				J.setv(v_c, "pay", 0.0)
		else:
			if J.eq(J.getv(v_c, "state"), "back"):
				J.setv(v_c, "t", J.add(J.getv(v_c, "t"), (float(v_dt) / float((1.1 * v_kYavas)))))
				J.setv(v_c, "x", game.math_utils.f_lerp((-J.n(60.0)), 24.0, game.math_utils.f_easeOut(game.math_utils.f_clamp(J.getv(v_c, "t"), 0.0, 1.0))))
				if J.ge(J.getv(v_c, "t"), 1.0):
					J.setv(v_c, "state", "in")
					J.setv(v_c, "x", 0.0)
	if J.eq(J.getv(v_p, "state"), "idle"):
		if not J.eq(J.getv(v_c, "state"), "in"):
			return null
		J.setv(v_p, "t", (J.getv(v_p, "t") - v_dt))
		if (J.le(J.getv(v_p, "t"), 0.0) and J.gt(J.getv(game.j_G, "timeLeft"), 25.0)):
			J.setv(v_p, "kind", "order")
			game.phone_system.f_topluKarar(v_p)
			J.setv(v_p, "state", "ring")
			J.setv(v_p, "ringT", 0.0)
			J.setv(v_p, "beep", 0.0)
	else:
		if J.eq(J.getv(v_p, "state"), "ring"):
			J.setv(v_p, "ringT", J.add(J.getv(v_p, "ringT"), v_dt))
			J.setv(v_p, "beep", (J.getv(v_p, "beep") - v_dt))
			if J.le(J.getv(v_p, "beep"), 0.0):
				J.setv(v_p, "beep", 1.1)
				J.method(game.j_SFX, "phone", [])
			if J.gt(J.getv(v_p, "ringT"), 11.0):
				if ((J.truth(game.phone_system.f_fermanTelefonZorunlu()) and J.truth(J.getv(game.j_G, "ferman"))) and (not J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi")))):
					v_tf = null
					v_ti = 0.0
					while J.lt(v_ti, J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), "length")):
						if J.eq(J.getv(J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), v_ti), "id"), "telefon"):
							v_tf = J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), v_ti)
						v_ti = J.add(v_ti, 1.0)
					game.regulation_system.f_fermanIhlal(v_tf, J.add(J.getv(J.getv(game.j_ST, "phone"), "x"), 30.0), J.add(J.getv(J.getv(game.j_ST, "phone"), "y"), 10.0), "telefon")
				J.setv(v_p, "state", "idle")
				J.setv(v_p, "t", (J.method(game.j_TUN, "phoneGap", [game.j_G]) * 0.6))
	return null

# BIRLESIK (6. tur, madde 12 — kullanici "toplu siparis: 4-5 durum, paket,
# yuksek odeme"): telefon calarken toplu olup olmadigi belirlenir (telefonun
# ustunde xN rozeti). Siparis N standart durum (+ bazen icecek); her urun paket
# ucretinin TOPLU_KAT kati oder.
const TOPLU_GUN := 5.0
const TOPLU_SANS := 0.22
const TOPLU_KAT := 1.4

func f_topluKarar(p: Variant) -> void:
	var olur: bool = J.n(game.j_G.day) >= TOPLU_GUN and J.n(game.j_G.timeLeft) > 60.0 and J.truth(game.f_chance(TOPLU_SANS))
	J.setv(p, "toplu", olur)
	J.setv(p, "topluN", (5.0 if J.truth(game.f_chance(0.5)) else 4.0) if olur else 0.0)

# game.js:3694
func f_phoneClick() -> Variant:
	var v_p: Variant = null
	v_p = J.getv(game.j_G, "phone")
	if (not J.truth(game.phone_system.f_phoneActive())):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Telefon hattı yok — dükkândan al")
		return null
	if J.eq(J.getv(v_p, "state"), "ring"):
		J.setv(v_p, "state", "order")
		if J.truth(J.getv(v_p, "toplu")):
			J.setv(v_p, "order", game.recipe_system.f_makeTopluOrder(game.j_G, J.getv(v_p, "topluN")))
		else:
			J.setv(v_p, "order", game.recipe_system.f_makePhoneOrder(game.j_G))
		J.setv(v_p, "done", J.method(J.getv(v_p, "order"), "map", [game.phone_system._closure_265.bind({})]))
		J.method(game.j_SFX, "ding", [])
		game.session_system.f_say("Toplu sipariş! Dürümleri Dayıya ver" if J.truth(J.getv(v_p, "toplu")) else "Paket sipariş alındı — Dayıya ver!")
		return null
	if J.eq(J.getv(v_p, "state"), "order"):
		game.session_system.f_say("Ürünleri Dayıya ver")
		return null
	game.session_system.f_say("Telefon sessiz")
	return null

# game.js:3709
func f_giveToCourier() -> Variant:
	var v_p: Variant = null
	var v_it: Variant = null
	var v_idx: Variant = null
	var v_pass: Variant = null
	var v_i: Variant = null
	var v_o: Variant = null
	var v_tam: Variant = null
	var v_ord: Variant = null
	var v_sauceOk: Variant = null
	var v_price: Variant = null
	var v_q: Variant = null
	var v_all: Variant = null
	var v_d: Variant = null
	if ((J.truth(J.getv(game.j_G, "hand")) and J.eq(J.getv(J.getv(game.j_G, "hand"), "kind"), "wrap")) and J.truth(J.getv(J.getv(game.j_G, "hand"), "burnt"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Yanmış dürüm satılmaz — çöpe at")
		return null
	v_p = J.getv(game.j_G, "phone")
	if (not J.eq(J.getv(v_p, "state"), "order") or (not J.truth(J.getv(game.j_G, "hand")))):
		return false
	if ((J.eq(J.getv(J.getv(game.j_G, "hand"), "kind"), "wrap") and J.eq(J.getv(J.getv(game.j_G, "hand"), "state"), "rolled")) and (not J.truth(J.getv(J.getv(game.j_G, "hand"), "paper")))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce kâğıtla — kağıtsız dürüm verilmez")
		return false
	if ((J.eq(J.getv(J.getv(game.j_G, "hand"), "kind"), "wrap") and J.truth(J.method(game.j_TUN, "grillOn", [game.j_G]))) and (not J.truth(J.getv(J.getv(game.j_G, "hand"), "grilled")))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Izgarasız dürüm olmaz — önce ızgaraya at")
		return false
	v_it = J.getv(game.j_G, "hand")
	v_idx = (-J.n(1.0))
	v_pass = 0.0
	while (J.lt(v_pass, 4.0) and J.lt(v_idx, 0.0)):
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(v_p, "order"), "length")):
			if J.truth(J.getv(J.getv(v_p, "done"), v_i)):
				v_i = J.add(v_i, 1.0)
				continue
			v_o = J.getv(J.getv(v_p, "order"), v_i)
			if not J.eq(J.getv(v_o, "kind"), J.getv(v_it, "kind")):
				v_i = J.add(v_i, 1.0)
				continue
			if (J.eq(J.getv(v_it, "kind"), "drink") and not J.eq(J.getv(v_o, "type"), J.getv(v_it, "type"))):
				v_i = J.add(v_i, 1.0)
				continue
			if (((J.eq(v_pass, 0.0) or J.eq(v_pass, 2.0)) and J.eq(J.getv(v_it, "kind"), "wrap")) and not J.eq((J.getv(v_o, "sauce") if J.truth(J.getv(v_o, "sauce")) else null), (J.getv(v_it, "sauce") if J.truth(J.getv(v_it, "sauce")) else null))):
				v_i = J.add(v_i, 1.0)
				continue
			if J.lt(v_pass, 2.0) and J.eq(J.getv(v_it, "kind"), "wrap") and not game.f_secimUyuyor(v_it, v_o):
				v_i = J.add(v_i, 1.0)
				continue
			# gevsek gecis: order_system'in sectigi en iyi kalem (order_loose_index)
			if J.ge(v_pass, 2.0) and v_it is Dictionary and v_it.has("_teslim_idx") and not J.eq(v_i, v_it._teslim_idx):
				v_i = J.add(v_i, 1.0)
				continue
			v_idx = v_i
			break
			v_i = J.add(v_i, 1.0)
		v_pass = J.add(v_pass, 1.0)
	if J.lt(v_idx, 0.0):
		return false
	# BIRLESIK (7. tur): eksik urun de pakete gider; ucret kaliteyle (asagida v_q)
	v_ord = J.getv(J.getv(v_p, "order"), v_idx)
	v_sauceOk = ((not J.truth(J.getv(v_ord, "sauce"))) if (not J.truth(J.getv(v_ord, "sauce"))) else J.eq(J.getv(v_it, "sauce"), J.getv(v_ord, "sauce")))
	v_price = (game.recipe_system.f_itemPrice({"kind": "wrap", "grilled": J.getv(v_it, "grilled"), "sauce": (J.getv(v_ord, "sauce") if J.truth(v_sauceOk) else null)}, game.j_G) if J.eq(J.getv(v_it, "kind"), "wrap") else game.recipe_system.f_itemPrice(v_it, game.j_G))
	if (J.eq(J.getv(v_it, "kind"), "wrap") or J.eq(J.getv(v_it, "kind"), "plate")):
		v_q = ((game.recipe_system.f_plateQuality(v_it) if J.eq(J.getv(v_it, "kind"), "plate") else game.f_wrapQuality(v_it)) if J.eq(J.getv(v_it, "quality"), null) else J.getv(v_it, "quality"))
		v_price = max(2.0, floor((v_price * v_q) + 0.5))
		if J.eq(J.getv(v_it, "kind"), "plate"):
			J.setv(J.getv(game.j_G, "stat"), "isk", J.add(J.getv(J.getv(game.j_G, "stat"), "isk"), 1.0))
		else:
			J.setv(J.getv(game.j_G, "stat"), "wraps", J.add(J.getv(J.getv(game.j_G, "stat"), "wraps"), 1.0))
	else:
		if J.eq(J.getv(v_it, "kind"), "drink"):
			J.setv(J.getv(game.j_G, "stat"), "drinks", J.add(J.getv(J.getv(game.j_G, "stat"), "drinks"), 1.0))
		else:
			if J.eq(J.getv(v_it, "kind"), "sweet"):
				J.setv(J.getv(game.j_G, "stat"), "sweets", J.add(J.getv(J.getv(game.j_G, "stat"), "sweets"), 1.0))
			else:
				J.setv(J.getv(game.j_G, "stat"), "boxes", J.add(J.getv(J.getv(game.j_G, "stat"), "boxes"), 1.0))
	if (not J.truth(v_sauceOk)):
		v_price = max(2.0, floor((v_price * 0.65) + 0.5))
		game.effects.f_ftext("SOS YANLIŞ!", J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 24.0), 126.0, J.getv(game.j_P, "bad"), {"life": 1.3})
		J.method(game.j_SFX, "bad", [])
	J.setv(game.j_G, "totalSold", J.add(J.getv(game.j_G, "totalSold"), 1.0))
	var kat: float = TOPLU_KAT if J.truth(J.getv(v_p, "toplu")) else 1.0
	J.setv(J.getv(game.j_G, "courier"), "pay", J.add(J.getv(J.getv(game.j_G, "courier"), "pay"), floor((v_price * game.j_PHONE_MUL * kat) + 0.5)))
	J.setv(J.getv(v_p, "done"), v_idx, true)
	J.setv(game.j_G, "hand", null)
	J.method(game.j_SFX, "serve", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 24.0), 150.0, 8.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 60.0, "up": 24.0, "sz": 2.0})
	v_all = true
	v_d = 0.0
	while J.lt(v_d, J.getv(J.getv(v_p, "done"), "length")):
		if (not J.truth(J.getv(J.getv(v_p, "done"), v_d))):
			v_all = false
		v_d = J.add(v_d, 1.0)
	if J.truth(v_all):
		J.setv(v_p, "state", "idle")
		J.setv(v_p, "t", (J.method(game.j_TUN, "phoneGap", [game.j_G]) * (0.5 if J.truth(game.weather_system.f_isRain()) else 1.0)))
		J.setv(J.getv(game.j_G, "courier"), "state", "leaving")
		J.setv(J.getv(game.j_G, "courier"), "t", 0.0)
		J.setv(J.getv(game.j_G, "courier"), "x", 24.0)
		J.setv(J.getv(game.j_G, "stats"), "phone", J.add((J.getv(J.getv(game.j_G, "stats"), "phone") if J.truth(J.getv(J.getv(game.j_G, "stats"), "phone")) else 0.0), 1.0))
		J.method(game.j_SFX, "bell", [])
		J.method(game.j_SFX, "moto", [])
		game.effects.f_ftext("KURYE YOLDA!", 60.0, 130.0, J.getv(game.j_P, "au0"), {"life": 1.6})
		if J.truth(J.getv(v_p, "toplu")):
			game.effects.f_ftext("TOPLU SİPARİŞ +%40", 60.0, 116.0, J.getv(game.j_P, "ok"), {"life": 1.8})
			J.setv(J.getv(game.j_G, "stats"), "toplu", J.add((J.getv(J.getv(game.j_G, "stats"), "toplu") if J.truth(J.getv(J.getv(game.j_G, "stats"), "toplu")) else 0.0), 1.0))
			J.setv(v_p, "toplu", false)
	return true
	return null

func _closure_265(_args: Array, _captures: Dictionary = {}) -> Variant:
	return false
	return null
