extends SceneTree
var shell: Control
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)
func step(n := 3) -> void:
	for i in n: shell.game.advance(1.0/60); await process_frame
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/order-flow/"+name+".png")
func run() -> void:
	root.size=Vector2i(1440,810)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size=Vector2i(960,540)
	shell=load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	var g: Node=shell.game
	g.j_MUTED=true; g.localization.f_setLang("tr")
	g.j_G.up={"secim":2.0,"uncle":1.0,"phone":1.0,"sauce":1.0,"ayran":1.0,"drink":1.0,"fbox":1.0,"expand":3.0}
	g.f_startDay(); g.j_G.tut=99; g.j_G.shutT=0; g.j_G.spawnT=10000; g.j_G.timeLeft=80
	g.j_G.meat=20; g.j_G.friesTray=20; g.j_G.stock.pickle=20; g.j_G.stock.yogurt=20
	var orders: Array = [
		[{"kind":"wrap","yok":["pickle"]},{"kind":"drink","type":"ayran"}],
		[{"kind":"wrap","yok":["yogurt"],"sauce":"hot"}],
		[{"kind":"wrap","yok":["fries"]},{"kind":"fbox"}],
		[{"kind":"wrap","yok":["pickle","fries"],"sauce":"garlic"},{"kind":"drink","type":"cola"}],
		[{"kind":"wrap"},{"kind":"drink","type":"fanta"},{"kind":"sweet"}]]
	for i in orders.size():
		g.customer_system.f_spawnCustomer()
		var c: Dictionary=g.j_G.customers.back()
		c.state="wait"; c.slot=i; c.x=142+i*65; c.tx=c.x; c.y=152; c.items=orders[i]; c.done=[]; c.bubble=1; c.lineT=0; c.patience=0.8 if i!=3 else 0.2
		for item in c.items: c.done.append(false)
	check(g.j_G.customers.size()==5,"all five simultaneous customer cards are rendered")
	for i in g.j_G.customers.size():
		var r: Rect2=g.order_bubble_rect(g.j_G.customers[i])
		check(r.position.y>=29 and r.end.y<=96,"customer order stays between the HUD and head")
		for j in range(i+1,g.j_G.customers.size()): check(not r.intersects(g.order_bubble_rect(g.j_G.customers[j])),"adjacent order cards do not overlap")
	g.order_select(g.j_G.customers[0]); g.f_newWrap(); g.j_G.boards[0].meat=4; g.j_G.boards[0].yogurtN=2; g.j_G.boards[0].friesN=4
	g.controls.set_mode("touch"); g.j_G.hintT=0
	await step(5); await snap("orders-desktop")
	check(Rect2(95,51,27,26).end.x < g.j_LAY.win.x,"wall decoration stays outside the window")
	check(g.j_ST.uncle.x+g.j_ST.uncle.w<=g.j_ST.spit.x,"chef bay and spit have separate targets")
	g.j_G.phone.state="order"; g.j_G.phone.order=[orders[0][0],orders[3][0],{"kind":"drink","type":"ayran"},{"kind":"fbox"},{"kind":"sweet"}]; g.j_G.phone.done=[false,false,false,true,false]
	await step(3); await snap("courier-receipt")
	g.stations.select("phone"); await step(3); await snap("courier-details")
	var phone_order: Array = g.j_G.phone.order
	g.j_G.phone.order=[{"kind":"plate"},orders[3][0],{"kind":"drink","type":"ayran"},{"kind":"fbox"},{"kind":"sweet"}]
	await step(3); await snap("courier-plate")
	g.j_G.phone.order=phone_order
	g.stations.select("board:0")
	root.size=Vector2i(1170,540); shell.mobile=true; await step(5); shell.update_layout(); await step(3); await snap("orders-phone")
	g.j_G.boards[0].yogurtN=4; g.f_finishRoll(0); g.wrap_system.f_applyPaper(0); g.j_G.hintT=0
	await step(3); await snap("ready-to-serve")
	g.j_G.hand=g.j_G.boards[0]; g.j_G.boards[0]=null; g.f_deliver(g.j_G.customers[0]); g.j_G.hintT=0
	await step(3); await snap("combo-progress")
	check(g.j_G.customers[0].done==[true,false],"completed wrap is checked while the drink remains visible")
	var report:={"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name()}
	var out:=FileAccess.open("res://validation/order-flow/visual-results.json",FileAccess.WRITE); out.store_string(JSON.stringify(report,"\t")); out.close()
	print("ORDER VISUAL ",JSON.stringify(report)); shell.free(); await process_frame; quit(0 if failures.is_empty() else 1)
