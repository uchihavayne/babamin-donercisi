# SEHIR KURALLARI + ZIYARET PRIMI (birlesik surum, 12. tur): her sube sehri, aciklama metnindeki vaadi tutan bir kural tasir;
# oynanan subenin geliri ayrica %50 artar. Veri: data/sehir_kural.gd, mantik: systems/city_rules.gd.
#   godot --headless --path . --script tests/sehir_kural.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []
const DILLER := ["en", "de", "fr", "es", "pt"]

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func yak(a: float, b: float, tol := 0.0001) -> bool:
	return absf(a - b) <= tol

# oynanan sehri ayarla (-1 = Babanin Dukkani); 9 sube acik
func sehir(i: int, gun := 60.0) -> Dictionary:
	game.session_system.f_resetProgress()
	var G: Dictionary = game.j_G
	G.day = gun
	G.branch = 9.0
	G.city = float(i)
	game.f_startDay()
	G.tut = 99; G.shutT = 0; G.weather = "sun"
	G.ferman = null; G.lider = null; G.night = null; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	return G

func tun(ad: String, G: Dictionary) -> float:
	return float(game.J.method(game.j_TUN, ad, [G]))

func teslim_kazanci(sehir_no: int, kusursuz: bool, evsiz := false) -> float:
	var G := sehir(sehir_no, 30.0)
	G.customers = []
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = G.customers.back()
	c.state = "wait"; c.x = c.tx; c.homeless = evsiz; c.mac = false; c.earn = 0; c.patience = 0.7
	c.items = [{"kind": "wrap"} if kusursuz else {"kind": "wrap", "sauce": "hot"}]
	c.done = [false]
	G.hand = {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": null, "state": "ready", "paper": true, "grilled": bool(game.J.method(game.j_TUN, "grillOn", [G])), "burnt": false}
	game.f_deliver(c)
	var kazanc := float(c.earn)
	while not G.coins.is_empty(): game.payment_system.f_collectCoin(0, true)
	return kazanc

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/sehir-kural-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var R = game.city_rules
	# ---- 1) veri: 9 girdi (8 kural + Demirkent null), her kuralin metni ve carpanlari makul, 5 dilde ceviri var
	check(game.j_SEHIR_KURAL.size() == game.j_BRANCH.size() and game.j_SEHIR_KURAL.size() == 9, "one rule slot per branch city")
	check(game.j_SEHIR_KURAL[8] == null, "Demirkent (ferman) carries no extra rule")
	var ad_tek := {}
	for i in 8:
		var r: Dictionary = game.j_SEHIR_KURAL[i]
		check(r.has("ad") and r.has("kisa") and r.has("acik") and str(r.ad) != "" and str(r.kisa) != "" and str(r.acik) != "", "city %d rule has a name, a badge and a line" % i)
		check(not ad_tek.has(str(r.ad)), "city %d rule name is unique" % i)
		ad_tek[str(r.ad)] = true
		for alan in ["gelis", "sabir", "bahsis", "fiyat", "sure", "ceza", "iddia", "kusursuz", "kusurlu"]:
			if r.has(alan): check(float(r[alan]) >= 0.5 and float(r[alan]) <= 2.0, "city %d: '%s' stays between 0.5 and 2" % [i, alan])
		for dil in DILLER:
			game.localization.f_setLang(dil)
			for alan in ["ad", "kisa", "acik"]:
				check(str(game.localization.f_T(str(r[alan]))) != str(r[alan]), "%s: city %d rule '%s' is translated" % [dil, i, alan])
		game.localization.f_setLang("tr")
	# ---- 2) API: Babanin Dukkani ve Demirkent kuralsiz, primsiz
	var G := sehir(-1)
	check(R.f_kural(G).is_empty() and R.f_carpan("gelis", G) == 1.0 and R.f_yer(G) == 0.0 and R.f_ziyaretTaban(G) == 0.0, "the father's shop: no rule, no premium")
	G = sehir(8)
	check(R.f_kural(G).is_empty() and R.f_ziyaretTaban(G) == 0.0, "Demirkent: no rule, no premium")
	check(R.f_carpan("gelis", {"up": {}}) == 1.0 and R.f_carpan("gelis", null) == 1.0, "a state without a city is rule-free")
	# ---- 3) etkiler: her kural, evdeki degerle ayni durumda karsilastirilir
	var ev := sehir(-1)
	var ev_cust := tun("custMul", ev); var ev_sabir := tun("patience", ev); var ev_bahsis := tun("havaBahsis", ev)
	var ev_fiyat := tun("priceMul", ev); var ev_yer := tun("slots", ev)
	var ev_len := float(game.progression_system.f_dayCfg(60.0, ev).len)
	var ev_bahis := float(game.progression_system.f_bahisPara(ev))
	var ist := sehir(0)
	check(yak(tun("custMul", ist), ev_cust * 1.25) and yak(tun("patience", ist), ev_sabir * 0.92), "Istanbul (queue): 25 percent more guests, a little less patience")
	var ist_hiz := float(game.progression_system.f_dayCfg(60.0, ist).rate)   # not: sehir() hep ayni G sozlugunu yeniden kurar
	sehir(-1)
	check(yak(ist_hiz, float(game.progression_system.f_dayCfg(60.0, game.j_G).rate) / 1.25), "Istanbul: guests really arrive faster")
	var ber := sehir(1)
	check(float(game.progression_system.f_bahisPara(ber)) == floorf(ev_bahis * 2.0 / 10.0 + 0.5) * 10.0 and ev_bahis > 0.0, "Berlin (stakes): bet money is doubled")
	var lon := sehir(2)
	check(float(game.progression_system.f_dayCfg(60.0, lon).len) == floorf(ev_len * 1.25 + 0.5), "London (never closes): the day is 25 percent longer")
	check(float(lon.timeLeft) == float(game.progression_system.f_dayCfg(60.0, lon).len), "London: the started day really lasts that long")
	var man := sehir(3)
	check(yak(tun("custMul", man), ev_cust * 1.4) and yak(tun("patience", man), ev_sabir * 0.85), "Manila (endless queue): 40 percent more guests, less patience")
	var par := sehir(4)
	check(tun("slots", par) == maxf(2.0, ev_yer - 1.0) and yak(tun("priceMul", par), ev_fiyat * 1.15) and R.f_carpan("ceza", par) == 2.0, "Paris (small and strict): one seat less, prices up, fines doubled")
	# genisletilmis dukkanda gercekten 1 yer eksilir (kuruluysa en az 2 kalir)
	par.up.expand = 3.0
	var par_yer := tun("slots", par)
	var ev3 := sehir(-1)
	ev3.up.expand = 3.0
	check(par_yer == tun("slots", ev3) - 1.0 and par_yer >= 2.0, "Paris: with an expanded shop the queue really loses one seat (%d vs %d)" % [int(par_yer), int(tun("slots", ev3))])
	var dub := sehir(5)
	check(yak(tun("havaBahsis", dub), ev_bahsis * 1.8) and yak(tun("patience", dub), ev_sabir * 0.85), "Dubai (tourist rush): bigger tips, less patience")
	var nyc := sehir(7)
	check(float(game.progression_system.f_dayCfg(60.0, nyc).len) == floorf(ev_len * 1.15 + 0.5) and yak(tun("custMul", nyc), ev_cust * 1.15), "New York (never sleeps): longer day and more guests")
	# kurali olmayan sehirde baska hicbir ayar kaymaz (Berlin yalniz bahis)
	ber = sehir(1)
	check(yak(tun("custMul", ber), ev_cust) and yak(tun("patience", ber), ev_sabir) and tun("slots", ber) == ev_yer and float(game.progression_system.f_dayCfg(60.0, ber).len) == ev_len, "Berlin touches nothing but the bets")
	# Paris: hijyen cezasi 2 kat (denetci kirli mutfagi cezalar)
	var ceza_min := 99999.0; var ceza_mak := 0.0
	for k in 14:
		G = sehir(4)
		G.trash = 0.95
		G.inspect = {"state": "check", "t": 5.0, "x": 200.0, "y": 152.0, "tx": 200.0, "dirty": false, "fine": 0.0, "line": ""}
		game.event_system.f_maybeInspector(0.01)
		ceza_min = minf(ceza_min, float(G.inspect.fine)); ceza_mak = maxf(ceza_mak, float(G.inspect.fine))
	check(ceza_min >= 2.0 * game.j_FINE_MIN and ceza_mak <= 2.0 * game.j_FINE_MAX and ceza_mak > game.j_FINE_MAX, "Paris: the hygiene fine really is doubled (%d..%d)" % [int(ceza_min), int(ceza_mak)])
	G = sehir(-1)
	G.trash = 0.95
	G.inspect = {"state": "check", "t": 5.0, "x": 200.0, "y": 152.0, "tx": 200.0, "dirty": false, "fine": 0.0, "line": ""}
	game.event_system.f_maybeInspector(0.01)
	check(float(G.inspect.fine) >= game.j_FINE_MIN and float(G.inspect.fine) <= game.j_FINE_MAX, "the father's shop: the usual fine")
	# Tokyo: kusursuz teslim fazla, kusurlu eksik
	var ev_iyi := teslim_kazanci(-1, true); var ev_kotu := teslim_kazanci(-1, false)
	var tok_iyi := teslim_kazanci(6, true); var tok_kotu := teslim_kazanci(6, false)
	check(ev_iyi > 0.0 and tok_iyi == floorf(ev_iyi * 1.25 + 0.5), "Tokyo (flawless): a perfect delivery pays 25 percent more (%d -> %d)" % [int(ev_iyi), int(tok_iyi)])
	check(ev_kotu > 0.0 and ev_kotu < ev_iyi and tok_kotu == floorf(ev_kotu * 0.8 + 0.5), "Tokyo: a flawed delivery pays 20 percent less (%d -> %d)" % [int(ev_kotu), int(tok_kotu)])
	check(teslim_kazanci(0, true) == ev_iyi and teslim_kazanci(0, false) == ev_kotu, "other cities pay deliveries the usual way")
	check(teslim_kazanci(6, true, true) == 0.0 and teslim_kazanci(-1, true, true) == 0.0, "a hungry stranger is still fed for free, in every city")
	# ---- 4) ziyaret primi
	for i in 8:
		G = sehir(i)
		check(R.f_ziyaretTaban(G) == float(game.j_BRANCH[i].inc) * 0.5, "city %d: visit premium is half of that branch's base income" % i)
	G = sehir(3)
	G.branch = 3.0   # Manila (dizin 3) acik degil
	check(R.f_ziyaretTaban(G) == 0.0, "a branch that is not open pays no premium")
	# gun sonunda prim brut gelire girer, evde girmez; gider de buna gore artar
	var sonuc := {}
	for i in [-1, 0, 5]:
		G = sehir(i)
		G.stat.wraps = 60.0; G.stat.lost = 10.0; G.stat.earned = 5000.0; G.money = 5000.0
		game.session_system.f_endDay()
		sonuc[i] = G.stat.duplicate()
	var taban: float = game.progression_system.f_branchBase(game.j_G)
	check(sonuc[-1].ziyaretPrim == 0.0 and sonuc[-1].branchBrut == floorf(taban * sonuc[-1].brPerf + 0.5), "the father's shop: no premium in the gross")
	for i in [0, 5]:
		var s: Dictionary = sonuc[i]
		var prim: float = float(game.j_BRANCH[i].inc) * 0.5
		check(s.ziyaretPrim == floorf(prim * s.brPerf + 0.5) and s.ziyaretPrim > 0.0, "city %d: the premium line is reported" % i)
		check(s.branchBrut == floorf((taban + prim) * s.brPerf + 0.5), "city %d: gross = (base + premium) x performance" % i)
		check(s.branchGider == game.progression_system.f_branchGider(taban + prim, s.brPerf), "city %d: expenses follow the premium too" % i)
		check(s.branch == s.branchBrut - s.branchGider, "city %d: net = gross - expenses" % i)
	# musteri yogunlugunu degistirmeyen bir sehirde (Dubai) ayni hizmetle prim net geliri belirgin arttirir
	check(sonuc[5].brPerf == sonuc[-1].brPerf and sonuc[5].branch > sonuc[-1].branch, "Dubai: same service, the visit premium raises the net income")
	# ---- 5) arayuz: her sehirde gun giris karti, gun sonu karti, sube paneli hatasiz
	for i in 9:
		G = sehir(i)
		G.scene = "intro"; G.sceneT = 5.0
		for k in 30: game.advance(1.0 / 60)
		check(G.scene == "intro", "city %d: the day intro card draws" % i)
	G = sehir(0)
	G.stat.wraps = 60.0; G.stat.earned = 5000.0; G.money = 5000.0
	game.session_system.f_endDay()
	game.tarif_system.f_durum().yeni = []
	for k in 140: game.advance(1.0 / 60)
	check(G.scene == "dayend" and G.stat.ziyaretPrim > 0.0, "day end with the premium star draws")
	G = sehir(1)
	G.scene = "shop"; G.sceneT = 5.0; G.money = 5000.0
	game.j_BRP.open = true
	for k in 40: game.advance(1.0 / 60)
	game.j_BRP.open = false
	check(G.scene == "shop", "the branch panel with rule badges draws")
	print("SEHIR KURAL ", JSON.stringify({"checks": checks, "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
