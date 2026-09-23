# Weather system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:4151
func f_rollWeather() -> Variant:
	var v_ihtimal: Variant = null
	var v_tm: Variant = null
	var v_karO: Variant = null
	var v_sicakO: Variant = null
	var v_tm2: Variant = null
	var v_z: Variant = null
	v_ihtimal = game.j_RAIN_CHANCE
	if J.eq(J.kind(J.ref(game.city_system.f_sehirTema, 0)), "function"):
		v_tm = game.city_system.f_sehirTema()
		if (J.truth(v_tm) and not J.eq(J.getv(v_tm, "yagmur"), null)):
			v_ihtimal = J.getv(v_tm, "yagmur")
	v_karO = 0.0
	v_sicakO = 0.0
	if J.eq(J.kind(J.ref(game.city_system.f_sehirTema, 0)), "function"):
		v_tm2 = game.city_system.f_sehirTema()
		if J.truth(v_tm2):
			v_karO = (J.getv(v_tm2, "kar") if J.truth(J.getv(v_tm2, "kar")) else 0.0)
			v_sicakO = (J.getv(v_tm2, "sicak") if J.truth(J.getv(v_tm2, "sicak")) else 0.0)
	J.setv(game.j_G, "weather", "sun")
	if J.ge(J.getv(game.j_G, "day"), 3.0):
		v_z = game.random_unit()
		if J.lt(v_z, v_karO):
			J.setv(game.j_G, "weather", "kar")
		else:
			if J.lt(v_z, J.add(v_karO, v_sicakO)):
				J.setv(game.j_G, "weather", "sicak")
			else:
				if J.lt(v_z, J.add(J.add(v_karO, v_sicakO), v_ihtimal)):
					J.setv(game.j_G, "weather", "rain")
	J.setv(game.j_G, "rainT", 0.0)
	J.setv(game.j_G, "camDamla", [])
	J.setv(game.j_G, "kar", [])
	return null

# game.js:4177
func f_isRain() -> Variant:
	return J.eq(J.getv(game.j_G, "weather"), "rain")
	return null

# game.js:4179
func f_macDalgada() -> Variant:
	var v_gecen: Variant = null
	if ((not J.truth(J.getv(game.j_G, "macGun"))) or (not J.truth(J.getv(game.j_G, "cfg")))):
		return false
	v_gecen = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "timeLeft")) / float(J.getv(J.getv(game.j_G, "cfg"), "len"))), 0.0, 1.0))
	return (J.le(v_gecen, game.j_MAC_BIT) if J.ge(v_gecen, game.j_MAC_BAS) else J.ge(v_gecen, game.j_MAC_BAS))
	return null

# game.js:4184
func f_isKar() -> Variant:
	return J.eq(J.getv(game.j_G, "weather"), "kar")
	return null

# game.js:4185
func f_isSicak() -> Variant:
	return J.eq(J.getv(game.j_G, "weather"), "sicak")
	return null

# game.js:4187
func f_isSoguk() -> Variant:
	return (J.eq(J.getv(game.j_G, "weather"), "kar") if J.eq(J.getv(game.j_G, "weather"), "kar") else J.eq(J.getv(game.j_G, "weather"), "rain"))
	return null

# game.js:4189
func f_karGuncelle(p_dt: Variant = null) -> Variant:
	var v_Gl: Variant = null
	var v_K: Variant = null
	var v_i: Variant = null
	var v_k: Variant = null
	var v_dt: Variant = p_dt
	if (not J.truth(J.getv(game.j_G, "kar"))):
		J.setv(game.j_G, "kar", [])
	v_Gl = J.getv(game.j_LAY, "glass")
	v_K = J.getv(game.j_G, "kar")
	if (J.lt(J.getv(v_K, "length"), 78.0) and J.truth(game.f_chance((v_dt * 46.0)))):
		J.method(v_K, "push", [{"x": J.add(J.getv(v_Gl, "x"), game.math_utils.f_rnd(0.0, J.getv(v_Gl, "w"))), "y": (J.getv(v_Gl, "y") - 2.0), "v": game.math_utils.f_rnd(7.0, 16.0), "s": game.math_utils.f_rnd((-J.n(5.0)), 5.0), "f": game.math_utils.f_rnd(0.0, 6.28), "r": (2.0 if J.truth(game.f_chance(0.34)) else 1.0)}])
	v_i = (J.getv(v_K, "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_k = J.getv(v_K, v_i)
		J.setv(v_k, "f", J.add(J.getv(v_k, "f"), (v_dt * 2.2)))
		J.setv(v_k, "y", J.add(J.getv(v_k, "y"), (J.getv(v_k, "v") * v_dt)))
		J.setv(v_k, "x", J.add(J.getv(v_k, "x"), ((sin(J.getv(v_k, "f")) * J.getv(v_k, "s")) * v_dt)))
		if J.gt(J.getv(v_k, "y"), (J.add(J.getv(v_Gl, "y"), J.getv(v_Gl, "h")) - 1.0)):
			J.method(v_K, "splice", [v_i, 1.0])
		v_i = (v_i - 1.0)
	return null

# game.js:4208
func f_updateWeather(p_dt: Variant = null) -> Variant:
	var v_dt: Variant = p_dt
	if J.truth(game.weather_system.f_isKar()):
		game.weather_system.f_karGuncelle(v_dt)
		return null
	if (J.truth(J.getv(game.j_G, "kar")) and J.truth(J.getv(J.getv(game.j_G, "kar"), "length"))):
		J.setv(J.getv(game.j_G, "kar"), "length", 0.0)
	if (not J.truth(game.weather_system.f_isRain())):
		if (J.truth(J.getv(game.j_G, "camDamla")) and J.truth(J.getv(J.getv(game.j_G, "camDamla"), "length"))):
			J.setv(J.getv(game.j_G, "camDamla"), "length", 0.0)
		return null
	J.setv(game.j_G, "rainT", (J.getv(game.j_G, "rainT") - v_dt))
	if J.le(J.getv(game.j_G, "rainT"), 0.0):
		J.setv(game.j_G, "rainT", game.math_utils.f_rnd(7.0, 14.0))
		if (not ((not J.eq(J.kind(game.j_SND), "undefined") and J.truth(J.getv(game.j_SND, "rain"))) and (J.truth(J.getv(J.getv(game.j_SND, "rain"), "buf")) or J.truth(J.getv(J.getv(game.j_SND, "rain"), "el"))))):
			J.method(game.j_SFX, "rain", [])
	game.weather_system.f_camDamlaGuncelle(v_dt)
	return null

# game.js:4227
func f_camDamlaGuncelle(p_dt: Variant = null) -> Variant:
	var v_Gl: Variant = null
	var v_D: Variant = null
	var v_kac: Variant = null
	var v_n: Variant = null
	var v_i: Variant = null
	var v_d: Variant = null
	var v_dt: Variant = p_dt
	if (not J.truth(J.getv(game.j_G, "camDamla"))):
		J.setv(game.j_G, "camDamla", [])
	v_Gl = J.getv(game.j_LAY, "glass")
	v_D = J.getv(game.j_G, "camDamla")
	v_kac = 2.0
	v_n = 0.0
	while J.lt(v_n, v_kac):
		if (J.lt(J.getv(v_D, "length"), 58.0) and J.truth(game.f_chance((v_dt * 12.0)))):
			J.method(v_D, "push", [{"x": J.add(J.getv(v_Gl, "x"), game.math_utils.f_rnd(3.0, (J.getv(v_Gl, "w") - 3.0))), "y": J.add(J.getv(v_Gl, "y"), game.math_utils.f_rnd(2.0, (J.getv(v_Gl, "h") * 0.55))), "r": game.math_utils.f_rnd(0.8, 2.1), "v": 0.0, "bekle": game.math_utils.f_rnd(0.15, 1.6), "iz": 0.0, "carp": 1.0}])
		v_n = J.add(v_n, 1.0)
	v_i = (J.getv(v_D, "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_d = J.getv(v_D, v_i)
		if J.gt(J.getv(v_d, "carp"), 0.0):
			J.setv(v_d, "carp", max(0.0, (J.getv(v_d, "carp") - (v_dt * 6.0))))
		if J.gt(J.getv(v_d, "bekle"), 0.0):
			J.setv(v_d, "bekle", (J.getv(v_d, "bekle") - (v_dt * (J.getv(v_d, "r") * 0.8))))
			v_i = (v_i - 1.0)
			continue
		J.setv(v_d, "v", J.add(J.getv(v_d, "v"), (v_dt * J.add(10.0, (J.getv(v_d, "r") * 26.0)))))
		J.setv(v_d, "y", J.add(J.getv(v_d, "y"), (J.getv(v_d, "v") * v_dt)))
		J.setv(v_d, "iz", min(26.0, J.add(J.getv(v_d, "iz"), ((J.getv(v_d, "v") * v_dt) * 1.5))))
		J.setv(v_d, "r", max(0.5, (J.getv(v_d, "r") - (v_dt * 0.22))))
		if J.gt(J.getv(v_d, "y"), (J.add(J.getv(v_Gl, "y"), J.getv(v_Gl, "h")) - 2.0)):
			J.method(v_D, "splice", [v_i, 1.0])
		v_i = (v_i - 1.0)
	return null

