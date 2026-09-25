# FARE AKISI + KLAVYE (birlesik surum, 9. tur): ogreticideki yolu yalniz
# gercek fare olaylariyla bastan sona oynar: patates cuvali -> dograma ->
# fritoz -> lavas -> malzemeler (tek tik) -> YUKARI surukleyerek sarma ->
# kagidi surukleyip birakma -> durumu alip musteriye verme -> parayi toplama.
# Ardindan klavye kisayollari: R hizli kesim, P/Esc duraklat, M ses, Tab/Q
# istasyon, Bosluk eylem.
#   godot --headless --path . --script tests/fare_akisi.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n := 1) -> void:
	for i in n: game.advance(1.0 / 60)

func center(key: String) -> Vector2:
	var s: Dictionary = game.j_ST[key]
	return Vector2(s.x + s.w / 2, s.y + s.h / 2)

func mouse(p: Vector2, down: bool) -> void:
	var e := InputEventMouseButton.new()
	e.position = p; e.pressed = down; e.button_index = MOUSE_BUTTON_LEFT
	game._input(e); step(2)

func motion(p: Vector2) -> void:
	var e := InputEventMouseMotion.new(); e.position = p
	game._input(e); step(1)

func tap(p: Vector2) -> void:
	mouse(p, true); mouse(p, false)

func drag(a: Vector2, b: Vector2, adim := 8) -> void:
	mouse(a, true)
	for i in range(1, adim + 1): motion(a.lerp(b, float(i) / adim))
	mouse(b, false)

func key(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code; e.keycode = code; e.pressed = down
	game._input(e); step(1)

func tus(code: Key) -> void:
	key(code, true); key(code, false)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/fare-akisi-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	game.session_system.f_resetProgress()
	game.j_G.day = 2.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 10000; game.j_G.timeLeft = 10000
	game.j_G.meat = 8; game.j_G.stock.pickle = 12; game.j_G.stock.yogurt = 12; game.j_G.friesTray = 0
	game.controls.set_mode("mouse")
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state = "wait"; c.x = c.tx; c.items = [{"kind": "wrap", "sauce": null}]; c.done = [false]; c.patience = 1.0
	# patates: cuval -> dograma (basili) -> fritoz -> cikar
	tap(center("potato")); step(60)
	check(game.j_G.cut.potato, "cuvala tiklamak patatesi dograma tahtasina getirir")
	mouse(center("cut"), true); step(int(60 * (float(game.J.method(game.j_TUN, "cutTime", [game.j_G])) + 0.5))); mouse(center("cut"), false)
	check(float(game.j_G.cut.raw) > 0.0, "tahtaya basili tutmak patatesi dograr (cig: %s)" % game.j_G.cut.raw)
	tap(center("fryer")); step(10)
	check(game.j_G.fryer.state == "fry", "fritoze tiklamak kizartmayi baslatir")
	step(int(60 * (float(game.J.method(game.j_TUN, "fryTime", [game.j_G])) + 0.5)))
	tap(center("fryer")); step(30)
	check(float(game.j_G.friesTray) >= 4.0, "pismis patates tepsiye gelir (%s)" % game.j_G.friesTray)
	# durum: lavas + tek tik malzemeler
	tap(center("bread")); step(5)
	var w: Variant = game.j_G.boards[0]
	check(w is Dictionary and w.kind == "wrap", "lavasa tiklamak tahtaya lavas acar")
	for k in ["meat", "pickle", "yogurt", "friesT"]: tap(center(k)); step(8)
	check(w.meat == 4 and w.pickleN == 4 and w.yogurtN == 4 and w.friesN == 4, "dort tik dort tam malzeme: %s" % [[w.meat, w.pickleN, w.yogurtN, w.friesN]])
	# sarma: tahtadaki durumu tutup YUKARI surukle
	var bc := Vector2(float(game.wrap_system.f_boardCX(0)), float(game.wrap_system.f_boardCY()))
	drag(bc, bc - Vector2(0, 34)); step(10)
	check(w.state == "rolled", "yukari surukleyince durum sarilir (durum: %s)" % w.state)
	# kagit: kagit yiginini tutup durumun ustune birak
	drag(center("paper"), bc, 12); step(int(60 * (float(game.J.method(game.j_TUN, "paperTime", [game.j_G])) + 0.6)))
	check(w.state == "ready" and w.paper, "kagidi durumun ustune birakmak kagitlar (durum: %s)" % w.state)
	# servis: durumu al, musteriye tikla
	tap(bc); step(3)
	check(is_same(game.j_G.hand, w), "hazir duruma tiklamak ele alir")
	tap(Vector2(float(c.x), float(c.y) - 30.0)); step(5)
	check(c.done[0] and game.j_G.hand == null, "elde durumla musteriye tiklamak teslim eder")
	# para: yere dusen paraya tikla
	step(90)
	var once := float(game.j_G.money)
	for co in game.j_G.coins.duplicate():
		if co.landed: tap(Vector2(float(co.x), float(co.y) - 2.0))
	check(float(game.j_G.money) > once, "paralara tiklamak kasaya ekler (%s -> %s)" % [once, game.j_G.money])
	# klavye: R hizli kesim (basili tut)
	game.j_G.meat = 0
	key(KEY_R, true); step(150); key(KEY_R, false)
	check(float(game.j_G.meat) >= 3.0, "R basili tutmak doner keser (et: %s)" % game.j_G.meat)
	var et := float(game.j_G.meat)
	step(60)
	check(float(game.j_G.meat) == et, "R birakinca kesim durur")
	# P ve Esc duraklatir / devam ettirir
	tus(KEY_P); step(2)
	check(game.j_G.scene == "pause", "P duraklatir (sahne: %s)" % game.j_G.scene)
	tus(KEY_P); step(2)
	check(game.j_G.scene == "play", "P tekrar devam ettirir (sahne: %s)" % game.j_G.scene)
	tus(KEY_ESCAPE); step(2)
	check(game.j_G.scene == "pause", "Esc duraklatir (sahne: %s)" % game.j_G.scene)
	tus(KEY_ESCAPE); step(2)
	check(game.j_G.scene == "play", "Esc tekrar devam ettirir (sahne: %s)" % game.j_G.scene)
	# M ses
	var ses: bool = game.j_MUTED
	tus(KEY_M); step(2)
	check(game.j_MUTED != ses, "M sesi acar/kapatir")
	tus(KEY_M); step(2)
	# Tab / Q (yardim ekrani: "tahta degistir"): malzeme seciliyken hazirlama
	# tahtasini degistirir; baska nesnede sonraki nesneye gecer
	game.j_G.up["board"] = 1.0
	game.stations.select("spit", false)
	tus(KEY_TAB); step(2)
	check(game.stations.selected != "spit", "Tab donerden sonraki nesneye gecer (%s)" % game.stations.selected)
	game.stations.select("meat", false)
	var tahta := int(game.j_G.act)
	tus(KEY_TAB); step(2)
	check(int(game.j_G.act) != tahta and game.stations.selected == "meat", "malzeme seciliyken Tab tahta degistirir")
	tus(KEY_Q); step(2)
	check(int(game.j_G.act) == tahta, "Q onceki tahtaya doner")
	game.stations.select("bread", false)
	var bos: int = game.wrap_system.f_emptyBoard()
	tus(KEY_SPACE); step(4)
	check(bos >= 0 and game.j_G.boards[bos] is Dictionary, "Bosluk secili lavas yiginindan lavas acar")
	print("FARE AKISI ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
