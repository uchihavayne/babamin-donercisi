# ICRA (birlesik surum, 12. tur): borc taksiti gunluk kesilmez, BIRIKIR; haftada bir sabah icra memuru kasadan tahsil eder;
# kasa yetmezse IHTAR, ust uste ikincisinde KEPENK MUHURU (gun atlar). Bkz. scripts/systems/events/icra_system.gd.
#   godot --headless --path . --script tests/icra.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

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

func taze(gun := 12.0) -> Dictionary:
	game.session_system.f_resetProgress()
	game.j_G.day = gun
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.weather = "sun"
	game.j_G.ferman = null; game.j_G.lider = null; game.j_G.night = null
	return game.j_G

# bir icra sabahi kur: kasa, birikmis taksit; ziyareti calistir. Dondurur: sonuc kaydi (ya da {})
func sabah(kasa: float, birikim: float, gun := 12.0) -> Dictionary:
	var G := taze(gun)
	G.money = kasa
	G.icra.birikim = birikim
	game.icra_system.f_sabahZiyareti()
	var s: Variant = G.icra.get("sonuc")
	# ziyaret olmadiysa: hicbir kontrolun tutmayacagi bir kayit (bos sozluk eksik alanlarla testi cokertirdi)
	return s if s is Dictionary else {"durum": "yok", "istenen": -1.0, "odenen": -1.0, "eksik": -1.0, "zam": -1.0, "atla": -1.0, "ilk": false}

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/icra-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var I = game.icra_system
	# ---- 1) taksit birikir (gunluk kesilmez)
	var G := taze(6.0)
	G.money = 1000.0; G.stat.earned = 1000.0
	game.session_system.f_endDay()
	check(G.money == 1000.0 and G.debt == 5000000.0, "day six: nothing is taken from the till at day end")
	check(G.icra.birikim == 180.0 and G.stat.taksitBirikti == 180.0 and G.stat.debtPaid == 0.0, "day six: 18 percent accrues (180 of 1000)")
	G = taze(5.0)
	G.money = 1000.0; G.stat.earned = 1000.0
	game.session_system.f_endDay()
	check(G.icra.birikim == 0.0, "no installment accrues in the first five days")
	G = taze(8.0)
	G.money = 500.0; G.stat.earned = 500.0
	game.session_system.f_endDay()
	G.day = 9.0; G.stat.earned = 300.0
	game.session_system.f_endDay()
	check(G.icra.birikim == 90.0 + 54.0, "accrual adds up over days (90 + 54)")
	G = taze(8.0)
	G.city = 8.0; G.branch = 9.0   # Demirkent (ferman): icra yok
	G.money = 500.0; G.stat.earned = 500.0
	game.session_system.f_endDay()
	check(G.icra.birikim == 0.0 and not I.f_aktif() and not I.f_sabahZiyareti(), "no icra in the ferman city")
	# ---- 2) vade: 13. gun sabahi (12. gunun dukkan cubugu)
	G = taze(11.0)
	G.money = 900.0; G.icra.birikim = 300.0
	check(not I.f_sabahZiyareti() and G.money == 900.0 and not I.f_kartAcik(), "day 11 evening: the first visit is not due yet (day 13 morning)")
	check(I.f_kalanGun() == 2 and I.f_yaklasti(2) and not I.f_yaklasti(1), "two mornings left on day 11; warning window is 2")
	G.day = 12.0
	check(I.f_kalanGun() == 1 and I.f_yaklasti(1), "day 12 evening: the visit is tomorrow morning")
	# ---- 3) kasa yeter: hesap tamam
	var s := sabah(2000.0, 500.0)
	var G2: Dictionary = game.j_G
	check(s.get("durum") == "tamam" and s.odenen == 500.0 and s.eksik == 0.0 and s.istenen == 500.0, "enough cash: account settled")
	check(G2.money == 1500.0 and G2.debt == 5000000.0 - 500.0 and G2.icra.birikim == 0.0 and G2.icra.ihtar == 0.0, "settled: cash and debt move, accrual empties")
	check(G2.icra.sonraki == 20.0 and s.ilk and I.f_kartAcik(), "settled: next visit a week later (day 20); card open; first visit flagged")
	check(G2.stat.debtPaid == 500.0, "the collection shows as today's installment")
	I.f_kartKapat()
	check(not I.f_kartAcik() and I.f_gunAtla() == 1.0, "closing the card: a plain next day")
	# ---- 4) ilk kusur: ihtar, gecikme zammi, kasadaki kadar tahsilat
	s = sabah(300.0, 1000.0)
	G2 = game.j_G
	check(s.durum == "ihtar" and s.odenen == 300.0 and s.eksik == 700.0 and s.zam == 350.0, "short cash: all the cash is taken, 50 percent late fee on the rest, WARNING")
	check(G2.money == 0.0 and G2.icra.birikim == 1050.0 and G2.icra.ihtar == 1.0 and G2.icra.ihtarSayisi == 1.0 and G2.icra.atla == 0.0, "warning: remainder + fee keep accruing, no seal yet")
	check(G2.debt == 5000000.0 - 300.0, "the taken cash reduces the debt")
	# ---- 5) ust uste ikinci kusur: kepenk muhru; sureler 2, 3, 4, 4
	var beklenen := [2.0, 3.0, 4.0, 4.0]
	G2.day = 19.0
	for k in 4:
		G2.money = 10.0
		G2.icra.birikim = 1000.0
		G2.icra.ihtar = 1.0
		G2.icra.sonraki = G2.day + 1.0
		I.f_kartKapat()
		check(I.f_sabahZiyareti(), "seal %d: card opens" % (k + 1))
		var sm: Dictionary = G2.icra.sonuc if G2.icra.sonuc is Dictionary else {"durum": "yok", "atla": -1.0}
		check(sm.durum == "muhur" and sm.atla == beklenen[k], "seal %d lasts %d days" % [k + 1, int(beklenen[k])])
		check(G2.icra.ihtar == 0.0 and G2.icra.muhur == float(k + 1), "seal %d: warning resets, seal count grows" % (k + 1))
		check(G2.icra.sonraki == G2.day + 1.0 + 7.0 + beklenen[k], "seal %d: the next visit is a FULL week after the reopening" % (k + 1))
		check(I.f_sonrakiGun() == G2.day + 1.0 + beklenen[k], "seal %d: the day button shows the reopening day" % (k + 1))
		check(I.f_gunAtla() == 1.0 + beklenen[k] and I.f_gunAtla() == 1.0, "seal %d: the day jump applies once" % (k + 1))
		G2.day += 1.0 + beklenen[k]
	# ---- 6) temiz hafta ihtari siler; kucuk eksik (yuvarlama payi) kusur sayilmaz
	s = sabah(3000.0, 1000.0)
	G2 = game.j_G
	G2.icra.ihtar = 1.0
	G2.icra.sonuc = null; G2.money = 3000.0; G2.icra.birikim = 1000.0; G2.icra.sonraki = 13.0
	I.f_sabahZiyareti()
	check(G2.icra.ihtar == 0.0 and G2.icra.sonuc is Dictionary and G2.icra.sonuc.durum == "tamam", "a clean week clears the warning")
	s = sabah(985.0, 1000.0)
	G2 = game.j_G
	check(s.durum == "tamam" and s.eksik == 15.0 and G2.icra.birikim == 15.0 and G2.icra.ihtar == 0.0, "a shortfall within 2 percent is not a fault; it keeps accruing")
	s = sabah(600.0, 1000.0)
	check(s.durum == "ihtar" and s.eksik == 400.0, "a 40 percent shortfall is a fault")
	# ---- 7) elle odeme once birikmis taksitten duser
	G = taze(10.0)
	G.money = 1000.0; G.icra.birikim = 500.0
	game.branch_draw.f_payDebt(300.0)
	check(G.icra.birikim == 200.0 and G.debt == 5000000.0 - 300.0 and G.money == 700.0, "manual payment settles the accrued installment first")
	check(I.f_taksitiOde() and G.icra.birikim == 0.0 and G.money == 500.0, "the INSTALLMENT button pays exactly the accrued amount")
	check(not I.f_taksitiOde(), "nothing accrued: the INSTALLMENT button does nothing")
	# ---- 8) son taksit: borcun tamami birikmis ve kasadaysa memur beklemez
	G = taze(40.0)
	G.debt = 50.0; G.money = 5000.0; G.stat.earned = 5000.0
	game.session_system.f_endDay()
	check(G.debt == 0.0 and G.debtCleared and G.celeb is Dictionary and not I.f_kartAcik(), "last installment clears the debt at day end with a celebration (no card)")
	G = taze(40.0)
	G.debt = 50.0; G.money = 10.0; G.stat.earned = 5000.0
	game.session_system.f_endDay()
	check(G.debt == 50.0 and G.icra.birikim == 50.0 and not G.debtCleared, "last installment waits when the till cannot cover it")
	# ---- 9) borc yokken / ferman sehrinde ziyaret yok; bos hafta sessiz
	G = taze(30.0)
	G.money = 500.0; G.icra.sonraki = 13.0; G.icra.birikim = 0.0
	check(not I.f_sabahZiyareti() and not I.f_kartAcik() and G.icra.sonraki == 38.0, "nothing accrued: the visit passes silently and is rescheduled")
	G.debt = 0.0
	check(not I.f_aktif() and I.f_kalanGun() == -1 and not I.f_yaklasti(3), "no icra once the debt is gone")
	# ---- 10) kayit: donguyle ayni, bozuk / eski kayit guvenli
	G = taze(20.0)
	G.icra = {"birikim": 1234.0, "sonraki": 27.0, "ihtar": 1.0, "muhur": 2.0, "atla": 2.0, "ziyaret": 3.0, "ihtarSayisi": 4.0, "sonuc": {"durum": "ihtar"}}
	var kayit: Dictionary = I.f_kayit()
	check(not kayit.has("sonuc") and kayit.birikim == 1234.0 and kayit.muhur == 2.0, "the save drops the UI card")
	var json = JSON.parse_string(JSON.stringify(kayit))
	G.icra = null
	var y: Dictionary = I.f_yukle(json, 20.0)
	check(y.birikim == 1234.0 and y.sonraki == 27.0 and y.ihtar == 1.0 and y.muhur == 2.0 and y.atla == 2.0 and y.ziyaret == 3.0 and y.ihtarSayisi == 4.0 and y.sonuc == null, "save round trip is exact")
	y = I.f_yukle({"birikim": -5.0, "sonraki": "x", "ihtar": 7.0, "atla": 99.0, "muhur": NAN}, 20.0)
	check(y.birikim == 0.0 and y.sonraki == 13.0 and y.ihtar == 1.0 and y.atla == 4.0 and y.muhur == 0.0, "corrupt save fields are sanitized")
	y = I.f_yukle(null, 20.0)
	check(y.sonraki == 27.0 and y.birikim == 0.0, "an old save (no icra data) starts a week after the load day")
	y = I.f_yukle(null, 3.0)
	check(y.sonraki == 13.0, "an old save at an early day keeps the first-visit day")
	G = taze(5.0)
	check(G.icra.birikim == 0.0 and G.icra.sonraki == 13.0 and G.icra.muhur == 0.0, "a new game starts with a clean icra state")
	# ilerleme kaydi gercekten yazar / okur
	G.icra.birikim = 777.0; G.icra.ihtar = 1.0; G.icra.sonraki = 26.0
	game.save_system.f_saveAll()
	G.icra = null
	game.save_system.f_loadAndGo()
	check(game.j_G.icra.birikim == 777.0 and game.j_G.icra.ihtar == 1.0 and game.j_G.icra.sonraki == 26.0, "progress save keeps the installment, warning and schedule")
	# ---- 11) arayuz: dukkan cubugundaki gun dugmesi memur kartini acar; TAMAM gunu baslatir
	for durum in ["tamam", "ihtar", "muhur"]:
		G = taze(12.0)
		G.scene = "shop"; G.sceneT = 5.0
		G.money = 3000.0 if durum == "tamam" else 10.0
		G.icra.birikim = 500.0
		G.icra.ihtar = 1.0 if durum == "muhur" else 0.0
		step(3)
		click(Vector2(449, 13))   # sag ustteki "GUN 13" dugmesi
		check(I.f_kartAcik() and G.scene == "shop" and G.day == 12.0, "%s: the day button opens the icra card; the day has not started" % durum)
		check(I.f_kartAcik() and G.icra.sonuc.durum == durum, "%s: the card outcome" % durum)
		step(40)   # kart cizimi hatasiz (ses / sarsinti ilk karede)
		click(Vector2(240, 200))   # TAMAM
		var beklenen_gun := 13.0 + (2.0 if durum == "muhur" else 0.0)
		check(not I.f_kartAcik() and G.day == beklenen_gun and (G.scene == "intro" or G.scene == "night"), "%s: OK starts the day (%d)" % [durum, int(beklenen_gun)])
	# icra yoksa dugme dogrudan gunu baslatir
	G = taze(8.0)
	G.scene = "shop"; G.sceneT = 5.0; G.money = 100.0
	step(3)
	click(Vector2(449, 13))
	check(not I.f_kartAcik() and G.day == 9.0 and (G.scene == "intro" or G.scene == "night"), "no icra due: the day button starts the next day directly")
	# gun sonu, dukkan, oyun ici ve odeme paneli cizimleri her durumda hatasiz
	G = taze(11.0)
	G.money = 800.0; G.icra.birikim = 500.0; G.stat.earned = 400.0
	game.session_system.f_endDay()
	step(120)
	check(G.scene == "dayend", "day end with accrual draws")
	G.scene = "shop"; G.sceneT = 5.0; step(30)
	game.j_PAYP.open = true; step(30); game.j_PAYP.open = false
	G.day = 14.0; G.scene = "play"; step(30)
	check(G.scene == "play" or G.scene == "dayend", "play HUD with the icra tag draws")
	var rapor := {"checks": checks, "failures": failures}
	print("ICRA ", JSON.stringify(rapor))
	game.free(); quit(0 if failures.is_empty() else 1)
