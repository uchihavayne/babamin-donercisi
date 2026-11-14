# GUN ICI KAYIT (birlesik surum, 11. tur, kullanici karari): mobilde uygulama
# isletim sistemince kapatilirsa devam eden gun kaybolmaz.
#  1) kaydet -> "uygulama kapandi" (yeni oyun nesnesi, ayni kayit dosyasi) -> Devam Et:
#     gun molada, kalinan yerden geri gelir (para, sure, musteriler, tahtadaki urun,
#     izgara, el, telefon siparisi) ve urunun siparis sahibi AYNI musteri nesnesidir
#  2) geri yuklenen gun oynanabilir (sure akar, musteri sabri azalir)
#  3) gun bitince / yeni oyunda / baska gunun kaydi / bozuk / eski surum / ogretici:
#     anlik goruntu kullanilmaz ya da silinir, Devam Et eskisi gibi giris kartina gider
#  4) arka plana alma (f_appPause) anlik goruntu yazar; ilerleme kaydi semasi degismez
#   godot --headless --path . --script tests/gun_ici_kayit.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var game2: Node
var failures: Array[String] = []
const YOL := "res://artifacts/gun-ici-kayit-save.json"

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(g: Node, n := 1) -> void:
	for i in n: g.advance(1.0 / 60)

func yeni_oyun() -> Node:
	var g: Node = load("res://scripts/platform_game.gd").new()
	g.storage.path = YOL
	root.add_child(g); g.set_process(false); g.j_MUTED = true
	g.localization.f_setLang("tr")
	return g

# "uygulama kapandi, yeniden acildi": ayni dosyadan okuyan yeni oyun nesnesi
func yeniden_ac() -> Node:
	# dosya OKUNUR, sonra oyun kurulur (kurulurken dil ayari dosyayi yeniden yazar)
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(YOL))
	var g := yeni_oyun()
	g.storage.values = d if d is Dictionary else {}
	return g

func zengin_gun(g: Node) -> void:
	g.session_system.f_resetProgress()
	for u in g.j_UPG: g.j_G.up[u.id] = float(u.lv.size())
	g.j_G.day = 14.0
	g.j_G.prologueSeen = true
	g.f_startDay()
	var G: Dictionary = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 0.5; G.meat = 12; G.friesTray = 8
	for k in G.stock.keys(): G.stock[k] = 12
	G.money = 1234.0
	G.inspect = null; G.rakip = null; G.kesinti = null
	G.kedi = {"faz": "bekle", "t": 0.0, "girisT": 0.0, "miyav": 0.0, "x": 200.0, "doydu": false}
	G.phone.state = "order"
	G.phone.order = [{"kind": "wrap", "sauce": "garlic", "yok": ["pickle"]}, {"kind": "drink", "type": "cola"}]
	G.phone.done = [false, false]
	g.f_newWrap()
	for i in 3: g.assembly_system.f_addMeat(); g.assembly_system.f_addIng("pickle"); g.assembly_system.f_addIng("yogurt"); g.assembly_system.f_addIng("fries")
	# bes musteri iceride bekler, ikisi kapida sirada (hizli kurulum: kareleri beklemeden)
	G.spawnT = 100000.0
	for i in 7: g.customer_system.f_spawnCustomer()
	for c in G.customers:
		if c.state == "walkin": c.state = "wait"; c.x = c.tx; c.bubble = 1.0
	step(g, 90)
	var musteri: Variant = null
	for c in G.customers:
		if c.state == "wait": musteri = c; break
	if musteri != null: g.order_select(musteri)
	G.hand = {"kind": "drink", "type": "fanta", "fill": 1.0}
	G.grill.slots.append({"w": {"kind": "wrap", "state": "rolled", "burnt": false, "meat": 4.0}, "t": 3.0, "dur": 8.0, "done": false, "yan": 0.0})
	G.timeLeft = 77.5
	step(g, 10)

# karsilastirma icin kanonik biçim: tam sayi -> ondalik (JSON geri yuklemede hepsi ondalik olur),
# kesirler 1e-6'ya yuvarlanir, istasyonun gecici kimligi (_station_uid) ve siparis sahibi
# (kimligi ayrica denenir) atilir
func norm(v: Variant) -> Variant:
	if v is Dictionary:
		var o := {}
		for k in v:
			if str(k) in ["_station_uid", "_order_owner"]: continue
			o[str(k)] = norm(v[k])
		return o
	if v is Array:
		var a := []
		for e in v: a.append(norm(e))
		return a
	if v is int or v is float: return snappedf(float(v), 0.000001)
	return v

func js(v: Variant) -> String: return JSON.stringify(norm(v), "", true)

# hafif gun: musteri / bekleme yok (yalniz kayit mekanigini denemek icin)
func hafif_gun(g: Node) -> void:
	g.session_system.f_resetProgress()
	g.j_G.day = 14.0
	g.j_G.prologueSeen = true
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 100000.0
	g.j_G.money = 777.0

func tum_etiket_yok(v: Variant) -> bool:
	if v is Dictionary:
		if v.has("\u0001"): return false
		for k in v:
			if not tum_etiket_yok(v[k]): return false
	elif v is Array:
		for e in v:
			if not tum_etiket_yok(e): return false
	return true

func run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(YOL))
	game = yeni_oyun()
	game.storage.values = {}
	# 1) kaydet -> yeniden ac -> Devam Et
	zengin_gun(game)
	var G: Dictionary = game.j_G
	check(G.customers.size() >= 2 and G.boards[0] != null, "kurulum: musteriler ve tahtada urun var (%d musteri)" % G.customers.size())
	var bagli: Variant = null
	for b in G.boards:
		if b is Dictionary and b.has("_order_owner"): bagli = b
	check(bagli != null, "kurulum: tahtadaki urun bir musterinin siparisine bagli")
	game.save_system.f_saveAll()
	check(game.save_system.gunici_kaydet(), "gunici_kaydet() true doner")
	check(tum_etiket_yok(G), "kayit sonrasi canli durumda gecici etiket kalmaz")
	check(game.storage.getItem(game.save_system.gunici_anahtar()) != null, "anlik goruntu ayri anahtarla yazildi")
	var onceki := {"money": float(G.money), "timeLeft": float(G.timeLeft), "musteri": G.customers.size(), "el": js(G.hand),
		"izgara": js(G.grill.slots), "stok": js(G.stock), "phone": js(G.phone),
		"stat": js(G.stat), "cop": float(G.trash), "gun": float(G.day), "kedi": js(G.kedi)}
	var durumlar: Array = []
	for c in G.customers: durumlar.append([c.state, int(c.slot), js(c.items), js(c.done), snappedf(float(c.patience), 0.001)])
	var tahtalar_once: Array = []
	for b in G.boards: tahtalar_once.append(null if b == null else js(b))
	var depo0: Dictionary = game.storage.values.duplicate(true)
	var anahtar: String = game.save_system.gunici_anahtar()
	game.free()
	game2 = yeniden_ac()
	var G2: Dictionary = game2.j_G
	check(str(G2.scene) == "title", "yeni acilista sahne baslik")
	game2.save_system.f_loadAndGo()
	check(str(G2.scene) == "pause", "Devam Et: gun molada geri gelir (sahne %s)" % G2.scene)
	check(float(G2.day) == onceki.gun and is_equal_approx(float(G2.money), onceki.money), "gun ve para ayni (%s / %s)" % [G2.day, G2.money])
	check(is_equal_approx(float(G2.timeLeft), onceki.timeLeft), "kalan sure ayni (%s)" % G2.timeLeft)
	check(G2.customers.size() == onceki.musteri, "musteri sayisi ayni (%d)" % G2.customers.size())
	for i in G2.customers.size():
		var c: Dictionary = G2.customers[i]
		check([c.state, int(c.slot), js(c.items), js(c.done), snappedf(float(c.patience), 0.001)] == durumlar[i], "musteri %d ayni (durum, yer, siparis, sabir)" % i)
	check(js(G2.hand) == onceki.el, "eldeki urun ayni")
	check(js(G2.grill.slots) == onceki.izgara, "izgaradaki urunler ayni")
	check(js(G2.stock) == onceki.stok and js(G2.phone) == onceki.phone, "stok ve telefon siparisi ayni")
	check(js(G2.stat) == onceki.stat and is_equal_approx(float(G2.trash), onceki.cop), "gunluk sayaclar ve cop ayni")
	check(js(G2.kedi) == onceki.kedi, "kedi ayni")
	var ayni_tahta := true
	for i in G2.boards.size():
		var b: Variant = G2.boards[i]
		var s2: Variant = null if b == null else js(b)
		if s2 != tahtalar_once[i]: ayni_tahta = false
	check(ayni_tahta, "tahtadaki urunler ayni")
	var bagli2: Variant = null
	for b in G2.boards:
		if b is Dictionary and b.has("_order_owner"): bagli2 = b
	var sahip_listede := false
	if bagli2 != null:
		for c in G2.customers: if is_same(c, bagli2._order_owner): sahip_listede = true
	check(bagli2 != null and sahip_listede, "tahtadaki urunun siparis sahibi AYNI musteri nesnesi (kimlik korunur)")
	check(tum_etiket_yok(G2), "geri yuklenen durumda gecici etiket yok")
	check(game2.storage.getItem(game2.save_system.gunici_anahtar()) == null, "geri yuklenince anlik goruntu silinir")
	# 2) oynanabilir: molada sure akmaz; devam edince akar
	var t0 := float(G2.timeLeft)
	step(game2, 30)
	check(is_equal_approx(float(G2.timeLeft), t0), "molada sure akmaz")
	G2.scene = "play"
	var sabir0 := float(G2.customers[0].patience)
	step(game2, 90)
	check(float(G2.timeLeft) < t0 - 1.0 and str(G2.scene) == "play", "devam edince sure akar (%s -> %s)" % [t0, G2.timeLeft])
	check(float(G2.customers[0].patience) != sabir0 or G2.customers[0].state != "wait", "musteri sabri / durumu ilerler")
	# eldeki ve tahtadaki urunler yine kullanilabilir: eldeki icecegi atmak
	game2.event_system.f_trashClick()
	check(G2.hand == null, "geri yuklenen elde urun cope atilabilir")
	# 3) gun bitince silinir
	game2.save_system.gunici_kaydet()
	check(game2.storage.getItem(game2.save_system.gunici_anahtar()) != null, "oynarken yeniden kaydedilir")
	game2.session_system.f_endDay()
	check(game2.storage.getItem(game2.save_system.gunici_anahtar()) == null, "gun bitince anlik goruntu silinir")
	# 4) gecersiz kayitlar kullanilmaz, Devam Et girise gider
	for durum in ["baska gun", "bozuk", "eski surum", "tahta sayisi"]:
		var depo: Dictionary = depo0.duplicate(true)
		var ham: String = str(depo[anahtar])
		var veri: Dictionary = JSON.parse_string(ham)
		match durum:
			"baska gun":
				veri["gun"] = 15.0
				depo[anahtar] = JSON.stringify(veri)
			"bozuk": depo[anahtar] = ham.substr(0, ham.length() / 2)
			"eski surum":
				veri["uygulama"] = "0.0.1"
				depo[anahtar] = JSON.stringify(veri)
			"tahta sayisi":
				veri["G"]["boards"].append(null)
				depo[anahtar] = JSON.stringify(veri)
		var f := FileAccess.open(YOL, FileAccess.WRITE)
		f.store_string(JSON.stringify(depo)); f.close()
		var g4 := yeniden_ac()
		g4.save_system.f_loadAndGo()
		check(str(g4.j_G.scene) == "intro", "[%s] gecersiz anlik goruntu: Devam Et giris kartina gider (sahne %s)" % [durum, g4.j_G.scene])
		check(g4.storage.getItem(anahtar) == null, "[%s] gecersiz anlik goruntu silinir" % durum)
		g4.free()
	# ogretici (1. gun) suruyorken kaydedilmez
	var g5 := yeni_oyun()
	g5.storage.values = {}
	g5.session_system.f_resetProgress()
	g5.j_G.prologueSeen = true
	g5.f_startDay()
	check(g5.gameplay_input.f_tutBusy() and not g5.save_system.gunici_kaydet(), "ogretici suruyorken gun ici kayit yazilmaz")
	g5.free()
	# yeni oyun / kayit silme anlik goruntuyu da siler
	var g6 := yeni_oyun()
	g6.storage.values = {}
	hafif_gun(g6)
	g6.save_system.gunici_kaydet()
	check(g6.storage.getItem(anahtar) != null, "yeni oyun testi icin anlik goruntu var")
	g6.f_clearSave()
	check(g6.storage.getItem(anahtar) == null, "kaydi silmek (Yeni Oyun) anlik goruntuyu de siler")
	hafif_gun(g6)
	g6.save_system.gunici_kaydet()
	g6.session_system.f_resetProgress()
	check(g6.storage.getItem(anahtar) == null, "f_resetProgress anlik goruntuyu siler")
	# 5) arka plana alma anlik goruntu yazar; ilerleme kaydi semasi ayni (yeni anahtar yalniz ek)
	hafif_gun(g6)
	g6.f_appPause()
	check(g6.storage.getItem(anahtar) != null and g6.storage.getItem(g6.j_SAVEKEY) != null, "arka plana alma: ilerleme kaydi + gun ici anlik goruntu")
	var ilerleme: Variant = JSON.parse_string(str(g6.storage.getItem(g6.j_SAVEKEY)))
	check(ilerleme is Dictionary and ilerleme.has("day") and ilerleme.has("money") and ilerleme.has("up") and not ilerleme.has("timeLeft"), "ilerleme kaydi eski semada (gun ici alanlar icermez)")
	g6.free()
	print("GUN ICI KAYIT ", JSON.stringify({"failures": failures}))
	game2.free(); quit(0 if failures.is_empty() else 1)
