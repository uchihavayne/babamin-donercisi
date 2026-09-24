# Story debt. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:908
func f_pro4Arka() -> Variant:
	var v_i: Variant = null
	var v_fon: Variant = null
	v_fon = [[(-J.n(62.0)), (-J.n(10.0)), "#170f0a"], [(-J.n(10.0)), 34.0, "#20160e"], [34.0, 66.0, "#1a1109"], [66.0, 96.0, "#120c07"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_fon, "length")):
		game.story_canvas.f_pb((-J.n(230.0)), J.getv(J.getv(v_fon, v_i), 0.0), 230.0, J.getv(J.getv(v_fon, v_i), 1.0), J.getv(J.getv(v_fon, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	v_i = 0.0
	while J.lt(v_i, 15.0):
		game.story_canvas.f_pb(J.add((-J.n(220.0)), (v_i * 30.0)), (-J.n(10.0)), J.add((-J.n(218.0)), (v_i * 30.0)), 96.0, "#2a1c12")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(61.0)), 240.0, (-J.n(16.0)), "#3d2a1c")
	v_i = 0.0
	while J.lt(v_i, 22.0):
		game.story_canvas.f_pb(J.add((-J.n(236.0)), (v_i * 22.0)), (-J.n(61.0)), J.add((-J.n(234.0)), (v_i * 22.0)), (-J.n(16.0)), "#33241a")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(16.0)), 240.0, (-J.n(13.0)), "#7a5638")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(13.0)), 240.0, (-J.n(6.0)), "#3d2a1c")
	game.story_canvas.f_pbA((-J.n(120.0)), (-J.n(16.0)), 120.0, (-J.n(12.0)), "#ffcf7a", 0.16)
	game.story_canvas.f_pbA((-J.n(172.0)), (-J.n(15.0)), (-J.n(114.0)), (-J.n(11.0)), "#000000", 0.4)
	game.f_ring(game.story_canvas.f_pbx((-J.n(158.0))), game.story_canvas.f_pby((-J.n(2.0))), 11.0, "#a8811f")
	game.f_ring(game.story_canvas.f_pbx((-J.n(158.0))), game.story_canvas.f_pby((-J.n(2.0))), 10.0, "#d8ac35")
	game.f_ring(game.story_canvas.f_pbx((-J.n(128.0))), game.story_canvas.f_pby((-J.n(2.0))), 11.0, "#a8811f")
	game.f_ring(game.story_canvas.f_pbx((-J.n(128.0))), game.story_canvas.f_pby((-J.n(2.0))), 10.0, "#d8ac35")
	game.story_canvas.f_pb((-J.n(147.0)), (-J.n(3.0)), (-J.n(139.0)), 0.0, "#a8811f")
	game.story_canvas.f_pb((-J.n(174.0)), (-J.n(2.0)), (-J.n(156.0)), 1.0, "#a8811f")
	game.story_canvas.f_pbA((-J.n(167.0)), (-J.n(11.0)), (-J.n(149.0)), 7.0, "#b0c6d2", 0.22)
	game.story_canvas.f_pbA((-J.n(137.0)), (-J.n(11.0)), (-J.n(119.0)), 7.0, "#b0c6d2", 0.22)
	game.story_canvas.f_pbA(122.0, (-J.n(14.0)), 186.0, (-J.n(9.0)), "#000000", 0.42)
	game.story_canvas.f_pbE(146.0, (-J.n(10.0)), 20.0, 3.0, "#5f727e")
	game.story_canvas.f_pbE(146.0, (-J.n(11.0)), 18.0, 2.0, "#b0c6d2")
	game.story_debt.f_proBardak(146.0, (-J.n(12.0)), 30.0, 10.0, 6.4, 11.0)
	game.story_canvas.f_pb(160.0, 0.0, 164.0, 28.0, "#98a2ab")
	game.story_canvas.f_pb(158.0, 26.0, 166.0, 32.0, "#c6ced5")
	game.story_canvas.f_pb(176.0, (-J.n(8.0)), 183.0, (-J.n(2.0)), "#f4f0e6")
	game.story_canvas.f_pb(184.0, (-J.n(6.0)), 191.0, 0.0, "#f4f0e6")
	return null

# prologue.js:945
func f_proBardak(p_cx: Variant = null, p_z0: Variant = null, p_boy: Variant = null, p_rAlt: Variant = null, p_rBel: Variant = null, p_rUst: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_u: Variant = null
	var v_rr: Variant = null
	var v_z: Variant = null
	var v_ri: Variant = null
	var v_cx: Variant = p_cx
	var v_z0: Variant = p_z0
	var v_boy: Variant = p_boy
	var v_rAlt: Variant = p_rAlt
	var v_rBel: Variant = p_rBel
	var v_rUst: Variant = p_rUst
	v_i = 0.0
	while J.lt(v_i, v_boy):
		v_u = (float(v_i) / float((v_boy - 1.0)))
		v_rr = (J.add(v_rAlt, ((v_rBel - v_rAlt) * (float(v_u) / float(0.5)))) if J.lt(v_u, 0.5) else J.add(v_rBel, ((v_rUst - v_rBel) * (float((v_u - 0.5)) / float(0.5)))))
		v_z = J.add(v_z0, v_i)
		game.story_canvas.f_pb((v_cx - v_rr), v_z, J.add(v_cx, v_rr), J.add(v_z, 1.0), "#5f727e")
		game.story_canvas.f_pb(J.add((v_cx - v_rr), 1.0), v_z, (J.add(v_cx, v_rr) - 2.0), J.add(v_z, 1.0), "#8098a6")
		if (J.gt(v_i, 1.0) and J.lt(v_i, (v_boy - 2.0))):
			v_ri = (v_rr - 2.0)
			game.story_canvas.f_pb((v_cx - v_ri), v_z, J.add(v_cx, v_ri), J.add(v_z, 1.0), "#8a4410")
			game.story_canvas.f_pb(J.add((v_cx - v_ri), 1.0), v_z, (J.add(v_cx, v_ri) - 2.0), J.add(v_z, 1.0), ("#c06a18" if J.gt(v_i, (v_boy * 0.5)) else "#e08a28"))
		game.story_canvas.f_pb(J.add((v_cx - v_rr), 1.0), v_z, J.add((v_cx - v_rr), 2.0), J.add(v_z, 1.0), "#e0eef6")
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:962
func f_pro4Koni() -> Variant:
	var v_i: Variant = null
	J.setv(game.j_ctx, "globalAlpha", 0.038)
	v_i = 0.0
	while J.lt(v_i, 30.0):
		game.story_canvas.f_pb(((-J.n(12.0)) - (v_i * 6.0)), (68.0 - (v_i * 4.4)), J.add(12.0, (v_i * 6.0)), (72.0 - (v_i * 4.4)), "#ffcf7a")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:969
func f_pro4Vinyet() -> Variant:
	var v_i: Variant = null
	game.story_canvas.f_pbA((-J.n(230.0)), (-J.n(62.0)), (-J.n(170.0)), 96.0, "#000000", 0.44)
	game.story_canvas.f_pbA(170.0, (-J.n(62.0)), 230.0, 96.0, "#000000", 0.44)
	game.story_canvas.f_pbA((-J.n(230.0)), 74.0, 230.0, 96.0, "#000000", 0.3)
	v_i = 0.0
	while J.lt(v_i, 12.0):
		game.story_canvas.f_pbA((-J.n(230.0)), J.add((-J.n(61.0)), (v_i * 3.0)), 230.0, J.add((-J.n(58.0)), (v_i * 3.0)), "#000000", (0.3 - (v_i * 0.024)))
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:977
func f_proDebt(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_Y: Variant = null
	var v_sal: Variant = null
	var v_sw: Variant = null
	var v_stampK: Variant = null
	var v_drop: Variant = null
	var v_mz: Variant = null
	var v_eller: Variant = null
	var v_ex: Variant = null
	var v_yon: Variant = null
	var v_w: Variant = null
	var v_wz: Variant = null
	var v_wx: Variant = null
	var v_ww: Variant = null
	var v_boy: Variant = null
	var v_j: Variant = null
	var v_fz2: Variant = null
	var v_fbas: Variant = null
	var v_fuc: Variant = null
	var v_f0: Variant = null
	var v_f1: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	# REMAKE kancasi
	if game.f_hdProDebt(p_t, p_k): return null
	game.story_canvas.f_proCiz("s4a", J.ref(game.story_debt.f_pro4Arka, 0))
	v_sal = (sin((v_t * 1.1)) * 2.0)
	game.story_canvas.f_pb(J.add((-J.n(2.0)), (v_sal * 0.3)), 84.0, J.add(2.0, (v_sal * 0.3)), 96.0, "#1a1208")
	game.story_canvas.f_pb(J.add((-J.n(5.0)), v_sal), 78.0, J.add(5.0, v_sal), 84.0, "#3a2f20")
	game.story_canvas.f_pbE(v_sal, 72.0, 8.0, 10.0, "#ffe9a8")
	game.story_canvas.f_pbE((v_sal - 2.0), 73.0, 4.0, 5.0, "#fff8d8")
	J.method(game.j_ctx, "drawImage", [game.f_proKat("s4koni", J.ref(game.story_debt.f_pro4Koni, 0)), J.add(40.0, floor(v_sal + 0.5)), 44.0])
	v_sw = floor(sin((v_t * 1.2)) + 0.5)
	game.story_canvas.f_pbA(J.add((-J.n(70.0)), v_sw), (-J.n(22.0)), J.add(82.0, v_sw), 58.0, "#000000", 0.4)
	game.story_canvas.f_pb(J.add((-J.n(76.0)), v_sw), (-J.n(18.0)), J.add(70.0, v_sw), 60.0, "#cfc7b2")
	game.story_canvas.f_pb(J.add((-J.n(76.0)), v_sw), (-J.n(18.0)), J.add(68.0, v_sw), 59.0, "#e8e2d0")
	game.story_canvas.f_pb(J.add((-J.n(74.0)), v_sw), (-J.n(16.0)), J.add(64.0, v_sw), 57.0, "#f8f4e8")
	v_Y = v_sw
	game.story_canvas.f_pb(J.add((-J.n(66.0)), v_Y), 42.0, J.add((-J.n(50.0)), v_Y), 56.0, "#8a8474")
	game.story_canvas.f_pb(J.add((-J.n(63.0)), v_Y), 45.0, J.add((-J.n(53.0)), v_Y), 53.0, "#cfc7b2")
	game.text_draw.f_txt("İCRA VE İFLAS MÜDÜRLÜĞÜ", game.story_canvas.f_pbx(J.add(2.0, v_Y)), game.story_canvas.f_pby(55.0), "#4a4438", {"align": "c"})
	game.story_canvas.f_pb(J.add((-J.n(42.0)), v_Y), 40.0, J.add(14.0, v_Y), 45.0, "#6b6558")
	game.story_canvas.f_pb(J.add((-J.n(66.0)), v_Y), 34.0, J.add(60.0, v_Y), 36.0, "#8a8474")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.story_canvas.f_pb(J.add((-J.n(66.0)), v_Y), (24.0 - (v_i * 7.0)), J.add((58.0 - (30.0 if J.eq(v_i, 3.0) else 0.0)), v_Y), (26.0 - (v_i * 7.0)), "#8a8474")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb(J.add((-J.n(54.0)), v_Y), (-J.n(10.0)), J.add(50.0, v_Y), 12.0, "#a8a090")
	game.story_canvas.f_pb(J.add((-J.n(52.0)), v_Y), (-J.n(8.0)), J.add(48.0, v_Y), 10.0, "#f2eede")
	var epi: bool = J.truth(J.getv(game.j_PRO, "epi"))
	var mur: String = "#2e7a3a" if epi else "#a8201a"
	game.text_draw.f_txt("KALAN BORÇ" if epi else "TOPLAM BORÇ", game.story_canvas.f_pbx(J.add((-J.n(2.0)), v_Y)), game.story_canvas.f_pby(9.0), "#7a3428", {"align": "c"})
	game.text_draw.f_txt("$0" if epi else "$5.000.000", game.story_canvas.f_pbx(J.add((-J.n(2.0)), v_Y)), game.story_canvas.f_pby(2.0), mur, {"align": "c", "sc": 2.0})
	v_i = 0.0
	while J.lt(v_i, 9.0):
		game.story_canvas.f_pb(J.add(J.add(20.0, (v_i * 4.0)), v_Y), J.add((-J.n(14.0)), (fmod(J.n(v_i), J.n(3.0)) * 2.0)), J.add(J.add(24.0, (v_i * 4.0)), v_Y), J.add((-J.n(12.0)), (fmod(J.n(v_i), J.n(3.0)) * 2.0)), "#3a3a4a")
		v_i = J.add(v_i, 1.0)
	v_stampK = game.math_utils.f_clamp(((J.getv(game.j_PRO, "t") - 2.0) * 3.2), 0.0, 1.0)
	if J.gt(v_stampK, 0.0):
		v_drop = floor(((1.0 - v_stampK) * 30.0) + 0.5)
		v_mz = J.add(22.0, v_drop)
		if (J.gt(v_stampK, 0.95) and J.lt(v_stampK, 1.0)):
			game.effects.f_shake(2.0)
		J.setv(game.j_ctx, "globalAlpha", (0.9 * J.add(0.4, (0.6 * v_stampK))))
		game.f_ring(game.story_canvas.f_pbx(J.add(44.0, v_Y)), game.story_canvas.f_pby(v_mz), 16.0, mur)
		game.f_ring(game.story_canvas.f_pbx(J.add(44.0, v_Y)), game.story_canvas.f_pby(v_mz), 15.0, mur)
		game.f_ring(game.story_canvas.f_pbx(J.add(44.0, v_Y)), game.story_canvas.f_pby(v_mz), 11.0, mur)
		game.text_draw.f_txt("ÖDENDİ" if epi else "ÖDENMEDİ", game.story_canvas.f_pbx(J.add(44.0, v_Y)), game.story_canvas.f_pby(J.add(v_mz, 3.0)), mur, {"align": "c"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.ge(v_stampK, 1.0):
			game.story_canvas.f_pbA(J.add(52.0, v_Y), 6.0, J.add(64.0, v_Y), 12.0, mur, 0.35)
	v_eller = [[(-J.n(84.0)), (-J.n(1.0))], [78.0, 1.0]]
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_ex = J.getv(J.getv(v_eller, v_i), 0.0)
		v_yon = J.getv(J.getv(v_eller, v_i), 1.0)
		game.story_canvas.f_pbA((v_ex - 16.0), (-J.n(14.0)), J.add(v_ex, 16.0), (-J.n(9.0)), "#000000", 0.42)
		v_w = 0.0
		while J.lt(v_w, 9.0):
			v_wz = J.add((-J.n(13.0)), v_w)
			v_wx = J.add(v_ex, (v_yon * (7.0 - (v_w * 0.5))))
			v_ww = (9.0 - (v_w * 0.35))
			game.story_canvas.f_pb((v_wx - v_ww), v_wz, J.add(v_wx, v_ww), J.add(v_wz, 1.0), ("#c2b9a2" if J.lt(v_w, 5.0) else "#8a5230"))
			game.story_canvas.f_pb(J.add((v_wx - v_ww), 1.0), v_wz, (J.add(v_wx, v_ww) - 2.0), J.add(v_wz, 1.0), ("#e4dcc6" if J.lt(v_w, 5.0) else "#a86a3e"))
			v_w = J.add(v_w, 1.0)
		game.story_canvas.f_pbE(J.add(v_ex, (v_yon * 2.0)), (-J.n(2.0)), 12.0, 10.0, "#7a4426")
		game.story_canvas.f_pbE(J.add(v_ex, (v_yon * 1.0)), (-J.n(3.0)), 10.0, 8.0, "#a86a3e")
		game.story_canvas.f_pbE((v_ex - (v_yon * 2.0)), (-J.n(4.0)), 6.0, 5.0, "#c9885a")
		v_boy = [13.0, 20.0, 22.0, 19.0]
		v_j = 0.0
		while J.lt(v_j, 4.0):
			v_fz2 = J.add((-J.n(8.0)), (v_j * 4.8))
			v_fbas = (v_ex - (v_yon * 4.0))
			v_fuc = (v_ex - (v_yon * J.getv(v_boy, v_j)))
			v_f0 = min(v_fbas, v_fuc)
			v_f1 = max(v_fbas, v_fuc)
			game.story_canvas.f_pb(v_f0, (v_fz2 - 2.0), v_f1, J.add(v_fz2, 2.0), "#5e3820")
			game.story_canvas.f_pb(v_f0, (v_fz2 - 1.0), v_f1, J.add(v_fz2, 2.0), ("#a86a3e" if J.truth(fmod(J.n(v_j), J.n(2.0))) else "#c9885a"))
			game.story_canvas.f_pb(J.add(v_f0, 1.0), J.add(v_fz2, 1.0), (v_f1 - 1.0), J.add(v_fz2, 2.0), "#e0a978")
			game.story_canvas.f_pbE(J.add(v_fuc, (v_yon * 2.0)), v_fz2, 2.6, 2.0, "#8a5230")
			game.story_canvas.f_pbE(J.add(v_fuc, (v_yon * 2.0)), J.add(v_fz2, 1.0), 1.8, 1.2, "#f0bd8a")
			game.story_canvas.f_pbE((v_fbas - (v_yon * 2.0)), v_fz2, 3.0, 2.4, "#7a4426")
			game.story_canvas.f_pbE((v_fbas - (v_yon * 2.0)), J.add(v_fz2, 1.0), 2.0, 1.4, "#c9885a")
			v_j = J.add(v_j, 1.0)
		game.story_canvas.f_pbE(J.add(v_ex, (v_yon * 9.0)), (-J.n(11.0)), 7.0, 4.0, "#5e3820")
		game.story_canvas.f_pbE(J.add(v_ex, (v_yon * 8.0)), (-J.n(11.0)), 5.5, 3.0, "#c9885a")
		game.story_canvas.f_pbE(J.add(v_ex, (v_yon * 4.0)), (-J.n(11.0)), 2.6, 2.0, "#e0a978")
		v_i = J.add(v_i, 1.0)
	if J.truth(game.f_chance(0.1)):
		game.effects.f_part({"x": J.add(game.story_canvas.f_pbx(146.0), game.math_utils.f_rnd((-J.n(5.0)), 5.0)), "y": game.story_canvas.f_pby(18.0), "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(16.0)), (-J.n(7.0))), "life": 1.0, "col": "rgba(255,225,180,.30)", "g": (-J.n(10.0)), "sz": 1.0})
	game.story_canvas.f_proCiz("s4on", J.ref(game.story_debt.f_pro4Vinyet, 0))
	return null

