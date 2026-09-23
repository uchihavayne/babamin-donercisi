# Story shop. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:161
func f_pro1Arka() -> Variant:
	var v_i: Variant = null
	var v_r: Variant = null
	var v_c: Variant = null
	var v_x0: Variant = null
	var v_x1: Variant = null
	var v_h: Variant = null
	var v_wx: Variant = null
	var v_wz: Variant = null
	var v_B: Variant = null
	var v_gok: Variant = null
	var v_bul: Variant = null
	var v_U1: Variant = null
	var v_U2: Variant = null
	var v_U3: Variant = null
	var v_uzak: Variant = null
	var v_mx: Variant = null
	var v_O1: Variant = null
	var v_O2: Variant = null
	var v_O3: Variant = null
	var v_O4: Variant = null
	var v_orta: Variant = null
	var v_ax: Variant = null
	var v_Y1: Variant = null
	var v_Y2: Variant = null
	var v_Y3: Variant = null
	var v_Y4: Variant = null
	var v_Y5: Variant = null
	var v_yak: Variant = null
	var v_n: Variant = null
	var v_b2: Variant = null
	var v_kat: Variant = null
	var v_lmb: Variant = null
	var v_lx: Variant = null
	v_gok = [[72.0, 96.0, "#5e8fbc"], [56.0, 72.0, "#72a2c9"], [42.0, 56.0, "#8ab7d6"], [28.0, 42.0, "#a4cbdf"], [14.0, 28.0, "#c0dbe4"], [0.0, 14.0, "#dbe4d8"], [(-J.n(62.0)), 0.0, "#f0e0bc"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_gok, "length")):
		game.story_canvas.f_pb((-J.n(230.0)), J.getv(J.getv(v_gok, v_i), 0.0), 230.0, J.getv(J.getv(v_gok, v_i), 1.0), J.getv(J.getv(v_gok, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE(150.0, 74.0, 22.0, 22.0, "#f6e6bc")
	game.story_canvas.f_pbE(150.0, 74.0, 15.0, 15.0, "#fdf2d2")
	game.story_canvas.f_pbE(150.0, 74.0, 9.0, 9.0, "#fffbe8")
	v_bul = [[(-J.n(150.0)), 70.0, 44.0, 7.0, "#e8f2f6", "#c2d8e6"], [(-J.n(58.0)), 80.0, 30.0, 6.0, "#e8f2f6", "#c2d8e6"], [54.0, 84.0, 40.0, 6.0, "#f0f6f8", "#cadfea"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_bul, "length")):
		v_B = J.getv(v_bul, v_i)
		game.story_canvas.f_pb((J.getv(v_B, 0.0) - J.getv(v_B, 2.0)), J.getv(v_B, 1.0), J.add(J.getv(v_B, 0.0), J.getv(v_B, 2.0)), J.add(J.getv(v_B, 1.0), J.getv(v_B, 3.0)), J.getv(v_B, 4.0))
		game.story_canvas.f_pb(J.add((J.getv(v_B, 0.0) - J.getv(v_B, 2.0)), 4.0), J.getv(v_B, 1.0), (J.add(J.getv(v_B, 0.0), J.getv(v_B, 2.0)) - 8.0), (J.add(J.getv(v_B, 1.0), J.getv(v_B, 3.0)) - 3.0), J.getv(v_B, 5.0))
		v_i = J.add(v_i, 1.0)
	v_U1 = "#9db6c6"
	v_U2 = "#8aa7ba"
	v_U3 = "#b2c6d2"
	v_uzak = [[(-J.n(238.0)), (-J.n(186.0)), 30.0], [(-J.n(192.0)), (-J.n(150.0)), 48.0], [(-J.n(156.0)), (-J.n(112.0)), 24.0], [(-J.n(118.0)), (-J.n(70.0)), 40.0], [(-J.n(76.0)), (-J.n(30.0)), 20.0], [(-J.n(36.0)), 14.0, 34.0], [10.0, 56.0, 16.0], [52.0, 104.0, 38.0], [98.0, 148.0, 26.0], [142.0, 196.0, 44.0], [188.0, 238.0, 22.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_uzak, "length")):
		v_x0 = J.getv(J.getv(v_uzak, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_uzak, v_i), 1.0)
		v_h = J.getv(J.getv(v_uzak, v_i), 2.0)
		game.story_canvas.f_pb(v_x0, (-J.n(40.0)), v_x1, v_h, v_U1)
		game.story_canvas.f_pb((v_x0 - 2.0), v_h, J.add(v_x1, 2.0), J.add(v_h, 3.0), v_U3)
		v_r = 0.0
		while J.truth((int(J.n(J.lt(v_r, (float(J.add(v_h, 34.0)) / float(13.0))))) | int(J.n(0.0)))):
			v_c = 0.0
			while J.lt(v_c, max(1.0, (int(J.n((float((v_x1 - v_x0)) / float(12.0)))) | int(J.n(0.0))))):
				game.story_canvas.f_pb(J.add(J.add(v_x0, 5.0), (v_c * 12.0)), J.add((-J.n(34.0)), (v_r * 13.0)), J.add(J.add(v_x0, 10.0), (v_c * 12.0)), J.add((-J.n(28.0)), (v_r * 13.0)), v_U2)
				v_c = J.add(v_c, 1.0)
			v_r = J.add(v_r, 1.0)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE(128.0, 44.0, 26.0, 22.0, v_U3)
	game.story_canvas.f_pb(98.0, 36.0, 158.0, 46.0, v_U1)
	game.story_canvas.f_pb(126.0, 62.0, 130.0, 72.0, v_U3)
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_mx = (156.0 if J.truth(v_i) else 102.0)
		game.story_canvas.f_pb((v_mx - 3.0), 36.0, J.add(v_mx, 3.0), 84.0, v_U3)
		game.story_canvas.f_pb((v_mx - 5.0), 76.0, J.add(v_mx, 5.0), 80.0, v_U1)
		game.story_canvas.f_pb((v_mx - 2.0), 84.0, J.add(v_mx, 2.0), 92.0, v_U3)
		v_i = J.add(v_i, 1.0)
	v_O1 = "#7d838a"
	v_O2 = "#686e75"
	v_O3 = "#949aa0"
	v_O4 = "#4a5663"
	v_orta = [[(-J.n(236.0)), (-J.n(168.0)), 28.0], [(-J.n(172.0)), (-J.n(104.0)), 52.0], [(-J.n(108.0)), (-J.n(50.0)), 20.0], [42.0, 96.0, 44.0], [100.0, 158.0, 26.0], [162.0, 236.0, 50.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_orta, "length")):
		v_x0 = J.getv(J.getv(v_orta, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_orta, v_i), 1.0)
		v_h = J.getv(J.getv(v_orta, v_i), 2.0)
		game.story_canvas.f_pb(v_x0, (-J.n(40.0)), v_x1, v_h, v_O1)
		game.story_canvas.f_pb((v_x1 - 7.0), (-J.n(40.0)), v_x1, v_h, v_O2)
		game.story_canvas.f_pb(v_x0, (-J.n(40.0)), J.add(v_x0, 4.0), v_h, v_O3)
		game.story_canvas.f_pb((v_x0 - 3.0), v_h, J.add(v_x1, 3.0), J.add(v_h, 4.0), v_O3)
		game.story_canvas.f_pb((v_x0 - 3.0), (v_h - 2.0), J.add(v_x1, 3.0), v_h, v_O2)
		v_r = 0.0
		while J.truth((int(J.n(J.lt(v_r, (float(J.add(v_h, 36.0)) / float(15.0))))) | int(J.n(0.0)))):
			v_c = 0.0
			while J.lt(v_c, max(1.0, (int(J.n((float((v_x1 - v_x0)) / float(15.0)))) | int(J.n(0.0))))):
				v_wx = J.add(J.add(v_x0, 6.0), (v_c * 15.0))
				v_wz = J.add((-J.n(32.0)), (v_r * 15.0))
				if J.gt(J.add(v_wz, 9.0), (v_h - 6.0)):
					v_c = J.add(v_c, 1.0)
					continue
				game.story_canvas.f_pb(v_wx, v_wz, J.add(v_wx, 7.0), J.add(v_wz, 9.0), v_O4)
				game.story_canvas.f_pb((v_wx - 1.0), (v_wz - 2.0), J.add(v_wx, 8.0), v_wz, v_O3)
				v_c = J.add(v_c, 1.0)
			v_r = J.add(v_r, 1.0)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(150.0)), 52.0, (-J.n(128.0)), 66.0, v_O2)
	game.story_canvas.f_pb((-J.n(146.0)), 46.0, (-J.n(143.0)), 52.0, v_O2)
	game.story_canvas.f_pb((-J.n(135.0)), 46.0, (-J.n(132.0)), 52.0, v_O2)
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_ax = (198.0 if J.truth(v_i) else 180.0)
		game.story_canvas.f_pb(v_ax, 50.0, J.add(v_ax, 2.0), 64.0, v_O2)
		game.story_canvas.f_pb((v_ax - 5.0), 61.0, J.add(v_ax, 7.0), 63.0, v_O2)
		v_i = J.add(v_i, 1.0)
	v_Y1 = "#6b6152"
	v_Y2 = "#544c40"
	v_Y3 = "#8a8070"
	v_Y4 = "#2c3742"
	v_Y5 = "#e8bd72"
	v_yak = [[(-J.n(236.0)), (-J.n(100.0)), 38.0], [100.0, 236.0, 34.0]]
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_x0 = J.getv(J.getv(v_yak, v_i), 0.0)
		v_x1 = J.getv(J.getv(v_yak, v_i), 1.0)
		v_h = J.getv(J.getv(v_yak, v_i), 2.0)
		game.story_canvas.f_pb(v_x0, (-J.n(38.0)), v_x1, v_h, v_Y1)
		game.story_canvas.f_pb(v_x0, v_h, v_x1, J.add(v_h, 5.0), v_Y3)
		game.story_canvas.f_pb(v_x0, (v_h - 3.0), v_x1, v_h, v_Y2)
		game.story_canvas.f_pb(v_x0, (-J.n(38.0)), J.add(v_x0, 3.0), v_h, v_Y3)
		game.story_canvas.f_pb((v_x1 - 6.0), (-J.n(38.0)), v_x1, v_h, v_Y2)
		game.story_canvas.f_pb(v_x0, (-J.n(8.0)), v_x1, (-J.n(6.0)), v_Y2)
		game.story_canvas.f_pb(v_x0, (-J.n(38.0)), v_x1, (-J.n(28.0)), v_Y2)
		v_n = (int(J.n((float((v_x1 - v_x0)) / float(30.0)))) | int(J.n(0.0)))
		v_c = 0.0
		while J.lt(v_c, v_n):
			v_r = 0.0
			while J.lt(v_r, 2.0):
				v_wx = J.add(J.add(v_x0, 12.0), (v_c * 30.0))
				v_wz = J.add((-J.n(24.0)), (v_r * 20.0))
				game.story_canvas.f_pb(v_wx, v_wz, J.add(v_wx, 12.0), J.add(v_wz, 13.0), (v_Y5 if J.eq(fmod(J.n(J.add(J.add(v_c, (v_r * 3.0)), v_i)), J.n(4.0)), 0.0) else v_Y4))
				game.story_canvas.f_pb(J.add(v_wx, 5.0), v_wz, J.add(v_wx, 7.0), J.add(v_wz, 13.0), v_Y2)
				game.story_canvas.f_pb((v_wx - 2.0), J.add(v_wz, 13.0), J.add(v_wx, 14.0), J.add(v_wz, 15.0), v_Y3)
				if J.eq(v_r, 1.0):
					v_b2 = 0.0
					while J.lt(v_b2, 5.0):
						game.story_canvas.f_pb(J.add((v_wx - 1.0), (v_b2 * 3.0)), (v_wz - 7.0), J.add(v_wx, (v_b2 * 3.0)), (v_wz - 1.0), v_Y2)
						v_b2 = J.add(v_b2, 1.0)
					game.story_canvas.f_pb((v_wx - 3.0), (v_wz - 1.0), J.add(v_wx, 15.0), J.add(v_wz, 1.0), v_Y3)
				v_r = J.add(v_r, 1.0)
			v_c = J.add(v_c, 1.0)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(61.0)), 240.0, (-J.n(48.0)), "#3b4046")
	v_i = 0.0
	while J.lt(v_i, 10.0):
		game.story_canvas.f_pb(J.add((-J.n(224.0)), (v_i * 48.0)), (-J.n(57.0)), J.add((-J.n(200.0)), (v_i * 48.0)), (-J.n(55.0)), "#c9c093")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(48.0)), 240.0, (-J.n(42.0)), "#6d6d64")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(42.0)), 240.0, (-J.n(40.0)), "#adada0")
	game.story_canvas.f_pb((-J.n(240.0)), (-J.n(40.0)), 240.0, (-J.n(38.0)), "#8f8f84")
	v_i = 0.0
	while J.lt(v_i, 11.0):
		game.story_canvas.f_pb(J.add((-J.n(224.0)), (v_i * 46.0)), (-J.n(42.0)), J.add((-J.n(223.0)), (v_i * 46.0)), (-J.n(38.0)), "#7c7c72")
		v_i = J.add(v_i, 1.0)
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.story_canvas.f_pb(J.add(128.0, (v_i * 5.0)), (-J.n(50.0)), J.add(130.0, (v_i * 5.0)), (-J.n(43.0)), "#4a4a44")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(86.0)), (-J.n(32.0)), 86.0, 24.0, "#20130c")
	v_kat = [[(-J.n(32.0)), (-J.n(18.0)), "#4a2e18"], [(-J.n(18.0)), (-J.n(4.0)), "#3a2313"], [(-J.n(4.0)), 10.0, "#2e1c10"], [10.0, 24.0, "#241509"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_kat, "length")):
		game.story_canvas.f_pb((-J.n(86.0)), J.getv(J.getv(v_kat, v_i), 0.0), 86.0, J.getv(J.getv(v_kat, v_i), 1.0), J.getv(J.getv(v_kat, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(80.0)), 0.0, (-J.n(16.0)), 3.0, "#6b4122")
	v_i = 0.0
	while J.lt(v_i, 8.0):
		game.story_canvas.f_pb(J.add((-J.n(76.0)), (v_i * 7.0)), 3.0, J.add((-J.n(72.0)), (v_i * 7.0)), 11.0, J.getv(["#3f79c0", "#c9302a", "#d8ac35"], fmod(J.n(v_i), J.n(3.0))))
		v_i = J.add(v_i, 1.0)
	v_lmb = [(-J.n(56.0)), (-J.n(6.0)), 46.0]
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_lx = J.getv(v_lmb, v_i)
		game.story_canvas.f_pb((v_lx - 1.0), 16.0, J.add(v_lx, 1.0), 24.0, "#2b2018")
		game.story_canvas.f_pb((v_lx - 6.0), 11.0, J.add(v_lx, 6.0), 16.0, "#4a3a28")
		game.story_canvas.f_pb((v_lx - 5.0), 11.0, J.add(v_lx, 5.0), 13.0, "#ffe6a8")
		game.story_canvas.f_pbA((v_lx - 15.0), (-J.n(2.0)), J.add(v_lx, 15.0), 13.0, "#ffcf7a", 0.22)
		game.story_canvas.f_pbA((v_lx - 9.0), (-J.n(14.0)), J.add(v_lx, 9.0), 12.0, "#ffb84a", 0.16)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(68.0)), (-J.n(22.0)), (-J.n(36.0)), (-J.n(16.0)), "#3a3a40")
	return null

# prologue.js:288
func f_pro1Ocak(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_kor: Variant = null
	var v_bx: Variant = null
	var v_kol: Variant = null
	var v_t: Variant = p_t
	v_i = 0.0
	while J.lt(v_i, 5.0):
		v_kor = J.gt(sin(J.add((v_t * 3.0), (v_i * 1.7))), (-J.n(0.2)))
		game.story_canvas.f_pb(J.add((-J.n(66.0)), (v_i * 6.0)), (-J.n(21.0)), J.add((-J.n(62.0)), (v_i * 6.0)), (-J.n(18.0)), (("#ffb04a" if J.truth(fmod(J.n(v_i), J.n(2.0))) else "#ff7a2a") if J.truth(v_kor) else "#a83a12"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbA((-J.n(76.0)), (-J.n(26.0)), (-J.n(28.0)), 22.0, "#ff9a3a", J.add(0.18, (0.05 * sin((v_t * 2.1)))))
	game.story_canvas.f_pbA((-J.n(86.0)), (-J.n(32.0)), 86.0, (-J.n(22.0)), "#ffb84a", 0.1)
	v_bx = 4.0
	v_kol = floor((sin((v_t * 1.9)) * 2.0) + 0.5)
	game.story_canvas.f_pb((v_bx - 12.0), (-J.n(19.0)), J.add(v_bx, 12.0), 6.0, "#a8281c")
	game.story_canvas.f_pb((v_bx - 8.0), (-J.n(19.0)), J.add(v_bx, 8.0), 3.0, "#e4dcc6")
	game.story_canvas.f_pb(J.add(v_bx, 11.0), J.add((-J.n(8.0)), v_kol), J.add(v_bx, 22.0), J.add(1.0, v_kol), "#a8281c")
	game.story_canvas.f_pb(J.add(v_bx, 20.0), J.add((-J.n(10.0)), v_kol), J.add(v_bx, 26.0), J.add((-J.n(4.0)), v_kol), "#e0a978")
	game.story_canvas.f_pb((v_bx - 7.0), 6.0, J.add(v_bx, 7.0), 18.0, "#e0a978")
	game.story_canvas.f_pb((v_bx - 5.0), 9.0, J.add(v_bx, 5.0), 11.0, "#ddd6c8")
	if J.gt(fmod(J.n((v_t * 0.7)), J.n(4.0)), 0.12):
		game.story_canvas.f_pb((v_bx - 4.0), 12.0, (v_bx - 2.0), 14.0, "#2b2018")
		game.story_canvas.f_pb(J.add(v_bx, 2.0), 12.0, J.add(v_bx, 4.0), 14.0, "#2b2018")
	else:
		game.story_canvas.f_pb((v_bx - 4.0), 12.0, (v_bx - 2.0), 13.0, "#c9885a")
		game.story_canvas.f_pb(J.add(v_bx, 2.0), 12.0, J.add(v_bx, 4.0), 13.0, "#c9885a")
	game.story_canvas.f_pb((v_bx - 8.0), 18.0, J.add(v_bx, 8.0), 24.0, "#c9302a")
	game.story_canvas.f_pb((v_bx - 9.0), 17.0, J.add(v_bx, 9.0), 18.0, "#7a1a12")
	game.story_canvas.f_pb((-J.n(86.0)), (-J.n(32.0)), 86.0, (-J.n(18.0)), "#6b4122")
	game.story_canvas.f_pb((-J.n(86.0)), (-J.n(19.0)), 86.0, (-J.n(17.0)), "#a8703f")
	game.story_canvas.f_pb((-J.n(30.0)), (-J.n(32.0)), 22.0, (-J.n(21.0)), "#456a7a")
	v_i = 0.0
	while J.lt(v_i, 6.0):
		game.story_canvas.f_pb(J.add((-J.n(27.0)), (v_i * 8.0)), (-J.n(30.0)), J.add((-J.n(22.0)), (v_i * 8.0)), (-J.n(26.0)), J.getv(["#c9302a", "#3f8a4a", "#d8ac35"], fmod(J.n(v_i), J.n(3.0))))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(53.0)), (-J.n(27.0)), (-J.n(51.0)), 28.0, "#9aa3ab")
	game.story_canvas.f_proSis((-J.n(52.0)), (-J.n(22.0)), 18.0, 11.0, 2.8, v_t)
	if J.truth(game.f_chance(0.3)):
		game.effects.f_part({"x": J.add(game.story_canvas.f_pbx((-J.n(52.0))), game.math_utils.f_rnd((-J.n(7.0)), 7.0)), "y": game.story_canvas.f_pby(16.0), "vx": game.math_utils.f_rnd((-J.n(5.0)), 5.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(9.0))), "life": 1.1, "col": "rgba(255,235,205,.35)", "g": (-J.n(14.0)), "sz": 1.0})
	return null

# prologue.js:331
func f_pro1On() -> Variant:
	var v_i: Variant = null
	var v_x0: Variant = null
	var v_AH1: Variant = null
	var v_AH2: Variant = null
	var v_AH3: Variant = null
	var v_AH4: Variant = null
	var v_tc: Variant = null
	game.story_canvas.f_pbA((-J.n(84.0)), (-J.n(30.0)), 84.0, 22.0, "#8fb8cc", 0.07)
	game.story_canvas.f_pbA((-J.n(84.0)), 8.0, 84.0, 22.0, "#12283a", 0.3)
	game.story_shop.f_proYansima((-J.n(76.0)), (-J.n(4.0)), 4.0, 74.0, 0.15)
	game.story_shop.f_proYansima((-J.n(69.0)), (-J.n(4.0)), 2.0, 74.0, 0.11)
	game.story_shop.f_proYansima(64.0, (-J.n(4.0)), 3.0, 72.0, 0.13)
	game.story_shop.f_proYansima(71.0, (-J.n(4.0)), 2.0, 72.0, 0.09)
	v_AH1 = "#5a3418"
	v_AH2 = "#7a4a24"
	v_AH3 = "#9a6634"
	v_AH4 = "#3d2210"
	game.story_canvas.f_pb((-J.n(98.0)), (-J.n(38.0)), (-J.n(84.0)), 34.0, v_AH2)
	game.story_canvas.f_pb((-J.n(98.0)), (-J.n(38.0)), (-J.n(95.0)), 34.0, v_AH3)
	game.story_canvas.f_pb(84.0, (-J.n(38.0)), 98.0, 34.0, v_AH2)
	game.story_canvas.f_pb(93.0, (-J.n(38.0)), 98.0, 34.0, v_AH1)
	game.story_canvas.f_pb((-J.n(98.0)), 22.0, 98.0, 34.0, v_AH2)
	game.story_canvas.f_pb((-J.n(98.0)), 32.0, 98.0, 34.0, v_AH3)
	game.story_canvas.f_pb((-J.n(98.0)), 22.0, 98.0, 24.0, v_AH1)
	game.story_canvas.f_pb((-J.n(98.0)), (-J.n(38.0)), 98.0, (-J.n(30.0)), v_AH4)
	v_i = 0.0
	while J.lt(v_i, 25.0):
		game.story_canvas.f_pb(J.add((-J.n(96.0)), (v_i * 8.0)), (-J.n(37.0)), J.add((-J.n(90.0)), (v_i * 8.0)), (-J.n(31.0)), ("#2f6b62" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#3d8078"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(98.0)), (-J.n(31.0)), 98.0, (-J.n(30.0)), "#8fbdb4")
	game.story_canvas.f_pb(26.0, (-J.n(30.0)), 32.0, 22.0, v_AH2)
	game.story_canvas.f_pb(26.0, (-J.n(30.0)), 28.0, 22.0, v_AH3)
	game.story_canvas.f_pb(78.0, (-J.n(30.0)), 84.0, 22.0, v_AH3)
	game.story_canvas.f_pb(70.0, (-J.n(6.0)), 76.0, (-J.n(3.0)), "#d8ac35")
	game.story_canvas.f_pb(32.0, (-J.n(40.0)), 84.0, (-J.n(38.0)), "#a2a297")
	v_i = 0.0
	while J.lt(v_i, 17.0):
		v_x0 = J.add((-J.n(102.0)), (v_i * 12.0))
		game.story_canvas.f_pb(v_x0, 26.0, J.add(v_x0, 12.0), 37.0, ("#c0281c" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#f2ece0"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(102.0)), 22.0, 102.0, 28.0, "#8e2018")
	v_i = 0.0
	while J.lt(v_i, 17.0):
		v_x0 = J.add((-J.n(102.0)), (v_i * 12.0))
		v_tc = ("#c0281c" if J.eq(fmod(J.n(v_i), J.n(2.0)), 0.0) else "#f2ece0")
		game.story_canvas.f_pb(v_x0, 19.0, J.add(v_x0, 12.0), 22.0, v_tc)
		game.story_canvas.f_pb(J.add(v_x0, 3.0), 16.0, J.add(v_x0, 9.0), 19.0, v_tc)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(92.0)), 38.0, 92.0, 61.0, "#7a1a12")
	game.story_canvas.f_pb((-J.n(88.0)), 42.0, 88.0, 57.0, "#c0281c")
	game.story_canvas.f_pb((-J.n(92.0)), 58.0, 92.0, 60.0, "#e2604f")
	game.story_canvas.f_pb(108.0, (-J.n(42.0)), 122.0, (-J.n(22.0)), "#4a5058")
	game.story_canvas.f_pb(106.0, (-J.n(22.0)), 124.0, (-J.n(19.0)), "#6b737d")
	game.story_canvas.f_pb((-J.n(128.0)), (-J.n(42.0)), (-J.n(108.0)), (-J.n(20.0)), "#6b4122")
	game.story_canvas.f_pb((-J.n(126.0)), (-J.n(40.0)), (-J.n(110.0)), (-J.n(22.0)), "#e8dcc0")
	game.story_canvas.f_pb((-J.n(123.0)), (-J.n(28.0)), (-J.n(113.0)), (-J.n(26.0)), "#8e2018")
	game.story_canvas.f_pb((-J.n(123.0)), (-J.n(33.0)), (-J.n(116.0)), (-J.n(31.0)), "#8e2018")
	return null

# prologue.js:385
func f_proYansima(p_cx: Variant = null, p_cz: Variant = null, p_gen: Variant = null, p_boy: Variant = null, p_a: Variant = null) -> Variant:
	var v_z0: Variant = null
	var v_z1: Variant = null
	var v_z: Variant = null
	var v_x: Variant = null
	var v_cx: Variant = p_cx
	var v_cz: Variant = p_cz
	var v_gen: Variant = p_gen
	var v_boy: Variant = p_boy
	var v_a: Variant = p_a
	J.setv(game.j_ctx, "globalAlpha", v_a)
	v_z0 = max((-J.n(30.0)), (v_cz - (float(v_boy) / float(2.0))))
	v_z1 = min(22.0, J.add(v_cz, (float(v_boy) / float(2.0))))
	v_z = v_z0
	while J.le(v_z, v_z1):
		v_x = (v_cx - (0.487 * (v_z - v_cz)))
		game.f_fr(game.story_canvas.f_pbx((v_x - (float(v_gen) / float(2.0)))), game.story_canvas.f_pby(v_z), max(1.0, v_gen), 1.0, "#eaf6ff")
		v_z = J.add(v_z, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:395
func f_pro1Sokak(p_t: Variant = null, p_gx: Variant = null, p_gy: Variant = null, p_gw: Variant = null, p_gh: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_kuy: Variant = null
	var v_mu: Variant = null
	var v_yx: Variant = null
	var v_t: Variant = p_t
	var v_gx: Variant = p_gx
	var v_gy: Variant = p_gy
	var v_gw: Variant = p_gw
	var v_gh: Variant = p_gh
	game.text_draw.f_txt("USTA DÖNER", game.story_canvas.f_pbx(0.0), game.story_canvas.f_pby(55.0), "#ffd75e", {"align": "c", "sc": 1.0, "outline": "#7a1a12"})
	v_i = 0.0
	while J.lt(v_i, 12.0):
		game.story_canvas.f_pb(J.add((-J.n(88.0)), (v_i * 16.0)), 37.0, J.add((-J.n(84.0)), (v_i * 16.0)), 41.0, ("#fff0b0" if J.gt(sin(J.add((v_t * 4.0), (v_i * 0.7))), (-J.n(0.3))) else "#8a7a4a"))
		v_i = J.add(v_i, 1.0)
	v_kuy = [[134.0, "#3f5a72", "#2e3f52", "#e0a978"], [160.0, "#5c4a5e", "#3e3242", "#c9885a"], [186.0, "#4a6b4a", "#33472f", "#f0bd8a"]]
	v_i = 0.0
	while J.lt(v_i, 3.0):
		game.story_canvas.f_proKisi(J.add(J.getv(J.getv(v_kuy, v_i), 0.0), floor((sin(J.add((v_t * 1.3), v_i)) * 1.2) + 0.5)), J.getv(J.getv(v_kuy, v_i), 1.0), J.getv(J.getv(v_kuy, v_i), 2.0), J.getv(J.getv(v_kuy, v_i), 3.0), "#2b2018", 0.0, false)
		v_i = J.add(v_i, 1.0)
	v_mu = fmod(J.n((v_t * 0.1)), J.n(1.35))
	if J.lt(v_mu, 1.0):
		v_yx = (60.0 - (v_mu * 210.0))
		game.story_canvas.f_proKisi(v_yx, "#6b5a3a", "#4a4030", "#e0a978", "#3a2a1e", (v_t * 7.0), true)
		game.story_canvas.f_pb(J.add(v_yx, 8.0), (-J.n(18.0)), J.add(v_yx, 16.0), (-J.n(13.0)), "#f0d5a8")
		game.story_canvas.f_pb(J.add(v_yx, 8.0), (-J.n(18.0)), J.add(v_yx, 15.0), (-J.n(14.0)), "#fdfaf0")
	game.story_canvas.f_pb((-J.n(176.0)), (-J.n(42.0)), (-J.n(170.0)), 66.0, "#2b2620")
	v_i = 0.0
	while J.lt(v_i, 9.0):
		game.story_canvas.f_pb(J.add((-J.n(170.0)), (v_i * 4.0)), (66.0 - (v_i * 0.9)), J.add((-J.n(164.0)), (v_i * 4.0)), (68.0 - (v_i * 0.9)), "#2b2620")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((-J.n(140.0)), 54.0, (-J.n(126.0)), 60.0, "#3a342c")
	game.story_canvas.f_pb((-J.n(138.0)), 55.0, (-J.n(128.0)), 58.0, "#ffe6a8")
	game.story_canvas.f_pb((-J.n(176.0)), (-J.n(42.0)), (-J.n(170.0)), (-J.n(38.0)), "#1e1a16")
	game.story_canvas.f_proBirds(v_t, v_gx, v_gy, v_gw, 3.0, 0.09)
	J.setv(game.j_ctx, "globalAlpha", J.add(0.07, (0.03 * sin(v_t))))
	v_i = 0.0
	while J.lt(v_i, 16.0):
		game.f_fr(J.add(J.add(v_gx, 24.0), (v_i * 22.0)), v_gy, 8.0, v_gh, "#ffe9a0")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:435
func f_proShopDay(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var v_gx: Variant = null
	var v_gy: Variant = null
	var v_gw: Variant = null
	var v_gh: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	v_gx = 40.0
	v_gy = 44.0
	v_gw = 400.0
	v_gh = 150.0
	game.story_canvas.f_proCiz("s1a", J.ref(game.story_shop.f_pro1Arka, 0))
	game.story_shop.f_pro1Ocak(v_t)
	game.story_canvas.f_proCiz("s1b", J.ref(game.story_shop.f_pro1On, 0))
	game.story_shop.f_pro1Sokak(v_t, v_gx, v_gy, v_gw, v_gh)
	return null

