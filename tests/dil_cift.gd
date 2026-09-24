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
	print("DIL CIFT ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
