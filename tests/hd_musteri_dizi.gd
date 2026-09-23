# HD MUSTERI DIZISI (birlesik surum): cok sayida rastgele musteriyi sirayla
# ilk slota koyup yuzlerini yakindan bir izgaraya dizer (yuzde garip cizgi /
# kayis gibi kusurlari toplu gormek icin).
#   godot --path . --resolution 960x540 --script tests/hd_musteri_dizi.gd -- --test --gpu-test
#       [--cikti artifacts/musteri_dizi.png] [--adet 24] [--kalip kurye]
extends SceneTree

var shell: Control
var g: Node

func arg(ad: String, varsayilan: String = "") -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else varsayilan

func _initialize() -> void:
	create_timer(110.0).timeout.connect(func() -> void: print("BEKCI: zaman asimi"); quit(2))
	call_deferred("calis")

func adim(n: int = 3) -> void:
	for i in n:
		g.advance(1.0 / 60.0)
		await process_frame

func calis() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	g.j_G.up = {}
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
	var adet := int(arg("--adet", "24"))
	var sutun := 8
	var hw := 128
	var hh := 150
	var izgara := Image.create(hw * sutun, hh * ceili(adet / float(sutun)), false, Image.FORMAT_RGBA8)
	for i in adet:
		g.j_G.customers.clear()
		g.customer_system.f_spawnCustomer()
		var c: Dictionary = g.j_G.customers[0]
		c.state = "wait"; c.x = c.tx; c.bubble = 0.0
		if arg("--kalip") != "" and c.get("look") is Dictionary:
			c.look.kalip = arg("--kalip")
		g.j_G.spawnT = 1000
		print("MUSTERI ", i, " ", c.get("look"))
		await adim(2)
		await RenderingServer.frame_post_draw
		var im := root.get_texture().get_image()
		var ox := int(float(c.x) * 2.0) - hw / 2
		var oy := 150
		izgara.blit_rect(im, Rect2i(ox, oy, hw, hh), Vector2i((i % sutun) * hw, (i / sutun) * hh))
	var cikti := arg("--cikti", "res://artifacts/musteri_dizi.png")
	izgara.save_png(cikti)
	print("KAYDEDILDI ", cikti)
	quit(0)
