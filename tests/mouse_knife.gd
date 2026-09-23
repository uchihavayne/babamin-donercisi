extends SceneTree

class ProbeGame extends "res://scripts/platform_game.gd":
	var blade_draws := 0
	var blade_alpha := 0.0
	func f_drawKesimBicagi(x: Variant = null, y: Variant = null, direction: Variant = null, level: Variant = null) -> Variant:
		blade_draws += 1
		blade_alpha = float(j_ctx.globalAlpha)
		return super.f_drawKesimBicagi(x, y, direction, level)

var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error(message)

func mouse(point: Vector2, motion := Vector2.ONE) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.relative = motion
	game._input(event)

func frame() -> void:
	game.blade_draws = 0
	game.blade_alpha = 0.0
	game.advance(1.0 / 60)

func snapshot(name: String) -> void:
	if not game.gpu_enabled: return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/cutting/" + name + ".png")

func check_blade_pixels() -> void:
	# Compare actual opaque blade pixels against the atlas while cut effects
	# are active: a drawn-but-covered knife must fail just like a missing one.
	var canvas := preload("res://scripts/pixel_canvas.gd").new()
	canvas.width = 480; canvas.height = 270; canvas.ensure()
	var original: Variant = game.j_ctx
	game.j_ctx = canvas
	game.f_drawPlay(game.j_G.t)
	game.j_ctx = original
	var blade: Variant = game.sprite_library.get_sprite("knife/0/-1")
	var offset: Array = game.sprite_library.manifest["knife/0/-1"].offset
	var origin := Vector2i(int(game.j_IN.x)-5,int(game.j_IN.y)) + Vector2i(offset[0],offset[1])
	var covered := 0
	for y in blade.image.get_height():
		for x in blade.image.get_width():
			var expected: Color = blade.image.get_pixel(x,y)
			if expected.a == 1.0 and canvas.image.get_pixel(origin.x+x,origin.y+y) != expected: covered += 1
	check(covered == 0, "complete world rendering cannot cover any opaque knife pixels: " + str(covered))

func run() -> void:
	root.content_scale_size = Vector2i(480,270)
	root.size = Vector2i(960,540)
	game = ProbeGame.new()
	game.storage.path = "res://artifacts/cutting/mouse-knife-save.json"
	game.storage.values = {}
	root.add_child(game)
	game.set_process(false)
	game.j_MUTED = true
	game.f_startDay()
	game.j_G.tut = 99
	game.j_G.shutT = 0
	game.j_G.spawnT = 1000
	mouse(Vector2(game.j_LAY.spit.cx,110))
	frame()
	check(game.blade_draws == 1 and game.blade_alpha == 1.0, "mouse hover has exactly one opaque knife")
	var stable := true
	for i in 40:
		frame()
		stable = stable and game.blade_draws == 1 and game.blade_alpha == 1.0
	check(stable, "stationary hover retains one opaque knife for 40 frames")
	game.controls.set_mode("touch")
	game.pointer(Vector2(240,220))
	mouse(Vector2(game.j_LAY.spit.cx,110), Vector2.ZERO)
	frame()
	check(game.controls.mode == "mouse" and game.blade_draws == 1, "absolute mouse entry after touch immediately restores knife")
	game.controls.set_mode("touch")
	mouse(Vector2(game.j_LAY.spit.cx,110), Vector2.ZERO)
	frame()
	check(game.controls.mode == "mouse" and game.blade_draws == 1, "mouse return at the same position restores knife without clicking")
	await snapshot("mouse-return")
	game.controls.set_mode("touch")
	var emulated := InputEventMouseMotion.new()
	emulated.device = InputEvent.DEVICE_ID_EMULATION
	emulated.position = Vector2(game.j_LAY.spit.cx,110)
	game._input(emulated)
	check(game.controls.mode == "touch", "touch-emulated mouse event cannot take ownership")
	var finger := InputEventScreenTouch.new()
	finger.index = 0; finger.position = Vector2(game.j_LAY.spit.cx,110); finger.pressed = true
	game._input(finger); frame()
	mouse(Vector2(240,220), Vector2.ZERO)
	check(game.controls.mode == "touch" and game.controls.touch_id == 0, "real mouse cannot interrupt a captured finger")
	finger.pressed = false; game._input(finger); frame()
	mouse(Vector2(game.j_LAY.spit.cx,110))
	game.f_doSlice()
	frame()
	check(game.blade_draws == 1, "mouse cutting has one stable knife instead of competing animations")
	check_blade_pixels()
	await snapshot("mouse-cut")
	stable = true
	for i in 60:
		mouse(Vector2(game.j_LAY.spit.cx, 75 if i % 2 else 150))
		frame()
		stable = stable and game.blade_draws == 1 and game.blade_alpha == 1.0
	check(stable, "mouse blade remains opaque through repeated cuts and cooldowns")
	check(game.j_G.meat > 2, "mouse swipes still produce meat")
	for level in 5:
		game.j_G.up.knife = float(level)
		game.j_G.meat = 16.0
		frame()
		check(game.blade_draws == 1 and game.blade_alpha == 1.0, "full tray retains knife at upgrade " + str(level))
	await snapshot("mouse-full-tray")
	game.j_G.up.knife = 0.0
	game.j_G.spit.sliceT = 0.0
	mouse(Vector2(240,220))
	frame()
	check(game.blade_draws == 0, "idle knife hides after leaving spit")
	mouse(Vector2(game.j_LAY.spit.cx,110), Vector2.ZERO)
	frame()
	check(game.blade_draws == 1, "absolute mouse re-entry restores knife immediately")
	var report := {"checks": checks, "failures": failures}
	var file := FileAccess.open("res://validation/cutting/mouse-knife-results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("MOUSE KNIFE ", JSON.stringify(report))
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
