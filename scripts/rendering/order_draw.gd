# Order bubbles, ingredient icons and the courier receipt.
extends "res://scripts/core/game_module.gd"

# BIRLESIK (kullanici): standart durumde (her sey var) tursu / yogurt / patates
# cipleri gereksiz kalabalik. Satir yalniz standarttan sapan durumde acilir ve
# yalniz istenmeyen malzemeler (ustu cizili) gosterilir; sos simgenin rozetinde.
func order_standard_disi(item: Dictionary) -> bool:
	return item.kind == "wrap" and not item.get("yok", []).is_empty()

# BIRLESIK (5. tur): her urune esit 20 px hucre; balon urun sayisina gore
# genisler (eskiden sabit 58 px'e 3 urun sikisip ust uste biniyordu).
const SIP_HUCRE := 20.0

func order_bubble_width(customer: Dictionary) -> float:
	return maxf(46.0, 8.0 + SIP_HUCRE * customer.items.size())

func order_bubble_rect(customer: Dictionary) -> Rect2:
	var wraps := 0
	for item in customer.items:
		if order_standard_disi(item): wraps += 1
	var height := 27 + 19 * wraps
	var w := order_bubble_width(customer)
	return Rect2(clampf(customer.x - w / 2.0, 2, 478 - w), maxf(game.j_VIEW.top + 3, customer.y - 56 - height), w, height)

func order_icon(item: Dictionary, x: float, y: float, time: float) -> void:
	var id: String = str(item.get("type", "cola")) if item.kind == "drink" else ("iskender" if item.kind == "plate" else str(item.kind))
	# tek tip boyda HD siparis ikonu (ikon_hd sip_*); yoksa eski ikon
	if not game.f_hdIkon("sip_" + id, x, y):
		game.icon_draw.f_icon(id, x, y, time)
	if item.get("sauce") != null:
		var hot: bool = item.sauce == "hot"
		# REMAKE kancasi: "!" / "G" yerine HD sos rozeti (aci biber / sarimsak)
		if game.f_hdIkon("sos_hot" if hot else "sos_garlic", x+6, y-5): return
		game.f_disc(x+6, y-5, 4, "#40291c")
		game.f_disc(x+6, y-5, 3, "#ce382c" if hot else "#fff3d2")
		game.text_draw.f_txt("!" if hot else "G", x+6, y-8, "#fff6df" if hot else "#675034", {"align":"c"})

func order_ingredient(ingredient: String, x: float, y: float) -> void:
	match ingredient:
		"pickle":
			game.f_ell(x, y, 5, 3, "#42672b"); game.f_ell(x, y-1, 4, 2, "#a7bc55")
			game.f_px(x-2, y-1, "#e9dd8a"); game.f_px(x+1, y-1, "#e9dd8a")
		"yogurt":
			game.f_ell(x, y+1, 5, 3, "#6f9aab"); game.f_ell(x, y, 5, 2, "#fff5de")
			game.f_px(x+2, y-2, "#fff5de")
		"fries":
			for i in 3:
				game.f_fr(x-4+i*3, y-4+(i%2), 2, 8, "#c9852c")
				game.f_fr(x-4+i*3, y-4+(i%2), 1, 7, "#f4ce69")
		"meat":
			for i in 3:
				game.f_fr(x-5+i*2, y-3+i*2, 7, 2, "#9c5427")
				game.f_hl(x-5+i*2, y-3+i*2, 6, "#e4a45b")

func order_badge(ingredient: String, x: float, y: float, omitted: bool) -> void:
	# REMAKE kancasi: HD malzeme cipi
	if game.f_hdCip(ingredient, x, y, omitted): return
	game.f_rrect(x-7, y-6, 14, 13, 2, "#f4d3bc" if omitted else "#e7dec3")
	order_ingredient(ingredient, x, y)
	if omitted:
		game.f_ln(x-5, y+5, x+5, y-5, "#b33028")
		game.f_ln(x-5, y+4, x+5, y-6, "#b33028")

func f_drawOrderBubble(customer: Variant = null, time: Variant = null) -> Variant:
	if customer.bubble <= 0.02: return null
	var r := order_bubble_rect(customer)
	var selected: bool = is_same(game.chosen_order, customer)
	var border := "#b33028" if customer.patience < 0.3 else ("#e8b453" if selected else "#876c48")
	game.j_ctx.save()
	game.j_ctx.globalAlpha = minf(1, float(customer.bubble)*2)
	# REMAKE kancasi: HD balon (9 dilim + kuyruk)
	if not game.f_hdSiparisBalon(r.position.x, r.position.y, r.size.x, r.size.y, customer.patience < 0.3, selected, customer.x):
		game.f_rrect(r.position.x+1, r.position.y+2, r.size.x, r.size.y, 3, "#35271d")
		game.f_rrect(r.position.x, r.position.y, r.size.x, r.size.y, 3, border)
		game.f_rrect(r.position.x+1, r.position.y+1, r.size.x-2, r.size.y-2, 2, "#fff1cf")
		game.f_fr(customer.x-2, r.end.y, 5, 2, border)
		game.f_fr(customer.x-1, r.end.y+2, 3, 2, border)
	var bos: float = (r.size.x - 8.0 - SIP_HUCRE * customer.items.size()) / 2.0
	for i in customer.items.size():
		var x: float = r.position.x + 4 + bos + SIP_HUCRE * (i + 0.5)
		game.j_ctx.globalAlpha = 0.35 if customer.done[i] else 1.0
		order_icon(customer.items[i], x, r.position.y+12, time)
		game.j_ctx.globalAlpha = 1
		if customer.done[i]: game.icon_draw.f_drawCheck(x, r.position.y+12, "#50843b")
	var row_y := r.position.y+31
	for i in customer.items.size():
		var item: Dictionary = customer.items[i]
		if not order_standard_disi(item): continue
		game.f_hl(r.position.x+4, row_y-9, r.size.x-8, "#d8bc8e")
		game.j_ctx.globalAlpha = 0.35 if customer.done[i] else 1.0
		var yok: Array = item.get("yok", [])
		for k in yok.size():
			order_badge(str(yok[k]), r.position.x + r.size.x / 2.0 + (k - (yok.size() - 1) / 2.0) * 16, row_y, true)
		game.j_ctx.globalAlpha = 1
		row_y += 19
	# Patience is integrated into the order; no extra panel or text obscures it.
	game.f_fr(r.position.x+4, r.end.y-4, r.size.x-8, 2, "#ceb58d")
	game.f_fr(r.position.x+4, r.end.y-4, floor((r.size.x-8)*clampf(customer.patience, 0, 1)), 2, "#b33028" if customer.patience < 0.3 else "#6c8e48")
	# (sira numarasi rozeti kaldirildi: balonun ustunde gereksiz kalabalik)
	if customer.get("wrongT", 0) > 0: game.icon_draw.f_drawX(customer.x, customer.y-34, "#d64932")
	game.j_ctx.restore()
	return null

# BIRLESIK (kullanici: "iskender tabaginda ne eksik gorunmuyor"): tabak / pide
# icin de serit. Tabak: et, yogurt, tereyagi (+ garnitur acikken domates, biber)
# ve her birinin dolma noktalari; pide: dograma sayaci.
func draw_plate_overlay(w: Dictionary, x: float, y: float) -> void:
	if w.kind == "pide":
		game.f_rrect(x-32, y-3, 64, 14, 2, "#493222")
		game.text_draw.f_txt(game.order_text("DOĞRA ", "CHOP ") + str(int(w.get("n", 0))) + "/" + str(int(game.j_PIDE_NEED)), x, y, "#f8d880", {"align":"c"})
		return
	if w.state != "open":
		game.f_rrect(x-32, y-3, 64, 14, 2, "#493222")
		game.text_draw.f_txt(game.order_text("SERVİS", "SERVE"), x, y, "#f8d880", {"align":"c"})
		return
	var parts: Array = [["meat", J.n(w.get("meat", 0)), J.n(J.method(game.j_TUN, "iskMeat", [game.j_G]))],
		["yogurt", J.n(w.get("yogurtN", 0)), J.n(game.j_PLATE_YOGURT)],
		["butter", 1.0 if J.truth(w.get("butter")) else 0.0, 1.0]]
	if J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G])):
		parts.append(["tomato", J.n(w.get("tomato", 0)), J.n(game.j_TOMATO_NEED)])
		parts.append(["pepper", J.n(w.get("pepper", 0)), J.n(game.j_PEPPER_NEED)])
	var aralik := 15.0
	var gen := parts.size() * aralik + 4.0
	game.f_rrect(x - gen / 2.0, y-3, gen, 14, 2, "#493222")
	for i in parts.size():
		var m: String = parts[i][0]
		var n: int = int(parts[i][1])
		var need: int = maxi(1, int(parts[i][2]))
		var px := x - (parts.size() - 1) * aralik / 2.0 + i * aralik
		if not game.f_hdMalzeme(m, px, y+1):
			if m in ["meat", "pickle", "yogurt", "fries"]: order_ingredient(m, px, y+1)
			else: game.f_disc(px, y+1, 4, {"tomato": "#d8402c", "pepper": "#4e9a24", "butter": "#f6dc84"}[m])
		var adim := minf(3.0, 12.0 / need)
		var dx0 := px - (need - 1) * adim / 2.0
		for dot in need:
			game.f_fr(floor(dx0 + dot * adim - 0.5 + 0.5), y+7, 2 if adim >= 3.0 else 1, 2, "#f8d880" if dot < n else "#7a6246")

func draw_preparation_overlay(time: Variant = null) -> Variant:
	var idx := int(game.j_G.act)
	var w: Variant = game.j_G.boards[idx]
	if not w is Dictionary: return null
	var x: float = game.wrap_system.f_boardCX(idx)
	var y: float = game.j_ST.board.y + game.j_ST.board.h - 4
	if w.kind != "wrap":
		draw_plate_overlay(w, x, y)
		return null
	var recipe: Dictionary = w.get("_order_recipe", {})
	game.f_rrect(x-32, y-3, 64, 14, 2, "#493222")
	# musteri sira numarasi balonlardan kaldirildi; tahtada yalniz telefon ("P") isareti kalir
	if w.has("_order_mark") and w._order_mark == "P":
		game.f_rrect(x-40, y-3, 9, 10, 2, "#e8b453")
		game.text_draw.f_txt(w._order_mark, x-36, y-2, "#493222", {"align":"c"})
	if w.state == "open":
		for i in 4:
			var ingredient: String = game.ORDER_FIELDS.keys()[i]
			var px := x-24+i*16
			var n := int(w.get(game.ORDER_FIELDS[ingredient], 0))
			# REMAKE kancasi: HD malzeme ikonu (zeminsiz)
			if not game.f_hdMalzeme(ingredient, px, y+1): order_ingredient(ingredient, px, y+1)
			if ingredient in recipe.get("yok", []):
				game.f_ln(px-5, y+5, px+5, y-4, "#f58d6f")
				if n > 0: game.text_draw.f_txt("!", px+6, y-2, "#ff8665")
			else:
				for dot in 4: game.f_fr(px-5+dot*3, y+7, 2, 2, "#f8d880" if dot < n else "#7a6246")
	else:
		var label: String = game.order_text("KAĞITLA", "PAPER")
		if w.get("burnt", false): label = game.order_text("YANMIŞ", "BURNT")
		elif w.get("paper", false): label = game.order_text("SERVİS", "SERVE")
		elif game.recipe_system.f_wrapNeedsGrill(w): label = game.order_text("IZGARA", "GRILL")
		game.text_draw.f_txt(label, x, y, "#f8d880", {"align":"c"})
	return null

func draw_order_receipt(time: float) -> void:
	var p: Dictionary = game.j_G.phone
	if p.state != "order": return
	var top: float = game.j_ST.phone.y + game.j_ST.phone.h + 2
	var wraps: Array[int] = []
	var sides: Array[int] = []
	for i in p.order.size():
		if p.order[i].kind == "wrap": wraps.append(i)
		else: sides.append(i)
	# BIRLESIK: balonla ayni HD ikonlar (olceksiz; ctx.scale HD'yi eski piksele
	# dusuruyordu), yan urunler iki sutun, istenmeyenler kucuk "yok" rozeti.
	var height := 14 + wraps.size()*20 + 17*int(ceil(sides.size()/3.0))
	game.f_rrect(2,top,47,height,2,"#b39663")
	game.f_rrect(3,top+1,45,height-2,1,"#fff1cf")
	game.text_draw.f_txt(game.order_text("PAKET","TO GO"),25,top+3,"#963d2e",{"align":"c"})
	var y := top+21
	for i in wraps:
		var item: Dictionary = p.order[i]
		game.j_ctx.globalAlpha = 0.35 if p.done[i] else 1.0
		order_icon(item,12,y,time)
		var omissions: Array = item.get("yok",[])
		for k in omissions.size():
			if not game.f_hdIkon("yok_" + str(omissions[k]), 29+k*13, y):
				game.j_ctx.save(); game.j_ctx.translate(29+k*13,y); game.j_ctx.scale(0.75,0.75)
				order_badge(omissions[k],0,0,true)
				game.j_ctx.restore()
		game.j_ctx.globalAlpha = 1.0
		if p.done[i]: game.icon_draw.f_drawCheck(12,y,"#50843b")
		y += 20
	for n in sides.size():
		var i: int = sides[n]
		var x: float = 11+(n%3)*14
		var side_y: float = y+floor(n/3.0)*17
		game.j_ctx.globalAlpha = 0.35 if p.done[i] else 1.0
		order_icon(p.order[i],x,side_y,time)
		game.j_ctx.globalAlpha = 1.0
		if p.done[i]: game.icon_draw.f_drawCheck(x,side_y,"#50843b")
