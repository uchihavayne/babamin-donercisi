# Explicit authoring tool: run only when intentionally rebuilding the PNG artwork.
extends SceneTree
const Canvas = preload("res://scripts/pixel_canvas.gd")
var game: Variant
var manifest: Dictionary = {}
var atlas: Image
var sheet_name := ""
var cell := Vector2i(128, 128)
var columns := 8
var index := 0

func _initialize() -> void: call_deferred("run")

func sheet(name: String, size: Vector2i, count: int, cols: int = 8) -> void:
	flush()
	sheet_name = name
	cell = size
	columns = cols
	index = 0
	atlas = Image.create(size.x * cols, size.y * int(ceil(float(count) / cols)), false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)

func flush() -> void:
	if atlas != null: atlas.save_png("res://assets/sprites/" + sheet_name + ".png")

func add(key: String, img: Image, offset: Vector2i = Vector2i.ZERO, extra: Dictionary = {}) -> void:
	var pos := Vector2i(index % columns, int(index / columns)) * cell
	atlas.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), pos)
	manifest[key] = {"sheet": sheet_name + ".png", "region": [pos.x, pos.y, img.get_width(), img.get_height()], "offset": [offset.x, offset.y], "cell": [cell.x, cell.y], "index": index}
	manifest[key].merge(extra)
	index += 1

func paint(method: String, args: Array, size: Vector2i = Vector2i(128, 128)) -> Image:
	var canvas := Canvas.new()
	canvas.width = size.x; canvas.height = size.y; canvas.ensure()
	game.j_ctx = canvas
	game.callv(method, args)
	return canvas.image

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/sprites")
	game = load("res://scripts/game.gd").new()
	game.storage.path = "res://artifacts/bake-save.json"; game.storage.values = {}
	root.add_child(game)
	game.j_MUTED = true
	game.set_process(false)
	game.localization.f_setLang("tr")
	sheet("tezgah_esyalari", Vector2i(128, 128), 32)
	for size in [Vector2i(46,28), Vector2i(34,28), Vector2i(42,28), Vector2i(34,34)]:
		for method in ["f_trayBase", "f_trayInnerShade"]:
			add("%s/%dx%d" % [method, size.x, size.y], paint(method, [32.0,32.0,float(size.x),float(size.y)]), Vector2i(-32,-32))
	add("bread/42", paint("f_drawBreadStack", [32.0,32.0,42.0,46.0,""]), Vector2i(-32,-32))
	add("pide/42", paint("f_drawPideStack", [32.0,32.0,42.0]), Vector2i(-32,-32))
	add("potato/44x38", paint("f_potBinPaint", [32.0,32.0,44.0,38.0]), Vector2i(-32,-32))
	for level in range(4):
		for direction in [-1,1]:
			add("knife/%d/%d" % [level,direction], paint("f_drawKesimBicagi", [64.0,64.0,float(direction),float(level)]), Vector2i(-64,-64))
	for seed_info in [["et", 46, 28, 1.3, "f_meatStrip"], ["tursu",34,28,4.7,"f_pickleSlice"], ["patates",34,28,9.2,"f_fryStick"]]:
		var w: int = seed_info[1]; var h: int = seed_info[2]
		sheet("doluluk_" + seed_info[0], Vector2i(w+4,h+10), 41)
		for q in range(41):
			var canvas := Canvas.new(); canvas.width = w+4; canvas.height = h+10; canvas.ensure()
			game.j_ctx = canvas
			var ty: float = game.tray_draw.f_fillPaint(2.0,6.0,float(w),float(h),q/40.0,seed_info[3],game.J.ref(Callable(game, seed_info[4]),5))
			add("fill/%dx%d/%.1f/%d" % [w,h,seed_info[3],q], canvas.image, Vector2i(-2,-6), {"top": ty-6})
	# Story backgrounds and foregrounds retain exactly the original separate layers.
	game.j_ctx = game.screen_canvas
	game.story_draw.f_proStart()
	for i in game.j_PRO_SCENES.size():
		game.j_PRO.i = float(i); game.j_PRO.t = 5.0; game.j_PRO.ch = 1000.0
		game.advance(1.0/60)
	for name in game.j_PRO_KAT:
		sheet("hikaye_" + str(name), Vector2i(400,150), 1, 1)
		add("story/" + str(name), game.j_PRO_KAT[name].image)
	flush()
	var file := FileAccess.open("res://assets/sprites/manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t")); file.close()
	var palette := FileAccess.open("res://assets/sprites/donerci.gpl", FileAccess.WRITE)
	palette.store_line("GIMP Palette\nName: Babamin Donercisi\nColumns: 8\n# Original game palette")
	for name in game.j_P:
		var color: Color = Canvas.parse_color(game.j_P[name])
		palette.store_line("%d %d %d %s" % [color.r8,color.g8,color.b8,name])
	palette.close()
	print("BAKED ", manifest.size(), " sprites; story layers=", game.j_PRO_KAT.size())
	game.free(); quit()
