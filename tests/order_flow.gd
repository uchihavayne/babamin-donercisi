extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)
func step(count := 1) -> void:
	for i in count:
		game.stations.refresh(); game.stations.tick(1.0/60); game.controls.tick(1.0/60)
		if game.j_G.scene == "play": game.game_loop.f_updatePlay(1.0/60)
		game.effects.f_inEnd()
func fresh(up := {}) -> void:
	game.controls.release_all(); game.j_G.up = up; game.f_startDay()
	game.j_G.shutT=0; game.j_G.tut=99; game.j_G.spawnT=10000; game.j_G.timeLeft=10000
	game.j_G.meat=40; game.j_G.friesTray=40; game.j_G.stock.pickle=40; game.j_G.stock.yogurt=40
	game.controls.set_mode("controller")
func customer(items: Array) -> Dictionary:
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state="wait"; c.x=c.tx; c.items=items; c.done=[]; c.bubble=1.0
	for item in items: c.done.append(false)
	return c
func hold(target: String, frames := 42) -> void:
	game.stations.select(target); game.stations.accept(true,"test"); step(frames); game.stations.accept(false,"test")
func mouse(position: Vector2, down: bool) -> void:
	var e := InputEventMouseButton.new(); e.position=position; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down
	game._input(e); step()
func touch(position: Vector2, down: bool) -> void:
	var e := InputEventScreenTouch.new(); e.position=position; e.index=0; e.pressed=down
	game._input(e); step()
func center(key: String) -> Vector2:
	var r: Dictionary=game.j_ST[key]; return Vector2(r.x+r.w/2,r.y+r.h/2)
func ready(yok: Array = [], sauce: Variant = null) -> Dictionary:
	return {"kind":"wrap","meat":4,"pickleN":0 if "pickle" in yok else 4,"yogurtN":0 if "yogurt" in yok else 4,"friesN":0 if "fries" in yok else 4,"sauce":sauce,"state":"ready","paper":true,"grilled":true,"burnt":false,"quality":1.0}
func run() -> void:
	game=load("res://scripts/platform_game.gd").new()
	game.storage.path="res://artifacts/order-flow/test-save.json"; game.storage.values={}
	root.add_child(game); game.set_process(false); game.j_MUTED=true; game.localization.f_setLang("tr")
	fresh({"secim":2.0,"sauce":1.0})
	var c := customer([{"kind":"wrap","yok":["pickle"],"sauce":"hot"},{"kind":"drink","type":"ayran"}])
	game.stations.refresh(); game.stations.select("customer:"+game.stations.uid(c)); game.stations.accept(true); game.stations.accept(false)
	check(is_same(game.chosen_order,c),"empty-hand controller action selects the customer's recipe")
	game.f_newWrap()
	var w: Dictionary=game.j_G.boards[0]
	check(w._order_recipe.yok==["pickle"] and w._order_mark=="1","new bread carries the selected recipe and customer number")
	hold("meat"); hold("yogurt"); hold("friesT")
	check(w.meat==4 and w.yogurtN==4 and w.friesN==4 and w.pickleN==0,"holding adds complete portions without unwanted pickles")
	check(game.j_G.meat==36 and game.j_G.stock.yogurt==36 and game.j_G.friesTray==36,"hold consumes exactly the actual ingredient amounts")
	# Birlesik surum: siparis sirasi dayatilmaz (sossuz sarma engellenmez; asagidaki
	# ayri senaryo). Bu akista sos once eklenir.
	hold("hot",1); hold("board:0",20)
	check(w.state=="rolled" and w.quality==1,"correct custom recipe rolls at full quality")
	hold("board:0",55); hold("board:0",1)
	check(game.j_G.hand is Dictionary and game.j_G.hand.paper,"wrap is packaged and picked up for serving")
	game.f_deliver(c)
	check(c.done==[true,false] and game.j_G.hand==null and c.state=="wait","serving main dish preserves outstanding drink")
	game.j_G.hand={"kind":"drink","type":"ayran"}; game.f_deliver(c)
	check(c.done==[true,true] and game.j_G.hand==null,"correct drink completes the combo")
	# Siparis sirasi dayatilmaz: yeni durum ilk musteriye baglanir ama baska bir
	# musterinin siparisine uyarsa ona gecer ve sarilir; hicbirine uymazsa da sarilir.
	fresh({"secim":2.0,"sauce":1.0})
	var c1 := customer([{"kind":"wrap","sauce":"hot"}])
	var c2 := customer([{"kind":"wrap","sauce":"garlic"}])
	game.f_newWrap()
	var w2: Dictionary=game.j_G.boards[0]
	check(is_same(w2.get("_order_owner"),c1),"new bread still suggests the first waiting order")
	hold("meat"); hold("pickle"); hold("yogurt"); hold("friesT"); hold("garlic",1); hold("board:0",20)
	check(w2.state=="rolled" and is_same(w2.get("_order_owner"),c2),"a wrap matching another order is rebound and rolls without being blocked")
	fresh({"secim":2.0,"sauce":1.0})
	c1 = customer([{"kind":"wrap","sauce":"hot"}])
	game.f_newWrap()
	var w3: Dictionary=game.j_G.boards[0]
	hold("meat"); hold("pickle"); hold("yogurt"); hold("friesT"); hold("board:0",20)
	check(w3.state=="rolled" and not w3.has("_order_recipe"),"a wrap matching no order still rolls and becomes a free wrap")
	fresh({"secim":2.0})
	c=customer([{"kind":"wrap","yok":["pickle","fries"]}])
	w=ready(["fries"]); w.pickleN=1; game.j_G.hand=w
	game.f_deliver(c)
	check(not c.done[0] and is_same(game.j_G.hand,w) and game.j_G.stat.wraps==0,"even one forbidden pickle is rejected without consuming food or recording a sale")
	w.pickleN=0; w.yogurtN=3; game.f_deliver(c)
	check(not c.done[0] and game.j_G.hand!=null,"a partially filled required ingredient is rejected")
	w.yogurtN=4; w.sauce="hot"; game.f_deliver(c)
	check(not c.done[0],"unrequested sauce does not count as the plain recipe")
	w.sauce=null; game.f_deliver(c)
	check(c.done[0] and game.j_G.hand==null,"correct double omission is accepted")
	fresh({"secim":2.0})
	c=customer([{"kind":"wrap","yok":["pickle"]},{"kind":"wrap","yok":["yogurt"]}])
	game.j_G.hand=ready(["yogurt"]); game.f_deliver(c)
	check(c.done==[false,true],"matching is ingredient-specific when one customer orders two wraps")
	fresh({"phone":1.0,"secim":2.0})
	game.j_G.phone.state="order"; game.j_G.phone.order=[{"kind":"wrap","yok":["pickle"]},{"kind":"wrap","yok":["fries"]}]; game.j_G.phone.done=[false,false]
	w=ready(); game.j_G.hand=w; game.f_giveToCourier()
	check(game.j_G.phone.done==[false,false] and is_same(game.j_G.hand,w),"courier rejects unwanted ingredients without consuming the item")
	game.j_G.hand=ready(["fries"]); game.f_giveToCourier()
	check(game.j_G.phone.done==[false,true],"courier resolves the correct wrap among different preferences")
	fresh({"board":1.0})
	game.f_newWrap(0); game.f_newWrap(1); game.j_G.act=0
	game.stations.select("meat"); game.stations.accept(true,"test"); step(4); game.j_G.act=1; step(40); game.stations.accept(false,"test")
	check(game.j_G.boards[0].meat==1 and game.j_G.boards[1].meat==0,"changing active board cancels a hold rather than spilling onto another wrap")
	game.j_G.act=0; hold("meat",150)
	check(game.j_G.boards[0].meat==4 and game.j_G.boards[1].meat==0,"holding a full ingredient never spills onto a second board")
	fresh(); game.f_newWrap(); w=game.j_G.boards[0]
	mouse(center("pickle"),true); step(40); mouse(center("pickle"),false)
	check(w.pickleN==4 and game.j_G.stock.pickle==36,"mouse hold uses the same bounded portion repeat")
	mouse(center("yogurt"),true); mouse(center("yogurt"),false); step(50)
	check(w.yogurtN==1,"mouse tap adds one portion and releasing stops repeat")
	mouse(center("friesT"),true)
	var motion:=InputEventMouseMotion.new(); motion.position=Vector2(470,265); game._input(motion); step(50); mouse(motion.position,false)
	check(w.friesN==1,"moving out of a tray cancels mouse repeat")
	touch(center("meat"),true); step(40); touch(center("meat"),false)
	check(w.meat==4,"touch hold fills a portion through the same action")
	touch(center("yogurt"),true)
	var drag:=InputEventScreenDrag.new(); drag.index=0; drag.position=Vector2(470,265); game._input(drag); step(50); touch(drag.position,false)
	check(w.yogurtN==2,"dragging out of a touch target cancels repeating")
	fresh(); game.f_newWrap(); w=game.j_G.boards[0]
	game.stations.select("meat"); game.stations.accept(true,"test"); step(5); game.controls.pause(); step(40)
	check(w.meat==1 and game.stations.holding.is_empty(),"pause cancels ingredient repeats")
	fresh(); game.f_newWrap(); w=game.j_G.boards[0]; game.j_G.stock.pickle=2
	hold("pickle",100)
	check(w.pickleN==2 and game.j_G.stock.pickle==0,"repeat stops at stock exhaustion without fabricating portions")
	fresh({"secim":2.0,"paper":2.0,"sauce":1.0})
	c=customer([{"kind":"wrap","yok":["pickle"],"sauce":"hot"}]); game.order_select(c); game.f_newWrap(); w=game.j_G.boards[0]
	w.meat=4; w.yogurtN=4; w.friesN=4; game.equipment_system.f_checkAuto()
	check(w.state=="open" and not game.f_wrapFull(w),"machine preparation still requires the requested sauce")
	w.sauce="hot"; game.equipment_system.f_checkAuto()
	game.f_finishRoll(0)
	check(w.state=="rolled" and game.j_G.paper.busy>0,"automatic paper machine accepts the complete custom wrap after rolling")
	fresh({"secim":2.0,"board":1.0})
	c=customer([{"kind":"wrap","yok":["pickle"]}]); var other:=customer([{"kind":"wrap","yok":["fries"]}])
	game.f_newWrap(0); game.f_newWrap(1)
	check(is_same(game.j_G.boards[0]._order_owner,c) and is_same(game.j_G.boards[1]._order_owner,other),"two boards automatically reserve different waiting orders")
	game.j_G.act=0; mouse(game.order_bubble_rect(other).get_center(),true); mouse(game.order_bubble_rect(other).get_center(),false)
	check(game.j_G.boards[0]._order_recipe.yok==["fries"],"mouse can retarget the open wrap from the order bubble")
	c.state="leaving"; other.state="leaving"; game.j_G.boards=[null,null,null]; game.f_newWrap()
	check(not game.j_G.boards[0].has("_order_recipe"),"departed customers never bind a new wrap")
	var report:={"checks":checks,"failures":failures,"devices":"synthetic mouse, touch and controller on macOS"}
	var file:=FileAccess.open("res://validation/order-flow/results.json",FileAccess.WRITE); file.store_string(JSON.stringify(report,"\t")); file.close()
	print("ORDER FLOW ",JSON.stringify(report)); game.free(); quit(0 if failures.is_empty() else 1)
