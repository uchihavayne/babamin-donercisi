# Direct interactions with visible counter objects on controller and touch.
# Stock, recipes and machine timers remain owned by the original game rules.
extends RefCounted

var game: Node
var enabled := true
var targets: Array[Dictionary] = []
var selected := "spit"
var holding: Dictionary = {}
var serial := 0
var recipe_board := -1
var hint_time := 0.0

func _init(owner_game: Node) -> void: game = owner_game

func text(tr_text: String, en_text: String) -> String:
	return tr_text if game.j_LANG == "tr" else en_text

func tun(key: String) -> Variant: return game.J.method(game.j_TUN, key, [game.j_G])

func available() -> bool:
	if not enabled or game.j_G == null or game.j_G.scene != "play" or game.suspended or game.overlay_open: return false
	if game.j_TEXTIN.active or game.debug_draw.f_testPanelOpen(): return false
	for panel in [game.j_CUSTOM, game.j_PAYP, game.j_BRP, game.j_SESP, game.j_STATS, game.j_BSP]:
		if panel.get("open", false): return false
	return true

func reset() -> void:
	cancel()
	selected = "spit"
	hint_time = 0.0
	targets.clear()

func add(id: String, label: String, rect: Rect2, group := "", index := -1, object: Variant = null) -> void:
	targets.append({"id":id, "label":label, "rect":rect, "group":group if group != "" else id, "index":index, "object":object})

func fixture(key: String, label: String) -> void:
	var s: Dictionary = game.j_ST[key]
	add(key,label,Rect2(s.x,s.y,s.w,s.h))

func uid(object: Dictionary) -> String:
	if not object.has("_station_uid"):
		serial += 1
		object._station_uid = serial
	return str(object._station_uid)

func refresh() -> void:
	targets.clear()
	if game.j_G.scene != "play": return
	fixture("spit", text("Döner", "Spit"))
	var bread: Dictionary = game.j_ST.bread
	if tun("iskOn"):
		add("pide",text("Pide","Pide"),Rect2(bread.x,bread.y,bread.w,16),"ingredient")
		add("bread",text("Lavaş","Flatbread"),Rect2(bread.x,bread.y+16,bread.w,bread.h-16),"ingredient")
	else: add("bread",text("Lavaş","Flatbread"),Rect2(bread.x,bread.y,bread.w,bread.h),"ingredient")
	for key in ["meat","pickle","yogurt","friesT"]:
		var st: Dictionary = game.j_ST[key]
		add(key,{"meat":"Et","pickle":"Turşu","yogurt":"Yoğurt","friesT":"Patates"}[key],Rect2(st.x,st.y,st.w,st.h),"ingredient")
	if tun("garnishOn"):
		var g: Dictionary = game.j_ST.garnish
		add("tomato","Domates",Rect2(g.x,g.y,g.w/2,g.h),"ingredient")
		add("pepper","Biber",Rect2(g.x+g.w/2,g.y,g.w/2,g.h),"ingredient")
	var sauce: Dictionary = game.j_ST.sauce
	if tun("sauceOn"):
		add("hot","Acı sos",Rect2(sauce.x,sauce.y,sauce.w/3,sauce.h),"ingredient")
		add("garlic","Sarımsaklı sos",Rect2(sauce.x+sauce.w/3,sauce.y,sauce.w/3,sauce.h),"ingredient")
	if tun("iskOn"): add("butter","Tereyağı",Rect2(sauce.x+sauce.w*2/3,sauce.y,sauce.w/3,sauce.h),"ingredient")
	fixture("paper",text("Kağıt","Paper"))
	for i in int(tun("boards")):
		var width: float = game.j_ST.board.w / float(tun("boards"))
		add("board:"+str(i),text("Tahta ","Board ")+str(i+1),Rect2(game.j_ST.board.x+i*width,game.j_ST.board.y,width,game.j_ST.board.h),"board",i)
	fixture("potato",text("Patates çuvalı","Potato sack"))
	fixture("cut",text("Doğrama","Chopping"))
	fixture("fryer",text("Fritöz","Fryer"))
	fixture("crate",text("Depo","Stock"))
	if game.j_G.crate.open:
		var items: Array = game.stock_system.f_crateItems()
		for i in items.size():
			var r: Array = game.stock_system.f_crateSlotRect(i)
			add("refill:"+items[i][0],str(items[i][1]),Rect2(r[0],r[1],r[2],r[3]),"crate")
	fixture("trash",text("Çöp","Trash"))
	if tun("grillOn"):
		fixture("grill",text("Izgara","Grill"))
		for i in game.j_G.grill.slots.size():
			var slot: Dictionary = game.j_G.grill.slots[i]
			add("grill:"+uid(slot),text("Izgara gözü ","Grill slot ")+str(i+1),Rect2(game.grill_system.f_grillSlotX(i)-10,game.grill_system.f_grillSlotY(i)-10,20,20),"grill",i,slot)
	for drink in game.drink_system.f_icecekMusluklari():
		var pos: Array = game.drink_system.f_cupPos(drink)
		var drink_width: float = game.j_ST.drinkM.w / game.drink_system.f_icecekMusluklari().size()
		add("drink:"+drink, str(drink).capitalize(),Rect2(pos[0]-drink_width/2,game.j_ST.drinkM.y,drink_width,game.j_ST.drinkM.h),"drink")
	if tun("fboxOn"): fixture("fbox",text("Patates kutusu","Fries box"))
	if tun("sweetOn"): fixture("sweet",text("Tatlı","Dessert"))
	if game.phone_system.f_phoneActive(): fixture("phone",text("Telefon","Phone"))
	if game.shop_background.f_dayiVar(): fixture("uncle",text("Dayı / kurye","Uncle / courier"))
	for customer in game.j_G.customers:
		if customer.state == "wait":
			var customer_rect := Rect2(customer.x-16,customer.y-52,32,44).merge(game.order_bubble_rect(customer))
			add("customer:"+uid(customer),text("Müşteri ","Customer ")+str(int(customer.slot)+1) if customer.has("slot") else text("Müşteri","Customer"),customer_rect,"customer",-1,customer)
	for coin in game.j_G.coins:
		if coin.landed: add("coin:"+uid(coin),text("Para topla","Collect money"),Rect2(coin.x-7,coin.y-8,14,14),"coin",-1,coin)
	var cat: Variant = game.j_G.get("kedi")
	if cat is Dictionary and cat.get("faz", "") in ["bekle","gelis"]:
		add("cat",text("Kedi","Cat"),Rect2(float(cat.get("x",40))-12,game.event_system.f_kediY()-16,24,20))
	if target().is_empty():
		cancel()
		selected = "spit"

func target() -> Dictionary:
	for item in targets:
		if item.id == selected: return item
	return {}

func select(id: String, aim := true) -> void:
	refresh()
	for item in targets:
		if item.id != id: continue
		if selected != id:
			cancel()
			hint_time = 1.4
			if game.j_G.crate.open and item.group != "crate": game.j_G.crate.open = false
		selected = id
		if item.group == "board": game.j_G.act = item.index
		if aim: game.pointer(item.rect.get_center())
		return

func select_at(point: Vector2, _direct := true) -> bool:
	if not available(): return false
	refresh()
	var best: Dictionary = {}
	for item in targets:
		if game.j_G.crate.open and item.id.begins_with("refill:") and item.rect.has_point(point):
			best = item
			break
		if item.rect.has_point(point) and (best.is_empty() or item.rect.get_area() < best.rect.get_area()): best = item
	if best.is_empty(): return false
	select(best.id,false)
	game.pointer(point)
	return best.id != "spit" # A finger on the spit still cuts directly.

func navigate(direction: Vector2) -> void:
	if not available(): return
	refresh()
	var origin: Vector2 = target().get("rect",Rect2(60,90,40,40)).get_center()
	var best := ""
	var score := INF
	for item in targets:
		var offset: Vector2 = item.rect.get_center()-origin
		if game.j_G.crate.open and item.group != "crate": continue
		var forward := offset.dot(direction)
		if forward < 2: continue
		var candidate := forward + absf(offset.cross(direction))*2.0
		if candidate < score: score = candidate; best = item.id
	if best != "": select(best)

func cycle(step: int, within_group := true) -> void:
	refresh()
	var current := target()
	if within_group and (current.get("group","") == "ingredient" or selected == "paper"):
		cancel()
		game.j_G.act = posmod(int(game.j_G.act)+step,int(tun("boards")))
		return
	var list: Array[Dictionary] = []
	for item in targets:
		if not within_group or item.group == current.get("group", ""): list.append(item)
	if list.size() <= 1: list = targets
	for i in list.size():
		if list[i].id == selected: select(list[posmod(i+step,list.size())].id); return

func action(id: String, tr_text: String, en_text: String, allowed := true, hold := false) -> Dictionary:
	return {"id":id,"label":text(tr_text,en_text),"enabled":allowed,"hold":hold}

func board() -> Variant:
	var t := target()
	return game.j_G.boards[t.index if t.get("group", "") == "board" else int(game.j_G.act)]

func can_paper(w: Dictionary) -> bool:
	return w.state == "rolled" and not w.get("burnt",false) and (not game.recipe_system.f_wrapNeedsGrill(w) or game.grill_system.f_grillTikali()) and game.j_G.paper.busy <= 0

func board_actions(w: Variant) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var hand: bool = game.J.truth(game.j_G.hand)
	var free: bool = not hand and not game.J.truth(game.j_G.drag)
	if w == null:
		if hand:
			list.append(action("put","Tezgâha bırak","Put on board",game.j_G.hand.kind in ["wrap","plate"]))
		else:
			list.append(action("bread","Lavaş aç","Open flatbread"))
			if tun("iskOn"): list.append(action("pide","Pide al","Take pide"))
	elif w.kind == "pide": list.append(action("pide_chop","Pide doğra","Chop pide",free))
	elif w.state == "open":
		var meat_need: float = tun("iskMeat") if w.kind == "plate" else game.j_MEAT_NEED
		list.append(action("meat","Et ekle","Add meat",free and w.meat < meat_need and game.j_G.meat > 0))
		if w.kind == "wrap": list.append(action("pickle","Turşu ekle","Add pickles",free and w.pickleN < game.j_PICKLE_NEED and game.j_G.stock.pickle > 0))
		list.append(action("yogurt","Yoğurt ekle","Add yogurt",free and w.yogurtN < (game.j_PLATE_YOGURT if w.kind == "plate" else game.j_YOGURT_NEED) and game.j_G.stock.yogurt > 0))
		if w.kind == "wrap": list.append(action("fries","Patates ekle","Add fries",free and w.friesN < game.j_FRIES_NEED and game.j_G.friesTray > 0))
		if w.kind == "plate" and tun("garnishOn"):
			list.append(action("tomato","Domates ekle","Add tomato",free and w.get("tomato",0) < game.j_TOMATO_NEED and game.j_G.stock.tomato > 0))
			list.append(action("pepper","Biber ekle","Add pepper",free and w.get("pepper",0) < game.j_PEPPER_NEED and game.j_G.stock.pepper > 0))
		if w.kind == "plate": list.append(action("butter","Tereyağı ekle","Add butter",free and not w.butter))
		elif tun("sauceOn"):
			list.append(action("hot","Acı sos","Hot sauce",free and w.get("sauce") != "hot"))
			list.append(action("garlic","Sarımsaklı sos","Garlic sauce",free and w.get("sauce") != "garlic"))
		if w.kind == "wrap": list.append(action("roll","Sar · basılı tut","Roll · hold",free and game.recipe_system.f_wrapAny(w),true))
		elif game.recipe_system.f_plateAny(w): list.append(action("take","Tabağı al","Take plate",free))
	elif w.state == "rolled":
		if game.recipe_system.f_wrapNeedsGrill(w): list.append(action("grill_put","Izgaraya koy","Put on grill",free and not game.grill_system.f_grillDolu() and not w.get("burnt",false)))
		list.append(action("paper","Kağıtla" + (" · basılı tut" if game.equipment_system.f_UV(game.j_G,"paper") == 0 else ""),"Wrap in paper" + (" · hold" if game.equipment_system.f_UV(game.j_G,"paper") == 0 else ""),free and can_paper(w),game.equipment_system.f_UV(game.j_G,"paper") == 0))
		if tun("sauceLate") and not game.J.truth(w.get("sauce")):
			list.append(action("hot","Acı sos","Hot sauce",free))
			list.append(action("garlic","Sarımsaklı sos","Garlic sauce",free))
		list.append(action("take","Dürümü al","Take wrap",free))
	else: list.append(action("take","Servis için al","Pick up to serve",free))
	return list

func actions() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var t := target()
	if t.is_empty() or not available(): return list
	var hand: bool = game.J.truth(game.j_G.hand)
	var free: bool = not hand and not game.J.truth(game.j_G.drag)
	var w: Variant = board()
	if t.group == "board": list = board_actions(w)
	elif t.group == "ingredient" or selected == "paper":
		var id: String = "fries" if selected == "friesT" else selected
		# akilli hedef: malzeme secili bolmeye degil, ona ihtiyaci olan urune gider
		var hedef: int = game.wrap_system.f_malzemeHedefi(id) if id in MALZEMELER else -1
		if hedef >= 0: w = game.j_G.boards[hedef]
		if id in ["bread","pide"]:
			list.append(action(id,"AL","TAKE",free and game.wrap_system.f_emptyBoard() >= 0))
		else:
			for a in board_actions(w):
				if a.id == id: list.append(a)
	elif t.group == "customer":
		list.append(action("serve","Servis et","Serve",true) if hand else action("order","Siparişi seç","Choose order",free and game.order_next(t.object) >= 0))
	elif t.group == "coin": list.append(action("collect","Parayı topla","Collect money"))
	elif t.group == "drink":
		var kind: String = t.id.trim_prefix("drink:")
		var cup: Variant = game.j_G.cups.get(kind)
		list.append(action("pour","Bardağı doldur","Fill cup",cup == null))
		list.append(action("drink_take","Bardağı al","Take cup",free and cup is Dictionary and cup.fill >= 1.0))
	elif t.group == "grill":
		if t.object is Dictionary: list.append(action("grill_take","Izgaradan al","Take off grill",free and t.object.done))
		elif w is Dictionary and w.kind == "wrap" and w.state == "rolled" and game.recipe_system.f_wrapNeedsGrill(w): list.append(action("grill_put","Izgaraya koy","Put on grill",free and not game.grill_system.f_grillDolu() and not w.get("burnt",false)))
		else: list.append(action("grill_open","Izgara gözlerini seç","Select grill slots",not game.j_G.grill.slots.is_empty()))
	else:
		match selected:
			"spit": list.append(action("cut_meat","Kes · basılı tut","Slice · hold",free and game.j_G.meat < tun("meatCap"),true))
			"potato": list.append(action("potato","Patates al","Take potato",free and not game.j_G.cut.potato and not game.J.truth(game.j_G.get("flyP"))))
			"cut":
				list.append(action("chop","Doğra · basılı tut","Chop · hold",free and game.j_G.cut.potato,true))
				list.append(action("potato","Patates al","Take potato",free and not game.j_G.cut.potato and not game.J.truth(game.j_G.get("flyP"))))
				list.append(action("fry","Fritöze koy","Put in fryer",free and game.j_G.cut.raw > 0 and game.j_G.fryer.state == "idle"))
			"fryer": list.append(action("fry",text("Hazır patatesi al","Take cooked fries") if game.j_G.fryer.state == "done" else text("Kızartmayı başlat","Start frying"),"Take fries" if game.j_G.fryer.state == "done" else "Start frying",free and game.j_G.fryer.state != "fry"))
			"fbox": list.append(action("fbox","Kutuyu al" if game.j_G.fbox.ready > 0 else "Kutuyu doldur","Take box" if game.j_G.fbox.ready > 0 else "Fill box",free and game.j_G.fbox.busy <= 0 and not game.J.truth(game.j_G.fbox.fly) and (game.j_G.fbox.ready > 0 or (not tun("autoBox") and game.j_G.friesTray >= 2))))
			"sweet": list.append(action("sweet","Tatlı al","Take dessert",free and game.j_G.stock.sweet > 0))
			"crate": list.append(action("crate","AÇ / KAPAT","OPEN / CLOSE",free))
			"phone": list.append(action("phone","Telefonu aç","Answer phone",game.j_G.phone.state == "ring"))
			"uncle": list.append(action("uncle","Kuryeye ver / yardım","Courier / help"))
			"trash": list.append(action("trash","Eldekini at" if hand else "Çöpü boşalt","Discard held item" if hand else "Empty trash"))
			"cat": list.append(action("cat","Kediyi besle","Feed cat",free and game.j_G.meat > 0))
	if selected.begins_with("refill:"):
		var key: String = selected.trim_prefix("refill:")
		list.append(action(selected,"DOLDUR","REFILL",free and game.j_G.crate.open and game.j_G.stock[key] < game.stock_system.f_crateMax(key)))
	if hand: list.append(action("return","Eldekini geri bırak","Return held item"))
	return list

# The primary action is tied to the object, never to a text menu.
func primary() -> Dictionary:
	var options := actions()
	var group: String = target().get("group", "")
	var w: Variant = board()
	if group == "board" and w is Dictionary:
		var wanted := "take"
		if w.kind == "pide": wanted = "pide_chop"
		elif w.state == "open" and w.kind == "wrap": wanted = "roll"
		elif w.state == "rolled": wanted = "grill_put" if game.recipe_system.f_wrapNeedsGrill(w) and not game.grill_system.f_grillTikali() else "paper"
		for a in options:
			if a.id == wanted: return a
		return {}
	if selected == "cut":
		var wanted := "chop" if game.j_G.cut.potato else ("fry" if game.j_G.cut.raw > 0 else "potato")
		for a in options:
			if a.id == wanted: return a
	if group == "drink":
		return options[0] if game.j_G.cups.get(selected.trim_prefix("drink:")) == null else options[1]
	for a in options:
		if a.id != "return": return a
	return {}

func accept(down: bool, source := "accept") -> void:
	if not down: release(source); return
	var a := primary()
	if not a.is_empty(): press(a.id,source)
	else: action_feedback(selected)

func action_feedback(id: String) -> void:
	if not available(): return
	if id in ["bread","pide"] and game.wrap_system.f_emptyBoard() < 0:
		game.J.method(game.j_SFX,"bad",[])
		game.session_system.f_say("Tezgâh dolu!")
		return
	if id == "friesT": id = "fries"
	if id not in ["meat","pickle","yogurt","fries"]: return
	if game.J.truth(game.j_G.hand) or game.J.truth(game.j_G.drag): return
	var message: String = game.assembly_system.ingredient_problem(id,board())
	if message != "":
		game.J.method(game.j_SFX,"bad",[])
		game.session_system.f_say(message)

func secondary() -> void:
	if game.J.truth(game.j_G.hand): return_hand()
	elif target().get("group", "") == "board": press("take","secondary")

func prompt() -> String:
	var a := primary()
	if a.is_empty(): return ""
	if a.id == "order": return text("SEÇ", "SELECT")
	var labels := {"bread":"AL","pide":"AL","meat":"EKLE","pickle":"EKLE","yogurt":"EKLE","fries":"EKLE","tomato":"EKLE","pepper":"EKLE","hot":"SOS","garlic":"SOS","butter":"EKLE","roll":"SAR","paper":"KAĞITLA","take":"AL","put":"BIRAK","serve":"VER","collect":"TOPLA","pour":"DOLDUR","drink_take":"AL","grill_put":"IZGARA","grill_take":"AL","grill_open":"SEÇ","potato":"AL","chop":"DOĞRA","fry":"AL" if game.j_G.fryer.state == "done" else "KIZART","crate":"KAPAT" if game.j_G.crate.open else "AÇ","trash":"AT","cat":"BESLE","pide_chop":"DOĞRA","phone":"AÇ","uncle":"VER","sweet":"AL","fbox":"AL" if game.j_G.fbox.ready > 0 else "DOLDUR"}
	if game.j_LANG != "tr":
		labels = {"roll":"ROLL","paper":"PAPER","take":"TAKE","put":"PUT","serve":"SERVE","collect":"TAKE","chop":"CHOP","crate":"STOCK","grill_put":"GRILL","grill_take":"TAKE","pour":"FILL","drink_take":"TAKE"}
	return labels.get(a.id,"DOLDUR" if a.id.begins_with("refill:") else "EKLE") if game.j_LANG == "tr" else labels.get(a.id,"USE")

func press(id: String, source := "world") -> void:
	if not available() or not holding.is_empty() or game.controls.quick_cut_active: return
	refresh()
	var chosen: Dictionary = {}
	for a in actions():
		if a.id == id and a.enabled: chosen = a; break
	if chosen.is_empty(): action_feedback(id); return
	var t := target()
	if chosen.hold:
		holding = {"id":id,"source":source,"target":selected,"time":0.0,"board":board(),"index":t.index if t.group == "board" else int(game.j_G.act)}
		if id == "cut_meat": game.controls.set_quick_cut(true)
		elif id == "chop": game.potato_system.f_cutClick()
		return
	execute(id,t)
	if id in ["meat","pickle","yogurt","fries"] and board() is Dictionary:
		holding = {"id":id,"source":source,"target":selected,"time":0.0,"board":board(),"index":int(game.j_G.act),"repeat":true,"next":0.24}

const MALZEMELER := ["meat","pickle","yogurt","fries","tomato","pepper","hot","garlic","butter"]

func execute(id: String, t: Dictionary) -> void:
	if t.group != "board" and id in MALZEMELER: game.wrap_system.f_malzemeYonlendir(id)
	var idx: int = t.index if t.group == "board" or (t.group == "grill" and t.object is Dictionary) else int(game.j_G.act)
	if t.group == "board": game.j_G.act = idx
	recipe_board = idx if t.group in ["board","ingredient","paper"] else -1
	match id:
		"bread": game.f_newWrap(idx if t.group == "board" or game.j_G.boards[idx] == null else null)
		"pide": game.recipe_system.f_newPide(false,idx if t.group == "board" or game.j_G.boards[idx] == null else null)
		"meat": game.assembly_system.f_addMeat()
		"pickle","yogurt","fries": game.assembly_system.f_addIng(id)
		"tomato","pepper": game.assembly_system.f_garnishClick(game.j_ST.garnish.x+game.j_ST.garnish.w*(0.25 if id == "tomato" else 0.75))
		"hot","garlic","butter": game.assembly_system.f_sauceClick(game.j_ST.sauce.x+game.j_ST.sauce.w*({"hot":0.5,"garlic":1.5,"butter":2.5}[id])/3)
		"pide_chop": game.assembly_system.f_pideChop(idx)
		"paper": game.paper_system.f_startPaper(idx)
		"grill_put": game.grill_system.f_grillPut(idx)
		"grill_take": game.grill_system.f_grillTakeOut(idx)
		"grill_open": cycle(1)
		"take":
			game.j_G.hand = game.j_G.boards[idx]
			game.j_G.boards[idx] = null
			game.J.method(game.j_SFX,"pick",[])
		"put":
			game.j_G.boards[idx] = game.j_G.hand
			game.j_G.hand = null
		"serve": game.f_deliver(t.object)
		"order": game.order_select(t.object)
		"collect":
			for i in game.j_G.coins.size():
				if is_same(game.j_G.coins[i],t.object): game.payment_system.f_collectCoin(i,false); break
		"pour": game.drink_system.f_pourStart(t.id.trim_prefix("drink:"))
		"drink_take": game.drink_system.f_takeCup(t.id.trim_prefix("drink:"))
		"potato": game.potato_system.f_potatoTake()
		"fry": game.potato_system.f_fryerClick()
		"fbox":
			if game.j_G.fbox.ready > 0: game.fries_box_system.f_fboxClick()
			else: game.fries_box_system.f_fboxDoldur(false)
		"sweet": game.equipment_system.f_sweetClick()
		"phone": game.f_phoneClick()
		"uncle":
			if not game.helper_system.f_motoClick() and not game.f_giveToCourier(): game.helper_system.f_uncleUse()
		"crate": game.j_G.crate.open = not game.j_G.crate.open
		"trash": game.event_system.f_trashClick()
		"cat": game.event_system.f_kediBesle()
		"return": return_hand()
		_:
			if id.begins_with("refill:"):
				var items: Array = game.stock_system.f_crateItems()
				game.j_G.crate.open = true
				for i in items.size():
					if items[i][0] == id.trim_prefix("refill:"):
						var r: Array = game.stock_system.f_crateSlotRect(i)
						game.stock_system.f_crateClick(r[0]+r[2]/2,r[1]+r[3]/2)
						break
	recipe_board = -1

func return_hand() -> void:
	if game.J.truth(game.j_G.hand) and game.drag_system.f_returnItem(game.j_G.hand): game.j_G.hand = null

func release(source: String) -> void:
	if holding.get("source", "") == source: cancel()

func cancel() -> void:
	if holding.is_empty(): return
	# Detach first: cleanup may call input code, and an incomplete hold still
	# needs to be cancelable without reading missing dictionary keys.
	var previous := holding
	holding = {}
	match previous.get("id", ""):
		"cut_meat":
			if game.controls != null: game.controls.set_quick_cut(false)
		"roll":
			var wrap: Variant = previous.get("board")
			if wrap is Dictionary and wrap.get("state") == "open": wrap.roll = 0.0
		"chop":
			game.j_G.cut.hold = 0.0
			game.j_G.cut.cutting = false

func back() -> bool:
	if not holding.is_empty(): cancel(); return true
	if game.J.truth(game.j_G.hand): return_hand(); return true
	return false

func tick(delta: float) -> void:
	hint_time = maxf(0,hint_time-delta)
	if holding.is_empty(): return
	if not holding.has_all(["id", "source", "target", "time", "board", "index"]) or (holding.get("repeat", false) and not holding.has("next")):
		cancel()
		return
	if not available() or selected != holding.target or game.J.truth(game.j_G.hand): cancel(); return
	if holding.id == "chop":
		if not game.j_G.cut.potato: cancel()
		return
	if holding.id == "cut_meat":
		if not game.controls.quick_cut_active or game.j_G.meat >= tun("meatCap"): cancel()
		return
	var idx: int = holding.index
	if idx < 0 or idx >= int(tun("boards")) or not is_same(game.j_G.boards[idx],holding.board): cancel(); return
	var w: Dictionary = holding.board
	if holding.get("repeat", false):
		if int(game.j_G.act) != idx or w.state != "open": cancel(); return
		holding.time += delta
		if holding.time < holding.next: return
		# basili tutmak "bu urunu doldur" demek: urun dolunca durur (fazlasi
		# baska urune tasmaz; tek tik ise ihtiyaci olan urune yonlenir)
		if not game.wrap_system.f_malzemeIhtiyac(w, holding.id): cancel(); return
		var allowed := false
		for a in actions():
			if a.id == holding.id and a.enabled: allowed = true; break
		if not allowed: cancel(); return
		holding.next = holding.time + 0.14
		execute(holding.id, target())
		return
	if (holding.id == "roll" and w.state != "open") or (holding.id == "paper" and not can_paper(w)): cancel(); return
	holding.time += delta
	var duration: float = 0.28 if holding.id == "roll" else float(tun("paperTime"))
	if holding.id == "roll": w.roll = clampf(holding.time/duration,0,1)
	if holding.time >= duration:
		var kind: String = holding.id
		holding.clear()
		if kind == "roll": game.f_finishRoll(idx)
		else: game.wrap_system.f_applyPaper(idx)

func status() -> String:
	var t := target()
	var w: Variant = board()
	if w is Dictionary:
		if w.kind == "pide": return text("Doğranan: ","Chopped: ")+str(int(w.n))+" / "+str(int(game.j_PIDE_NEED))
		if w.state == "open":
			if w.kind == "wrap": return text("Et %d/4 · Turşu %d/4\nYoğurt %d/4 · Patates %d/4","Meat %d/4 · Pickle %d/4\nYogurt %d/4 · Fries %d/4") % [w.meat,w.pickleN,w.yogurtN,w.friesN]
			return text("Et %d/%d · Yoğurt %d/%d","Meat %d/%d · Yogurt %d/%d") % [w.meat,tun("iskMeat"),w.yogurtN,game.j_PLATE_YOGURT]
		return text("Yanmış · çöpe at","Burnt · discard") if w.get("burnt",false) else text("Sarılmış" if w.state == "rolled" else "Servise hazır","Rolled" if w.state == "rolled" else "Ready to serve")
	if selected == "spit": return text("Tepside %d / %d dilim","Tray: %d / %d slices") % [game.j_G.meat,tun("meatCap")]
	if selected == "cut": return text("Doğrama %d%% · Çiğ patates %d","Chopping %d%% · Raw fries %d") % [game.j_G.cut.prog*100,game.j_G.cut.raw]
	if selected == "fryer": return text("Kızarıyor… %d%%","Frying… %d%%") % [game.j_G.fryer.prog*100] if game.j_G.fryer.state == "fry" else text("Pişmiş patates: ","Cooked fries: ")+str(int(game.j_G.friesTray))
	if t.get("group","") == "customer":
		var order: Array[String] = []
		for i in t.object.items.size():
			if not t.object.done[i]: order.append(order_label(t.object.items[i]))
		return text("Sipariş: ","Order: ")+", ".join(order)
	if game.J.truth(game.j_G.hand): return text("Elde ürün var · müşteri seç","Holding an item · choose a customer")
	return text("İşlemi seç; basılı tut yazıyorsa tut.","Choose an action; hold when indicated.")

func order_label(item: Dictionary) -> String:
	var names := {"wrap":text("Dürüm","Wrap"),"plate":text("İskender","Iskender"),"fbox":text("Patates kutusu","Fries box"),"sweet":text("Tatlı","Dessert"),"pickle":text("turşu","pickles"),"yogurt":text("yoğurt","yogurt"),"fries":text("patates","fries")}
	var label: String = str(item.get("type","")) if item.kind == "drink" else names.get(item.kind,item.kind)
	if item.get("sauce","") == "hot": label += text(" · acı sos"," · hot sauce")
	if item.get("sauce","") == "garlic": label += text(" · sarımsaklı"," · garlic sauce")
	for ingredient in item.get("yok",[]): label += text(" · "," · no ")+names.get(ingredient,ingredient)+text(" olmasın","")
	return label
