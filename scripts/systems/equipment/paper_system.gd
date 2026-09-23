# Paper system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:1509
func f_paperHedef(p_sessiz: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_duz: Variant = null
	var v_kizarmis: Variant = null
	var v_yanmis: Variant = null
	var v_i: Variant = null
	var v_w: Variant = null
	var v_sessiz: Variant = p_sessiz
	v_n = J.method(game.j_TUN, "boards", [game.j_G])
	v_duz = (-J.n(1.0))
	v_kizarmis = (-J.n(1.0))
	v_yanmis = (-J.n(1.0))
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_w = J.getv(J.getv(game.j_G, "boards"), v_i)
		if ((not J.truth(v_w)) or not J.eq(J.getv(v_w, "state"), "rolled")):
			v_i = J.add(v_i, 1.0)
			continue
		if J.truth(J.getv(v_w, "burnt")):
			if J.lt(v_yanmis, 0.0):
				v_yanmis = v_i
			v_i = J.add(v_i, 1.0)
			continue
		if J.truth(J.getv(v_w, "grilled")):
			if J.lt(v_kizarmis, 0.0):
				v_kizarmis = v_i
		else:
			if J.lt(v_duz, 0.0):
				v_duz = v_i
		v_i = J.add(v_i, 1.0)
	if J.ge(v_kizarmis, 0.0):
		return v_kizarmis
	if J.ge(v_duz, 0.0):
		if (J.truth(J.method(game.j_TUN, "grillOn", [game.j_G])) and (not J.truth(game.grill_system.f_grillTikali()))):
			if (not J.truth(v_sessiz)):
				J.method(game.j_SFX, "bad", [])
				game.session_system.f_say("Önce ızgaraya at — kâğıt sonra")
			return (-J.n(1.0))
		return v_duz
	if J.ge(v_yanmis, 0.0):
		if (not J.truth(v_sessiz)):
			J.method(game.j_SFX, "bad", [])
			game.session_system.f_say("Yanmış dürüm satılmaz — çöpe at")
		return (-J.n(1.0))
	if (not J.truth(v_sessiz)):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce dürümü sar")
	return (-J.n(1.0))
	return null

# game.js:1533
func f_paperClick() -> Variant:
	var v_idx: Variant = null
	if J.eq(game.equipment_system.f_UV(game.j_G, "paper"), 0.0):
		game.session_system.f_say("Kağıdı tutup dürümün üstüne sürükle")
		return null
	v_idx = game.paper_system.f_paperHedef()
	if J.lt(v_idx, 0.0):
		return null
	if J.gt(J.getv(J.getv(game.j_G, "paper"), "busy"), 0.0):
		J.method(game.j_SFX, "bad", [])
		return null
	game.paper_system.f_startPaper(v_idx)
	return null

# game.js:1540
func f_startPaper(p_idx: Variant = null) -> Variant:
	var v_idx: Variant = p_idx
	J.setv(J.getv(game.j_G, "paper"), "busy", 1.0)
	J.setv(J.getv(game.j_G, "paper"), "dur", J.method(game.j_TUN, "paperTime", [game.j_G]))
	J.setv(J.getv(game.j_G, "paper"), "idx", v_idx)
	J.method(game.j_SFX, "pick", [])
	return null

# game.js:1544
func f_updatePaper(p_dt: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_dt: Variant = p_dt
	v_p = J.getv(game.j_G, "paper")
	if J.gt(J.getv(v_p, "busy"), 0.0):
		J.setv(v_p, "busy", (J.getv(v_p, "busy") - (float(v_dt) / float(J.getv(v_p, "dur")))))
		if J.le(J.getv(v_p, "busy"), 0.0):
			J.setv(v_p, "busy", 0.0)
			game.wrap_system.f_applyPaper(J.getv(v_p, "idx"))
	return null

