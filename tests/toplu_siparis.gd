# TOPLU SIPARIS (birlesik surum, 6. tur madde 12; kullanici: "toplu siparis:
# 4-5 durum, paket, yuksek odeme"). Telefon toplu calar -> acilinca N standart
# durum (+ bazen icecek) -> Dayi'ya verilince her urun paket ucretinin 1.4 kati.
#   godot --headless --path . --script tests/toplu_siparis.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func hazir(item: Dictionary) -> Dictionary:
	if item.kind == "wrap":
		return {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": null, "state": "ready",
			"paper": true, "grilled": game.J.truth(game.J.method(game.j_TUN, "grillOn", [game.j_G])), "burnt": false}
	return item.duplicate(true)

func teslim(p: Dictionary) -> float:
	for item in p.order.duplicate():
		game.j_G.hand = hazir(item)
		game.phone_system.f_giveToCourier()
	return float(game.j_G.courier.pay)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/toplu-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.j_G.up = {"phone": 1, "drink": 1}
	game.j_G.day = 6.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0
	var p: Dictionary = game.j_G.phone
	# normal paket: tek durumun odemesi (karsilastirma icin)
	p.state = "ring"; p.toplu = false
	game.phone_system.f_phoneClick()
	var tek_durum := 0.0
	for item in p.order:
		if item.kind == "wrap":
			game.j_G.hand = hazir(item); game.phone_system.f_giveToCourier()
			tek_durum = float(game.j_G.courier.pay)
			break
	# kurye bosalsin, yeni gun
	game.f_startDay(); game.j_G.tut = 99
	p = game.j_G.phone
	p.state = "ring"; p.toplu = true; p.topluN = 5.0
	game.phone_system.f_phoneClick()
	var durum := 0
	for item in p.order: if item.kind == "wrap": durum += 1
	check(durum == 5, "toplu sipariste 5 durum var (%d)" % durum)
	check(p.order.all(func(o): return o.kind != "wrap" or (o.get("yok") == null and o.get("sauce") == null)), "toplu durumlar standart")
	check(game.J.truth(p.toplu), "siparis toplu isaretli")
	game.draw_order_receipt(0.0)
	var odeme := teslim(p)
	var icecek := 0.0
	for item in p.order:
		if item.kind != "wrap": icecek += floor(float(game.recipe_system.f_itemPrice(item, game.j_G)) * game.j_PHONE_MUL * 1.4 + 0.5)
	check(absf(odeme - (5.0 * floor(tek_durum / game.j_PHONE_MUL * game.j_PHONE_MUL * 1.4 + 0.5) + icecek)) <= 6.0, "odeme 1.4 kat: %s (tek %s)" % [odeme, tek_durum])
	check(odeme > tek_durum * 5.0 * 1.3, "toplu odeme normal paketten belirgin yuksek")
	check(game.j_G.courier.state == "leaving", "hepsi verilince kurye yola cikar")
	check(not game.J.truth(game.j_G.phone.toplu), "teslimden sonra toplu isareti kalkar")
	# erken gunlerde toplu cikmaz
	game.j_G.day = 2.0
	var hic := true
	for i in 40:
		game.phone_system.f_topluKarar(game.j_G.phone)
		if game.J.truth(game.j_G.phone.toplu): hic = false
	check(hic, "5. gunden once toplu siparis yok")
	print("TOPLU ", JSON.stringify({"failures": failures, "odeme": odeme, "tek": tek_durum}))
	game.free(); quit(0 if failures.is_empty() else 1)
