# MIKRO OLCUM (gelistirme araci): sicak yollarin tek tek maliyeti (us / cagri).
#   godot --path . --resolution 960x540 --script tests/hd_mikro.gd -- --test --gpu-test
extends SceneTree
const J = preload("res://scripts/js_compat.gd")

const N := 2000
var shell: Control
var g: Node

func _initialize() -> void:
	create_timer(170.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func olc(ad: String, fn: Callable) -> void:
	var c = g.screen_canvas
	c.begin_frame()
	var t0 := Time.get_ticks_usec()
	for i in N: fn.call()
	var us := (Time.get_ticks_usec() - t0) / float(N)
	c.end_frame()
	print("%-34s %7.2f us" % [ad, us])

func calis() -> void:
	root.size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	var A: Dictionary = g.atlas("efekt")
	var p := {"x": 200.0, "y": 100.0, "t": 0.2, "life": 1.0, "type": "smoke", "col": "rgba(255,235,205,.35)", "sz": 2.0}
	var tex: Texture2D = A.tex
	var src := Rect2(0, 0, 12, 12)
	var ctx = g.screen_canvas
	olc("bos cagri", func() -> void: pass)
	olc("J.n(float)", func() -> void: J.n(p.x))
	olc("p.get + J.n x5", func() -> void:
		var a := J.n(p.get("x")); var b := J.n(p.get("y")); var c := J.n(p.get("t")); var d := J.n(p.get("life")); var e := J.n(p.get("sz")))
	olc("_renk(rgba)", func() -> void: g._renk(p.col))
	olc("'duman_%d' % R", func() -> void: var s := "duman_%d" % 6)
	olc("A.parca.get(ad)", func() -> void: A.parca.get("duman_6"))
	olc("ctx.texture_hd", func() -> void: ctx.texture_hd(tex, src, 200.0, 100.0, 0.5, false, Color.WHITE))
	olc("hd_ciz", func() -> void: g.hd_ciz(A, "duman_6", 200.0, 100.0, 0.5, false, Color.WHITE))
	olc("f_fr (duz dikdortgen)", func() -> void: g.f_fr(10, 10, 4, 4, "#ff0000"))
	olc("f_px", func() -> void: g.f_px(10, 10, "#ff0000"))
	olc("f_ell 8x3", func() -> void: g.f_ell(100, 100, 8, 3, "#ff0000"))
	olc("f_txt 'USTA DONER'", func() -> void: g.text_draw.f_txt("USTA DÖNER", 100, 100, "#fff", {}))
	olc("  f_T", func() -> void: g.localization.f_T("USTA DÖNER"))
	olc("  f_textW", func() -> void: g.f_textW("USTA DÖNER", 1.0, null))
	olc("  f_drawStr", func() -> void: g.f_drawStr("USTA DÖNER", 100, 100, "#fff", 1.0, null))
	olc("f_txt golgeli", func() -> void: g.text_draw.f_txt("USTA DÖNER", 100, 100, "#fff", {"shadow": 1.0}))
	olc("f_txt cerceveli", func() -> void: g.text_draw.f_txt("USTA DÖNER", 100, 100, "#fff", {"outline": "#000"}))
	olc("f_pedKimlik", func() -> void: g.pedestrian_draw.f_pedKimlik(3.0))
	olc("_c f_hash1", func() -> void: g._c("f_hash1", 1.0))
	olc("f_hash1 dogrudan", func() -> void: g.f_hash1(1.0))
	olc("_c f_stM", func() -> void: g._c("f_stM"))
	olc("f_hdYaya", func() -> void: g.f_hdYaya(300.0, 150.0, 3.0, 1.0, 2.0, 1.0, false))
	olc("f_hdYarimPx", func() -> void: g.f_hdYarimPx(3.3))
	g.j_PS = []
	for i in 67:
		g.j_PS.append({"x": 100.0 + i, "y": 100.0, "t": 0.2, "life": 1.0, "type": ["smoke", "star", "px"][i % 3], "col": "rgba(255,235,205,.35)" if i % 3 == 0 else "#ffcc66", "sz": 2.0})
	olc("f_psDraw (67)", func() -> void: g.effects.f_psDraw())
	quit(0)
