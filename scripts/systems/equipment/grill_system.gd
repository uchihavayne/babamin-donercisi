# Grill system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1206
func f_grillSlotX(p_i: Variant = null) -> Variant:
	var v_cap: Variant = null
	var v_sut: Variant = null
	var v_k: Variant = null
	var v_gen: Variant = null
	var v_i: Variant = p_i
	# BIRLESIK: yeni tezgahin izgarasi dar (48 px); iki sutunda durumler ust
	# uste binip tek uzun durum gibi gorunuyordu -> tek sutun, alt alta.
	if game.get("counter_design_enabled"):
		var gx: float = J.n(J.getv(J.getv(game.j_ST, "grill"), "x"))
		if J.n(J.method(game.j_TUN, "grillCap", [game.j_G])) <= 2.0:
			return floor(gx + J.n(J.getv(J.getv(game.j_ST, "grill"), "w")) / 2.0 + 0.5)
		return floor(gx + 12.5 + 23.0 * (int(J.n(v_i)) % 2) + 0.5)
	v_cap = J.method(game.j_TUN, "grillCap", [game.j_G])
	v_sut = (v_cap if J.le(v_cap, 2.0) else 2.0)
	v_k = fmod(J.n(v_i), J.n(v_sut))
	v_gen = (J.getv(J.getv(game.j_ST, "grill"), "w") - 8.0)
	return floor(J.add(J.add(J.getv(J.getv(game.j_ST, "grill"), "x"), 4.0), ((float(v_gen) / float(v_sut)) * J.add(v_k, 0.5))) + 0.5)
	return null

# game.js:1213
func f_grillSlotY(p_i: Variant = null) -> Variant:
	var v_cap: Variant = null
	var v_satir: Variant = null
	var v_r: Variant = null
	var v_i: Variant = p_i
	if game.get("counter_design_enabled"):
		# tek goz: ortada; iki goz: iki satir; uc-dort goz: 2x2
		var n: int = clampi(int(J.n(J.method(game.j_TUN, "grillCap", [game.j_G]))), 1, 4)
		var gy: float = J.n(J.getv(J.getv(game.j_ST, "grill"), "y"))
		if n == 1: return floor(gy + 24.0 + 0.5)
		if n == 2: return floor(gy + 18.0 + 15.0 * J.n(v_i) + 0.5)
		return floor(gy + 19.0 + 15.0 * floor(J.n(v_i) / 2.0) + 0.5)
	v_cap = J.method(game.j_TUN, "grillCap", [game.j_G])
	v_satir = (1.0 if J.le(v_cap, 2.0) else 2.0)
	v_r = (0.0 if J.eq(v_satir, 1.0) else floor((float(v_i) / float(2.0))))
	return floor(J.add(J.getv(J.getv(game.j_ST, "grill"), "y"), (23.0 if J.eq(v_satir, 1.0) else J.add(15.0, (v_r * 16.0)))) + 0.5)
	return null

# game.js:1220
func f_grillSlotSc() -> Variant:
	var v_cap: Variant = null
	v_cap = J.method(game.j_TUN, "grillCap", [game.j_G])
	if game.get("counter_design_enabled") and J.gt(v_cap, 2.0):
		return 0.5
	return (0.8 if J.eq(v_cap, 1.0) else (0.62 if J.eq(v_cap, 2.0) else 0.58))
	return null

# game.js:1225
func f_grillDolu() -> Variant:
	return J.ge(J.getv(J.getv(J.getv(game.j_G, "grill"), "slots"), "length"), J.method(game.j_TUN, "grillCap", [game.j_G]))
	return null

# game.js:1227
func f_grillHazirIdx() -> Variant:
	var v_sl: Variant = null
	var v_i: Variant = null
	v_sl = J.getv(J.getv(game.j_G, "grill"), "slots")
	v_i = 0.0
	while J.lt(v_i, J.getv(v_sl, "length")):
		if J.truth(J.getv(J.getv(v_sl, v_i), "done")):
			return v_i
		v_i = J.add(v_i, 1.0)
	return (-J.n(1.0))
	return null

# game.js:1232
func f_grillClick() -> Variant:
	var v_hi: Variant = null
	var v_wi: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	if (not J.truth(J.method(game.j_TUN, "grillOn", [game.j_G]))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Izgara kapalı — dükkândan aç")
		return null
	v_hi = game.grill_system.f_grillHazirIdx()
	if (J.ge(v_hi, 0.0) and J.ge(game.grill_system.f_grillBosYer(), 0.0)):
		game.grill_system.f_grillTakeOut(v_hi)
		return null
	if (not J.truth(game.grill_system.f_grillDolu())):
		v_wi = (-J.n(1.0))
		v_i = 0.0
		while J.lt(v_i, J.method(game.j_TUN, "boards", [game.j_G])):
			v_b = J.getv(J.getv(game.j_G, "boards"), v_i)
			if (((J.truth(v_b) and J.eq(J.getv(v_b, "kind"), "wrap")) and J.eq(J.getv(v_b, "state"), "rolled")) and (not J.truth(J.getv(v_b, "grilled")))):
				v_wi = v_i
				break
			v_i = J.add(v_i, 1.0)
		if J.ge(v_wi, 0.0):
			game.grill_system.f_grillPut(v_wi)
			# BIRLESIK: tek tikta bos goz kadar sarili durumun HEPSI izgaraya
			# girer (kullanici: "son seviyede 2-3 durumu birden almasi lazim").
			var v_j: int = int(v_wi) + 1
			while v_j < int(J.n(J.method(game.j_TUN, "boards", [game.j_G]))) and not J.truth(game.grill_system.f_grillDolu()):
				var v_b2: Variant = J.getv(J.getv(game.j_G, "boards"), v_j)
				if J.truth(v_b2) and J.eq(J.getv(v_b2, "kind"), "wrap") and J.eq(J.getv(v_b2, "state"), "rolled") and not J.truth(J.getv(v_b2, "grilled")):
					game.grill_system.f_grillPut(v_j)
				v_j += 1
			return null
		if J.ge(v_hi, 0.0):
			game.grill_system.f_grillTakeOut(v_hi)
			return null
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce dürümü sar — ızgaraya sarılmış dürüm girer")
		return null
	if J.ge(v_hi, 0.0):
		game.grill_system.f_grillTakeOut(v_hi)
		return null
	game.session_system.f_say("Daha pişiyor…")
	return null

# game.js:1255
func f_grillBosYer() -> Variant:
	var v_i: Variant = null
	v_i = 0.0
	while J.lt(v_i, J.method(game.j_TUN, "boards", [game.j_G])):
		if (not J.truth(J.getv(J.getv(game.j_G, "boards"), v_i))):
			return v_i
		v_i = J.add(v_i, 1.0)
	return (-J.n(1.0))
	return null

# game.js:1262
func f_grillTikali() -> Variant:
	return (J.lt(game.grill_system.f_grillBosYer(), 0.0) if J.ge(game.grill_system.f_grillHazirIdx(), 0.0) else J.ge(game.grill_system.f_grillHazirIdx(), 0.0))
	return null

# game.js:1265
func f_grillPut(p_idx: Variant = null) -> Variant:
	var v_w: Variant = null
	var v_idx: Variant = p_idx
	v_w = J.getv(J.getv(game.j_G, "boards"), v_idx)
	if J.truth(game.event_system.f_kesintiVarMi()):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Elektrik yok — ızgara soğuk")
		return null
	if ((not J.truth(v_w)) or J.truth(game.grill_system.f_grillDolu())):
		return null
	J.setv(J.getv(game.j_G, "boards"), v_idx, null)
	J.method(J.getv(J.getv(game.j_G, "grill"), "slots"), "push", [{"w": v_w, "t": 0.0, "dur": J.method(game.j_TUN, "grillTime", [game.j_G]), "done": false, "yan": 0.0}])
	J.method(game.j_SFX, "sizzle", [])
	return null

# game.js:1273
func f_grillTakeOut(p_si: Variant = null) -> Variant:
	var v_sl: Variant = null
	var v_w: Variant = null
	var v_idx: Variant = null
	var v_ti: Variant = null
	var v_tb: Variant = null
	var v_tw: Variant = null
	var v_bekleyen: Variant = null
	var v_gx0: Variant = null
	var v_gy0: Variant = null
	var v_s2: Variant = null
	var v_si: Variant = p_si
	v_sl = J.getv(J.getv(game.j_G, "grill"), "slots")
	if J.eq(v_si, null):
		v_si = game.grill_system.f_grillHazirIdx()
	if (J.lt(v_si, 0.0) or J.ge(v_si, J.getv(v_sl, "length"))):
		return null
	v_w = J.getv(J.getv(v_sl, v_si), "w")
	v_idx = game.grill_system.f_grillBosYer()
	if J.lt(v_idx, 0.0):
		v_ti = (-J.n(1.0))
		v_tb = 0.0
		while J.lt(v_tb, J.method(game.j_TUN, "boards", [game.j_G])):
			v_tw = J.getv(J.getv(game.j_G, "boards"), v_tb)
			if (((J.truth(v_tw) and J.eq(J.getv(v_tw, "kind"), "wrap")) and J.eq(J.getv(v_tw, "state"), "rolled")) and (not J.truth(J.getv(v_tw, "grilled")))):
				v_ti = v_tb
				break
			v_tb = J.add(v_tb, 1.0)
		if J.ge(v_ti, 0.0):
			v_bekleyen = J.getv(J.getv(game.j_G, "boards"), v_ti)
			J.setv(v_w, "grilled", true)
			J.setv(v_w, "kizarma", 1.0)
			J.setv(v_w, "pop", 1.0)
			J.setv(J.getv(game.j_G, "boards"), v_ti, v_w)
			J.setv(J.getv(v_sl, v_si), "w", v_bekleyen)
			J.setv(J.getv(v_sl, v_si), "t", 0.0)
			J.setv(J.getv(v_sl, v_si), "dur", J.method(game.j_TUN, "grillTime", [game.j_G]))
			J.setv(J.getv(v_sl, v_si), "done", false)
			J.setv(J.getv(v_sl, v_si), "yan", 0.0)
			J.method(game.j_SFX, "sizzle", [])
			J.method(game.j_SFX, "pick", [])
			game.effects.f_burst(game.grill_system.f_grillSlotX(v_si), game.grill_system.f_grillSlotY(v_si), 8.0, ["#ffe9c0", "#ffd257", "#ffffff"], {"spMax": 50.0, "up": 20.0})
			game.equipment_system.f_checkAuto()
			return null
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say(("Tezgâh dolu — bir dürümü servis et" if J.truth(J.method(game.j_TUN, "autoPaper", [game.j_G])) else "Tezgâh dolu — bir dürümü kâğıtlayıp ver"))
		return null
	J.setv(v_w, "grilled", true)
	J.setv(v_w, "kizarma", 1.0)
	J.setv(v_w, "pop", 1.0)
	J.setv(J.getv(game.j_G, "boards"), v_idx, v_w)
	J.method(v_sl, "splice", [v_si, 1.0])
	J.method(game.j_SFX, "pick", [])
	v_gx0 = game.grill_system.f_grillSlotX(v_si)
	v_gy0 = game.grill_system.f_grillSlotY(v_si)
	if J.truth(J.getv(v_w, "burnt")):
		game.effects.f_ftext("YANDI!", v_gx0, (v_gy0 - 16.0), J.getv(game.j_P, "bad"), {"life": 1.3})
		J.method(game.j_SFX, "bad", [])
		game.effects.f_burst(v_gx0, v_gy0, 8.0, ["#3a2a1e", "#6b4a2a", "#1a1210"], {"spMax": 46.0, "up": 18.0})
	else:
		game.effects.f_burst(v_gx0, v_gy0, 8.0, ["#ffe9c0", "#ffd257", "#ffffff"], {"spMax": 50.0, "up": 20.0})
		v_s2 = 0.0
		while J.lt(v_s2, 5.0):
			game.effects.f_part({"x": J.add(v_gx0, game.math_utils.f_rnd((-J.n(10.0)), 10.0)), "y": (v_gy0 - 6.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(24.0)), (-J.n(12.0))), "life": 0.9, "col": "rgba(240,235,225,.5)", "g": (-J.n(10.0)), "sz": 1.0})
			v_s2 = J.add(v_s2, 1.0)
	game.equipment_system.f_checkAuto()
	return null

# game.js:1322
func f_updateGrill(p_dt: Variant = null) -> Variant:
	var v_sl: Variant = null
	var v_yanar: Variant = null
	var v_yanSure: Variant = null
	var v_cizirti: Variant = null
	var v_i: Variant = null
	var v_s: Variant = null
	var v_hi: Variant = null
	var v_dt: Variant = p_dt
	v_sl = J.getv(J.getv(game.j_G, "grill"), "slots")
	if (not J.truth(J.getv(v_sl, "length"))):
		return null
	if J.truth(game.event_system.f_kesintiVarMi()):
		return null
	v_yanar = J.method(game.j_TUN, "grillYanar", [game.j_G])
	v_yanSure = J.method(game.j_TUN, "grillYanmaSure", [game.j_G])
	v_cizirti = false
	v_i = 0.0
	while J.lt(v_i, J.getv(v_sl, "length")):
		v_s = J.getv(v_sl, v_i)
		J.setv(v_s, "t", J.add(J.getv(v_s, "t"), v_dt))
		J.setv(J.getv(v_s, "w"), "kizarma", game.math_utils.f_clamp((float(J.getv(v_s, "t")) / float(max(0.001, J.getv(v_s, "dur")))), 0.0, 1.0))
		if J.lt(J.getv(v_s, "t"), J.getv(v_s, "dur")):
			v_cizirti = true
			if J.truth(game.f_chance((v_dt * 5.0))):
				game.effects.f_part({"x": J.add(game.grill_system.f_grillSlotX(v_i), game.math_utils.f_rnd((-J.n(8.0)), 8.0)), "y": (game.grill_system.f_grillSlotY(v_i) - 4.0), "vx": game.math_utils.f_rnd((-J.n(5.0)), 5.0), "vy": game.math_utils.f_rnd((-J.n(22.0)), (-J.n(10.0))), "life": 0.8, "col": "rgba(240,232,220,.42)", "g": (-J.n(12.0)), "sz": 1.0})
		else:
			if (not J.truth(J.getv(v_s, "done"))):
				J.setv(v_s, "done", true)
				J.method(game.j_SFX, "ding", [])
			if ((J.truth(v_yanar) and J.gt(v_yanSure, 0.0)) and (not J.truth(J.getv(J.getv(v_s, "w"), "burnt")))):
				J.setv(v_s, "yan", game.math_utils.f_clamp(J.add(J.getv(v_s, "yan"), (float(v_dt) / float(v_yanSure))), 0.0, 1.0))
				if J.truth(game.f_chance((v_dt * J.add(2.0, (J.getv(v_s, "yan") * 10.0))))):
					game.effects.f_part({"x": J.add(game.grill_system.f_grillSlotX(v_i), game.math_utils.f_rnd((-J.n(7.0)), 7.0)), "y": (game.grill_system.f_grillSlotY(v_i) - 4.0), "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(8.0))), "life": 1.1, "col": ("rgba(60,50,44,.55)" if J.gt(J.getv(v_s, "yan"), 0.6) else "rgba(150,140,130,.45)"), "g": (-J.n(14.0)), "sz": 1.0})
				if J.ge(J.getv(v_s, "yan"), 1.0):
					J.setv(J.getv(v_s, "w"), "burnt", true)
					J.setv(J.getv(v_s, "w"), "kizarma", 1.0)
					J.setv(J.getv(game.j_G, "stats"), "yanik", J.add((J.getv(J.getv(game.j_G, "stats"), "yanik") if J.truth(J.getv(J.getv(game.j_G, "stats"), "yanik")) else 0.0), 1.0))
					J.method(game.j_SFX, "bad", [])
					game.effects.f_shake(1.6)
					game.effects.f_ftext("YANIYOR!", game.grill_system.f_grillSlotX(v_i), (game.grill_system.f_grillSlotY(v_i) - 18.0), J.getv(game.j_P, "bad"), {"life": 1.4})
		v_i = J.add(v_i, 1.0)
	if J.truth(v_cizirti):
		J.setv(J.getv(game.j_G, "grill"), "sz", J.add((J.getv(J.getv(game.j_G, "grill"), "sz") if J.truth(J.getv(J.getv(game.j_G, "grill"), "sz")) else 0.0), v_dt))
		if J.gt(J.getv(J.getv(game.j_G, "grill"), "sz"), 0.9):
			J.setv(J.getv(game.j_G, "grill"), "sz", 0.0)
			J.method(game.j_SFX, "sizzle", [])
	if J.truth(J.method(game.j_TUN, "autoGrill", [game.j_G])):
		v_hi = game.grill_system.f_grillHazirIdx()
		if (J.ge(v_hi, 0.0) and J.ge(game.grill_system.f_grillBosYer(), 0.0)):
			game.grill_system.f_grillTakeOut(v_hi)
	return null

