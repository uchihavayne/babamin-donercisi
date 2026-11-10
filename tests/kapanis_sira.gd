# KAPANIS + KAPIDA SIRA (birlesik surum, 9. tur genel test bulgulari; 10. tur
# kullanici geri bildirimi):
#  1) son 15 sn yeni musteri gelmez; sure dolunca icerideki musteriler servis
#     edilene ya da sabri tukenene kadar gun surer, kapidaki sira gider
#  2) yer yokken gelen musteri camin disinda bekler (en fazla 3): siranin
#     arkasindaki seritten gelir, camin dibinde durur; yer acilinca kapiya
#     yuruyup girer, beklemekten sikilinca yazisiz / sessizce gider; gun
#     sonunda "kapidan donen". Lider gelince sira dagilir (sayilmaz).
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
	# patMax buyuk: uzun sira senaryosunda icerideki sabri tukenip kacan sayilmasin
	c.state = "wait"; c.x = c.tx; c.items = items; c.done = []; c.patience = sabir; c.patMax = 9999.0
	for i in items: c.done.append(false)
	return c

func sira() -> Array: return game.customer_system.sira_musterileri()

# ekrandaki ucan yazilar (musteri ayrilirken hicbiri olmamali)
func yazilar() -> Array:
	var out: Array = []
	for f in game.j_FT: out.append(str(f.s))
	return out

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/kapanis-sira-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var CS = game.customer_system
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
	# 2a) iki yer dolu: ucuncu musteri camin disinda sirada bekler
	fresh()
	bekleyen(); bekleyen()
	game.customer_system.f_spawnCustomer()
	var s1: Dictionary = game.j_G.customers.back()
	check(s1.state == "sira" and int(s1.slot) == -1, "yer yokken gelen musteri sirada (durum %s)" % s1.state)
	check(is_equal_approx(float(s1.sy), CS.yol_y()) and float(s1.x) > CS.sira_x(0), "gelen kapi tarafindan, siranin arkasindaki seritten yurur")
	step(180)
	check(absf(float(s1.x) - CS.sira_x(0)) < 1.0 and is_equal_approx(float(s1.sy), CS.sira_y()) and float(s1.bubble) == 0.0,
		"sira camin dibinde bekler, siparis balonu yok (x %s, y %s)" % [s1.x, s1.sy])
	check(not s1.yurur and float(s1.yon) > 0.0, "sirada ayakta, kapiya donuk durur")
	# 2b) sira en fazla 3; dorduncu gelen hic girmez, kapidan donen sayilir
	game.customer_system.f_spawnCustomer(); game.customer_system.f_spawnCustomer()
	var n: int = game.j_G.customers.size()
	game.customer_system.f_spawnCustomer()
	check(sira().size() == 3 and game.j_G.customers.size() == n and float(game.j_G.stat.yerYok) == 1.0, "sira 3 kisi; fazlasi kapidan doner (%s)" % game.j_G.stat.yerYok)
	# 2c) bir yer bosalinca siranin ilki kapiya yurur (yeri ayrilir), kapida girer
	var giden: Dictionary = game.j_G.customers[0]
	var yer := int(giden.slot)
	giden.state = "leave"
	step(2)
	check(s1.state == "sira_gir" and int(s1.slot) == yer and not CS.bos_yerler().has(yer), "yer acilinca siranin ilki kapiya yurur, yer ona ayrilir (durum %s, yer %s)" % [s1.state, s1.slot])
	check(CS.sokakta(s1) and float(s1.x) < CS.kapi_x(), "kapiya varana dek sokakta yurur (x %s)" % s1.x)
	for i in 120:
		step()
		if s1.state != "sira_gir": break
	check(s1.state == "walkin" and int(s1.slot) == yer and float(s1.x) > 470.0, "kapiya varinca kapidan iceri girer (durum %s, x %s)" % [s1.state, s1.x])
	step(240)
	check(s1.state == "wait", "siradan giren siparis verir (durum %s)" % s1.state)
	check(absf(float(sira()[0].x) - CS.sira_x(0)) < 1.0, "sira bir adim one kayar")
	# 2d) siradakiler beklemekten sikilip yazisiz, sessizce gider
	game.j_FT.clear()
	var git_serit := false
	for i in int(60 * (CS.SIRA_SURE + 1.0)):
		step()
		for g in game.j_G.customers:
			if g.state == "sira_git" and is_equal_approx(float(g.sy), CS.yol_y()): git_serit = true
	check(sira().is_empty() and float(game.j_G.stat.yerYok) == 3.0, "sabirsiz sira gider (kapidan donen %s)" % game.j_G.stat.yerYok)
	check(yazilar().is_empty(), "siradan ayrilan icin ekrana yazi cikmaz (%s)" % [yazilar()])
	check(git_serit, "giden siranin arkasindaki seride gecip yurur")
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
	check(yazilar() == ["SON MÜŞTERİLER"], "kapanista yalniz kepenk yazisi (%s)" % [yazilar()])
	# 2e') kapiya yuruyen varken sure dolarsa o da doner; baska bekleyen yoksa gun biter
	fresh()
	bekleyen(); bekleyen()
	game.customer_system.f_spawnCustomer()
	var s2: Dictionary = game.j_G.customers.back()
	step(10)
	game.j_G.customers[0].state = "leave"; game.j_G.customers[1].state = "leave"
	step(2)
	check(s2.state == "sira_gir", "kapiya yuruyor (durum %s)" % s2.state)
	game.j_G.timeLeft = 0.05
	step(3)
	check(s2.state == "sira_git" and int(s2.slot) == -1 and float(game.j_G.stat.yerYok) == 1.0, "kapanista kapiya yuruyen de doner (durum %s)" % s2.state)
	step(5)
	check(game.j_G.scene == "dayend", "iceride kimse yoksa gun biter (sahne %s)" % game.j_G.scene)
	# 2f) lider gelince iceridekiler gibi kapidaki sira da dagilir, sayilmaz
	fresh()
	bekleyen(); bekleyen()
	game.customer_system.f_spawnCustomer(); game.customer_system.f_spawnCustomer()
	step(10)
	var siradakiler := sira()
	game.j_G.ferman = {"liste": [], "ceza": 0.0, "kapandi": false, "kagit": 0.0, "kagitT": 0.0, "kayit": [], "kacan": 0.0}
	game.j_G.lider = {"state": "bekle", "t": 0.0, "x": game.j_W + 40.0, "y": 152.0, "tx": 250.0, "sabir": 1.0, "istek": null, "sonuc": null}
	game.leader_system.f_updateLider(1.0 / 60)
	var hepsi_gitti := siradakiler.size() == 2
	for g in siradakiler: hepsi_gitti = hepsi_gitti and g.state == "sira_git"
	check(hepsi_gitti and sira().is_empty() and float(game.j_G.stat.yerYok) == 0.0, "lider gelince sira dagilir, kapidan donen sayilmaz (%s)" % game.j_G.stat.yerYok)
	CS.sira_guncelle(1.0 / 60)
	var giren := 0
	for g in game.j_G.customers:
		if g.state in ["sira_gir", "walkin"]: giren += 1
	check(giren == 0, "lider varken bosalan yere kimse girmez")
	# 2g) yerlesim: sira her yer duzeninde (Dukkani Buyut son seviyesi, 5 yer)
	#     iki musterinin arasinda gorunur; cop kutusu siranin onunde degil
	var S: Array = game.j_LAY.custSlots
	var M: Dictionary = game.street_background.f_stM()
	check(CS.sira_x(0) + 4.0 <= float(S[4].x) - 14.0 and CS.sira_x(CS.SIRA_MAX - 1) - 4.0 >= float(S[3].x) + 14.0, "sira son iki musteri yerinin arasinda")
	check(float(M.gx) + game.street_draw.COP_X + 13.0 < CS.sira_x(CS.SIRA_MAX - 1) - 4.0, "cop kutusu siranin onunde degil")
	check(CS.sira_y() > CS.yol_y(), "sira camin dibinde, yol arkasinda")
	print("KAPANIS SIRA ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
