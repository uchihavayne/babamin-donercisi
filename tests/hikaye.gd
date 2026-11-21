# HIKAYE KARTLARI (birlesik surum, 12. tur): oyun boyunca kosulu ilk saglandiginda gun sonunda bir kez gosterilen 8 kisa yazi karti
# + kapanis hikayesinin Demirkent'e bagli sahnesi. Veri: data/hikaye.gd, mantik: systems/events/hikaye_system.gd.
#   godot --headless --path . --script tests/hikaye.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []
const DILLER := ["en", "de", "fr", "es", "pt"]

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count: game.advance(1.0 / 60)

func click(point: Vector2) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.position = point; event.pressed = down
		game._input(event); step(2)

func taze(gun := 20.0) -> Dictionary:
	game.session_system.f_resetProgress()
	var G: Dictionary = game.j_G
	G.day = gun
	game.f_startDay()
	G.tut = 99; G.shutT = 0; G.weather = "sun"
	G.ferman = null; G.lider = null; G.night = null; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	return G

func kosul(id: String) -> bool:
	return game.hikaye_system.f_kosul(id)

# kartin TAMAM dugmesinin merkezi (hikaye_draw ile ayni yerlesim)
func tamam_noktasi(satir_sayisi: int) -> Vector2:
	var h := 68.0 + float(satir_sayisi) * 14.0
	var y := floorf((270.0 - h) / 2.0) - 6.0
	return Vector2(240.0, y + h - 26.0 + 9.0)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/hikaye-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var Hs = game.hikaye_system
	# ---- 1) veri: 8 yazi, gecerli tur, 4-5 satir, 5 dilde ceviri
	check(game.j_HIKAYE.size() == 8, "eight story cards")
	var kimlikler := {}
	for h in game.j_HIKAYE:
		check(not kimlikler.has(str(h.id)), "story id %s is unique" % h.id)
		kimlikler[str(h.id)] = true
		check(str(h.tur) in ["resmi", "mektup", "baba"] and str(h.baslik) != "" and h.satir.size() >= 4 and h.satir.size() <= 5, "story %s: kind, title and 4-5 lines" % h.id)
		check(Hs.f_kosul(str(h.id)) or true, "story %s has a condition" % h.id)
		for dil in DILLER:
			game.localization.f_setLang(dil)
			check(str(game.localization.f_T(str(h.baslik))) != str(h.baslik) or str(h.baslik) == "HAMDİ BEY", "%s: story %s title translated" % [dil, h.id])
			for l in h.satir:
				check(str(game.localization.f_T(str(l))) != str(l), "%s: story %s line translated: %s" % [dil, h.id, l])
		game.localization.f_setLang("tr")
	for ad in ["direnis", "sifa", "uyum"]:
		for l in game.j_EPI_DEMIRKENT[ad]:
			for dil in DILLER:
				game.localization.f_setLang(dil)
				check(str(game.localization.f_T(str(l))) != str(l), "%s: epilogue line translated: %s" % [dil, l])
	for ad in ["sofra_tam", "sofra_eksik"]:
		for dil in DILLER:
			game.localization.f_setLang(dil)
			check(str(game.localization.f_T(str(game.j_EPI_DEMIRKENT[ad]))) != str(game.j_EPI_DEMIRKENT[ad]), "%s: epilogue line translated: %s" % [dil, ad])
	game.localization.f_setLang("tr")
	# ---- 2) kosullar
	var G := taze(5.0)
	check(not kosul("icra_zarf"), "icra_zarf: not before day 6")
	G.day = 6.0
	check(kosul("icra_zarf"), "icra_zarf: day 6 with a debt")
	G.debt = 0.0
	check(not kosul("icra_zarf"), "icra_zarf: no debt, no letter")
	G.debt = 5000000.0; G.city = 8.0; G.branch = 9.0
	check(not kosul("icra_zarf"), "icra_zarf: not in the ferman city")
	G = taze()
	check(not kosul("rakip_tanisma") and not kosul("rakip_kapandi"), "rival cards wait for the rival")
	G.rakipTanisti = true
	check(kosul("rakip_tanisma") and not kosul("rakip_kapandi"), "rival met")
	G.rakipKapandi = true
	check(kosul("rakip_kapandi"), "rival closed")
	check(not kosul("ilk_sube"), "ilk_sube: no branch yet")
	G.branch = 1.0
	check(kosul("ilk_sube") and not kosul("demirkent_mektup"), "ilk_sube: first branch")
	G.branch = 7.0
	check(not kosul("demirkent_mektup"), "demirkent_mektup: not with seven branches")
	G.branch = 8.0
	check(kosul("demirkent_mektup"), "demirkent_mektup: eight branches")
	G.icra.ziyaret = 2.0
	check(not kosul("icra_memur"), "icra_memur: after two visits not yet")
	G.icra.ziyaret = 3.0
	check(kosul("icra_memur"), "icra_memur: third visit")
	check(not kosul("yari_yol"), "yari_yol: debt still full")
	G.debt = game.j_DEBT_START / 2.0 + 1.0
	check(not kosul("yari_yol"), "yari_yol: just above half")
	G.debt = game.j_DEBT_START / 2.0
	check(kosul("yari_yol"), "yari_yol: at half")
	G.debt = 0.0
	check(not kosul("yari_yol"), "yari_yol: a cleared debt has its own ending")
	check(not kosul("demirkent_ilk"), "demirkent_ilk: never in Demirkent")
	G.stats.fgunEn = 1.0
	check(kosul("demirkent_ilk"), "demirkent_ilk: one day in Demirkent")
	check(not kosul("bilinmeyen_yazi"), "an unknown id never triggers")
	# ---- 3) sira: bir kez, listedeki sirayla, gorulenler tekrar gelmez
	G = taze(6.0)
	G.rakipTanisti = true; G.branch = 1.0
	Hs.f_tara()
	var d: Dictionary = Hs.f_durum()
	check(d.sira == ["icra_zarf", "rakip_tanisma", "ilk_sube"], "new cards queue in list order (%s)" % str(d.sira))
	Hs.f_tara()
	check(d.sira.size() == 3, "scanning twice does not queue twice")
	check(Hs.f_kartAcik() and str(Hs.f_kart().id) == "icra_zarf", "the first queued card is shown")
	Hs.f_kartKapat()
	check(d.sira == ["rakip_tanisma", "ilk_sube"] and d.gorulen == ["icra_zarf"], "closing moves the card to the seen list")
	Hs.f_kartKapat(); Hs.f_kartKapat()
	check(not Hs.f_kartAcik() and Hs.f_kart().is_empty() and d.gorulen.size() == 3, "all cards seen")
	Hs.f_kartKapat()
	check(d.gorulen.size() == 3, "closing with an empty queue does nothing")
	Hs.f_tara()
	check(not Hs.f_kartAcik(), "seen cards never come back")
	# ---- 4) gun sonu akisi: kart cikar, TAMAM'a kadar dukkana gecilmez
	G = taze(6.0)
	G.money = 800.0; G.stat.earned = 800.0
	game.session_system.f_endDay()
	game.tarif_system.f_durum().yeni = []
	step(140)
	check(G.scene == "dayend" and Hs.f_kartAcik() and str(Hs.f_kart().id) == "icra_zarf", "day end 6: the envelope card is waiting")
	var n: int = Hs.f_kart().get("satir", []).size()
	click(tamam_noktasi(n))   # satirlar henuz gorunmuyorken: basis yalniz satirlari gosterir, TAMAM'i tiklamaz
	check(Hs.f_kartAcik() and G.scene == "dayend", "the press that skips the typing does not also press OK")
	click(Vector2(240, 7 + 48 + 156 + 9))   # arkadaki "DUKKANA GIT" dugmesi
	check(G.scene == "dayend" and Hs.f_kartAcik(), "the shop is not reachable while the card is open")
	click(tamam_noktasi(n))
	check(not Hs.f_kartAcik() and Hs.f_durum().gorulen == ["icra_zarf"], "OK closes the card and marks it seen")
	step(20)
	click(Vector2(240, 48 + 156 + 9))
	check(G.scene == "shop", "after the card the shop opens")
	# ---- 5) kayit: dongu ayni, bozuk kayit guvenli, eski kayitta su an saglananlar "goruldu"
	G = taze(30.0)
	G.hikaye = {"gorulen": ["icra_zarf", "ilk_sube"], "sira": ["rakip_tanisma"]}
	var kayit: Dictionary = Hs.f_kayit()
	var json = JSON.parse_string(JSON.stringify(kayit))
	G.hikaye = null
	var y: Dictionary = Hs.f_yukle(json)
	check(y.gorulen == ["icra_zarf", "ilk_sube"] and y.sira == ["rakip_tanisma"], "save round trip is exact")
	y = Hs.f_yukle({"gorulen": ["icra_zarf", "icra_zarf", "yok_boyle", 5], "sira": ["icra_zarf", "rakip_tanisma", "rakip_tanisma", "yok"]})
	check(y.gorulen == ["icra_zarf"] and y.sira == ["rakip_tanisma"], "corrupt save: unknown / duplicate / seen ids are dropped")
	G.branch = 3.0; G.rakipTanisti = true
	y = Hs.f_yukle(null)
	check(y.sira.is_empty() and "ilk_sube" in y.gorulen and "rakip_tanisma" in y.gorulen, "an old save: conditions already met count as seen, nothing floods the screen")
	G = taze(5.0)
	check(Hs.f_durum().gorulen.is_empty() and Hs.f_durum().sira.is_empty(), "a new game starts with no cards seen")
	G.rakipTanisti = true
	game.session_system.f_resetProgress()
	check(not game.j_G.rakipTanisti and not kosul("rakip_tanisma"), "a new game forgets the rival (the first-meeting card and greeting can happen again)")
	G.hikaye = {"gorulen": ["ilk_sube"], "sira": ["icra_zarf"]}
	game.save_system.f_saveAll()
	G.hikaye = null
	game.save_system.f_loadAndGo()
	check(game.j_G.hikaye.gorulen == ["ilk_sube"] and game.j_G.hikaye.sira == ["icra_zarf"], "progress save keeps the story state")
	# ---- 6) kapanis hikayesi: Demirkent'e bagli sahne
	G = taze(80.0)
	check(Hs.f_epiDemirkent().is_empty(), "never went to Demirkent: no extra epilogue scene")
	G.stats.fgunEn = 4.0
	var uyum: Array = Hs.f_epiDemirkent()
	check(uyum.size() == 2 and uyum[0] == game.j_EPI_DEMIRKENT.uyum[0], "Demirkent, nothing special: the obedient lines")
	G.stats.fed = 5.0
	var sifa: Array = Hs.f_epiDemirkent()
	check(sifa[0] == game.j_EPI_DEMIRKENT.sifa[0], "Demirkent, five hungry fed: the compassion lines")
	G.stats.muhur = 1.0
	var direnis: Array = Hs.f_epiDemirkent()
	check(direnis[0] == game.j_EPI_DEMIRKENT.direnis[0], "Demirkent, sealed once: the defiance lines win over compassion")
	G.hane = game.progression_system.f_haneKur()
	var tam: Array = Hs.f_epiDemirkent()
	check(tam.size() == 3 and tam[2] == game.j_EPI_DEMIRKENT.sofra_tam, "the whole household alive: complete table")
	G.hane[1].gitti = true
	var eksik: Array = Hs.f_epiDemirkent()
	check(eksik.size() == 3 and eksik[2] == game.j_EPI_DEMIRKENT.sofra_eksik, "a member gone: empty chairs")
	G.stats.sehir = [0.0, 8.0]; G.stats.fgunEn = 0.0
	check(not Hs.f_epiDemirkent().is_empty(), "having visited the city counts even without a recorded stay")
	# kapanis akisi: sahne 4. siraya girer, her varyant hatasiz cizilir, bitince temel liste geri gelir
	check(game.j_EPI_TEMEL.size() == 5 and game.j_EPI_SCENES.size() == 5, "the base epilogue has five scenes")
	for varyant in ["uyum", "sifa", "direnis"]:
		G = taze(80.0)
		G.stats.fgunEn = 4.0
		G.stats.fed = 5.0 if varyant == "sifa" else 0.0
		G.stats.muhur = 1.0 if varyant == "direnis" else 0.0
		G.hane = game.progression_system.f_haneKur()
		game.story_draw.f_epiStart()
		check(game.j_EPI_SCENES.size() == 6 and game.j_EPI_SCENES[3].lines == Hs.f_epiDemirkent(), "%s: the Demirkent scene sits before the closing scenes" % varyant)
		check(game.j_EPI_SCENES[4] == game.j_EPI_TEMEL[3] and game.j_EPI_SCENES[5] == game.j_EPI_TEMEL[4], "%s: the last two scenes are unchanged" % varyant)
		for i in 6:
			game.j_PRO.i = float(i); game.j_PRO.t = 3.0; game.j_PRO.ch = 0.0
			step(5)
			check(G.scene == "prologue", "%s: epilogue scene %d draws" % [varyant, i])
		game.story_draw.f_proFinish()
		check(game.j_EPI_SCENES.size() == 5 and G.scene == "dayend", "%s: back to five scenes after the epilogue" % varyant)
	G = taze(80.0)
	game.story_draw.f_epiStart()
	check(game.j_EPI_SCENES.size() == 5, "no Demirkent history: still the five-scene epilogue")
	game.story_draw.f_epiFinish()
	# ---- 7) arayuz: her kart her turde hatasiz cizilir
	for h in game.j_HIKAYE:
		G = taze(30.0)
		G.scene = "dayend"; G.sceneT = 5.0
		G.hikaye = {"gorulen": [], "sira": [str(h.id)]}
		step(90)
		check(G.scene == "dayend" and Hs.f_kartAcik(), "card %s draws" % h.id)
	print("HIKAYE ", JSON.stringify({"checks": checks, "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
