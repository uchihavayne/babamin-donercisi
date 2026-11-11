# CILA (birlesik surum, 11. tur: yayin oncesi ekran taramasi). Taramada bulunup
# duzeltilen kusurlarin geri gelmemesi icin:
#  1) Yeni Oyun tabelayi ilk acilistaki varsayilana dondurur (eskiden null:
#     Kisisellestir penceresi "null" gosteriyordu)
#  2) mufettis musterilerin ustune binmez (bos yer / iki yerin arasi)
#  3) cop kutusu etiketi gercekte olacak isi soyler; dort dilde cevirisi var
#  4) uzun metin "maxw" ile sigdirilir (sube aciklamalari, gun basi karti)
#  5) kapida sorgulanan musteri (Demirkent) eski yerini tutmaz
#  6) basarim bildirimi pencereler acikken bekler
#   godot --headless --path . --script tests/cila.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func fresh(up := {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.j_G.day = 6.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 10000; game.j_G.timeLeft = 100
	game.j_G.customers = []
	game.j_G.inspect = null; game.j_G.kedi = null; game.j_G.rakip = null; game.j_G.kesinti = null

func cop_etiketi() -> String:
	game.stations.refresh()
	game.stations.select("trash")
	for a in game.stations.actions():
		if a.id == "trash": return a.label
	return ""

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/cila-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	game.controls.set_mode("controller")
	# 1) yeni oyun: tabela varsayilani
	game.j_G.custom = {"sign": "BENIM YERIM", "sub": "", "poster": 0.0, "counter": 2.0}
	game.session_system.f_resetProgress()
	var c: Variant = game.j_G.custom
	check(c is Dictionary and c.sign == "USTA DÖNER" and c.sub == "EFSANE LEZZET" and float(c.poster) == 1.0 and float(c.counter) == 0.0,
		"yeni oyun tabelayi varsayilana dondurur (%s)" % [c])
	game.session_system.f_resetProgress()
	check(not is_same(c, game.j_G.custom), "her yeni oyun kendi tabela sozlugunu alir")
	# 2) mufettis: bos yerde, 5 yerli dukkanda iki yerin arasinda
	var S: Array = game.j_LAY.custSlots
	for seviye in 4:
		fresh({"expand": float(seviye)})
		var n := int(game.j_G.cfg.slots)
		var x: float = game.event_system.mufettis_x()
		var en_yakin := 999.0
		for i in n: en_yakin = minf(en_yakin, absf(x - float(S[i].x)))
		check(en_yakin >= 30.0 and x > float(S[0].x) and x < float(S[S.size() - 1].x) + 1.0,
			"mufettis %d yerli dukkanda musteriye binmez (x %s, en yakin %s)" % [n, x, en_yakin])
	# 3) cop kutusu etiketi = f_trashClick'in yapacagi is
	fresh()
	check(game.event_system.cop_eylemi() == "bos" and cop_etiketi() == "Çöpü boşalt", "bos kova: Çöpü boşalt")
	game.j_G.trash = 0.4
	check(game.event_system.cop_eylemi() == "bosalt" and cop_etiketi() == "Çöpü boşalt", "dolu kova: Çöpü boşalt")
	game.f_newWrap()
	check(game.event_system.cop_eylemi() == "tezgah" and cop_etiketi() == "Tezgâhtakini at", "tezgahta urun: Tezgâhtakini at (%s)" % cop_etiketi())
	game.event_system.f_trashClick()
	check(game.j_G.boards[0] == null and float(game.j_G.trash) > 0.4, "etiketin dedigi olur: tezgahtaki atilir, kova bosalmaz")
	game.j_G.hand = {"kind": "drink", "type": "cola"}
	check(game.event_system.cop_eylemi() == "el" and cop_etiketi() == "Eldekini at", "elde urun: Eldekini at")
	game.j_G.hand = null
	game.j_G.grill.slots.append({"w": {"kind": "wrap", "state": "rolled", "burnt": true}, "t": 9.0, "dur": 8.0, "done": true, "yan": 9.0})
	check(game.event_system.cop_eylemi() == "yanik", "izgarada yanmis durum: once o atilir")
	for dil in ["de", "fr", "es", "pt"]:
		var d: Dictionary = game.j_SOZLUK[dil]
		for k in ["Eldekini at", "Çöpü boşalt", "Yanmış dürümü at", "Tezgâhtakini at"]:
			check(d.has(k), "%s sozlugunde '%s' var" % [dil, k])
	# 4) uzun metin sigdirilir
	var TD = game.text_draw
	check(TD.kisalt("kisa", 200.0) == "kisa", "sigan metin degismez")
	var uzun := "La couronne de la chaîne. Du doner dans la ville qui ne dort jamais."
	var k2: String = TD.kisalt(uzun, 120.0)
	check(k2.ends_with("…") and float(game.f_textW(k2)) <= 120.0 and uzun.begins_with(k2.trim_suffix("…")), "tasan metin kisalir (%s)" % k2)
	for dil in ["tr", "en", "de", "fr", "es", "pt"]:
		game.localization.f_setLang(dil)
		for b in game.j_BRANCH:
			var m: String = TD.kisalt(str(game.localization.f_T(b.desc)), 432.0 - 156.0)
			check(float(game.f_textW(m)) <= 276.0, "%s sube aciklamasi sutuna sigar: %s" % [dil, m])
	game.localization.f_setLang("tr")
	# 5) sorgu: kapidaki musteri eski yerini tutmaz
	fresh()
	game.customer_system.f_spawnCustomer()
	var m1: Dictionary = game.j_G.customers[0]
	var yer := int(m1.slot)
	m1.state = "sorgu"
	check(game.customer_system.bos_yerler().has(yer), "sorgudaki musterinin yeri bos sayilir")
	game.customer_system.f_spawnCustomer(); game.customer_system.f_spawnCustomer()
	var icerde := 0
	for g in game.j_G.customers:
		if g.state == "walkin": icerde += 1
	check(icerde == 2 and game.customer_system.sira_musterileri().is_empty(), "sorgu surerken iki yer de dolabilir (%d)" % icerde)
	# 6) basarim bildirimi: pencere acikken bekler
	var bildirim := {"b": game.j_BASARIM[0], "t": 0.0}
	game.j_BSQ.kuyruk = [bildirim]
	for pencere in [game.j_BRP, game.j_PAYP, game.j_CUSTOM, game.j_EVP]:
		pencere.open = true
		game.achievement_draw.f_drawBasarimToast(0.0, 0.5)
		check(float(bildirim.t) == 0.0 and game.j_BSQ.kuyruk.size() == 1, "pencere acikken bildirim beklemede")
		pencere.open = false
	game.achievement_draw.f_drawBasarimToast(0.0, 0.5)
	check(float(bildirim.t) > 0.0, "pencere kapaninca bildirim ilerler")
	game.j_BSQ.kuyruk = []
	print("CILA ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
