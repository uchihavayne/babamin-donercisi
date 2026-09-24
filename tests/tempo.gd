# TEMPO (birlesik surum, 6. tur analiz madde 10): uzun vadeli ekonomi.
# Gercek siparis uretimi (f_makeOrder), fiyat (f_itemPrice), gun sonu
# (f_endDay: sube geliri + %18 borc kesintisi), yukseltme alimi
# (upgrade_system.buy) ve sube fiyatlari/kosullari. Oyuncu modeli: gunun
# gelen musterilerinin ((len - 25) / rate, dayCfg) "beceri" kadarina yetisir,
# gerisi kacar. Alim: once acilabilen sube, sonra en ucuz yukseltme seviyesi.
# Telefon/Dayi geliri, bahsis, olaylar, cezalar yok (temkinli tahmin).
#   godot --headless --path . --script tests/tempo.gd --quit-after 100000 -- --test [--gun 200]
extends SceneTree
const J = preload("res://scripts/js_compat.gd")
var game: Node

func _initialize() -> void: call_deferred("run")

func arg(ad: String, v: String) -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else v

func gun_oyna(beceri: float) -> void:
	var G: Dictionary = game.j_G
	game.f_startDay()
	G.weather = "sun"; G.ferman = null; G.lider = null
	var cfg: Dictionary = G.cfg
	var gelen := int(floor((float(cfg.len) - 25.0) / float(cfg.rate)))
	var servis := int(round(gelen * beceri))
	var izgara := J.truth(J.method(game.j_TUN, "grillOn", [G]))
	var ciro := 0.0
	for i in servis:
		for it in game.recipe_system.f_makeOrder(G):
			var f: Variant = it
			if it.kind == "wrap": f = {"kind": "wrap", "grilled": izgara, "sauce": it.get("sauce")}
			ciro += float(game.recipe_system.f_itemPrice(f, G))
	G.money += ciro
	G.stat.earned = ciro
	G.stat.wraps = float(servis)
	G.stat.lost = float(gelen - servis)
	game.session_system.f_endDay()

var biriktir := false   # true: sube acilabiliyorsa yukseltme almadan ona biriktir

func alisveris() -> Array:
	var G: Dictionary = game.j_G
	G.scene = "shop"
	var alinan: Array = []
	# sube
	var n := int(J.n(G.get("branch", 0)))
	var hedef := 0.0
	if n < game.j_BRANCH.size():
		var b: Dictionary = game.j_BRANCH[n]
		if not J.truth(game.progression_system.f_branchLocked(n, G)):
			if G.money >= b.p:
				G.money -= b.p
				G.branch = float(n + 1)
				alinan.append("SUBE:" + str(b.name))
			elif biriktir:
				hedef = b.p
	# yukseltmeler: en ucuz seviye, para yettikce
	while true:
		var en: Variant = null
		var en_fiyat := INF
		for u in game.j_UPG:
			var p: Variant = game.upgrade_system.price(u)
			if p == null: continue
			if u.has("gerek") and int(G.up.get(u.gerek, 0)) <= 0: continue
			if float(p) < en_fiyat:
				en_fiyat = float(p); en = u
		if en == null or G.money - en_fiyat < hedef or not game.upgrade_system.buy(en.id): break
		alinan.append(en.id)
	return alinan

func simule(beceri: float, gunler: int) -> Dictionary:
	game.session_system.f_resetProgress()
	game.j_G.branch = 0.0
	var sonuc := {"sube": {}, "borc_bitti": -1, "ilk_alim": -1, "para": {}, "seviye": {}}
	for d in range(1, gunler + 1):
		game.j_G.day = float(d)
		gun_oyna(beceri)
		var borc_once := float(game.j_G.debt)
		var alinan := alisveris()
		if sonuc.ilk_alim < 0 and not alinan.is_empty(): sonuc.ilk_alim = d
		for a in alinan:
			if str(a).begins_with("SUBE:"): sonuc.sube[str(a).substr(5)] = d
		if sonuc.borc_bitti < 0 and borc_once <= 0.0: sonuc.borc_bitti = d
		if d in [10, 20, 30, 45, 60, 90, 120, 150, 200]:
			sonuc.para[d] = int(game.j_G.debt)
			sonuc.seviye[d] = int(J.n(game.equipment_system.f_upgTotalLv(game.j_G)))
	return sonuc

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/tempo-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var gunler := int(arg("--gun", "200"))
	var toplam_seviye := 0
	for u in game.j_UPG: toplam_seviye += u.lv.size()
	print("TEMPO toplam yukseltme seviyesi: %d, sube: %d" % [toplam_seviye, game.j_BRANCH.size()])
	for kip in [false, true]:
		biriktir = kip
		print("TEMPO --- alim kurali: %s" % ("subeye biriktir" if kip else "en ucuz yukseltme"))
		for beceri in [0.55, 0.7, 0.85]:
			tek(beceri, gunler)
	game.free(); quit(0)

func tek(beceri: float, gunler: int) -> void:
	var s := simule(beceri, gunler)
	print("TEMPO beceri %.2f  ilk alim: gun %d  borc bitti: gun %s" % [beceri, s.ilk_alim, str(s.borc_bitti) if s.borc_bitti > 0 else "yok (%d gunde)" % gunler])
	print("  subeler: ", JSON.stringify(s.sube))
	print("  kalan borc: ", JSON.stringify(s.para))
	print("  seviye:     ", JSON.stringify(s.seviye))
