# Regulation system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:668
func f_fermanBitti() -> Variant:
	return (J.ge((J.getv(game.j_G, "fbatik") if J.truth(J.getv(game.j_G, "fbatik")) else 0.0), game.j_FP_BATIK_SINIR) if J.ge((J.getv(game.j_G, "fbatik") if J.truth(J.getv(game.j_G, "fbatik")) else 0.0), game.j_FP_BATIK_SINIR) else (J.eq(game.progression_system.f_haneCanli(J.getv(game.j_G, "hane")), 0.0) if J.truth(J.getv(game.j_G, "hane")) else J.getv(game.j_G, "hane")))
	return null

# game.js:674
func f_fermanYasakMusteri(p_c: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_i: Variant = null
	var v_f: Variant = null
	var v_c: Variant = p_c
	v_F = J.getv(game.j_G, "ferman")
	if ((not J.truth(v_F)) or J.truth(J.getv(v_F, "kapandi"))):
		return null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_F, "liste"), "length")):
		v_f = J.getv(J.getv(v_F, "liste"), v_i)
		if (J.eq(J.getv(v_f, "tip"), "musteri") and J.truth(J.method(v_f, "test", [v_c]))):
			return v_f
		v_i = J.add(v_i, 1.0)
	return null
	return null

# game.js:684
func f_fermanYasakUrun(p_it: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_i: Variant = null
	var v_f: Variant = null
	var v_it: Variant = p_it
	v_F = J.getv(game.j_G, "ferman")
	if ((not J.truth(v_F)) or J.truth(J.getv(v_F, "kapandi"))):
		return null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(v_F, "liste"), "length")):
		v_f = J.getv(J.getv(v_F, "liste"), v_i)
		if (J.eq(J.getv(v_f, "tip"), "urun") and J.truth(J.method(v_f, "test", [v_it]))):
			return v_f
		v_i = J.add(v_i, 1.0)
	return null
	return null

# game.js:705
func f_gozcuKur() -> Variant:
	return {"x": (-J.n(24.0)), "dir": 1.0, "state": "yuru", "t": 0.0, "bekle": game.math_utils.f_rnd(J.getv(game.j_GOZ_ARA, 0.0), J.getv(game.j_GOZ_ARA, 1.0)), "bakT": 0.0, "sorgu": null, "sorguT": 0.0, "kafa": 0.0}
	return null

# game.js:713
func f_gozcuBakiyor() -> Variant:
	var v_Z: Variant = null
	v_Z = J.getv(game.j_G, "gozcu")
	return (not (not ((J.truth(v_Z) and J.eq(J.getv(v_Z, "state"), "bak")) and J.gt(J.getv(v_Z, "bakT"), 0.35))))
	return null

# game.js:718
func f_gozcuSinir() -> Variant:
	var v_M: Variant = null
	v_M = game.street_background.f_stM()
	return [(J.getv(v_M, "gx") - 26.0), J.add(J.add(J.getv(v_M, "gx"), J.getv(v_M, "gw")), 26.0)]
	return null

# game.js:720
func f_updateGozcu(p_dt: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_Z: Variant = null
	var v_sn: Variant = null
	var v_M: Variant = null
	var v_f0: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_dt: Variant = p_dt
	v_F = J.getv(game.j_G, "ferman")
	v_Z = J.getv(game.j_G, "gozcu")
	if ((not J.truth(v_F)) or J.truth(J.getv(v_F, "kapandi"))):
		return null
	if (not J.truth(v_Z)):
		J.setv(game.j_G, "gozcu", game.regulation_system.f_gozcuKur())
		return null
	v_sn = game.regulation_system.f_gozcuSinir()
	v_M = game.street_background.f_stM()
	J.setv(v_Z, "t", J.add(J.getv(v_Z, "t"), v_dt))
	if J.eq(J.getv(v_Z, "state"), "sorgu"):
		J.setv(v_Z, "sorguT", J.add(J.getv(v_Z, "sorguT"), v_dt))
		if (((J.gt(J.getv(v_Z, "sorguT"), 1.4) and J.truth(J.getv(v_Z, "sorgu"))) and J.truth(J.getv(J.getv(v_Z, "sorgu"), "kacak"))) and J.truth(J.getv(J.getv(J.getv(v_Z, "sorgu"), "kacak"), "length"))):
			v_f0 = J.method(J.getv(J.getv(v_Z, "sorgu"), "kacak"), "shift", [])
			game.regulation_system.f_fermanIhlal(v_f0, game.math_utils.f_clamp(J.getv(v_Z, "x"), 30.0, (game.j_W - 30.0)), (J.getv(v_M, "curb2") - 40.0), "sokak")
			if (not J.truth(J.getv(J.getv(J.getv(v_Z, "sorgu"), "kacak"), "length"))):
				J.setv(J.getv(v_Z, "sorgu"), "yakalandi", true)
			J.setv(v_Z, "sorguT", 0.2)
		if (J.gt(J.getv(v_Z, "sorguT"), 1.2) and (((not J.truth(J.getv(v_Z, "sorgu"))) or (not J.truth(J.getv(J.getv(v_Z, "sorgu"), "kacak")))) or (not J.truth(J.getv(J.getv(J.getv(v_Z, "sorgu"), "kacak"), "length"))))):
			J.setv(v_Z, "sorgu", null)
			J.setv(v_Z, "state", "yuru")
			J.setv(v_Z, "bekle", game.math_utils.f_rnd(J.getv(game.j_GOZ_ARA, 0.0), J.getv(game.j_GOZ_ARA, 1.0)))
		return null
	if J.eq(J.getv(v_Z, "state"), "bak"):
		J.setv(v_Z, "bakT", J.add(J.getv(v_Z, "bakT"), v_dt))
		J.setv(v_Z, "kafa", game.math_utils.f_approach(J.getv(v_Z, "kafa"), 1.0, (v_dt * 6.0)))
		if J.ge(J.getv(v_Z, "bakT"), J.getv(v_Z, "bakSure")):
			J.setv(v_Z, "state", "yuru")
			J.setv(v_Z, "bakT", 0.0)
			J.setv(v_Z, "bekle", game.math_utils.f_rnd(J.getv(game.j_GOZ_ARA, 0.0), J.getv(game.j_GOZ_ARA, 1.0)))
			J.setv(v_Z, "dir", (1.0 if J.truth(game.f_chance(0.5)) else (-J.n(1.0))))
		return null
	J.setv(v_Z, "kafa", game.math_utils.f_approach(J.getv(v_Z, "kafa"), 0.0, (v_dt * 6.0)))
	J.setv(v_Z, "x", J.add(J.getv(v_Z, "x"), ((J.getv(v_Z, "dir") * 17.0) * v_dt)))
	if J.lt(J.getv(v_Z, "x"), J.getv(v_sn, 0.0)):
		J.setv(v_Z, "x", J.getv(v_sn, 0.0))
		J.setv(v_Z, "dir", 1.0)
	if J.gt(J.getv(v_Z, "x"), J.getv(v_sn, 1.0)):
		J.setv(v_Z, "x", J.getv(v_sn, 1.0))
		J.setv(v_Z, "dir", (-J.n(1.0)))
	J.setv(v_Z, "bekle", (J.getv(v_Z, "bekle") - v_dt))
	if ((J.le(J.getv(v_Z, "bekle"), 0.0) and J.gt(J.getv(v_Z, "x"), J.add(J.getv(v_M, "gx"), 20.0))) and J.lt(J.getv(v_Z, "x"), (J.add(J.getv(v_M, "gx"), J.getv(v_M, "gw")) - 20.0))):
		J.setv(v_Z, "state", "bak")
		J.setv(v_Z, "bakT", 0.0)
		J.setv(v_Z, "bakSure", game.math_utils.f_rnd(J.getv(game.j_GOZ_BAK_SURE, 0.0), J.getv(game.j_GOZ_BAK_SURE, 1.0)))
		(J.method(game.j_SFX, "ui", []) if J.truth(J.getv(game.j_SFX, "ui")) else J.getv(game.j_SFX, "ui"))
	if (not J.truth(J.getv(v_Z, "sorgu"))):
		v_i = 0.0
		while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
			v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
			if (((not J.eq(J.getv(v_c, "state"), "leave") or (not J.truth(J.getv(v_c, "kacak")))) or (not J.truth(J.getv(J.getv(v_c, "kacak"), "length")))) or J.truth(J.getv(v_c, "sorgulandi"))):
				v_i = J.add(v_i, 1.0)
				continue
			if (J.gt(J.getv(v_c, "x"), game.j_GOZ_KAPI) and J.lt(J.getv(v_c, "x"), (game.j_W - game.j_GOZ_KAPI))):
				v_i = J.add(v_i, 1.0)
				continue
			J.setv(v_c, "sorgulandi", true)
			if (not J.truth(game.f_chance(game.j_GOZ_SORGU_SANS))):
				v_i = J.add(v_i, 1.0)
				continue
			J.setv(v_Z, "sorgu", v_c)
			J.setv(v_Z, "state", "sorgu")
			J.setv(v_Z, "sorguT", 0.0)
			J.setv(v_Z, "x", game.math_utils.f_clamp(J.getv(v_c, "x"), J.getv(v_sn, 0.0), J.getv(v_sn, 1.0)))
			J.setv(v_c, "state", "sorgu")
			J.setv(v_c, "sorguT", 0.0)
			J.method(game.j_SFX, "bad", [])
			break
			v_i = J.add(v_i, 1.0)
	return null

# game.js:784
func f_fermanKacak(p_f: Variant = null, p_c: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_f: Variant = p_f
	var v_c: Variant = p_c
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	v_F = J.getv(game.j_G, "ferman")
	if ((not J.truth(v_F)) or J.truth(J.getv(v_F, "kapandi"))):
		return false
	if J.truth(game.regulation_system.f_gozcuBakiyor()):
		game.regulation_system.f_fermanIhlal(v_f, v_x, v_y, "pencere")
		return true
	J.setv(v_c, "kacak", (J.getv(v_c, "kacak") if J.truth(J.getv(v_c, "kacak")) else []))
	J.method(J.getv(v_c, "kacak"), "push", [v_f])
	J.setv(J.getv(game.j_G, "stats"), "kacak", J.add((J.getv(J.getv(game.j_G, "stats"), "kacak") if J.truth(J.getv(J.getv(game.j_G, "stats"), "kacak")) else 0.0), 1.0))
	game.effects.f_burst(v_x, J.add(v_y, 14.0), 5.0, ["#8a8f96", "#b0b4b8"], {"spMax": 26.0, "up": 10.0, "sz": 1.0})
	return false
	return null

# game.js:797
func f_fermanIhlal(p_f: Variant = null, p_x: Variant = null, p_y: Variant = null, p_nerede: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_f: Variant = p_f
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_nerede: Variant = p_nerede
	v_F = J.getv(game.j_G, "ferman")
	if ((not J.truth(v_F)) or J.truth(J.getv(v_F, "kapandi"))):
		return null
	J.setv(v_F, "ceza", J.add(J.getv(v_F, "ceza"), 1.0))
	game.household_system.f_kasaDus(game.j_FERMAN_CEZA_PARA)
	J.setv(J.getv(game.j_G, "stat"), "fine", J.add((J.getv(J.getv(game.j_G, "stat"), "fine") if J.truth(J.getv(J.getv(game.j_G, "stat"), "fine")) else 0.0), game.j_FERMAN_CEZA_PARA))
	J.setv(v_F, "kayit", (J.getv(v_F, "kayit") if J.truth(J.getv(v_F, "kayit")) else []))
	J.method(J.getv(v_F, "kayit"), "push", [{"id": (J.getv(v_f, "id") if J.truth(v_f) else v_f), "metin": (J.getv(v_f, "metin") if J.truth(v_f) else ""), "nerede": (v_nerede if J.truth(v_nerede) else "pencere"), "para": game.j_FERMAN_CEZA_PARA}])
	J.method(game.j_SFX, "bad", [])
	game.effects.f_shake(0.35)
	game.effects.f_flash(0.2, "#e2483a")
	game.effects.f_ftext(J.add(J.add(J.add(game.localization.f_T("FERMAN İHLALİ "), J.getv(v_F, "ceza")), "/"), game.j_FERMAN_CEZA_SINIR), ((float(game.j_W) / float(2.0)) if J.eq(v_x, null) else v_x), (110.0 if J.eq(v_y, null) else v_y), J.getv(game.j_P, "bad"), {"sc": 1.0, "life": 1.8})
	if J.ge(J.getv(v_F, "ceza"), game.j_FERMAN_CEZA_SINIR):
		J.setv(v_F, "kapandi", true)
		J.setv(J.getv(game.j_G, "stats"), "muhur", J.add((J.getv(J.getv(game.j_G, "stats"), "muhur") if J.truth(J.getv(J.getv(game.j_G, "stats"), "muhur")) else 0.0), 1.0))
		game.effects.f_ftext(game.localization.f_T("MÜFETTİŞ GELDİ — DÜKKÂN KAPANDI"), (float(game.j_W) / float(2.0)), 140.0, J.getv(game.j_P, "bad"), {"sc": 1.0, "life": 2.6})
		J.method(game.j_SFX, "shutter", [])
		J.setv(game.j_G, "timeLeft", min(J.getv(game.j_G, "timeLeft"), 1.2))
	return null

# game.js:819
func f_fermanGonder(p_c: Variant = null) -> Variant:
	var v_c: Variant = p_c
	J.setv(v_c, "state", "leave")
	J.setv(v_c, "leaveT", 0.0)
	J.setv(v_c, "mood", "angry")
	J.setv(v_c, "line", game.math_utils.f_pick(game.j_LINES_WRONG))
	J.setv(v_c, "lineT", 1.4)
	J.method(game.j_SFX, "uiBack", [])
	game.effects.f_ftext(game.localization.f_T("GÖNDERİLDİ"), J.getv(v_c, "x"), (J.getv(v_c, "y") - 58.0), J.getv(game.j_P, "ui1"), {"life": 1.2})
	return null

# game.js:828
func f_fermanXKutu(p_c: Variant = null) -> Variant:
	var v_c: Variant = p_c
	return [floor(J.add(J.getv(v_c, "x"), 15.0) + 0.5), floor((J.getv(v_c, "y") - 44.0) + 0.5), 14.0, 14.0]
	return null

# game.js:3823
func f_fermanKagitKutu() -> Variant:
	return [(game.j_W - 34.0), 34.0, 26.0, 30.0]
	return null

# game.js:3826
func f_denetimLambaKutu() -> Variant:
	return [426.0, 34.0, 16.0, 18.0]
	return null

# game.js:3832
func f_denetimSeviye() -> Variant:
	var v_Z: Variant = null
	v_Z = J.getv(game.j_G, "gozcu")
	if ((not J.truth(v_Z)) or J.eq(J.getv(v_Z, "state"), "yuru")):
		return 0.0
	if J.eq(J.getv(v_Z, "state"), "sorgu"):
		return 1.0
	return game.math_utils.f_clamp((float(J.getv(v_Z, "bakT")) / float(0.35)), 0.0, 1.0)
	return null

# game.js:3985
func f_fermanTik(p_mx: Variant = null, p_my: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_kk: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_k: Variant = null
	var v_mx: Variant = p_mx
	var v_my: Variant = p_my
	v_F = J.getv(game.j_G, "ferman")
	if (not J.truth(v_F)):
		return false
	if J.gt(J.getv(v_F, "kagit"), 0.01):
		if (not J.truth(game.math_utils.f_inRect(v_mx, v_my, ((float(game.j_W) / float(2.0)) - 130.0), 0.0, 260.0, game.j_H))):
			J.setv(v_F, "kagitT", 0.0)
			J.method(game.j_SFX, "uiBack", [])
		return true
	v_kk = game.regulation_system.f_fermanKagitKutu()
	if J.truth(game.math_utils.f_inRect(v_mx, v_my, J.getv(v_kk, 0.0), J.getv(v_kk, 1.0), J.getv(v_kk, 2.0), J.getv(v_kk, 3.0))):
		J.setv(v_F, "kagitT", 1.0)
		J.method(game.j_SFX, "ui", [])
		return true
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		if not J.eq(J.getv(v_c, "state"), "wait"):
			v_i = J.add(v_i, 1.0)
			continue
		v_k = game.regulation_system.f_fermanXKutu(v_c)
		if J.truth(game.math_utils.f_inRect(v_mx, v_my, (J.getv(v_k, 0.0) - 3.0), (J.getv(v_k, 1.0) - 3.0), J.add(J.getv(v_k, 2.0), 6.0), J.add(J.getv(v_k, 3.0), 6.0))):
			game.regulation_system.f_fermanGonder(v_c)
			return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# game.js:4007
func f_updateFerman(p_dt: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_dt: Variant = p_dt
	v_F = J.getv(game.j_G, "ferman")
	if (not J.truth(v_F)):
		return null
	J.setv(v_F, "kagit", game.math_utils.f_approach(J.getv(v_F, "kagit"), J.getv(v_F, "kagitT"), (v_dt * 5.5)))
	return null

