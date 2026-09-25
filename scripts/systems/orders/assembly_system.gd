# Assembly system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func ingredient_problem(id: String, wrap: Variant) -> String:
	if wrap == null: return "Önce lavaş ya da pide al!" if J.method(game.j_TUN,"iskOn",[game.j_G]) else "Önce lavaş al!"
	if wrap.kind == "pide": return "Önce pideyi doğra"
	if wrap.state != "open": return "Sarılmış ürüne malzeme eklenmez"
	if wrap.kind == "plate" and id in ["pickle","fries"]: return "İskendere sadece yoğurt gider"
	var label: String = {"meat":"Et","pickle":"Turşu","yogurt":"Yoğurt","fries":"Patates"}[id]
	var field: String = "meat" if id == "meat" else id+"N"
	var need: float = {"meat":game.j_MEAT_NEED,"pickle":game.j_PICKLE_NEED,"yogurt":game.j_YOGURT_NEED,"fries":game.j_FRIES_NEED}[id]
	if wrap.kind == "plate": need = J.method(game.j_TUN,"iskMeat",[game.j_G]) if id == "meat" else game.j_PLATE_YOGURT
	if wrap.get(field,0) >= need: return label+" yeterli"
	if id == "meat" and game.j_G.meat <= 0: return "Et yok — dönerden kes!"
	if id == "fries" and game.j_G.friesTray <= 0: return "Patates yok — doğra ve kızart!"
	if id in ["pickle","yogurt"] and game.j_G.stock[id] <= 0: return label+" bitti — kutudan doldur!"
	return ""

# BIRLESIK (8. tur): tiklanan malzeme secili urune kondu; masa seviyesi kadar
# siradaki urunlere de (akilli hedefle) sessizce konur. Son seviyede turşu /
# yogurt / patates tiklamasi uc yan malzemeyi birlikte koyar.
const YAN := ["pickle", "yogurt", "fries"]
const KAYNAK := {"meat": ["meat", 8.0, "#c98436"], "pickle": ["pickle", 10.0, "g1"], "yogurt": ["yogurt", 10.0, "s0"], "fries": ["friesT", 10.0, "p1"]}

func masa_yay(k: String) -> void:
	var set_var: bool = k in YAN and J.truth(J.method(game.j_TUN, "tongsSet", [game.j_G]))
	var turler: Array = YAN if set_var else [k]
	var i := int(J.n(game.j_G.act))
	for tur in turler: sessiz_ekle(i, tur)
	for n in int(J.n(J.method(game.j_TUN, "tongsTargets", [game.j_G]))) - 1:
		i = game.wrap_system.f_malzemeHedefi(k)
		if i < 0 or not sessiz_ekle(i, k): break
		if set_var:
			for tur in YAN: sessiz_ekle(i, tur)

func sessiz_ekle(i: int, k: String) -> bool:
	var b: Variant = game.j_G.boards[i]
	if not game.wrap_system.f_malzemeIhtiyac(b, k): return false
	var alan: String = game.wrap_system.MALZEME_ALANI[k]
	var gerek: float = {"meat": game.j_MEAT_NEED, "pickle": game.j_PICKLE_NEED, "yogurt": game.j_YOGURT_NEED, "fries": game.j_FRIES_NEED}[k]
	if b.kind == "plate": gerek = J.n(J.method(game.j_TUN, "iskMeat", [game.j_G])) if k == "meat" else J.n(game.j_PLATE_YOGURT)
	var var_olan: float = J.n(game.j_G.meat) if k == "meat" else (J.n(game.j_G.friesTray) if k == "fries" else J.n(game.j_G.stock[k]))
	var n := minf(gerek - J.n(b.get(alan, 0.0)), var_olan)
	if n <= 0.0: return false
	if k == "meat": game.j_G.meat -= n
	elif k == "fries": game.j_G.friesTray -= n
	else: game.j_G.stock[k] -= n
	b[alan] = J.n(b.get(alan, 0.0)) + n
	b.pop = 1.0
	game.j_G.fxTray[k] = 1.0
	var s: Array = KAYNAK[k]
	var st: Dictionary = game.j_ST[s[0]]
	var col: String = s[2] if str(s[2]).begins_with("#") else game.j_P[s[2]]
	f_flyTo(J.n(st.x) + (J.n(st.w) / 2.0 if k == "meat" else 19.0), J.n(st.y) + s[1], game.wrap_system.f_boardCX(i), game.wrap_system.f_boardCY(), col, 5.0)
	if b.kind == "plate":
		if k == "yogurt": b.yogurt = J.n(b.yogurtN) >= J.n(game.j_PLATE_YOGURT)
		game.recipe_system.f_finishPlate(i)
	return true

# game.js:1015
func f_addMeat() -> Variant:
	var v_w: Variant = null
	var v_need: Variant = null
	var v_n: Variant = null
	game.wrap_system.f_malzemeYonlendir("meat")
	v_w = game.wrap_system.f_selWrap(J.ref(game.wrap_system.f_yerEt, 1))
	if (not J.truth(v_w)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(("Önce lavaş ya da pide al!" if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])) else "Önce lavaş al!"))
		return null
	if not J.eq(J.getv(v_w, "state"), "open"):
		J.method(game.j_SFX, "bad", [])
		return null
	if J.eq(J.getv(v_w, "kind"), "pide"):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce pideyi doğra")
		return null
	v_need = (J.method(game.j_TUN, "iskMeat", [game.j_G]) if J.eq(J.getv(v_w, "kind"), "plate") else game.j_MEAT_NEED)
	if J.ge(J.getv(v_w, "meat"), v_need):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Et yeterli")
		return null
	if J.le(J.getv(game.j_G, "meat"), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Et yok — dönerden kes!")
		return null
	v_n = min(min(J.method(game.j_TUN, "meatPerClick", [game.j_G]), (v_need - J.getv(v_w, "meat"))), J.getv(game.j_G, "meat"))
	J.setv(game.j_G, "meat", (J.getv(game.j_G, "meat") - v_n))
	J.setv(v_w, "meat", J.add(J.getv(v_w, "meat"), v_n))
	J.setv(v_w, "pop", 1.0)
	J.setv(J.getv(game.j_G, "fxTray"), "meat", 1.0)
	game.assembly_system.f_flyTo(J.add(J.getv(J.getv(game.j_ST, "meat"), "x"), (float(J.getv(J.getv(game.j_ST, "meat"), "w")) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "meat"), "y"), 8.0), game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY(), "#c98436", 5.0)
	masa_yay("meat")
	J.method(game.j_SFX, "pop", [])
	game.equipment_system.f_checkAuto()
	return null

# game.js:1029
func f_addIng(p_k: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_pn: Variant = null
	var v_fn: Variant = null
	var v_need: Variant = null
	var v_key: Variant = null
	var v_an: Variant = null
	var v_src: Variant = null
	var v_k: Variant = p_k
	game.wrap_system.f_malzemeYonlendir(str(v_k))
	v_w = game.wrap_system.f_selWrap(game.wrap_system.f_yerIng(v_k))
	if (not J.truth(v_w)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(("Önce lavaş ya da pide al!" if J.truth(J.method(game.j_TUN, "iskOn", [game.j_G])) else "Önce lavaş al!"))
		return null
	if not J.eq(J.getv(v_w, "state"), "open"):
		J.method(game.j_SFX, "bad", [])
		return null
	if J.eq(J.getv(v_w, "kind"), "pide"):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce pideyi doğra")
		return null
	if J.eq(J.getv(v_w, "kind"), "plate"):
		if not J.eq(v_k, "yogurt"):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("İskendere sadece yoğurt gider")
			return null
		if J.ge((J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), game.j_PLATE_YOGURT):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Yoğurt yeterli")
			return null
		if J.le(J.getv(J.getv(game.j_G, "stock"), "yogurt"), 0.0):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Yoğurt bitti — kutudan doldur!")
			return null
		v_pn = min(min(J.method(game.j_TUN, "meatPerClick", [game.j_G]), (game.j_PLATE_YOGURT - (J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0))), J.getv(J.getv(game.j_G, "stock"), "yogurt"))
		J.setv(J.getv(game.j_G, "stock"), "yogurt", (J.getv(J.getv(game.j_G, "stock"), "yogurt") - v_pn))
		J.setv(v_w, "yogurtN", J.add((J.getv(v_w, "yogurtN") if J.truth(J.getv(v_w, "yogurtN")) else 0.0), v_pn))
		J.setv(v_w, "yogurt", J.ge(J.getv(v_w, "yogurtN"), game.j_PLATE_YOGURT))
		J.setv(J.getv(game.j_G, "fxTray"), "yogurt", 1.0)
		J.method(game.j_SFX, "scoop", [])
		game.assembly_system.f_flyTo(J.add(J.getv(J.getv(game.j_ST, "yogurt"), "x"), 19.0), J.add(J.getv(J.getv(game.j_ST, "yogurt"), "y"), 10.0), game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY(), J.getv(game.j_P, "s0"), 6.0)
		J.setv(v_w, "pop", 1.0)
		J.method(game.j_SFX, "pop", [])
		game.recipe_system.f_finishPlate(J.getv(game.j_G, "act"))
		masa_yay("yogurt")
		return null
	if J.eq(v_k, "fries"):
		if J.ge(J.getv(v_w, "friesN"), game.j_FRIES_NEED):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Patates yeterli")
			return null
		if J.le(J.getv(game.j_G, "friesTray"), 0.0):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Patates yok — doğra ve kızart!")
			return null
		v_fn = min(min(J.method(game.j_TUN, "meatPerClick", [game.j_G]), (game.j_FRIES_NEED - J.getv(v_w, "friesN"))), J.getv(game.j_G, "friesTray"))
		J.setv(game.j_G, "friesTray", (J.getv(game.j_G, "friesTray") - v_fn))
		J.setv(v_w, "friesN", J.add(J.getv(v_w, "friesN"), v_fn))
		J.setv(J.getv(game.j_G, "fxTray"), "fries", 1.0)
		game.assembly_system.f_flyTo(J.add(J.getv(J.getv(game.j_ST, "friesT"), "x"), 19.0), J.add(J.getv(J.getv(game.j_ST, "friesT"), "y"), 10.0), game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY(), J.getv(game.j_P, "p1"), 6.0)
		J.setv(v_w, "pop", 1.0)
		J.method(game.j_SFX, "pop", [])
		masa_yay("fries")
		game.equipment_system.f_checkAuto()
		return null
	else:
		v_need = (game.j_PICKLE_NEED if J.eq(v_k, "pickle") else game.j_YOGURT_NEED)
		v_key = J.add(v_k, "N")
		if J.ge((J.getv(v_w, v_key) if J.truth(J.getv(v_w, v_key)) else 0.0), v_need):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say(J.add(game.localization.f_T(("Turşu" if J.eq(v_k, "pickle") else "Yoğurt")), game.localization.f_T(" yeterli")))
			return null
		if J.le(J.getv(J.getv(game.j_G, "stock"), v_k), 0.0):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say(J.add(game.localization.f_T(("Turşu" if J.eq(v_k, "pickle") else "Yoğurt")), game.localization.f_T(" bitti — kutudan doldur!")))
			return null
		v_an = min(min(J.method(game.j_TUN, "meatPerClick", [game.j_G]), (v_need - (J.getv(v_w, v_key) if J.truth(J.getv(v_w, v_key)) else 0.0))), J.getv(J.getv(game.j_G, "stock"), v_k))
		J.setv(J.getv(game.j_G, "stock"), v_k, (J.getv(J.getv(game.j_G, "stock"), v_k) - v_an))
		J.setv(v_w, v_key, J.add((J.getv(v_w, v_key) if J.truth(J.getv(v_w, v_key)) else 0.0), v_an))
		J.setv(J.getv(game.j_G, "fxTray"), v_k, 1.0)
		J.method(game.j_SFX, "scoop", [])
		v_src = (J.getv(game.j_ST, "pickle") if J.eq(v_k, "pickle") else J.getv(game.j_ST, "yogurt"))
		game.assembly_system.f_flyTo(J.add(J.getv(v_src, "x"), 19.0), J.add(J.getv(v_src, "y"), 10.0), game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY(), (J.getv(game.j_P, "g1") if J.eq(v_k, "pickle") else J.getv(game.j_P, "s0")), 6.0)
	J.setv(v_w, "pop", 1.0)
	J.method(game.j_SFX, "pop", [])
	masa_yay(str(v_k))
	game.equipment_system.f_checkAuto()
	return null

# game.js:1072
func f_flyTo(p_x0: Variant = null, p_y0: Variant = null, p_x1: Variant = null, p_y1: Variant = null, p_col: Variant = null, p_n: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_x0: Variant = p_x0
	var v_y0: Variant = p_y0
	var v_x1: Variant = p_x1
	var v_y1: Variant = p_y1
	var v_col: Variant = p_col
	var v_n: Variant = p_n
	v_i = 0.0
	while J.lt(v_i, v_n):
		game.effects.f_part({"x": J.add(v_x0, game.math_utils.f_rnd((-J.n(3.0)), 3.0)), "y": v_y0, "vx": ((v_x1 - v_x0) * game.math_utils.f_rnd(1.5, 2.1)), "vy": (((v_y1 - v_y0) * 1.7) - game.math_utils.f_rnd(30.0, 60.0)), "life": 0.4, "col": v_col, "g": 200.0, "sz": 2.0})
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1082
func f_garnishClick(p_mx: Variant = null) -> Variant:
	var v_isTom: Variant = null
	var v_k: Variant = null
	var v_w: Variant = null
	var v_wi: Variant = null
	var v_act: Variant = null
	var v_bi: Variant = null
	var v_b0: Variant = null
	var v_need: Variant = null
	var v_n: Variant = null
	var v_sx: Variant = null
	var v_mx: Variant = p_mx
	if (not J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G]))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Garnitür tepsisi kapalı — dükkândan al")
		return null
	v_isTom = J.lt(v_mx, J.add(J.getv(J.getv(game.j_ST, "garnish"), "x"), (J.getv(J.getv(game.j_ST, "garnish"), "w") * 0.52)))
	v_k = ("tomato" if J.truth(v_isTom) else "pepper")
	game.wrap_system.f_malzemeYonlendir(v_k)
	v_w = null
	v_wi = (-J.n(1.0))
	v_act = J.getv(J.getv(game.j_G, "boards"), J.getv(game.j_G, "act"))
	if (J.truth(v_act) and J.eq(J.getv(v_act, "kind"), "plate")):
		v_w = v_act
		v_wi = J.getv(game.j_G, "act")
	else:
		v_bi = 0.0
		while J.lt(v_bi, J.method(game.j_TUN, "boards", [game.j_G])):
			v_b0 = J.getv(J.getv(game.j_G, "boards"), v_bi)
			if ((J.truth(v_b0) and J.eq(J.getv(v_b0, "kind"), "plate")) and ((not J.truth(v_w)) or J.gt(J.getv(v_b0, "born"), J.getv(v_w, "born")))):
				v_w = v_b0
				v_wi = v_bi
			v_bi = J.add(v_bi, 1.0)
	if (not J.truth(v_w)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Garnitür iskender tabağına gider")
		return null
	J.setv(game.j_G, "act", v_wi)
	v_need = (game.j_TOMATO_NEED if J.truth(v_isTom) else game.j_PEPPER_NEED)
	if J.ge((J.getv(v_w, v_k) if J.truth(J.getv(v_w, v_k)) else 0.0), v_need):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(("Domates yeterli" if J.truth(v_isTom) else "Biber yeterli"))
		return null
	if J.le(J.getv(J.getv(game.j_G, "stock"), v_k), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(J.add(game.localization.f_T(("Domates" if J.truth(v_isTom) else "Biber")), game.localization.f_T(" bitti — kutudan doldur!")))
		return null
	v_n = min(min(J.method(game.j_TUN, "meatPerClick", [game.j_G]), (v_need - (J.getv(v_w, v_k) if J.truth(J.getv(v_w, v_k)) else 0.0))), J.getv(J.getv(game.j_G, "stock"), v_k))
	J.setv(J.getv(game.j_G, "stock"), v_k, (J.getv(J.getv(game.j_G, "stock"), v_k) - v_n))
	J.setv(v_w, v_k, J.add((J.getv(v_w, v_k) if J.truth(J.getv(v_w, v_k)) else 0.0), v_n))
	J.setv(J.getv(game.j_G, "fxTray"), v_k, 1.0)
	J.setv(v_w, "pop", 1.0)
	J.method(game.j_SFX, "scoop", [])
	J.method(game.j_SFX, "pop", [])
	v_sx = J.add(J.getv(J.getv(game.j_ST, "garnish"), "x"), (10.0 if J.truth(v_isTom) else (J.getv(J.getv(game.j_ST, "garnish"), "w") - 10.0)))
	game.assembly_system.f_flyTo(v_sx, J.add(J.getv(J.getv(game.j_ST, "garnish"), "y"), 12.0), game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY(), ("#e2483a" if J.truth(v_isTom) else "#5d9a24"), 6.0)
	game.session_system.f_say(("Domates kondu" if J.truth(v_isTom) else "Biber kondu"))
	return null

# game.js:1111
func f_pideChop(p_idx: Variant = null, p_otomatik: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_i: Variant = null
	var v_idx: Variant = p_idx
	var v_otomatik: Variant = p_otomatik
	v_p = J.getv(J.getv(game.j_G, "boards"), v_idx)
	if ((not J.truth(v_p)) or not J.eq(J.getv(v_p, "kind"), "pide")):
		return false
	J.setv(v_p, "n", J.add((J.getv(v_p, "n") if J.truth(J.getv(v_p, "n")) else 0.0), 1.0))
	J.setv(v_p, "chop", 1.0)
	J.method(game.j_SFX, "potato", [])
	game.effects.f_shake(1.2)
	v_bx = game.wrap_system.f_boardCX(v_idx)
	v_by = game.wrap_system.f_boardCY()
	v_i = 0.0
	while J.lt(v_i, 7.0):
		game.effects.f_part({"x": J.add(v_bx, game.math_utils.f_rnd((-J.n(18.0)), 18.0)), "y": (v_by - 2.0), "vx": game.math_utils.f_rnd((-J.n(46.0)), 46.0), "vy": game.math_utils.f_rnd((-J.n(46.0)), (-J.n(14.0))), "life": game.math_utils.f_rnd(0.35, 0.65), "col": game.math_utils.f_pick(["#eec78c", "#d9a765", "#8a5f31", "#f4ead2"]), "g": 280.0, "sz": 1.0, "floor": J.add(v_by, 6.0), "bounce": 0.3})
		v_i = J.add(v_i, 1.0)
	if J.ge(J.getv(v_p, "n"), game.j_PIDE_NEED):
		J.setv(J.getv(game.j_G, "boards"), v_idx, {"kind": "plate", "pide": true, "meat": 0.0, "butter": false, "yogurt": false, "yogurtN": 0.0, "tomato": 0.0, "pepper": 0.0, "state": "open", "pop": 1.0, "born": J.getv(game.j_G, "t")})
		if (not J.truth(v_otomatik)):
			J.setv(game.j_G, "act", v_idx)
		J.method(game.j_SFX, "plate", [])
		game.effects.f_burst(v_bx, v_by, 14.0, ["#d9a765", "#eec78c", "#ffffff", "#e9eef2"], {"spMax": 62.0, "up": 24.0, "sz": 2.0})
		game.effects.f_ftext("PİDE HAZIR", v_bx, (v_by - 26.0), J.getv(game.j_P, "au0"), {"life": 1.2})
		if (not J.truth(v_otomatik)):
			game.session_system.f_say("Tabağa geçti — şimdi döner koy")
	return true
	return null

# game.js:1145
func f_sauceIdxAt(p_mx: Variant = null) -> Variant:
	var v_mx: Variant = p_mx
	return game.math_utils.f_clamp(floor((float(((v_mx - J.getv(J.getv(game.j_ST, "sauce"), "x")) - 2.0)) / float(15.0))), 0.0, 2.0)
	return null

# game.js:1146
func f_sauceOpen(p_i: Variant = null) -> Variant:
	var v_i: Variant = p_i
	return (J.method(game.j_TUN, "iskOn", [game.j_G]) if J.eq(v_i, 2.0) else J.method(game.j_TUN, "sauceOn", [game.j_G]))
	return null

# game.js:1147
func f_squirt(p_id: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_cols: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_i: Variant = null
	var v_id: Variant = p_id
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	v_cols = (["#e2382a", "#ff7a62", "#a81f18"] if J.eq(v_id, "hot") else (["#f6f2e6", "#ffffff", "#d8d2c2"] if J.eq(v_id, "garlic") else ["#f0b53c", "#ffd77a", "#e2621c"]))
	v_sx = J.add(game.f_sauceSlotX(J.getv(game.j_SAUCE_IDX, v_id)), 3.0)
	v_sy = J.add(J.getv(J.getv(game.j_ST, "sauce"), "y"), 22.0)
	v_i = 0.0
	while J.lt(v_i, 11.0):
		game.effects.f_part({"x": J.add(v_sx, game.math_utils.f_rnd((-J.n(1.0)), 1.0)), "y": v_sy, "vx": ((v_x - v_sx) * game.math_utils.f_rnd(1.4, 2.0)), "vy": (((v_y - v_sy) * 1.6) - game.math_utils.f_rnd(24.0, 56.0)), "life": 0.45, "col": game.math_utils.f_pick(v_cols), "g": 220.0, "sz": 1.0})
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1158
func f_sauceClick(p_mx: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_id: Variant = null
	var v_w: Variant = null
	var v_sb: Variant = null
	var v_sw: Variant = null
	var v_sarili: Variant = null
	var v_mx: Variant = p_mx
	v_i = game.f_sauceIdxAt(v_mx)
	v_id = J.getv(J.getv(game.j_SAUCE_DEF, v_i), "id")
	if (not J.truth(game.assembly_system.f_sauceOpen(v_i))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(("Tereyağı sosu İskender ile gelir" if J.eq(v_i, 2.0) else "Sos standı kapalı — dükkândan aç"))
		return null
	game.wrap_system.f_malzemeYonlendir(str(v_id))
	v_w = game.wrap_system.f_selWrap()
	if ((not J.truth(v_w)) and J.truth(J.method(game.j_TUN, "sauceLate", [game.j_G]))):
		v_sb = 0.0
		while J.lt(v_sb, J.method(game.j_TUN, "boards", [game.j_G])):
			v_sw = J.getv(J.getv(game.j_G, "boards"), v_sb)
			if (((J.truth(v_sw) and J.eq(J.getv(v_sw, "kind"), "wrap")) and J.eq(J.getv(v_sw, "state"), "rolled")) and (not J.truth(J.getv(v_sw, "sauce")))):
				v_w = v_sw
				J.setv(game.j_G, "act", v_sb)
				break
			v_sb = J.add(v_sb, 1.0)
	if (not J.truth(v_w)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce lavaş ya da pide al!")
		return null
	v_sarili = (J.eq(J.getv(v_w, "kind"), "wrap") if (J.eq(J.getv(v_w, "state"), "rolled") and J.truth(J.method(game.j_TUN, "sauceLate", [game.j_G]))) else (J.method(game.j_TUN, "sauceLate", [game.j_G]) if J.eq(J.getv(v_w, "state"), "rolled") else J.eq(J.getv(v_w, "state"), "rolled")))
	if (not J.eq(J.getv(v_w, "state"), "open") and (not J.truth(v_sarili))):
		J.method(game.j_SFX, "bad", [])
		return null
	if J.eq(J.getv(v_w, "kind"), "pide"):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce pideyi doğra")
		return null
	if J.eq(v_id, "butter"):
		if not J.eq(J.getv(v_w, "kind"), "plate"):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Tereyağı sosu iskendere gider")
			return null
		if J.truth(J.getv(v_w, "butter")):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Sos zaten döküldü")
			return null
		J.setv(v_w, "butter", true)
		game.session_system.f_say("Tereyağı sosu döküldü")
	else:
		if J.eq(J.getv(v_w, "kind"), "plate"):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Tabağa dürüm sosu sürülmez")
			return null
		if J.eq(J.getv(v_w, "sauce"), v_id):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Sos zaten sürüldü")
			return null
		J.setv(v_w, "sauce", v_id)
		game.session_system.f_say(("Acı sos sürüldü" if J.eq(v_id, "hot") else "Sarımsak sosu sürüldü"))
	J.setv(v_w, "pop", 1.0)
	J.setv(J.getv(game.j_G, "sauceFx"), v_id, 1.0)
	J.method(game.j_SFX, "squirt", [])
	game.assembly_system.f_squirt(v_id, game.wrap_system.f_boardCX(J.getv(game.j_G, "act")), game.wrap_system.f_boardCY())
	if J.eq(J.getv(v_w, "kind"), "plate"):
		game.recipe_system.f_finishPlate(J.getv(game.j_G, "act"))
	game.equipment_system.f_checkAuto()
	return null
