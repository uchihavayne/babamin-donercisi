# CILA (birlesik surum, 11. tur: yayin oncesi ekran taramasi). Taramada bulunup
# duzeltilen kusurlarin geri gelmemesi icin:
#  1) Yeni Oyun tabelayi ilk acilistaki varsayilana dondurur (eskiden null:
#     Kisisellestir penceresi "null" gosteriyordu)
#  2) mufettis musterilerin ustune binmez (bos yer / iki yerin arasi)
#  3) cop kutusu etiketi gercekte olacak isi soyler; dort dilde cevirisi var
#  4) uzun metin "maxw" ile sigdirilir (sube aciklamalari, gun basi karti)
#  5) kapida sorgulanan musteri (Demirkent) eski yerini tutmaz
#  6) basarim bildirimi pencereler acikken bekler
#  7) telefon fisinin basligi, 8) basarim grubu etiketleri, 9) rekor satirlari
#     alti dilde yerine sigar
# 10) sayi bicimi dile gore (binlik / ondalik ayraci, yuzde isaretinin yeri)
# 11) soz girdi aygitina gore: farede "tıkla", telefonda "dokun", kolda yalin
# 12) cikis ayarlari (Windows/Android/iOS) proje surumuyle ayni
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
	# 7) telefon fisinin basligi her dilde fise sigar (Almanca "LIEFERUNG" tasiyordu)
	var DILLER := ["tr", "en", "de", "fr", "es", "pt"]
	for dil in DILLER:
		game.localization.f_setLang(dil)
		for toplu in [false, true]:
			var baslik: String = game.order_draw.fis_basligi(toplu)
			check(float(game.f_textW(baslik)) <= game.order_draw.FIS_BASLIK_W, "%s fis basligi sigar: %s (%s px)" % [dil, baslik, game.f_textW(baslik)])
	# 8) basarim penceresi: rozetler en genis grup etiketinden sonra baslar, panele sigar
	var en_kalabalik := 0
	var say := {}
	for b in game.j_BASARIM:
		say[b.grup] = int(say.get(b.grup, 0)) + 1
		en_kalabalik = maxi(en_kalabalik, say[b.grup])
	for dil in DILLER:
		game.localization.f_setLang(dil)
		var sutun: float = game.achievement_draw.rozet_sutunu()
		for grup in game.j_BS_GRUP:
			check(10.0 + float(game.f_textW(grup[1])) + 4.0 <= sutun, "%s basarim grubu etiketi rozete binmez: %s" % [dil, game.localization.f_T(grup[1])])
		check(sutun + en_kalabalik * 19.0 <= (float(game.j_W) - 52.0) - 10.0, "%s rozet satiri panele sigar (%s)" % [dil, sutun])
	# 9) rekorlar tablosu: etiket degere degmez (en genis deger: 5 hane / "12,5")
	var AD: RefCounted = game.achievement_draw
	for dil in DILLER:
		game.localization.f_setLang(dil)
		for etiket in ["Toplam dürüm", "İskender", "Toplam içecek", "Patates porsiyon", "Tatlı", "Oynanan gün", "Kaçan müşteri"]:
			check(16.0 + float(game.f_textW(etiket)) + AD.REKOR_BOSLUK + float(game.f_textW("99999")) <= AD.REKOR_HUCRE_W, "%s rekor etiketi sigar: %s" % [dil, game.localization.f_T(etiket)])
		var ort: String = AD.gunluk_kacan({"lost": 365.0, "days": 29.0})
		check(16.0 + float(game.f_textW("Kaçan (günlük ort.)")) + AD.REKOR_BOSLUK + float(game.f_textW(ort)) <= AD.REKOR_HUCRE_W, "%s gunluk kacan etiketi sigar (%s)" % [dil, ort])
	# 10) sayi bicimi dile gore; gunluk ortalama tek ondalik
	var MU: RefCounted = game.math_utils
	var beklenen := {"tr": ["5.000.000", "5,00M", "%42", "0,4"], "en": ["5,000,000", "5.00M", "42%", "0.4"], "de": ["5.000.000", "5,00M", "42%", "0,4"],
		"fr": ["5 000 000", "5,00M", "42%", "0,4"], "es": ["5.000.000", "5,00M", "42%", "0,4"], "pt": ["5.000.000", "5,00M", "42%", "0,4"]}
	for dil in DILLER:
		game.localization.f_setLang(dil)
		var b: Array = beklenen[dil]
		check(str(MU.f_fmtMoney(5000000.0)) == b[0], "%s binlik ayraci: %s" % [dil, MU.f_fmtMoney(5000000.0)])
		check(str(MU.f_fmtShort(5000000.0)) == b[1], "%s kisa bicim: %s" % [dil, MU.f_fmtShort(5000000.0)])
		check(MU.f_yuzde(42.0) == b[2], "%s yuzde: %s" % [dil, MU.f_yuzde(42.0)])
		check(AD.gunluk_kacan({"lost": 12.0, "days": 29.0}) == b[3], "%s gunluk kacan: %s" % [dil, AD.gunluk_kacan({"lost": 12.0, "days": 29.0})])
	game.localization.f_setLang("tr")
	check(str(MU.f_fmtMoney(950.0)) == "950" and str(MU.f_fmtMoney(-1200.0)) == "-1.200" and str(MU.f_fmtShort(12500.0)) == "13K", "kucuk / eksi / K bicimi degismedi")
	check(AD.gunluk_kacan({}) == "0,0" and AD.gunluk_kacan({"lost": 3.0, "days": 0.0}) == "0,0", "hic gun oynanmadiysa ortalama 0,0")
	# 11) soz girdi aygitina gore: farede "tıkla", telefonda "dokun", kolda yalin
	var L: RefCounted = game.localization
	game.controls.set_mode("mouse")
	check(L.f_T("Turşuya tıkla") == "Turşuya tıkla", "farede: tıkla")
	game.controls.set_mode("touch")
	check(L.f_T("Turşuya tıkla") == "Turşuya dokun" and L.cift("3 MALZEME TEK TIK", "3 SIDES, ONE CLICK") == "3 MALZEME TEK DOKUNUŞ", "telefonda: dokun")
	game.controls.set_mode("controller")
	check(L.f_T("Turşuya tıkla") == "Turşu ekle" and L.f_T("Tahtaya tıklayarak doğra") == "Tahtayı basılı tutarak doğra", "kolda: yalin soz, tahta basili tutulur")
	for dil in ["en", "de", "fr", "es", "pt"]:
		var d: Dictionary = game.j_SOZLUK[dil]
		for anahtar in L.GIRDI_SOZ:
			check(d.has(anahtar), "%s sozlugunde fare sozu var: %s" % [dil, anahtar])
			for soz in L.GIRDI_SOZ[anahtar]:
				check(d.has(soz), "%s sozlugunde aygit sozu var: %s" % [dil, soz])
	# ogreticinin hicbir adimi telefonda / kolda fareden soz etmez (6 dil)
	var fare_sozu := RegEx.new()
	fare_sozu.compile("(?i)tıkla|tık\\b|fare|click|mouse|klick|maus|clic|clique|souris|ratón|rato\\b")
	for kip in ["touch", "controller", "keyboard"]:
		for dil in DILLER:
			game.localization.f_setLang(dil)
			game.controls.set_mode("mouse"); game.controls.set_mode(kip)
			for adim in game.j_TUT:
				var yazi: String = str(L.f_T(adim.s))
				check(fare_sozu.search(yazi) == null, "%s / %s ogretici adimi fareden soz etmez: %s" % [kip, dil, yazi])
			for ipucu in ["Kutu açık — tıklayarak doldur", "Pideyi doğra — tahtaya tıkla", " (tekrar tıkla)", "tıkla: +", "Tek tıkla 2-3 ürüne birden"]:
				check(fare_sozu.search(str(L.f_T(ipucu))) == null, "%s / %s ipucu fareden soz etmez: %s" % [kip, dil, L.f_T(ipucu)])
			var etiket: String = L.cift("3 MALZEME TEK TIK", "3 SIDES, ONE CLICK")
			check(fare_sozu.search(etiket) == null and not etiket.contains("TIK"), "%s / %s gelistirme etiketi fareden soz etmez: %s" % [kip, dil, etiket])
	game.localization.f_setLang("tr")
	game.controls.set_mode("mouse")
	# 12) cikis ayarlari proje surumuyle ayni: Windows/Android/iOS paketleri eski
	#     "0.2.0" ile cikmasin; Android surum kodu = ana*10000 + ara*100 + yama
	var proje := FileAccess.get_file_as_string("res://project.godot")
	var sm := RegEx.create_from_string("config/version=\"([^\"]+)\"").search(proje)
	var surum: String = sm.get_string(1) if sm != null else ""
	var parca := surum.split(".")
	var kod_beklenen := int(parca[0]) * 10000 + int(parca[1]) * 100 + int(parca[2]) if parca.size() == 3 else -1
	var cikis := FileAccess.get_file_as_string("res://export_presets.cfg")
	check(surum != "" and kod_beklenen > 0, "proje surumu okunur (%s)" % surum)
	for anahtar in ["application/short_version", "version/name"]:
		var bulunan := RegEx.create_from_string(anahtar + "=\"([^\"]*)\"").search_all(cikis)
		check(not bulunan.is_empty(), "cikis ayarinda %s var" % anahtar)
		for m in bulunan: check(m.get_string(1) == surum, "%s = %s, proje surumu %s" % [anahtar, m.get_string(1), surum])
	var kodlar := RegEx.create_from_string("version/code=(\\d+)").search_all(cikis)
	check(not kodlar.is_empty(), "Android surum kodu var")
	for m in kodlar: check(int(m.get_string(1)) == kod_beklenen, "Android surum kodu %s, beklenen %d" % [m.get_string(1), kod_beklenen])
	for m in RegEx.create_from_string("application/version=\"(\\d+)\"").search_all(cikis):
		check(int(m.get_string(1)) == kod_beklenen, "uygulama yapi numarasi %s, beklenen %d" % [m.get_string(1), kod_beklenen])
	print("CILA ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
