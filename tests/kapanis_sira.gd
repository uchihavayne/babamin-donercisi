# KAPANIS + KAPIDA SIRA (birlesik surum, 9. tur genel test bulgulari):
#  1) son 15 sn yeni musteri gelmez; sure dolunca icerideki musteriler servis
#     edilene ya da sabri tukenene kadar gun surer, kapidaki sira gider
#  2) yer yokken gelen musteri kapida bekler (en fazla 3), yer acilinca girer,
#     beklemekten sikilinca "YER YOK" deyip gider; gun sonunda "kapidan donen"
#   godot --headless --path . --script tests/kapanis_sira.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n := 1) -> void:
	for i in n: game.advance(1.0 / 60)

func fresh(up := {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.j_G.day = 6.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 10000; game.j_G.timeLeft = 100
	game.j_G.customers = []
	game.j_G.inspect = null; game.j_G.kedi = null; game.j_G.rakip = null; game.j_G.kesinti = null

func bekleyen(items := [{"kind": "wrap", "sauce": null}], sabir := 0.9) -> Dictionary:
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state = "wait"; c.x = c.tx; c.items = items; c.done = []; c.patience = sabir
	for i in items: c.done.append(false)
	return c

func sira() -> Array: return game.customer_system.sira_musterileri()

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/kapanis-sira-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	# 1a) son 15 saniyede musteri gelmez
	fresh()
	game.j_G.timeLeft = 14.0; game.j_G.spawnT = 0.01
	step(60)
	check(game.j_G.customers.is_empty(), "son 15 sn yeni musteri gelmez")
	game.j_G.timeLeft = 20.0; game.j_G.spawnT = 0.01
	step(5)
	check(game.j_G.customers.size() == 1, "sure varken musteri gelir")
	# 1b) sure dolunca iceride bekleyen varsa gun bitmez; servis edilince biter
	fresh()
	var c := bekleyen()
	game.j_G.timeLeft = 0.05
	step(10)
	check(game.j_G.scene == "play" and game.j_G.kapanis is Dictionary, "sure doldu ama bekleyen musteri var: kapanis (sahne %s)" % game.j_G.scene)
	game.j_G.hand = {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": null, "state": "ready", "paper": true, "grilled": false, "burnt": false}
	game.f_deliver(c)
	step(10)
	check(game.j_G.scene == "dayend" and float(game.j_G.stat.wraps) == 1.0, "son musteri servis edilince gun biter (sahne %s)" % game.j_G.scene)
	# 1c) servis edilmeyen musterinin sabri tukenir, kacan sayilir, gun biter
	fresh()
	c = bekleyen([{"kind": "wrap", "sauce": null}], 0.05)
	c.patMax = 1.0
	game.j_G.timeLeft = 0.05
	step(120)
	check(game.j_G.scene == "dayend" and float(game.j_G.stat.lost) == 1.0, "kapanista bekletilen musteri gider, kacan 1 (sahne %s, kacan %s)" % [game.j_G.scene, game.j_G.stat.lost])
	# 1d) kapanis en fazla 45 sn surer
	fresh()
	c = bekleyen([{"kind": "wrap", "sauce": null}], 1.0)
	c.patMax = 9999.0
	game.j_G.timeLeft = 0.05
	step(60 * 44)
	check(game.j_G.scene == "play", "kapanis 44. sn'de suruyor")
	step(60 * 2)
	check(game.j_G.scene == "dayend", "kapanis 45 sn sinirinda biter")
	# 2a) iki yer dolu: ucuncu musteri kapida sirada bekler
	fresh()
	bekleyen(); bekleyen()
	game.customer_system.f_spawnCustomer()
	var s1: Dictionary = game.j_G.customers.back()
	check(s1.state == "sira" and int(s1.slot) == -1, "yer yokken gelen musteri sirada (durum %s)" % s1.state)
	step(90)
	check(absf(float(s1.x) - game.customer_system.sira_x(0)) < 1.0 and float(s1.bubble) == 0.0, "sira kaldirimda kapinin onunde bekler, siparis balonu yok (x %s)" % s1.x)
	# 2b) sira en fazla 3; dorduncu gelen hic girmez, kapidan donen sayilir
	game.customer_system.f_spawnCustomer(); game.customer_system.f_spawnCustomer()
	var n: int = game.j_G.customers.size()
	game.customer_system.f_spawnCustomer()
	check(sira().size() == 3 and game.j_G.customers.size() == n and float(game.j_G.stat.yerYok) == 1.0, "sira 3 kisi; fazlasi kapidan doner (%s)" % game.j_G.stat.yerYok)
	# 2c) bir yer bosalinca siranin ilki girer
	var giden: Dictionary = game.j_G.customers[0]
	var yer := int(giden.slot)
	giden.state = "leave"
	step(2)
	check(s1.state == "walkin" and int(s1.slot) == yer and float(s1.x) > 470.0, "yer acilinca siranin ilki kapidan girer (durum %s, yer %s)" % [s1.state, s1.slot])
	step(240)
	check(s1.state == "wait", "siradan giren siparis verir (durum %s)" % s1.state)
	check(absf(float(sira()[0].x) - game.customer_system.sira_x(0)) < 1.0, "sira bir adim one kayar")
	# 2d) siradakiler beklemekten sikilip gider
	step(int(60 * (game.customer_system.SIRA_SURE + 1.0)))
	check(sira().is_empty() and float(game.j_G.stat.yerYok) == 3.0, "sabirsiz sira gider (kapidan donen %s)" % game.j_G.stat.yerYok)
	step(60 * 12)
	var kalan := 0
	for g in game.j_G.customers:
		if g.state == "sira_git": kalan += 1
	check(kalan == 0, "gidenler kaldirimdan cikip listeden silinir")
	check(float(game.j_G.stat.lost) == 0.0, "kapidan donenler kacan sayilmaz")
	# 2e) kepenk inince kapidaki sira gider, iceridekiler kalir
	fresh()
	bekleyen(); bekleyen()
	game.customer_system.f_spawnCustomer()
	game.j_G.timeLeft = 0.05
	step(5)
	check(sira().is_empty() and float(game.j_G.stat.yerYok) == 1.0 and game.j_G.scene == "play", "kapanista sira dagilir, icerisi servis bekler")
	print("KAPANIS SIRA ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
