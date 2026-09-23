# Story closed. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:752
func f_pro3Arka() -> Variant:
	var v_i: Variant = null
	var v_r: Variant = null
	var v_c: Variant = null
	var v_x0: Variant = null
	var v_x1: Variant = null
	var v_h: Variant = null
	var v_gok: Variant = null
	var v_bul: Variant = null
	var v_uzak: Variant = null
	var v_kom: Variant = null
	var v_z: Variant = null
	var v_v: Variant = null
	var v_pas: Variant = null
	var v_tx: Variant = null
	var v_sk: Variant = null
	var v_gul: Variant = null
	var v_fx: Variant = null
	var v_fz: Variant = null
	v_gok = [[64.0, 96.0, "#121824"], [44.0, 64.0, "#18202f"], [26.0, 44.0, "#1f293b"], [10.0, 26.0, "#273348"], [(-J.n(62.0)), 10.0, "#2f3d55"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_gok, "length")):
		game.story_canvas.f_pb((-J.n(230.0)), J.getv(J.getv(v_gok, v_i), 0.0), 230.0, J.getv(J.getv(v_gok, v_i), 1.0), J.getv(J.getv(v_gok, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	v_bul = [[(-J.n(140.0)), 70.0, 60.0, 9.0], [30.0, 82.0, 74.0, 8.0], [170.0, 64.0, 44.0, 7.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_bul, "length")):
		game.story_canvas.f_pb((J.getv(J.getv(v_bul, v_i), 0.0) - J.getv(J.getv(v_bul, v_i), 2.0)), J.getv(J.getv(v_bul, v_i), 1.0), J.add(J.getv(J.getv(v_bul, v_i), 0.0), J.getv(J.getv(v_bul, v_i), 2.0)), J.add(J.getv(J.getv(v_bul, v_i), 1.0), J.getv(J.getv(v_bul, v_i), 3.0)), "#38455e")
		game.story_canvas.f_pb(J.add((J.getv(J.getv(v_bul, v_i), 0.0) - J.getv(J.getv(v_bul, v_i), 2.0)), 5.0), J.getv(J.getv(v_bul, v_i), 1.0), (J.add(J.getv(J.getv(v_bul, v_i), 0.0), J.getv(J.getv(v_bul, v_i), 2.0)) - 9.0), (J.add(J.getv(J.getv(v_bul, v_i), 1.0), J.getv(J.getv(v_bul, v_i), 3.0)) - 3.0), "#2b3448")
		v_i = J.add(v_i, 1.0)
	v_uzak = [[(-J.n(238.0)), (-J.n(170.0)), 40.0], [(-J.n(176.0)), (-J.n(120.0)), 62.0], [126.0, 190.0, 54.0], [184.0, 238.0, 38.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_uzak, "length")):
		v_x0 = J.getv(J.getv(v_uzak, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_uzak, v_i), 1.0)
		v_h = J.getv(J.getv(v_uzak, v_i), 2.0)
		game.story_canvas.f_pb(v_x0, (-J.n(36.0)), v_x1, v_h, "#1b2432")
		v_r = 0.0
		while J.truth((int(J.n(J.lt(v_r, (float(J.add(v_h, 30.0)) / float(16.0))))) | int(J.n(0.0)))):
			v_c = 0.0
			while J.lt(v_c, max(1.0, (int(J.n((float((v_x1 - v_x0)) / float(18.0)))) | int(J.n(0.0))))):
				game.story_canvas.f_pb(J.add(J.add(v_x0, 7.0), (v_c * 18.0)), J.add((-J.n(26.0)), (v_r * 16.0)), J.add(J.add(v_x0, 14.0), (v_c * 18.0)), J.add((-J.n(17.0)), (v_r * 16.0)), ("#d8a850" if J.eq(fmod(J.n(J.add(J.add((v_r * 3.0), (v_c * 5.0)), v_i)), J.n(7.0)), 0.0) else "#232d3d"))
				v_c = J.add(v_c, 1.0)
			v_r = J.add(v_r, 1.0)
		v_i = J.add(v_i, 1.0)
	v_kom = [[(-J.n(238.0)), (-J.n(142.0))], [142.0, 238.0]]
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_x0 = J.getv(J.getv(v_kom, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_kom, v_i), 1.0)
		game.story_canvas.f_pb(v_x0, (-J.n(36.0)), v_x1, 54.0, "#2a3040")
		game.story_canvas.f_pb(v_x0, 54.0, v_x1, 59.0, "#3a4254")
		v_c = 0.0
		while J.lt(v_c, 3.0):
			v_r = 0.0
			while J.lt(v_r, 3.0):
				game.story_canvas.f_pb(J.add(J.add(v_x0, 14.0), (v_c * 28.0)), J.add((-J.n(22.0)), (v_r * 22.0)), J.add(J.add(v_x0, 26.0), (v_c * 28.0)), J.add((-J.n(8.0)), (v_r * 22.0)), ("#e0b060" if J.eq(fmod(J.n(J.add(J.add(v_c, (v_r * 2.0)), v_i)), J.n(5.0)), 0.0) else "#1c2430"))
				v_r = J.add(v_r, 1.0)
			v_c = J.add(v_c, 1.0)
		game.story_canvas.f_pb(v_x0, 54.0, v_x1, 57.0, "#c8d4e0")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(61.0)), 240.0, (-J.n(48.0)), "#191d25")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(48.0)), 240.0, (-J.n(42.0)), "#20262e")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(42.0)), 240.0, (-J.n(38.0)), "#c8d4e0")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(38.0)), 240.0, (-J.n(36.0)), "#9fb0c2")
	v_i = 0.0
	while J.lt(v_i, 14.0):
		game.story_canvas.f_pb(J.add((-J.n(230.0)), (v_i * 34.0)), (-J.n(52.0)), J.add((-J.n(206.0)), (v_i * 34.0)), (-J.n(50.0)), "#8fa2b6")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(150.0)), (-J.n(38.0)), 150.0, 40.0, "#33251a")
	game.story_canvas.f_pb(140.0, (-J.n(38.0)), 150.0, 40.0, "#241a12")
	game.story_canvas.f_pb((-J.n(150.0)), (-J.n(38.0)), 150.0, (-J.n(30.0)), "#241a12")
	v_i = 0.0
	while J.lt(v_i, 38.0):
		game.story_canvas.f_pb(J.add((-J.n(148.0)), (v_i * 8.0)), (-J.n(37.0)), J.add((-J.n(142.0)), (v_i * 8.0)), (-J.n(31.0)), ("#22453f" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#2b544e"))
		v_i = J.add(v_i, 1.0)
	v_r = 0.0
	while J.lt(v_r, 18.0):
		v_z = J.add((-J.n(30.0)), (v_r * 3.0))
		game.story_canvas.f_pb((-J.n(136.0)), v_z, 136.0, J.add(v_z, 1.0), "#2a3138")
		game.story_canvas.f_pb((-J.n(136.0)), J.add(v_z, 1.0), 136.0, J.add(v_z, 2.0), "#4b555f")
		game.story_canvas.f_pb((-J.n(136.0)), J.add(v_z, 2.0), 136.0, J.add(v_z, 3.0), "#39424a")
		v_r = J.add(v_r, 1.0)
	v_v = (-J.n(132.0))
	while J.lt(v_v, 136.0):
		game.story_canvas.f_pb(v_v, (-J.n(30.0)), J.add(v_v, 2.0), 24.0, "#232a30")
		v_v = J.add(v_v, 26.0)
	v_pas = [[(-J.n(96.0)), (-J.n(12.0)), 14.0, 8.0], [34.0, 6.0, 10.0, 6.0], [88.0, (-J.n(22.0)), 18.0, 5.0], [(-J.n(40.0)), 14.0, 9.0, 7.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_pas, "length")):
		game.story_canvas.f_pb(J.getv(J.getv(v_pas, v_i), 0.0), J.getv(J.getv(v_pas, v_i), 1.0), J.add(J.getv(J.getv(v_pas, v_i), 0.0), J.getv(J.getv(v_pas, v_i), 2.0)), J.add(J.getv(J.getv(v_pas, v_i), 1.0), J.getv(J.getv(v_pas, v_i), 3.0)), "#6b4526")
		game.story_canvas.f_pb(J.add(J.getv(J.getv(v_pas, v_i), 0.0), 2.0), J.add(J.getv(J.getv(v_pas, v_i), 1.0), 1.0), (J.add(J.getv(J.getv(v_pas, v_i), 0.0), J.getv(J.getv(v_pas, v_i), 2.0)) - 3.0), (J.add(J.getv(J.getv(v_pas, v_i), 1.0), J.getv(J.getv(v_pas, v_i), 3.0)) - 2.0), "#8a5a30")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(140.0)), 24.0, 140.0, 34.0, "#3d464f")
	game.story_canvas.f_pb((-J.n(140.0)), 32.0, 140.0, 34.0, "#5d6772")
	game.story_canvas.f_pb((-J.n(136.0)), (-J.n(32.0)), 136.0, (-J.n(30.0)), "#5d6772")
	game.story_canvas.f_pb((-J.n(14.0)), (-J.n(30.0)), (-J.n(6.0)), (-J.n(14.0)), "#5d6772")
	game.story_canvas.f_pb(6.0, (-J.n(30.0)), 14.0, (-J.n(14.0)), "#5d6772")
	game.story_canvas.f_pb((-J.n(14.0)), (-J.n(30.0)), (-J.n(12.0)), (-J.n(14.0)), "#2f363c")
	game.story_canvas.f_pb(12.0, (-J.n(30.0)), 14.0, (-J.n(14.0)), "#2f363c")
	game.f_ring(game.story_canvas.f_pbx(0.0), game.story_canvas.f_pby((-J.n(14.0))), 8.0, "#98a2ab")
	game.f_ring(game.story_canvas.f_pbx(0.0), game.story_canvas.f_pby((-J.n(14.0))), 7.0, "#6f7880")
	game.story_canvas.f_pbA((-J.n(14.0)), (-J.n(36.0)), 16.0, (-J.n(30.0)), "#000000", 0.45)
	game.story_canvas.f_pbE(0.0, (-J.n(24.0)), 12.0, 10.0, "#4d545c")
	game.story_canvas.f_pbE((-J.n(2.0)), (-J.n(25.0)), 10.0, 8.0, "#98a2ab")
	game.story_canvas.f_pbE((-J.n(4.0)), (-J.n(26.0)), 6.0, 5.0, "#c6ced5")
	game.story_canvas.f_pb((-J.n(2.0)), (-J.n(28.0)), 2.0, (-J.n(24.0)), "#12161a")
	game.story_canvas.f_pb((-J.n(1.0)), (-J.n(31.0)), 1.0, (-J.n(27.0)), "#12161a")
	game.story_canvas.f_pb((-J.n(140.0)), 36.0, 140.0, 62.0, "#3a1410")
	game.story_canvas.f_pb((-J.n(136.0)), 39.0, 136.0, 59.0, "#521a14")
	v_i = 0.0
	while J.lt(v_i, 12.0):
		game.story_canvas.f_pb(J.add((-J.n(132.0)), (v_i * 23.0)), 36.0, J.add((-J.n(127.0)), (v_i * 23.0)), 40.0, ("#2b2620" if ((J.eq(v_i, 2.0) or J.eq(v_i, 5.0)) or J.eq(v_i, 9.0)) else "#4a4438"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(140.0)), 62.0, 140.0, 65.0, "#c8d4e0")
	v_i = 0.0
	while J.lt(v_i, 13.0):
		v_tx = J.add((-J.n(80.0)), (v_i * 12.0))
		v_sk = (0.0 if ((J.eq(v_i, 5.0) or J.eq(v_i, 6.0)) or J.eq(v_i, 7.0)) else 1.0)
		game.story_canvas.f_pb(v_tx, (28.0 - (0.0 if J.truth(v_sk) else 8.0)), J.add(v_tx, 12.0), (35.0 - (0.0 if J.truth(v_sk) else 6.0)), ("#6b1a14" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#8a8478"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(80.0)), 33.0, 76.0, 36.0, "#c8d4e0")
	game.story_canvas.f_pb((-J.n(168.0)), (-J.n(38.0)), (-J.n(156.0)), (-J.n(26.0)), "#3a3f48")
	v_gul = [[(-J.n(167.0)), (-J.n(14.0))], [(-J.n(161.0)), (-J.n(8.0))], [(-J.n(155.0)), (-J.n(16.0))]]
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_fx = J.getv(J.getv(v_gul, v_i), 0.0)
		v_fz = J.getv(J.getv(v_gul, v_i), 1.0)
		game.story_canvas.f_pb(v_fx, (-J.n(26.0)), J.add(v_fx, 2.0), v_fz, "#2f4a2a")
		game.story_canvas.f_pb((v_fx - 4.0), (v_fz - 8.0), J.add(v_fx, 1.0), (v_fz - 6.0), "#2f4a2a")
		game.story_canvas.f_pb((v_fx - 5.0), v_fz, J.add(v_fx, 7.0), J.add(v_fz, 8.0), "#8e2018")
		game.story_canvas.f_pb((v_fx - 3.0), J.add(v_fz, 2.0), J.add(v_fx, 5.0), J.add(v_fz, 7.0), "#c33c2c")
		game.story_canvas.f_pb((v_fx - 2.0), J.add(v_fz, 5.0), J.add(v_fx, 3.0), J.add(v_fz, 7.0), "#e2604f")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(146.0)), (-J.n(38.0)), (-J.n(140.0)), (-J.n(26.0)), "#d8d2c0")
	game.story_canvas.f_pb((-J.n(141.0)), (-J.n(38.0)), (-J.n(140.0)), (-J.n(26.0)), "#9e9888")
	game.story_canvas.f_pb((-J.n(206.0)), (-J.n(42.0)), (-J.n(200.0)), 66.0, "#12161c")
	v_i = 0.0
	while J.lt(v_i, 9.0):
		game.story_canvas.f_pb(J.add((-J.n(200.0)), (v_i * 4.0)), (66.0 - (v_i * 0.9)), J.add((-J.n(194.0)), (v_i * 4.0)), (68.0 - (v_i * 0.9)), "#12161c")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(170.0)), 54.0, (-J.n(156.0)), 60.0, "#1a1f26")
	game.story_canvas.f_pb((-J.n(168.0)), 55.0, (-J.n(158.0)), 58.0, "#ffe6a8")
	v_r = 0.0
	while J.lt(v_r, 16.0):
		game.story_canvas.f_pbA(((-J.n(178.0)) - (v_r * 2.6)), (52.0 - (v_r * 6.0)), J.add((-J.n(148.0)), (v_r * 2.6)), (56.0 - (v_r * 6.0)), "#cfe0ff", 0.03)
		v_r = J.add(v_r, 1.0)
	return null

# prologue.js:866
func f_proClosed(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var v_gx: Variant = null
	var v_gy: Variant = null
	var v_gw: Variant = null
	var v_gh: Variant = null
	var v_i: Variant = null
	var v_kalk: Variant = null
	var v_alev: Variant = null
	var v_kx: Variant = null
	var v_ky: Variant = null
	var v_b: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	v_gx = 40.0
	v_gy = 44.0
	v_gw = 400.0
	v_gh = 150.0
	game.story_canvas.f_proCiz("s3a", J.ref(game.story_closed.f_pro3Arka, 0))
	v_kalk = (max(0.0, sin((v_t * 1.1))) * 3.0)
	game.story_canvas.f_pb((-J.n(84.0)), (-J.n(8.0)), (-J.n(58.0)), 16.0, "#cfc7b2")
	game.story_canvas.f_pb((-J.n(84.0)), (-J.n(8.0)), (-J.n(80.0)), 16.0, "#b0a894")
	game.story_canvas.f_pb((-J.n(84.0)), 13.0, (-J.n(58.0)), 16.0, "#e8e2d0")
	game.story_canvas.f_pb((-J.n(80.0)), 10.0, (-J.n(62.0)), 13.0, "#8a2018")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.story_canvas.f_pb((-J.n(80.0)), (4.0 - (v_i * 4.0)), J.add((-J.n(66.0)), (fmod(J.n(v_i), J.n(2.0)) * 4.0)), (5.0 - (v_i * 4.0)), "#6b6558")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb(((-J.n(64.0)) - v_kalk), (-J.n(8.0)), (-J.n(58.0)), J.add((-J.n(3.0)), v_kalk), "#8a8474")
	game.story_canvas.f_pb((-J.n(87.0)), 13.0, (-J.n(79.0)), 17.0, "#d8d2c0")
	game.story_canvas.f_pb((-J.n(63.0)), 13.0, (-J.n(55.0)), 17.0, "#d8d2c0")
	v_alev = floor(J.add((sin((v_t * 9.0)) * 0.5), (sin((v_t * 5.3)) * 0.5)) + 0.5)
	game.story_canvas.f_pb((-J.n(144.0)), (-J.n(26.0)), (-J.n(142.0)), J.add((-J.n(21.0)), v_alev), "#ffd75e")
	game.story_canvas.f_pb((-J.n(144.0)), (-J.n(24.0)), (-J.n(143.0)), J.add((-J.n(22.0)), v_alev), "#fff6d8")
	v_i = 0.0
	while J.lt(v_i, 7.0):
		game.story_canvas.f_pbA(((-J.n(147.0)) - (v_i * 2.0)), ((-J.n(30.0)) - (v_i * 1.5)), J.add((-J.n(139.0)), (v_i * 2.0)), J.add((-J.n(20.0)), (v_i * 2.0)), "#ffb04a", J.add(0.055, (0.012 * sin(J.add((v_t * 6.0), v_i)))))
		v_i = J.add(v_i, 1.0)
	v_i = 0.0
	while J.lt(v_i, 70.0):
		v_kx = J.add(v_gx, fmod(J.n(J.add(J.add((game.f_hash1((v_i * 3.1)) * v_gw), (sin(J.add((v_t * 0.5), v_i)) * 14.0)), (v_t * 9.0))), J.n(v_gw)))
		v_ky = J.add(v_gy, fmod(J.n(J.add((game.f_hash1((v_i * 7.7)) * v_gh), (v_t * J.add(16.0, (game.f_hash1(v_i) * 26.0))))), J.n(v_gh)))
		v_b = (2.0 if J.eq(fmod(J.n(v_i), J.n(5.0)), 0.0) else 1.0)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (game.f_hash1((v_i * 2.3)) * 0.4)))
		game.f_fr(v_kx, v_ky, v_b, v_b, "#eaf2ff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (0.04 * sin((v_t * 0.7)))))
	game.f_fr(v_gx, (J.add(v_gy, v_gh) - 22.0), v_gw, 4.0, "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

