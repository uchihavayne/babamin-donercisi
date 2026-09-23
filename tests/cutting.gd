extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error(message)
func trigger(value: float) -> void:
	var e := InputEventJoypadMotion.new()
	e.device = 0; e.axis = JOY_AXIS_TRIGGER_RIGHT; e.axis_value = value
	game._input(e)
func button(value: bool) -> void:
	var e := InputEventJoypadButton.new()
	e.device = 0; e.button_index = JOY_BUTTON_A; e.pressed = value
	game._input(e)
func finger(value: bool, point := Vector2(-1,-1), index := 0, canceled := false) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index; e.position = Vector2(game.j_LAY.spit.cx,110) if point.x<0 else point; e.pressed = value; e.canceled = canceled
	game._input(e)
func mouse(point: Vector2) -> void:
	var e := InputEventMouseMotion.new(); e.position=point; game._input(e)
func step(count := 1, fps := 60) -> void:
	for i in count:
		game.controls.tick(1.0 / fps)
		if game.j_G.scene == "play" and not game.suspended: game.f_updateShave(1.0 / fps)
		game.effects.f_inEnd()
func fresh(level := 0) -> void:
	trigger(0)
	game.controls.release_all()
	game.j_G.up = {"knife": float(level)}
	game.f_startDay()
	game.j_G.tut = 99
	game.j_G.shutT = 0.0
	game.j_G.meat = 0.0
	game.controls.set_mode("mouse")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/cutting/test-save.json"
	game.storage.values = {}
	root.add_child(game)
	game.set_process(false)
	game.j_MUTED = true
	fresh()
	game.pointer(Vector2(348,220))
	trigger(0.4); step(30)
	check(game.j_G.meat == 0 and not game.controls.quick_cut_active, "trigger deadzone prevents accidental cutting")
	trigger(1); step()
	check(game.controls.quick_cut_active and game.f_hitST("spit"), "R2 targets spit directly from another station")
	check(game.j_G.meat == 3, "first cut responds on next game frame")
	check(not game.j_IN.down, "shortcut never synthesizes a mouse click or drag")
	button(true); step(); button(false)
	check(not game.j_IN.down, "accept cannot click through a held shortcut")
	step(60)
	check(game.j_G.meat >= 6 and game.j_G.meat <= 9, "hold keeps the original base knife cadence with larger cuts")
	trigger(0)
	check(Vector2(game.j_IN.x,game.j_IN.y) == Vector2(348,220), "release returns to previous station")
	var before: float = game.j_G.meat
	step(120)
	check(game.j_G.meat == before, "released shortcut cannot leave a phantom cut")
	var counts: Array[float] = []
	for fps in [30,60,120]:
		fresh(); trigger(1); step(fps*2,fps); trigger(0)
		counts.append(game.j_G.meat)
		check(game.j_G.meat == 12, "base knife rate at " + str(fps) + " FPS")
	check(counts.max() - counts.min() <= 1, "hold rate does not depend on frame rate")
	fresh(3); trigger(1); step(120); trigger(0)
	check(game.j_G.meat == 16, "upgraded knife still fills the tray faster")
	fresh(); trigger(1); step(1200)
	check(game.j_G.meat == game.J.method(game.j_TUN,"meatCap",[]), "full tray never overflows")
	check(game.cut_marks.is_empty(), "full tray cannot produce fake success effects")
	trigger(0)
	fresh(); game.controls.set_mode("controller"); game.pointer(Vector2(game.j_LAY.spit.cx,110))
	button(true); step()
	check(game.j_G.meat == 3 and game.cut_hold_active, "hold accept over spit also cuts")
	button(false); step(60)
	check(game.j_G.meat == 3, "accept release stops cutting")
	fresh(); finger(true); step()
	check(game.j_G.meat == 3 and game.cut_hold_active, "touch hold starts cutting immediately")
	check(game.cut_marks.size() == 1 and game.j_G.flyMeat[0].sz >= 0.95, "real cut creates readable slash and larger meat strip")
	finger(true, Vector2(430,230), 1); finger(false,Vector2(430,230),1)
	step(40)
	check(game.j_G.meat == 6 and game.j_IN.down, "second finger cannot stop held cutting")
	finger(false); step()
	before = game.j_G.meat
	step(60)
	check(game.j_G.meat == before and game.cut_marks.is_empty(), "touch release stops and visual feedback expires")
	for i in 20:
		game.pointer(Vector2(game.j_LAY.spit.cx,70 if i%2 else 145)); step()
	check(game.j_G.meat == before, "touch hover cannot cut without a finger held down")
	fresh(); finger(true); finger(false); step(2)
	check(game.j_G.meat == 3 and not game.j_IN.down, "quick tap yields one three-strip cut")
	fresh(); finger(true); step(); finger(false,Vector2(game.j_LAY.spit.cx,110),0,true); step(90)
	check(game.j_G.meat == 3, "canceled touch cannot leave cutting active")
	fresh(); game.j_G.hand = {"kind":"wrap", "state":"ready"}; trigger(1); step(60)
	check(game.j_G.meat == 0 and game.j_G.hand != null, "shortcut cannot interrupt held food")
	fresh(); game.j_G.crate.open = true; trigger(1); step(60)
	check(game.j_G.meat == 0 and not game.controls.quick_cut_active, "crate panel blocks shortcut")
	fresh(); game.overlay_open = true; trigger(1); step(60)
	check(game.j_G.meat == 0, "native modal blocks shortcut")
	game.overlay_open = false
	fresh(); trigger(1); step(); game.controls.pause(); step(60)
	check(game.j_G.scene == "pause" and game.j_G.meat == 3, "pause stops hold")
	game.controls.pause(); trigger(0.9); step(60)
	check(game.j_G.meat == 3, "held trigger must be released after pause")
	trigger(0); trigger(1); step()
	check(game.j_G.meat == 6, "fresh trigger press works after pause")
	game.controls.disconnected(0); step(60)
	check(not game.controls.quick_cut_active and game.j_G.scene == "pause", "controller unplug stops cut immediately")
	fresh(); game.controls.set_mode("mouse"); mouse(Vector2(game.j_LAY.spit.cx,75)); step()
	for y in [150,75,150]: mouse(Vector2(game.j_LAY.spit.cx,y)); step()
	check(game.j_G.meat == 3, "original mouse swiping still cuts")
	step(60)
	check(game.j_G.meat == 3, "stationary mouse never gets automatic hold cutting")
	fresh()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_R; key.keycode = KEY_R; key.pressed = true
	game._input(key); step()
	check(game.j_G.meat == 3, "R provides keyboard quick cut")
	key.pressed = false; game._input(key); step(60)
	check(game.j_G.meat == 3, "keyboard release stops cut")
	# Stock, visible strips and the badge must agree, including a nearly full tray.
	for stock in [0,13,14,15,16]:
		fresh(); game.j_G.meat = stock
		game.pointer(Vector2(game.j_LAY.spit.cx,110))
		game.f_doSlice()
		var gained := mini(3,16-stock)
		check(game.j_G.meat == stock+gained,"cut yield is capped at remaining tray space: "+str(stock))
		check(game.j_G.flyMeat.size() == gained,"only gained meat gets a flying strip: "+str(stock))
		if gained > 0:
			check(game.cut_marks.size() == 1 and game.cut_marks[0].amount == gained,"one stroke shows its actual gain: "+str(stock))
		else:
			check(game.cut_marks.is_empty(),"full tray produces no gain badge")
	fresh()
	for cut in 6:
		game.f_doSlice()
		check(game.j_G.meat == mini((cut+1)*3,16),"tray fills in six substantial cuts: "+str(cut+1))
	game.cutting_system.f_updateFlyMeat(2.0)
	check(game.j_G.meat == 16 and game.j_G.flyMeat.is_empty(),"landing the bundle cannot add stock a second time")
	fresh(4); step(10)
	check(game.j_G.meat == 3,"automatic cutter uses the same yield at its existing interval")
	var fill_times: Dictionary = {}
	for fps in [30,60,120]:
		fresh(); trigger(1)
		var frames := 0
		while game.j_G.meat < 16 and frames < fps*4:
			step(1,fps); frames += 1
		trigger(0)
		var seconds: float = float(frames)/fps
		fill_times[str(fps)] = seconds
		check(game.j_G.meat == 16 and seconds >= 2.5 and seconds <= 3.2,"base knife fills a tray in about three seconds at "+str(fps)+" FPS")
	var report := {"checks":checks,"failures":failures,"two_second_base_knife_counts":counts,"full_tray_seconds":fill_times,"input":"synthetic controller/touch/keyboard on macOS"}
	var file := FileAccess.open("res://validation/cutting/results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("CUTTING ",JSON.stringify(report))
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
