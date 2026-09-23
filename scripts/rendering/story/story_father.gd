# Story father. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:447
func f_pro2Arka() -> Variant:
	var v_i: Variant = null
	var v_r: Variant = null
	var v_c: Variant = null
	var v_fon: Variant = null
	var v_ox: Variant = null
	var v_ask: Variant = null
	v_fon = [[(-J.n(70.0)), (-J.n(30.0)), "#241610"], [(-J.n(30.0)), 4.0, "#2e1c12"], [4.0, 34.0, "#382214"], [34.0, 96.0, "#432a18"]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_fon, "length")):
		game.story_canvas.f_pb((-J.n(230.0)), J.getv(J.getv(v_fon, v_i), 0.0), 230.0, J.getv(J.getv(v_fon, v_i), 1.0), J.getv(J.getv(v_fon, v_i), 2.0))
		v_i = J.add(v_i, 1.0)
	v_r = 0.0
	while J.lt(v_r, 11.0):
		game.story_canvas.f_pb((-J.n(230.0)), J.add((-J.n(60.0)), (v_r * 14.0)), 230.0, J.add((-J.n(59.0)), (v_r * 14.0)), "#4e3020")
		v_c = 0.0
		while J.lt(v_c, 13.0):
			v_ox = (9.0 if J.truth(fmod(J.n(v_r), J.n(2.0))) else 0.0)
			game.story_canvas.f_pb(J.add(J.add((-J.n(222.0)), (v_c * 36.0)), v_ox), J.add((-J.n(59.0)), (v_r * 14.0)), J.add(J.add((-J.n(221.0)), (v_c * 36.0)), v_ox), J.add((-J.n(46.0)), (v_r * 14.0)), "#4e3020")
			v_c = J.add(v_c, 1.0)
		v_r = J.add(v_r, 1.0)
	v_ask = [[(-J.n(186.0)), 26.0], [(-J.n(166.0)), 20.0], [154.0, 30.0], [176.0, 22.0]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_ask, "length")):
		game.story_canvas.f_pb((J.getv(J.getv(v_ask, v_i), 0.0) - 1.0), (96.0 - J.getv(J.getv(v_ask, v_i), 1.0)), J.add(J.getv(J.getv(v_ask, v_i), 0.0), 1.0), 96.0, "#1c1108")
		game.story_canvas.f_pb((J.getv(J.getv(v_ask, v_i), 0.0) - 7.0), (90.0 - J.getv(J.getv(v_ask, v_i), 1.0)), J.add(J.getv(J.getv(v_ask, v_i), 0.0), 7.0), (96.0 - J.getv(J.getv(v_ask, v_i), 1.0)), "#2b2018")
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:468
func f_pro2Baba(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_j: Variant = null
	var v_BX: Variant = null
	var v_BZ: Variant = null
	var v_kirp: Variant = null
	var v_sx: Variant = null
	var v_eg: Variant = null
	var v_sal: Variant = null
	var v_u: Variant = null
	var v_lift: Variant = null
	var v_th: Variant = null
	var v_u2: Variant = null
	var v_t: Variant = p_t
	v_BX = 62.0
	v_BZ = 6.0
	game.story_canvas.f_pbE(v_BX, (v_BZ - 62.0), 56.0, 46.0, "#8e2018")
	game.story_canvas.f_pbE((v_BX - 4.0), (v_BZ - 62.0), 52.0, 43.0, "#c33c2c")
	game.story_canvas.f_pbE((v_BX - 10.0), (v_BZ - 62.0), 40.0, 38.0, "#e2604f")
	game.story_canvas.f_pbE(v_BX, (v_BZ - 66.0), 26.0, 42.0, "#aba392")
	game.story_canvas.f_pbE((v_BX - 3.0), (v_BZ - 66.0), 23.0, 39.0, "#e4dcc6")
	game.story_canvas.f_pbE((v_BX - 8.0), (v_BZ - 66.0), 15.0, 32.0, "#f6f1e2")
	game.story_canvas.f_pbE(v_BX, (v_BZ - 30.0), 20.0, 8.0, "#c33c2c")
	game.story_canvas.f_pb((v_BX - 11.0), (v_BZ - 26.0), J.add(v_BX, 11.0), (v_BZ - 6.0), "#c9885a")
	game.story_canvas.f_pbE(v_BX, J.add(v_BZ, 4.0), 25.0, 29.0, "#8a5230")
	game.story_canvas.f_pbE((v_BX - 2.0), J.add(v_BZ, 3.0), 23.0, 27.0, "#a86a3e")
	game.story_canvas.f_pbE((v_BX - 4.0), J.add(v_BZ, 2.0), 20.0, 24.0, "#c9885a")
	game.story_canvas.f_pbE((v_BX - 6.0), v_BZ, 16.0, 20.0, "#e0a978")
	game.story_canvas.f_pbE((v_BX - 8.0), (v_BZ - 2.0), 10.0, 13.0, "#f0bd8a")
	game.story_canvas.f_pbE(v_BX, (v_BZ - 12.0), 18.0, 12.0, "#d79f70")
	game.story_canvas.f_pbE((v_BX - 4.0), (v_BZ - 13.0), 14.0, 9.0, "#e8b184")
	v_i = 0.0
	while J.lt(v_i, 2.0):
		game.story_canvas.f_pbE(J.add(v_BX, (25.0 if J.truth(v_i) else (-J.n(25.0)))), J.add(v_BZ, 2.0), 5.0, 8.0, ("#a86a3e" if J.truth(v_i) else "#c9885a"))
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE((v_BX - 1.0), J.add(v_BZ, 1.0), 6.0, 9.0, "#c9885a")
	game.story_canvas.f_pbE((v_BX - 3.0), v_BZ, 4.0, 7.0, "#e0a978")
	game.story_canvas.f_pbE((v_BX - 1.0), (v_BZ - 5.0), 8.0, 4.0, "#b87b4c")
	v_kirp = J.lt(fmod(J.n((v_t * 0.62)), J.n(4.4)), 0.13)
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_sx = (11.0 if J.truth(v_i) else (-J.n(11.0)))
		if J.truth(v_kirp):
			game.story_canvas.f_pb((J.add(v_BX, v_sx) - 5.0), J.add(v_BZ, 11.0), J.add(J.add(v_BX, v_sx), 5.0), J.add(v_BZ, 13.0), "#c9885a")
		else:
			game.story_canvas.f_pbE(J.add(v_BX, v_sx), J.add(v_BZ, 13.0), 7.0, 6.0, "#b87b4c")
			game.story_canvas.f_pbE(J.add(v_BX, v_sx), J.add(v_BZ, 12.0), 5.0, 4.0, "#cfc7b6")
			game.story_canvas.f_pbE((J.add(v_BX, v_sx) - 1.0), J.add(v_BZ, 12.0), 4.0, 3.0, "#f0ece2")
			game.story_canvas.f_pbE(J.add(J.add(v_BX, v_sx), 1.0), J.add(v_BZ, 12.0), 2.4, 2.4, "#2b2018")
			game.f_px(game.story_canvas.f_pbx(J.add(v_BX, v_sx)), game.story_canvas.f_pby(J.add(v_BZ, 13.0)), "#ffffff")
		v_j = 0.0
		while J.lt(v_j, 9.0):
			v_eg = ((v_j - 4.0) * (0.5 if J.truth(v_i) else (-J.n(0.5))))
			game.story_canvas.f_pb(J.add((J.add(v_BX, v_sx) - 8.0), (v_j * 2.0)), J.add(J.add(v_BZ, 18.0), v_eg), J.add((J.add(v_BX, v_sx) - 6.0), (v_j * 2.0)), J.add(J.add(v_BZ, 20.0), v_eg), "#8f8578")
			game.story_canvas.f_pb(J.add((J.add(v_BX, v_sx) - 8.0), (v_j * 2.0)), J.add(J.add(v_BZ, 19.0), v_eg), J.add((J.add(v_BX, v_sx) - 6.0), (v_j * 2.0)), J.add(J.add(v_BZ, 20.0), v_eg), "#b8b0a0")
			v_j = J.add(v_j, 1.0)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((v_BX - 22.0), J.add(v_BZ, 30.0), J.add(v_BX, 22.0), J.add(v_BZ, 52.0), "#8e2018")
	game.story_canvas.f_pb((v_BX - 21.0), J.add(v_BZ, 30.0), J.add(v_BX, 20.0), J.add(v_BZ, 52.0), "#c33c2c")
	game.story_canvas.f_pb((v_BX - 21.0), J.add(v_BZ, 30.0), (v_BX - 12.0), J.add(v_BZ, 52.0), "#e2604f")
	game.story_canvas.f_pbE(v_BX, J.add(v_BZ, 52.0), 22.0, 6.0, "#c33c2c")
	game.story_canvas.f_pbE((v_BX - 6.0), J.add(v_BZ, 53.0), 14.0, 4.0, "#e2604f")
	game.story_canvas.f_pb((v_BX - 23.0), J.add(v_BZ, 27.0), J.add(v_BX, 23.0), J.add(v_BZ, 31.0), "#7a1a12")
	v_sal = floor((sin((v_t * 1.6)) * 3.0) + 0.5)
	game.story_canvas.f_pb(J.add(J.add(v_BX, 19.0), v_sal), J.add(v_BZ, 38.0), J.add(J.add(v_BX, 21.0), v_sal), J.add(v_BZ, 54.0), "#2b2018")
	game.story_canvas.f_pbE(J.add(J.add(v_BX, 20.0), v_sal), J.add(v_BZ, 37.0), 4.0, 3.0, "#2b2018")
	v_j = 0.0
	while J.lt(v_j, 29.0):
		v_u = (float(abs((v_j - 14.0))) / float(14.0))
		v_lift = ((v_u * v_u) * 6.0)
		v_th = max(2.0, (6.0 - (v_u * 3.5)))
		game.story_canvas.f_pb(J.add((v_BX - 15.0), v_j), J.add((v_BZ - 9.0), v_lift), J.add((v_BX - 14.0), v_j), J.add(J.add((v_BZ - 9.0), v_lift), v_th), "#ddd6c8")
		game.story_canvas.f_pb(J.add((v_BX - 15.0), v_j), (J.add(J.add((v_BZ - 9.0), v_lift), v_th) - 1.0), J.add((v_BX - 14.0), v_j), J.add(J.add((v_BZ - 9.0), v_lift), v_th), "#f4f0e6")
		v_j = J.add(v_j, 1.0)
	v_j = 0.0
	while J.lt(v_j, 13.0):
		v_u2 = (float(abs((v_j - 6.0))) / float(6.0))
		game.story_canvas.f_pb(J.add((v_BX - 6.0), v_j), J.add((v_BZ - 17.0), ((v_u2 * v_u2) * 2.0)), J.add((v_BX - 5.0), v_j), J.add((v_BZ - 16.0), ((v_u2 * v_u2) * 2.0)), "#8a4a2e")
		v_j = J.add(v_j, 1.0)
	return null

# prologue.js:550
func f_pro2Doner(p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_X: Variant = null
	var v_bz: Variant = null
	var v_yan: Variant = null
	var v_t: Variant = p_t
	v_X = (-J.n(136.0))
	game.story_canvas.f_pb((v_X - 38.0), (-J.n(58.0)), J.add(v_X, 38.0), (-J.n(48.0)), "#2f2f38")
	game.story_canvas.f_pb((v_X - 38.0), (-J.n(50.0)), J.add(v_X, 38.0), (-J.n(48.0)), "#6f7880")
	game.story_canvas.f_pb((v_X - 38.0), (-J.n(58.0)), (v_X - 34.0), (-J.n(48.0)), "#4d545c")
	game.story_canvas.f_pb((v_X - 32.0), (-J.n(48.0)), J.add(v_X, 32.0), 44.0, "#22222a")
	game.story_canvas.f_pb((v_X - 32.0), (-J.n(48.0)), (v_X - 27.0), 44.0, "#3d3d48")
	game.story_canvas.f_pb(J.add(v_X, 27.0), (-J.n(48.0)), J.add(v_X, 32.0), 44.0, "#14141a")
	game.story_canvas.f_pb((v_X - 32.0), 40.0, J.add(v_X, 32.0), 44.0, "#3d3d48")
	game.story_canvas.f_pb((v_X - 32.0), (-J.n(48.0)), J.add(v_X, 32.0), (-J.n(45.0)), "#14141a")
	v_i = 0.0
	while J.lt(v_i, 12.0):
		v_bz = J.add((-J.n(43.0)), (v_i * 7.0))
		v_yan = J.gt(sin(J.add((v_t * 2.2), (v_i * 0.8))), (-J.n(0.35)))
		game.story_canvas.f_pb((v_X - 25.0), v_bz, J.add(v_X, 25.0), J.add(v_bz, 5.0), ("#c0421a" if J.truth(v_yan) else "#7a2c0c"))
		game.story_canvas.f_pb((v_X - 25.0), J.add(v_bz, 1.0), J.add(v_X, 25.0), J.add(v_bz, 4.0), ("#ff7a2a" if J.truth(v_yan) else "#a83a12"))
		game.story_canvas.f_pb((v_X - 25.0), J.add(v_bz, 2.0), J.add(v_X, 25.0), J.add(v_bz, 3.0), ("#ffb04a" if J.truth(v_yan) else "#c0421a"))
		game.story_canvas.f_pb((v_X - 25.0), J.add(v_bz, 5.0), J.add(v_X, 25.0), J.add(v_bz, 6.0), "#1c1c24")
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((v_X - 27.0), (-J.n(43.0)), (v_X - 25.0), 41.0, "#3d3d48")
	game.story_canvas.f_pb(J.add(v_X, 25.0), (-J.n(43.0)), J.add(v_X, 27.0), 41.0, "#1c1c24")
	game.story_canvas.f_pb((v_X - 16.0), 44.0, J.add(v_X, 16.0), 54.0, "#2a2a32")
	game.story_canvas.f_pb((v_X - 16.0), 52.0, J.add(v_X, 16.0), 54.0, "#4d545c")
	game.story_canvas.f_pb((v_X - 14.0), 46.0, (v_X - 4.0), 50.0, "#6f7880")
	game.story_canvas.f_pb((v_X - 2.0), (-J.n(52.0)), J.add(v_X, 2.0), 48.0, "#6f7880")
	game.story_canvas.f_pb((v_X - 2.0), (-J.n(52.0)), v_X, 48.0, "#c6ced5")
	game.story_canvas.f_proSis(v_X, (-J.n(40.0)), 30.0, 20.0, 5.0, v_t)
	game.story_canvas.f_pb(J.add(v_X, 12.0), (-J.n(48.0)), J.add(v_X, 26.0), (-J.n(46.0)), "#8a5f2a")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.story_canvas.f_pb((v_X - 6.0), (-J.n(48.0)), J.add(v_X, 4.0), (-J.n(44.0)), "#7a3f12")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:611
func f_proParmak(p_x0: Variant = null, p_x1: Variant = null, p_cz: Variant = null, p_kal: Variant = null) -> Variant:
	var v_uz: Variant = null
	var v_i: Variant = null
	var v_u: Variant = null
	var v_h: Variant = null
	var v_x: Variant = null
	var v_x0: Variant = p_x0
	var v_x1: Variant = p_x1
	var v_cz: Variant = p_cz
	var v_kal: Variant = p_kal
	v_uz = (v_x1 - v_x0)
	v_i = 0.0
	while J.le(v_i, v_uz):
		v_u = (float(v_i) / float(v_uz))
		v_h = (v_kal * sqrt(max(0.2, (1.0 - pow(((v_u * 2.0) - 1.0), 6.0)))))
		v_x = J.add(v_x0, v_i)
		game.story_canvas.f_pb(v_x, (v_cz - v_h), J.add(v_x, 1.0), J.add(v_cz, v_h), "#4e2e1a")
		game.story_canvas.f_pb(v_x, J.add((v_cz - v_h), 1.0), J.add(v_x, 1.0), (J.add(v_cz, v_h) - 1.0), "#96603a")
		game.story_canvas.f_pb(v_x, (J.add(v_cz, v_h) - 3.0), J.add(v_x, 1.0), (J.add(v_cz, v_h) - 1.0), "#b87b4c")
		game.story_canvas.f_pb(v_x, (J.add(v_cz, v_h) - 2.0), J.add(v_x, 1.0), (J.add(v_cz, v_h) - 1.0), "#d79f70")
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:627
func f_pro2Kol() -> Variant:
	var v_i: Variant = null
	var v_u: Variant = null
	var v_ax: Variant = null
	var v_az: Variant = null
	var v_aw: Variant = null
	var v_X0: Variant = null
	var v_Z0: Variant = null
	var v_X1: Variant = null
	var v_Z1: Variant = null
	var v_n: Variant = null
	v_X0 = 26.0
	v_Z0 = (-J.n(59.0))
	v_X1 = (-J.n(16.0))
	v_Z1 = (-J.n(39.0))
	v_n = (v_X0 - v_X1)
	v_i = 0.0
	while J.le(v_i, v_n):
		v_u = (float(v_i) / float(v_n))
		v_ax = (v_X0 - v_i)
		v_az = J.add(v_Z0, ((v_Z1 - v_Z0) * v_u))
		v_aw = (11.0 - (v_u * 3.0))
		game.story_canvas.f_pb(v_ax, ((v_az - v_aw) - 1.0), J.add(v_ax, 1.0), J.add(J.add(v_az, v_aw), 1.0), "#4a0f0a")
		game.story_canvas.f_pb(v_ax, (v_az - v_aw), J.add(v_ax, 1.0), J.add(v_az, v_aw), "#8e2018")
		game.story_canvas.f_pb(v_ax, J.add((v_az - v_aw), 2.0), J.add(v_ax, 1.0), (J.add(v_az, v_aw) - 2.0), "#c33c2c")
		game.story_canvas.f_pb(v_ax, (J.add(v_az, v_aw) - 4.0), J.add(v_ax, 1.0), (J.add(v_az, v_aw) - 2.0), "#e2604f")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.story_canvas.f_pb(4.0, (-J.n(50.0)), 14.0, (-J.n(47.0)), "#6b1610")
	game.story_canvas.f_pb((-J.n(6.0)), (-J.n(45.0)), 4.0, (-J.n(42.0)), "#6b1610")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.le(v_i, 9.0):
		v_ax = ((-J.n(12.0)) - v_i)
		v_az = ((-J.n(39.0)) - (v_i * 0.5))
		v_aw = (10.0 - (v_i * 0.25))
		game.story_canvas.f_pb(v_ax, ((v_az - v_aw) - 1.0), J.add(v_ax, 1.0), J.add(J.add(v_az, v_aw), 1.0), "#8a8272")
		game.story_canvas.f_pb(v_ax, (v_az - v_aw), J.add(v_ax, 1.0), J.add(v_az, v_aw), "#c2b9a2")
		game.story_canvas.f_pb(v_ax, J.add((v_az - v_aw), 1.0), J.add(v_ax, 1.0), (J.add(v_az, v_aw) - 1.0), "#e4dcc6")
		if J.gt(v_i, 6.0):
			game.story_canvas.f_pb(v_ax, J.add((v_az - v_aw), 1.0), J.add(v_ax, 1.0), (J.add(v_az, v_aw) - 1.0), "#f6f1e2")
		v_i = J.add(v_i, 1.0)
	return null

# prologue.js:656
func f_pro2Durum() -> Variant:
	var v_i: Variant = null
	var v_q: Variant = null
	var v_uu: Variant = null
	var v_kis: Variant = null
	var v_col: Variant = null
	var v_X: Variant = null
	var v_R: Variant = null
	var v_ZA: Variant = null
	var v_ZB: Variant = null
	var v_KAG: Variant = null
	var v_YA: Variant = null
	var v_YU: Variant = null
	var v_fz: Variant = null
	var v_f0: Variant = null
	var v_f1: Variant = null
	var v_tu: Variant = null
	var v_tz: Variant = null
	var v_tx: Variant = null
	var v_tw: Variant = null
	v_X = (-J.n(31.0))
	v_R = 10.0
	v_ZA = (-J.n(42.0))
	v_ZB = 15.0
	v_KAG = (-J.n(10.0))
	v_YA = (-J.n(40.0))
	v_YU = (-J.n(13.0))
	v_i = (-J.n(v_R))
	while J.le(v_i, v_R):
		v_uu = (float(v_i) / float(v_R))
		v_kis = floor(((1.0 - sqrt(max(0.0, (1.0 - (v_uu * v_uu))))) * 3.0) + 0.5)
		v_col = ("#fdfaf0" if J.lt(v_uu, (-J.n(0.55))) else ("#f0d5a8" if J.lt(v_uu, (-J.n(0.12))) else ("#cfa268" if J.lt(v_uu, 0.45) else ("#a87a41" if J.lt(v_uu, 0.8) else "#8a5f2a"))))
		game.story_canvas.f_pb(J.add(v_X, v_i), J.add(v_ZA, v_kis), J.add(J.add(v_X, v_i), 1.0), (v_ZB - v_kis), v_col)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pbE(v_X, (v_ZB - 3.0), (v_R - 1.0), 4.0, "#e8c07a")
	game.story_canvas.f_pbE(v_X, (v_ZB - 4.0), (v_R - 3.0), 3.0, "#8a4a1a")
	game.story_canvas.f_pbE((v_X - 3.0), (v_ZB - 4.0), 3.5, 2.2, "#d18c42")
	game.story_canvas.f_pbE(J.add(v_X, 3.0), (v_ZB - 4.0), 2.6, 1.8, "#3f8a4a")
	game.story_canvas.f_pbE(v_X, (v_ZB - 6.0), 2.0, 1.4, "#c9302a")
	v_i = ((-J.n(v_R)) - 1.0)
	while J.le(v_i, J.add(v_R, 1.0)):
		v_uu = (float(v_i) / float(J.add(v_R, 1.0)))
		v_kis = floor(((1.0 - sqrt(max(0.0, (1.0 - (v_uu * v_uu))))) * 3.0) + 0.5)
		v_col = ("#ffffff" if J.lt(v_uu, (-J.n(0.55))) else ("#fdfaf0" if J.lt(v_uu, (-J.n(0.12))) else ("#e4dcc6" if J.lt(v_uu, 0.45) else "#b0a894")))
		game.story_canvas.f_pb(J.add(v_X, v_i), J.add(v_ZA, v_kis), J.add(J.add(v_X, v_i), 1.0), v_KAG, v_col)
		v_i = J.add(v_i, 1.0)
	game.story_canvas.f_pb((v_X - v_R), (v_KAG - 2.0), J.add(v_X, v_R), v_KAG, "#9e9888")
	game.story_canvas.f_pb(J.add((v_X - v_R), 1.0), (v_KAG - 9.0), (J.add(v_X, v_R) - 1.0), (v_KAG - 7.0), "#d8352c")
	game.story_canvas.f_pb(J.add((v_X - v_R), 1.0), (v_KAG - 14.0), (J.add(v_X, v_R) - 1.0), (v_KAG - 12.0), "#2f5f9e")
	game.story_canvas.f_pbE(v_X, J.add((float(J.add(v_YA, v_YU)) / float(2.0)), 1.0), 16.0, 12.5, "#3d2314")
	game.story_canvas.f_pbE((v_X - 1.0), J.add((float(J.add(v_YA, v_YU)) / float(2.0)), 1.0), 14.0, 10.5, "#6f4326")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		v_fz = ((v_YU - 3.0) - (v_i * 6.0))
		v_f0 = J.add((v_X - 15.0), (2.0 if J.eq(v_i, 3.0) else 0.0))
		v_f1 = (J.add(v_X, 13.0) - (2.0 if J.eq(v_i, 3.0) else 0.0))
		game.story_father.f_proParmak(v_f0, v_f1, v_fz, 3.4)
		v_i = J.add(v_i, 1.0)
	v_q = 0.0
	while J.le(v_q, 18.0):
		v_tu = (float(v_q) / float(18.0))
		v_tz = J.add(J.add(v_YA, 4.0), v_q)
		v_tx = (J.add(v_X, 12.0) - (v_tu * 3.0))
		v_tw = (3.8 * sqrt(max(0.22, (1.0 - pow(((v_tu * 2.0) - 1.0), 4.0)))))
		game.story_canvas.f_pb((v_tx - v_tw), v_tz, J.add(v_tx, v_tw), J.add(v_tz, 1.0), "#3d2314")
		game.story_canvas.f_pb(J.add((v_tx - v_tw), 1.0), v_tz, (J.add(v_tx, v_tw) - 1.0), J.add(v_tz, 1.0), ("#b87b4c" if J.gt(v_tu, 0.55) else "#96603a"))
		game.story_canvas.f_pb(J.add((v_tx - v_tw), 1.0), v_tz, J.add((v_tx - v_tw), 2.0), J.add(v_tz, 1.0), "#d79f70")
		v_q = J.add(v_q, 1.0)
	game.story_canvas.f_pbE(J.add(v_X, 9.0), (v_YU - 2.0), 3.4, 2.6, "#8a5230")
	game.story_canvas.f_pbE(J.add(v_X, 9.0), (v_YU - 2.0), 2.4, 1.8, "#f0bd8a")
	return null

# prologue.js:711
func f_pro2Hale() -> Variant:
	var v_r: Variant = null
	J.setv(game.j_ctx, "globalAlpha", 0.03)
	v_r = 0.0
	while J.lt(v_r, 26.0):
		game.story_canvas.f_pb(((-J.n(166.0)) - (v_r * 3.0)), ((-J.n(56.0)) - (v_r * 2.0)), J.add((-J.n(106.0)), (v_r * 4.0)), J.add(42.0, (v_r * 2.0)), "#ff9a3a")
		v_r = J.add(v_r, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:718
func f_pro2Atmosfer() -> Variant:
	game.story_canvas.f_pbA((-J.n(230.0)), (-J.n(70.0)), 230.0, 96.0, "#ff8a3a", 0.07)
	game.story_canvas.f_pbA((-J.n(230.0)), (-J.n(70.0)), (-J.n(150.0)), 96.0, "#000000", 0.3)
	game.story_canvas.f_pbA(150.0, (-J.n(70.0)), 230.0, 96.0, "#000000", 0.3)
	game.story_canvas.f_pbA((-J.n(230.0)), 70.0, 230.0, 96.0, "#000000", 0.22)
	game.story_canvas.f_pbA((-J.n(230.0)), (-J.n(70.0)), 230.0, (-J.n(52.0)), "#000000", 0.22)
	return null

# prologue.js:726
func f_proFather(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_r: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	# REMAKE kancasi
	if game.f_hdProFather(p_t, p_k): return null
	game.story_canvas.f_proCiz("s2a", J.ref(game.story_father.f_pro2Arka, 0))
	game.story_father.f_pro2Doner(v_t)
	J.setv(game.j_ctx, "globalAlpha", J.add(0.88, (0.26 * sin((v_t * 1.7)))))
	J.method(game.j_ctx, "drawImage", [game.f_proKat("s2hale", J.ref(game.story_father.f_pro2Hale, 0)), 40.0, 44.0])
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.story_father.f_pro2Baba(v_t)
	game.story_father.f_pro2Kol()
	game.story_father.f_pro2Durum()
	if J.truth(game.f_chance(0.14)):
		game.effects.f_part({"x": J.add(game.story_canvas.f_pbx((-J.n(34.0))), game.math_utils.f_rnd((-J.n(16.0)), 16.0)), "y": game.story_canvas.f_pby((-J.n(24.0))), "vx": game.math_utils.f_rnd((-J.n(5.0)), 5.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(9.0))), "life": 1.1, "col": "rgba(255,235,205,.4)", "g": (-J.n(12.0)), "sz": 1.0})
	game.story_canvas.f_proCiz("s2on", J.ref(game.story_father.f_pro2Atmosfer, 0))
	return null

