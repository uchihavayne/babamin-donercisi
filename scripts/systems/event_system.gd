# Event system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2424
func f_rollNight() -> Variant:
	var v_stole: Variant = null
	var v_amount: Variant = null
	J.setv(game.j_G, "night", null)
	if J.lt(J.getv(game.j_G, "day"), game.j_THIEF_DAY):
		return null
	if (not J.truth(game.f_chance(J.method(game.j_TUN, "thiefVisit", [game.j_G])))):
		return null
	v_stole = game.f_chance(J.method(game.j_TUN, "thiefSteal", [game.j_G]))
	v_amount = 0.0
	if J.truth(v_stole):
		v_amount = floor((J.getv(game.j_G, "money") * game.math_utils.f_rnd(game.j_THIEF_MIN, game.j_THIEF_MAX)) + 0.5)
		v_amount = min(J.getv(game.j_G, "money"), max(v_amount, min(J.getv(game.j_G, "money"), 40.0)))
	J.setv(game.j_G, "night", {"t": 0.0, "phase": 0.0, "stole": v_stole, "amount": v_amount, "sec": J.method(game.j_TUN, "secLevel", [game.j_G]), "line": game.math_utils.f_pick((game.j_LINES_THIEF_WIN if J.truth(v_stole) else game.j_LINES_THIEF_LOSE)), "paid": false})
	return null

# game.js:4339
func f_addTrash(p_v: Variant = null) -> Variant:
	var v_v: Variant = p_v
	J.setv(game.j_G, "trash", game.math_utils.f_clamp(J.add(J.getv(game.j_G, "trash"), v_v), 0.0, 1.35))
	return null

# game.js:4343
func f_copaAt(p_x0: Variant = null, p_y0: Variant = null, p_renkler: Variant = null) -> Variant:
	var v_hx: Variant = null
	var v_hy: Variant = null
	var v_i: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	var v_renkler: Variant = p_renkler
	v_hx = J.add(J.getv(J.getv(game.j_ST, "trash"), "x"), (float(J.getv(J.getv(game.j_ST, "trash"), "w")) / float(2.0)))
	v_hy = J.add(J.getv(J.getv(game.j_ST, "trash"), "y"), 10.0)
	v_i = 0.0
	while J.lt(v_i, 5.0):
		game.effects.f_part({"x": J.add(v_x0, game.math_utils.f_rnd((-J.n(4.0)), 4.0)), "y": v_y0, "vx": ((v_hx - v_x0) * game.math_utils.f_rnd(1.5, 2.0)), "vy": (((v_hy - v_y0) * 1.5) - game.math_utils.f_rnd(28.0, 52.0)), "life": 0.45, "col": game.math_utils.f_pick(v_renkler), "g": 210.0, "sz": 1.0})
		v_i = J.add(v_i, 1.0)
	return null

# COP KUTUSU (BIRLESIK 11. tur, kullanici karari "ayri hedefler"):
#   - Kutuya dokunmak / basmak HEP copu bosaltir; elde urun varsa onu atar
#   - Tezgahtaki urunu atmak icin urunu TUTUP kutuya SURUKLE ve birak
#     (f_dropOnTrash: fare, dokunma, kumandada kilitli imlec); kumanda / klavyede
#     urunun uzerine gelip "al" tusunu basili tut (station_actions "discard")
# Eskiden kutuya dokunmak sirayla eldekini, izgaradaki yanmisi, TEZGAHTAKI urunu
# atip en sona copu bosaltiyordu: cop dolu iken (muftetis cezasi: 150-400 $) tezgahta
# hazirlanan durum yanlislikla gidiyor, cop bosalmiyordu.
#   cop_eylemi(): "el" (eldekini at) | "bosalt" (kova bosalir) | "bos" (kova bos)
func cop_eylemi() -> String:
	if J.truth(game.j_G.hand): return "el"
	return "bosalt" if J.n(game.j_G.trash) > 0.02 else "bos"

# Tezgahta (ya da izgarada yanmis) atilabilecek bir urun var mi?
func f_atilabilirUrunVar() -> bool:
	for i in int(J.n(J.method(game.j_TUN, "boards", [game.j_G]))):
		if J.truth(game.j_G.boards[i]): return true
	for sl in game.j_G.grill.slots:
		if J.truth(sl.w.get("burnt")): return true
	return false

# game.js:4354
func f_trashClick() -> Variant:
	if J.truth(J.getv(game.j_G, "hand")):
		return f_discardHand()
	return f_emptyTrash()

func f_discardHand() -> Variant:
	J.setv(game.j_G, "hand", null)
	game.event_system.f_addTrash(game.j_TRASH_PER_ITEM)
	J.method(game.j_SFX, "drop", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "trash"), "x"), 11.0), J.add(J.getv(J.getv(game.j_ST, "trash"), "y"), 6.0), 8.0, ["#8a7a6a", "#5e5048"], {"spMax": 40.0, "up": 20.0})
	game.session_system.f_say("Çöpe atıldı")
	return null

# Tahtadaki urunu (acik / sarili durum, pide, tabak, yanmis) cope atar.
func f_discardBoard(idx: int) -> bool:
	if idx < 0 or idx >= int(J.n(J.method(game.j_TUN, "boards", [game.j_G]))): return false
	var w: Variant = game.j_G.boards[idx]
	if not J.truth(w): return false
	var tur: String = "tabak" if J.eq(J.getv(w, "kind"), "plate") else ("pide" if J.eq(J.getv(w, "kind"), "pide") else "durum")
	var kirinti := {"tabak": ["#e2eaf0", "#c98436", "#d9a765"], "pide": ["#dcae55", "#a8762e", "#f4e6c2"], "durum": ["#f0d5a8", "#c98436", "#8a5f31"]}
	if J.truth(J.getv(w, "burnt")): kirinti["durum"] = ["#3a2a1e", "#6b4a2a", "#1a1210"]
	game.event_system.f_copaAt(game.wrap_system.f_boardCX(idx), J.add(J.getv(J.getv(game.j_ST, "board"), "y"), 10.0), kirinti[tur])
	game.j_G.boards[idx] = null
	game.event_system.f_addTrash(game.j_TRASH_PER_ITEM)
	J.method(game.j_SFX, "drop", [])
	if J.truth(J.getv(w, "burnt")): game.session_system.f_say("Yanmış dürüm çöpe atıldı")
	else: game.session_system.f_say("Tabak çöpe atıldı" if tur == "tabak" else ("Pide çöpe atıldı" if tur == "pide" else "Dürüm çöpe atıldı"))
	game.equipment_system.f_checkAuto()
	return true

func f_emptyTrash() -> Variant:
	if J.gt(J.getv(game.j_G, "trash"), 0.02):
		J.setv(game.j_G, "emptyT", 0.9)
		J.setv(game.j_G, "trash", 0.0)
		J.method(game.j_SFX, "pour", [])
		game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "trash"), "x"), 11.0), J.add(J.getv(J.getv(game.j_ST, "trash"), "y"), 4.0), 14.0, ["#6d6258", "#8a7a6a", "#4a423a"], {"spMax": 60.0, "up": 26.0})
		game.session_system.f_say("Çöp boşaltıldı — tertemiz!")
		return null
	# Kova zaten bos: oyuncu muhtemelen tezgahtaki urunu atmaya calisti; nasil
	# yapilacagini soyle (dokunma / kumandada metin aygita gore degisir)
	game.session_system.f_say("Ürünü atmak için çöp kutusuna sürükle" if f_atilabilirUrunVar() else "Kova zaten boş")
	return null

# Surukle-birak: basildigi nokta bir tahta urunu, birakildigi nokta cop kutusu ise
# o urun atilir. el_bostu: basma ani eldeki bos muydu (basinca urun ele alindiysa
# atilan o urundur). 10 px'ten kisa hareket tiklamadir, atmaz.
const SURUKLE_MIN := 10.0

func f_copUstunde(p: Vector2) -> bool:
	var s: Variant = game.j_ST.get("trash")
	return s != null and Rect2(J.n(s.x), J.n(s.y), J.n(s.w), J.n(s.h)).grow(3.0).has_point(p)

func f_dropOnTrash(down: Vector2, up: Vector2, el_bostu := true) -> bool:
	if down.distance_to(up) < SURUKLE_MIN or not f_copUstunde(up): return false
	var bi := int(game.drag_system.f_boardAt(down.x, down.y))
	if bi < 0: return false
	if el_bostu and J.truth(game.j_G.hand):
		f_discardHand()
		return true
	return f_discardBoard(bi)

# Mufettisin durdugu yer. BIRLESIK (11. tur): sabit 250'deydi; 3 ve ustu
# yerli dukkanda 3. musterinin ustune biniyordu. Bos kalan ilk musteri yerinde
# durur; dukkan 5 yerliyse (bos yer yok) iki yerin tam arasinda.
func mufettis_x() -> float:
	var S: Array = game.j_LAY.custSlots
	var n := int(J.n(game.j_G.cfg.slots))
	if n < S.size(): return J.n(S[n].x)
	return (J.n(S[2].x) + J.n(S[3].x)) / 2.0

# game.js:4413
func f_maybeInspector(p_dt: Variant = null) -> Variant:
	var v_I: Variant = null
	var v_dirty: Variant = null
	var v_dt: Variant = p_dt
	v_I = J.getv(game.j_G, "inspect")
	if (not J.truth(v_I)):
		return null
	if J.eq(J.getv(v_I, "state"), "wait"):
		J.setv(v_I, "t", (J.getv(v_I, "t") - v_dt))
		if J.le(J.getv(v_I, "t"), 0.0):
			J.setv(v_I, "state", "in")
			J.setv(v_I, "t", 0.0)
			J.setv(v_I, "x", J.add(game.j_W, 26.0))
			J.setv(v_I, "look", game.appearance_system.f_newCustomerLook(floor(game.math_utils.f_rnd(1.0, 9999.0))))
			J.setv(J.getv(v_I, "look"), "kalip", "yok")
			J.setv(J.getv(v_I, "look"), "hair", 0.0)
			J.setv(J.getv(v_I, "look"), "glTip", null)
			J.setv(J.getv(v_I, "look"), "acc", "cap")
			J.setv(J.getv(v_I, "look"), "shirt", 7.0)
			J.method(game.j_SFX, "uiBack", [])
		return null
	if J.eq(J.getv(v_I, "state"), "in"):
		J.setv(v_I, "x", game.math_utils.f_approach(J.getv(v_I, "x"), J.getv(v_I, "tx"), (v_dt * 110.0)))
		if J.lt(abs((J.getv(v_I, "x") - J.getv(v_I, "tx"))), 1.0):
			J.setv(v_I, "state", "check")
			J.setv(v_I, "t", 0.0)
		return null
	if J.eq(J.getv(v_I, "state"), "check"):
		J.setv(v_I, "t", J.add(J.getv(v_I, "t"), v_dt))
		if J.gt(J.getv(v_I, "t"), 4.5):
			v_dirty = J.gt(J.getv(game.j_G, "trash"), 0.55)
			J.setv(v_I, "dirty", v_dirty)
			if J.truth(v_dirty):
				J.setv(v_I, "fine", floor(game.math_utils.f_rnd(game.j_FINE_MIN, game.j_FINE_MAX) * game.city_rules.f_carpan("ceza") + 0.5))   # 12. tur: sehir kurali (Paris)
				J.setv(game.j_G, "debt", J.add(J.getv(game.j_G, "debt"), J.getv(v_I, "fine")))
				J.setv(J.getv(game.j_G, "stat"), "fine", J.add((J.getv(J.getv(game.j_G, "stat"), "fine") if J.truth(J.getv(J.getv(game.j_G, "stat"), "fine")) else 0.0), J.getv(v_I, "fine")))
				J.setv(v_I, "line", game.math_utils.f_pick(game.j_LINES_INSPECT_BAD))
				J.method(game.j_SFX, "fine", [])
				game.effects.f_shake(3.0)
				game.effects.f_flash(0.2, "#ff6a4a")
				game.effects.f_ftext(J.add(game.localization.f_T("CEZA +$"), J.getv(v_I, "fine")), J.getv(v_I, "x"), (J.getv(v_I, "y") - 84.0), J.getv(game.j_P, "bad"), {"sc": 1.0, "life": 2.0})
			else:
				J.setv(v_I, "fine", 0.0)
				J.setv(v_I, "line", game.math_utils.f_pick(game.j_LINES_INSPECT_OK))
				J.method(game.j_SFX, "stamp", [])
				game.effects.f_ftext("TEMİZ!", J.getv(v_I, "x"), (J.getv(v_I, "y") - 84.0), J.getv(game.j_P, "ok"), {"sc": 1.0, "life": 1.6})
			J.setv(v_I, "state", "leave")
			J.setv(v_I, "t", 0.0)
			game.save_system.f_saveAll()
		return null
	if J.eq(J.getv(v_I, "state"), "leave"):
		J.setv(v_I, "t", J.add(J.getv(v_I, "t"), v_dt))
		if J.gt(J.getv(v_I, "t"), 2.2):
			J.setv(v_I, "x", J.add(J.getv(v_I, "x"), (v_dt * 110.0)))
			if J.gt(J.getv(v_I, "x"), J.add(game.j_W, 40.0)):
				J.setv(game.j_G, "inspect", null)
	return null

# game.js:4508
func f_kediGuncelle(p_dt: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_M: Variant = null
	var v_hedef: Variant = null
	var v_dt: Variant = p_dt
	v_K = J.getv(game.j_G, "kedi")
	if ((not J.truth(v_K)) or not J.eq(J.getv(game.j_G, "scene"), "play")):
		return null
	J.setv(v_K, "t", J.add(J.getv(v_K, "t"), v_dt))
	if J.gt(J.getv(v_K, "miyav"), 0.0):
		J.setv(v_K, "miyav", (J.getv(v_K, "miyav") - v_dt))
	v_M = game.street_background.f_stM()
	v_hedef = J.add(J.getv(v_M, "gx"), floor((J.getv(v_M, "gw") * 0.53) + 0.5))
	if J.eq(J.getv(v_K, "faz"), "yok"):
		if J.ge(J.getv(v_K, "t"), J.getv(v_K, "girisT")):
			J.setv(v_K, "faz", "gelis")
			J.setv(v_K, "t", 0.0)
			J.setv(v_K, "x", J.add(J.add(J.getv(v_M, "gx"), J.getv(v_M, "gw")), 20.0))
		return null
	if J.eq(J.getv(v_K, "faz"), "gelis"):
		J.setv(v_K, "x", game.math_utils.f_approach(J.getv(v_K, "x"), v_hedef, (v_dt * 42.0)))
		if J.lt(abs((J.getv(v_K, "x") - v_hedef)), 1.0):
			J.setv(v_K, "faz", "bekle")
			J.setv(v_K, "t", 0.0)
			J.setv(v_K, "miyav", 1.6)
			if J.eq(J.kind(J.ref(game.session_system.f_say, 1)), "function"):
				game.session_system.f_say("Kedi geldi — et verirsen şans getirir")
		return null
	if J.eq(J.getv(v_K, "faz"), "bekle"):
		if J.truth(game.f_chance((v_dt * 0.35))):
			J.setv(v_K, "miyav", 1.4)
		if J.ge(J.getv(v_K, "t"), game.j_KEDI_BEKLE):
			J.setv(v_K, "faz", "gidis")
			J.setv(v_K, "t", 0.0)
		return null
	if J.eq(J.getv(v_K, "faz"), "yiyor"):
		if J.gt(J.getv(v_K, "t"), 1.5):
			J.setv(v_K, "faz", "gidis")
			J.setv(v_K, "t", 0.0)
		return null
	if J.eq(J.getv(v_K, "faz"), "gidis"):
		J.setv(v_K, "x", game.math_utils.f_approach(J.getv(v_K, "x"), (J.getv(v_M, "gx") - 30.0), (v_dt * 34.0)))
		if J.le(J.getv(v_K, "x"), (J.getv(v_M, "gx") - 28.0)):
			J.setv(game.j_G, "kedi", null)
	return null

# game.js:4547
func f_kediHit(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_y: Variant = null
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	v_K = J.getv(game.j_G, "kedi")
	if ((not J.truth(v_K)) or (not J.eq(J.getv(v_K, "faz"), "bekle") and not J.eq(J.getv(v_K, "faz"), "gelis"))):
		return false
	v_y = game.event_system.f_kediY()
	return game.math_utils.f_inRect(v_mx, v_my, (J.getv(v_K, "x") - 10.0), (v_y - 16.0), 20.0, 18.0)
	return null

# game.js:4553
func f_kediY() -> Variant:
	return J.add(J.getv(game.street_background.f_stM(), "curb2"), 1.0)
	return null

# game.js:4556
func f_kediBesle() -> Variant:
	var v_K: Variant = null
	var v_ky: Variant = null
	v_K = J.getv(game.j_G, "kedi")
	if (not J.truth(v_K)):
		return false
	if J.le(J.getv(game.j_G, "meat"), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Et yok — önce dönerden kes")
		return true
	J.setv(game.j_G, "meat", (J.getv(game.j_G, "meat") - 1.0))
	J.setv(v_K, "faz", "yiyor")
	J.setv(v_K, "t", 0.0)
	J.setv(v_K, "doydu", true)
	J.setv(v_K, "miyav", 0.0)
	J.setv(game.j_G, "luck", min(game.j_LUCK_MAX, J.add((J.getv(game.j_G, "luck") if J.truth(J.getv(game.j_G, "luck")) else 0.0), 1.0)))
	J.setv(J.getv(game.j_G, "stats"), "kedi", J.add((J.getv(J.getv(game.j_G, "stats"), "kedi") if J.truth(J.getv(J.getv(game.j_G, "stats"), "kedi")) else 0.0), 1.0))
	J.method(game.j_SFX, "ding", [])
	v_ky = game.event_system.f_kediY()
	game.effects.f_burst(J.getv(v_K, "x"), (v_ky - 8.0), 14.0, ["#e2483a", "#ff8a7a", "#ffffff"], {"spMax": 60.0, "up": 24.0, "type": "heart", "sz": 2.0})
	game.effects.f_ftext("ŞANS +1", J.getv(v_K, "x"), (v_ky - 26.0), J.getv(game.j_P, "ok"), {"sc": 1.0, "life": 1.6})
	game.session_system.f_say("Kedi doydu — şans +1")
	if J.eq(J.kind(J.ref(game.achievement_system.f_basarimTara, 1)), "function"):
		game.achievement_system.f_basarimTara()
	return true
	return null

# game.js:4642
func f_kesintiVarMi() -> Variant:
	return (not (not (J.truth(J.getv(game.j_G, "kesinti")) and J.eq(J.getv(J.getv(game.j_G, "kesinti"), "faz"), "kesik"))))
	return null

# game.js:4645
func f_kesintiGuncelle(p_dt: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_gecen: Variant = null
	var v_dt: Variant = p_dt
	v_K = J.getv(game.j_G, "kesinti")
	if (((not J.truth(v_K)) or not J.eq(J.getv(game.j_G, "scene"), "play")) or (not J.truth(J.getv(game.j_G, "cfg")))):
		return null
	v_gecen = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "timeLeft")) / float(J.getv(J.getv(game.j_G, "cfg"), "len"))), 0.0, 1.0))
	if J.eq(J.getv(v_K, "faz"), "bekle"):
		if J.ge(v_gecen, (J.getv(v_K, "basla") - 0.03)):
			J.setv(v_K, "uyari", 1.0)
		if J.ge(v_gecen, J.getv(v_K, "basla")):
			J.setv(v_K, "faz", "kesik")
			J.setv(v_K, "t", 0.0)
			J.setv(v_K, "uyari", 0.0)
			J.method(game.j_SFX, "bad", [])
			game.effects.f_shake(2.2)
			game.session_system.f_say("Elektrik kesildi — ızgara ve fritöz durdu!")
			game.effects.f_ftext("ELEKTRİK KESİNTİSİ", (float(game.j_W) / float(2.0)), 96.0, J.getv(game.j_P, "bad"), {"sc": 2.0, "life": 2.2})
		return null
	if J.eq(J.getv(v_K, "faz"), "kesik"):
		J.setv(v_K, "t", J.add(J.getv(v_K, "t"), v_dt))
		if J.ge(J.getv(v_K, "t"), J.getv(v_K, "sure")):
			J.setv(v_K, "faz", "bitti")
			J.method(game.j_SFX, "levelup", [])
			game.session_system.f_say("Elektrik geldi!")
			game.effects.f_ftext("ELEKTRİK GELDİ", (float(game.j_W) / float(2.0)), 96.0, J.getv(game.j_P, "ok"), {"sc": 2.0, "life": 1.6})
			game.effects.f_flash(0.14, "#ffe9a0")
	return null

