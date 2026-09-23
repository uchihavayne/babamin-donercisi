extends SceneTree
var shell: Control
var failures: Array[String]=[]
var checks:=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures.append(label); push_error(label)
func step(n:=3) -> void:
	for i in n: shell.game.advance(1.0/60); await process_frame
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/counter-design/"+name+".png")
func rect(key: String) -> Rect2:
	var s: Dictionary=shell.game.j_ST[key]
	return Rect2(s.x,s.y,s.w,s.h)
func run() -> void:
	root.size=Vector2i(1440,810)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size=Vector2i(960,540)
	shell=load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	var g: Node=shell.game
	g.j_MUTED=true; g.localization.f_setLang("tr")
	g.j_G.up={}; g.f_startDay(); g.j_G.tut=99; g.j_G.shutT=0; g.j_G.spawnT=1000
	g.j_G.meat=12; g.j_G.friesTray=12; g.j_G.stock.pickle=12; g.j_G.stock.yogurt=12
	g.j_G.stockAnim.pickle=12; g.j_G.stockAnim.yogurt=12
	g.f_newWrap(); g.j_G.boards[0].meat=4; g.j_G.boards[0].pickleN=4; g.j_G.boards[0].yogurtN=4; g.j_G.boards[0].friesN=4
	g.j_G.hintT=0
	g.customer_system.f_spawnCustomer(); var c: Dictionary=g.j_G.customers[0]
	c.state="wait"; c.x=c.tx; c.items=[{"kind":"wrap"}]; c.done=[false]
	g.controls.set_mode("touch")
	await step(10); await snap("early-counter")
	check(g.j_ST.board.w>=150,"preparation board is expanded and centered")
	check(g.j_ST.meat.w==g.j_ST.pickle.w and g.j_ST.meat.w==g.j_ST.yogurt.w and g.j_ST.meat.w==g.j_ST.friesT.w,"four ingredient trays share a consistent size")
	for st in g.j_ST.values():
		check(Rect2(0,0,480,270).encloses(Rect2(st.x,st.y,st.w,st.h)),"station stays inside game: "+str(st))
	for key in ["bread","meat","pickle","yogurt","friesT","sauce","paper","fryer","cut","grill","fbox","sweet","crate","potato","trash"]:
		check(not rect("board").intersects(rect(key)),"preparation board does not overlap "+key)
	check(g.counter_base != null,"editable counter PNG is loaded at runtime")
	check(not rect("spit").intersects(rect("uncle")),"spit and courier have distinct interaction areas")
	g.j_G.up={"grill":1.0,"drink":1.0,"ayran":1.0,"sauce":1.0,"fbox":1.0,"sweet":1.0}
	g.j_G.stock.ayran=8; g.j_G.stockAnim.ayran=8; g.j_G.stock.sweet=8; g.j_G.stockAnim.sweet=8
	await step(10); await snap("equipped-counter")
	g.j_G.cut.potato=false; g.j_G.cut.raw=3
	await step(2); await snap("cut-potatoes")
	g.j_G.fryer.state="fry"; g.j_G.fryer.dur=20; g.j_G.fryer.t=0; g.j_G.fryer.load=6
	await step(2); await snap("frying-potatoes")
	g.j_G.cut.raw=0; g.j_G.fryer.state="idle"; g.j_G.fryer.load=0
	root.size=Vector2i(1170,540); shell.mobile=true
	await step(5); shell.update_layout(); await step(3); await snap("phone-counter")
	g.j_G.up.board=2.0; g.j_G.up.iskender=1.0; g.j_G.up.garnish=1.0
	g.f_newWrap(1); g.recipe_system.f_newPide(false,2)
	g.j_G.boards[1].meat=4
	g.j_G.stock.tomato=10; g.j_G.stockAnim.tomato=10; g.j_G.stock.pepper=10; g.j_G.stockAnim.pepper=10
	g.j_G.hintT=0; await step(5); await snap("three-boards")
	g.stations.select("crate"); g.stations.accept(true); g.stations.accept(false)
	await step(25); await snap("stock-drawer")
	g.j_G.crate.open=false
	for upgrade in g.j_UPG: g.j_G.up[upgrade.id]=float(upgrade.lv.size())
	g.j_G.fryer.state="fry"; g.j_G.fryer.dur=20; g.j_G.fryer.t=0; g.j_G.fryer.load=6
	g.j_G.cut.raw=3
	for type in g.drink_system.f_icecekMusluklari(): g.drink_system.f_pourStart(type)
	g.j_G.hintT=0; await step(30); await snap("all-equipment")
	# Every visible ingredient/cup must select its own action at its center.
	g.stations.refresh()
	var targets: Array=g.stations.targets.duplicate()
	for target in targets:
		if target.id in ["hot","garlic","butter","tomato","pepper","drink:fanta","drink:cola","drink:ayran","bread","pide","board:0","board:1","board:2","cut","fryer","potato","crate"]:
			g.stations.select_at(target.rect.get_center())
			check(g.stations.selected==target.id,"world target resolves without an overlapping neighbor: "+target.id)
	g.stations.hint_time=0
	for theme in range(1,4):
		g.j_G.custom.counter=float(theme); g.j_CLAYER=null; await step(2)
		# HD'de tezgah dogrudan Blender parcalarindan (tema rengi modulate), onbellek katmani yok
		check(g.j_CLAYER != null or g.t2_hd(),"custom counter theme renders: "+str(theme))
	await snap("custom-counter")
	g.j_G.custom.counter=0; g.j_CLAYER=null
	g.controls.pause(); await step(2); await snap("pause")
	g.j_G.scene="title"; await step(2); await snap("upgraded-title")
	var report:={"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name()}
	var out:=FileAccess.open("res://validation/counter-design/visual-results.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(report,"\t")); out.close()
	print("COUNTER DESIGN ",JSON.stringify(report))
	shell.free(); await process_frame; quit(0 if failures.is_empty() else 1)
