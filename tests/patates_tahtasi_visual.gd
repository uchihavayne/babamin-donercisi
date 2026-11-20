# PATATES TAHTASI, GPU PIKSELLERI (birlesik surum, 12. tur). Kullanici: "patates kesme tahtasini daha buyuk, genis,
# anlasilabilir yap ama diger upgradeler geldiginde ustuste binmesinler". Mantik / olcu testi: tests/tezgah_yerlesim.gd.
# Bu test GERCEK GPU tuvalinde pikselleri olcer (oyun donduruldu: yalniz advance(0) ile cizilir, otomasyon calismaz):
#  1) HD acik; tahta eskisinden genis cizilir (sprite genisligi ~63 px = 126 HD piksel)
#  2) HICBIR upgrade tahtanin kutusuna piksel koymaz: tahta durumu ayni tutulup upgrade'siz kareyle her upgrade'in tek tek ve
#     hepsinin maksimum oldugu kare karsilastirilir, tahta kutusu icinde FARK YOK
#  3) tahta kendi kutusunun DISINA tasmaz: bos tahta ile "patates + dilimler + dolu celik kap + sayac" tahtasi karsilastirilir
#     (tum upgrade'ler acikken), farklar tahta kutusunun icinde kalir
#  4) dolu tahtada celik kapta cubuklar cizilir (bos ve dolu tahta birbirinden gercekten farkli); ayni durum ayni goruntuyu verir
#   godot --path . --script tests/patates_tahtasi_visual.gd --quit-after 3000 -- --test --gpu-test
extends SceneTree
var shell: Control
var g: Node
var failures: Array[String] = []
var checks := 0
var olc := {}
# Olcum penceresi (HD piksel): sos / kagit / tahta / fritoz / izgara / kutu sirasi ve tezgah kenari. Disarida birakilanlar oyun durmusken
# de kareler arasi DEGISIR: sokak sahnesi (cam, arabalar, yayalar; ayni durumda bile ~170 bin piksel) ve doner (shaders/sis.gdshader
# parilti / titreme icin motorun TIME'ini kullanir; alt kismi y >= 300'e iner). Kutudan tasma olcumu bu yuzden yalniz bu pencerede yapilir.
const TEZGAH_PENCERESI := Rect2i(560, 300, 400, 240)

func _initialize() -> void:
	create_timer(170.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

# pencere goruntusu degil, oyunun KENDI 960x540 HD tuvali (SubViewport): kenar boslugu / olcekleme olmadan, mantik px x 2 = HD px
func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return shell.game_viewport.get_texture().get_image()

# yeni gun kurar (verilen upgrade seviyeleriyle), tahta durumunu verir, oyunu DONDURUP bir kare cizer
func kare(up: Dictionary, patates: bool, ilerleme: float, ham: float) -> Image:
	g.random_state = 123456                    # gun kurulumu ve cizim ayni rastgele diziyle: arka plan suslemeleri kareler arasi sabit
	g.session_system.f_resetProgress()
	g.j_G.prologueSeen = true
	g.j_G.up = up.duplicate()
	g.f_startDay()
	var G: Dictionary = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.hintT = 0; G.timeLeft = 100000
	G.customers = []; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	G.meat = 12; G.friesTray = 12
	for k in G.stock.keys():
		G.stock[k] = 12; G.stockAnim[k] = 12
	g.j_BSQ.kuyruk = []
	G.flyP = null; G.flyF = null
	G.cut.potato = patates; G.cut.prog = ilerleme; G.cut.raw = ham; G.cut.land = 0.0; G.cut.cutting = false
	G.cut.slash = []
	# otomatik fritoz (fryer 4. kademe) hazir cubuklari aninda alip ucurur: fritozu "kizartiyor" durumunda dondur, tahta durumu degismesin
	G.fryer.state = "fry"; G.fryer.t = 0.0; G.fryer.dur = 99999.0; G.fryer.load = 3.0
	g.random_state = 777
	g.j_IN.x = 2.0; g.j_IN.y = 2.0             # imlec tezgah bolgesinin disinda, sabit
	g.advance(0.0)
	await process_frame
	return await goruntu()

func tahta_kutusu() -> Rect2i:
	var c: Dictionary = g.j_ST.cut
	return Rect2i(int(c.x * 2.0), int(c.y * 2.0), int(c.w * 2.0), int(c.h * 2.0))

# iki goruntu arasinda, pencere icinde farkli piksel sayisi (HD piksel)
func fark(a: Image, b: Image, pencere: Rect2i, esik: float = 0.02) -> int:
	var n := 0
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik: n += 1
	return n

# fark piksellerinin ilk birkac konumu (teshis icin)
func fark_konumlari(a: Image, b: Image, pencere: Rect2i, adet: int = 6, esik: float = 0.02) -> Array:
	var out: Array = []
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik:
				out.append(Vector2i(x, y))
				if out.size() >= adet: return out
	return out

# teshis: TAHTA_DUMP=<klasor> verilirse kareleri ve fark maskesini PNG olarak yazar (kirmizi = fark)
func dokum(ad: String, a: Image, b: Image = null) -> void:
	var klasor := OS.get_environment("TAHTA_DUMP")
	if klasor == "": return
	a.save_png("%s/%s.png" % [klasor, ad])
	if b == null: return
	var m := Image.create(960, 540, false, Image.FORMAT_RGB8)
	for y in 540:
		for x in 960:
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			m.set_pixel(x, y, Color(1, 0, 0) if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > 0.02 else ca * 0.5)
	m.save_png("%s/%s_fark.png" % [klasor, ad])

# iki goruntu arasinda FARKLI piksellerin sinir kutusu (pencere icinde)
func fark_kutusu(a: Image, b: Image, pencere: Rect2i, esik: float = 0.02) -> Rect2i:
	var x0 := 100000; var y0 := 100000; var x1 := -1; var y1 := -1
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik:
				x0 = mini(x0, x); y0 = mini(y0, y); x1 = maxi(x1, x); y1 = maxi(y1, y)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1) if x1 >= 0 else Rect2i()

func run() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.set_process(false)                       # oyun kendiliginden ilerlemez: otomasyon (otomatik dograyici / fritoz) tahtayi degistirmez
	g.set_process_input(false)                 # gercek fare / dokunma olaylari imleci ve ustune gelme vurgularini oynatmasin (xvfb'de pencere
	shell.set_process_input(false)             # acilirken gelen ilk fare hareketi bir karenin imlecini oynatip olcumu bozabiliyordu)
	shell.set_process_unhandled_input(false)
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	await process_frame
	check(g.hd_acik and g.hd_gpu() and g.t2_hd(), "HD acik, GPU tuvali var, yeni tezgah HD parcalari etkin")
	var kutu := tahta_kutusu()
	check(kutu.size.x >= 120 and kutu.size.y >= 72, "tahta kutusu genis: %s HD piksel (eskisi 102 x 74)" % str(kutu.size))
	# 1) tahta eskisinden genis cizilir: bos tahtanin acik tahta rengi (#d4ad73 / #e0bd88 / #986c40 ailesi) kapladigi yatay uzunluk
	var tum := {}
	for u in g.j_UPG: tum[u.id] = float(u.lv.size())
	var durumlar := {"bos": [false, 0.0, 0.0], "dolu": [true, 0.5, 14.0]}
	var temel := {}
	for ad in durumlar:
		var d: Array = durumlar[ad]
		temel[ad] = await kare({}, d[0], d[1], d[2])
	var ahsap := 0
	var satir_y: int = kutu.position.y + 16                 # tahta yuzeyinde, satir / patates / kabin ustunde bir yatay tarama
	for x in range(kutu.position.x + 2, kutu.end.x - 2):
		var c: Color = (temel["bos"] as Image).get_pixel(x, satir_y)
		if c.r - c.b > 0.2: ahsap += 1                          # tahta ahsabi sicak renklidir; tezgah celigi gridir
	olc["ahsap_genislik_hd"] = ahsap
	check(ahsap >= kutu.size.x - 8, "tahta sprite'i kutunun tamamini kaplar (%d / %d HD piksel; genisletme cizilmezse ~100)" % [ahsap, kutu.size.x])
	# 2) hicbir upgrade tahtanin kutusuna piksel koymaz (tek tek ve hepsi)
	var en_cok := 0
	var ihlal: Array = []
	var denemeler: Array = [["hepsi", tum, "bos"], ["hepsi", tum, "dolu"]]
	for u in g.j_UPG: denemeler.append([str(u.id), {u.id: float(u.lv.size())}, "dolu"])
	for dn in denemeler:
		var d: Array = durumlar[dn[2]]
		var img: Image = await kare(dn[1], d[0], d[1], d[2])
		var n := fark(img, temel[dn[2]], kutu)
		en_cok = maxi(en_cok, n)
		if n > 0: ihlal.append("%s/%s: %d px, ilk: %s" % [dn[2], dn[0], n, str(fark_konumlari(img, temel[dn[2]], kutu))])
	olc["upgrade_tahta_fark"] = en_cok
	check(ihlal.is_empty(), "upgrade'ler tahtanin kutusuna piksel koymaz (ihlal: %s)" % str(ihlal))
	# 3) tahta kendi kutusunun disina tasmaz (tum upgrade'ler acikken, komsular yerinde)
	var bos_t: Image = await kare(tum, false, 0.0, 0.0)
	var dolu_t: Image = await kare(tum, true, 0.5, 14.0)
	dokum("bos_dolu", bos_t, dolu_t)
	var fk := fark_kutusu(bos_t, dolu_t, TEZGAH_PENCERESI)
	olc["tahta_fark_kutusu"] = [fk.position.x, fk.position.y, fk.size.x, fk.size.y]
	check(fk.size.x > 0, "bos ve dolu tahta birbirinden farkli cizilir")
	check(kutu.encloses(fk), "tahta kendi kutusunun disina tasmaz: fark %s, kutu %s" % [str(fk), str(kutu)])
	# 4) bos tahtada soluk patates izi (potanin gelecegi yer), dolu tahtada kapta cubuk + sayac
	var kap: Vector2 = g.potato_system.f_kapNoktasi(g.j_ST.cut.x, g.j_ST.cut.y, g.j_ST.cut.w)
	var kap_hd := Rect2i(int(kap.x * 2.0), int(kap.y * 2.0), 32, 32)
	var kapta := fark(bos_t, dolu_t, kap_hd, 0.15)
	olc["kapta_fark"] = kapta
	check(kapta >= 150, "dolu tahtada celik kabin icinde cubuklar cizilir (%d px)" % kapta)
	var tekrar: Image = await kare(tum, false, 0.0, 0.0)
	var tekrar_fark := fark(bos_t, tekrar, TEZGAH_PENCERESI)
	olc["tekrar_fark"] = tekrar_fark
	check(tekrar_fark == 0, "ayni durum iki kez ayni goruntuyu verir (oyun donduruldu, olcum penceresi kararli): %d px" % tekrar_fark)
	print("OLCUM ", JSON.stringify(olc))
	for f in failures: push_error(f)
	print("PATATES TAHTASI GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
