extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)

func start_day() -> void:
	game.controls.release_all()
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 10000
	game.j_G.meat = 16
	game.controls.set_mode("controller")
	game.f_newWrap()
	game.stations.select("meat")

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/runtime-state-save.json"
	game.storage.values = {}
	root.add_child(game)
	game.set_process(false); game.j_MUTED = true
	# A real New Game transition after an existing run, not a direct startDay.
	game.j_G.prologueSeen = true
	game.j_G.custom.counter = 2
	game.session_system.f_resetProgress()
	# Birlesik 11. tur: Yeni Oyun artik null birakmaz (Kisisellestir penceresi
	# "null" gosteriyordu); ilk acilistaki varsayilan tabelaya doner.
	check(game.j_G.custom is Dictionary and game.j_G.custom.sign == "USTA DÖNER" and float(game.j_G.custom.counter) == 0.0, "new game resets prior customization to the default")
	game.session_system.f_goIntro()
	game.advance(1.0/60)
	check(game.j_G.scene == "intro" and game.counter_theme() == 0, "new game intro renders the default counter without customization")
	# The procedural fallback must handle the same optional state as the atlas.
	var atlas: Variant = game.counter_base
	game.counter_base = null; game.j_CLAYER = null
	game.advance(1.0/60)
	check(game.j_CLAYER != null, "procedural counter also renders after new game")
	game.counter_base = atlas
	start_day(); game.advance(1.0/60)
	check(game.j_G.scene == "play" and float(game.j_G.custom.counter) == 0.0, "first day runs with the default customization")
	# Eski kayitlardaki bos / eksik ozellestirme de calismaya devam eder.
	game.j_G.custom = null
	game.advance(1.0/60)
	check(game.j_G.scene == "play" and game.counter_theme() == 0, "a legacy null customization still renders the default counter")
	game.j_G.custom = {}
	check(game.counter_theme() == 0, "an unset counter choice uses the default")
	game.j_G.erase("custom")
	check(game.counter_theme() == 0, "missing legacy customization uses the default")
	for theme in range(game.j_COUNTER_PAL.size()):
		game.j_G.custom = {"counter":theme}
		check(game.counter_theme() == theme, "valid counter theme preserved: " + str(theme))
	game.j_G.custom = null
	# Reproduce the reported partial Dictionary from otherwise valid actions.
	for missing in ["target", "id", "source", "time", "board", "index", "next"]:
		start_day()
		game.stations.accept(true, "test")
		game.stations.holding.erase(missing)
		var before: float = game.j_G.meat
		game.advance(1.0/60)
		check(game.stations.holding.is_empty() and game.j_G.meat == before, "incomplete ingredient hold cancels without extra stock use: " + missing)
		# BIRLESIK (8. tur): ilk basis porsiyonu doldurdu; yeni basis bos lavasa tam porsiyon koyar
		game.j_G.boards[int(game.j_G.act)].meat = 0
		game.stations.accept(true, "test")
		game.stations.accept(false, "test")
		check(game.j_G.meat == before-game.j_MEAT_NEED and game.stations.holding.is_empty(), "a fresh press works after invalid hold: " + missing)
	start_day()
	var wrap: Dictionary = game.j_G.boards[0]
	wrap.meat = 4
	game.stations.select("board:0"); game.stations.press("roll", "test")
	game.stations.tick(0.1)
	check(wrap.roll > 0, "roll begins before cancellation test")
	game.stations.holding.erase("target"); game.stations.tick(0.1)
	check(wrap.roll == 0 and wrap.state == "open" and game.stations.holding.is_empty(), "invalid roll clears progress without completing the wrap")
	game.stations.holding = {"id":"roll"}; game.stations.cancel()
	check(game.stations.holding.is_empty(), "cancel tolerates a roll with no board")
	game.stations.holding = {"target":"meat"}; game.stations.cancel()
	check(game.stations.holding.is_empty(), "cancel tolerates an absent action id")
	game.j_G.cut.potato = true
	game.stations.select("cut"); game.stations.press("chop", "test")
	game.j_G.cut.hold = 0.1; game.j_G.cut.cutting = true
	game.stations.holding.erase("target"); game.stations.tick(0.1)
	check(not game.j_G.cut.cutting and game.j_G.cut.hold == 0 and game.stations.holding.is_empty(), "invalid potato hold stops chopping")
	game.j_G.meat = 0
	game.stations.select("spit"); game.stations.press("cut_meat", "test")
	check(game.controls.quick_cut_active, "station cut starts before cancellation test")
	game.stations.holding.erase("target"); game.stations.tick(0.1)
	check(not game.controls.quick_cut_active and game.stations.holding.is_empty(), "invalid meat hold releases the quick cut")
	var report := {"checks":checks,"failures":failures,"cases":"new game intro/first day; atlas/procedural counter; injected incomplete holds"}
	var file := FileAccess.open("res://validation/runtime-state-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("RUNTIME STATE ",JSON.stringify(report))
	game.free(); await process_frame; quit(0 if failures.is_empty() else 1)
