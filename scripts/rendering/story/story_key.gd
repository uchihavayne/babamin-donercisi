# Story key. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:1081
func f_pro5Arka() -> Variant:
	var v_i: Variant = null
	var v_c: Variant = null
	var v_r: Variant = null
	var v_x0: Variant = null
	var v_x1: Variant = null
	var v_h: Variant = null
	var v_gok: Variant = null
	var v_uzak: Variant = null
	var v_kom: Variant = null
	var v_kat: Variant = null
	v_gok = [[72.0, 96.0, "#22305c"], [58.0, 72.0, "#33406c"], [46.0, 58.0, "#4d5478"], [36.0, 46.0, "#6f6180"], [26.0, 36.0, "#9a6f72"], [16.0, 26.0, "#c58a5c"], [6.0, 16.0, "#e0a758"], [(-J.n(62.0)), 6.0, "#f2c877"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_gok, "length")):
		game.story_canvas.f_pb((-J.n(230.0)), J.getv(J.getv(v_gok, v_i), 0.0), 230.0, J.getv(J.getv(v_gok, v_i), 1.0), J.getv(J.getv(v_gok, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE(180.0, 72.0, 30.0, 30.0, "#f6d68a")
	game.story_canvas.f_pbE(180.0, 72.0, 21.0, 21.0, "#fde8b0")
	game.story_canvas.f_pbE(180.0, 72.0, 13.0, 13.0, "#fff6d8")
	v_uzak = [[(-J.n(238.0)), (-J.n(172.0)), 44.0], [(-J.n(178.0)), (-J.n(126.0)), 60.0], [128.0, 192.0, 52.0], [186.0, 238.0, 40.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_uzak, "length")):
		v_x0 = J.getv(J.getv(v_uzak, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_uzak, v_i), 1.0)
		v_h = J.getv(J.getv(v_uzak, v_i), 2.0)
		game.story_canvas.f_pb(v_x0, (-J.n(36.0)), v_x1, v_h, "#4a4258")
		game.story_canvas.f_pb((v_x0 - 2.0), v_h, J.add(v_x1, 2.0), J.add(v_h, 3.0), "#5e5468")
		v_i = J.add(v_i, 1.0)
	v_kom = [[(-J.n(238.0)), (-J.n(144.0))], [144.0, 238.0]]
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_x0 = J.getv(J.getv(v_kom, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_kom, v_i), 1.0)
		game.story_canvas.f_pb(v_x0, (-J.n(36.0)), v_x1, 54.0, "#5a4c4a")
		game.story_canvas.f_pb(v_x0, 54.0, v_x1, 59.0, "#7a6656")
		game.story_canvas.f_pb(v_x0, (-J.n(36.0)), J.add(v_x0, 4.0), 54.0, "#7a6656")
		v_c = 0.0
		while J.lt(v_c, 3.0):
			v_r = 0.0
			while J.lt(v_r, 3.0):
				game.story_canvas.f_pb(J.add(J.add(v_x0, 14.0), (v_c * 28.0)), J.add((-J.n(22.0)), (v_r * 22.0)), J.add(J.add(v_x0, 26.0), (v_c * 28.0)), J.add((-J.n(8.0)), (v_r * 22.0)), "#3a3442")
				v_r = J.add(v_r, 1.0)
			v_c = J.add(v_c, 1.0)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(61.0)), 240.0, (-J.n(48.0)), "#3a3038")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(48.0)), 240.0, (-J.n(42.0)), "#6a6058")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(42.0)), 240.0, (-J.n(40.0)), "#a8a096")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(40.0)), 240.0, (-J.n(38.0)), "#8a8078")
	v_i = 0.0
	while J.lt(v_i, 11.0):
		game.story_canvas.f_pb(J.add((-J.n(224.0)), (v_i * 46.0)), (-J.n(42.0)), J.add((-J.n(223.0)), (v_i * 46.0)), (-J.n(38.0)), "#7a7268")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(136.0)), (-J.n(30.0)), 136.0, 2.0, "#3a2312")
	v_kat = [[(-J.n(30.0)), (-J.n(24.0)), "#a8631f"], [(-J.n(24.0)), (-J.n(18.0)), "#7d4116"], [(-J.n(18.0)), (-J.n(10.0)), "#552c11"], [(-J.n(10.0)), (-J.n(4.0)), "#3a1e0c"], [(-J.n(4.0)), 2.0, "#291406"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_kat, "length")):
		game.story_canvas.f_pb((-J.n(136.0)), J.getv(J.getv(v_kat, v_i), 0.0), 136.0, J.getv(J.getv(v_kat, v_i), 1.0), J.getv(J.getv(v_kat, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(128.0)), (-J.n(8.0)), (-J.n(92.0)), (-J.n(5.0)), "#6b4122")
	v_i = 0.0
	while J.lt(v_i, 5.0):
		game.story_canvas.f_pb(J.add((-J.n(126.0)), (v_i * 7.0)), (-J.n(5.0)), J.add((-J.n(122.0)), (v_i * 7.0)), 1.0, J.getv(["#3f79c0", "#c9302a", "#d8ac35"], fmod(J.n(v_i), J.n(3.0))))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb(30.0, (-J.n(6.0)), 108.0, (-J.n(3.0)), "#6b4122")
	v_i = 0.0
	while J.lt(v_i, 5.0):
		game.story_canvas.f_pb(J.add(38.0, (v_i * 15.0)), (-J.n(12.0)), J.add(40.0, (v_i * 15.0)), (-J.n(6.0)), "#8a929a")
		game.story_canvas.f_pb(J.add(36.0, (v_i * 15.0)), (-J.n(18.0)), J.add(42.0, (v_i * 15.0)), (-J.n(12.0)), "#a5622a")
		game.story_canvas.f_pb(J.add(37.0, (v_i * 15.0)), (-J.n(17.0)), J.add(40.0, (v_i * 15.0)), (-J.n(14.0)), "#d18c42")
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:1131
func f_proKey(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var v_gx: Variant = null
	var v_gy: Variant = null
	var v_gw: Variant = null
	var v_gh: Variant = null
	var v_i: Variant = null
	var v_r: Variant = null
	var v_ac: Variant = null
	var v_alt: Variant = null
	var v_z: Variant = null
	var v_v: Variant = null
	var v_isik: Variant = null
	var v_kal: Variant = null
	var v_fz: Variant = null
	var v_isl: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	# REMAKE kancasi
	if game.f_hdProKey(p_t, p_k): return null
	v_gx = 40.0
	v_gy = 44.0
	v_gw = 400.0
	v_gh = 150.0
	game.story_canvas.f_proCiz("s5a", J.ref(game.story_key.f_pro5Arka, 0))
	game.story_canvas.f_pb((-J.n(75.0)), (-J.n(30.0)), (-J.n(73.0)), 6.0, "#9aa3ab")
	game.story_canvas.f_proSis((-J.n(74.0)), (-J.n(26.0)), 4.0, 9.0, 2.4, v_t)
	v_i = 0.0
	while J.lt(v_i, 5.0):
		game.story_canvas.f_pb(J.add((-J.n(88.0)), (v_i * 6.0)), (-J.n(26.0)), J.add((-J.n(84.0)), (v_i * 6.0)), (-J.n(23.0)), (("#ffb04a" if J.truth(fmod(J.n(v_i), J.n(2.0))) else "#ff7a2a") if J.gt(sin(J.add((v_t * 3.0), v_i)), (-J.n(0.2))) else "#a83a12"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(136.0)), (-J.n(30.0)), 136.0, (-J.n(18.0)), "#6b4122")
	game.story_canvas.f_pb((-J.n(136.0)), (-J.n(19.0)), 136.0, (-J.n(17.0)), "#a8703f")
	v_i = 0.0
	while J.lt(v_i, 9.0):
		game.story_canvas.f_pbA((-J.n(136.0)), J.add((-J.n(30.0)), (v_i * 4.0)), 136.0, J.add((-J.n(26.0)), (v_i * 4.0)), "#ffb04a", (0.13 - (v_i * 0.014)))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(150.0)), (-J.n(38.0)), (-J.n(136.0)), 40.0, "#4a3524")
	game.story_canvas.f_pb(136.0, (-J.n(38.0)), 150.0, 40.0, "#4a3524")
	game.story_canvas.f_pb(144.0, (-J.n(38.0)), 150.0, 40.0, "#33251a")
	game.story_canvas.f_pb((-J.n(150.0)), 34.0, 150.0, 40.0, "#4a3524")
	game.story_canvas.f_pb((-J.n(150.0)), (-J.n(38.0)), (-J.n(136.0)), (-J.n(30.0)), "#33251a")
	game.story_canvas.f_pb(136.0, (-J.n(38.0)), 150.0, (-J.n(30.0)), "#33251a")
	v_i = 0.0
	while J.lt(v_i, 2.0):
		game.story_canvas.f_pb(J.add((-J.n(149.0)), (v_i * 7.0)), (-J.n(37.0)), J.add((-J.n(143.0)), (v_i * 7.0)), (-J.n(31.0)), ("#2f6b62" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#3d8078"))
		game.story_canvas.f_pb(J.add(137.0, (v_i * 7.0)), (-J.n(37.0)), J.add(143.0, (v_i * 7.0)), (-J.n(31.0)), ("#2f6b62" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#3d8078"))
		v_i = J.add(v_i, 1.0)
	v_ac = game.math_utils.f_clamp(((J.getv(game.j_PRO, "t") - 0.4) * 0.55), 0.0, 1.0)
	v_alt = floor(J.add((-J.n(30.0)), (v_ac * 32.0)) + 0.5)
	v_r = 0.0
	while J.lt(J.add((v_r * 3.0), v_alt), 24.0):
		v_z = J.add(v_alt, (v_r * 3.0))
		game.story_canvas.f_pb((-J.n(136.0)), v_z, 136.0, J.add(v_z, 1.0), "#3a4148")
		game.story_canvas.f_pb((-J.n(136.0)), J.add(v_z, 1.0), 136.0, J.add(v_z, 2.0), "#5d6772")
		game.story_canvas.f_pb((-J.n(136.0)), J.add(v_z, 2.0), 136.0, J.add(v_z, 3.0), "#48515a")
		v_r = J.add(v_r, 1.0)
	v_v = (-J.n(132.0))
	while J.lt(v_v, 136.0):
		game.story_canvas.f_pb(v_v, v_alt, J.add(v_v, 2.0), 24.0, "#2f363c")
		v_v = J.add(v_v, 26.0)
	game.story_canvas.f_pb((-J.n(136.0)), (v_alt - 3.0), 136.0, (v_alt - 1.0), "#2a3138")
	game.story_canvas.f_pb((-J.n(136.0)), (v_alt - 1.0), 136.0, J.add(v_alt, 2.0), "#98a2ab")
	game.story_canvas.f_pb((-J.n(140.0)), 24.0, 140.0, 34.0, "#3d464f")
	game.story_canvas.f_pb((-J.n(140.0)), 32.0, 140.0, 34.0, "#5d6772")
	game.story_canvas.f_pb((-J.n(142.0)), (-J.n(30.0)), (-J.n(136.0)), 34.0, "#4a5058")
	game.story_canvas.f_pb(136.0, (-J.n(30.0)), 142.0, 34.0, "#4a5058")
	v_isik = (v_ac * J.add(0.055, (0.01 * sin((v_t * 1.6)))))
	v_r = 0.0
	while J.lt(v_r, 18.0):
		game.story_canvas.f_pbA(((-J.n(136.0)) - (v_r * 3.0)), ((-J.n(33.0)) - (v_r * 0.6)), J.add(136.0, (v_r * 3.0)), ((-J.n(31.0)) - (v_r * 0.6)), "#ffcf7a", v_isik)
		v_r = J.add(v_r, 1.0)
	game.story_canvas.f_pbA((-J.n(140.0)), (v_alt - 4.0), 140.0, J.add(v_alt, 2.0), "#ffd08a", (0.3 * v_ac))
	game.story_canvas.f_pb((-J.n(140.0)), 36.0, 140.0, 62.0, "#7a1a12")
	game.story_canvas.f_pb((-J.n(136.0)), 39.0, 136.0, 59.0, "#a8281c")
	v_i = 0.0
	while J.lt(v_i, 12.0):
		game.story_canvas.f_pb(J.add((-J.n(132.0)), (v_i * 23.0)), 36.0, J.add((-J.n(127.0)), (v_i * 23.0)), 40.0, "#8a7a4a")
		v_i = J.add(v_i, 1.0)
	game.text_draw.f_txt("USTA DÖNER", game.story_canvas.f_pbx(0.0), game.story_canvas.f_pby(55.0), "#e8c070", {"align": "c", "outline": "#7a1a12"})
	v_kal = floor((sin((v_t * 1.5)) * 2.0) + 0.5)
	game.story_canvas.f_pb(150.0, J.add((-J.n(34.0)), v_kal), 240.0, J.add((-J.n(8.0)), v_kal), "#8e2018")
	game.story_canvas.f_pb(150.0, J.add((-J.n(12.0)), v_kal), 240.0, J.add((-J.n(8.0)), v_kal), "#c33c2c")
	game.story_canvas.f_pb(142.0, J.add((-J.n(36.0)), v_kal), 156.0, J.add((-J.n(6.0)), v_kal), "#e4dcc6")
	game.story_canvas.f_pb(142.0, J.add((-J.n(36.0)), v_kal), 156.0, J.add((-J.n(32.0)), v_kal), "#c2b9a2")
	game.story_canvas.f_pbE(128.0, J.add((-J.n(21.0)), v_kal), 17.0, 14.0, "#6f4326")
	game.story_canvas.f_pbE(128.0, J.add((-J.n(21.0)), v_kal), 15.0, 12.0, "#a86a3e")
	game.story_canvas.f_pbE(126.0, J.add((-J.n(22.0)), v_kal), 13.0, 10.0, "#c9885a")
	game.story_canvas.f_pbE(123.0, J.add((-J.n(24.0)), v_kal), 8.0, 6.0, "#e0a978")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		v_fz = J.add(J.add((-J.n(33.0)), (v_i * 7.0)), v_kal)
		game.story_canvas.f_pbE(119.0, J.add(v_fz, 3.0), 10.0, 4.0, "#8a5230")
		game.story_canvas.f_pbE(118.0, J.add(v_fz, 3.0), 8.0, 3.0, ("#c9885a" if J.truth(fmod(J.n(v_i), J.n(2.0))) else "#e0a978"))
		game.story_canvas.f_pb(112.0, v_fz, 128.0, J.add(v_fz, 1.0), "#6f4326")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE(125.0, J.add((-J.n(9.0)), v_kal), 7.0, 5.0, "#8a5230")
	game.story_canvas.f_pbE(124.0, J.add((-J.n(10.0)), v_kal), 5.0, 4.0, "#e0a978")
	v_i = 0.0
	while J.lt(v_i, 7.0):
		game.story_canvas.f_pbA((92.0 - (v_i * 5.0)), J.add(((-J.n(27.0)) - (v_i * 2.0)), v_kal), J.add(100.0, (v_i * 5.0)), J.add(J.add((-J.n(15.0)), (v_i * 2.0)), v_kal), "#fff0b0", 0.1)
		v_i = J.add(v_i, 1.0)
	game.f_ring(game.story_canvas.f_pbx(106.0), game.story_canvas.f_pby(J.add((-J.n(21.0)), v_kal)), 14.0, "#a8811f")
	game.f_ring(game.story_canvas.f_pbx(106.0), game.story_canvas.f_pby(J.add((-J.n(21.0)), v_kal)), 13.0, "#d8ac35")
	game.f_ring(game.story_canvas.f_pbx(106.0), game.story_canvas.f_pby(J.add((-J.n(21.0)), v_kal)), 11.0, "#ffd75e")
	game.f_ring(game.story_canvas.f_pbx(106.0), game.story_canvas.f_pby(J.add((-J.n(21.0)), v_kal)), 10.0, "#a8811f")
	game.story_canvas.f_pb(52.0, J.add((-J.n(25.0)), v_kal), 108.0, J.add((-J.n(18.0)), v_kal), "#a8811f")
	game.story_canvas.f_pb(52.0, J.add((-J.n(24.0)), v_kal), 108.0, J.add((-J.n(20.0)), v_kal), "#ffd75e")
	game.story_canvas.f_pb(52.0, J.add((-J.n(34.0)), v_kal), 62.0, J.add((-J.n(21.0)), v_kal), "#d8ac35")
	game.story_canvas.f_pb(66.0, J.add((-J.n(32.0)), v_kal), 74.0, J.add((-J.n(21.0)), v_kal), "#d8ac35")
	game.story_canvas.f_pb(52.0, J.add((-J.n(21.0)), v_kal), 58.0, J.add((-J.n(14.0)), v_kal), "#a8811f")
	v_isl = [[88.0, (-J.n(6.0))], [118.0, (-J.n(34.0))], [74.0, (-J.n(30.0))]]
	v_i = 0.0
	while J.lt(v_i, 3.0):
		if J.lt(sin(J.add((v_t * 3.2), (v_i * 2.1))), 0.4):
			v_i = J.add(v_i, 1.0)
			continue
		game.story_canvas.f_pb((J.getv(J.getv(v_isl, v_i), 0.0) - 4.0), J.add(J.getv(J.getv(v_isl, v_i), 1.0), v_kal), J.add(J.getv(J.getv(v_isl, v_i), 0.0), 4.0), J.add(J.add(J.getv(J.getv(v_isl, v_i), 1.0), 1.0), v_kal), "#fff6d8")
		game.story_canvas.f_pb(J.getv(J.getv(v_isl, v_i), 0.0), J.add((J.getv(J.getv(v_isl, v_i), 1.0) - 4.0), v_kal), J.add(J.getv(J.getv(v_isl, v_i), 0.0), 1.0), J.add(J.add(J.getv(J.getv(v_isl, v_i), 1.0), 5.0), v_kal), "#fff6d8")
		v_i = J.add(v_i, 1.0)
	if J.truth(game.f_chance(0.16)):
		game.effects.f_part({"x": J.add(game.story_canvas.f_pbx(106.0), game.math_utils.f_rnd((-J.n(14.0)), 14.0)), "y": J.add(game.story_canvas.f_pby((-J.n(21.0))), game.math_utils.f_rnd((-J.n(12.0)), 12.0)), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(14.0)), (-J.n(4.0))), "life": 0.7, "col": J.getv(game.j_P, "au0"), "g": (-J.n(4.0)), "sz": 1.0, "type": "star"})
	game.story_canvas.f_proBirds(v_t, v_gx, v_gy, v_gw, 4.0, 0.12)
	J.setv(game.j_ctx, "globalAlpha", J.add(0.03, (0.012 * sin((v_t * 1.5)))))
	v_i = 0.0
	while J.lt(v_i, 14.0):
		game.f_fr((J.add(v_gx, 320.0) - (v_i * 20.0)), v_gy, 6.0, v_gh, "#ffd75e")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

