# Street draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:1094
func f_drawStreetProps(p_t: Variant = null, p_lampOn: Variant = null) -> Variant:
	var v_M: Variant = null
	var v_gx: Variant = null
	var v_lx: Variant = null
	var v_ly: Variant = null
	var v_gI: Variant = null
	var v_bsx: Variant = null
	var v_bsy: Variant = null
	var v_pkx: Variant = null
	var v_pky: Variant = null
	var v_trx: Variant = null
	var v_try0: Variant = null
	var v_st: Variant = null
	var v_kirmizi: Variant = null
	var v_sari: Variant = null
	var v_yesil: Variant = null
	var v_hy: Variant = null
	var v_hc: Variant = null
	var v_pwx: Variant = null
	var v_t: Variant = p_t
	var v_lampOn: Variant = p_lampOn
	v_M = game.street_background.f_stM()
	v_gx = J.getv(v_M, "gx")
	game.street_background.f_drawSokakAgaci(J.add(v_gx, 118.0), J.add(J.getv(v_M, "base"), 7.0), J.getv((game.city_system.f_sehirTema() if J.truth(game.city_system.f_sehirTema()) else {}), "agac"))
	v_lx = J.add(v_gx, 46.0)
	v_ly = J.add(J.getv(v_M, "base"), 8.0)
	game.f_fr((v_lx - 1.0), (v_ly - 34.0), 3.0, 34.0, "#4d545b")
	game.f_vl((v_lx - 1.0), (v_ly - 34.0), 34.0, "#6f777f")
	game.f_fr((v_lx - 3.0), (v_ly - 1.0), 7.0, 2.0, "#3d434a")
	game.f_ln(J.add(v_lx, 1.0), (v_ly - 34.0), J.add(v_lx, 7.0), (v_ly - 36.0), "#4d545b")
	game.f_fr(J.add(v_lx, 6.0), (v_ly - 37.0), 8.0, 3.0, "#5b636b")
	game.f_fr(J.add(v_lx, 7.0), (v_ly - 34.0), 6.0, 2.0, ("#ffe9a0" if J.truth(v_lampOn) else "#8f979f"))
	if J.truth(v_lampOn):
		J.setv(game.j_ctx, "globalAlpha", 0.22)
		v_gI = 0.0
		while J.lt(v_gI, 12.0):
			game.f_fr(((J.add(v_lx, 10.0) - 2.0) - v_gI), J.add((v_ly - 32.0), v_gI), J.add(4.0, (v_gI * 2.0)), 1.0, "#ffe9a0")
			v_gI = J.add(v_gI, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_bsx = J.add(v_gx, 150.0)
	v_bsy = J.add(J.getv(v_M, "base"), 8.0)
	game.f_fr(v_bsx, (v_bsy - 22.0), 2.0, 22.0, "#5a636b")
	game.f_fr(J.add(v_bsx, 30.0), (v_bsy - 22.0), 2.0, 22.0, "#5a636b")
	game.f_fr((v_bsx - 2.0), (v_bsy - 25.0), 36.0, 3.0, "#3f6fbd")
	game.f_hl((v_bsx - 2.0), (v_bsy - 25.0), 36.0, "#6f9ede")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_bsx, 2.0), (v_bsy - 22.0), 28.0, 14.0, "#cfe4f2")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(J.add(v_bsx, 8.0), (v_bsy - 20.0), 14.0, 8.0, "#2f4f6a")
	game.f_fr(J.add(v_bsx, 9.0), (v_bsy - 19.0), 12.0, 6.0, "#e8ecef")
	game.f_hl(J.add(v_bsx, 10.0), (v_bsy - 17.0), 10.0, "#3f6fbd")
	game.f_hl(J.add(v_bsx, 10.0), (v_bsy - 15.0), 7.0, "#8a9aa8")
	game.f_fr(J.add(v_bsx, 4.0), (v_bsy - 7.0), 24.0, 2.0, "#7a5a3a")
	game.f_hl(J.add(v_bsx, 4.0), (v_bsy - 7.0), 24.0, "#9a7a52")
	game.f_vl(J.add(v_bsx, 6.0), (v_bsy - 5.0), 5.0, "#5a4a32")
	game.f_vl(J.add(v_bsx, 25.0), (v_bsy - 5.0), 5.0, "#5a4a32")
	v_pkx = J.add(v_gx, 78.0)
	v_pky = J.add(J.getv(v_M, "base"), 8.0)
	game.street_background.f_drawSehirIkonu(v_pkx, v_pky, J.getv((game.city_system.f_sehirTema() if J.truth(game.city_system.f_sehirTema()) else {}), "ikon"), v_t)
	v_trx = J.add(v_gx, 224.0)
	v_try0 = J.add(J.getv(v_M, "base"), 8.0)
	game.f_fr((v_trx - 1.0), (v_try0 - 26.0), 3.0, 26.0, "#4d545b")
	game.f_fr((v_trx - 4.0), (v_try0 - 38.0), 9.0, 13.0, "#33383e")
	game.f_fr((v_trx - 3.0), (v_try0 - 37.0), 7.0, 11.0, "#454b52")
	v_st = J.getv(game.j_TLIGHT, "state")
	v_kirmizi = J.eq(v_st, "red")
	v_sari = J.eq(v_st, "yellow")
	v_yesil = J.eq(v_st, "green")
	game.f_disc(v_trx, (v_try0 - 34.0), 2.0, ("#e2483a" if J.truth(v_kirmizi) else "#5a2a26"))
	game.f_disc(v_trx, (v_try0 - 30.0), 2.0, ("#e0c23a" if J.truth(v_sari) else "#5a512a"))
	game.f_disc(v_trx, (v_try0 - 27.0), 2.0, ("#3fbf5a" if J.truth(v_yesil) else "#2a5a34"))
	v_hy = ((v_try0 - 34.0) if J.truth(v_kirmizi) else ((v_try0 - 30.0) if J.truth(v_sari) else (v_try0 - 27.0)))
	v_hc = ("#e2483a" if J.truth(v_kirmizi) else ("#e0c23a" if J.truth(v_sari) else "#3fbf5a"))
	J.setv(game.j_ctx, "globalAlpha", J.add(0.22, (0.1 * sin((v_t * 4.0)))))
	game.f_disc(v_trx, v_hy, 4.0, v_hc)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_pwx = (v_trx - 30.0)
	game.f_fr((v_pwx - 1.0), (v_try0 - 16.0), 3.0, 16.0, "#4d545b")
	game.f_fr((v_pwx - 3.0), (v_try0 - 24.0), 7.0, 9.0, "#33383e")
	game.f_fr((v_pwx - 2.0), (v_try0 - 23.0), 5.0, 7.0, "#454b52")
	game.f_disc(v_pwx, (v_try0 - 21.0), 1.0, ("#3fbf5a" if J.truth(v_kirmizi) else "#2a5a34"))
	game.f_disc(v_pwx, (v_try0 - 18.0), 1.0, ("#5a2a26" if J.truth(v_kirmizi) else "#e2483a"))
	return null

# art.js:1158
func f_drawNearProps(p_t: Variant = null) -> Variant:
	var v_M: Variant = null
	var v_gx: Variant = null
	var v_pby: Variant = null
	var v_pbx: Variant = null
	var v_kx: Variant = null
	var v_kk: Variant = null
	var v_t: Variant = p_t
	v_M = game.street_background.f_stM()
	v_gx = J.getv(v_M, "gx")
	v_pby = (J.add(J.getv(J.getv(game.j_LAY, "glass"), "y"), J.getv(J.getv(game.j_LAY, "glass"), "h")) - 1.0)
	v_pbx = J.add(v_gx, 90.0)
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(J.add(v_pbx, 7.0), v_pby, 11.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ring(v_pbx, (v_pby - 5.0), 4.0, "#2b3037")
	game.f_ring(J.add(v_pbx, 14.0), (v_pby - 5.0), 4.0, "#2b3037")
	game.f_px(v_pbx, (v_pby - 5.0), "#8f979f")
	game.f_px(J.add(v_pbx, 14.0), (v_pby - 5.0), "#8f979f")
	game.f_ln(v_pbx, (v_pby - 5.0), J.add(v_pbx, 6.0), (v_pby - 12.0), "#3f8a4a")
	game.f_ln(J.add(v_pbx, 6.0), (v_pby - 12.0), J.add(v_pbx, 14.0), (v_pby - 5.0), "#3f8a4a")
	game.f_ln(J.add(v_pbx, 6.0), (v_pby - 12.0), J.add(v_pbx, 2.0), (v_pby - 5.0), "#357a40")
	game.f_ln(J.add(v_pbx, 14.0), (v_pby - 5.0), J.add(v_pbx, 9.0), (v_pby - 5.0), "#357a40")
	game.f_fr(J.add(v_pbx, 4.0), (v_pby - 14.0), 4.0, 2.0, "#2b2018")
	game.f_ln(J.add(v_pbx, 12.0), (v_pby - 13.0), J.add(v_pbx, 17.0), (v_pby - 13.0), "#5a636b")
	game.f_vl(J.add(v_pbx, 14.0), (v_pby - 13.0), 8.0, "#5a636b")
	v_kx = J.add(v_gx, 236.0)
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(J.add(v_kx, 5.0), v_pby, 8.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_kx, (v_pby - 13.0), 11.0, 13.0, "#4f5a52")
	game.f_fr(J.add(v_kx, 1.0), (v_pby - 13.0), 9.0, 12.0, "#63705f")
	v_kk = 0.0
	while J.lt(v_kk, 3.0):
		game.f_vl(J.add(J.add(v_kx, 3.0), (v_kk * 3.0)), (v_pby - 11.0), 9.0, "#4f5a52")
		v_kk = J.add(v_kk, 1.0)
	game.f_fr((v_kx - 1.0), (v_pby - 15.0), 13.0, 3.0, "#3f4a44")
	game.f_hl((v_kx - 1.0), (v_pby - 15.0), 13.0, "#7c8a78")
	return null

# art.js:1874
func f_drawStreet(p_t: Variant = null, p_dayK: Variant = null, p_rainOn: Variant = null, p_courier: Variant = null) -> Variant:
	var _cells: Dictionary = {"M": [null], "actors": [null], "laneY": [null], "t": [p_t], "gx": [null], "gw": [null], "rainOn": [p_rainOn], "courier": [p_courier]}
	var v_gy: Variant = null
	var v_gh: Variant = null
	var v_hs: Variant = null
	var v_hy: Variant = null
	var v_kay: Variant = null
	var v_bi2: Variant = null
	var v_bsp: Variant = null
	var v_bu: Variant = null
	var v_bx2: Variant = null
	var v_by2: Variant = null
	var v_kanat: Variant = null
	var v_span: Variant = null
	var v_devriye: Variant = null
	var v_wi: Variant = null
	var v_wk: Variant = null
	var v_uw: Variant = null
	var v_wx: Variant = null
	var v_i: Variant = null
	var v_PK: Variant = null
	var v_ci2: Variant = null
	var v_aI: Variant = null
	var v_eskiKip: Variant = null
	var v_d: Variant = null
	var v_hz: Variant = null
	var v_dx0: Variant = null
	var v_dy0: Variant = null
	var v_boy: Variant = null
	var v_yak: Variant = null
	var v_q: Variant = null
	var v_sp: Variant = null
	var v_faz: Variant = null
	var v_sx0: Variant = null
	var v_sy0: Variant = null
	var v_rr: Variant = null
	var v_wr: Variant = null
	var v_wy: Variant = null
	var v_ww: Variant = null
	var v_dayK: Variant = p_dayK
	_cells["M"][0] = game.street_background.f_stM()
	_cells["gx"][0] = J.getv(_cells["M"][0], "gx")
	v_gy = J.getv(_cells["M"][0], "gy")
	_cells["gw"][0] = J.getv(_cells["M"][0], "gw")
	v_gh = J.getv(_cells["M"][0], "gh")
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [_cells["gx"][0], v_gy, _cells["gw"][0], v_gh])
	J.method(game.j_ctx, "clip", [])
	if J.gt(v_dayK, 0.001):
		J.setv(game.j_ctx, "globalAlpha", min(0.4, (v_dayK * 0.4)))
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#ff8a3a")
		J.setv(game.j_ctx, "globalAlpha", min(0.2, (v_dayK * 0.2)))
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#3a2a5a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(_cells["rainOn"][0]):
		J.setv(game.j_ctx, "globalAlpha", 0.24)
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#2a4a7a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (J.eq(J.kind(J.ref(game.weather_system.f_isKar, 0)), "function") and J.truth(game.weather_system.f_isKar())):
		J.setv(game.j_ctx, "globalAlpha", 0.2)
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#b8cde4")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		if (J.eq(J.kind(J.ref(game.weather_system.f_isSicak, 0)), "function") and J.truth(game.weather_system.f_isSicak())):
			J.setv(game.j_ctx, "globalAlpha", 0.16)
			game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#ffb64a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.street_draw.f_drawStreetProps(_cells["t"][0], (J.gt(v_dayK, 0.35) if J.gt(v_dayK, 0.35) else _cells["rainOn"][0]))
	if (J.eq(J.kind(J.ref(game.weather_system.f_isSicak, 0)), "function") and J.truth(game.weather_system.f_isSicak())):
		J.setv(game.j_ctx, "globalAlpha", 0.13)
		v_hs = 0.0
		while J.lt(v_hs, 7.0):
			v_hy = J.add(J.add(J.getv(_cells["M"][0], "roadY"), 3.0), (v_hs * max(2.0, (float((J.getv(_cells["M"][0], "roadH") - 6.0)) / float(7.0)))))
			v_kay = (sin(J.add((_cells["t"][0] * 1.7), (v_hs * 1.3))) * 7.0)
			game.f_hl(floor(J.add(J.add(_cells["gx"][0], 10.0), v_kay) + 0.5), floor(v_hy + 0.5), (_cells["gw"][0] - 26.0), "#fff0c0")
			v_hs = J.add(v_hs, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (not J.truth(_cells["rainOn"][0])):
		v_bi2 = 0.0
		while J.lt(v_bi2, 5.0):
			v_bsp = J.add(11.0, (fmod(J.n(v_bi2), J.n(3.0)) * 4.0))
			v_bu = fmod(J.n(J.add((float((_cells["t"][0] * v_bsp)) / float(J.add(_cells["gw"][0], 60.0))), (v_bi2 * 0.23))), J.n(1.0))
			v_bx2 = J.add((_cells["gx"][0] - 20.0), (v_bu * J.add(_cells["gw"][0], 40.0)))
			v_by2 = J.add(J.add(J.add(v_gy, 6.0), (sin(J.add((_cells["t"][0] * 1.4), (v_bi2 * 2.1))) * 3.0)), (fmod(J.n(v_bi2), J.n(3.0)) * 5.0))
			v_kanat = (1.0 if J.gt(sin(J.add((_cells["t"][0] * 9.0), (v_bi2 * 1.7))), 0.0) else (-J.n(1.0)))
			J.setv(game.j_ctx, "globalAlpha", 0.55)
			game.f_px(v_bx2, v_by2, "#4a5560")
			game.f_px((v_bx2 - 1.0), (v_by2 - v_kanat), "#4a5560")
			game.f_px(J.add(v_bx2, 1.0), (v_by2 - v_kanat), "#4a5560")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_bi2 = J.add(v_bi2, 1.0)
	v_span = J.add(_cells["gw"][0], 110.0)
	v_devriye = (game.progression_system.f_fermanSehri(game.j_G) if (not J.eq(J.kind(game.j_G), "undefined") and J.truth(J.getv(game.j_G, "ferman"))) else (J.getv(game.j_G, "ferman") if not J.eq(J.kind(game.j_G), "undefined") else not J.eq(J.kind(game.j_G), "undefined")))
	v_wi = 0.0
	while J.lt(v_wi, J.getv(game.j_WALKERS, "length")):
		v_wk = J.getv(game.j_WALKERS, v_wi)
		v_uw = fmod(J.n(J.add((float((_cells["t"][0] * J.getv(v_wk, "sp"))) / float(v_span)), J.getv(v_wk, "off"))), J.n(1.0))
		v_wx = (J.add((_cells["gx"][0] - 24.0), (v_uw * v_span)) if J.gt(J.getv(v_wk, "dir"), 0.0) else (J.add(J.add(_cells["gx"][0], _cells["gw"][0]), 24.0) - (v_uw * v_span)))
		if (J.truth(v_devriye) and (J.eq(v_wi, 1.0) or J.eq(v_wi, 3.0))):
			game.pedestrian_draw.f_drawAsker(v_wx, J.getv(_cells["M"][0], "walkY"), _cells["t"][0], J.getv(v_wk, "dir"), 0.0)
			game.pedestrian_draw.f_drawAsker((v_wx - (J.getv(v_wk, "dir") * 7.0)), J.getv(_cells["M"][0], "walkY"), _cells["t"][0], J.getv(v_wk, "dir"), 0.0)
		else:
			game.pedestrian_draw.f_drawPed(v_wx, J.getv(_cells["M"][0], "walkY"), J.getv(v_wk, "k"), J.getv(v_wk, "dir"), _cells["t"][0], 1.0, (J.eq(fmod(J.n(J.getv(v_wk, "k")), J.n(2.0)), 0.0) if J.truth(_cells["rainOn"][0]) else _cells["rainOn"][0]))
		v_wi = J.add(v_wi, 1.0)
	_cells["laneY"][0] = [J.getv(_cells["M"][0], "farY"), J.getv(_cells["M"][0], "nearY")]
	_cells["actors"][0] = []
	game.traffic_system.f_trafGerek()
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_TRAF, "length")):
		J.invoke(game.street_actors._closure_57.bind({"218:M": _cells["M"], "218:actors": _cells["actors"], "218:laneY": _cells["laneY"], "218:t": _cells["t"]}), [J.getv(game.j_TRAF, v_i)])
		v_i = J.add(v_i, 1.0)
	v_PK = game.vehicle_draw.f_parkedKalip()
	game.traffic_system.f_updateBinek(_cells["t"][0], v_PK)
	if not J.eq(J.getv(game.j_KAR, "faz"), "yok"):
		J.invoke(game.street_actors._closure_59.bind({"218:M": _cells["M"], "218:gx": _cells["gx"], "218:gw": _cells["gw"], "218:actors": _cells["actors"], "218:t": _cells["t"]}), [])
	if not J.eq(J.getv(game.j_EJD, "faz"), "yok"):
		J.invoke(game.street_actors._closure_61.bind({"218:gx": _cells["gx"], "218:gw": _cells["gw"], "218:M": _cells["M"], "218:actors": _cells["actors"], "218:t": _cells["t"]}), [])
	if not J.eq(J.getv(game.j_SUP, "faz"), "yok"):
		J.invoke(game.street_actors._closure_63.bind({"218:gx": _cells["gx"], "218:gw": _cells["gw"], "218:M": _cells["M"], "218:actors": _cells["actors"], "218:t": _cells["t"]}), [])
	v_ci2 = 0.0
	while J.lt(v_ci2, J.getv(game.j_CROSSERS, "length")):
		J.invoke(game.street_actors._closure_65.bind({"218:M": _cells["M"], "218:gx": _cells["gx"], "218:actors": _cells["actors"], "218:t": _cells["t"], "218:rainOn": _cells["rainOn"]}), [J.getv(game.j_CROSSERS, v_ci2)])
		v_ci2 = J.add(v_ci2, 1.0)
	if (J.truth(_cells["courier"][0]) and J.gt(J.getv(_cells["courier"][0], "out"), 0.0)):
		J.invoke(game.street_actors._closure_67.bind({"218:courier": _cells["courier"], "218:M": _cells["M"], "218:gx": _cells["gx"], "218:gw": _cells["gw"], "218:actors": _cells["actors"], "218:t": _cells["t"]}), [])
	if ((not J.eq(J.kind(game.j_G), "undefined") and J.truth(J.getv(game.j_G, "kedi"))) and not J.eq(J.getv(J.getv(game.j_G, "kedi"), "faz"), "yok")):
		J.method(_cells["actors"][0], "push", [{"y": J.add(J.getv(_cells["M"][0], "curb2"), 2.0), "f": game.street_actors._closure_69.bind({"218:t": _cells["t"]})}])
	if (((not J.eq(J.kind(game.j_G), "undefined") and J.truth(J.getv(game.j_G, "gozcu"))) and J.truth(J.getv(game.j_G, "ferman"))) and (not J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi")))):
		J.invoke(game.street_actors._closure_70.bind({"218:actors": _cells["actors"], "218:M": _cells["M"], "218:t": _cells["t"]}), [J.getv(game.j_G, "gozcu")])
	J.method(_cells["actors"][0], "sort", [game.street_actors._closure_72.bind({})])
	v_aI = 0.0
	while J.lt(v_aI, J.getv(_cells["actors"][0], "length")):
		J.method(J.getv(_cells["actors"][0], v_aI), "f", [])
		v_aI = J.add(v_aI, 1.0)
	game.street_draw.f_drawNearProps(_cells["t"][0])
	if J.truth(game.traffic_system.f_betonSehir()):
		v_eskiKip = J.getv(game.j_ctx, "globalCompositeOperation")
		J.setv(game.j_ctx, "globalCompositeOperation", "saturation")
		J.setv(game.j_ctx, "globalAlpha", 0.72)
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#808080")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		J.setv(game.j_ctx, "globalCompositeOperation", v_eskiKip)
		J.setv(game.j_ctx, "globalAlpha", 0.1)
		game.f_fr(_cells["gx"][0], v_gy, _cells["gw"][0], v_gh, "#9aa0a8")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(_cells["rainOn"][0]):
		v_d = 0.0
		while J.lt(v_d, 40.0):
			v_hz = J.add(150.0, (game.f_hash1((v_d * 1.7)) * 190.0))
			v_dx0 = J.add(_cells["gx"][0], fmod(J.n(J.add((game.f_hash1((v_d * 3.3)) * _cells["gw"][0]), (_cells["t"][0] * 26.0))), J.n(_cells["gw"][0])))
			v_dy0 = J.add(v_gy, fmod(J.n(J.add((game.f_hash1((v_d * 7.9)) * v_gh), (_cells["t"][0] * v_hz))), J.n(v_gh)))
			v_boy = J.add(4.0, fmod(J.n(v_d), J.n(5.0)))
			v_yak = game.f_hash1((v_d * 5.1))
			J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (v_yak * 0.26)))
			v_q = 0.0
			while J.lt(v_q, v_boy):
				game.f_px(floor((v_dx0 - (v_q * 0.32)) + 0.5), floor(J.add(v_dy0, v_q) + 0.5), ("#eaf6ff" if J.gt(v_yak, 0.6) else "#bcd8e8"))
				v_q = J.add(v_q, 1.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_d = J.add(v_d, 1.0)
		v_sp = 0.0
		while J.lt(v_sp, 14.0):
			v_faz = fmod(J.n(J.add((_cells["t"][0] * 1.9), (game.f_hash1((v_sp * 2.3)) * 5.0))), J.n(1.0))
			v_sx0 = J.add(_cells["gx"][0], (game.f_hash1((v_sp * 4.7)) * _cells["gw"][0]))
			v_sy0 = J.add(J.getv(_cells["M"][0], "roadY"), (game.f_hash1((v_sp * 8.1)) * (J.getv(_cells["M"][0], "curb2") - J.getv(_cells["M"][0], "roadY"))))
			J.setv(game.j_ctx, "globalAlpha", ((1.0 - v_faz) * 0.34))
			v_rr = floor(J.add(1.0, (v_faz * 3.0)) + 0.5)
			game.f_ring(floor(v_sx0 + 0.5), floor(v_sy0 + 0.5), v_rr, "#cfe4f2")
			if J.lt(v_faz, 0.35):
				game.f_px(floor(v_sx0 + 0.5), (floor(v_sy0 + 0.5) - 1.0), "#ffffff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_sp = J.add(v_sp, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.12)
		v_wr = 0.0
		while J.lt(v_wr, 8.0):
			v_wx = J.add(_cells["gx"][0], (game.f_hash1((v_wr * 6.1)) * (_cells["gw"][0] - 14.0)))
			v_wy = J.add(J.add(J.getv(_cells["M"][0], "roadY"), 4.0), (game.f_hash1((v_wr * 3.9)) * (J.getv(_cells["M"][0], "roadH") - 8.0)))
			v_ww = J.add(J.add(6.0, floor((sin(J.add((_cells["t"][0] * 3.0), v_wr)) * 2.0) + 0.5)), (fmod(J.n(v_wr), J.n(4.0)) * 3.0))
			game.f_hl(floor(v_wx + 0.5), floor(v_wy + 0.5), v_ww, "#8fb8d0")
			v_wr = J.add(v_wr, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.eq(J.kind(J.ref(game.weather_draw.f_drawCamDamla, 1)), "function"):
			game.weather_draw.f_drawCamDamla(_cells["t"][0])
	if J.eq(J.kind(J.ref(game.weather_draw.f_drawKar, 1)), "function"):
		game.weather_draw.f_drawKar(_cells["t"][0])
	J.method(game.j_ctx, "restore", [])
	if (not J.truth(game.j_WINOVER)):
		game.window_draw.f_bakeWinOver()
	J.method(game.j_ctx, "drawImage", [J.getv(game.j_WINOVER, "c"), (J.getv(J.getv(game.j_LAY, "win"), "x") - J.getv(game.j_WINOVER, "ox")), (J.getv(J.getv(game.j_LAY, "win"), "y") - J.getv(game.j_WINOVER, "oy"))])
	return null

