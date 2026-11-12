# DIL CIFTLERI (birlesik surum, 6. tur madde 17): kodda (tr, en) cifti olarak
# yazilan metinler de/fr/es/pt'de sozlukten cevrilir, tr/en eskisi gibi.
#   godot --headless --path . --script tests/dil_cift.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/dil-cift-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	var beklenen := {"tr": "KAĞITLA", "en": "PAPER", "de": "EINWICKELN", "fr": "EMBALLER", "es": "ENVOLVER", "pt": "EMBRULHAR"}
	for dil in beklenen:
		game.localization.f_setLang(dil)
		check(game.order_text("KAĞITLA", "PAPER") == beklenen[dil], "siparis etiketi " + dil)
	game.localization.f_setLang("de")
	check(game.stations.text("Sar · basılı tut", "Roll · hold") == "Rollen · halten", "istasyon eylemi de")
	check(game.localization.cift("Sozlukte olmayan", "Missing") == "Missing", "sozlukte yoksa Ingilizce")
	# 11. tur: dolayli mesajlar (degiskenden gelen) ve kumanda ipucu fiilleri her dilde
	for dil in ["en", "de", "fr", "es", "pt"]:
		game.localization.f_setLang(dil)
		for k in ["Sarılmış ürüne malzeme eklenmez", "Turşu yeterli", "Turşu bitti — kutudan doldur!"]:
			check(game.localization.f_T(k) != k, "%s: '%s' cevrili" % [dil, k])
		for ad in game.stations.FIIL:
			var f: String = game.stations.fiil(ad)
			check(f != "" and f != "USE" and (f != game.stations.FIIL[ad][0] or ad in ["sos"]), "%s: ipucu fiili '%s' cevrili (%s)" % [dil, ad, f])
	for dil in ["de", "fr", "es", "pt"]:
		game.localization.f_setLang(dil)
		for cift in [["Kutuyu al", "Take box"], ["Kutuyu doldur", "Fill box"], ["Sarılmış", "Rolled"], ["Servise hazır", "Ready to serve"], ["Kağıtla", "Wrap in paper"], ["Kağıtla · basılı tut", "Wrap in paper · hold"], ["KONTROLLER", "CONTROLS"], ["EKRAN", "DISPLAY"], ["Çöpü boşalt", "Empty trash"]]:
			check(game.localization.cift(cift[0], cift[1]) != cift[1], "%s: '%s' Ingilizce kalmaz" % [dil, cift[0]])
	game.localization.f_setLang("tr")
	check(game.stations.fiil("al") == "AL" and game.stations.fiil("cevapla") == "AÇ", "Turkce ipucu fiilleri ayni")
	game.localization.f_setLang("en")
	check(game.stations.fiil("ekle") == "ADD" and game.stations.fiil("ac") == "OPEN", "Ingilizce ipucu fiilleri 'USE' degil")
	print("DIL CIFT ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
