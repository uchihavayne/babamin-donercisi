# PANEL / MOLA GECISLERI (birlesik surum, 12. tur, akicilik cilasi: "mola menusu ve paneller sert kesmeyle aciliyor").
# rendering/ui/modal_fx.gd: panellerin arka plan karartmasi tek yerden cizilir ve yumusak acilip soner, panel govdesi acilista
# ustten suzulup beliriverir. SALT GORSEL: oyun durumu, rastgele sayi ve tiklama dikdortgenleri degismez. GPU pikselleri
# (belirme, dinlenme karesinin bire bir ayni oldugu): tests/modal_fx_visual.gd. Bu test mantik / durum tarafini olcer:
#  1) saflik: ayni betikli mola / panel oturumu gecisli ve gecissiz (kapali_zorla) oynayinca oyun durumu (G) ve rastgele sayi AYNI
#  2) mola karartmasi: acilista 0'dan yumusak artar, DIM_ACIL icinde tam hedefe (0,62) VARIR; ilk kare hedefin yarisindan az
#  3) paneller arasi gecis (mola <-> ses): karartma ASLA 0'a dusmez (arada parlak kare yok), tam hedeflere varir
#  4) kapanis: mola -> oyun karartmayi soldurur (monoton), DIM_KAPA'dan sonra tam 0; kapaninca arkasinda artik kalmaz
#  5) baslik ekrani: tabani da ayni yerden (0,52); ilk kare anlik oturur (acilis fade'i yok); panel acilinca 0,52 -> 0,84
#     asla altina dusmeden, kapaninca geri; baslik <-> basarim cift cizimi tek ilerleme sayar
#  6) sahne degisimi: mola -> baslik anlik oturur; karartmasiz sahnelerde (giris, gun sonu) sonme sizmaz
#  7) panel girisi: ilk kare -14 px, tam sayi adimlar, hafif asma (<= 2 px) ve tam 0'a oturma; save / restore dengeli
#  8) girdi ayni: dugme / panel dikdortgenleri gecis sirasinda dinlenme degerleriyle BIREBIR ayni
#  9) kanca: kapali_zorla ya da HD_KAPALI=panel_gecis eski sert kesmeyi geri getirir (karartma hemen hedefte, kayma yok, sonme yok)
# 10) tick yokken (dogrudan cizim) her sey anlik; ic ice f_basla yalniz en disi kaydirir; yeniden acilis gecikmeyle baslar
# 11) dinlenme: gecis bitince cizim kanca kapaliyken cizilenle BIREBIR ayni (karartma + panel pikselleri)
#   godot --headless --path . --script tests/modal_fx.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []
var checks := 0
const DT := 1.0 / 60

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n: game.advance(DT)

# hermetik karsilastirma icin: her kosu yepyeni bir oyunla baslar (trafik / sokak sayaclari onceki kosudan artik tasimaz)
func taze_oyun() -> Node:
	var g: Node = load("res://scripts/platform_game.gd").new()
	g.storage.path = "res://artifacts/modal-fx-save.json"; g.storage.values = {}
	root.add_child(g); g.set_process(false); g.j_MUTED = true
	g.localization.f_setLang("tr")
	return g

func kur() -> void:
	game.random_state = 424242
	game.clock_ms = 0.0; game.j__last = 0.0   # kare saati her kurulumda sifirdan (ms kayan nokta gurultusu karsilastirmayi bozmasin)
	game.session_system.f_resetProgress()
	game.j_G.prologueSeen = true
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.t = 0.0; G.sceneT = 0.0; G.bsT = 0.0   # saate bagli sayaclar (parlayan dugme, basarim taramasi...) her kurulumda ayni fazdan baslasin
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	for p in [game.j_SESP, game.j_STATS, game.j_BSP, game.j_CUSTOM, game.j_PAYP, game.j_BRP, game.j_TARIFP]: p.open = false
	game.modal_fx.kapali_zorla = false
	game.modal_fx._gor = 0.0; game.modal_fx._hedef = 0.0; game.modal_fx._t = game.modal_fx._sure
	game.modal_fx._pk = ""; game.modal_fx._p_kare = -9; game.modal_fx._pt = 99.0
	step(3)

# n kare ilerletip her karenin karartma opakligini dondurur
func dim_seri(n: int) -> Array:
	var s: Array = []
	for i in n:
		step()
		s.append(game.modal_fx._gor)
	return s

func kayma_seri(n: int) -> Array:
	var s: Array = []
	for i in n:
		step()
		s.append(game.modal_fx._kayma_son)
	return s

func monoton(a: Array, artan: bool) -> bool:
	for i in range(1, a.size()):
		if artan and float(a[i]) < float(a[i - 1]) - 1e-9: return false
		if not artan and float(a[i]) > float(a[i - 1]) + 1e-9: return false
	return true

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/modal-fx-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var M = game.modal_fx
	var G: Dictionary
	kur(); G = game.j_G
	var KARE_ACIL: int = int(ceil(M.DIM_ACIL / DT)) + 1
	var KARE_KAPA: int = int(ceil(M.DIM_KAPA / DT)) + 1

	# modul cagrilari rastgele sayi CEKMEZ
	var rs0: int = game.random_state
	M.f_tick(DT); M.f_dim(0.5, "#000000"); M.f_basla("x"); M.f_bitir(); M.f_son()
	check(game.random_state == rs0, "f_tick / f_dim / f_basla / f_bitir / f_son rastgele sayi cekmez")
	M._gor = 0.0; M._hedef = 0.0; M._t = M._sure; M._pk = ""; M._p_kare = -9

	# 2) mola karartmasi
	check(M._gor == 0.0, "oyun sahnesinde karartma yok")
	G.scene = "pause"
	var s: Array = dim_seri(KARE_ACIL + 4)
	check(float(s[0]) > 0.0 and float(s[0]) < 0.62 * 0.5, "mola acilisi ilk kare hedefin yarisindan az (%.3f)" % float(s[0]))
	check(monoton(s, true), "mola karartmasi acilirken monoton artar")
	check(float(s[KARE_ACIL - 1]) == 0.62, "mola karartmasi DIM_ACIL icinde TAM 0,62'ye varir (%s)" % str(s[KARE_ACIL - 1]))
	check(float(s[-1]) == 0.62, "dinlenme: karartma tam 0,62 (eski sert kesmeyle ayni deger)")

	# 3) paneller arasi gecis: mola <-> ses (karartma asla 0'a dusmez)
	game.j_SESP.open = true
	s = dim_seri(KARE_ACIL + 4)
	var altinda := false
	for v in s:
		if float(v) < 0.62 - 1e-9: altinda = true
	check(not altinda, "mola -> ses: karartma 0,62'nin altina dusmez (arada parlak kare yok)")
	check(monoton(s, true) and float(s[-1]) == 0.84, "mola -> ses: 0,62'den 0,84'e monoton, tam 0,84 (%s)" % str(s[-1]))
	game.j_SESP.open = false
	s = dim_seri(KARE_KAPA + 6)
	var ustunde := false
	for v in s:
		if float(v) > 0.84 + 1e-9 or float(v) < 0.62 - 1e-9: ustunde = true
	check(not ustunde and monoton(s, false) and float(s[-1]) == 0.62, "ses -> mola: 0,84'ten 0,62'ye monoton, hicbir an 0,62'nin altina inmez (%s)" % str(s[-1]))

	# 4) kapanis: mola -> oyun
	G.scene = "play"
	s = dim_seri(KARE_KAPA + 3)
	check(float(s[0]) > 0.0 and float(s[0]) < 0.62, "kapanisin ilk karesinde karartma hala var, hedeften az (%.3f)" % float(s[0]))
	check(monoton(s, false), "mola -> oyun: karartma monoton soner")
	check(float(s[KARE_KAPA - 1]) == 0.0 and float(s[-1]) == 0.0, "DIM_KAPA'dan sonra karartma TAM 0")
	check(not M._cagrildi, "oyun sahnesinde panel karartmasi cagrilmaz")

	# 5) baslik ekrani
	G.scene = "title"
	step()
	check(M._gor == 0.52, "baslik ekrani ilk karede karartmasi anlik oturur (acilis fade'i yok): %s" % str(M._gor))
	step(30)
	game.j_SESP.open = true
	s = dim_seri(KARE_ACIL + 4)
	altinda = false
	for v in s:
		if float(v) < 0.52 - 1e-9: altinda = true
	check(not altinda and monoton(s, true) and float(s[-1]) == 0.84, "baslik -> ses paneli: 0,52'den 0,84'e monoton, 0,52'nin altina dusmez (%s)" % str(s[-1]))
	game.j_SESP.open = false
	s = dim_seri(KARE_KAPA + 6)
	check(monoton(s, false) and float(s[-1]) == 0.52, "ses paneli -> baslik: 0,84'ten tam 0,52'ye (%s)" % str(s[-1]))
	# baslik <-> basarim: panel ayni karede iki kez cizilir (f_drawTitle + f_drawTitleBasarim); ilerleme tek sayilir
	game.j_BSP.open = true
	step()
	var pt1: float = M._pt
	step()
	check(absf(M._pt - pt1 - DT) < 1e-6, "ayni karede iki kez cizilen panel tek karelik ilerler (pt %.4f -> %.4f)" % [pt1, M._pt])
	step(40)
	check(M._gor == 0.84 and M._kayma_son == 0.0, "baslik + basarim dinlenmede: karartma 0,84, kayma 0")
	game.j_BSP.open = false
	step(40)

	# 6) sahne degisimi
	G.scene = "pause"; game.j_SESP.open = true
	step(40)
	check(M._gor == 0.84, "mola + ses: karartma 0,84")
	game.j_SESP.open = false
	G.scene = "title"
	step()
	check(M._gor == 0.52, "mola -> baslik: karartma anlik 0,52'ye oturur (sahne degisince fade yok): %s" % str(M._gor))
	G.scene = "pause"
	step(40)
	check(M._gor == 0.62, "baslik -> mola: karartma 0,62'de")
	G.scene = "intro"
	step()
	check(M._gor == 0.0, "karartmasiz sahnede (giris) onceki karartma sizmaz")
	G.scene = "dayend"
	step(3)
	check(M._gor == 0.0, "gun sonu sahnesinde karartma 0")
	kur(); G = game.j_G

	# 7) panel girisi
	G.scene = "pause"
	step(40)
	game.j_SESP.open = true
	var k: Array = kayma_seri(int(ceil(M.PANEL_SURE / DT)) + 4)
	check(float(k[0]) == -14.0, "panel girisi ilk karede -14 px (%s)" % str(k[0]))
	var tam := true
	var asma := 0.0
	for v in k:
		if float(v) != roundf(float(v)): tam = false
		asma = maxf(asma, float(v))
	check(tam, "kayma hep tam sayi (piksel kaymasi / onbellek taşkini yok)")
	check(asma > 0.0 and asma <= 2.0, "panel hafif asar ve oturur (en fazla %s px)" % str(asma))
	check(float(k[-1]) == 0.0 and float(k[-3]) == 0.0, "panel tam 0'a oturur")
	check(game.j_ctx.stack.size() == 0, "save / restore dengeli (yigin bos)")
	game.j_SESP.open = false
	step(3)

	# 8) girdi ayni: izle listesi (dugme / panel dikdortgenleri) gecis sirasinda dinlenmeyle ayni
	step(40)
	game.j_STATS.open = false
	game.text_draw.izle = []
	game.j_SESP.open = true
	step()   # gecisin ilk karesi
	var ilk: Array = game.text_draw.izle.duplicate()
	step(40)
	game.text_draw.izle = []
	step()
	var son: Array = game.text_draw.izle.duplicate()
	game.text_draw.izle = null
	check(ilk.size() > 0 and ilk == son, "gecis sirasinda dugme / panel dikdortgenleri dinlenmeyle BIREBIR ayni (%d kayit)" % ilk.size())
	game.j_SESP.open = false
	step(40)

	# 10) tick yok / ic ice / yeniden acilis
	var yeni = M.get_script().new(game)
	yeni.f_dim(0.7, "#000000")
	check(yeni._kayma == 0.0 and yeni._gor == 0.7, "tick hic cagrilmadiysa karartma anlik hedefte, kayma yok (dogrudan cizim yolu)")
	yeni.f_basla("a"); yeni.f_basla("b"); yeni.f_bitir(); yeni.f_bitir()
	check(yeni._p_derin == 0 and not yeni._kayma_acik, "tick yokken f_basla / f_bitir dengeli ve kaydirmaz")
	yeni = M.get_script().new(game)
	yeni.f_tick(DT)
	yeni.f_basla("a"); var disk: float = yeni._kayma
	yeni.f_basla("b")
	check(yeni._kayma == disk and yeni._p_derin == 2, "ic ice f_basla yalniz en disi kaydirir")
	yeni.f_bitir()
	check(yeni._kayma_acik, "ic f_bitir dis panelin kaymasini bozmaz")
	yeni.f_bitir()
	check(not yeni._kayma_acik and yeni._kayma == 0.0, "dis f_bitir kaymayi geri alir")
	# ayni panel, arada BASKA panel yokken (dukkan sahnesi gibi) kapanip yeniden acilirsa bastan baslar (kare bosluguyla anlasilir)
	yeni = M.get_script().new(game)
	for i in 5:
		yeni.f_tick(DT); yeni.f_basla("a"); yeni.f_bitir()
	var pt_acik: float = yeni._pt
	check(pt_acik > 0.0 and yeni._pk == "a", "panel birkac kare acik kaldi (pt %.3f)" % pt_acik)
	for i in 3: yeni.f_tick(DT)   # 3 kare panel cizilmedi
	yeni.f_tick(DT); yeni.f_basla("a"); yeni.f_bitir()
	check(yeni._pt == 0.0 and yeni._kayma_son == -14.0, "ayni panel kapanip yeniden acilinca (arada baska panel yokken) bastan baslar (pt %.3f)" % yeni._pt)
	# kapanma yok (her karede cizilir): ilerler
	yeni.f_tick(DT); yeni.f_basla("a"); yeni.f_bitir()
	check(absf(yeni._pt - DT) < 1e-6, "kesintisiz cizilen panel ilerler")
	# yeniden acilis: kapaliyken >= 2 kare gecince bastan baslar; ayni karede degisen panel de bastan baslar
	kur(); G = game.j_G
	G.scene = "pause"; step(40)
	game.j_SESP.open = true; step(40)
	check(M._pt >= M.PANEL_SURE, "panel oturdu")
	game.j_SESP.open = false; step(3)
	game.j_SESP.open = true; step()
	check(M._pt == 0.0 and M._kayma_son == -14.0, "kapanip yeniden acilan panel bastan baslar")
	step(40)
	game.j_SESP.open = false; game.j_STATS.open = true; step()
	check(M._pk == "rekor" and M._pt == 0.0, "panel degisince giris bastan baslar (mola / ses -> rekor)")
	game.j_STATS.open = false

	# 9) kanca
	kur(); G = game.j_G
	M.kapali_zorla = true
	G.scene = "pause"
	s = dim_seri(4)
	check(float(s[0]) == 0.62, "kanca kapaliyken karartma ilk karede hedefte (sert kesme)")
	game.j_SESP.open = true
	k = kayma_seri(6)
	check(k.all(func(v: float) -> bool: return v == 0.0), "kanca kapaliyken panel kaymaz")
	game.j_SESP.open = false
	G.scene = "play"
	s = dim_seri(3)
	check(s.all(func(v: float) -> bool: return v == 0.0), "kanca kapaliyken kapanista sonme yok (hemen 0)")
	M.kapali_zorla = false
	var eski_kapali: PackedStringArray = game._hd_kapali
	game._hd_kapali = PackedStringArray(["panel_gecis"])
	G.scene = "pause"
	s = dim_seri(2)
	check(float(s[0]) == 0.62, "HD_KAPALI=panel_gecis de ayni etkiyi yapar")
	game._hd_kapali = eski_kapali
	G.scene = "play"; step(20)

	# 1) saflik: ayni betik gecisli / gecissiz -> G ve rastgele sayi ayni
	var sonuclar: Array = []
	var ana_oyun: Node = game
	for kapali in [false, true]:
		game = taze_oyun()
		kur(); G = game.j_G
		game.modal_fx.kapali_zorla = kapali
		game.random_state = 99
		var betik := [["scene", "pause"], 12, ["ses", true], 9, ["ses", false], 6, ["stats", true], 14, ["stats", false], 4, ["scene", "play"], 30,
			["scene", "pause"], 3, ["scene", "play"], 20, ["scene", "title"], 20, ["bsp", true], 25, ["bsp", false], 5, ["scene", "pause"], 5, ["scene", "play"], 20]
		for o in betik:
			if o is int: step(o)
			elif o[0] == "scene": game.j_G.scene = o[1]
			elif o[0] == "ses": game.j_SESP.open = o[1]
			elif o[0] == "stats": game.j_STATS.open = o[1]
			elif o[0] == "bsp": game.j_BSP.open = o[1]
		game.j_SESP.open = false; game.j_STATS.open = false; game.j_BSP.open = false
		sonuclar.append([JSON.stringify(game.j_G), game.random_state, game.j_G.t])
		game.queue_free()
	game = ana_oyun
	var gfark := ""
	if sonuclar[0][0] != sonuclar[1][0]:
		var ja: Dictionary = JSON.parse_string(sonuclar[0][0])
		var jb: Dictionary = JSON.parse_string(sonuclar[1][0])
		for kk in ja:
			if JSON.stringify(ja[kk]) != JSON.stringify(jb.get(kk)): gfark += " " + str(kk)
	check(sonuclar[0][0] == sonuclar[1][0], "oyun durumu (G) gecisli ve gecissiz AYNI (farkli alanlar:%s)" % gfark)
	check(sonuclar[0][1] == sonuclar[1][1], "rastgele sayi durumu AYNI (gecis rastgele sayi cekmez)")
	game.modal_fx.kapali_zorla = false

	# 11) dinlenme pikselleri: gecis bitince cizim kanca kapaliyken cizilenle BIREBIR ayni (CPU tuvali, 480 x 270)
	var olcek := {}
	for kapali in [false, true]:
		kur(); G = game.j_G
		game.modal_fx.kapali_zorla = kapali
		for durum in ["mola", "ses", "rekor", "baslik+basarim"]:
			game.j_SESP.open = false; game.j_STATS.open = false; game.j_BSP.open = false
			match durum:
				"mola": G.scene = "pause"
				"ses": G.scene = "pause"; game.j_SESP.open = true
				"rekor": G.scene = "pause"; game.j_STATS.open = true
				"baslik+basarim": G.scene = "title"; game.j_BSP.open = true
			step(45)
			game.random_state = 5
			game.advance(0.0)   # donuk kare (sahne animasyonlari ilerlemeden)
			game.j_ctx.ensure()
			olcek[[kapali, durum]] = game.j_ctx.image.duplicate()
		game.j_SESP.open = false; game.j_STATS.open = false; game.j_BSP.open = false
	for durum in ["mola", "ses", "rekor", "baslik+basarim"]:
		var a: Image = olcek[[false, durum]]
		var b: Image = olcek[[true, durum]]
		# pencere panelin ICINDE (kirli / hareketli sahne arka plani degil: sokak ve doner kareler arasi oynar)
		var pencere := Rect2i(100, 60, 280, 150)
		if durum == "mola": pencere = Rect2i(180, 70, 120, 120)
		elif durum == "ses": pencere = Rect2i(140, 64, 200, 130)
		var fark := 0
		var kutu := Rect2i(100000, 100000, -100000, -100000)
		for y in range(pencere.position.y, pencere.end.y):
			for x in range(pencere.position.x, pencere.end.x):
				if a.get_pixel(x, y) != b.get_pixel(x, y):
					fark += 1
					kutu = kutu.expand(Vector2i(x, y))
		check(fark == 0, "dinlenme karesi kanca kapaliyla BIREBIR ayni: %s (%d farkli piksel, kutu %s)" % [durum, fark, str(kutu)])

	var ozet := {"checks": checks, "failures": failures}
	print("MODAL FX ", JSON.stringify(ozet))
	game.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
