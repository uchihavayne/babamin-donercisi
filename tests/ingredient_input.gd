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
		game.game_loop.f_updatePlay(1.0/60)
		game.effects.f_inEnd()

func fresh(up := {}) -> void:
	game.controls.release_all(); game.j_G.up = up; game.f_startDay()
	game.j_G.shutT = 0; game.j_G.tut = 99; game.j_G.spawnT = 10000; game.j_G.timeLeft = 10000
	game.j_G.meat = 16; game.j_G.stock.pickle = 16; game.j_G.stock.yogurt = 16; game.j_G.friesTray = 16
	game.controls.set_mode("mouse")

func center(key: String) -> Vector2:
	var s: Dictionary = game.j_ST[key]
	return Vector2(s.x+s.w/2,s.y+s.h/2)

func mouse(point: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point; event.pressed = down; event.button_index = MOUSE_BUTTON_LEFT
	game._input(event)

func tap(key: String) -> void:
	mouse(center(key),true); mouse(center(key),false)

func queue_legacy_tap() -> void:
	mouse(Vector2(475,265),true); mouse(Vector2(475,265),false)

func motion(point: Vector2) -> void:
	var event := InputEventMouseMotion.new(); event.position = point
	game._input(event)

func touch(point: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new(); event.position = point; event.pressed = down; event.index = 0
	game._input(event)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/ingredient-input-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	fresh(); queue_legacy_tap()
	tap("bread"); tap("meat"); tap("pickle"); step(12)
	var w: Variant = game.j_G.boards[0]
	check(w is Dictionary and w.meat == 1 and w.pickleN == 1, "bread, meat and pickle clicks between two frames keep their order")
	check(game.j_G.meat == 15 and game.j_G.stock.pickle == 15, "rapid preparation consumes each portion exactly once")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]; w.meat = 1
	mouse(center("board"),true); step()
	mouse(center("board"),false); tap("pickle"); step(12)
	check(w.pickleN == 1 and game.j_G.drag == null, "board release followed immediately by pickle tap does not swallow the tap")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]
	for key in ["meat","pickle","yogurt","friesT"]:
		for i in 3: tap(key)
	step(30)
	check(w.meat == 3 and w.pickleN == 3 and w.yogurtN == 3 and w.friesN == 3, "bursts of three taps add three portions to each ingredient")
	for frames in [6,18,45]:
		fresh(); game.f_newWrap(); w = game.j_G.boards[0]
		game.j_G.kedi = {"faz":"bekle","t":0.0,"x":300.0,"miyav":0.0}
		mouse(center("meat"),true); step(frames); mouse(center("meat"),false); step(3)
		check(w.meat == 1 and game.j_G.meat == 15, "cat present: stationary meat click lasting %d frames still adds meat" % frames)
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]; game.j_G.stock.pickle = 0; game.j_G.hint = ""
	tap("pickle"); step(3)
	check(w.pickleN == 0 and game.j_G.hint.contains("bitti"), "empty pickle tray explains why the click could not add anything")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]; w.meat = 4; game.j_G.hint = ""
	tap("meat"); step(3)
	check(w.meat == 4 and game.j_G.meat == 16 and game.j_G.hint.contains("yeterli"), "full meat portion gives feedback without consuming stock")
	fresh(); game.j_G.hint = ""; tap("pickle"); step(3)
	check(game.j_G.boards[0] == null and game.j_G.hint.contains("lavaş"), "ingredient before bread gives a short explanation")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]; w.state = "rolled"; game.j_G.hint = ""
	tap("pickle"); step(3)
	check(w.pickleN == 0 and game.j_G.hint.contains("Sarılmış"), "rolled wrap explains why further ingredients cannot be added")
	step(120)
	check(game.j_G.hintT <= 0, "rejection message expires instead of becoming permanent UI")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]
	game.j_G.kedi = {"faz":"bekle","t":0.0,"x":300.0,"miyav":0.0}
	mouse(center("meat"),true); step(6)
	var cat_point := Vector2(300,game.event_system.f_kediY()-8)
	motion(cat_point); step(2); mouse(cat_point,false); step(3)
	check(game.j_G.kedi.faz == "yiyor" and game.j_G.meat == 15 and w.meat == 0, "real drag to the cat still feeds it exactly once without adding to bread")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]
	game.j_G.kedi = {"faz":"bekle","t":0.0,"x":300.0,"miyav":0.0}
	mouse(center("meat"),true); step(6); motion(Vector2(470,265)); step(2); mouse(Vector2(470,265),false); step(3)
	check(game.j_G.meat == 16 and w.meat == 0, "dragging meat to empty space cancels without consuming or adding it")
	fresh(); game.f_newWrap(); w = game.j_G.boards[0]; game.j_G.stock.pickle = 1
	for i in 3: tap("pickle")
	step(10)
	check(w.pickleN == 1 and game.j_G.stock.pickle == 0, "repeated taps at last stock cannot create extra ingredients")
	fresh({"board":1.0}); game.f_newWrap(0); game.f_newWrap(1); game.j_G.act = 0
	game.j_G.boards[0].pickleN = 4
	tap("pickle"); step(3)
	# BIRLESIK (kullanici karari): dolu bolmedeki fazladan tik, ihtiyaci olan urune gider
	check(game.j_G.boards[1].pickleN == 1 and game.j_G.boards[0].pickleN == 4 and game.j_G.act == 1, "full active portion sends an extra tap to the portion that needs it")
	fresh(); queue_legacy_tap(); tap("bread"); mouse(center("pickle"),true); motion(Vector2(470,265)); step(45); mouse(Vector2(470,265),false); step(3)
	w = game.j_G.boards[0]
	check(w.pickleN == 1 and game.stations.holding.is_empty(), "motion outside a deferred tray press cancels its hold")
	fresh(); queue_legacy_tap(); tap("bread"); tap("pickle"); game.controls.pause(); game.j_G.scene = "play"; step(12)
	check(game.j_G.boards[0] == null and game.j_G.stock.pickle == 16, "pause discards pending preparation clicks")
	fresh()
	# Start with a legacy touch on empty space so following direct touches must wait.
	for key in ["", "bread", "meat", "pickle"]:
		var point := Vector2(475,265) if key == "" else center(key)
		touch(point,true); touch(point,false)
	step(16); w = game.j_G.boards[0]
	check(w is Dictionary and w.meat == 1 and w.pickleN == 1, "touch preparation also respects preceding queued input")
	check(game.controls.touch_id == -1 and not game.controls.touch_select_only and game.stations.holding.is_empty(), "rapid touch releases leave no captured finger or hold")
	fresh(); queue_legacy_tap(); tap("bread"); tap("pickle"); game.controls.set_mode("controller"); step(12)
	check(game.j_G.boards[0] == null and game.j_G.stock.pickle == 16, "switching input device cancels queued pointer actions")
	var report := {"checks":checks,"failures":failures,"input":"native mouse events, deterministic simulation"}
	var file := FileAccess.open("res://validation/ingredient-input-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("INGREDIENT INPUT ",JSON.stringify(report)); game.free(); quit(0 if failures.is_empty() else 1)
