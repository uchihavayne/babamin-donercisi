# DAYI BEKLEME ANIMASYONU (gelistirme araci): servis bolmesindeki Dayi'yi
# zaman icinde N kare yakalar, yan yana PNG (4x buyutulmus).
#   godot --path . --resolution 960x540 --script tests/hd_dayi_kare.gd -- --test --gpu-test [--adim 0.35] [--n 24]
extends SceneTree

var shell: Control
var g: Node

func arg(ad: String, v: String) -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else v

func _initialize() -> void:
	create_timer(110.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func calis() -> void:
	root.size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	g.j_G.up = {}
	for u in g.j_UPG: g.j_G.up[u.id] = float(u.lv.size())
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
	var adim := float(arg("--adim", "0.35"))
	var n := int(arg("--n", "24"))
	var kutu := Rect2i(0, 236, 110, 304)
	var sheet := Image.create(kutu.size.x * n, kutu.size.y, false, Image.FORMAT_RGBA8)
	for i in n:
		var k := int(round(adim * 60.0))
		for j in k:
			g.advance(1.0 / 60.0)
			await process_frame
		await RenderingServer.frame_post_draw
		var im := root.get_texture().get_image()
		im.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(im, kutu, Vector2i(i * kutu.size.x, 0))
	sheet.save_png("res://artifacts/dayi_kare.png")
	print("KAYDEDILDI dayi_kare")
	quit(0)
