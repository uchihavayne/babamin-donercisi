# Logo draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# logo.js:50
func f_logoDil() -> Variant:
	return (game.j_LANG if (not J.eq(J.kind(game.j_LOGO_VERI), "undefined") and J.truth(J.getv(J.getv(game.j_LOGO_VERI, "on"), game.j_LANG))) else "en")
	return null

# logo.js:54
func f_logoHazir() -> Variant:
	var v_im: Variant = null
	v_im = J.getv(game.j_LOGO, "im")
	return (not (not ((J.truth(J.getv(v_im, "arka")) and J.truth(J.getv(v_im, "sis"))) and J.truth(J.getv(v_im, J.add("on_", game.logo_draw.f_logoDil()))))))
	return null

# logo.js:63
func f_logoGiris(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	if J.gt((v_t - J.getv(game.j_LOGO, "son")), 0.5):
		J.setv(game.j_LOGO, "giris", v_t)
	J.setv(game.j_LOGO, "son", v_t)
	return null

# logo.js:69
func f_logoYukseklik() -> Variant:
	return (56.0 if J.eq(J.kind(game.j_LOGO_VERI), "undefined") else J.getv(game.j_LOGO_VERI, "h"))
	return null

# logo.js:74
func f_logoIsiticiKare(p_t: Variant = null) -> Variant:
	var v_A: Variant = null
	var v_u: Variant = null
	var v_t: Variant = p_t
	v_A = J.getv(game.j_LOGO_VERI, "arka")
	v_u = ((v_t - J.getv(game.j_LOGO, "giris")) - J.getv(v_A, "yakBas"))
	if J.lt(v_u, 0.0):
		return 0.0
	if J.lt(v_u, (J.getv(v_A, "yakAdim") * J.getv(v_A, "yak"))):
		return min((J.getv(v_A, "yak") - 1.0), floor((float(v_u) / float(J.getv(v_A, "yakAdim")))))
	return J.add(J.getv(v_A, "yak"), fmod(J.n(floor((v_t * J.getv(v_A, "titFps")))), J.n(J.getv(v_A, "tit"))))
	return null

# logo.js:80
func f_logoYandi(p_t: Variant = null) -> Variant:
	var v_A: Variant = null
	var v_t: Variant = p_t
	v_A = J.getv(game.j_LOGO_VERI, "arka")
	return J.ge(((v_t - J.getv(game.j_LOGO, "giris")) - J.getv(v_A, "yakBas")), (J.getv(v_A, "yakAdim") * J.getv(v_A, "yak")))
	return null

# logo.js:86
func f_logoCiz(p_t: Variant = null, p_cx: Variant = null, p_y: Variant = null) -> Variant:
	var v_V: Variant = null
	var v_dil: Variant = null
	var v_u: Variant = null
	var v_dy: Variant = null
	var v_x: Variant = null
	var v_A: Variant = null
	var v_k: Variant = null
	var v_S: Variant = null
	var v_f: Variant = null
	var v_O: Variant = null
	var v_p: Variant = null
	var v_faz: Variant = null
	var v_I: Variant = null
	var v_sag: Variant = null
	var v_t: Variant = p_t
	var v_cx: Variant = p_cx
	var v_y: Variant = p_y
	if (J.eq(J.kind(game.j_LOGO_VERI), "undefined") or (not J.truth(game.logo_draw.f_logoHazir()))):
		return false
	v_V = game.j_LOGO_VERI
	v_dil = game.logo_draw.f_logoDil()
	if not J.eq(J.getv(game.j_LOGO, "dil"), v_dil):
		if not J.eq(J.getv(game.j_LOGO, "dil"), null):
			J.setv(game.j_LOGO, "dilT", v_t)
		J.setv(game.j_LOGO, "dil", v_dil)
	v_u = (v_t - J.getv(game.j_LOGO, "giris"))
	v_dy = ((-J.n(floor(((1.0 - game.math_utils.f_easeOutBack(game.math_utils.f_clamp((float(v_u) / float(game.j_LOGO_DUSUS)), 0.0, 1.0))) * 26.0) + 0.5))) if J.lt(v_u, game.j_LOGO_DUSUS) else 0.0)
	v_x = floor((v_cx - J.getv(v_V, "cx")) + 0.5)
	v_y = J.add(floor(v_y + 0.5), v_dy)
	J.setv(game.j_ctx, "imageSmoothingEnabled", false)
	v_A = J.getv(v_V, "arka")
	v_k = game.logo_draw.f_logoIsiticiKare(v_t)
	J.method(game.j_ctx, "drawImage", [J.getv(J.getv(game.j_LOGO, "im"), "arka"), (v_k * J.getv(v_A, "kw")), 0.0, J.getv(v_A, "kw"), J.getv(v_A, "kh"), J.add(v_x, J.getv(v_A, "x")), J.add(v_y, J.getv(v_A, "y")), J.getv(v_A, "kw"), J.getv(v_A, "kh")])
	v_S = J.getv(v_V, "sis")
	v_f = fmod(J.n(floor((float((v_t * J.getv(v_S, "n"))) / float(J.getv(v_S, "turSn"))))), J.n(J.getv(v_S, "n")))
	J.method(game.j_ctx, "drawImage", [J.getv(J.getv(game.j_LOGO, "im"), "sis"), (fmod(J.n(v_f), J.n(J.getv(v_S, "sut"))) * J.getv(v_S, "kw")), (floor((float(v_f) / float(J.getv(v_S, "sut")))) * J.getv(v_S, "kh")), J.getv(v_S, "kw"), J.getv(v_S, "kh"), J.add(v_x, J.getv(v_S, "x")), J.add(v_y, J.getv(v_S, "y")), J.getv(v_S, "kw"), J.getv(v_S, "kh")])
	v_O = J.getv(J.getv(v_V, "on"), v_dil)
	J.method(game.j_ctx, "drawImage", [J.getv(J.getv(game.j_LOGO, "im"), J.add("on_", v_dil)), J.add(v_x, J.getv(v_O, "x")), J.add(v_y, J.getv(v_O, "y"))])
	v_p = (-J.n(1.0))
	if J.lt((v_t - J.getv(game.j_LOGO, "dilT")), game.j_LOGO_PARILTI):
		v_p = (float((v_t - J.getv(game.j_LOGO, "dilT"))) / float(game.j_LOGO_PARILTI))
	else:
		if J.gt(v_u, 1.4):
			v_faz = fmod(J.n((v_u - 1.4)), J.n(game.j_LOGO_PARILTI_ARA))
			if J.lt(v_faz, game.j_LOGO_PARILTI):
				v_p = (float(v_faz) / float(game.j_LOGO_PARILTI))
	if J.ge(v_p, 0.0):
		game.logo_draw.f_logoParilti(v_O, J.getv(J.getv(game.j_LOGO, "im"), J.add("maske_", v_dil)), J.add(v_x, J.getv(v_O, "x")), J.add(v_y, J.getv(v_O, "y")), v_p)
	if (J.truth(game.logo_draw.f_logoYandi(v_t)) and J.eq(v_dy, 0.0)):
		if J.truth(game.f_chance(0.07)):
			game.effects.f_smoke(J.add(J.add(v_x, J.getv(J.getv(v_S, "tepe"), 0.0)), game.math_utils.f_rnd((-J.n(9.0)), 9.0)), J.add(J.add(v_y, J.getv(J.getv(v_S, "tepe"), 1.0)), 7.0), 1.0, "rgba(255,248,236,.55)", {"sz": 2.0})
		if J.truth(game.f_chance(0.1)):
			v_I = J.getv(v_V, "isitici")
			v_sag = game.f_chance(0.5)
			game.effects.f_part({"x": J.add(v_x, (game.math_utils.f_rnd((J.getv(v_I, 2.0) - 16.0), (J.getv(v_I, 2.0) - 4.0)) if J.truth(v_sag) else game.math_utils.f_rnd(J.add(J.getv(v_I, 0.0), 4.0), J.add(J.getv(v_I, 0.0), 16.0)))), "y": J.add(J.add(v_y, J.getv(v_I, 1.0)), game.math_utils.f_rnd(4.0, 14.0)), "vx": game.math_utils.f_rnd((-J.n(5.0)), 5.0), "vy": game.math_utils.f_rnd((-J.n(26.0)), (-J.n(12.0))), "life": game.math_utils.f_rnd(0.5, 1.0), "col": game.math_utils.f_pick([J.getv(game.j_P, "f1"), J.getv(game.j_P, "f2"), J.getv(game.j_P, "f0")]), "g": (-J.n(10.0)), "sz": 1.0})
	return true
	return null

# logo.js:140
func f_logoParilti(p_O: Variant = null, p_maske: Variant = null, p_x: Variant = null, p_y: Variant = null, p_p: Variant = null) -> Variant:
	var _v: Dictionary = {"pc": null, "e": null, "g": null, "bx0": null, "yy": null, "bx": null, "O": p_O, "maske": p_maske, "x": p_x, "y": p_y, "p": p_p}
	if (not J.truth(_v["maske"])):
		return null
	_v["pc"] = J.getv(game.j_LOGO, "pc")
	if (not J.truth(_v["pc"])):
		_v["pc"] = J.setv(game.j_LOGO, "pc", Canvas.new())
	if (not J.eq(J.getv(_v["pc"], "width"), J.getv(_v["O"], "w")) or not J.eq(J.getv(_v["pc"], "height"), J.getv(_v["O"], "h"))):
		J.setv(_v["pc"], "width", J.getv(_v["O"], "w"))
		J.setv(_v["pc"], "height", J.getv(_v["O"], "h"))
	_v["g"] = J.method(_v["pc"], "getContext", ["2d"])
	if (not J.truth(_v["g"])):
		return null
	J.setv(_v["g"], "imageSmoothingEnabled", false)
	J.setv(_v["g"], "globalCompositeOperation", "source-over")
	J.method(_v["g"], "clearRect", [0.0, 0.0, J.getv(_v["O"], "w"), J.getv(_v["O"], "h")])
	_v["bx0"] = J.add((-J.n(20.0)), (_v["p"] * J.add(J.getv(_v["O"], "w"), 60.0)))
	_v["yy"] = 0.0
	while J.lt(_v["yy"], J.getv(_v["O"], "h")):
		_v["bx"] = floor((_v["bx0"] - ((J.getv(_v["O"], "h") - _v["yy"]) * 0.5)) + 0.5)
		J.setv(_v["g"], "fillStyle", J.getv(game.j_P, "au0"))
		J.method(_v["g"], "fillRect", [(_v["bx"] - 2.0), _v["yy"], 5.0, 1.0])
		J.setv(_v["g"], "fillStyle", J.getv(game.j_P, "white"))
		J.method(_v["g"], "fillRect", [(_v["bx"] - 1.0), _v["yy"], 3.0, 1.0])
		_v["yy"] = J.add(_v["yy"], 1.0)
	J.setv(_v["g"], "globalCompositeOperation", "destination-in")
	J.method(_v["g"], "drawImage", [_v["maske"], 0.0, 0.0])
	J.setv(_v["g"], "globalCompositeOperation", "source-over")
	J.method(game.j_ctx, "drawImage", [_v["pc"], _v["x"], _v["y"]])
	return null
