# BAHIS HEDEFLERI (birlesik surum, 11. tur, kullanici karari "hedefler son 3 gune gore"):
#  1) gecmis yokken eski gun formulleri gecerli (10. gun: 8 durum / $420 / $90 bahsis)
#  2) hedef = son 3 gunun ortalamasinin %110'u (durum 1, para 10, bahsis 5 adimiyla
#     yuvarlanir); tabanlar 4 / $100 / $10; gecmiste 1-2 gun varsa onlarin ortalamasi
#  3) f_bahisGunuKaydet: yalniz son 3 gun tutulur, "kazanc" = earned - branch
#  4) gun sonu (f_endDay) gecmise TAM BIR kayit ekler; kayit / yukleme / sifirlama
#     gecmisi korur (eski kayitta alan yoksa bos)
#  5) "musteri kacirirsin" bahsi: son gunlerde hic musteri kacmadiysa baska tur secilir
#     (rastgele sayi tuketmeden); kacmissa ya da gecmis yoksa secilebilir
#  6) rakip teklifi (f_rakipGunBasi) hedefi gecmisten alir; kabul edilen bahsin hedefi
#     sabittir (gunun icinde degismez) ve f_bahisCoz onunla karsilastirir
#   godot --headless --path . --script tests/bahis_hedef.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []
const YOL := "res://artifacts/bahis-hedef-save.json"

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func yeni_oyun() -> Node:
	var g: Node = load("res://scripts/platform_game.gd").new()
	g.storage.path = YOL
	root.add_child(g); g.set_process(false); g.j_MUTED = true
	g.localization.f_setLang("tr")
	return g

func gun_kur(day: float) -> void:
	game.session_system.f_resetProgress()
	game.j_G.day = day
	game.j_G.prologueSeen = true
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 10000; G.timeLeft = 10000
	G.customers = []
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null

func tip(id: String) -> Dictionary:
	for t in game.j_BAHIS:
		if t.id == id: return t
	return {}

func hedef(id: String) -> float:
	return float(tip(id).hedef.call([game.j_G]))

func kayit(w: float, k: float, b: float, c: float) -> Dictionary:
	return {"wraps": w, "kazanc": k, "bahsis": b, "kacan": c}

func run() -> void:
	game = yeni_oyun()
	game.storage.values = {}
	var RS = game.rival_system

	# 1) gecmis yok -> eski formuller (davranis degismez)
	gun_kur(10.0)
	check(game.j_G.bahisGecmis is Array and game.j_G.bahisGecmis.is_empty(), "yeni oyun: gecmis bos (%s)" % str(game.j_G.get("bahisGecmis")))
	check(hedef("durum") == 8.0, "10. gun, gecmis yok: durum 8 (%s)" % hedef("durum"))
	check(hedef("para") == 420.0, "10. gun, gecmis yok: para 420 (%s)" % hedef("para"))
	check(hedef("bahsis") == 90.0, "10. gun, gecmis yok: bahsis 90 (%s)" % hedef("bahsis"))
	game.j_G.day = 30.0
	check(hedef("durum") == 13.0 and hedef("para") == 940.0 and hedef("bahsis") == 210.0,
		"30. gun, gecmis yok: 13 / 940 / 210 (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	game.j_G.day = 10.0

	# 2) hedef = son 3 gunun ortalamasi x 1,10
	game.j_G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	check(hedef("durum") == 13.0, "ort. 12 durum -> 13 (13,2 yuvarlanir) (%s)" % hedef("durum"))
	check(hedef("para") == 370.0, "ort. $340 -> $370 (374 -> 10'a yuvarlanir) (%s)" % hedef("para"))
	check(hedef("bahsis") == 30.0, "ort. $25 bahsis -> $30 (27,5 -> 5'e yuvarlanir) (%s)" % hedef("bahsis"))
	game.j_G.day = 40.0   # gun sayisi artik hedefi etkilemez
	check(hedef("durum") == 13.0 and hedef("para") == 370.0 and hedef("bahsis") == 30.0, "hedef gun sayisina bagli degil")
	game.j_G.day = 10.0
	# yuksek tempolu oyuncu: hedef de yukselir (eskiden bedava paraydi)
	game.j_G.bahisGecmis = [kayit(30, 1500, 80, 0), kayit(32, 1600, 90, 0), kayit(34, 1700, 100, 0)]
	check(hedef("durum") == 35.0 and hedef("para") == 1760.0 and hedef("bahsis") == 100.0,
		"hizli oyuncu: 35 / 1760 / 100 (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	# kayit 3 gunden uzunsa yalniz en yeni 3 gun sayilir
	game.j_G.bahisGecmis = [kayit(100, 5000, 90, 0), kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	check(hedef("durum") == 13.0 and hedef("para") == 370.0 and hedef("bahsis") == 30.0,
		"4 kayit: en eskisi sayilmaz (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	# tabanlar
	game.j_G.bahisGecmis = [kayit(0, 0, 0, 0), kayit(1, 20, 0, 0), kayit(0, 0, 1, 0)]
	check(hedef("durum") == 4.0 and hedef("para") == 100.0 and hedef("bahsis") == 10.0,
		"tabanlar: 4 / 100 / 10 (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	# gecmiste yalniz 1 ya da 2 gun varsa onlarin ortalamasi
	game.j_G.bahisGecmis = [kayit(20, 600, 40, 0)]
	check(hedef("durum") == 22.0 and hedef("para") == 660.0 and hedef("bahsis") == 45.0,
		"tek gunluk gecmis: 22 / 660 / 45 (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	game.j_G.bahisGecmis = [kayit(20, 600, 40, 0), kayit(10, 200, 10, 0)]
	check(hedef("durum") == 17.0 and hedef("para") == 440.0 and hedef("bahsis") == 30.0,
		"iki gunluk gecmis: 17 / 440 / 30 (%s / %s / %s)" % [hedef("durum"), hedef("para"), hedef("bahsis")])
	# bozuk alan (kayit elle bozulmus): eski formullere dusmek yerine sifir sayilir, patlamaz
	game.j_G.bahisGecmis = [{"wraps": "x"}]
	check(hedef("durum") == 4.0 and hedef("para") == 100.0 and hedef("bahsis") == 10.0, "eksik/bozuk kayit alani sifir sayilir")
	game.j_G.bahisGecmis = "bozuk"
	check(hedef("durum") == 8.0, "gecmis dizi degilse eski formul (%s)" % hedef("durum"))

	# 3) f_bahisGunuKaydet: yalniz son 3 gun, kazanc = earned - branch
	game.j_G.bahisGecmis = []
	for i in 5:
		game.j_G.stat.wraps = 10.0 + i
		game.j_G.stat.earned = 300.0 + 10.0 * i
		game.j_G.stat.branch = 0.0
		game.j_G.stat.tips = 20.0 + i
		game.j_G.stat.lost = float(i % 2)
		RS.f_bahisGunuKaydet()
	var g: Array = RS.f_bahisGecmisi()
	check(g.size() == 3, "5 gun kaydedildi, 3 tutulur (%d)" % g.size())
	check(float(g[0].wraps) == 12.0 and float(g[1].wraps) == 13.0 and float(g[2].wraps) == 14.0, "en eski dusen, sira korunur")
	check(float(g[2].kazanc) == 340.0 and float(g[2].bahsis) == 24.0 and float(g[2].kacan) == 0.0, "son kayit: 340 / 24 / 0 (%s)" % str(g[2]))
	check(float(g[1].kacan) == 1.0, "kacan musteri kaydi")
	game.j_G.stat.earned = 500.0; game.j_G.stat.branch = 120.0
	RS.f_bahisGunuKaydet()
	check(float(RS.f_bahisGecmisi()[2].kazanc) == 380.0, "kazanc sube geliri haric: 500 - 120 = 380")
	game.j_G.stat = null
	var once: int = RS.f_bahisGecmisi().size()
	RS.f_bahisGunuKaydet()
	check(RS.f_bahisGecmisi().size() == once, "stat yokken kayit eklenmez, patlamaz")

	# 4) gun sonu tam bir kayit ekler
	gun_kur(12.0)
	var G: Dictionary = game.j_G
	G.stat.wraps = 17.0; G.stat.earned = 456.0; G.stat.tips = 35.0; G.stat.lost = 2.0
	game.session_system.f_endDay()
	check(RS.f_bahisGecmisi().size() == 1, "gun sonu: tek kayit (%d)" % RS.f_bahisGecmisi().size())
	var son: Dictionary = RS.f_bahisGecmisi()[0]
	check(float(son.wraps) == 17.0 and float(son.kazanc) == 456.0 and float(son.bahsis) == 35.0 and float(son.kacan) == 2.0,
		"gun sonu kaydi gunun sayilari (%s)" % str(son))
	var diskte: Variant = game.f_loadGame()
	check(diskte is Dictionary and diskte.get("bahisGecmis") is Array and diskte.bahisGecmis.size() == 1 and float(diskte.bahisGecmis[0].wraps) == 17.0,
		"gun sonu kaydi diske de yazilir (%s)" % str(diskte.get("bahisGecmis") if diskte is Dictionary else null))
	# sonraki gun: gecmis surer, 3 gunden fazla birikmez
	for d in 4:
		G.day = 13.0 + d
		game.f_startDay()
		game.j_G.stat.wraps = 20.0 + d; game.j_G.stat.earned = 500.0
		game.session_system.f_endDay()
	check(RS.f_bahisGecmisi().size() == 3, "gun sonlari birikir ama en cok 3 tutulur (%d)" % RS.f_bahisGecmisi().size())
	check(float(RS.f_bahisGecmisi()[2].wraps) == 23.0, "en yeni gun sonda")

	# 5) kayit / yukleme / sifirlama
	game.j_G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 1)]
	game.save_system.f_saveAll()
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(YOL))
	check(disk is Dictionary and disk.has(game.j_SAVEKEY), "ilerleme kaydi dosyada")
	var anahtar: String = str(game.j_SAVEKEY)
	var kayitli: Variant = JSON.parse_string(str(disk[anahtar])) if disk is Dictionary and disk.has(anahtar) else null
	check(kayitli is Dictionary and kayitli.get("bahisGecmis") is Array and kayitli.bahisGecmis.size() == 2, "kayitta bahisGecmis var (%s)" % str(kayitli.get("bahisGecmis") if kayitli is Dictionary else null))
	var g2 := yeni_oyun()
	g2.storage.values = disk.duplicate(true)
	g2.save_system.f_loadAndGo()
	var yuk: Array = g2.rival_system.f_bahisGecmisi()
	check(yuk.size() == 2 and float(yuk[1].wraps) == 12.0 and float(yuk[1].kacan) == 1.0 and float(yuk[0].kazanc) == 300.0,
		"kayit -> yukleme: gecmis korunur (%s)" % str(yuk))
	check(g2.rival_system.f_bahisHedefi("wraps", 99.0, 4.0, 1.0) == 12.0, "yuklenen gecmisle hedef: ort. 11 -> 12")
	g2.session_system.f_resetProgress()
	check(g2.rival_system.f_bahisGecmisi().is_empty(), "sifirlama gecmisi siler")
	# bu surumden onceki kayit (alan yok) bos gecmisle acilir
	var eski_kayit: Dictionary = kayitli.duplicate(true)
	check(eski_kayit.erase("bahisGecmis"), "eski kayit taklidi: alan silindi")
	var eski_disk: Dictionary = disk.duplicate(true)
	eski_disk[anahtar] = JSON.stringify(eski_kayit)
	var eski := yeni_oyun()
	eski.storage.values = eski_disk
	eski.save_system.f_loadAndGo()
	check(eski.j_G.day == float(kayitli.day) and eski.rival_system.f_bahisGecmisi().is_empty(), "eski kayit (alan yok): oyun acilir, gecmis bos, hata yok")
	check(eski.rival_system.f_bahisHedefi("wraps", 8.0, 4.0, 1.0) == 8.0, "bos gecmis: eski formul degeri")

	# 6) "kacirirsin" filtresi
	gun_kur(14.0)
	var kacan: Dictionary = tip("kacan")
	var rnd0: int = game.random_state
	game.j_G.bahisGecmis = []
	check(RS.f_bahisTuruSec(kacan).id == "kacan", "gecmis yok: kacan bahsi secilebilir")
	game.j_G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	var yerine: Dictionary = RS.f_bahisTuruSec(kacan)
	check(yerine.id != "kacan" and yerine.id == "bahsis", "hic musteri kacmadi: bedava para olur, siradaki tur secilir (%s)" % yerine.id)
	check(RS.f_bahisTuruSec(tip("durum")).id == "durum" and RS.f_bahisTuruSec(tip("para")).id == "para", "diger turler degismez")
	check(game.random_state == rnd0, "filtre rastgele sayi tuketmez")
	game.j_G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 1), kayit(14, 380, 30, 0)]
	check(RS.f_bahisTuruSec(kacan).id == "kacan", "son gunlerde musteri kacmis: bahis gercek bir risk, secilebilir")

	# 7) rakip teklifi (f_rakipGunBasi): hedef gecmisten, kacan filtreli
	gun_kur(14.0)
	G = game.j_G
	G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	var beklenen := {"durum": 13.0, "para": 370.0, "bahsis": 30.0}
	var gorulen := {}
	for i in 80:
		G.rakipHedef = 1.0; G.rakipKapandi = false; G.rakip = null
		RS.f_rakipGunBasi()
		var R: Variant = G.rakip
		if not (R is Dictionary): failures.append("teklif olusmadi"); break
		gorulen[R.tip] = true
		check(R.tip != "kacan", "gecmiste kacan yok: teklif 'kacirirsin' olmaz (%s)" % R.tip)
		if beklenen.has(R.tip):
			check(float(R.hedef) == float(beklenen[R.tip]), "teklif hedefi gecmisten: %s %s (beklenen %s)" % [R.tip, R.hedef, beklenen[R.tip]])
		check(float(R.para) == float(game.progression_system.f_bahisPara(G)), "kazanc/ceza miktari degismedi")
	check(gorulen.has("durum") and gorulen.has("para") and gorulen.has("bahsis"), "80 teklifte uc sayisal tur de goruldu (%s)" % str(gorulen.keys()))
	G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 2), kayit(14, 380, 30, 0)]
	gorulen = {}
	for i in 80:
		G.rakipHedef = 1.0; G.rakip = null
		RS.f_rakipGunBasi()
		gorulen[G.rakip.tip] = true
	check(gorulen.has("kacan"), "son gunlerde musteri kacmissa 'kacirirsin' de teklif edilir")

	# 8) kabul edilen bahis hedefini saklar; gun sonunda ona gore cozulur
	gun_kur(14.0)
	G = game.j_G
	G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	G.rakip = {"faz": "teklif", "t": 0.0, "girisT": 0.0, "x": 300.0, "tip": "durum", "hedef": hedef("durum"), "para": float(game.progression_system.f_bahisPara(G)), "selam": "x", "ilk": false}
	RS.f_rakipCevap(true, false)
	check(G.bahis is Dictionary and float(G.bahis.hedef) == 13.0, "kabul: bahis hedefi 13 saklandi")
	G.bahisGecmis = [kayit(100, 9000, 90, 0)]   # gecmis degisse de kabul edilen hedef degismez
	check(float(G.bahis.hedef) == 13.0, "kabul edilen hedef sabit")
	var para0: float = float(G.money)
	G.stat.wraps = 12.0
	RS.f_bahisCoz()
	check(G.bahisSonuc is Dictionary and not G.bahisSonuc.kazandi and float(G.money) == maxf(0.0, para0 - float(G.bahisSonuc.para)), "12 < 13: bahis kaybedilir, ceza kesilir")
	gun_kur(14.0)
	G = game.j_G
	G.bahisGecmis = [kayit(10, 300, 20, 0), kayit(12, 340, 25, 0), kayit(14, 380, 30, 0)]
	G.rakip = {"faz": "teklif", "t": 0.0, "girisT": 0.0, "x": 300.0, "tip": "durum", "hedef": hedef("durum"), "para": float(game.progression_system.f_bahisPara(G)), "selam": "x", "ilk": false}
	RS.f_rakipCevap(true, false)
	para0 = float(G.money)
	G.stat.wraps = 13.0
	RS.f_bahisCoz()
	check(G.bahisSonuc is Dictionary and G.bahisSonuc.kazandi and float(G.money) == para0 + float(G.bahisSonuc.para), "13 >= 13: bahis kazanilir, odul eklenir")

	if failures.is_empty():
		print("BAHIS HEDEF TAMAM")
		quit(0)
	else:
		print("BAHIS HEDEF HATA: ", failures.size())
		for f in failures: print("  - ", f)
		quit(1)
