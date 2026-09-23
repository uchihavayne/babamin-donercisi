# Order bubbles, ingredient icons and the courier receipt.
extends "res://scripts/core/game_module.gd"

func order_bubble_rect(customer: Dictionary) -> Rect2:
	var wraps := 0
	for item in customer.items:
		if item.kind == "wrap": wraps += 1
	var height := 27 + 19 * wraps
	return Rect2(clampf(customer.x - 29, 2, 420), maxf(game.j_VIEW.top + 3, customer.y - 56 - height), 58, height)

func order_icon(item: Dictionary, x: float, y: float, time: float) -> void:
	game.icon_draw.f_icon(item.get("type", "cola") if item.kind == "drink" else ("iskender" if item.kind == "plate" else item.kind), x, y, time)
	if item.get("sauce") != null:
		var hot: bool = item.sauce == "hot"
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
	var step_x: float = 50.0 / max(1, customer.items.size())
	for i in customer.items.size():
		var x: float = r.position.x + 4 + step_x*(i+0.5)
		game.j_ctx.globalAlpha = 0.35 if customer.done[i] else 1.0
		order_icon(customer.items[i], x, r.position.y+12, time)
		game.j_ctx.globalAlpha = 1
		if customer.done[i]: game.icon_draw.f_drawCheck(x, r.position.y+12, "#50843b")
	var row_y := r.position.y+31
	for i in customer.items.size():
		var item: Dictionary = customer.items[i]
		if item.kind != "wrap": continue
		game.f_hl(r.position.x+4, row_y-9, 50, "#d8bc8e")
		game.j_ctx.globalAlpha = 0.35 if customer.done[i] else 1.0
		for k in 3:
			var ingredient: String = ["pickle", "yogurt", "fries"][k]
			order_badge(ingredient, r.position.x+13+k*16, row_y, ingredient in item.get("yok", []))
		game.j_ctx.globalAlpha = 1
		row_y += 19
	# Patience is integrated into the order; no extra panel or text obscures it.
	game.f_fr(r.position.x+4, r.end.y-4, 50, 2, "#ceb58d")
	game.f_fr(r.position.x+4, r.end.y-4, floor(50*clampf(customer.patience, 0, 1)), 2, "#b33028" if customer.patience < 0.3 else "#6c8e48")
	game.f_rrect(r.position.x-2, r.position.y-3, 9, 9, 2, border)
	game.text_draw.f_txt(str(int(customer.get("slot", 0))+1), r.position.x+2, r.position.y-2, "#fff1cf", {"align":"c"})
	if customer.get("wrongT", 0) > 0: game.icon_draw.f_drawX(customer.x, customer.y-34, "#d64932")
	game.j_ctx.restore()
	return null

func draw_preparation_overlay(time: Variant = null) -> Variant:
	var idx := int(game.j_G.act)
	var w: Variant = game.j_G.boards[idx]
	if not w is Dictionary or w.kind != "wrap": return null
	var x: float = game.wrap_system.f_boardCX(idx)
	var y: float = game.j_ST.board.y + game.j_ST.board.h - 4
	var recipe: Dictionary = w.get("_order_recipe", {})
	game.f_rrect(x-32, y-3, 64, 14, 2, "#493222")
	if w.has("_order_mark"):
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
	# Two mains and three sides fit above the chef, including every omission.
	var height := 12 + wraps.size()*20 + 17*int(ceil(sides.size()/3.0))
	game.f_rrect(2,top,43,height,2,"#b39663")
	game.f_rrect(3,top+1,41,height-2,1,"#fff1cf")
	game.text_draw.f_txt(game.order_text("PAKET","TO GO"),23,top+3,"#963d2e",{"align":"c"})
	var y := top+21
	for i in wraps:
		var item: Dictionary = p.order[i]
		game.j_ctx.globalAlpha = 0.35 if p.done[i] else 1.0
		order_icon(item,12,y,time)
		var omissions: Array = item.get("yok",[])
		for k in omissions.size():
			game.j_ctx.save(); game.j_ctx.translate(27+k*12,y); game.j_ctx.scale(0.75,0.75)
			order_badge(omissions[k],0,0,true)
			game.j_ctx.restore()
		game.j_ctx.globalAlpha = 1.0
		if p.done[i]: game.icon_draw.f_drawCheck(12,y,"#50843b")
		y += 20
	for n in sides.size():
		var i: int = sides[n]
		var x: float = 10+(n%3)*13
		var side_y: float = y-1+floor(n/3.0)*17
		game.j_ctx.globalAlpha = 0.35 if p.done[i] else 1.0
		game.j_ctx.save(); game.j_ctx.translate(x,side_y); game.j_ctx.scale(0.65,0.65)
		order_icon(p.order[i],0,0,time)
		game.j_ctx.restore()
		game.j_ctx.globalAlpha = 1.0
		if p.done[i]: game.icon_draw.f_drawCheck(x,side_y,"#50843b")
