# KESME EFEKTI, GPU PIKSELLERI (birlesik surum, 12. tur). Kullanici: "patatesi keserken patates havaya mi ucsun, guzel kesilme
# efekti ve animasyonu olsa, goze guzel gelen". Mantik / "oyunu degistirmez" kilidi: tests/kesme_efekt.gd. Bu test GERCEK
# GPU tuvalinde pikselleri olcer (oyun donuk: yalniz advance(0) ile cizilir; efekt durumu elle ve guncelleme cagrisiyla surulur):
#  1) dinlenme: hicbir efekt yokken kare efektsiz (kd_kapali) kareyle AYNI (efekt dinlenme gorunumunu degistirmez)
#  2) vurus ezilmesi: patates vurus anında ezilir (kare dinlenmeden farkli), fark patatesin kutusunda kalir
#  2b) BUTUN PATATES havada: vurustan sonra patates tahtanin ustune yukselir (eski ust kenarinin ustunde patates pikselleri belirir),
#     altinda golge kalir; vuruslar bitince ve yere inince kare dinlenmeye BIREBIR doner (egik cizim yolu dahil, artik yok)
#  3) ziplayan dilim: havadayken dilim yerinde cizilmez ve havada cizilir (fark var), tahtanin kutusunun disina tasmaz;
#     inince kare dinlenme karesine BIREBIR doner (tek piksel artik yok)
#  4) patates bitince: dilimler havaya firlar (tahtanin ustune cikar), sayac inene kadar eski degeri gosterir; hepsi inince kare
#     "patates bitmis, raw dolu" dinlenme karesiyle BIREBIR ayni (parcacik / dilim / sayac artigi yok)
#  5) eski cizim (HD kapali) da ayni efekti piksel dilimlerle gosterir ve artik birakmaz
#  6) kanca adi "kesme_efekt" (HD_KAPALI) efekti tek basina kapatir: aktif efekt durumu bile dinlenme karesiyle ayni cikar
#  7) ayni durum ayni goruntuyu verir
#   godot --path . --script tests/kesme_efekt_visual.gd --quit-after 3000 -- --test --gpu-test
extends SceneTree
var shell: Control
var g: Node
var P: Variant
var failures: Array[String] = []
var checks := 0
var olc := {}
# Olcum penceresi (HD piksel): tahta ve cevresi. Doner (shaders/sis.gdshader TIME kullanir) ve sokak sahnesi oyun durmusken de kareler
# arasi degisir; ikisi de pencerenin disinda (bkz. tests/patates_tahtasi_visual.gd).
const PENCERE := Rect2i(560, 300, 400, 240)

func _initialize() -> void:
	create_timer(170.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return shell.game_viewport.get_texture().get_image()

# gunu kurar, tahta durumunu verir (efekt durumu bos), HIC cizmez
func hazirla(patates: bool, ilerleme: float, ham: float) -> void:
	g.random_state = 123456
	g.session_system.f_resetProgress()
	g.j_G.prologueSeen = true
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
	G.fryer.state = "fry"; G.fryer.t = 0.0; G.fryer.dur = 99999.0; G.fryer.load = 3.0
	P.f_kesimEfektTemizle()
	g.j_PS.clear()

# mevcut durumu (efekt durumu dahil) donuk olarak cizer ve goruntuyu verir
func ciz() -> Image:
	g.random_state = 777
	g.j_IN.x = 2.0; g.j_IN.y = 2.0
	g.advance(0.0)
	await process_frame
	return await goruntu()

func fark(a: Image, b: Image, pencere: Rect2i, esik: float = 0.02) -> int:
	var n := 0
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik: n += 1
	return n

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

func kutu_hd() -> Rect2i:
	var c: Dictionary = g.j_ST.cut
	return Rect2i(int(c.x * 2.0), int(c.y * 2.0), int(c.w * 2.0), int(c.h * 2.0))

func patates_kutu_hd() -> Rect2i:
	var c: Dictionary = g.j_ST.cut
	return Rect2i(int((c.x + 5.0) * 2.0), int((c.y + 9.0) * 2.0), 52, 40)     # tahtanin sol yarisi: patates + kesik yuz

func guncelle(sn: float, adim: float = 1.0 / 60.0) -> void:
	var kalan := sn
	while kalan > 0.0001:
		var d := minf(adim, kalan)
		P.f_kesimEfektGuncelle(d)
		kalan -= d

func serisini_dene(etiket: String, ham: float, hd: bool) -> void:
	# --- ortak: dinlenme kareleri (efekt yok)
	g.hd_acik = hd
	hazirla(true, 0.3, ham)
	var rest_patates: Image = await ciz()                         # patates tahtada, 2 dilim, raw dolu
	hazirla(true, 0.45, ham)
	var rest_3: Image = await ciz()                               # 3 dilim
	hazirla(false, 0.0, ham)
	var rest_bitti: Image = await ciz()                           # patates bitmis, raw dolu
	# 1) kd_kapali ile dinlenme karesi ayni
	hazirla(true, 0.3, ham)
	P.kd_kapali = true
	var kapali: Image = await ciz()
	P.kd_kapali = false
	check(fark(rest_patates, kapali, PENCERE) == 0, "%s: dinlenmede efekt kapali ile acik kare ayni" % etiket)
	# 2) vurus ezilmesi
	hazirla(true, 0.3, ham)
	P.f_kesimVurus()
	P.f_kesimEfektGuncelle(0.03)                                  # ezilme tepede
	var ezik: Image = await ciz()
	var ez_fark := fark(rest_patates, ezik, PENCERE)
	olc["%s_ezilme_fark" % etiket] = ez_fark
	check(ez_fark >= 6, "%s: vurus aninda patates ezilir (%d piksel farkli)" % [etiket, ez_fark])
	check(kutu_hd().encloses(fark_kutusu(rest_patates, ezik, PENCERE)), "%s: ezilme tahtanin kutusundan tasmaz: %s" % [etiket, str(fark_kutusu(rest_patates, ezik, PENCERE))])
	guncelle(1.0)
	var ezik_sonra: Image = await ciz()
	check(fark(rest_patates, ezik_sonra, PENCERE) == 0, "%s: ezilme bitince kare dinlenmeye birebir doner" % etiket)
	# 2b) havada asili patates
	hazirla(true, 0.3, ham)
	P.f_kesimVurus()
	guncelle(0.1)                                                 # 6 kare: yaklasik 7 px yukseklik
	var yuk: float = P.kd_py
	var havada_p: Image = await ciz()
	dokum("%s_dinlenme_patates" % etiket, rest_patates)
	dokum("%s_havada_patates" % etiket, havada_p, rest_patates)
	var tc: Dictionary = g.j_ST.cut
	check(yuk > 4.0 and absf(P.kd_pa) > 0.01, "%s: patates havada ve egik (yukseklik %.2f px, egim %.3f)" % [etiket, yuk, P.kd_pa])
	var ust_y: float = float(tc.y) + (11.5 if hd else 12.5)                  # patatesin dinlenmedeki ust kenari (mantik px)
	var ust_bolge := Rect2i(int((float(tc.x) + (8.0 if hd else 22.0)) * 2.0), int((ust_y - yuk) * 2.0) + 2, 30, int(yuk * 2.0) + 4)
	var ust_fark := fark(rest_patates, havada_p, ust_bolge)
	olc["%s_havada_ust_fark" % etiket] = ust_fark
	check(ust_fark >= 40, "%s: patates dinlenme konumunun ustunde de cizilir, yani havaya kalkmis (%d piksel farkli)" % [etiket, ust_fark])
	check(yuk > 5.5 and yuk < 11.0, "%s: vuruslar bir sure surunce patates ~6-9 px havada (%.2f px)" % [etiket, yuk])
	# alt kenar: patatesin dinlenmedeki ALT kismi bosalir (patates yukari cikti; ezilme alt kenari sabit tutar, yalniz egim bu kadar bosaltmaz)
	var alt_bolge := Rect2i(int((float(tc.x) + (8.0 if hd else 22.0)) * 2.0), int((float(tc.y) + (22.5 if hd else 21.0)) * 2.0), 30, 7 if hd else 6)
	var alt_fark := fark(rest_patates, havada_p, alt_bolge, 0.05)
	olc["%s_havada_alt_fark" % etiket] = alt_fark
	check(alt_fark >= 90, "%s: patatesin dinlenmedeki alt kismi bosalir, yani patates gercekten yukari cikmis (%d piksel farkli)" % [etiket, alt_fark])
	var golge_y: float = float(tc.y) + (27.0 if hd else 25.0)
	var golge_bolge := Rect2i(int((float(tc.x) + (10.0 if hd else 24.0)) * 2.0), int(golge_y * 2.0), 24, 4)
	var golge_fark := fark(rest_patates, havada_p, golge_bolge, 0.012)
	olc["%s_havada_golge_fark" % etiket] = golge_fark
	check(golge_fark >= 8, "%s: havadaki patatenin altinda golge kalir (%d piksel farkli)" % [etiket, golge_fark])
	check(kutu_hd().encloses(fark_kutusu(rest_patates, havada_p, PENCERE)) or fark_kutusu(rest_patates, havada_p, PENCERE).position.y >= kutu_hd().position.y - 24, "%s: havadaki patates tahtanin cevresinde kalir: %s" % [etiket, str(fark_kutusu(rest_patates, havada_p, PENCERE))])
	guncelle(1.5)
	g.j_PS.clear()
	var indi_p: Image = await ciz()
	var indi_fark := fark(rest_patates, indi_p, PENCERE)
	if indi_fark > 0: dokum("%s_indi_patates" % etiket, rest_patates, indi_p)
	check(P.kd_py == 0.0 and P.kd_pa == 0.0 and P.kd_inis == 0.0, "%s: vuruslar bitince patates indi ve tamamen durdu" % etiket)
	check(indi_fark == 0, "%s: inip durunca kare dinlenme karesine BIREBIR doner (artik %d piksel)" % [etiket, indi_fark])
	if hd:
		# bicak havadaki patatesin yuksekligini izler: ayni vurus fazinda, patates havadayken bicagin ust kismi (patatesin ustu) dolu, yereyken bos
		hazirla(true, 0.3, ham)
		g.j_G.cut.cutting = true; g.j_G.cut.hold = 1.0
		P.f_kesimVurus()
		guncelle(0.1)
		var bicakli: Image = await ciz()
		P.kd_py = 0.0; P.kd_pv = 0.0; P.kd_pa = 0.0; P.kd_pw = 0.0
		var bicaksiz: Image = await ciz()
		var bicak_bolge := Rect2i(int(P.f_kesikYuzX(0.3) * 2.0), int((float(tc.y) - 5.0) * 2.0), 16, 16)
		var bicak_fark := fark(bicakli, bicaksiz, bicak_bolge)
		olc["%s_bicak_izler_fark" % etiket] = bicak_fark
		check(bicak_fark >= 60, "%s: bicak havadaki patatesin yuksekligini izler (%d piksel farkli)" % [etiket, bicak_fark])
	# 3) ziplayan dilim: 2 dilimden 3 dilime
	hazirla(true, 0.3, ham)
	P.f_kesimEfektGuncelle(0.0)                                   # ilk gorus: kd_n = 2
	g.j_G.cut.prog = 0.45
	P.f_kesimEfektGuncelle(0.12)                                  # 3. dilim ziplamaya basladi (havada)
	var havada: Image = await ciz()
	var hv_fark := fark(rest_3, havada, PENCERE)
	olc["%s_zipla_fark" % etiket] = hv_fark
	check(P.kd_ucan.size() == 1 and P.f_dilimHavada(2), "%s: 3. dilim havada" % etiket)
	check(hv_fark >= 6, "%s: ziplayan dilim cizilir (%d piksel farkli)" % [etiket, hv_fark])
	# dilimin HAVADAKI konumunda (yerinden uzakta) dinlenme karesinde olmayan pikseller var: dilim gercekten orada cizilmis
	var hk: Variant = P.f_dilimKonum(P.kd_ucan[0])
	var hava_kutu := Rect2i(int(float(hk.x) * 2.0) - 5, int(float(hk.y) * 2.0) - 5, 10, 10)
	var hava_fark := fark(rest_3, havada, hava_kutu)
	olc["%s_zipla_hava_fark" % etiket] = hava_fark
	check(hava_fark >= 4, "%s: ziplayan dilim havadaki konumunda cizilir (%d piksel farkli)" % [etiket, hava_fark])
	if hd:
		# havadaki dilimin tahtadaki YERI bos kalir (ayni dilim ayni anda iki yerde gorunmez): yer kutusunda dinlenme karesinden fark var
		var yer: Vector2 = P.f_dilimYeri(2, P.f_kesikYuzX(0.45))
		var yer_hd := Rect2i(int((yer.x - 0.5) * 2.0), int((yer.y - 0.5) * 2.0), 8, 20)
		var bos_fark := fark(rest_3, havada, yer_hd)
		olc["%s_yer_bos_fark" % etiket] = bos_fark
		check(bos_fark >= 8, "%s: havadaki dilimin tahtadaki yeri bos (%d piksel farkli)" % [etiket, bos_fark])
	var hv_kutu := fark_kutusu(rest_3, havada, PENCERE)
	var genis := Rect2i(kutu_hd().position - Vector2i(8, 24), kutu_hd().size + Vector2i(16, 24))
	check(genis.encloses(hv_kutu), "%s: ziplayan dilim tahtanin cevresinde kalir (kutu %s, tahta %s)" % [etiket, str(hv_kutu), str(kutu_hd())])
	guncelle(0.5)
	g.j_PS.clear()
	var indi: Image = await ciz()
	check(P.kd_ucan.is_empty(), "%s: dilim indi" % etiket)
	check(fark(rest_3, indi, PENCERE) == 0, "%s: dilim inince kare dinlenme karesine BIREBIR doner (artik %d piksel)" % [etiket, fark(rest_3, indi, PENCERE)])
	# 4) patates bitince: dilimler havaya firlar
	hazirla(true, 0.9, 3.0)
	P.f_kesimEfektGuncelle(0.0)
	g.j_G.cut.potato = false; g.j_G.cut.prog = 0.0; g.j_G.cut.raw = ham
	P.f_kesimTamam(ham - 3.0)                                     # sayac simdilik eski degeri (3) gostermeli
	P.f_kesimEfektGuncelle(0.16)                                  # dilimler havada
	var ucus: Image = await ciz()
	var uc_fark := fark(rest_bitti, ucus, PENCERE)
	olc["%s_ucus_fark" % etiket] = uc_fark
	check(uc_fark >= 80, "%s: bitince dilimler havaya firlar, sayac ve kap degisir (%d piksel farkli)" % [etiket, uc_fark])
	var ucan_say := 0
	for c in P.kd_ucan:
		if float(c.t) < 0.03: continue
		var ck: Variant = P.f_dilimKonum(c)
		if ck == null or float(ck.k) < 0.15 or float(ck.k) > 0.85: continue
		var ck_kutu := Rect2i(int(float(ck.x) * 2.0) - 5, int(float(ck.y) * 2.0) - 5, 10, 10)
		if fark(rest_bitti, ucus, ck_kutu) >= 4: ucan_say += 1
	olc["%s_ucan_dilim" % etiket] = ucan_say
	check(ucan_say >= 2, "%s: havadaki dilimler konumlarinda cizilir (%d dilim goruldu)" % [etiket, ucan_say])
	var uc_kutu := fark_kutusu(rest_bitti, ucus, PENCERE)
	check(uc_kutu.position.y < kutu_hd().position.y + 24, "%s: dilimler tahtanin ust yarisina kadar yukselir (fark kutusu ust y %d, tahta ust y %d)" % [etiket, uc_kutu.position.y, kutu_hd().position.y])
	guncelle(1.0)
	g.j_PS.clear()
	var bitti: Image = await ciz()
	check(P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0, "%s: butun dilimler kaba indi" % etiket)
	var bit_fark := fark(rest_bitti, bitti, PENCERE)
	if bit_fark > 0: dokum("%s_bitti" % etiket, rest_bitti, bitti)
	check(bit_fark == 0, "%s: hepsi inince kare 'patates bitmis, raw dolu' dinlenme karesine BIREBIR doner (artik %d piksel)" % [etiket, bit_fark])
	# 6) kanca adi
	g._hd_kapali.append("kesme_efekt")
	hazirla(true, 0.3, ham)
	P.f_kesimVurus()
	P.f_kesimEfektGuncelle(0.03)
	var kancali: Image = await ciz()
	var kanca_fark := fark(rest_patates, kancali, PENCERE)
	check(kanca_fark == 0, "%s: kesme_efekt kancasi kapaliyken aktif efekt durumu bile gorunmez (%d piksel)" % [etiket, kanca_fark])
	g._hd_kapali.erase("kesme_efekt")
	# 7) determinizm
	hazirla(true, 0.45, ham)
	P.f_kesimEfektGuncelle(0.0)
	g.j_G.cut.prog = 0.6
	P.f_kesimEfektGuncelle(0.1)
	var d1: Image = await ciz()
	var d2: Image = await ciz()
	check(fark(d1, d2, PENCERE) == 0, "%s: ayni efekt durumu ayni goruntuyu verir (%d piksel)" % [etiket, fark(d1, d2, PENCERE)])

func run() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.set_process(false)                       # oyun kendiliginden ilerlemez; efekt durumu elle surulur
	g.set_process_input(false)
	shell.set_process_input(false)
	shell.set_process_unhandled_input(false)
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	P = g.potato_system
	await process_frame
	check(g.hd_acik and g.hd_gpu() and g.t2_hd(), "HD acik, GPU tuvali var, yeni tezgah HD parcalari etkin")
	await serisini_dene("HD", 40.0, true)
	await serisini_dene("eski", 40.0, false)
	g.hd_acik = true
	print("OLCUM ", JSON.stringify(olc))
	for f in failures: push_error(f)
	print("KESME EFEKT GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
