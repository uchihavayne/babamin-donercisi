# Customer system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# BIRLESIK (9. tur, genel test): yer doluyken gelen musteri eskiden hic
# dogmuyordu (gelme denemelerinin %45-75'i sessizce kayboluyordu; Tabela
# Dukkani Buyut olmadan etkisizdi, oyuncu kacirdigini gormuyordu). Artik
# camin disinda, kapinin (sag uc) onunde en fazla SIRA_MAX kisi bekler
# (sokakta yaya olarak cizilir); yer acilinca kapiya yurur ve iceri girer,
# SIRA_SURE dolunca kaldirimdan uzaklasir (kacan sayilmaz, gun sonunda
# "kapidan donen").
# 10. tur (kullanici: "musteri kacti vs diye yazi cikmasin; camin disinda
# yakinda siralansinlar, yer yoksa ayrilsinlar"): giden icin yazi / ses yok;
# sira camin dibinde (bisiklet ve cop kutusuyla ayni hizada) durur, gelen ve
# giden onlarin arkasindan kaldirim seridinde yurur.
const SIRA_MAX := 3
const SIRA_SURE := 10.0
const SIRA_ARA := 11.0
const SIRA_HIZ := 26.0
const GIRIS_HIZ := 40.0 # siranin ilki kapiya biraz daha hizli yurur
# sokakta cizilen (henuz iceri girmemis ya da kapidan donen) musteri durumlari
const SOKAK := ["sira", "sira_gir", "sira_git"]

func sokakta(c: Dictionary) -> bool:
	return c.get("state") in SOKAK

func sira_musterileri() -> Array:
	var out: Array = []
	for c in game.j_G.customers:
		if c.get("state") == "sira": out.append(c)
	return out

# kaldirimda k. siradakinin yeri (0: kapiya en yakin). Camin sag ucu, Dukkani
# Buyut son seviyesindeki 5. yerin musterisinin arkasinda kaliyordu (sira tam
# doluyken hic gorunmuyordu); sira son iki musteri yerinin arasindaki, hicbir
# yer duzeninde ortulmeyen bosluga dizilir.
func sira_x(k: int) -> float:
	var S: Array = game.j_LAY.custSlots
	var orta: float = (J.n(S[S.size() - 2].x) + J.n(S[S.size() - 1].x)) / 2.0
	return orta + SIRA_ARA - k * SIRA_ARA

# siranin durdugu cizgi: camin dibi (yakin esyalarla ayni derinlik)
func sira_y() -> float:
	var M: Dictionary = game.street_background.f_stM()
	return J.n(M.gy) + J.n(M.gh) - 1.0

# gelenin / gidenin yurudugu serit: siranin arkasi, bordure yakin
func yol_y() -> float:
	var M: Dictionary = game.street_background.f_stM()
	return J.n(M.curb2) + 3.0

# kapi: camin sag ucunun ardi; siranin ilki buraya yuruyup iceri girer
func kapi_x() -> float:
	var M: Dictionary = game.street_background.f_stM()
	return J.n(M.gx) + J.n(M.gw) + 8.0

func bos_yerler() -> Array:
	var dolu := {}
	for c in game.j_G.customers:
		# "sorgu": cikarken kapida gozcuye yakalanan musteri (Demirkent); yerini birakmistir
		if not c.get("state") in ["leave", "sorgu", "sira", "sira_git"]: dolu[int(J.n(c.get("slot", -1)))] = true
	var out: Array = []
	for s in int(J.n(game.j_G.cfg.slots)):
		if not dolu.has(s): out.append(s)
	return out

# sessizce siradan cikip gider (yazi / ses yok). sayilir: gun sonundaki
# "kapidan donen" (lider gelince dagilan sira sayilmaz)
func kapidan_don(c: Dictionary, sayilir := true) -> void:
	c.state = "sira_git"; c.mood = "angry"; c.slot = -1.0
	if sayilir: game.j_G.stat.yerYok = J.n(game.j_G.stat.get("yerYok", 0.0)) + 1.0

# kapiya varan musteri iceri girer (sagdan, yerine yurur)
func kapidan_gir(c: Dictionary) -> void:
	var ks: Dictionary = game.j_LAY.custSlots[int(J.n(c.slot))]
	c.tx = ks.x; c.y = ks.y; c.state = "walkin"; c.mood = "wait"
	c.x = J.add(game.j_W, 24.0)
	J.method(game.j_SFX, "door", [])
	if J.truth(c.get("homeless")): evsiz_geldi(c)

func evsiz_geldi(c: Dictionary) -> void:
	c.line = game.math_utils.f_pick(game.j_LINES_HOMELESS)
	c.lineT = 3.2
	game.session_system.f_say("Aç bir misafir geldi — dürüm verirsen şansın açılır")

# sokakta cizim icin: yurur (yuruyus karesi) ve yon (-1 sola, 1 saga)
func _sokak_adim(c: Dictionary, hx: float, hy: float, dt: float, yuz: float) -> void:
	var x0 := float(c.x)
	var y0 := J.n(c.get("sy", hy))
	c.x = game.math_utils.f_approach(x0, hx, dt * SIRA_HIZ)
	c.sy = game.math_utils.f_approach(y0, hy, dt * 20.0)
	var dx: float = float(c.x) - x0
	c.yurur = absf(dx) > 0.0001 or absf(float(c.sy) - y0) > 0.0001
	if absf(dx) > 0.0001: c.yon = signf(dx)
	elif not c.yurur: c.yon = yuz

func sira_guncelle(dt: float) -> void:
	var M: Dictionary = game.street_background.f_stM()
	var i: int = game.j_G.customers.size() - 1
	while i >= 0:
		var g: Dictionary = game.j_G.customers[i]
		if g.get("state") == "sira_git":
			# siranin arkasindaki seride gecip sola yurur, camin disina cikinca silinir
			_sokak_adim(g, float(g.x) - 1000.0, yol_y(), dt, -1.0)
			if float(g.x) < J.n(M.gx) - 12.0: game.j_G.customers.remove_at(i)
		elif g.get("state") == "sira_gir":
			_sokak_adim(g, kapi_x(), sira_y(), dt * GIRIS_HIZ / SIRA_HIZ, 1.0)
			if absf(float(g.x) - kapi_x()) < 0.5: kapidan_gir(g)
		i -= 1
	var sira := sira_musterileri()
	if sira.is_empty(): return
	var bekler: bool = not J.truth(game.gameplay_input.f_tutBusy())
	for k in sira.size():
		var c: Dictionary = sira[k]
		var hx := sira_x(k)
		# yeni gelen siradakilerin arkasindan yurur, yerine varinca cama yanasir;
		# sira ilerleyince camin dibinde bir adim one kayar
		if absf(float(c.x) - hx) < 3.0: c.dizide = true
		_sokak_adim(c, hx, sira_y() if J.truth(c.get("dizide")) else yol_y(), dt, 1.0)
		if bekler: c.siraT = J.n(c.get("siraT", 0.0)) + dt
	var bos := bos_yerler()
	if not bos.is_empty():
		# yer ayrilir; siranin ilki kapiya yurur (sira_gir), kapida iceri girer
		var ilk: Dictionary = sira[0]
		ilk.slot = float(game.math_utils.f_pick(bos)); ilk.state = "sira_gir"
		return
	for c in sira:
		if J.n(c.siraT) > J.n(c.siraMax): kapidan_don(c)

# game.js:2085
func f_spawnCustomer() -> Variant:
	var v_used: Variant = null
	var v_i: Variant = null
	var v_free: Variant = null
	var v_s: Variant = null
	var v_slot: Variant = null
	var v_homeless: Variant = null
	var v_items: Variant = null
	var v_ek: Variant = null
	var v_pat: Variant = null
	var v_look: Variant = null
	var v_c: Variant = null
	v_used = {}
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		if not J.getv(J.getv(J.getv(game.j_G, "customers"), v_i), "state") in ["leave", "sorgu"]:
			J.setv(v_used, J.getv(J.getv(J.getv(game.j_G, "customers"), v_i), "slot"), 1.0)
		v_i = J.add(v_i, 1.0)
	v_free = []
	v_s = 0.0
	while J.lt(v_s, J.getv(J.getv(game.j_G, "cfg"), "slots")):
		if (not J.truth(J.getv(v_used, v_s))):
			J.method(v_free, "push", [v_s])
		v_s = J.add(v_s, 1.0)
	# yer yoksa ya da kapida sira varsa yeni gelen sirada bekler (siranin onune gecmez)
	var sira_n: int = sira_musterileri().size()
	var kapida: bool = (not J.truth(J.getv(v_free, "length"))) or sira_n > 0
	if kapida and sira_n >= SIRA_MAX:
		game.j_G.stat.yerYok = J.n(game.j_G.stat.get("yerYok", 0.0)) + 1.0
		return null
	v_slot = -1.0 if kapida else game.math_utils.f_pick(v_free)
	J.setv(game.j_G, "macDalga", game.weather_system.f_macDalgada())
	v_homeless = (game.f_chance((float(game.j_HOMELESS_CHANCE) / float(14.0))) if (J.ge(J.getv(game.j_G, "day"), game.j_HOMELESS_DAY) and (not J.truth(J.getv(game.j_G, "hadHomeless")))) else ((not J.truth(J.getv(game.j_G, "hadHomeless"))) if J.ge(J.getv(game.j_G, "day"), game.j_HOMELESS_DAY) else J.ge(J.getv(game.j_G, "day"), game.j_HOMELESS_DAY)))
	v_items = ([{"kind": "wrap"}] if J.truth(v_homeless) else game.recipe_system.f_makeOrder(game.j_G))
	if ((((not J.truth(v_homeless)) and J.truth(game.progression_system.f_fermanDunya("sokak"))) and J.lt(J.getv(v_items, "length"), 3.0)) and J.truth(game.f_chance(0.7))):
		v_ek = game.recipe_system.f_makeOrder(game.j_G)
		if (J.truth(v_ek) and J.truth(J.getv(v_ek, "length"))):
			v_items = J.method(v_items, "concat", [[J.getv(v_ek, 0.0)]])
	v_pat = (((((52.0 - min(16.0, (J.getv(game.j_G, "day") * 0.9))) * J.method(game.j_TUN, "patience", [game.j_G])) * J.add(1.0, ((J.getv(v_items, "length") - 1.0) * 0.45))) * J.method(game.j_TUN, "havaSabir", [game.j_G])) * J.method(game.j_TUN, "macSabir", [game.j_G]))
	if J.truth(v_homeless):
		v_pat = (v_pat * 2.2)
		J.setv(game.j_G, "hadHomeless", true)
	v_look = game.appearance_system.f_newCustomerLook(floor(game.math_utils.f_rnd(1.0, 9999.0)))
	if J.truth(v_homeless):
		J.setv(v_look, "shirt", 5.0)
		J.setv(v_look, "hair", 2.0)
		J.setv(v_look, "acc", "cap")
	if not kapida: J.method(game.j_SFX, "door", []) # siradaki kapidan girince calar
	v_c = {"slot": v_slot, "homeless": v_homeless, "look": v_look, "mac": (not (not J.truth(J.getv(game.j_G, "macDalga")))), "items": v_items, "done": J.method(v_items, "map", [game.customer_system._closure_249.bind({})]), "patMax": v_pat, "patience": 1.0, "t": 0.0, "mood": "wait", "state": "walkin", "x": J.add(game.j_W, 24.0), "y": J.getv(J.getv(J.getv(game.j_LAY, "custSlots"), (0.0 if kapida else v_slot)), "y"), "tx": (0.0 if kapida else J.getv(J.getv(J.getv(game.j_LAY, "custSlots"), v_slot), "x")), "bubble": 0.0, "line": "", "lineT": 0.0, "wrongT": 0.0, "earn": 0.0}
	if kapida:
		v_c.state = "sira"; v_c.siraT = 0.0
		# kaldirimin sagindan (kapi tarafi) siranin arkasindaki seritten gelir
		v_c.x = kapi_x() + 8.0; v_c.sy = yol_y()
		v_c.siraMax = SIRA_SURE * J.n(J.method(game.j_TUN, "patience", [game.j_G]))
	J.method(J.getv(game.j_G, "customers"), "push", [v_c])
	# ac misafir sirada beklerse duyuru iceri girince (kapidan_gir)
	if J.truth(v_homeless) and not kapida: evsiz_geldi(v_c)
	return null

# game.js:2125
func f_updateCustomers(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_c: Variant = null
	var v_kr: Variant = null
	var v_sr: Variant = null
	var v_dt: Variant = p_dt
	sira_guncelle(float(v_dt))
	v_i = (J.getv(J.getv(game.j_G, "customers"), "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		J.setv(v_c, "t", J.add(J.getv(v_c, "t"), v_dt))
		if J.gt(J.getv(v_c, "lineT"), 0.0):
			J.setv(v_c, "lineT", (J.getv(v_c, "lineT") - v_dt))
		if J.gt(J.getv(v_c, "wrongT"), 0.0):
			J.setv(v_c, "wrongT", (J.getv(v_c, "wrongT") - v_dt))
		if J.eq(J.getv(v_c, "state"), "walkin"):
			if ((J.eq(J.kind(J.ref(game.traffic_system.f_binekBekle, 1)), "function") and J.truth(J.getv(v_c, "look"))) and J.truth(game.traffic_system.f_binekBekle(J.getv(J.getv(v_c, "look"), "kalip")))):
				J.setv(v_c, "x", J.add(game.j_W, 24.0))
			else:
				J.setv(v_c, "x", game.math_utils.f_approach(J.getv(v_c, "x"), J.getv(v_c, "tx"), (v_dt * 120.0)))
			if J.lt(abs((J.getv(v_c, "x") - J.getv(v_c, "tx"))), 1.0):
				J.setv(v_c, "state", "wait")
				v_kr = (J.getv(game.j_KALIP_REPLIK, J.getv(J.getv(v_c, "look"), "kalip")) if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
				if (J.truth(v_kr) and (not J.truth(J.getv(v_c, "homeless")))):
					J.setv(v_c, "line", v_kr)
					J.setv(v_c, "lineT", 3.4)
				else:
					if ((not J.truth(J.getv(v_c, "homeless"))) and J.eq(J.kind(J.ref(game.progression_system.f_secimReplik, 1)), "function")):
						v_sr = game.progression_system.f_secimReplik((J.getv(J.getv(v_c, "items"), 0.0) if J.truth(J.getv(v_c, "items")) else J.getv(v_c, "items")))
						if J.truth(v_sr):
							J.setv(v_c, "line", v_sr)
							J.setv(v_c, "lineT", 3.0)
		else:
			if J.eq(J.getv(v_c, "state"), "wait"):
				J.setv(v_c, "bubble", min(1.0, J.add(J.getv(v_c, "bubble"), (v_dt * 5.0))))
				if (not J.truth(game.gameplay_input.f_tutBusy())):
					J.setv(v_c, "patience", (J.getv(v_c, "patience") - (float(v_dt) / float(J.getv(v_c, "patMax")))))
				if (not J.truth(J.getv(v_c, "mad"))):
					J.setv(v_c, "mood", ("angry" if J.lt(J.getv(v_c, "patience"), 0.3) else "wait"))
				if ((J.truth(game.f_chance((v_dt * 0.12))) and J.le(J.getv(v_c, "lineT"), 0.0)) and J.lt(J.getv(v_c, "patience"), 0.55)):
					J.setv(v_c, "line", game.math_utils.f_pick((game.j_LINES_ANGRY if J.lt(J.getv(v_c, "patience"), 0.3) else game.j_LINES_WAIT)))
					J.setv(v_c, "lineT", 1.8)
				if J.le(J.getv(v_c, "patience"), 0.0):
					J.setv(v_c, "state", "leave")
					J.setv(v_c, "leaveDir", 1.0)
					if J.truth(J.getv(v_c, "homeless")):
						J.setv(v_c, "mood", "wait")
						J.setv(v_c, "line", "")
						J.setv(v_c, "lineT", 0.0)
					else:
						J.setv(v_c, "mood", "angry")
						J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_ANGRY))
						J.setv(v_c, "lineT", 2.2)
						J.setv(J.getv(game.j_G, "stat"), "lost", J.add(J.getv(J.getv(game.j_G, "stat"), "lost"), 1.0))
						J.setv(J.getv(game.j_G, "stat"), "seri", 0.0)
						J.method(game.j_SFX, "angry", [])
						game.effects.f_shake(2.5)
			else:
				if J.eq(J.getv(v_c, "state"), "served"):
					J.setv(v_c, "bubble", max(0.0, (J.getv(v_c, "bubble") - (v_dt * 4.0))))
					if J.gt((J.getv(v_c, "t") - J.getv(v_c, "servedAt")), 1.0):
						J.setv(v_c, "state", "leave")
						J.setv(v_c, "leaveDir", 1.0)
				else:
					if J.eq(J.getv(v_c, "state"), "sorgu"):
						J.setv(v_c, "sorguT", J.add((J.getv(v_c, "sorguT") if J.truth(J.getv(v_c, "sorguT")) else 0.0), v_dt))
						J.setv(v_c, "bubble", max(0.0, (J.getv(v_c, "bubble") - (v_dt * 5.0))))
						if J.gt(J.getv(v_c, "sorguT"), 2.6):
							J.setv(v_c, "state", "leave")
							J.setv(v_c, "mood", "angry")
					else:
						if J.eq(J.getv(v_c, "state"), "leave"):
							J.setv(v_c, "x", J.add(J.getv(v_c, "x"), (((1.0 if J.gt(J.getv(v_c, "leaveDir"), 0.0) else (-J.n(1.0))) * v_dt) * 100.0)))
							J.setv(v_c, "bubble", max(0.0, (J.getv(v_c, "bubble") - (v_dt * 5.0))))
							if (J.lt(J.getv(v_c, "x"), (-J.n(40.0))) or J.gt(J.getv(v_c, "x"), J.add(game.j_W, 40.0))):
								J.method(J.getv(game.j_G, "customers"), "splice", [v_i, 1.0])
		v_i = (v_i - 1.0)
	return null

# game.js:2200
func f_custHit(p_c: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_c: Variant = p_c
	v_p = (10.0 if J.truth(game.j_TOUCH) else 0.0)
	return game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), ((J.getv(v_c, "x") - 20.0) - v_p), ((J.getv(v_c, "y") - 54.0) - v_p), J.add(40.0, (v_p * 2.0)), J.add(54.0, (v_p * 2.0)))
	return null

# game.js:2208
func f_surukleServis() -> Variant:
	var v_i: Variant = null
	var v_c: Variant = null
	if ((not J.truth(J.getv(game.j_G, "hand"))) or (not J.truth(J.getv(game.j_IN, "released")))):
		return false
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		if not J.eq(J.getv(v_c, "state"), "wait"):
			v_i = J.add(v_i, 1.0)
			continue
		if (not J.truth(game.customer_system.f_custHit(v_c))):
			v_i = J.add(v_i, 1.0)
			continue
		game.f_deliver(v_c)
		return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# game.js:2220
func f_deliver(p_c: Variant = null) -> Variant:
	var v_it: Variant = null
	var v_yasakM: Variant = null
	var v_yasakU: Variant = null
	var v_idx: Variant = null
	var v_pass: Variant = null
	var v_i: Variant = null
	var v_o: Variant = null
	var v_ord: Variant = null
	var v_sauceOk: Variant = null
	var v_price: Variant = null
	var v_q: Variant = null
	var v_secimOk: Variant = null
	var v_all: Variant = null
	var v_d: Variant = null
	var v_c: Variant = p_c
	v_it = J.getv(game.j_G, "hand")
	if ((not J.truth(v_it)) or not J.eq(J.getv(v_c, "state"), "wait")):
		return null
	if (J.truth(game.leader_system.f_liderBekliyor()) and J.truth(game.leader_system.f_liderVer(v_it))):
		return null
	if ((J.eq(J.getv(v_it, "kind"), "wrap") and J.eq(J.getv(v_it, "state"), "rolled")) and (not J.truth(J.getv(v_it, "paper")))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce kâğıtla — kağıtsız dürüm verilmez")
		return null
	v_yasakM = game.regulation_system.f_fermanYasakMusteri(v_c)
	if J.truth(v_yasakM):
		game.regulation_system.f_fermanKacak(v_yasakM, v_c, J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0))
	v_yasakU = game.regulation_system.f_fermanYasakUrun(v_it)
	if J.truth(v_yasakU):
		game.regulation_system.f_fermanKacak(v_yasakU, v_c, J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0))
	if (J.eq(J.getv(v_it, "kind"), "wrap") and J.truth(J.getv(v_it, "burnt"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Yanmış dürüm satılmaz — çöpe at")
		return null
	if ((J.eq(J.getv(v_it, "kind"), "wrap") and J.truth(J.method(game.j_TUN, "grillOn", [game.j_G]))) and (not J.truth(J.getv(v_it, "grilled")))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Izgarasız dürüm olmaz — önce ızgaraya at")
		return null
	v_idx = (-J.n(1.0))
	v_pass = 0.0
	# BIRLESIK (7. tur): 3. gecis eksik malzemeli durumu da kabul eder (once ayni
	# soslu kalem); ucret kaliteyle (order_system.order_quality) carpilir.
	while (J.lt(v_pass, 4.0) and J.lt(v_idx, 0.0)):
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(v_c, "items"), "length")):
			if J.truth(J.getv(J.getv(v_c, "done"), v_i)):
				v_i = J.add(v_i, 1.0)
				continue
			v_o = J.getv(J.getv(v_c, "items"), v_i)
			if not J.eq(J.getv(v_o, "kind"), J.getv(v_it, "kind")):
				v_i = J.add(v_i, 1.0)
				continue
			if (J.eq(J.getv(v_it, "kind"), "drink") and not J.eq(J.getv(v_o, "type"), J.getv(v_it, "type"))):
				v_i = J.add(v_i, 1.0)
				continue
			if (((J.eq(v_pass, 0.0) or J.eq(v_pass, 2.0)) and J.eq(J.getv(v_it, "kind"), "wrap")) and not J.eq((J.getv(v_o, "sauce") if J.truth(J.getv(v_o, "sauce")) else null), (J.getv(v_it, "sauce") if J.truth(J.getv(v_it, "sauce")) else null))):
				v_i = J.add(v_i, 1.0)
				continue
			if J.lt(v_pass, 2.0) and J.eq(J.getv(v_it, "kind"), "wrap") and not game.f_secimUyuyor(v_it, v_o):
				v_i = J.add(v_i, 1.0)
				continue
			# gevsek gecis: order_system'in sectigi en iyi kalem (order_loose_index)
			if J.ge(v_pass, 2.0) and v_it is Dictionary and v_it.has("_teslim_idx") and not J.eq(v_i, v_it._teslim_idx):
				v_i = J.add(v_i, 1.0)
				continue
			v_idx = v_i
			break
			v_i = J.add(v_i, 1.0)
		v_pass = J.add(v_pass, 1.0)
	if J.lt(v_idx, 0.0):
		J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_WRONG))
		J.setv(v_c, "lineT", 1.6)
		J.setv(v_c, "wrongT", 0.6)
		J.method(game.j_SFX, "bad", [])
		game.effects.f_ftext("YANLIŞ!", J.getv(v_c, "x"), (J.getv(v_c, "y") - 62.0), J.getv(game.j_P, "bad"))
		return null
	J.setv(J.getv(v_c, "done"), v_idx, true)
	v_ord = J.getv(J.getv(v_c, "items"), v_idx)
	v_sauceOk = ((not J.truth(J.getv(v_ord, "sauce"))) if (not J.truth(J.getv(v_ord, "sauce"))) else J.eq(J.getv(v_it, "sauce"), J.getv(v_ord, "sauce")))
	v_price = (game.recipe_system.f_itemPrice({"kind": "wrap", "grilled": J.getv(v_it, "grilled"), "sauce": (J.getv(v_ord, "sauce") if J.truth(v_sauceOk) else null)}, game.j_G) if J.eq(J.getv(v_it, "kind"), "wrap") else game.recipe_system.f_itemPrice(v_it, game.j_G))
	v_q = 1.0
	if (J.eq(J.getv(v_it, "kind"), "wrap") or J.eq(J.getv(v_it, "kind"), "plate")):
		v_q = ((game.recipe_system.f_plateQuality(v_it) if J.eq(J.getv(v_it, "kind"), "plate") else game.f_wrapQuality(v_it)) if J.eq(J.getv(v_it, "quality"), null) else J.getv(v_it, "quality"))
		v_price = max(2.0, floor((v_price * v_q) + 0.5))
		if J.lt(v_q, 0.99):
			J.setv(v_c, "mad", true)
			J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_CHEAP))
			J.setv(v_c, "lineT", 1.8)
			J.setv(v_c, "patience", max(0.05, (J.getv(v_c, "patience") - ((1.0 - v_q) * 0.35))))
			game.effects.f_ftext(J.add(J.add(game.localization.f_T("EKSİK! -%"), floor(((1.0 - v_q) * 100.0) + 0.5)), game.math_utils.yuzde_sonu()), J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0), J.getv(game.j_P, "bad"), {"life": 1.3})
			J.method(game.j_SFX, "bad", [])
	v_secimOk = (not J.eq(J.getv(v_it, "kind"), "wrap") if not J.eq(J.getv(v_it, "kind"), "wrap") else game.f_secimUyuyor(v_it, v_ord))
	if (not J.truth(v_secimOk)):
		v_price = max(2.0, floor((v_price * 0.6) + 0.5))
		v_q = min(v_q, 0.75)
		J.setv(v_c, "mad", true)
		J.setv(v_c, "madSebep", "secim")
		J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_SECIM))
		J.setv(v_c, "lineT", 1.9)
		J.setv(v_c, "patience", max(0.05, (J.getv(v_c, "patience") - 0.18)))
		game.effects.f_ftext(game.localization.f_T("İSTEDİĞİ GİBİ DEĞİL!"), J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0), J.getv(game.j_P, "bad"), {"life": 1.3})
		J.method(game.j_SFX, "bad", [])
	if (not J.truth(v_sauceOk)):
		v_price = max(2.0, floor((v_price * 0.65) + 0.5))
		v_q = min(v_q, 0.8)
		J.setv(v_c, "mad", true)
		J.setv(v_c, "madSebep", "sos")
		J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_SAUCE))
		J.setv(v_c, "lineT", 1.9)
		J.setv(v_c, "patience", max(0.05, (J.getv(v_c, "patience") - 0.18)))
		game.effects.f_ftext("SOS YANLIŞ!", J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0), J.getv(game.j_P, "bad"), {"life": 1.3})
		J.method(game.j_SFX, "bad", [])
	if J.truth(J.getv(v_c, "homeless")):
		v_price = 0.0
	J.setv(v_c, "earn", J.add((J.getv(v_c, "earn") if J.truth(J.getv(v_c, "earn")) else 0.0), v_price))
	if J.eq(J.getv(v_it, "kind"), "wrap"):
		J.setv(J.getv(game.j_G, "stat"), "wraps", J.add(J.getv(J.getv(game.j_G, "stat"), "wraps"), 1.0))
	else:
		if J.eq(J.getv(v_it, "kind"), "plate"):
			J.setv(J.getv(game.j_G, "stat"), "isk", J.add(J.getv(J.getv(game.j_G, "stat"), "isk"), 1.0))
		else:
			if J.eq(J.getv(v_it, "kind"), "drink"):
				J.setv(J.getv(game.j_G, "stat"), "drinks", J.add(J.getv(J.getv(game.j_G, "stat"), "drinks"), 1.0))
			else:
				if J.eq(J.getv(v_it, "kind"), "fbox"):
					J.setv(J.getv(game.j_G, "stat"), "boxes", J.add(J.getv(J.getv(game.j_G, "stat"), "boxes"), 1.0))
				else:
					if J.eq(J.getv(v_it, "kind"), "sweet"):
						J.setv(J.getv(game.j_G, "stat"), "sweets", J.add(J.getv(J.getv(game.j_G, "stat"), "sweets"), 1.0))
	J.setv(game.j_G, "totalSold", J.add(J.getv(game.j_G, "totalSold"), 1.0))
	J.setv(game.j_G, "hand", null)
	game.effects.f_burst(J.getv(v_c, "x"), (J.getv(v_c, "y") - 26.0), (5.0 if J.lt(v_q, 0.99) else 8.0), ([J.getv(game.j_P, "warn"), "#fff"] if J.lt(v_q, 0.99) else [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"]), {"spMax": 70.0, "up": 25.0, "sz": 2.0})
	if J.ge(v_q, 0.99):
		J.method(game.j_SFX, "serve", [])
	J.setv(v_c, "mood", ("angry" if J.lt(v_q, 0.99) else "happy"))
	v_all = true
	v_d = 0.0
	while J.lt(v_d, J.getv(J.getv(v_c, "done"), "length")):
		if (not J.truth(J.getv(J.getv(v_c, "done"), v_d))):
			v_all = false
		v_d = J.add(v_d, 1.0)
	if J.truth(v_all):
		game.customer_system.f_payCustomer(v_c)
	return null

# game.js:2325
func f_payCustomer(p_c: Variant = null) -> Variant:
	var v_val: Variant = null
	var v_tip: Variant = null
	var v_n: Variant = null
	var v_i: Variant = null
	var v_c: Variant = p_c
	if J.truth(J.getv(v_c, "homeless")):
		J.setv(v_c, "state", "served")
		J.setv(v_c, "servedAt", J.getv(v_c, "t"))
		J.setv(v_c, "mood", "happy")
		J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_HOMELESS_OK))
		J.setv(v_c, "lineT", 2.6)
		J.setv(game.j_G, "luck", min(game.j_LUCK_MAX, J.add((J.getv(game.j_G, "luck") if J.truth(J.getv(game.j_G, "luck")) else 0.0), 1.0)))
		J.setv(J.getv(game.j_G, "stats"), "fed", J.add((J.getv(J.getv(game.j_G, "stats"), "fed") if J.truth(J.getv(J.getv(game.j_G, "stats"), "fed")) else 0.0), 1.0))
		J.method(game.j_SFX, "ding", [])
		J.method(game.j_SFX, "levelup", [])
		game.effects.f_burst(J.getv(v_c, "x"), (J.getv(v_c, "y") - 30.0), 18.0, ["#e2483a", "#ff8a7a", "#ffffff"], {"spMax": 70.0, "up": 28.0, "type": "heart", "sz": 2.0})
		game.effects.f_ftext("ŞANS +1", J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0), J.getv(game.j_P, "ok"), {"sc": 1.0, "life": 1.8})
		game.effects.f_flash(0.1, "#ffd7d0")
		game.save_system.f_saveAll()
		return null
	v_val = (J.getv(v_c, "earn") if J.truth(J.getv(v_c, "earn")) else 0.0)
	v_tip = floor(((((v_val * 0.22) * game.math_utils.f_clamp(J.getv(v_c, "patience"), 0.0, 1.0)) * J.method(game.j_TUN, "havaBahsis", [game.j_G])) * (1.55 if J.truth(J.getv(v_c, "mac")) else 1.0)) + 0.5)
	J.setv(v_c, "state", "served")
	J.setv(v_c, "servedAt", J.getv(v_c, "t"))
	J.setv(v_c, "mood", ("angry" if J.truth(J.getv(v_c, "mad")) else "served"))
	J.setv(v_c, "line", game.math_utils.f_pick((game.j_LINES_HAPPY if (not J.truth(J.getv(v_c, "mad"))) else (game.j_LINES_SECIM if J.eq(J.getv(v_c, "madSebep"), "secim") else (game.j_LINES_SAUCE if J.eq(J.getv(v_c, "madSebep"), "sos") else game.j_LINES_CHEAP)))))
	J.setv(v_c, "lineT", 1.8)
	J.setv(J.getv(game.j_G, "stat"), "earned", J.add(J.getv(J.getv(game.j_G, "stat"), "earned"), J.add(v_val, v_tip)))
	J.setv(J.getv(game.j_G, "stat"), "tips", J.add(J.getv(J.getv(game.j_G, "stat"), "tips"), v_tip))
	if (not J.truth(J.getv(v_c, "mad"))):
		J.setv(J.getv(game.j_G, "stat"), "seri", J.add((J.getv(J.getv(game.j_G, "stat"), "seri") if J.truth(J.getv(J.getv(game.j_G, "stat"), "seri")) else 0.0), 1.0))
		if J.gt(J.getv(J.getv(game.j_G, "stat"), "seri"), (J.getv(J.getv(game.j_G, "stats"), "enSeri") if J.truth(J.getv(J.getv(game.j_G, "stats"), "enSeri")) else 0.0)):
			J.setv(J.getv(game.j_G, "stats"), "enSeri", J.getv(J.getv(game.j_G, "stat"), "seri"))
	else:
		J.setv(J.getv(game.j_G, "stat"), "seri", 0.0)
	if J.gt(v_tip, (J.getv(J.getv(game.j_G, "stats"), "enBahsis") if J.truth(J.getv(J.getv(game.j_G, "stats"), "enBahsis")) else 0.0)):
		J.setv(J.getv(game.j_G, "stats"), "enBahsis", v_tip)
	if (J.truth(J.getv(v_c, "items")) and J.ge(J.getv(J.getv(v_c, "items"), "length"), 4.0)):
		J.setv(J.getv(game.j_G, "stats"), "buyukSiparis", J.add((J.getv(J.getv(game.j_G, "stats"), "buyukSiparis") if J.truth(J.getv(J.getv(game.j_G, "stats"), "buyukSiparis")) else 0.0), 1.0))
	game.event_system.f_addTrash(game.j_TRASH_PER_SALE)
	v_n = game.math_utils.f_clamp(floor((float(J.add(v_val, v_tip)) / float(10.0)) + 0.5), 1.0, 6.0)
	v_i = 0.0
	while J.lt(v_i, v_n):
		J.method(J.getv(game.j_G, "coins"), "push", [{"x": J.add(J.getv(v_c, "x"), game.math_utils.f_rnd((-J.n(14.0)), 14.0)), "y": (J.getv(v_c, "y") - 30.0), "vy": game.math_utils.f_rnd((-J.n(70.0)), (-J.n(40.0))), "vx": game.math_utils.f_rnd((-J.n(18.0)), 18.0), "v": game.payment_system.coin_share(int(J.add(v_val, v_tip)), int(v_n), int(v_i)), "t": game.math_utils.f_rnd(0.0, 3.0), "landed": 0.0, "life": 0.0, "ph": game.math_utils.f_rnd(0.0, 6.0)}])
		v_i = J.add(v_i, 1.0)
	J.method(game.j_SFX, "cash", [])
	game.effects.f_ftext(J.add("+$", game.math_utils.f_fmtMoney(J.add(v_val, v_tip))), J.getv(v_c, "x"), (J.getv(v_c, "y") - 46.0), J.getv(game.j_P, "au1"))
	game.effects.f_flash(0.08, "#ffe9a0")
	return null

func _closure_249(_args: Array, _captures: Dictionary = {}) -> Variant:
	return false
	return null

