extends SceneTree
const Shell = preload("res://scripts/platform_shell.gd")
var game: Node
var checks := 0
var failures: Array[String] = []

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func button(index: JoyButton, down: bool, id := 0) -> void:
	var e := InputEventJoypadButton.new()
	e.device = id
	e.button_index = index
	e.pressed = down
	game._input(e)

func axis(index: JoyAxis, value: float, id := 0) -> void:
	var e := InputEventJoypadMotion.new()
	e.device = id
	e.axis = index
	e.axis_value = value
	game._input(e)

func touch(index: int, down: bool, position: Vector2, canceled := false) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.pressed = down
	e.position = position
	e.canceled = canceled
	game._input(e)

func drag(index: int, position: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = position
	game._input(e)

func key(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = down
	game._input(e)

func step(count := 1) -> void:
	for i in count: game.advance(1.0 / 60)

func center(key: String) -> Vector2:
	var st: Dictionary=game.j_ST[key]
	return Vector2(st.x+st.w/2,st.y+st.h/2)

func click_at(position: Vector2) -> void:
	game.pointer(position)
	button(JOY_BUTTON_A, true)
	step()
	button(JOY_BUTTON_A, false)
	step()

func _initialize() -> void: call_deferred("run")
func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/platform/input-save.json"
	game.storage.values = {}
	root.add_child(game)
	# This suite retains coverage of the optional original pointer/drag mode.
	# The default station workflow is exercised by tests/stations.gd.
	game.stations.enabled = false
	game.set_process(false)
	game.j_MUTED = true
	step()
	check(InputMap.has_action("game_accept"), "Godot editable Input Map installed")
	check(not ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"), "no duplicate emulated touch clicks")
	check(game.controls.targets.size() >= 5, "menu exposes controller focus targets")
	button(JOY_BUTTON_RIGHT_SHOULDER, true)
	button(JOY_BUTTON_RIGHT_SHOULDER, false)
	check(game.controls.mode == "controller", "controller detected without mouse")
	check(game.controls.target_index == 0, "bumper selects first menu target")
	button(JOY_BUTTON_A, true)
	step()
	button(JOY_BUTTON_A, false)
	step()
	check(game.j_G.scene == "prologue", "controller starts the game")
	game.f_startDay()
	game.j_G.tut = 99
	game.j_G.shutT = 0.0
	step()
	axis(JOY_AXIS_LEFT_X, 0.1)
	var x: float = game.j_IN.x
	step(3)
	check(is_equal_approx(x, game.j_IN.x), "deadzone suppresses drift")
	axis(JOY_AXIS_LEFT_X, 1)
	step(3)
	check(game.j_IN.x > x + 7, "analog stick moves cursor")
	axis(JOY_AXIS_TRIGGER_LEFT, 1)
	x = game.j_IN.x
	step(3)
	check(game.j_IN.x > x and game.j_IN.x < x + 3, "trigger provides precision movement")
	axis(JOY_AXIS_LEFT_X, 0)
	axis(JOY_AXIS_TRIGGER_LEFT, 0)
	game.pointer(Vector2(70, 230))
	button(JOY_BUTTON_DPAD_RIGHT, true)
	step()
	button(JOY_BUTTON_DPAD_RIGHT, false)
	check(game.j_IN.x > 70, "D-pad moves to station on right")
	# Complete a real order using controller clicks and drag input.
	click_at(center("bread"))
	check(game.j_G.boards[0] is Dictionary, "controller takes lavash")
	game.j_G.meat = 20.0
	game.j_G.stock.pickle = 20.0
	game.j_G.stock.yogurt = 20.0
	game.j_G.friesTray = 20.0
	for i in 4:
		for point in [center("meat"), center("pickle"), center("yogurt"), center("friesT")]: click_at(point)
	var wrap: Dictionary = game.j_G.boards[0]
	check(wrap.meat == 4 and wrap.pickleN == 4 and wrap.yogurtN == 4 and wrap.friesN == 4, "controller adds full recipe")
	var board := Vector2(game.wrap_system.f_boardCX(0), game.wrap_system.f_boardCY())
	game.pointer(board)
	button(JOY_BUTTON_A, true)
	step()
	axis(JOY_AXIS_LEFT_Y, -1)
	step(12)
	axis(JOY_AXIS_LEFT_Y, 0)
	button(JOY_BUTTON_A, false)
	step()
	check(wrap.state == "rolled", "stick and held accept roll wrap")
	game.pointer(center("paper"))
	button(JOY_BUTTON_X, true)
	button(JOY_BUTTON_X, false)
	step()
	check(game.j_IN.down and game.controls.latched, "latch holds paper without holding button")
	game.pointer(board)
	step()
	button(JOY_BUTTON_X, true)
	button(JOY_BUTTON_X, false)
	step()
	check(wrap.state == "ready" and wrap.paper, "latched drag packages wrap")
	game.customer_system.f_spawnCustomer()
	var customer: Dictionary = game.j_G.customers[0]
	customer.state = "wait"; customer.x = customer.tx
	customer.items = [{"kind": "wrap"}]; customer.done = [false]
	click_at(board)
	check(game.j_G.hand is Dictionary, "controller picks up ready order")
	click_at(Vector2(customer.x, customer.y - 25))
	check(game.j_G.stat.wraps == 1, "controller serves customer")
	button(JOY_BUTTON_START, true)
	button(JOY_BUTTON_START, false)
	check(game.j_G.scene == "pause", "Start pauses")
	game.j_SESP.open = true
	button(JOY_BUTTON_B, true); button(JOY_BUTTON_B, false)
	check(not game.j_SESP.open and game.j_G.scene == "pause", "back closes overlay before unpausing")
	button(JOY_BUTTON_START, true); button(JOY_BUTTON_START, false)
	check(game.j_G.scene == "play", "Start resumes")
	button(JOY_BUTTON_A, true); step()
	axis(JOY_AXIS_LEFT_X, 1)
	game.controls.disconnected(0)
	check(game.j_G.scene == "pause" and not game.j_IN.down and game.controls.axes == Vector2.ZERO, "controller disconnect pauses and releases all input")
	button(JOY_BUTTON_START, true, 1); button(JOY_BUTTON_START, false, 1)
	check(game.controls.device == 1 and game.j_G.scene == "play", "replacement controller takes over")
	button(JOY_BUTTON_START, true, 2)
	check(game.j_G.scene == "play", "second controller cannot interrupt active player")
	# Finger ownership, canceled gestures and input method switching.
	touch(3, true, center("bread")); step()
	check(game.controls.mode == "touch" and game.j_TOUCH, "touch updates current input mode")
	touch(7, true, Vector2(445, 238))
	drag(7, Vector2(400, 200))
	check(game.j_IN.x == center("bread").x and game.controls.touch_id == 3, "second finger cannot move active gesture")
	touch(7, false, Vector2(400, 200)); step()
	check(game.j_IN.down, "second finger release cannot release first finger")
	touch(3, false, center("bread"), true)
	check(not game.j_IN.down and game.controls.touch_id == -1, "OS touch cancel clears gesture")
	# Both edges before a frame still produce a click, once.
	game.j_G.boards = [null, null, null]
	touch(2, true, center("bread")); touch(2, false, center("bread"))
	step(2)
	check(game.j_G.boards[0] is Dictionary and not game.j_IN.down, "quick tap survives press and release in same frame")
	var mouse := InputEventMouseMotion.new()
	mouse.position = Vector2(60,220); mouse.relative = Vector2(3,0)
	game._input(mouse)
	check(not game.j_TOUCH and game.controls.mode == "mouse", "real mouse restores cursor after touch")
	key(KEY_RIGHT, true); step(3); key(KEY_RIGHT, false)
	check(game.controls.mode == "keyboard" and game.j_IN.x > 65, "keyboard-only cursor works")
	key(KEY_SPACE, true); step()
	game.f_appPause()
	check(game.suspended and not game.j_IN.down and game.controls.held.is_empty(), "backgrounding clears held keys and suspends")
	check(game.f_loadGame() is Dictionary, "backgrounding flushes progression checkpoint")
	game.f_appResume()
	check(not game.suspended and game.j_G.scene == "pause", "foreground return waits in pause menu")
	# Aspect ratios, safe areas and coordinate round trips.
	for screen in [Vector2(640,360), Vector2(1920,1080), Vector2(3840,2160), Vector2(3440,1440), Vector2(2732,2048), Vector2(2532,1170), Vector2(1280,800), Vector2(390,844)]:
		for whole in [false, true]:
			var safe := Shell.usable_area(screen, screen, Rect2(Vector2(32,12), screen - Vector2(64,32)), false)
			var fitted := Shell.fit_game(safe, whole)
			check(safe.grow(1).encloses(fitted), "full game fits " + str(screen) + " integer=" + str(whole))
			check(is_equal_approx(fitted.size.x / fitted.size.y, 16.0 / 9), "aspect preserved " + str(screen))
			var point := Vector2(455, 242)
			var physical := fitted.position + point * fitted.size / Shell.GAME_SIZE
			var restored := (physical - fitted.position) * Shell.GAME_SIZE / fitted.size
			check(restored.distance_to(point) < 0.001, "pointer roundtrip " + str(screen))
	var tv := Shell.usable_area(Vector2(1920,1080), Vector2(1920,1080), Rect2(0,0,1920,1080), true)
	check(tv.position == Vector2(54,54) and tv.end == Vector2(1866,1026), "TV overscan margin applied")
	for density in [1.25, 1.5]:
		var integer_fit := Shell.fit_game(Rect2(8,8,944,476), true, density)
		var physical_pixel: float = integer_fit.size.x / 480 * density
		check(is_equal_approx(physical_pixel, floorf(physical_pixel)), "integer pixels survive desktop DPI scaling " + str(density))
	var output := {"checks": checks, "failures": failures, "hardware": "macOS; simulated device input and screen geometry"}
	var file := FileAccess.open("res://validation/platform/input-results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t")); file.close()
	print("PLATFORM INPUT ", JSON.stringify(output))
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
