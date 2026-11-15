# BABA'NIN DEFTERI / KAYIP TARIFLER (birlesik surum, 12. tur, kullanici istegi: "kayip tarifler olsun").
# Her sayfa adiyla istenen bir siparis sablonu (sos / istenmeyen malzeme / ek urun); sayfa gun sonunda
# bulunur, ekipman varsa musteriler tarifi adiyla ister, dogru + tam kalite teslimde prim ve ustalik.
#  1) veri: 8 sayfa, gunler artan, kimlikler tek, sos / yok / ek / gerek tutarli, 6 dilde ad ve not
#  2) sayfa bulma: gun gelince bir kez bulunur, eski kayitta birden cok sayfa birden gelir; yeni kuyrugu
#  3) ekipman: ekipmani olmayan tarif siparis edilmez (ve rastgele sayi tuketilmez); eksik yukseltmeler
#  4) siparis: bulunmus + ekipmani olan tarif ~%14 adiyla istenir; menu tarifleri tam menu
#  5) eslesme: dogru yapilmis durum tarife uyar, eksik / yanlis uymaz
#  6) teslim: dogru + tam kalite = durum fiyati x carpan; 5 / 15 / 40 serviste usta (+%10); aksi halde prim yok
#  7) menu bonusu: tam teslimde %20 / %25, kizgin musteride yok
#  8) kayit: diske yazilir / yuklenir, eski ya da bozuk kayit bos defter, yeni oyun sifirlar
#  9) arayuz: defter dugmesi yalniz sayfa varsa; panel acilir / kapanir; gun sonunda yeni sayfa karti
#     "TAMAM"a kadar "DUKKANA GIT"i tutar; tarif notlari alti dilde kartlara sigar
#   godot --headless --path . --script tests/tarif.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []
const YOL := "res://artifacts/tarif-save.json"
const DILLER := ["tr", "en", "de", "fr", "es", "pt"]
const TAM := {"sauce": 1.0, "secim": 2.0, "fbox": 1.0, "ayran": 1.0, "sweet": 1.0, "drink": 1.0}

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func yeni_oyun() -> Node:
	var g: Node = load("res://scripts/platform_game.gd").new()
	g.storage.path = YOL
	root.add_child(g); g.set_process(false); g.j_MUTED = true
	g.localization.f_setLang("tr")
	return g

func gun_kur(day: float, up: Dictionary = {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.j_G.day = day
	game.j_G.prologueSeen = true
	game.j_G.dersGorulmus = true
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null; G.ferman = null; G.lider = null
	G.weather = "sun"

func hepsini_bul() -> void:
	var d: Dictionary = game.tarif_system.f_durum()
	d.bulunan = []
	for t in game.j_TARIF: d.bulunan.append(str(t.id))

func tarif(id: String) -> Dictionary:
	return game.tarif_system.f_tarif(id)

# tarifin tam dogru yapilmis, kagitli, servise hazir durumu
func dogru_durum(id: String) -> Dictionary:
	var t := tarif(id)
	var w := {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": t.get("sos"),
		"state": "ready", "paper": true, "grilled": bool(game.J.method(game.j_TUN, "grillOn", [game.j_G])), "burnt": false}
	for m in t.get("yok", []): w[game.ORDER_FIELDS[str(m)]] = 0
	return w

func musteri(items: Array) -> Dictionary:
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state = "wait"; c.x = c.tx; c.items = items; c.done = []; c.earn = 0; c.patience = 0.9; c.homeless = false; c.mad = false; c.mac = false
	for i in items: c.done.append(false)
	return c

func siparis(id: String) -> Array:
	var items: Array = [game.tarif_system.f_siparisKalemi(id)]
	items.append_array(game.tarif_system.f_ekKalemler(id))
	return items

func teslim(c: Dictionary, w: Dictionary) -> void:
	game.j_G.hand = w
	game.f_deliver(c)

func temel_fiyat(w: Dictionary, sos: Variant) -> float:
	return float(game.recipe_system.f_itemPrice({"kind": "wrap", "grilled": w.grilled, "sauce": sos}, game.j_G))

func kare_kayit(once: int = 1) -> Array:
	for i in once: game.advance(1.0 / 60)
	game.text_draw.izle = []
	game.advance(1.0 / 60)
	var kayit: Array = game.text_draw.izle
	game.text_draw.izle = null
	return kayit

func dugme_rect(kayit: Array, yazi: String) -> Variant:
	for k in kayit:
		if k.has("dugme") and str(k.s) == yazi: return k.dugme
	return null

func yazi_var(kayit: Array, yazi: String) -> bool:
	for k in kayit:
		if k.has("s") and str(k.s) == yazi: return true
	return false

func tikla(p: Vector2) -> void:
	for asagi in [true, false]:
		var olay := InputEventMouseButton.new()
		olay.button_index = MOUSE_BUTTON_LEFT; olay.position = p; olay.pressed = asagi
		game._input(olay)
		for i in 2: game.advance(1.0 / 60)

func pencereler_kapali() -> void:
	for p in [game.j_CUSTOM, game.j_PAYP, game.j_BRP, game.j_SESP, game.j_STATS, game.j_BSP, game.j_TARIFP]:
		p.open = false

func run() -> void:
	game = yeni_oyun()
	game.storage.values = {}
	veri_testi()
	sayfa_bulma_testi()
	ekipman_testi()
	siparis_testi()
	eslesme_testi()
	teslim_testi()
	menu_testi()
	kayit_testi()
	arayuz_testi()
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("TARIF ", JSON.stringify({"sayfa": game.j_TARIF.size(), "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)

# ---------------------------------------------------------------- 1) veri
func veri_testi() -> void:
	var liste: Array = game.j_TARIF
	check(liste.size() == 8, "8 tarif sayfasi (%d)" % liste.size())
	var ids := {}
	var onceki := 0
	var upg := {}
	for u in game.j_UPG: upg[str(u.id)] = true
	var ek_yukseltme := {"fbox": "fbox", "ayran": "ayran", "cola": "drink", "sweet": "sweet"}
	for t in liste:
		var id := str(t.id)
		check(id != "" and not ids.has(id), "tarif kimligi tek: " + id)
		ids[id] = true
		check(int(t.gun) > onceki, "sayfa gunleri artan: %s %d" % [id, int(t.gun)])
		onceki = int(t.gun)
		check(t.sos == null or str(t.sos) in ["hot", "garlic"], "sos gecerli: " + id)
		for m in t.yok: check(str(m) in ["pickle", "yogurt", "fries"], "yok gecerli: %s %s" % [id, m])
		for e in t.ek:
			check(str(e) in ek_yukseltme, "ek gecerli: %s %s" % [id, e])
			check(ek_yukseltme.get(str(e), "?") in t.gerek, "ek urun icin yukseltme gerek: %s %s" % [id, e])
		check(float(t.carpan) >= 1.2 and float(t.carpan) <= 2.5, "carpan makul: %s %s" % [id, t.carpan])
		check(t.ek.is_empty() == (float(t.menu) == 0.0) and float(t.menu) <= 0.5, "menu bonusu yalniz ek urunlu tariflerde: " + id)
		for k in t.gerek: check(str(k) == "secim2" or upg.has(str(k)), "gerek yukseltmesi var: %s %s" % [id, k])
		if t.sos != null: check("sauce" in t.gerek, "sos istiyorsa Sos yukseltmesi gerekir: " + id)
		if not t.yok.is_empty(): check("secim" in t.gerek or "secim2" in t.gerek, "yok istiyorsa Malzeme Secimi gerekir: " + id)
		if t.yok.size() >= 2: check("secim2" in t.gerek, "iki malzeme cikarmak Secim 2 ister: " + id)
		check(str(t.mesaj).ends_with("— Baba"), "not Baba'nin imzasiyla biter: " + id)
		for dil in ["en", "de", "fr", "es", "pt"]:
			var soz: Dictionary = game.j_SOZLUK[dil]
			check(soz.has(str(t.ad)) and soz.has(str(t.mesaj)), "%s: ad ve not cevrilmis (%s)" % [dil, id])
			if soz.has(str(t.ad)) and soz.has(str(t.mesaj)):
				check(str(soz[str(t.ad)]) != str(t.ad), "%s: ad Turkce'den farkli (%s)" % [dil, id])
	for anahtar in ["BABA'NIN DEFTERİ", "BABA'NIN DEFTERİNDEN", "Yeni sayfa bulundu!", "Hazır", "Gerekli: ", "Kilitli sayfa", "Bulunacağı gün: ",
			"Fiyat: $", "Servis: ", "USTA", "BABA'NIN TARİFİ!", "USTA SEVİYESİ!", "MENÜ BONUSU +$", "TAMAM", "KAPAT"]:
		for dil in ["en", "de", "fr", "es", "pt"]:
			check(game.j_SOZLUK[dil].has(anahtar), "%s: arayuz metni cevrilmis: %s" % [dil, anahtar])
	# kart / panel genislikleri: en uzun not alti dilde de 3 satira sigar (yeni sayfa karti en dar: 236 px)
	for dil in DILLER:
		game.localization.f_setLang(dil)
		for t in liste:
			var metin := str(game.localization.f_T(str(t.mesaj)))
			var satirlar: Array = game.tarif_draw.satirlara(metin, 236.0, 3)
			check(" ".join(satirlar) == metin, "%s: not 3 satira sigar: %s -> %s" % [dil, metin, str(satirlar)])
			var ad := str(game.localization.f_T(str(t.ad)))
			check(float(game.f_textW(ad)) <= 212.0, "%s: tarif adi kart basligina sigar: %s" % [dil, ad])
	game.localization.f_setLang("tr")

# ---------------------------------------------------------------- 2) sayfa bulma
func sayfa_bulma_testi() -> void:
	var T = game.tarif_system
	gun_kur(1.0)
	check(T.f_bulunanSayi() == 0 and not T.f_yeniVar() and T.f_okunmamis() == 0 and T.f_yeniId() == "", "yeni oyun: defter bos")
	check(T.f_sonrakiGun() == 3, "ilk sayfa 3. gun (%d)" % T.f_sonrakiGun())
	game.j_G.day = 2.0
	check(T.f_sayfaBul().is_empty(), "2. gun: sayfa yok")
	game.j_G.day = 3.0
	var b: Array = T.f_sayfaBul()
	check(b == ["acili"] and T.f_bulundu("acili") and T.f_yeniVar() and T.f_yeniId() == "acili" and T.f_okunmamis() == 1, "3. gun: ilk sayfa bulunur (%s)" % str(b))
	check(T.f_sayfaBul().is_empty() and T.f_bulunanSayi() == 1, "ayni sayfa ikinci kez bulunmaz")
	T.f_yeniKapat()
	check(not T.f_yeniVar() and T.f_okunmamis() == 0 and "acili" in T.f_durum().gorulen, "TAMAM: kart kapanir, sayfa okunmus sayilir")
	check(T.f_sonrakiGun() == 8, "siradaki sayfa 8. gun (%d)" % T.f_sonrakiGun())
	game.j_G.day = 8.0
	check(T.f_sayfaBul() == ["sarimsakli"] and T.f_okunmamis() == 1, "8. gun: ikinci sayfa")
	# eski kayit: 40. gunde acilan oyun, atlanan sayfalar birden gelir (sirayla, bir kart ardindan digeri)
	game.j_G.day = 40.0
	var toplu: Array = T.f_sayfaBul()
	check(toplu == ["tursusuz", "yogurtsuz", "hafif"], "40. gun: atlanan 3 sayfa birden (%s)" % str(toplu))
	check(T.f_yeniId() == "sarimsakli", "yeni kuyrugu sirayla: once en eski")
	T.f_yeniKapat(); T.f_yeniKapat(); T.f_yeniKapat(); T.f_yeniKapat()
	check(not T.f_yeniVar() and T.f_okunmamis() == 0, "kuyruk bosalir, bos kuyrukta kapat patlamaz")
	game.j_G.day = 500.0
	check(T.f_sayfaBul() == ["menu", "cifte", "gece"] and T.f_sonrakiGun() == -1, "500. gun: kalanlar, sonraki sayfa yok")
	# gun sonu (f_endDay) sayfayi bulur ve diske yazar
	gun_kur(3.0)
	game.session_system.f_endDay()
	check(game.j_G.scene == "dayend" and game.j_G.tarif.bulunan == ["acili"] and T.f_yeniId() == "acili", "gun sonu: sayfa bulundu, kart sirada")
	var diskte: Variant = game.f_loadGame()
	check(diskte is Dictionary and diskte.get("tarif") is Dictionary and "acili" in diskte.tarif.bulunan, "gun sonu: defter diske yazildi")

# ---------------------------------------------------------------- 3) ekipman
func ekipman_testi() -> void:
	var T = game.tarif_system
	gun_kur(100.0)
	hepsini_bul()
	for t in game.j_TARIF:
		check(not T.f_yapilabilir(str(t.id)), "ekipmansiz: %s yapilamaz" % t.id)
		check(T.f_eksikler(str(t.id)).size() >= 1, "ekipmansiz: %s eksikleri sayilir" % t.id)
	var rnd0: int = game.random_state
	for i in 40: check(T.f_sec() == "", "ekipmansiz tarif secilmez")
	check(game.random_state == rnd0, "ekipman yokken rastgele sayi tuketilmez (eski akislar degismez)")
	check(T.f_eksikler("acili") == [T._yukseltmeAdi("sauce")], "acili eksigi: Sos yukseltmesi (%s)" % str(T.f_eksikler("acili")))
	game.j_G.up = {"sauce": 1.0}
	check(T.f_yapilabilir("acili") and T.f_yapilabilir("sarimsakli") and not T.f_yapilabilir("tursusuz") and not T.f_yapilabilir("menu"), "yalniz Sos: iki sosluk sayfa yapilir")
	game.j_G.up = {"sauce": 1.0, "secim": 1.0}
	check(T.f_yapilabilir("tursusuz") and T.f_yapilabilir("yogurtsuz") and T.f_yapilabilir("hafif") and not T.f_yapilabilir("cifte"), "Secim 1: tek malzemeli sayfalar, ikili degil")
	check(T.f_eksikler("cifte").size() == 1 and str(T.f_eksikler("cifte")[0]).ends_with(" 2"), "cifte eksigi: Malzeme Secimi 2 (%s)" % str(T.f_eksikler("cifte")))
	game.j_G.up = {"sauce": 1.0, "secim": 2.0}
	check(T.f_yapilabilir("cifte"), "Secim 2: cifte yapilir")
	game.j_G.up = {"sauce": 1.0, "fbox": 1.0, "ayran": 1.0}
	check(T.f_yapilabilir("menu") and not T.f_yapilabilir("gece"), "Patates kutusu + Ayran: menu tamam, gece tatli bekler")
	game.j_G.up = TAM.duplicate()
	for t in game.j_TARIF: check(T.f_yapilabilir(str(t.id)) and T.f_eksikler(str(t.id)).is_empty(), "tam ekipman: %s yapilir" % t.id)

# ---------------------------------------------------------------- 4) siparis uretimi
func siparis_testi() -> void:
	var T = game.tarif_system
	# bulunmus sayfa yokken: tarif yok, rastgele sayi akisi de ayni
	gun_kur(50.0, TAM)
	var G: Dictionary = game.j_G
	check(T.f_bulunanSayi() == 0, "gun_kur: defter bos")
	game.random_state = 4242
	var bos_adet := 0
	for i in 800:
		for it in game.recipe_system.f_makeOrder(G):
			if it.has("tarif"): bos_adet += 1
	check(bos_adet == 0, "sayfa yokken hic tarif siparisi yok (%d)" % bos_adet)
	# tum sayfalar + tam ekipman (iskender yok: ilk kalem hep durum)
	hepsini_bul()
	game.random_state = 4242
	var sayi := {}
	var toplam := 6000
	var tarifli := 0
	for i in toplam:
		var items: Array = game.recipe_system.f_makeOrder(G)
		check(items.size() >= 1 and items.size() <= 4, "siparis 1-4 kalem")
		if not items[0].has("tarif"): continue
		tarifli += 1
		var id := str(items[0].tarif)
		sayi[id] = int(sayi.get(id, 0)) + 1
		var t := tarif(id)
		check(items[0].kind == "wrap" and items[0].get("sauce") == t.get("sos") and items[0].get("yok", []) == t.get("yok", []), "tarif kalemi tarifle ayni: " + id)
		if i < 400 and not t.ek.is_empty():
			var beklenen := siparis(id)
			check(items.size() == beklenen.size(), "menu: tarifin kendi kalemleri (%s: %d/%d)" % [id, items.size(), beklenen.size()])
			for k in beklenen.size(): check(items[k].kind == beklenen[k].kind and items[k].get("type") == beklenen[k].get("type"), "menu kalemi %d: %s" % [k, id])
	var oran := float(tarifli) / float(toplam)
	check(oran > 0.11 and oran < 0.17, "tarif orani ~%%14 (%.3f)" % oran)
	for t in game.j_TARIF: check(int(sayi.get(str(t.id), 0)) > 60, "her tarif gelir: %s %d" % [t.id, int(sayi.get(str(t.id), 0))])
	# kismi ekipman: yalniz yapilabilir tarifler istenir
	game.j_G.up = {"sauce": 1.0}
	game.random_state = 99
	var gorulen := {}
	for i in 3000:
		for it in game.recipe_system.f_makeOrder(G):
			if it.has("tarif"): gorulen[str(it.tarif)] = true
	check(gorulen.keys().size() == 2 and gorulen.has("acili") and gorulen.has("sarimsakli"), "yalniz Sos varken yalniz iki sosluk tarif gelir (%s)" % str(gorulen.keys()))
	# iskenderli ilk kalem tarif olmaz (tabak)
	game.j_G.up = TAM.duplicate(); game.j_G.up["iskender"] = 1.0
	game.random_state = 5
	var plate_ve_tarif := 0
	for i in 2000:
		var items2: Array = game.recipe_system.f_makeOrder(G)
		if items2[0].kind == "plate":
			for it in items2: if it.has("tarif"): plate_ve_tarif += 1
	check(plate_ve_tarif == 0, "tabakli siparise tarif karismaz")

# ---------------------------------------------------------------- 5) eslesme
func eslesme_testi() -> void:
	gun_kur(50.0, TAM)
	hepsini_bul()
	var OS = game.order_system
	for t in game.j_TARIF:
		var id := str(t.id)
		var kalem: Dictionary = game.tarif_system.f_siparisKalemi(id)
		var w := dogru_durum(id)
		check(OS.order_matches(w, kalem), "dogru yapilan durum tarife uyar: " + id)
		for alan in ["meat", "pickleN", "yogurtN", "friesN"]:
			var b := w.duplicate()
			b[alan] = 0 if int(b[alan]) > 0 else 4
			check(not OS.order_matches(b, kalem), "%s: %s ters cevrilince uymaz" % [id, alan])
		var s := w.duplicate()
		s.sauce = "garlic" if t.get("sos") != "garlic" else "hot"
		check(not OS.order_matches(s, kalem), "%s: yanlis sos uymaz" % id)
		var sossuz := w.duplicate(); sossuz.sauce = null
		check(t.get("sos") == null or not OS.order_matches(sossuz, kalem), "%s: sossuz uymaz" % id)

# ---------------------------------------------------------------- 6) teslim ve prim
func teslim_testi() -> void:
	var T = game.tarif_system
	# 6a) dogru tarif: fiyat x carpan, sayac artar
	gun_kur(6.0, {"sauce": 1.0})
	T.f_durum().bulunan = ["acili"]
	var c := musteri(siparis("acili"))
	var w := dogru_durum("acili")
	var temel := temel_fiyat(w, "hot")
	var beklenen := floorf(temel * 1.6 + 0.5)
	teslim(c, w)
	check(c.done[0] and absf(float(c.earn) - beklenen) < 0.001, "dogru tarif: durum fiyati x1.6 (%s / beklenen %s, temel %s)" % [c.earn, beklenen, temel])
	check(float(c.earn) > temel, "prim gercekten fazla")
	check(T.f_servis("acili") == 1 and T.f_usta("acili") == 0, "servis sayaci 1")
	check(not c.mad and c.state == "served" and c.mood == "served", "musteri memnun, siparis tamam (%s / %s)" % [c.state, c.mood])
	# 6b) ayni tarif normal (tarifsiz) siparis olsaydi: prim yok
	var normal := musteri([{"kind": "wrap", "sauce": "hot"}])
	var w2 := dogru_durum("acili")
	teslim(normal, w2)
	check(absf(float(normal.earn) - temel) < 0.001, "tarifsiz ayni siparis: yalniz durum fiyati (%s)" % normal.earn)
	check(T.f_servis("acili") == 1, "tarifsiz teslim sayaci artirmaz")
	# 6c) yanlis sos: kabul (indirimli), prim yok, sayac artmaz
	var c3 := musteri(siparis("acili"))
	var w3 := dogru_durum("acili"); w3.sauce = null
	teslim(c3, w3)
	check(c3.done[0] and float(c3.earn) < temel and c3.mad, "yanlis sos: indirimli, musteri kizgin (%s)" % c3.earn)
	check(T.f_servis("acili") == 1, "yanlis sos sayaci artirmaz")
	# 6d) evsiz musteri: ucret 0, sayac degismez
	var c4 := musteri(siparis("acili"))
	c4.homeless = true
	teslim(c4, dogru_durum("acili"))
	check(float(c4.earn) == 0.0 and T.f_servis("acili") == 1, "evsiz musteri: ucret yok, sayac yok")
	# 6e) eksik malzemeli tarif: prim yok
	gun_kur(10.0, {"sauce": 1.0, "secim": 1.0})
	T.f_durum().bulunan = ["tursusuz"]
	var c5 := musteri(siparis("tursusuz"))
	var w5 := dogru_durum("tursusuz"); w5.yogurtN = 0
	teslim(c5, w5)
	check(float(c5.earn) < temel_fiyat(w5, null) and c5.mad and T.f_servis("tursusuz") == 0, "eksik malzeme: indirimli, prim yok, sayac yok (%s)" % c5.earn)
	# 6f) dogru turşusuz: carpan 1.7
	var c6 := musteri(siparis("tursusuz"))
	var w6 := dogru_durum("tursusuz")
	teslim(c6, w6)
	check(absf(float(c6.earn) - floorf(temel_fiyat(w6, null) * 1.7 + 0.5)) < 0.001 and T.f_servis("tursusuz") == 1, "tursusuz: x1.7 (%s)" % c6.earn)
	# 6g) ustalik: 5 / 15 / 40 serviste seviye atlar, her seviye +%10
	gun_kur(10.0, {"sauce": 1.0})
	T.f_durum().bulunan = ["acili"]
	var musteri_ornek := {"x": 240.0, "y": 140.0}
	var onceki_carpan: float = T.f_carpan("acili")
	check(absf(onceki_carpan - 1.6) < 0.0001, "baslangic carpani 1.6")
	var esik := {5: 1, 15: 2, 40: 3}
	for n in range(1, 41):
		T.f_odul("acili", 20.0, musteri_ornek)
		var beklenen_usta: int = 0
		for e in esik: if n >= int(e): beklenen_usta = maxi(beklenen_usta, int(esik[e]))
		check(T.f_usta("acili") == beklenen_usta, "%d serviste usta seviyesi %d (%d)" % [n, beklenen_usta, T.f_usta("acili")])
	check(absf(T.f_carpan("acili") - 1.6 * 1.3) < 0.0001, "usta: carpan 1.6 x 1.3 (%s)" % T.f_carpan("acili"))
	check(T.f_odul("acili", 20.0, musteri_ornek) == floorf(20.0 * 1.6 * 1.3 + 0.5), "usta fiyati: 20 -> %d" % int(floorf(20.0 * 1.6 * 1.3 + 0.5)))
	check(T.f_usta("acili") == 3, "usta seviyesi 3'te kalir (ust sinir)")
	# ayni sayac sadece o tarifin: baska tarif etkilenmez
	check(T.f_servis("sarimsakli") == 0 and absf(T.f_carpan("sarimsakli") - 1.6) < 0.0001, "ustalik tarife ozel")

# ---------------------------------------------------------------- 7) menu bonusu
func menu_testi() -> void:
	var T = game.tarif_system
	gun_kur(50.0, {"sauce": 1.0, "fbox": 1.0, "ayran": 1.0})
	T.f_durum().bulunan = ["menu"]
	var G: Dictionary = game.j_G
	var items := siparis("menu")
	check(items.size() == 3 and items[1].kind == "fbox" and items[2].kind == "drink" and items[2].type == "ayran", "menu: durum + patates kutusu + ayran")
	var c := musteri(items)
	var w := dogru_durum("menu")
	var temel := temel_fiyat(w, "hot")
	var durum_fiyati := floorf(temel * 1.5 + 0.5)
	var yan := float(game.recipe_system.f_itemPrice({"kind": "fbox"}, G)) + float(game.recipe_system.f_itemPrice({"kind": "drink", "type": "ayran"}, G))
	G.stat.earned = 0.0; G.stat.tips = 0.0
	teslim(c, w)
	check(not bool(c.done[1]) and not bool(c.done[2]) and float(G.stat.earned) == 0.0, "durum teslimi: menu henuz bitmedi, odeme yok")
	teslim(c, {"kind": "fbox", "state": "ready"})
	teslim(c, {"kind": "drink", "type": "ayran"})
	check(c.done[0] and c.done[1] and c.done[2] and c.state == "served", "menu tamamlandi")
	var toplam := durum_fiyati + yan
	check(absf(float(c.earn) - toplam) < 0.001, "kalemler: %s + yan urunler %s = %s (earn %s)" % [durum_fiyati, yan, toplam, c.earn])
	var odenen: float = float(G.stat.earned) - float(G.stat.tips)
	var beklenen := toplam + floorf(toplam * 0.2 + 0.5)
	check(absf(odenen - beklenen) < 0.001, "menu bonusu %%20: %s -> %s (odenen %s)" % [toplam, beklenen, odenen])
	# kizgin musteri: bonus yok
	gun_kur(50.0, {"sauce": 1.0, "fbox": 1.0, "ayran": 1.0})
	T.f_durum().bulunan = ["menu"]
	G = game.j_G
	var c2 := musteri(siparis("menu"))
	var w2 := dogru_durum("menu"); w2.sauce = null          # yanlis sos: musteri kizar
	G.stat.earned = 0.0; G.stat.tips = 0.0
	teslim(c2, w2)
	teslim(c2, {"kind": "fbox", "state": "ready"})
	teslim(c2, {"kind": "drink", "type": "ayran"})
	check(c2.state == "served" and c2.mad, "kizgin musteri menuyu tamamlar")
	check(absf((float(G.stat.earned) - float(G.stat.tips)) - float(c2.earn)) < 0.001, "kizgin musteri: menu bonusu yok (earn %s, odenen %s)" % [c2.earn, float(G.stat.earned) - float(G.stat.tips)])
	check(T.f_menuBonusu(c2) == 0.0 and T.f_menuBonusu({"items": [{"kind": "wrap"}], "mad": false}) == 0.0 and T.f_menuBonusu({"items": siparis("gece"), "mad": false}) == 0.25 and T.f_menuBonusu({"items": siparis("menu"), "mad": false}) == 0.2, "menu bonusu orani tarife bagli")

# ---------------------------------------------------------------- 8) kayit
func kayit_testi() -> void:
	var T = game.tarif_system
	gun_kur(40.0)
	var d: Dictionary = T.f_durum()
	d.bulunan = ["acili", "sarimsakli", "tursusuz"]; d.gorulen = ["acili"]; d.yeni = ["sarimsakli"]; d.servis = {"acili": 7, "sarimsakli": 2}
	game.save_system.f_saveAll()
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(YOL))
	check(disk is Dictionary and disk.has(game.j_SAVEKEY), "ilerleme kaydi dosyada")
	var anahtar: String = str(game.j_SAVEKEY)
	var kayitli: Variant = JSON.parse_string(str(disk[anahtar])) if disk is Dictionary and disk.has(anahtar) else null
	check(kayitli is Dictionary and kayitli.get("tarif") is Dictionary and kayitli.tarif.bulunan.size() == 3, "kayitta tarif var (%s)" % str(kayitli.get("tarif") if kayitli is Dictionary else null))
	var g2 := yeni_oyun()
	g2.storage.values = disk.duplicate(true)
	g2.save_system.f_loadAndGo()
	var d2: Dictionary = g2.tarif_system.f_durum()
	check(d2.bulunan == ["acili", "sarimsakli", "tursusuz"] and d2.gorulen == ["acili"] and d2.yeni == ["sarimsakli"], "kayit -> yukleme: sayfalar ve okunmuslar korunur (%s)" % str(d2))
	check(g2.tarif_system.f_servis("acili") == 7 and g2.tarif_system.f_servis("sarimsakli") == 2, "servis sayaclari korunur")
	check(g2.tarif_system.f_okunmamis() == 2, "okunmamis sayisi korunur (%d)" % g2.tarif_system.f_okunmamis())
	g2.session_system.f_resetProgress()
	check(g2.tarif_system.f_bulunanSayi() == 0 and g2.tarif_system.f_servis("acili") == 0 and not g2.tarif_system.f_yeniVar(), "yeni oyun defteri sifirlar")
	# bu surumden onceki kayit (alan yok) bos defterle acilir
	var eski_kayit: Dictionary = kayitli.duplicate(true)
	check(eski_kayit.erase("tarif"), "eski kayit taklidi: alan silindi")
	var eski_disk: Dictionary = disk.duplicate(true)
	eski_disk[anahtar] = JSON.stringify(eski_kayit)
	var eski := yeni_oyun()
	eski.storage.values = eski_disk
	eski.save_system.f_loadAndGo()
	check(eski.j_G.day == float(kayitli.day) and eski.tarif_system.f_bulunanSayi() == 0, "eski kayit (alan yok): oyun acilir, defter bos")
	# eski kayitla acilan oyun ilk gun sonunda atlanan sayfalari alir
	eski.j_G.day = 22.0
	check(eski.tarif_system.f_sayfaBul() == ["acili", "sarimsakli", "tursusuz", "yogurtsuz"], "eski kayit: ilk gun sonunda 22. gune kadar olan 4 sayfa")
	# bozuk kayit: alan yanlis turde
	for bozuk in ["metin", 5, [1, 2], {"bulunan": "x", "yeni": 3, "gorulen": null, "servis": []}]:   # bilinmeyen / tekrarli kimlikler ayrica asagida
		var bk: Dictionary = kayitli.duplicate(true)
		bk.tarif = bozuk
		var bd: Dictionary = disk.duplicate(true)
		bd[anahtar] = JSON.stringify(bk)
		var bg := yeni_oyun()
		bg.storage.values = bd
		bg.save_system.f_loadAndGo()
		var bdurum: Dictionary = bg.tarif_system.f_durum()
		check(bdurum.bulunan is Array and bdurum.yeni is Array and bdurum.gorulen is Array and bdurum.servis is Dictionary, "bozuk kayit (%s): defter bos ama saglam" % str(bozuk))
		check(bg.tarif_system.f_bulunanSayi() == 0 and bg.tarif_system.f_servis("acili") == 0 and bg.tarif_system.f_okunmamis() == 0, "bozuk kayit: hicbir sey bulunmus sayilmaz (%s)" % str(bozuk))
		bg.free()
	# bilinmeyen / tekrarli kimlik, bulunmamis sayfada yeni-okunmus, eksi / bozuk sayac ayiklanir
	var tuhaf: Dictionary = game.tarif_system.f_yukle({"bulunan": ["acili", "yok_boyle_biri", "acili"], "yeni": ["yok_boyle_biri", "gece", "acili"],
		"gorulen": ["gece"], "servis": {"acili": -4, "yok_boyle_biri": 9, "sarimsakli": "x", "tursusuz": 12.0}})
	check(tuhaf.bulunan == ["acili"] and tuhaf.yeni == ["acili"] and tuhaf.gorulen.is_empty(), "yukleme ayiklar: bilinmeyen / tekrarli / bulunmamis sayfa (%s)" % str(tuhaf))
	check(tuhaf.servis == {"acili": 0, "tursusuz": 12}, "sayaclar: eksi 0'a, bozuk atilir (%s)" % str(tuhaf.servis))
	g2.free(); eski.free()
	# gun ici anlik goruntu de defteri tasir
	gun_kur(12.0, {"sauce": 1.0})
	T.f_durum().bulunan = ["acili"]; T.f_durum().servis = {"acili": 3}
	game.j_G.scene = "play"
	check(game.save_system.gunici_kaydet(), "gun ici kayit yazildi")
	var anlik: Dictionary = game.save_system.gunici_oku()
	check(anlik.get("tarif") is Dictionary and float(anlik.tarif.servis.get("acili", 0)) == 3.0 and "acili" in anlik.tarif.bulunan, "gun ici anlik goruntu defteri tasir (%s)" % str(anlik.get("tarif")))
	game.save_system.gunici_sil()

# ---------------------------------------------------------------- 9) arayuz
func arayuz_testi() -> void:
	var T = game.tarif_system
	# 9a) dukkan cubugu: defter dugmesi yalniz sayfa varsa
	gun_kur(18.0)
	var G: Dictionary = game.j_G
	G.money = 3200.0; G.scene = "shop"; G.sceneT = 5.0
	pencereler_kapali()
	var kayit := kare_kayit()
	var ilk_dugmeler := 0
	for k in kayit:
		if k.has("dugme") and float(k.dugme.size.x) == 20.0 and float(k.dugme.size.y) == 17.0: ilk_dugmeler += 1
	check(ilk_dugmeler == 0, "sayfa yokken defter dugmesi yok")
	hepsini_bul()
	T.f_durum().gorulen = []
	kayit = kare_kayit()
	var dugme: Variant = null
	for k in kayit:
		if k.has("dugme") and float(k.dugme.size.x) == 20.0 and float(k.dugme.size.y) == 17.0: dugme = k.dugme
	check(dugme != null, "sayfa bulununca defter dugmesi cubukta")
	if dugme != null:
		var r: Rect2 = dugme
		var konum := r.position + r.size / 2.0
		# komsu dugmelerle cakismaz (para yazisi sagi - BORC ODE solu)
		for k in kayit:
			if k.has("dugme") and k.dugme != dugme: check(not (k.dugme as Rect2).intersects(r), "defter dugmesi komsuyla cakismaz: %s" % str(k.dugme))
		check(T.f_okunmamis() == 8, "8 sayfa okunmamis")
		tikla(konum)
		check(bool(game.j_TARIFP.open), "dugmeye tiklayinca defter acilir")
		# acilista ilk okunmamis sayfa secili ve okunmus sayilir
		kayit = kare_kayit()
		check(int(game.j_TARIFP.sec) == 0 and T.f_okunmamis() == 7, "ilk okunmamis sayfa acilir ve okunmus olur (sec %s, okunmamis %d)" % [game.j_TARIFP.sec, T.f_okunmamis()])
		var durum_yazisi: String = "Hazır" if T.f_eksikler("acili").is_empty() else "Gerekli: " + ", ".join(T.f_eksikler("acili"))
		check(yazi_var(kayit, "Baba'nın Acılısı") and yazi_var(kayit, durum_yazisi), "panelde tarif adi ve durum yazilir (%s)" % durum_yazisi)
		# baska sekmeye gec
		var kapat: Variant = dugme_rect(kayit, "KAPAT")
		check(kapat != null, "panelde KAPAT dugmesi")
		var s3: Variant = dugme_rect(kayit, "3")
		check(s3 != null, "3. sekme dugmesi")
		if s3 != null:
			tikla((s3 as Rect2).position + (s3 as Rect2).size / 2.0)
			check(int(game.j_TARIFP.sec) == 2, "sekmeye tiklayinca o sayfa secilir")
		kayit = kare_kayit()
		check(yazi_var(kayit, "Turşusuz Sade"), "3. sayfa: Turşusuz Sade")
		if kapat != null:
			tikla((kapat as Rect2).position + (kapat as Rect2).size / 2.0)
			check(not bool(game.j_TARIFP.open), "KAPAT paneli kapatir")
		# geri tusu / kumanda
		game.j_TARIFP.open = true
		game.controls.back()
		check(not bool(game.j_TARIFP.open), "geri tusu defteri kapatir")
		# defter yalniz dukkanda acik kalir: sahne degisince (gun biter / baslar / mola) kapanir
		for sahne in ["dayend", "play", "pause", "intro"]:
			G.scene = "shop"; game.j_TARIFP.open = true
			G.scene = sahne
			game.advance(1.0 / 60)
			check(not bool(game.j_TARIFP.open), "sahne %s'e gecince defter paneli kapanir" % sahne)
			G.scene = "shop"
		# panel acikken dukkandan gunun baslatilmasi engellenir (panel ustte)
		game.j_TARIFP.open = true
		kayit = kare_kayit()
		check(dugme_rect(kayit, "GÜN 19") == null, "defter acikken arkadaki GUN dugmesi cizilmez (modal)")
		game.j_TARIFP.open = false
	# 9b) kilitli sayfa: sonraki sayfa gunu gosterilir
	gun_kur(18.0)
	G = game.j_G
	T.f_sayfaBul()
	game.j_G.scene = "shop"; game.j_G.sceneT = 5.0
	game.j_TARIFP.open = true; game.j_TARIFP.sec = 5
	kayit = kare_kayit()
	check(yazi_var(kayit, "Kilitli sayfa") and yazi_var(kayit, "Bulunacağı gün: 42"), "kilitli sayfa: Bulunacagi gun 42")
	game.j_TARIFP.open = false
	# 9c) gun sonu: yeni sayfa karti TAMAM'a kadar "DUKKANA GIT"i tutar
	gun_kur(3.0)
	G = game.j_G
	game.session_system.f_endDay()
	G.sceneT = 5.0
	pencereler_kapali()
	kayit = kare_kayit()
	check(T.f_yeniVar() and dugme_rect(kayit, "DÜKKÂNA GİT") == null, "yeni sayfa varken DUKKANA GIT yok")
	check(yazi_var(kayit, "Yeni sayfa bulundu!") and yazi_var(kayit, "Baba'nın Acılısı"), "yeni sayfa karti: baslik ve tarif adi")
	kayit = kare_kayit(40)
	var tamam: Variant = dugme_rect(kayit, "TAMAM")
	check(tamam != null, "kartta TAMAM dugmesi (yarim saniye sonra)")
	if tamam != null:
		tikla((tamam as Rect2).position + (tamam as Rect2).size / 2.0)
		check(not T.f_yeniVar() and G.scene == "dayend", "TAMAM: kart kapanir, hala gun sonu ekraninda")
		kayit = kare_kayit()
		var git: Variant = dugme_rect(kayit, "DÜKKÂNA GİT")
		check(git != null, "kart kapaninca DUKKANA GIT geri gelir")
		if git != null:
			tikla((git as Rect2).position + (git as Rect2).size / 2.0)
			check(G.scene == "shop", "DUKKANA GIT dukkana gecirir (sahne %s)" % G.scene)
	# 9d) yildiz simgesi: siparis balonunda ve defterde piksel cizer; HD / eski cizimde hata vermez
	var cv: Variant = game.draw_context
	cv.fillStyle = "#000000"; cv.fillRect(0, 0, 480, 270)
	var bos_goruntu: Image = game.screen_canvas.image.duplicate()
	game.tarif_draw.f_yildiz(100.0, 100.0)
	var dolu: Image = game.screen_canvas.image.duplicate()
	var farkli := 0
	for py in range(98, 110):
		for px in range(98, 110):
			if bos_goruntu.get_pixel(px, py) != dolu.get_pixel(px, py): farkli += 1
	check(farkli >= 25, "yildiz simgesi cizilir (%d piksel)" % farkli)
	# 9e) tarif siparisi balonu: yildizli simge (ayni sabit musteriyle yildizsiz siparisten farkli)
	gun_kur(20.0, {"sauce": 1.0})
	G = game.j_G
	T.f_durum().bulunan = ["acili"]
	var m1 := musteri([{"kind": "wrap", "sauce": "hot"}])
	var m2 := musteri(siparis("acili"))
	m1.bubble = 1.0; m2.bubble = 1.0; m1.x = 120.0; m2.x = 360.0; m1.y = 150.0; m2.y = 150.0
	cv.fillStyle = "#000000"; cv.fillRect(0, 0, 480, 270)
	game.order_draw.f_drawOrderBubble(m1, 1.0)
	game.order_draw.f_drawOrderBubble(m2, 1.0)
	var bal: Image = game.screen_canvas.image.duplicate()
	var r1: Rect2 = game.order_draw.order_bubble_rect(m1)
	var r2: Rect2 = game.order_draw.order_bubble_rect(m2)
	var altin := 0
	var altin_yok := 0
	for py in range(int(r2.position.y), int(r2.end.y)):
		for px in range(int(r2.position.x), int(r2.end.x)):
			var col: Color = bal.get_pixel(px, py)
			if absf(col.r - 1.0) < 0.03 and absf(col.g - 0.824) < 0.03 and absf(col.b - 0.29) < 0.05: altin += 1
	for py in range(int(r1.position.y), int(r1.end.y)):
		for px in range(int(r1.position.x), int(r1.end.x)):
			var col2: Color = bal.get_pixel(px, py)
			if absf(col2.r - 1.0) < 0.03 and absf(col2.g - 0.824) < 0.03 and absf(col2.b - 0.29) < 0.05: altin_yok += 1
	check(altin >= 12 and altin_yok == 0, "tarif balonunda altin yildiz var, normal siparis balonunda yok (%d / %d)" % [altin, altin_yok])
	# 9f) sesli / kumanda etiketi tarifi adiyla soyler
	check(game.stations.order_label(m2.items[0]).begins_with("Baba'nın Acılısı"), "siparis etiketi tarif adiyla: %s" % game.stations.order_label(m2.items[0]))
	check(game.stations.order_label(m1.items[0]).begins_with("Dürüm"), "normal siparis etiketi degismez: %s" % game.stations.order_label(m1.items[0]))
