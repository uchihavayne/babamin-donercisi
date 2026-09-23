extends SceneTree
var shell: Control
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)
func step(count := 8) -> void:
	for i in count:
		shell.game.advance(1.0/60)
		await process_frame
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/stations/"+name+".png")
func center(key: String) -> Vector2:
	var st: Dictionary=shell.game.j_ST[key]
	return Vector2(st.x+st.w/2,st.y+st.h/2)
func world(point: Vector2) -> Vector2:
	return shell.game_rect.position+point*shell.game_rect.size/Vector2(480,270)
func finger(point: Vector2, down: bool, index := 0, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.index=index; event.position=point*Vector2(root.size)/root.get_visible_rect().size; event.pressed=down; event.canceled=canceled
	Input.parse_input_event(event)
func touch(point: Vector2, frames := 2) -> void:
	finger(world(point),true); await step(frames); finger(world(point),false); await step(3)
func check_layout(name: String) -> void:
	check(shell.safe_rect.grow(1).encloses(shell.game_rect),name+" full game stays visible")
	check(is_equal_approx(shell.game_rect.size.aspect(),16.0/9.0),name+" art aspect is preserved")
	var available: Rect2 = shell.safe_rect.grow(-8*shell.ui_scale)
	var expected: Rect2 = shell.fit_game(available,false)
	check(shell.game_rect.size.distance_to(expected.size) < 1,name+" counter uses the whole available area without a dock or help bar")
func run() -> void:
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size=Vector2i(960,540)
	root.size=Vector2i(1440,810)
	shell=load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	shell.game.set_process(false); shell.game.j_MUTED=true
	shell.game.localization.f_setLang("tr"); shell.game.f_startDay()
	shell.game.j_G.tut=99; shell.game.j_G.shutT=0; shell.game.j_G.spawnT=1000
	shell.game.j_G.timeLeft=1000; shell.game.stations.enabled=true; shell.integer_scale=false
	await step()
	await touch(center("bread"))
	check(shell.game.j_G.boards[0] is Dictionary,"touching the actual bread creates a wrap")
	shell.game.j_G.meat=16; shell.game.j_G.friesTray=16
	shell.game.j_G.stock.pickle=16; shell.game.j_G.stock.yogurt=16
	for point in [center("meat"),center("pickle"),center("yogurt"),center("friesT")]:
		for i in 4: await touch(point)
	check(shell.game.f_wrapFull(shell.game.j_G.boards[0]),"actual ingredient trays build the full recipe with touch")
	check(shell.game.j_G.meat == 12 and shell.game.j_G.stock.pickle == 12,"touch and emulated mouse never double-add ingredients")
	shell.game.customer_system.f_spawnCustomer()
	var customer: Dictionary=shell.game.j_G.customers[0]
	customer.state="wait"; customer.x=customer.tx; customer.items=[{"kind":"wrap"}]; customer.done=[false]
	shell.game.controls.set_mode("controller"); shell.game.stations.select("board:0")
	await step(3); check_layout("desktop"); await snap("desktop-direct")
	for spec in [["phone",Vector2i(1170,540),true],["tablet",Vector2i(1024,768),true],["portrait",Vector2i(540,960),true],["tv",Vector2i(1920,1080),false]]:
		root.size=spec[1]; shell.mobile=spec[2]
		shell.game.controls.set_mode("touch" if spec[2] else "controller")
		await step(); shell.update_layout(); await step(3)
		check_layout(spec[0]); await snap(spec[0]+"-direct")
	root.size=Vector2i(1170,540); shell.mobile=true
	await step(); shell.update_layout(); await step(3)
	await touch(center("board"),5)
	check(shell.game.j_G.boards[0].state == "open","short hold on actual wrap cancels rolling")
	finger(world(center("board")),true); await step(4)
	finger(world(center("meat")),true,1); finger(world(center("meat")),false,1); await step(3)
	check(not shell.game.stations.holding.is_empty(),"second finger cannot steal an active preparation hold")
	var drag := InputEventScreenDrag.new()
	drag.index=0; drag.position=world(Vector2(310,220))*Vector2(root.size)/root.get_visible_rect().size
	Input.parse_input_event(drag); await step(25)
	finger(world(Vector2(310,220)),false); await step(2)
	check(shell.game.j_G.boards[0].state == "open" and shell.game.stations.holding.is_empty(),"moving away cancels a world hold without completing it")
	await touch(center("board"),22)
	check(shell.game.j_G.boards[0].state == "rolled","holding actual wrap rolls it without dragging")
	await touch(center("paper"),58)
	check(shell.game.j_G.boards[0].paper,"holding the actual paper station packages the active wrap")
	await snap("phone-ready-wrap")
	await touch(center("board"))
	check(shell.game.j_G.hand is Dictionary,"touching finished food picks it up")
	await snap("phone-held-food")
	await touch(Vector2(customer.x,customer.y-30))
	check(shell.game.j_G.stat.wraps == 1 and shell.game.j_G.hand == null,"touching the actual customer serves the validated recipe")
	shell.game.j_G.meat=0
	finger(world(center("spit")),true); await step(35)
	check(shell.game.j_G.meat > 0,"direct touch on spit still cuts meat")
	finger(Vector2(2,2),false,0,true); await step(3)
	var meat: float=shell.game.j_G.meat
	await step(40)
	check(shell.game.j_G.meat == meat and not shell.game.j_IN.down,"canceled touch outside game leaves no phantom cuts")
	shell.game.controls.set_mode("controller"); shell.game.stations.select("pickle")
	await step(3); await snap("controller-direct")
	check(shell.game.stations.prompt() == "","empty board does not offer a misleading ingredient action")
	shell.show_help(); await step(3)
	check(not shell.game.stations.available(),"help modal blocks cooking")
	shell.close_modal(); await step(3)
	var result := {"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name(),"host":"macOS; simulated screen sizes and native touch events"}
	var file:=FileAccess.open("res://validation/stations/visual-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t")); file.close()
	print("DIRECT VISUAL ",JSON.stringify(result))
	shell.free(); await process_frame; quit(0 if failures.is_empty() else 1)
