# YAZI TASMASI (birlesik surum, 11. tur: yayin oncesi dil taramasi). Alti dilde
# butun pencereler ve kartlar cizilir; cizilen her yazi olculur:
#  K1) hicbir yazi ekranin (480x270) disina cikmaz
#  K2) dugme yazisi dugmesine sigar
#  K3) pencere icindeki yazi pencerenin kenarlarini asmaz
#  K4) ayni satirdaki iki yazi birbirinin ustune binmez (etiket / deger)
#  K5) Turkce'ye ozgu harf Turkce disi dilde gorunmez (cevrilmemis metin)
# Olcum text_draw.izle kayitlarindan yapilir (cizim koduyla ayni konum ve
# genislik); goruntu gerekmez, basliksiz calisir.
#   godot --headless --path . --script tests/yazi_tasma.gd --quit-after 3000 -- --test
#   ... -- --test --dil de        (tek dil)      ... -- --test --dok   (kayitlari yaz)
extends SceneTree
var game: Node
var failures: Array[String] = []
var gorulen := {}
var olculen := 0
var dok := false
const DILLER := ["tr", "en", "de", "fr", "es", "pt"]
const W := 480.0
const H := 270.0

func _initialize() -> void: call_deferred("run")

func arg(a: String, v: String = "") -> String:
	var u := OS.get_cmdline_user_args()
	var i := u.find(a)
	return u[i + 1] if i >= 0 and i + 1 < u.size() else v

func hata(dil: String, ekran: String, mesaj: String) -> void:
	var anahtar := dil + "|" + ekran + "|" + mesaj
	if gorulen.has(anahtar): return
	gorulen[anahtar] = true
	failures.append("%s / %s: %s" % [dil, ekran, mesaj])

# K5) Turkce'ye ozgu harfler (ğ ı İ ş Ş) baska dilde gorunuyorsa o metin
# cevrilmemis demektir; Ingilizcede bunlara ç ö ü â î û da girer (de/fr/es/pt'de
# ö ü ç gibi harfler yasal). "TR" disindaki her dilde calisir.
func tr_harf_kontrol(dil: String, ekran: String, yazi: String) -> void:
	if dil == "tr": return
	var yasak := "ğĞıİşŞ" + ("çÇöÖüÜâÂîÎûÛ" if dil == "en" else "")
	for ch in yazi:
		if yasak.contains(ch):
			hata(dil, ekran, "cevrilmemis (Turkce harf '%s'): '%s'" % [ch, yazi])
			return

func pencereler_kapali() -> void:
	for p in [game.j_CUSTOM, game.j_PAYP, game.j_BRP, game.j_SESP, game.j_STATS, game.j_BSP, game.j_EVP]:
		p.open = false
	game.j_BSP.sec = null
	game.j_SHOP.sec = null
	game.j_BSQ.kuyruk = []
	game.j_FT.clear()

func kur(gun: float, seviye: int, sehir: int = -1) -> void:
	pencereler_kapali()
	game.session_system.f_resetProgress()
	var G: Dictionary = game.j_G
	G.prologueSeen = true
	G.dersGorulmus = true
	for u in game.j_UPG: G.up[u.id] = float(mini(seviye, u.lv.size()))
	G.day = gun
	if sehir >= 0:
		G.branch = float(sehir + 1)
		game.branch_draw.f_sehreGit(float(sehir))
	game.f_startDay()
	G = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.hintT = 0
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	game.j_BSQ.kuyruk = []
	game.j_FT.clear()

# bir kare cizer, o karenin kayitlarini dondurur
func kare(once: int = 1) -> Array:
	for i in once: game.advance(1.0 / 60)
	game.j_BSQ.kuyruk = []
	game.text_draw.izle = []
	game.advance(1.0 / 60)
	var kayit: Array = game.text_draw.izle
	game.text_draw.izle = null
	return kayit

func olc(dil: String, ekran: String, once: int = 1) -> void:
	var kayit := kare(once)
	if dok: print("--- ", dil, " / ", ekran)
	var panel: Variant = null
	var satirlar: Array = []     # pencere icindeki yazilar (K4)
	var dugme_yazisi := false
	for k in kayit:
		if k.has("panel"):
			panel = k.panel; satirlar = []; dugme_yazisi = false
			continue
		if k.has("dugme"):
			olculen += 1
			var gen: float = float(game.f_textW(k.s))
			tr_harf_kontrol(dil, ekran, k.s)
			if gen > k.dugme.size.x - 2.0:
				hata(dil, ekran, "dugme yazisi sigmiyor: '%s' %d px > %d px" % [k.s, int(gen), int(k.dugme.size.x)])
			dugme_yazisi = true
			continue
		if dugme_yazisi:     # dugmenin kendi yazisi: yukarida olculdu
			dugme_yazisi = false
			continue
		if k.s == "$": continue     # hirsizin cantasi: ekran disindan girip cikar
		olculen += 1
		tr_harf_kontrol(dil, ekran, k.s)
		var x0: float = float(k.x)
		var x1: float = x0 + float(k.w)
		if dok: print("   %4d..%4d y%4d  %s" % [int(x0), int(x1), int(k.y), k.s])
		if x0 < 0.0 or x1 > W:
			hata(dil, ekran, "ekrandan tasiyor: '%s' x %d..%d" % [k.s, int(x0), int(x1)])
		if panel != null and float(k.y) >= panel.position.y - 8.0 and float(k.y) <= panel.end.y:
			if x0 < panel.position.x + 2.0 or x1 > panel.end.x - 2.0:
				hata(dil, ekran, "pencereden tasiyor: '%s' x %d..%d, pencere %d..%d" % [k.s, int(x0), int(x1), int(panel.position.x), int(panel.end.x)])
			for o in satirlar:
				# 2 px'ten az degme "etiket: deger" gibi bitisik yazidir; ayni yazi iki kez = golge
				if o.s != k.s and absf(float(o.y) - float(k.y)) < 7.0 and x0 < float(o.x) + float(o.w) - 2.0 and float(o.x) < x1 - 2.0:
					hata(dil, ekran, "ust uste: '%s' (%d..%d) ile '%s' (%d..%d)" % [o.s, int(o.x), int(o.x + o.w), k.s, int(x0), int(x1)])
			satirlar.append(k)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/yazi-tasma-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	dok = "--dok" in OS.get_cmdline_user_args()
	var diller: Array = DILLER if arg("--dil") == "" else [arg("--dil")]
	for dil in diller:
		game.localization.f_setLang(dil)
		game.controls.set_mode("mouse")
		baslik_ekrani(dil)
		oyun_ekrani(dil)
		dukkan_ekrani(dil)
		gun_sonu_ve_gece(dil)
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("YAZI TASMA ", JSON.stringify({"olculen": olculen, "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)

func baslik_ekrani(dil: String) -> void:
	pencereler_kapali()
	game.session_system.f_resetProgress()
	game.j_G.scene = "title"; game.j_G.sceneT = 5.0
	olc(dil, "baslik")
	game.j_SESP.open = true; olc(dil, "baslik ses"); game.j_SESP.open = false
	game.j_STATS.open = true; olc(dil, "baslik rekorlar"); game.j_STATS.open = false
	# basarimlar: her basarim secili (ad + aciklama seridi), kilitli ve acik
	game.j_BSP.open = true
	for acik in [false, true]:
		game.j_G.bs = {}
		if acik:
			for b in game.j_BASARIM: game.j_G.bs[b.id] = 12.0
		for b in game.j_BASARIM:
			game.j_BSP.sec = b.id
			olc(dil, "basarim %s%s" % [b.id, " (acik)" if acik else ""], 0)
	game.j_G.bs = {}
	pencereler_kapali()

func oyun_ekrani(dil: String) -> void:
	# gun basi karti: hava ve mac gunu cesitleri
	for hava in ["sun", "rain", "snow", "heat", "fog", "wind"]:
		for mac in [false, true]:
			kur(7.0, 1)
			game.session_system.f_goIntro()
			game.j_G.weather = hava
			game.j_G.macGun = mac
			game.j_G.sceneT = 5.0
			olc(dil, "gun basi %s%s" % [hava, " mac" if mac else ""])
	# ogretici adimlari, uc girdi aygitinda
	for kip in ["mouse", "touch", "controller"]:
		game.session_system.f_resetProgress()
		game.j_G.prologueSeen = true
		game.f_startDay()
		game.j_G.shutT = 0; game.j_G.spawnT = 100000
		game.controls.set_mode("mouse"); game.controls.set_mode(kip)
		for i in game.j_TUT.size():
			game.j_G.tut = float(i)
			olc(dil, "ogretici %d (%s)" % [i, kip], 1)
	game.controls.set_mode("mouse")
	# mola menusu
	kur(12.0, 3)
	game.j_G.scene = "pause"
	olc(dil, "mola")

func dukkan_ekrani(dil: String) -> void:
	kur(30.0, 0)
	var G: Dictionary = game.j_G
	G.money = 61000.0; G.branch = 3.0
	G.stats.wraps = 81234.0; G.stats.earned = 1964000.0; G.stats.days = 29.0; G.stats.lost = 365.0
	G.stats.isk = 9123.0; G.stats.drinks = 12345.0; G.stats.boxes = 8123.0; G.stats.sweets = 4123.0
	G.stats.best = 98765.0; G.stats.debtPaid = 1234567.0; G.stats.fines = 12345.0; G.stats.stolen = 23456.0
	G.scene = "shop"; G.sceneT = 5.0
	olc(dil, "dukkan")
	# gelistirme kartlari: her gelistirme, her seviye (kilitli / alinir / tam)
	for u in game.j_UPG:
		for lv in range(0, u.lv.size() + 1):
			for para in [0.0, 9999999.0]:
				for k in game.j_UPG: G.up[k.id] = 0.0
				if u.get("gerek") != null and lv > 0: G.up[u.gerek] = 1.0
				G.up[u.id] = float(lv)
				G.money = para
				game.j_SHOP.sec = u.id
				olc(dil, "kart %s sv%d%s" % [u.id, lv, "" if para > 0.0 else " (parasiz)"], 0)
	game.j_SHOP.sec = null
	G.money = 61000.0
	for k in game.j_UPG: G.up[k.id] = float(k.lv.size())
	# subeler: hic sube yokken, ara durumda, hepsi acikken
	for sube in [0.0, 3.0, float(game.j_BRANCH.size())]:
		G.branch = sube
		game.j_BRP.open = true
		olc(dil, "subeler %d" % int(sube))
		game.j_BRP.open = false
	G.branch = 3.0
	for borc in [5000000.0, 123456.0, 0.0]:
		G.debt = borc
		game.j_PAYP.open = true; olc(dil, "borc ode %d" % int(borc)); game.j_PAYP.open = false
		game.j_STATS.open = true; olc(dil, "rekorlar %d" % int(borc)); game.j_STATS.open = false
	G.debt = 5000000.0
	game.j_CUSTOM.open = true; olc(dil, "kisisellestir"); game.j_CUSTOM.open = false
	game.j_SESP.open = true; olc(dil, "dukkan ses"); game.j_SESP.open = false
	pencereler_kapali()

func gun_sonu_ve_gece(dil: String) -> void:
	kur(18.0, 2)
	var G: Dictionary = game.j_G
	G.stat.wraps = 121.0; G.stat.isk = 34.0; G.stat.drinks = 99.0; G.stat.boxes = 66.0; G.stat.sweets = 33.0
	G.stat.lost = 12.0; G.stat.yerYok = 117.0; G.stat.earned = 18400.0; G.stat.tips = 2120.0
	G.money = 18400.0
	game.session_system.f_endDay()
	game.j_G.sceneT = 5.0
	olc(dil, "gun sonu")
	# gece: hirsiz caldi / calamadi, guvenlik seviyeleri
	for caldi in [true, false]:
		for guvenlik in 4:
			kur(20.0, 1)
			G = game.j_G
			G.money = 900.0
			G.night = {"t": 5.0, "phase": 2.0, "stole": caldi, "amount": 12345.0, "sec": float(guvenlik), "line": game.j_LINES_THIEF_WIN[0] if caldi else game.j_LINES_THIEF_LOSE[0], "paid": true}
			G.scene = "night"; G.sceneT = 5.0
			olc(dil, "gece %s guvenlik %d" % ["caldi" if caldi else "kurtuldu", guvenlik])
