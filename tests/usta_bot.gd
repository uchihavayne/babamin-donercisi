# USTA BOT (birlesik surum, 9. tur): oyunu 1. gunden gercek kurallarla,
# insan hizinda (her eylem arasi --gecikme sn) oynar. Istasyon sistemindeki
# gecerli eylemleri kullanir (kumanda/dokunma ile ayni yol); gun sonunda
# dukkanda en ucuz yukseltmeyi alir, gece hirsizi ve olaylar dogal olarak gelir.
# Her karede durum tutarliligini denetler (eksi para/stok, porsiyon tasmasi,
# ayni urun hem elde hem tahtada, takilan sahne...). Gun gun oynanabilirlik
# olcumu basar: gelen / servis / kacan musteri, kazanc, bekleme nedenleri.
#   godot --headless --path . --script tests/usta_bot.gd --quit-after 100000000 -- --test [--gun 12] [--gecikme 0.6] [--tohum 1]
extends SceneTree
const J = preload("res://scripts/js_compat.gd")
var game: Node
var G: Dictionary
var ihlaller: Dictionary = {}
var gecikme := 0.6
var bekle := 0.0
var tutma: Dictionary = {}
var gun_say: Dictionary = {}
var goruldu: Dictionary = {}
var t_gun := 0.0
var servis_sureleri: Array = []
var kapanis := {"bekleyen": 0, "tahtada": 0}
var iz := false
var son_spawn := 0.0
var son_eylem := ""

func _initialize() -> void: call_deferred("run")

func arg(ad: String, v: String) -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else v

func say(k: String, n := 1.0) -> void: gun_say[k] = float(gun_say.get(k, 0.0)) + n

func ihlal(ok: bool, m: String) -> void:
	if ok: return
	var k := "gun %d: %s" % [int(G.day), m]
	if not ihlaller.has(k): ihlaller[k] = 0
	ihlaller[k] += 1

func tun(k: String) -> Variant: return J.method(game.j_TUN, k, [G])
func st() -> Variant: return game.stations

# ------------------------------------------------------------ denetim
func denetle() -> void:
	var ferman: bool = J.truth(game.progression_system.f_fermanSehri(G))
	ihlal(is_finite(float(G.money)) and (ferman or float(G.money) >= 0.0), "para gecersiz: %s" % G.money)
	ihlal(float(G.debt) >= 0.0, "borc eksi")
	ihlal(float(G.meat) >= 0.0 and float(G.meat) <= float(tun("meatCap")) + 0.01, "et tepsisi sinir disi: %s" % G.meat)
	ihlal(float(G.friesTray) >= 0.0 and float(G.friesTray) <= float(tun("friesCap")) + 0.01, "patates tepsisi sinir disi: %s" % G.friesTray)
	for it in game.stock_system.f_crateItems():
		var k: String = it[0]
		ihlal(float(G.stock[k]) >= 0.0 and float(G.stock[k]) <= float(game.stock_system.f_crateMax(k)) + 0.01, "stok sinir disi %s: %s" % [k, G.stock[k]])
	var n := int(tun("boards"))
	for i in G.boards.size():
		var b: Variant = G.boards[i]
		if b == null: continue
		ihlal(i < n, "acik olmayan tahtada urun")
		ihlal(b is Dictionary and b.get("kind") in ["wrap", "plate", "pide"], "tahtada gecersiz nesne")
		if b.kind == "wrap":
			for a in ["meat", "pickleN", "yogurtN", "friesN"]:
				ihlal(float(b.get(a, 0)) >= 0.0 and float(b.get(a, 0)) <= 4.0, "durumda %s tasmasi: %s" % [a, b.get(a)])
		elif b.kind == "plate":
			ihlal(float(b.get("meat", 0)) <= float(tun("iskMeat")) and float(b.get("yogurtN", 0)) <= float(game.j_PLATE_YOGURT), "tabak tasmasi")
		ihlal(not is_same(b, G.hand), "ayni urun hem elde hem tahtada")
		for j in range(i + 1, G.boards.size()):
			ihlal(not is_same(b, G.boards[j]), "ayni urun iki tahtada")
	var slotlar := {}
	for c in G.customers:
		ihlal(c.done.size() == c.items.size(), "musteri done/items uyumsuz")
		if not c.state in ["leave", "served", "sira", "sira_git"]:
			ihlal(not slotlar.has(c.slot), "iki musteri ayni yerde")
			slotlar[c.slot] = true
	ihlal(G.hand == null or (G.hand is Dictionary and G.hand.has("kind")), "elde gecersiz nesne")
	ihlal(is_finite(float(G.timeLeft)), "sure gecersiz")

var kare_no := 0

# hiz: oyun mantigi her karede; tam kare (cizim + cizimdeki arayuz mantigi)
# 30 karede bir. Oyun disi sahneler (gece vb.) hep tam kare.
func step() -> void:
	kare_no += 1
	var dt := 1.0 / 60.0
	if str(G.scene) != "play" or kare_no % 30 == 0:
		game.advance(dt)
	else:
		st().refresh(); st().tick(dt)
		game.controls.tick(dt); game.controls.begin_targets()
		G.t = float(G.t) + dt
		game.game_loop.f_updatePlay(dt)
		game.effects.f_psUpdate(dt); game.effects.f_ftUpdate(dt)
		game.controls.end_targets()
		game.effects.f_inEnd()
	if str(G.scene) == "play":
		t_gun += 1.0 / 60.0
		denetle()
		# musteri gelme denemesi: spawnT yeniden kuruldu (yer yoksa musteri dogmaz)
		if float(G.spawnT) > son_spawn + 0.5: say("deneme")
		son_spawn = float(G.spawnT)
		var bk := 0
		for c in G.customers:
			if c.state == "wait" and c.done.has(false): bk += 1
		var th := 0
		for b in G.boards:
			if b is Dictionary: th += 1
		kapanis = {"bekleyen": bk, "tahtada": th + (1 if G.hand is Dictionary else 0) + G.grill.slots.size()}
		if iz and kare_no % 180 == 0:
			var tah: Array = []
			for b in G.boards:
				tah.append(null if not b is Dictionary else [b.kind, b.state, b.get("meat"), b.get("pickleN"), b.get("yogurtN"), b.get("friesN"), b.get("sauce"), b.get("grilled"), b.get("burnt"), b.get("_order_recipe")])
			var ist: Array = []
			for c in G.customers: ist.append([c.state, c.items, c.done])
			print("IZ t=%d son=%s el=%s tahta=%s izgara=%s et=%s pat=%s musteri=%s" % [int(t_gun), son_eylem, G.hand.kind if G.hand is Dictionary else "-", JSON.stringify(tah), G.grill.slots.size(), G.meat, G.friesTray, JSON.stringify(ist)])
		for c in G.customers:
			if not c.has("_bot_id") and not c.state in ["sira", "sira_gir", "sira_git"]:
				c._bot_id = goruldu.size()
				goruldu[c._bot_id] = {"t": t_gun, "bitti": false}
				say("gelen")
				if c.get("homeless", false): say("evsiz")
			if not c.has("_bot_id"): continue
			var kay: Dictionary = goruldu[c._bot_id]
			if not kay.bitti and not c.done.has(false):
				kay.bitti = true
				servis_sureleri.append(t_gun - float(kay.t))

# ------------------------------------------------------------ eylem
func hedef_id(nesne: Dictionary, on_ek: String) -> String:
	st().refresh()
	return on_ek + str(nesne.get("_station_uid", -1))

func dene(target: String, action: String) -> bool:
	st().select(target)
	if st().selected != target: return false
	for a in st().actions():
		if a.id == action and a.enabled:
			st().press(action, "bot")
			son_eylem = target + "/" + action
			say("eylem")
			var tur := "siparis"
			if action in ["cut_meat", "potato", "chop", "fry", "crate"] or action.begins_with("refill:"): tur = "hazirlik"
			elif action in ["collect", "trash", "cat", "return"]: tur = "diger"
			say("eylem_" + tur)
			if not st().holding.is_empty():
				if st().holding.get("repeat", false): st().release("bot")
				else: tutma = {"id": action, "t": 0.0}
			bekle = gecikme
			return true
	return false

func tutma_devam() -> void:
	tutma.t += 1.0 / 60.0
	var bitti: bool = st().holding.is_empty()
	match tutma.id:
		"cut_meat": bitti = bitti or float(G.meat) >= minf(float(tun("meatCap")), 12.0) or tutma.t > 6.0
		"chop": bitti = bitti or not G.cut.potato or tutma.t > 8.0
	if tutma.t > 10.0: bitti = true
	if bitti:
		st().release("bot")
		tutma = {}
		bekle = gecikme * 0.5

# ------------------------------------------------------------ siparis bilgisi
func bekleyenler() -> Array:
	var out: Array = []
	for c in G.customers:
		if c.state != "wait": continue
		for i in c.items.size():
			if not c.done[i]: out.append({"o": c, "i": i, "it": c.items[i]})
	if G.phone is Dictionary and G.phone.get("state") == "order":
		for i in G.phone.order.size():
			if not G.phone.done[i]: out.append({"o": G.phone, "i": i, "it": G.phone.order[i]})
	return out

func sayi(tur: String, tip := "") -> int:
	var n := 0
	for p in bekleyenler():
		if p.it.kind == tur and (tip == "" or p.it.get("type") == tip): n += 1
	return n

func hazirlanan(tur: String) -> int:
	var n := 0
	var yigin: Array = G.boards.duplicate()
	yigin.append(G.hand)
	for s in G.grill.slots: yigin.append(s.w)
	for b in yigin:
		if b is Dictionary and (b.kind == tur or (tur == "plate" and b.kind == "pide")): n += 1
	return n

func ayrilmamis_durum() -> bool:
	for p in bekleyenler():
		if p.it.kind == "wrap" and not game.order_system.order_reserved(p.o, p.i): return true
	return false

# ------------------------------------------------------------ servis
func teslim() -> bool:
	var h: Dictionary = G.hand
	var sahip: Variant = h.get("_order_owner")
	var adaylar: Array = []
	if sahip is Dictionary and game.order_system.order_live(sahip): adaylar.append(sahip)
	for p in bekleyenler():
		var uyar: bool = p.it.kind == h.kind and (h.kind != "drink" or p.it.get("type") == h.get("type"))
		if uyar and not adaylar.has(p.o): adaylar.append(p.o)
	for o in adaylar:
		if is_same(o, G.phone):
			if dene("uncle", "uncle"): say("paket"); return true
		elif dene(hedef_id(o, "customer:"), "serve"):
			return true
	if h.get("burnt", false) or h.kind in ["wrap", "plate"]:
		if dene("trash", "trash"): say("cope_atilan"); return true
	st().refresh()
	if dene(st().selected, "return"): return true
	return dene("trash", "trash")

func tahta_isi() -> bool:
	for i in int(tun("boards")):
		var w: Variant = G.boards[i]
		if not w is Dictionary: continue
		var t := "board:%d" % i
		if w.kind == "pide":
			if dene(t, "pide_chop"): return true
			continue
		if w.get("burnt", false):
			if dene(t, "take"): return true
			continue
		if w.state == "ready":
			if sayi(w.kind) > 0 and dene(t, "take"): return true
			continue
		if w.kind == "plate":
			for a in ["meat", "yogurt", "butter", "tomato", "pepper"]:
				if dene(t, a): return true
			if game.recipe_system.f_plateFull(w) and sayi("plate") > 0 and dene(t, "take"): return true
			if float(w.meat) < float(tun("iskMeat")) and float(G.meat) <= 0.0: say("bekle_et")
			continue
		if w.state == "rolled":
			if dene(t, "grill_put") or dene(t, "paper"): return true
			if J.truth(game.recipe_system.f_wrapNeedsGrill(w)): say("bekle_izgara")
			continue
		# acik durum
		var r: Variant = w.get("_order_recipe")
		if not r is Dictionary:
			if not ayrilmamis_durum():
				if dene(t, "take"): say("sahipsiz_durum"); return true
			continue
		if game.order_system.order_matches(w, r):
			if dene(t, "roll"): return true
			continue
		if float(w.meat) < 4.0:
			if dene(t, "meat"): return true
			say("bekle_et")
		for k in ["pickle", "yogurt", "fries"]:
			var alan: String = k + "N"
			if k in r.get("yok", []) or float(w.get(alan, 0)) >= 4.0: continue
			if dene(t, k): return true
			say("bekle_patates" if k == "fries" else "bekle_stok")
		if r.get("sauce") != null and w.get("sauce") != r.sauce:
			if dene(t, str(r.sauce)): return true
	return false

func yeni_urun() -> bool:
	if ayrilmamis_durum() and game.wrap_system.f_emptyBoard() >= 0:
		if dene("bread", "bread"): return true
	if J.truth(tun("iskOn")) and sayi("plate") > hazirlanan("plate") and game.wrap_system.f_emptyBoard() >= 0:
		if dene("pide", "pide"): return true
	for tip in game.drink_system.f_icecekMusluklari():
		var cup: Variant = G.cups.get(tip)
		var el: int = 1 if (G.hand is Dictionary and G.hand.get("type") == tip) else 0
		if sayi("drink", tip) > el:
			if cup is Dictionary and float(cup.get("fill", 0)) >= 1.0:
				if dene("drink:" + tip, "drink_take"): return true
			elif cup == null:
				if dene("drink:" + tip, "pour"): return true
			else: say("bekle_icecek")
	if J.truth(tun("fboxOn")) and sayi("fbox") > 0:
		if dene("fbox", "fbox"): return true
	if J.truth(tun("sweetOn")) and sayi("sweet") > 0:
		if dene("sweet", "sweet"): return true
	return false

func patates_isi(esik: float) -> bool:
	if G.fryer.state == "done": return dene("fryer", "fry")
	if float(G.friesTray) >= esik: return false
	if float(G.cut.raw) > 0.0 and G.fryer.state == "idle": return dene("cut", "fry")
	if G.cut.potato: return dene("cut", "chop")
	if G.fryer.state == "idle" and float(G.cut.raw) <= 0.0: return dene("potato", "potato")
	return false

func bakim(tam: bool) -> bool:
	var et_esik := 16.0 if tam else 6.0
	if float(G.meat) < minf(et_esik, float(tun("meatCap"))) and dene("spit", "cut_meat"): return true
	if patates_isi(16.0 if tam else 8.0): return true
	for it in game.stock_system.f_crateItems():
		var k: String = it[0]
		var esik: float = float(game.stock_system.f_crateMax(k)) * (0.9 if tam else 0.3)
		if float(G.stock[k]) < esik:
			if not G.crate.open:
				if dene("crate", "crate"): return true
			elif dene("refill:" + k, "refill:" + k): return true
	return false

func karar() -> void:
	if game.rival_system.f_bahisAcik():
		game.rival_system.f_rakipCevap(int(G.day) % 2 == 0)
		say("bahis"); bekle = gecikme; return
	if G.hand is Dictionary:
		if teslim(): return
		say("el_takildi"); return
	if G.phone is Dictionary and G.phone.get("state") == "ring" and dene("phone", "phone"): return
	# izgaradan alma: bos tahta ya da takas icin sarili izgarasiz durum gerekir
	# (yoksa oyun "Tezgah dolu" der; once tahtadaki durum sarilmali)
	var takas := false
	for b in G.boards:
		if b is Dictionary and b.kind == "wrap" and b.state == "rolled" and not b.get("grilled", false): takas = true
	if int(game.grill_system.f_grillBosYer()) >= 0 or takas:
		for i in G.grill.slots.size():
			var s: Dictionary = G.grill.slots[i]
			if s.done and dene(hedef_id(s, "grill:"), "grill_take"): return
	if tahta_isi(): return
	if bakim(false): return
	if yeni_urun(): return
	if not J.truth(tun("autoCoin")):
		for c in G.coins:
			if c.landed and dene(hedef_id(c, "coin:"), "collect"): return
	if float(G.trash) > 0.5 and dene("trash", "trash"): return
	var kedi: Variant = G.get("kedi")
	if kedi is Dictionary and kedi.get("faz") == "bekle" and float(G.meat) >= 8.0 and dene("cat", "cat"): return
	if bakim(true): say("hazirlik"); return
	say("bos_kare", 15.0)
	bekle = 0.25

# ------------------------------------------------------------ gun
func gun_oyna() -> Dictionary:
	gun_say = {}
	goruldu = {}
	servis_sureleri = []
	t_gun = 0.0
	game.f_startDay()
	G.tut = 99
	if int(G.day) == 1: G.spawnT = float(game.j_ILK_MUSTERI)
	var kare := 0
	while str(G.scene) == "play" and kare < 60 * 400:
		kare += 1
		if bekle > 0.0:
			bekle -= 1.0 / 60.0
		elif not tutma.is_empty():
			tutma_devam()
		else:
			karar()
		step()
	ihlal(str(G.scene) == "dayend", "gun bitmedi (sahne %s)" % G.scene)
	var s: Dictionary = G.stat
	var ort := 0.0
	for x in servis_sureleri: ort += float(x)
	if not servis_sureleri.is_empty(): ort /= servis_sureleri.size()
	return {"gun": int(G.day), "sure": int(t_gun), "gelen": int(gun_say.get("gelen", 0)), "kacan": int(s.get("lost", 0)),
		"durum": int(s.get("wraps", 0)), "iskender": int(s.get("isk", 0)), "icecek": int(s.get("drinks", 0)),
		"kazanc": int(s.get("earned", 0)), "bahsis": int(s.get("tips", 0)), "taksit": int(s.get("debtPaid", 0)), "ceza": int(s.get("fine", 0)),
		"ort_servis_sn": snappedf(ort, 0.1), "eylem": int(gun_say.get("eylem", 0)),
		"bos_%": snappedf(100.0 * float(gun_say.get("bos_kare", 0)) / maxf(1.0, float(kare)), 0.1),
		"hazirlik_karar": int(gun_say.get("hazirlik", 0)), "gelme_denemesi": int(gun_say.get("deneme", 0)),
		"eylem_siparis": int(gun_say.get("eylem_siparis", 0)), "eylem_hazirlik": int(gun_say.get("eylem_hazirlik", 0)), "eylem_diger": int(gun_say.get("eylem_diger", 0)), "kapidan_donen": int(G.stat.get("yerYok", 0)), "yer": int(tun("slots")), "kapanista_bekleyen": kapanis.bekleyen, "kapanista_yarim_urun": kapanis.tahtada,
		"bekleme": {"et": int(gun_say.get("bekle_et", 0)), "patates": int(gun_say.get("bekle_patates", 0)), "stok": int(gun_say.get("bekle_stok", 0)),
			"izgara": int(gun_say.get("bekle_izgara", 0)), "icecek": int(gun_say.get("bekle_icecek", 0))},
		"diger": {"paket": int(gun_say.get("paket", 0)), "cope": int(gun_say.get("cope_atilan", 0)), "sahipsiz": int(gun_say.get("sahipsiz_durum", 0)),
			"el_takildi": int(gun_say.get("el_takildi", 0)), "bahis": int(gun_say.get("bahis", 0)), "evsiz": int(gun_say.get("evsiz", 0)),
			"hava": str(G.weather), "mac": J.truth(G.get("macGun")), "kesinti": G.get("kesinti") != null, "kedi": G.get("kedi") != null,
			"mufettis": G.get("inspect") != null}}

func dukkan_ve_gece() -> Dictionary:
	G.scene = "shop"
	var alinan: Array = []
	while true:
		var en: Variant = null
		var en_fiyat := INF
		for u in game.j_UPG:
			var p: Variant = game.upgrade_system.price(u)
			if p == null or (u.has("gerek") and int(G.up.get(u.gerek, 0)) <= 0): continue
			if float(p) < en_fiyat: en_fiyat = float(p); en = u
		if en == null or not game.upgrade_system.buy(en.id): break
		alinan.append(en.id)
	var once := float(G.money)
	G.day += 1.0
	game.event_system.f_rollNight()
	var gece := {}
	if J.truth(G.get("night")):
		G.scene = "night"; G.sceneT = 0.0
		for i in 60 * 14: game.advance(1.0 / 60.0)
		gece = {"hirsiz": true, "caldi": J.truth(G.night.stole), "kayip": int(once - float(G.money))}
	G.scene = "intro"
	return {"alinan": alinan, "gece": gece}

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/usta-bot-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	gecikme = float(arg("--gecikme", "0.6"))
	seed(int(arg("--tohum", "1")))
	game.session_system.f_resetProgress()
	G = game.j_G
	game.controls.set_mode("controller")
	var gunler := int(arg("--gun", "12"))
	# --up a,b,c : baslangic yukseltmeleri (1. seviye); --ilk N : baslangic gunu; --iz : durum izi
	if arg("--up", "") != "":
		for u in arg("--up", "").split(","): G.up[u] = 1.0
	G.day = float(arg("--ilk", "1"))
	iz = "--iz" in OS.get_cmdline_user_args()
	print("USTA BOT gecikme %.2f sn, %d gun" % [gecikme, gunler])
	for d in gunler:
		G = game.j_G
		var r := gun_oyna()
		var dk := dukkan_ve_gece()
		r["alinan"] = dk.alinan
		if not dk.gece.is_empty(): r["gece"] = dk.gece
		r["kasa"] = int(G.money)
		print("GUN ", JSON.stringify(r))
	print("IHLAL ", JSON.stringify(ihlaller))
	game.free(); quit(0 if ihlaller.is_empty() else 1)
