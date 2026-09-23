# Traffic system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:773
func f_t0Bin() -> Variant:
	return (J.getv(game.j_G, "t") if (not J.eq(J.kind(game.j_G), "undefined") and J.truth(J.getv(game.j_G, "t"))) else 0.0)
	return null

# art.js:1035
func f_fazIlerlet(p_S: Variant = null, p_SURE: Variant = null, p_ist: Variant = null, p_sira: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_S: Variant = p_S
	var v_SURE: Variant = p_SURE
	var v_ist: Variant = p_ist
	var v_sira: Variant = p_sira
	J.setv(v_S, "t", J.add(J.getv(v_S, "t"), J.getv(v_S, "dt")))
	v_i = J.method(v_sira, "indexOf", [J.getv(v_S, "faz")])
	if J.eq(J.getv(v_S, "faz"), "yok"):
		if J.truth(v_ist):
			J.setv(v_S, "faz", J.getv(v_sira, 1.0))
			J.setv(v_S, "t", 0.0)
		return null
	if J.eq(J.getv(v_S, "faz"), "bekle"):
		if (not J.truth(v_ist)):
			J.setv(v_S, "faz", J.getv(v_sira, J.add(v_i, 1.0)))
			J.setv(v_S, "t", 0.0)
		return null
	if (not J.eq(J.getv(v_SURE, J.getv(v_S, "faz")), null) and J.ge(J.getv(v_S, "t"), J.getv(v_SURE, J.getv(v_S, "faz")))):
		J.setv(v_S, "faz", J.getv(v_sira, fmod(J.n(J.add(v_i, 1.0)), J.n(J.getv(v_sira, "length")))))
		J.setv(v_S, "t", 0.0)
	return null

# art.js:1045
func f_updateBinek(p_t: Variant = null, p_PK: Variant = null) -> Variant:
	var v_dt: Variant = null
	var v_t: Variant = p_t
	var v_PK: Variant = p_PK
	v_dt = (0.0 if J.lt(game.j__binekT, 0.0) else game.math_utils.f_clamp((v_t - game.j__binekT), 0.0, 0.12))
	game.j__binekT = v_t
	J.setv(game.j_KAR, "dt", v_dt)
	game.traffic_system.f_fazIlerlet(game.j_KAR, game.j_KAR_SURE, (not (not J.truth(J.getv(v_PK, "kimyager")))), game.j_KAR_SIRA)
	J.setv(game.j_EJD, "dt", v_dt)
	game.traffic_system.f_fazIlerlet(game.j_EJD, game.j_EJD_SURE, (not (not J.truth(J.getv(v_PK, "kralice")))), ["yok", "ucus", "inis", "iner", "bekle", "biner", "kalkis"])
	J.setv(game.j_SUP, "dt", v_dt)
	game.traffic_system.f_fazIlerlet(game.j_SUP, game.j_SUP_SURE, (not (not J.truth(J.getv(v_PK, "cirak")))), ["yok", "ucus", "iner", "bekle", "biner", "kalkis"])
	return null

# art.js:1060
func f_binekBekle(p_kalip: Variant = null) -> Variant:
	var v_kalip: Variant = p_kalip
	if J.eq(v_kalip, "kralice"):
		return (((J.eq(J.getv(game.j_EJD, "faz"), "yok") if J.eq(J.getv(game.j_EJD, "faz"), "yok") else J.eq(J.getv(game.j_EJD, "faz"), "ucus")) if (J.eq(J.getv(game.j_EJD, "faz"), "yok") or J.eq(J.getv(game.j_EJD, "faz"), "ucus")) else J.eq(J.getv(game.j_EJD, "faz"), "inis")) if ((J.eq(J.getv(game.j_EJD, "faz"), "yok") or J.eq(J.getv(game.j_EJD, "faz"), "ucus")) or J.eq(J.getv(game.j_EJD, "faz"), "inis")) else (J.lt(J.getv(game.j_EJD, "t"), (J.getv(game.j_EJD_SURE, "iner") * 0.8)) if J.eq(J.getv(game.j_EJD, "faz"), "iner") else J.eq(J.getv(game.j_EJD, "faz"), "iner")))
	if J.eq(v_kalip, "cirak"):
		return ((J.eq(J.getv(game.j_SUP, "faz"), "yok") if J.eq(J.getv(game.j_SUP, "faz"), "yok") else J.eq(J.getv(game.j_SUP, "faz"), "ucus")) if (J.eq(J.getv(game.j_SUP, "faz"), "yok") or J.eq(J.getv(game.j_SUP, "faz"), "ucus")) else (J.lt(J.getv(game.j_SUP, "t"), (J.getv(game.j_SUP_SURE, "iner") * 0.8)) if J.eq(J.getv(game.j_SUP, "faz"), "iner") else J.eq(J.getv(game.j_SUP, "faz"), "iner")))
	if J.eq(v_kalip, "kimyager"):
		return (((J.eq(J.getv(game.j_KAR, "faz"), "yok") if J.eq(J.getv(game.j_KAR, "faz"), "yok") else J.eq(J.getv(game.j_KAR, "faz"), "gelis")) if (J.eq(J.getv(game.j_KAR, "faz"), "yok") or J.eq(J.getv(game.j_KAR, "faz"), "gelis")) else J.eq(J.getv(game.j_KAR, "faz"), "kapiAc")) if ((J.eq(J.getv(game.j_KAR, "faz"), "yok") or J.eq(J.getv(game.j_KAR, "faz"), "gelis")) or J.eq(J.getv(game.j_KAR, "faz"), "kapiAc")) else (J.lt(J.getv(game.j_KAR, "t"), (J.getv(game.j_KAR_SURE, "iner") * 0.8)) if J.eq(J.getv(game.j_KAR, "faz"), "iner") else J.eq(J.getv(game.j_KAR, "faz"), "iner")))
	return false
	return null

# art.js:1205
func f_vehLen(p_type: Variant = null, p_sc: Variant = null) -> Variant:
	var v_b: Variant = null
	var v_type: Variant = p_type
	var v_sc: Variant = p_sc
	v_b = (44.0 if J.eq(v_type, 2.0) else (32.0 if J.eq(v_type, 3.0) else (50.0 if J.eq(v_type, 4.0) else (46.0 if J.eq(v_type, 5.0) else 38.0))))
	return floor((v_b * v_sc) + 0.5)
	return null

# art.js:1344
func f_betonSehir() -> Variant:
	var v_tm: Variant = null
	if not J.eq(J.kind(J.ref(game.city_system.f_sehirTema, 0)), "function"):
		return false
	v_tm = game.city_system.f_sehirTema()
	return (not (not ((J.truth(v_tm) and J.truth(J.getv(v_tm, "cephe"))) and J.eq(J.getv(J.getv(v_tm, "cephe"), "tarz"), "beton"))))
	return null

# art.js:1592
func f_trafInit() -> Variant:
	var v_M: Variant = null
	var v_span: Variant = null
	var v_tema: Variant = null
	var v_tar: Variant = null
	var v_toplam: Variant = null
	var v_sayac: Variant = null
	var v_k: Variant = null
	var v_r: Variant = null
	var v_ln: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	v_M = game.street_background.f_stM()
	v_span = J.add(J.getv(v_M, "gw"), 140.0)
	v_tema = (game.city_system.f_sehirTema() if J.eq(J.kind(J.ref(game.city_system.f_sehirTema, 0)), "function") else null)
	v_tar = (J.getv(v_tema, "trafik") if ((J.truth(v_tema) and J.truth(J.getv(v_tema, "trafik"))) and J.truth(J.getv(J.getv(v_tema, "trafik"), "length"))) else game.j_TRAF_VARSAYILAN)
	v_toplam = [0.0, 0.0]
	v_sayac = [0.0, 0.0]
	v_k = 0.0
	while J.lt(v_k, J.getv(v_tar, "length")):
		J.setv(v_toplam, J.getv(J.getv(v_tar, v_k), 0.0), J.add(J.getv(v_toplam, J.getv(J.getv(v_tar, v_k), 0.0)), 1.0))
		v_k = J.add(v_k, 1.0)
	game.j_TRAF = []
	v_k = 0.0
	while J.lt(v_k, J.getv(v_tar, "length")):
		v_r = J.getv(v_tar, v_k)
		v_ln = J.getv(v_r, 0.0)
		J.method(game.j_TRAF, "push", [{"lane": v_ln, "ty": J.getv(v_r, 1.0), "ci": J.getv(v_r, 2.0), "want": J.getv(v_r, 3.0), "v": J.getv(v_r, 3.0), "u": (float(J.add(J.getv(v_sayac, v_ln), (0.55 if J.truth(v_ln) else 0.05))) / float(max(1.0, J.getv(v_toplam, v_ln))))}])
		J.setv(v_sayac, v_ln, J.add(J.getv(v_sayac, v_ln), 1.0))
		v_k = J.add(v_k, 1.0)
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_TRAF, "length")):
		J.setv(J.getv(game.j_TRAF, v_i), "dir", J.getv(game.j_LANE_DIR, J.getv(J.getv(game.j_TRAF, v_i), "lane")))
		J.setv(J.getv(game.j_TRAF, v_i), "span", v_span)
		v_i = J.add(v_i, 1.0)
	game.j__carSnd = []
	v_j = 0.0
	while J.lt(v_j, J.getv(game.j_TRAF, "length")):
		J.method(game.j__carSnd, "push", [0.0])
		v_j = J.add(v_j, 1.0)
	return null

# art.js:1612
func f_trafGerek() -> Variant:
	var v_c: Variant = null
	v_c = (J.getv(game.j_G, "city") if ((not J.eq(J.kind(game.j_G), "undefined") and J.truth(game.j_G)) and J.eq(J.kind(J.getv(game.j_G, "city")), "number")) else (-J.n(1.0)))
	if ((not J.truth(J.getv(game.j_TRAF, "length"))) or not J.eq(game.j_TRAFCITY, v_c)):
		game.j_TRAFCITY = v_c
		game.traffic_system.f_trafInit()
	return null

# art.js:1618
func f_trafX(p_c: Variant = null, p_M: Variant = null) -> Variant:
	var v_span: Variant = null
	var v_L: Variant = null
	var v_c: Variant = p_c
	var v_M: Variant = p_M
	v_span = J.add(J.getv(v_M, "gw"), 140.0)
	v_L = game.traffic_system.f_vehLen(J.getv(v_c, "ty"), (1.0 if J.truth(J.getv(v_c, "lane")) else 0.86))
	return (J.add(((J.getv(v_M, "gx") - v_L) - 20.0), (J.getv(v_c, "u") * v_span)) if J.gt(J.getv(v_c, "dir"), 0.0) else (J.add(J.add(J.getv(v_M, "gx"), J.getv(v_M, "gw")), 20.0) - (J.getv(v_c, "u") * v_span)))
	return null

# art.js:1629
func f_kornaGuncelle(p_dt: Variant = null, p_t: Variant = null) -> Variant:
	var v_yavas: Variant = null
	var v_n: Variant = null
	var v_i: Variant = null
	var v_yogun: Variant = null
	var v_dt: Variant = p_dt
	var v_t: Variant = p_t
	J.setv(game.j_KORNA, "bek", (J.getv(game.j_KORNA, "bek") - v_dt))
	if J.gt(J.getv(game.j_KORNA, "bek"), 0.0):
		return null
	v_yavas = 0.0
	v_n = J.getv(game.j_TRAF, "length")
	v_i = 0.0
	while J.lt(v_i, v_n):
		if J.lt(J.getv(J.getv(game.j_TRAF, v_i), "v"), (J.getv(J.getv(game.j_TRAF, v_i), "want") * 0.45)):
			v_yavas = J.add(v_yavas, 1.0)
		v_i = J.add(v_i, 1.0)
	v_yogun = ((float(v_yavas) / float(v_n)) if J.truth(v_n) else 0.0)
	if J.lt(v_yogun, 0.25):
		J.setv(game.j_KORNA, "bek", 2.5)
		return null
	J.setv(game.j_KORNA, "bek", J.add(J.add(4.5, ((1.0 - v_yogun) * 16.0)), (game.random_unit() * 4.0)))
	if J.lt((v_t - J.getv(game.j_KORNA, "son")), 2.5):
		return null
	J.setv(game.j_KORNA, "son", v_t)
	if J.eq(J.kind(J.ref(game.f_sndPlay, 2)), "function"):
		game.f_sndPlay(("korna1" if J.lt(game.random_unit(), 0.55) else "korna2"), J.add(0.94, (game.random_unit() * 0.14)))
	return null

# art.js:1647
func f_updateTraffic(p_dt: Variant = null) -> Variant:
	var v_M: Variant = null
	var v_span: Variant = null
	var v_T: Variant = null
	var v_durmaliMi: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_L: Variant = null
	var v_hedef: Variant = null
	var v_burun: Variant = null
	var v_cizgi: Variant = null
	var v_kalan: Variant = null
	var v_enYakin: Variant = null
	var v_j: Variant = null
	var v_o: Variant = null
	var v_fark: Variant = null
	var v_mesafe: Variant = null
	var v_ivme: Variant = null
	var v_onceki: Variant = null
	var v_dt: Variant = p_dt
	game.traffic_system.f_trafGerek()
	v_M = game.street_background.f_stM()
	v_span = J.add(J.getv(v_M, "gw"), 140.0)
	if (not J.eq(J.kind(game.j_G), "undefined") and J.eq(J.getv(game.j_G, "scene"), "play")):
		game.traffic_system.f_kornaGuncelle(v_dt, (J.getv(game.j_G, "t") if J.truth(J.getv(game.j_G, "t")) else 0.0))
	v_T = game.j_TLIGHT
	J.setv(v_T, "t", J.add(J.getv(v_T, "t"), v_dt))
	if (J.eq(J.getv(v_T, "state"), "green") and J.gt(J.getv(v_T, "t"), J.getv(v_T, "GREEN"))):
		J.setv(v_T, "state", "yellow")
		J.setv(v_T, "t", 0.0)
	else:
		if (J.eq(J.getv(v_T, "state"), "yellow") and J.gt(J.getv(v_T, "t"), J.getv(v_T, "YELLOW"))):
			J.setv(v_T, "state", "red")
			J.setv(v_T, "t", 0.0)
		else:
			if (J.eq(J.getv(v_T, "state"), "red") and J.gt(J.getv(v_T, "t"), J.getv(v_T, "RED"))):
				J.setv(v_T, "state", "green")
				J.setv(v_T, "t", 0.0)
	v_durmaliMi = (J.eq(J.getv(v_T, "state"), "red") if J.eq(J.getv(v_T, "state"), "red") else J.eq(J.getv(v_T, "state"), "yellow"))
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_TRAF, "length")):
		v_c = J.getv(game.j_TRAF, v_i)
		v_L = game.traffic_system.f_vehLen(J.getv(v_c, "ty"), (1.0 if J.truth(J.getv(v_c, "lane")) else 0.86))
		v_hedef = J.getv(v_c, "want")
		if J.truth(v_durmaliMi):
			v_burun = J.add(game.traffic_system.f_trafX(v_c, v_M), (v_L if J.gt(J.getv(v_c, "dir"), 0.0) else 0.0))
			v_cizgi = (J.add(J.getv(v_M, "gx"), 192.0) if J.gt(J.getv(v_c, "dir"), 0.0) else J.add(J.getv(v_M, "gx"), 240.0))
			v_kalan = ((v_cizgi - v_burun) * J.getv(v_c, "dir"))
			if (J.gt(v_kalan, (-J.n(2.0))) and J.lt(v_kalan, 52.0)):
				v_hedef = min(v_hedef, max(0.0, ((v_kalan - 2.0) * 1.1)))
		v_enYakin = 1000000000.0
		v_j = 0.0
		while J.lt(v_j, J.getv(game.j_TRAF, "length")):
			if J.eq(v_j, v_i):
				v_j = J.add(v_j, 1.0)
				continue
			v_o = J.getv(game.j_TRAF, v_j)
			if not J.eq(J.getv(v_o, "lane"), J.getv(v_c, "lane")):
				v_j = J.add(v_j, 1.0)
				continue
			v_fark = (J.getv(v_o, "u") - J.getv(v_c, "u"))
			if J.lt(v_fark, 0.0):
				v_fark = J.add(v_fark, 1.0)
			v_mesafe = (((v_fark * v_span) - v_L) - 4.0)
			if J.lt(v_mesafe, v_enYakin):
				v_enYakin = v_mesafe
			v_j = J.add(v_j, 1.0)
		if J.lt(v_enYakin, 34.0):
			v_hedef = min(v_hedef, max(0.0, ((v_enYakin - 5.0) * 1.15)))
		v_ivme = (46.0 if J.lt(v_hedef, J.getv(v_c, "v")) else 15.0)
		if J.lt(J.getv(v_c, "v"), v_hedef):
			J.setv(v_c, "v", min(v_hedef, J.add(J.getv(v_c, "v"), (v_ivme * v_dt))))
		else:
			J.setv(v_c, "v", max(v_hedef, (J.getv(v_c, "v") - (v_ivme * v_dt))))
		if J.lt(J.getv(v_c, "v"), 0.0):
			J.setv(v_c, "v", 0.0)
		v_onceki = J.getv(v_c, "u")
		J.setv(v_c, "u", fmod(J.n(J.add(J.getv(v_c, "u"), (float((J.getv(v_c, "v") * v_dt)) / float(v_span)))), J.n(1.0)))
		if ((J.lt(v_onceki, 0.5) and J.ge(J.getv(v_c, "u"), 0.5)) and J.gt(J.getv(v_c, "v"), 6.0)):
			J.method(game.j_SFX, "carPass", [J.eq(J.getv(v_c, "lane"), 1.0)])
		if (J.lt(J.getv(v_c, "u"), v_onceki) and J.truth(game.f_chance(0.06))):
			J.method(game.j_SFX, "horn", [])
		J.setv(game.j__carSnd, v_i, J.getv(v_c, "u"))
		v_i = J.add(v_i, 1.0)
	return null

# art.js:1850
func f_updateCrossers(p_dt: Variant = null) -> Variant:
	var v_gecebilir: Variant = null
	var v_i: Variant = null
	var v_cr: Variant = null
	var v_dt: Variant = p_dt
	v_gecebilir = J.eq(J.getv(game.j_TLIGHT, "state"), "red")
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_CROSSERS, "length")):
		v_cr = J.getv(game.j_CROSSERS, v_i)
		if J.gt(J.getv(v_cr, "git"), 0.0):
			J.setv(v_cr, "git", (J.getv(v_cr, "git") - v_dt))
			J.setv(v_cr, "kay", J.add(J.getv(v_cr, "kay"), (v_dt * 30.0)))
			if J.le(J.getv(v_cr, "git"), 0.0):
				J.setv(v_cr, "p", 0.0)
				J.setv(v_cr, "kay", 0.0)
				J.setv(v_cr, "git", 0.0)
				J.setv(v_cr, "yon", (-J.n((J.getv(v_cr, "yon") if J.truth(J.getv(v_cr, "yon")) else 1.0))))
				J.setv(v_cr, "bekle", J.add(4.0, (v_i * 3.0)))
		else:
			if (J.gt(J.getv(v_cr, "p"), 0.0) and J.lt(J.getv(v_cr, "p"), 1.0)):
				J.setv(v_cr, "p", J.add(J.getv(v_cr, "p"), (float((J.getv(v_cr, "hiz") * v_dt)) / float(30.0))))
				if J.ge(J.getv(v_cr, "p"), 1.0):
					J.setv(v_cr, "p", 1.0)
					J.setv(v_cr, "git", 3.4)
			else:
				if J.truth(v_gecebilir):
					if J.gt(J.getv(v_cr, "bekle"), 0.0):
						J.setv(v_cr, "bekle", (J.getv(v_cr, "bekle") - v_dt))
					else:
						J.setv(v_cr, "p", 0.001)
						J.setv(v_cr, "bekle", J.add(3.0, (v_i * 2.5)))
		v_i = J.add(v_i, 1.0)
	return null

