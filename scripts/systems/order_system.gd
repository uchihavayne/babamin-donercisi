# Order matching, selection and preparation rules.
extends "res://scripts/core/game_module.gd"

func order_text(tr_text: String, en_text: String) -> String:
	return game.localization.cift(tr_text, en_text)

func f_startDay() -> Variant:
	game.chosen_order = {}
	return game.session_system.f_startDay()

func order_items(owner: Dictionary) -> Array:
	return owner.get("items", owner.get("order", []))

func order_live(owner: Dictionary) -> bool:
	if owner.is_empty(): return false
	if is_same(owner, game.j_G.phone): return owner.state == "order"
	for customer in game.j_G.customers:
		if is_same(customer, owner): return customer.state == "wait"
	return false

func order_next(owner: Dictionary) -> int:
	if not order_live(owner): return -1
	var items := order_items(owner)
	for i in items.size():
		if items[i].kind == "wrap" and not owner.done[i]: return i
	return -1

func order_select(owner: Dictionary) -> void:
	var index := order_next(owner)
	if index < 0: return
	game.chosen_order = owner
	var w: Variant = game.j_G.boards[int(game.j_G.act)]
	if w is Dictionary and w.kind == "wrap" and w.state == "open": order_bind(w, owner, index)
	J.method(game.j_SFX, "pick", [])

func order_bind(w: Dictionary, owner: Dictionary, index: int) -> void:
	w._order_recipe = order_items(owner)[index].duplicate(true)
	w._order_owner = owner
	w._order_index = index
	w._order_mark = "P" if is_same(owner, game.j_G.phone) else str(int(owner.get("slot", 0)) + 1)

func order_reserved(owner: Dictionary, index: int) -> bool:
	var food: Array = game.j_G.boards.duplicate()
	food.append(game.j_G.hand)
	for slot in game.j_G.grill.slots: food.append(slot.w)
	for w in food:
		if w is Dictionary and is_same(w.get("_order_owner"), owner) and w.get("_order_index", -1) == index: return true
	return false

func f_newWrap(preferred_board: Variant = null) -> Variant:
	var idx: int = game.wrap_system.f_emptyBoard(preferred_board)
	var result: Variant = game.wrap_system.f_newWrap(preferred_board)
	if idx < 0 or not game.j_G.boards[idx] is Dictionary: return result
	var owners: Array = []
	if order_live(game.chosen_order): owners.append(game.chosen_order)
	owners.append_array(game.j_G.customers)
	if game.j_G.phone.state == "order": owners.append(game.j_G.phone)
	for owner in owners:
		if not order_live(owner): continue
		var items := order_items(owner)
		for i in items.size():
			if items[i].kind == "wrap" and not owner.done[i] and not order_reserved(owner, i):
				order_bind(game.j_G.boards[idx], owner, i)
				return result
	return result

func f_phoneClick() -> Variant:
	var result: Variant = game.phone_system.f_phoneClick()
	if game.j_G.phone.state == "order" and not J.truth(game.j_G.hand): order_select(game.j_G.phone)
	return result

func f_secimUyuyor(w: Variant = null, recipe: Variant = null) -> Variant:
	if not w is Dictionary or not recipe is Dictionary: return false
	for ingredient in ["pickle", "yogurt", "fries"]:
		var amount := float(w.get(game.ORDER_FIELDS[ingredient], 0))
		if ingredient in recipe.get("yok", []):
			if amount != 0: return false
		elif amount < 4: return false
	return true

func order_matches(w: Dictionary, recipe: Dictionary) -> bool:
	return w.get("meat", 0) >= game.j_MEAT_NEED and game.f_secimUyuyor(w, recipe) and w.get("sauce") == recipe.get("sauce")

func order_problem(w: Dictionary, recipe: Dictionary) -> String:
	var names := {"meat":order_text("Et", "Meat"), "pickle":order_text("Turşu", "Pickles"), "yogurt":order_text("Yoğurt", "Yogurt"), "fries":order_text("Patates", "Fries")}
	for ingredient in game.ORDER_FIELDS:
		var amount := int(w.get(game.ORDER_FIELDS[ingredient], 0))
		if ingredient in recipe.get("yok", []):
			if amount > 0: return names[ingredient] + order_text(" istenmiyor", " not wanted")
		elif amount < 4: return names[ingredient] + order_text(" eksik", " missing")
	if w.get("sauce") != recipe.get("sauce"):
		return order_text("Acı sos isteniyor", "Hot sauce wanted") if recipe.get("sauce") == "hot" else (order_text("Sarımsaklı sos isteniyor", "Garlic sauce wanted") if recipe.get("sauce") == "garlic" else order_text("Sossuz isteniyor", "No sauce wanted"))
	return ""

func f_wrapFull(w: Variant = null) -> Variant:
	if w is Dictionary and w.has("_order_recipe"): return order_matches(w, w._order_recipe)
	return game.recipe_system.f_wrapFull(w)

func f_wrapQuality(w: Variant = null) -> Variant:
	if w is Dictionary and not w.get("burnt", false) and w.has("_order_recipe") and order_matches(w, w._order_recipe): return 1.0
	return game.recipe_system.f_wrapQuality(w)

func f_wrapKimlik(w: Variant = null) -> Variant:
	if not w is Dictionary or w.kind != "wrap": return null
	var badges: Array = []
	if w.has("_order_recipe") or J.method(game.j_TUN,"secimOn",[game.j_G]):
		for ingredient in ["pickle","yogurt","fries"]:
			if w.get(game.ORDER_FIELDS[ingredient],0) == 0: badges.append({"tip":"yok","m":ingredient})
	if w.get("sauce") != null: badges.append({"tip":"sos","m":w.sauce})
	return badges

# Kullanici istegi (birlesik surum): siparis sirasi DAYATILMAZ. Yeni durum ilk
# bekleyen siparise baglaniyordu ve o tarife uymazsa sarma reddediliyordu
# ("Sossuz isteniyor"). Artik durum baska bir bekleyen siparise uyuyorsa ona
# baglanir; hicbirine uymuyorsa baglanti kalkar ve yine sarilir. Teslimde her
# musteri kendi siparisine uyani kabul eder (order_match_index).
func f_finishRoll(index: Variant = null) -> Variant:
	var w: Variant = game.j_G.boards[int(index)]
	if w is Dictionary and w.has("_order_recipe") and not order_matches(w, w._order_recipe):
		order_rebind_or_free(w)
	return game.wrap_system.f_finishRoll(index)

func order_rebind_or_free(w: Dictionary) -> void:
	var owners: Array = []
	if order_live(game.chosen_order): owners.append(game.chosen_order)
	owners.append_array(game.j_G.customers)
	if game.j_G.phone.state == "order": owners.append(game.j_G.phone)
	for owner in owners:
		if not order_live(owner): continue
		var items := order_items(owner)
		for i in items.size():
			if items[i].kind != "wrap" or owner.done[i]: continue
			if order_reserved(owner, i) and not (is_same(w.get("_order_owner"), owner) and w.get("_order_index", -1) == i): continue
			if order_matches(w, items[i]):
				order_bind(w, owner, i)
				return
	for key in ["_order_recipe", "_order_owner", "_order_index", "_order_mark"]: w.erase(key)

func order_match_index(w: Dictionary, owner: Dictionary) -> int:
	var items := order_items(owner)
	for i in items.size():
		if not owner.done[i] and items[i].kind == "wrap" and order_matches(w, items[i]): return i
	return -1

func order_reject(w: Dictionary, owner: Dictionary) -> void:
	var index := order_next(owner)
	var message := order_text("Bu sipariş farklı", "Different order")
	if index >= 0: message = order_problem(w, order_items(owner)[index])
	game.session_system.f_say(message)
	owner.wrongT = 0.8
	J.method(game.j_SFX, "bad", [])

# BIRLESIK (7. tur, kullanici: "eksik malzemeli verirsek verebilelim, illa tam
# malzeme olmasina gerek yok, ona gore para aliriz"). Siparise birebir uyan durum
# yoksa bekleyen ilk durum kalemine (once ayni soslu) verilir; ucret siparise
# gore tamamlik oraniyla carpilir: et %40, patates %28, tursu %16, yogurt %16.
# "Istenmeyen" malzeme konmamissa o pay tam, konmussa kesilir.
# en iyi kalem: once ayni soslu, sonra en yuksek tamamlik orani
func order_loose_index(w: Dictionary, owner: Dictionary) -> int:
	var items := order_items(owner)
	var en := -1
	var en_puan := -1.0
	for i in items.size():
		if owner.done[i] or items[i].kind != "wrap": continue
		var puan := order_quality(w, items[i]) + (2.0 if w.get("sauce") == items[i].get("sauce") else 0.0)
		if puan > en_puan:
			en_puan = puan
			en = i
	return en

func order_quality(w: Dictionary, recipe: Dictionary) -> float:
	var q := 0.4 * minf(float(w.get("meat", 0)) / float(game.j_MEAT_NEED), 1.0)
	for pay in [["pickle", 0.16], ["yogurt", 0.16], ["fries", 0.28]]:
		var amount := float(w.get(game.ORDER_FIELDS[pay[0]], 0))
		if pay[0] in recipe.get("yok", []): q += pay[1] if amount == 0 else 0.0
		else: q += pay[1] * minf(amount / 4.0, 1.0)
	return clampf(q, 0.0, 1.0)

func f_deliver(customer: Variant = null) -> Variant:
	var w: Variant = game.j_G.hand
	if w is Dictionary and w.kind == "wrap" and customer.state == "wait" and not game.leader_system.f_liderBekliyor():
		if order_match_index(w, customer) < 0:
			var i := order_loose_index(w, customer)
			if i < 0:
				order_reject(w, customer)
				return null
			if not w.get("burnt", false): w.quality = order_quality(w, order_items(customer)[i])
			w._teslim_idx = i
		# Intentional omissions never reduce the quality of a correct order.
		elif not w.get("burnt", false): w.quality = 1.0
	return game.customer_system.f_deliver(customer)

func f_giveToCourier() -> Variant:
	var w: Variant = game.j_G.hand
	if w is Dictionary and w.kind == "wrap" and game.j_G.phone.state == "order":
		var tam := order_match_index(w, game.j_G.phone)
		if tam < 0:
			# eksik malzemeli paket de verilir (ucret tamamlik oraniyla)
			var i := order_loose_index(w, game.j_G.phone)
			if i < 0:
				order_reject(w, game.j_G.phone)
				return false
			order_bind(w, game.j_G.phone, i)
			if not w.get("burnt", false): w.quality = order_quality(w, order_items(game.j_G.phone)[i])
			w._teslim_idx = i
		else:
			# Rebind a correctly matched spare wrap for the courier's completeness check.
			order_bind(w, game.j_G.phone, tam)
			if not w.get("burnt", false): w.quality = 1.0
	return game.phone_system.f_giveToCourier()
