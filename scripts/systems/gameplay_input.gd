# Gameplay input. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2613
func f_handleInput() -> Variant:
	var v_mx: Variant = null
	var v_my: Variant = null
	var v_cr: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_k: Variant = null
	var v_co: Variant = null
	var v_idx: Variant = null
	var v_w: Variant = null
	var v_bi2: Variant = null
	var v_bi3: Variant = null
	var v_pb: Variant = null
	var v_old: Variant = null
	var v_mus: Variant = null
	var v_gen: Variant = null
	var v_i2: Variant = null
	var v_tip: Variant = null
	if (not J.truth(J.getv(game.j_IN, "pressed"))):
		return null
	v_mx = J.getv(game.j_IN, "x")
	v_my = J.getv(game.j_IN, "y")
	if (J.eq(J.kind(J.ref(game.interface_draw.f_devDugmeTik, 2)), "function") and J.truth(game.interface_draw.f_devDugmeTik(v_mx, v_my))):
		return null
	if J.truth(game.debug_draw.f_testHit(v_mx, v_my)):
		return null
	# bahis paneli uzerindeki tiklama panelin dugmelerine aittir
	if game.rival_system.f_bahisPanelde(v_mx, v_my):
		return null
	if J.truth(game.math_utils.f_inRect(v_mx, v_my, (game.hud_draw.f_hudSagKenar() - 22.0), J.add(4.0, J.getv(game.j_VIEW, "top")), 18.0, 16.0)):
		J.setv(game.j_G, "scene", "pause")
		J.method(game.j_SFX, "ui", [])
		return null
	if J.truth(game.regulation_system.f_fermanTik(v_mx, v_my)):
		return null
	if J.truth(J.getv(J.getv(game.j_G, "crate"), "open")):
		v_cr = game.stock_system.f_cratePanelRect()
		if (J.truth(game.math_utils.f_inRect(v_mx, v_my, J.getv(v_cr, 0.0), J.getv(v_cr, 1.0), J.getv(v_cr, 2.0), J.getv(v_cr, 3.0))) or J.truth(game.f_hitST("crate"))):
			game.stock_system.f_crateClick(v_mx, v_my)
			return null
		J.setv(J.getv(game.j_G, "crate"), "open", false)
		J.method(game.j_SFX, "uiBack", [])
	if J.truth(J.getv(game.j_G, "hand")):
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
			v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
			if (J.eq(J.getv(v_c, "state"), "wait") and J.truth(game.customer_system.f_custHit(v_c))):
				game.f_deliver(v_c)
				return null
			v_i = J.add(v_i, 1.0)
	v_k = (J.getv(J.getv(game.j_G, "coins"), "length") - 1.0)
	while J.ge(v_k, 0.0):
		v_co = J.getv(J.getv(game.j_G, "coins"), v_k)
		if (J.truth(J.getv(v_co, "landed")) and J.truth(game.math_utils.f_inRect(v_mx, v_my, (J.getv(v_co, "x") - 7.0), (J.getv(v_co, "y") - 8.0), 14.0, 14.0))):
			game.payment_system.f_collectCoin(v_k, false)
			return null
		v_k = (v_k - 1.0)
	if (J.eq(J.kind(J.ref(game.event_system.f_kediHit, 2)), "function") and J.truth(game.event_system.f_kediHit(v_mx, v_my))):
		J.method(game.j_SFX, "uiBack", [])
		game.session_system.f_say(("Et tepsisinden bir dilim sürükle" if J.gt(J.getv(game.j_G, "meat"), 0.0) else "Et yok — önce dönerden kes"))
		return null
	if (J.truth(game.f_hitST("phone")) and J.truth(game.phone_system.f_phoneActive())):
		game.f_phoneClick()
		return null
	if J.truth(game.f_hitST("uncle")):
		if J.truth(game.helper_system.f_motoClick()):
			return null
		if J.truth(game.f_giveToCourier()):
			return null
		game.helper_system.f_uncleUse()
		return null
	if J.truth(game.f_hitST("trash")):
		game.event_system.f_trashClick()
		return null
	if ((J.truth(J.getv(game.j_G, "hand")) and (not J.truth(game.f_hitST("board")))) and (not J.truth(game.f_hitST("uncle")))):
		if (not J.truth(game.drag_system.f_returnItem(J.getv(game.j_G, "hand")))):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Koyacak yer yok — tezgâhta yer aç")
			return null
		J.setv(game.j_G, "hand", null)
		J.method(game.j_SFX, "pick", [])
	if J.truth(game.f_hitST("crate")):
		game.stock_system.f_crateClick(v_mx, v_my)
		return null
	if J.truth(game.f_hitST("spit")):
		if J.le(J.getv(J.getv(game.j_G, "shave"), "act"), 0.0):
			game.session_system.f_say(("Parmağını yukarı-aşağı sürt!" if J.truth(game.j_TOUCH) else "Fareyi yukarı-aşağı sürt!"))
		return null
	if J.truth(game.f_hitST("meat")):
		game.assembly_system.f_addMeat()
		return null
	if J.truth(game.f_hitST("pickle")):
		game.assembly_system.f_addIng("pickle")
		return null
	if J.truth(game.f_hitST("yogurt")):
		game.assembly_system.f_addIng("yogurt")
		return null
	if J.truth(game.f_hitST("friesT")):
		game.assembly_system.f_addIng("fries")
		return null
	if J.truth(game.f_hitST("garnish")):
		game.assembly_system.f_garnishClick(v_mx)
		return null
	if J.truth(game.f_hitST("bread")):
		if (J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])) and J.lt(v_my, J.add(J.getv(J.getv(game.j_ST, "bread"), "y"), 16.0))):
			game.recipe_system.f_newPide()
		else:
			game.f_newWrap()
		return null
	if J.truth(game.f_hitST("sauce")):
		game.assembly_system.f_sauceClick(v_mx)
		return null
	if J.truth(game.f_hitST("board")):
		v_idx = game.drag_system.f_boardAt(v_mx, v_my)
		v_w = J.getv(J.getv(game.j_G, "boards"), v_idx)
		# BIRLESIK (7. tur, kullanici: "durumu tahtaya geri birakamiyorum, bazen
		# oluyor bazen olmuyor"): eldeki durum/tabak BOS tahtaya tiklaninca oraya
		# birakilir. Eskiden bos tahtada dolu tahta araniyor, bulunamayinca hicbir
		# sey olmuyordu (yalniz tahta disina tiklamak geri koyuyordu).
		var v_el: Variant = J.getv(game.j_G, "hand")
		if (not J.truth(v_w)) and J.truth(v_el) and (J.eq(J.getv(v_el, "kind"), "wrap") or J.eq(J.getv(v_el, "kind"), "plate")) and J.lt(v_idx, J.method(game.j_TUN, "boards", [game.j_G])):
			J.setv(J.getv(game.j_G, "boards"), v_idx, v_el)
			J.setv(v_el, "pop", 1.0)
			J.setv(game.j_G, "hand", null)
			J.setv(game.j_G, "act", v_idx)
			J.method(game.j_SFX, "drop", [])
			return null
		if (not J.truth(v_w)):
			v_bi2 = 0.0
			while J.lt(v_bi2, J.method(game.j_TUN, "boards", [game.j_G])):
				if (J.truth(J.getv(J.getv(game.j_G, "boards"), v_bi2)) and J.eq(J.getv(J.getv(J.getv(game.j_G, "boards"), v_bi2), "state"), "ready")):
					v_idx = v_bi2
					v_w = J.getv(J.getv(game.j_G, "boards"), v_bi2)
					break
				v_bi2 = J.add(v_bi2, 1.0)
		if (not J.truth(v_w)):
			v_bi3 = 0.0
			while J.lt(v_bi3, J.method(game.j_TUN, "boards", [game.j_G])):
				v_pb = J.getv(J.getv(game.j_G, "boards"), v_bi3)
				if ((J.truth(v_pb) and J.eq(J.getv(v_pb, "kind"), "plate")) and J.truth(game.recipe_system.f_plateAny(v_pb))):
					v_idx = v_bi3
					v_w = v_pb
					break
				v_bi3 = J.add(v_bi3, 1.0)
		if (not J.truth(v_w)):
			v_pb = 0.0
			while J.lt(v_pb, J.method(game.j_TUN, "boards", [game.j_G])):
				if (J.truth(J.getv(J.getv(game.j_G, "boards"), v_pb)) and J.eq(J.getv(J.getv(J.getv(game.j_G, "boards"), v_pb), "kind"), "pide")):
					v_idx = v_pb
					v_w = J.getv(J.getv(game.j_G, "boards"), v_pb)
					break
				v_pb = J.add(v_pb, 1.0)
		if (J.truth(v_w) and J.eq(J.getv(v_w, "kind"), "pide")):
			J.setv(game.j_G, "act", v_idx)
			game.assembly_system.f_pideChop(v_idx)
			return null
		# BIRLESIK (7. tur): secili tahtadaki eksik tabak ikinci tiklamada ele alinir
		# (eskiden yalniz tamamen dolunca alinabiliyordu; "teslim edemiyorum").
		var v_tabakAl: bool = J.truth(v_w) and J.eq(J.getv(v_w, "kind"), "plate") and J.truth(game.recipe_system.f_plateAny(v_w)) and J.eq(J.getv(game.j_G, "act"), v_idx)
		if ((J.truth(v_w) and J.eq(J.getv(v_w, "state"), "open")) and (not J.truth(J.getv(game.j_G, "hand")))) and not v_tabakAl:
			if not J.eq(J.getv(game.j_G, "act"), v_idx):
				J.setv(game.j_G, "act", v_idx)
				J.method(game.j_SFX, "pick", [])
				J.setv(v_w, "pop", 1.0)
			return null
		if (J.truth(v_w) and ((J.eq(J.getv(v_w, "state"), "ready") or J.eq(J.getv(v_w, "state"), "rolled")) or (J.eq(J.getv(v_w, "kind"), "plate") and J.truth(game.recipe_system.f_plateAny(v_w))))):
			if J.truth(J.getv(game.j_G, "hand")):
				v_old = J.getv(game.j_G, "hand")
				J.setv(game.j_G, "hand", v_w)
				J.setv(J.getv(game.j_G, "boards"), v_idx, null)
				if (J.eq(J.getv(v_old, "kind"), "wrap") or J.eq(J.getv(v_old, "kind"), "plate")):
					J.setv(J.getv(game.j_G, "boards"), v_idx, v_old)
					J.method(game.j_SFX, "pick", [])
					return null
				if (not J.truth(game.drag_system.f_returnItem(v_old))):
					J.setv(J.getv(game.j_G, "boards"), v_idx, v_w)
					J.setv(game.j_G, "hand", v_old)
					J.method(game.j_SFX, "bad", [])
					game.session_system.f_say("Yer yok!")
					return null
				J.method(game.j_SFX, "pick", [])
				return null
			J.setv(game.j_G, "hand", v_w)
			J.setv(J.getv(game.j_G, "boards"), v_idx, null)
			J.method(game.j_SFX, "pick", [])
		return null
	if J.truth(game.f_hitST("paper")):
		game.paper_system.f_paperClick()
		return null
	if J.truth(game.f_hitST("grill")):
		game.grill_system.f_grillClick()
		return null
	if J.truth(game.f_hitST("potato")):
		game.potato_system.f_potatoTake()
		return null
	if J.truth(game.f_hitST("cut")):
		game.potato_system.f_cutClick()
		return null
	if J.truth(game.f_hitST("fryer")):
		game.potato_system.f_fryerClick()
		return null
	if J.truth(game.f_hitST("fbox")):
		game.fries_box_system.f_fboxClick()
		return null
	if J.truth(game.f_hitST("sweet")):
		game.equipment_system.f_sweetClick()
		return null
	if J.truth(game.f_hitST("drinkM")):
		v_mus = game.drink_system.f_icecekMusluklari()
		if (not J.truth(J.getv(v_mus, "length"))):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("İçecek standı kapalı")
			return null
		v_gen = (float(J.getv(J.getv(game.j_ST, "drinkM"), "w")) / float(J.getv(v_mus, "length")))
		v_i2 = game.math_utils.f_clamp(floor((float((v_mx - J.getv(J.getv(game.j_ST, "drinkM"), "x"))) / float(v_gen))), 0.0, (J.getv(v_mus, "length") - 1.0))
		v_tip = J.getv(v_mus, v_i2)
		if J.gt(v_my, J.add(J.getv(J.getv(game.j_ST, "drinkM"), "y"), 32.0)):
			game.drink_system.f_takeCup(v_tip)
		else:
			game.drink_system.f_pourStart(v_tip)
		return null
	return null

# game.js:3466
func f_tutBusy() -> Variant:
	if not J.eq(J.getv(game.j_G, "day"), 1.0):
		return false
	if J.ge(J.getv(game.j_G, "tut"), J.getv(game.j_TUT, "length")):
		return false
	return J.lt(J.getv(game.j_G, "tut"), (J.getv(game.j_TUT, "length") - 1.0))
	return null

# game.js:3474
func f_updateTut() -> Variant:
	if J.ge(J.getv(game.j_G, "tut"), J.getv(game.j_TUT, "length")):
		return null
	if J.truth(J.method(J.getv(game.j_TUT, J.getv(game.j_G, "tut")), "ok", [])):
		J.setv(game.j_G, "tut", J.add(J.getv(game.j_G, "tut"), 1.0))
		J.method(game.j_SFX, "ding", [])
		if ((J.eq(J.getv(game.j_G, "day"), 1.0) and J.eq(J.getv(game.j_G, "tut"), (J.getv(game.j_TUT, "length") - 2.0))) and (not J.truth(J.getv(J.getv(game.j_G, "customers"), "length")))):
			game.customer_system.f_spawnCustomer()
			J.setv(game.j_G, "spawnT", 6.0)
		if J.ge(J.getv(game.j_G, "tut"), J.getv(game.j_TUT, "length")):
			game.effects.f_ftext("HAZIRSIN USTA!", (float(game.j_W) / float(2.0)), 120.0, J.getv(game.j_P, "au0"), {"sc": 2.0, "life": 2.0})
			game.effects.f_flash(0.18, "#ffe9a0")
	return null

