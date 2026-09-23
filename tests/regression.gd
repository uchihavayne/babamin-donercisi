extends SceneTree
var game: Variant
var failures: Array[String] = []
var checks: int = 0
var report: Dictionary = {}
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error("CHECK FAILED: " + message)
func snap(name: String) -> void:
	if not game.gpu_enabled: game.screen_canvas.image.save_png("res://artifacts/" + name + ".png")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/regression-save.json"
	game.storage.values = {}
	root.add_child(game)
	game.set_process(false)
	game.j_MUTED = true
	check(game.j_LOGO.tamam == 14, "all 14 logo assets load")
	check(game.audio_streams.size() == 7, "all 7 audio clips load")
	for lang in ["en", "tr", "de", "es", "fr", "pt"]:
		game.localization.f_setLang(lang)
		game.advance(1.0 / 60)
		check(game.j_LANG == lang, "language " + lang)
	game.localization.f_setLang("tr")
	game.pointer(Vector2(240, 144))
	game.pointer_button(true)
	game.advance(1.0 / 60)
	game.pointer_button(false)
	check(game.j_G.scene == "prologue", "start button enters prologue")
	for i in game.j_PRO_SCENES.size():
		game.j_PRO.i = float(i)
		game.j_PRO.t = 5.0
		game.j_PRO.ch = 1000.0
		game.advance(1.0 / 60)
		snap("story-" + str(i))
	game.f_startDay()
	game.j_G.tut = 99
	game.j_G.shutT = 0.0
	game.customer_system.f_spawnCustomer()
	check(game.j_G.customers.size() == 1, "customer spawns with procedural appearance")
	var customer: Dictionary = game.j_G.customers[0]
	customer.state = "wait"
	customer.x = customer.tx
	customer.items = [{"kind": "wrap"}]
	customer.done = [false]
	game.j_G.meat = 20.0
	game.j_G.friesTray = 20.0
	game.j_G.stock.pickle = 20.0
	game.j_G.stock.yogurt = 20.0
	game.f_newWrap()
	for i in 4:
		game.assembly_system.f_addMeat()
		game.assembly_system.f_addIng("pickle")
		game.assembly_system.f_addIng("yogurt")
		game.assembly_system.f_addIng("fries")
	var wrap: Dictionary = game.j_G.boards[0]
	check(wrap.meat == 4 and wrap.pickleN == 4 and wrap.yogurtN == 4 and wrap.friesN == 4, "all four recipe ingredients transfer correctly")
	game.f_finishRoll(0)
	game.wrap_system.f_applyPaper(0)
	check(wrap.state == "ready" and wrap.paper, "wrap rolls and paper attaches")
	game.j_G.hand = wrap
	game.j_G.boards[0] = null
	game.f_deliver(customer)
	check(game.j_G.stat.wraps == 1, "customer receives correct wrap")
	check(game.j_G.hand == null, "serving clears held item")
	check(game.j_G.coins.size() > 0, "sale creates collectible money")
	while game.j_G.coins.size() > 0: game.payment_system.f_collectCoin(0, true)
	check(game.j_G.money > 0, "sale increases money")
	game.advance(1.0 / 60)
	snap("served-wrap")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_ESCAPE
	key.keycode = KEY_ESCAPE
	key.pressed = true
	game._input(key)
	game.advance(1.0 / 60)
	check(game.j_G.scene == "pause", "Escape pauses")
	key.pressed = false; game._input(key)
	key.pressed = true; game._input(key)
	game.advance(1.0 / 60)
	check(game.j_G.scene == "play", "Escape resumes")
	key.pressed = false; game._input(key)
	game.session_system.f_endDay()
	game.advance(1.0 / 60)
	snap("day-end")
	check(game.j_G.scene == "dayend", "day ends")
	var saved: Variant = game.f_loadGame()
	check(saved is Dictionary and saved.stats.wraps == 1, "save reload preserves sales")
	game.j_G.scene = "shop"
	game.j_G.dersGorulmus = true
	game.advance(1.0 / 60)
	snap("upgrades")
	for panel in ["SESP", "STATS", "BSP", "CUSTOM", "BRP", "PAYP"]:
		game.get("j_" + panel).open = true
		game.advance(1.0 / 60)
		snap("panel-" + panel.to_lower())
		game.get("j_" + panel).open = false
	game.j_G.day = 60.0
	game.j_G.money = 5000000.0
	game.j_G.branch = game.j_BRANCH.size()
	for upgrade in game.j_UPG: game.j_G.up[upgrade.id] = float(upgrade.lv.size())
	for city in range(-1, game.j_SEHIR.size()):
		print("CITY ", city)
		game.branch_draw.f_sehreGit(city)
		game.f_startDay()
		game.j_G.tut = 99
		game.j_G.shutT = 0.0
		game.j_G.weather = "rain"
		for i in 3: game.customer_system.f_spawnCustomer()
		for c in game.j_G.customers:
			c.state = "wait"; c.x = c.tx; c.bubble = 1.0
		for step in 60:
			game.j_G.t += 1.0 / 30
			game.game_loop.f_updatePlay(1.0 / 30)
			game.effects.f_psUpdate(1.0 / 30)
			game.effects.f_ftUpdate(1.0 / 30)
		for step in 2: game.advance(1.0 / 60)
		snap("city-" + str(city))
		check(game.j_G.scene == "play", "advanced city " + str(city) + " runs")
	game.j_G.scene = "night"
	game.j_G.night = {"t": 1.0, "phase": 0.0, "stole": true, "amount": 100.0, "sec": 0.0, "line": "Deneme", "paid": false}
	game.advance(1.0 / 60)
	snap("night")
	game.effects.f_textStart("USTA", 14)
	var letter := InputEventKey.new()
	letter.keycode = KEY_I; letter.physical_keycode = KEY_I; letter.unicode = 105; letter.pressed = true
	game._input(letter)
	check(game.j_TEXTIN.value == "USTAİ", "Turkish shop name input")
	game.effects.f_textStop()
	game.f_appPause()
	check(game.suspended, "focus loss suspends simulation")
	game.f_appResume()
	check(not game.suspended, "focus return resumes platform")
	report = {"checks": checks, "failures": failures, "cities": game.j_SEHIR.size(), "upgrades": game.j_UPG.size()}
	var file := FileAccess.open("res://artifacts/regression.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t")); file.close()
	print("REGRESSION ", JSON.stringify(report))
	game.free()
	game = null
	await create_timer(.15).timeout
	quit(0 if failures.is_empty() else 1)
