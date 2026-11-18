# HAPTIK GERI BILDIRIM (birlesik surum, 12. tur, akicilik cilasi: "haptik geri bildirim henuz oyunda yok").
# Ses olaylari (j_SFX) titresim desenine de baglanir (core/haptics.gd); telefonda Input.vibrate_handheld, kolda
# Input.start_joy_vibration, masaustunde (fare / klavye) hicbir sey. Bu test GERCEK aygit olmadan, sahte arka uc ile olcer:
#  1) aygit yokken (fare) hicbir sey kuyruga girmez; dokunmatik / kol (cihaz secili) / arka uc varken aygit var
#  2) sarmalayici: ses AYNEN calisir (donus degeri dahil), desensiz sesler (yagmur, motor, korna ...) sarilmaz ve titremez
#  3) desenler: tek darbe hemen; cok darbeli desen bosluklarla zamanlanir (tick ile)
#  4) ayni ses adi 0,09 sn'den sik titretmez; ust uste binen desenler sirayla kuyruklanir, 0,30 sn'den fazla birikeni atilir
#  5) kullanici ayari kapaliyken titresim yok; ses etkilenmez
#  6) gercek oyun akisi: teslim edilen siparis "serve" ve "cash" titresimlerini uretir
#  7) cihaz ayari diske yazilir / okunur; arka plana giderken bekleyen darbeler iptal
#  8) Android cikis ayarinda VIBRATE izni acik (yoksa telefonda titresim sessizce calismaz)
#   godot --headless --path . --script tests/haptik.gd --quit-after 3000 -- --test
extends SceneTree
const Shell = preload("res://scripts/platform_shell.gd")
var game: Node
var failures: Array[String] = []
var darbeler: Array = []      # [ms, genlik]

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n: game.advance(1.0 / 60)

func sahte() -> void:
	darbeler = []
	game.haptics.backend = func(ms: int, genlik: float) -> void: darbeler.append([ms, genlik])

func temiz() -> void:
	game.haptics._kuyruk.clear()
	game.haptics._son.clear()
	game.haptics._bos = 0.0
	darbeler = []

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/haptik-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var H = game.haptics
	var J = game.J
	game.session_system.f_resetProgress(); game.j_G.prologueSeen = true; game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 100000; game.j_G.timeLeft = 100000
	# 1) aygit
	H.backend = Callable()
	game.controls.set_mode("mouse")
	check(not H.aygit_var(), "fare / klavye: titresim aygiti yok (masaustu sessiz)")
	J.method(game.j_SFX, "bad", [])
	check(H._kuyruk.is_empty(), "aygit yokken kuyruga hicbir sey girmez")
	game.controls.set_mode("touch")
	check(H.aygit_var(), "dokunmatik kip: aygit var")
	game.controls.set_mode("controller"); game.controls.device = -1
	check(not H.aygit_var(), "kol kipi ama cihaz secili degil: aygit yok")
	game.controls.device = 0
	check(H.aygit_var(), "kol kipi + cihaz 0: aygit var")
	game.controls.set_mode("mouse"); game.controls.device = -1
	# 2) sarmalayici: ses aynen calisir; desensiz sesler sarilmaz
	var sayac := {"ses": 0}
	var orijinal_yagmur := func(_a: Array = []) -> Variant: sayac.ses += 100; return "yagmur"
	var tablo := {"bad": func(_a: Array = []) -> Variant: sayac.ses += 1; return 42, "rain": orijinal_yagmur, "moto": orijinal_yagmur}
	H.bagla(tablo)
	sahte(); temiz()
	var donus: Variant = tablo["bad"].call([])
	check(donus == 42 and sayac.ses == 1, "sarmalanan ses aynen calisir, donus degeri korunur (%s / %d)" % [donus, sayac.ses])
	check(darbeler.size() == 1 and darbeler[0][0] == 26 and absf(darbeler[0][1] - 0.75) < 0.001, "ilk darbe hemen: bad -> 26 ms / 0.75 (%s)" % str(darbeler))
	check(is_same(tablo["rain"], orijinal_yagmur) and is_same(tablo["moto"], orijinal_yagmur), "desensiz sesler (yagmur, motor) sarilmaz")
	for ad in ["rain", "moto", "horn", "carPass", "steam", "footstep", "fry"]:
		check(not H.DESEN.has(ad), "ambiyans sesi titresmez: " + ad)
	# 3) cok darbeli desen tick ile zamanlanir: bad = 26 ms, 55 ms bosluk, 26 ms -> ikinci darbe ~81 ms sonra
	temiz()
	J.method(game.j_SFX, "bad", [])
	step(4)
	check(darbeler.size() == 1, "66 ms: ikinci darbe henuz yok (%d)" % darbeler.size())
	step(2)
	check(darbeler.size() == 2 and darbeler[1][0] == 26, "100 ms: ikinci darbe geldi (%s)" % str(darbeler))
	# 4) ayni ad 0.09 sn'den sik degil; sonra tekrar
	temiz()
	for i in 10: J.method(game.j_SFX, "pick", [])
	check(darbeler.size() == 1 and H._kuyruk.is_empty(), "ayni ses adi arka arkaya: tek darbe, kuyrukta birikme yok (%d, kuyruk %d)" % [darbeler.size(), H._kuyruk.size()])
	step(6)
	J.method(game.j_SFX, "pick", [])
	check(darbeler.size() == 2, "0.1 sn sonra yine titrer (%d)" % darbeler.size())
	# ust uste binen desenler sirayla; cok geriye giden atilir
	temiz()
	J.method(game.j_SFX, "levelup", [])
	J.method(game.j_SFX, "fanfare", [])
	var kuyruk_boy: int = H._kuyruk.size()
	J.method(game.j_SFX, "fail", [])
	check(H._kuyruk.size() == kuyruk_boy, "0.30 sn'den fazla geriye giden darbe atilir (kuyruk %d)" % H._kuyruk.size())
	step(40)
	var sira: Array = []
	for d in darbeler: sira.append(d[0])
	check(sira == [10, 12, 16, 14, 14, 26] and H._kuyruk.is_empty(), "levelup (3) + fanfare (3) sirayla kuyruklanip calindi, fail atildi (%s)" % str(sira))
	# 5) ayar kapali
	temiz()
	H.acik = false
	J.method(game.j_SFX, "bad", [])
	step(10)
	check(darbeler.is_empty() and H._kuyruk.is_empty(), "ayar kapaliyken titresim yok")
	H.acik = true
	# 6) gercek oyun akisi: teslim -> serve + cash titresimi
	temiz()
	game.j_G.up = {}
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state = "wait"; c.x = c.tx; c.items = [{"kind": "wrap"}]; c.done = [false]; c.earn = 0; c.patience = 0.9; c.homeless = false; c.mad = false
	game.j_G.hand = {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": null, "state": "ready", "paper": true, "grilled": false, "burnt": false}
	game.f_deliver(c)
	step(30)
	var ms_listesi: Array = []
	for d in darbeler: ms_listesi.append(d[0])
	check(14 in ms_listesi and 10 in ms_listesi and 12 in ms_listesi, "teslim: serve (14 ms) ve cash (10 + 12 ms) titresimleri (%s)" % str(ms_listesi))
	# 7) cihaz ayari: diske yazilir / okunur
	var yol := "user://haptik-test.cfg"
	var kabuk = Shell.new()
	kabuk.game = game
	kabuk.settings_path = yol
	H.acik = false
	kabuk.save_preferences()
	H.acik = true
	kabuk.load_preferences()
	check(H.acik == false, "kapali ayar kaydedilip okunur")
	H.acik = true
	kabuk.save_preferences()
	H.acik = false
	kabuk.load_preferences()
	check(H.acik == true, "acik ayar kaydedilip okunur")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(yol))
	kabuk.load_preferences()      # dosya yok: varsayilan acik
	check(H.acik == true, "ayar dosyasi yoksa varsayilan: acik")
	kabuk.free()
	Engine.max_fps = 0
	# 8) Android: titresim izni cikis ayarinda ACIK olmali (izin yoksa vibrate_handheld sessizce hicbir sey yapmaz)
	var cfg := ConfigFile.new()
	check(cfg.load("res://export_presets.cfg") == OK, "export_presets.cfg okunur")
	var android_bulundu := false
	for bolum in cfg.get_sections():
		if cfg.has_section_key(bolum, "platform") and str(cfg.get_value(bolum, "platform")) == "Android":
			android_bulundu = true
			check(bool(cfg.get_value(bolum + ".options", "permissions/vibrate", false)), "Android cikis ayarinda VIBRATE izni acik")
	check(android_bulundu, "Android cikis ayari var")
	# arka plana giderken bekleyen darbeler iptal
	temiz()
	J.method(game.j_SFX, "bad", [])
	check(not H._kuyruk.is_empty(), "bad ikinci darbesi bekliyor")
	game.f_appPause()
	check(H._kuyruk.is_empty(), "arka plana giderken bekleyen darbeler iptal edilir")
	# gercek aygit yolu hata vermez (masaustunde etkisiz): dokunmatik kip + arka uc yok
	H.backend = Callable()
	game.controls.set_mode("touch")
	J.method(game.j_SFX, "levelup", [])
	step(30)
	# kol yolu: cihaz yokken (masaustu, baglanti yok) Input.start_joy_vibration guvenle etkisiz kalir
	game.controls.set_mode("controller"); game.controls.device = 0
	J.method(game.j_SFX, "fanfare", [])
	step(30)
	check(H._kuyruk.is_empty(), "kol yolu: darbeler hata vermeden bosalir")
	game.controls.set_mode("mouse"); game.controls.device = -1
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("HAPTIK ", JSON.stringify({"desen": H.DESEN.size(), "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
