# Weather draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:4261
func f_drawWeather(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	if J.truth(game.weather_system.f_isRain()):
		J.setv(game.j_ctx, "globalAlpha", 0.1)
		game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#2a4a7a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		if J.truth(game.weather_system.f_isKar()):
			J.setv(game.j_ctx, "globalAlpha", 0.13)
			game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#8fb4dc")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.truth(game.weather_system.f_isSicak()):
				J.setv(game.j_ctx, "globalAlpha", 0.09)
				game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#ffb040")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:4274
func f_drawKar(p_t: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_Gl: Variant = null
	var v_b: Variant = null
	var v_h: Variant = null
	var v_h2: Variant = null
	var v_t: Variant = p_t
	if ((not J.truth(game.weather_system.f_isKar())) or (not J.truth(J.getv(game.j_G, "kar")))):
		return null
	v_K = J.getv(game.j_G, "kar")
	# REMAKE kancasi: HD kar taneleri + kiragi
	if J.truth(game.f_hdKar(v_K, J.getv(game.j_LAY, "glass"))): return null
	v_i = 0.0
	while J.lt(v_i, J.getv(v_K, "length")):
		v_k = J.getv(v_K, v_i)
		v_x = floor(J.getv(v_k, "x") + 0.5)
		v_y = floor(J.getv(v_k, "y") + 0.5)
		if J.gt(J.getv(v_k, "r"), 1.0):
			game.f_fr(v_x, v_y, 2.0, 2.0, "#ffffff")
		else:
			J.setv(game.j_ctx, "globalAlpha", 0.88)
			game.f_px(v_x, v_y, "#f2f8ff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	v_Gl = J.getv(game.j_LAY, "glass")
	J.setv(game.j_ctx, "globalAlpha", 0.34)
	v_b = 0.0
	while J.lt(v_b, J.getv(v_Gl, "w")):
		v_h = J.add(3.0, floor(J.add((sin((v_b * 0.21)) * 2.0), (sin((v_b * 0.07)) * 2.5)) + 0.5))
		if J.gt(v_h, 0.0):
			game.f_fr(J.add(J.getv(v_Gl, "x"), v_b), J.getv(v_Gl, "y"), 2.0, v_h, "#e8f3ff")
		v_h2 = J.add(2.0, floor((sin(J.add((v_b * 0.17), 2.0)) * 1.8) + 0.5))
		if J.gt(v_h2, 0.0):
			game.f_fr(J.add(J.getv(v_Gl, "x"), v_b), (J.add(J.getv(v_Gl, "y"), J.getv(v_Gl, "h")) - v_h2), 2.0, v_h2, "#e8f3ff")
		v_b = J.add(v_b, 2.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:4299
func f_drawCamDamla(p_t: Variant = null) -> Variant:
	var v_D: Variant = null
	var v_i: Variant = null
	var v_d: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_iz: Variant = null
	var v_r: Variant = null
	var v_t: Variant = p_t
	if ((not J.truth(game.weather_system.f_isRain())) or (not J.truth(J.getv(game.j_G, "camDamla")))):
		return null
	v_D = J.getv(game.j_G, "camDamla")
	# REMAKE kancasi: HD cam damlalari
	if J.truth(game.f_hdCamDamla(v_D)): return null
	v_i = 0.0
	while J.lt(v_i, J.getv(v_D, "length")):
		v_d = J.getv(v_D, v_i)
		v_x = floor(J.getv(v_d, "x") + 0.5)
		v_y = floor(J.getv(v_d, "y") + 0.5)
		if J.gt(J.getv(v_d, "iz"), 1.0):
			J.setv(game.j_ctx, "globalAlpha", 0.26)
			v_iz = floor(J.getv(v_d, "iz") + 0.5)
			game.f_fr(v_x, (v_y - v_iz), 1.0, v_iz, "#cfe4f2")
			J.setv(game.j_ctx, "globalAlpha", 0.16)
			game.f_fr((v_x - 1.0), (v_y - floor((v_iz * 0.7) + 0.5)), 1.0, floor((v_iz * 0.7) + 0.5), "#eaf6ff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_r = J.getv(v_d, "r")
		J.setv(game.j_ctx, "globalAlpha", 0.72)
		if J.lt(v_r, 1.1):
			game.f_px(v_x, v_y, "#dff0fa")
		else:
			game.f_ell(v_x, v_y, floor(v_r + 0.5), max(1.0, floor((v_r * 1.25) + 0.5)), "#cfe4f2")
			J.setv(game.j_ctx, "globalAlpha", 0.95)
			game.f_px(v_x, (v_y - floor((v_r * 0.5) + 0.5)), "#ffffff")
			game.f_px((v_x - 1.0), v_y, "#eaf6ff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if J.gt(J.getv(v_d, "carp"), 0.0):
			J.setv(game.j_ctx, "globalAlpha", (J.getv(v_d, "carp") * 0.55))
			game.f_ring(v_x, v_y, floor(J.add(1.0, ((1.0 - J.getv(v_d, "carp")) * 3.0)) + 0.5), "#eaf6ff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

