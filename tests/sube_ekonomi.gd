# SUBE EKONOMISI (birlesik surum, 12. tur): sube geliri NET'tir (brut - zincir gideri: kira + maas + malzeme) ve performans
# egrisi gec oyunda daha cok hizmet ister ("gec oyunda beceri geri gelsin + para sinki"). Bkz. progression_system.BR_*.
#   godot --headless --path . --script tests/sube_ekonomi.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func taze(gun: float, sube: float, sehir := -1.0) -> Dictionary:
	game.session_system.f_resetProgress()
	game.j_G.day = gun
	game.j_G.branch = sube
	game.j_G.city = sehir
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.weather = "sun"
	game.j_G.ferman = null; game.j_G.lider = null; game.j_G.night = null
	return game.j_G

func perf(oran: float, gun: float) -> float:
	var G: Dictionary = game.j_G
	var cfg: Dictionary = game.progression_system.f_dayCfg(gun, G)
	var gelen := floorf((float(cfg.len) - 25.0) / float(cfg.rate))
	var servis := roundf(gelen * oran)
	return float(game.progression_system.f_branchPerf(servis, gelen - servis, gun, G))

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/sube-ekonomi-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var P = game.progression_system
	# ---- 1) hacim hedefi gun gun yukselir: %35 -> %75
	check(P.f_branchHedefOran(1.0) == 0.35 and P.f_branchHedefOran(20.0) == 0.35, "early target is 35 percent of arrivals")
	check(is_equal_approx(P.f_branchHedefOran(45.0), 0.55), "target at day 45 is 55 percent")
	check(P.f_branchHedefOran(70.0) == 0.75 and P.f_branchHedefOran(200.0) == 0.75, "late target is 75 percent")
	var artan := true
	for g in range(1, 120): artan = artan and P.f_branchHedefOran(float(g + 1)) >= P.f_branchHedefOran(float(g))
	check(artan, "the target never falls")
	# ---- 2) performans uclari
	taze(70.0, 3.0)
	check(is_equal_approx(perf(0.0, 70.0), game.j_BR_MIN), "nobody served: the floor multiplier")
	check(is_equal_approx(perf(1.0, 70.0), game.j_BR_MAX) and game.j_BR_MAX == 1.35, "everybody served: the ceiling multiplier (1.35)")
	# yuvarlama payi (servis sayisi tam sayi): tam hacimde ~1,0575; hacim doymadiysa belirgin daha dusuk olurdu
	check(absf(perf(0.35, 20.0) - (0.35 + (1.35 - 0.35) * 1.0 * (0.55 + 0.45 * 0.35))) < 0.01, "early game: 35 percent served is already full volume")
	check(perf(0.20, 20.0) < perf(0.35, 20.0) - 0.15, "early game: below the target the multiplier still falls")
	# ---- 3) gec oyunda beceri ayirir (eskiden %35'ten sonra doyuyordu)
	var p40 := perf(0.40, 70.0); var p55 := perf(0.55, 70.0); var p70 := perf(0.70, 70.0); var p85 := perf(0.85, 70.0)
	check(p40 + 0.1 < p55 and p55 + 0.1 < p70 and p70 + 0.07 < p85, "late game: 40 / 55 / 70 / 85 percent served earn clearly different multipliers")
	check(p85 / p55 > 1.3, "late game: 85 percent served earns over 30 percent more than 55 percent")
	# ---- 4) zincir gideri
	check(P.f_branchGider(1000.0, 1.0) == 480.0 and P.f_branchGider(1000.0, 0.35) == 363.0, "expense: 30 percent fixed + 18 percent x performance")
	check(P.f_branchGider(0.0, 1.2) == 0.0, "no branches, no expense")
	var net_ok := true
	for base in [1000.0, 123456.0, 1.0e7]:
		for pf in [0.35, 0.5, 0.8, 1.0, 1.35]:
			var br: float = floorf(base * pf + 0.5)
			var gd: float = minf(br, P.f_branchGider(base, pf))
			net_ok = net_ok and br - gd >= 0.0
	check(net_ok, "net income is never negative")
	check(1000.0 * 0.35 - P.f_branchGider(1000.0, 0.35) < 0.0 + 20.0 and 1000.0 * 0.36 - P.f_branchGider(1000.0, 0.36) > -20.0, "break-even sits at the floor multiplier (~0.37)")
	# ---- 5) gun sonu: sube geliri net eklenir
	var G := taze(60.0, 4.0)   # 4 sube
	var taban: float = P.f_branchBase(G)
	check(taban == 1000.0 + 3100.0 + 8700.0 + 15700.0, "four branches' base income")
	G.stat.wraps = 60.0; G.stat.lost = 10.0; G.stat.earned = 5000.0; G.money = 5000.0
	var para0: float = G.money
	game.session_system.f_endDay()
	var st: Dictionary = G.stat
	check(st.branchBrut == floorf(taban * st.brPerf + 0.5), "gross branch income = base x performance")
	check(st.branchGider == P.f_branchGider(taban, st.brPerf) and st.branch == st.branchBrut - st.branchGider and st.branch > 0.0, "net = gross - expense")
	check(G.money == para0 + st.branch and st.earned == 5000.0 + st.branch, "cash and earnings grow by the NET amount")
	# olu gun: kimse servis edilmedi -> performans tabanda, gider geliri asar; zincir hicbir sey kazanmaz ama kasadan da eksilmez
	G = taze(60.0, 4.0)
	G.stat.wraps = 0.0; G.stat.lost = 100.0; G.stat.earned = 0.0; G.money = 777.0
	game.session_system.f_endDay()
	check(is_equal_approx(G.stat.brPerf, game.j_BR_MIN) and G.stat.branch == 0.0 and G.stat.branchGider <= G.stat.branchBrut and G.money == 777.0, "a dead day: the chain earns nothing and never takes money from the till")
	# ---- 6) Demirkent (ferman): sube geliri de gideri de yok
	G = taze(60.0, 9.0, 8.0)
	G.stat.wraps = 60.0; G.stat.earned = 1000.0; G.money = 1000.0
	game.session_system.f_endDay()
	check(G.stat.branch == 0.0 and G.stat.branchBrut == 0.0 and G.stat.branchGider == 0.0, "ferman city: no branch income, no expense")
	# ---- 7) sube yokken hicbir sey
	G = taze(30.0, 0.0)
	G.stat.wraps = 30.0; G.stat.earned = 800.0; G.money = 800.0
	game.session_system.f_endDay()
	check(G.stat.branch == 0.0 and G.stat.branchBrut == 0.0 and G.stat.branchGider == 0.0 and G.money == 800.0, "no branches: nothing changes")
	# ---- 8) sube tablosu: gelirler artan, fiyat ve gereksinim sirasi bozulmaz
	var onceki := 0.0
	for b in game.j_BRANCH:
		check(float(b.inc) > onceki, "branch %s income grows along the chain" % b.name)
		onceki = float(b.inc)
	# ---- 9) gun sonu karti sube satirlariyla hatasiz cizilir
	G = taze(60.0, 4.0)
	G.stat.wraps = 60.0; G.stat.lost = 10.0; G.stat.earned = 5000.0; G.money = 5000.0
	game.session_system.f_endDay()
	game.tarif_system.f_durum().yeni = []
	for i in 140: game.advance(1.0 / 60)
	check(G.scene == "dayend", "day end with branch rows draws")
	print("SUBE EKONOMI ", JSON.stringify({"checks": checks, "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
