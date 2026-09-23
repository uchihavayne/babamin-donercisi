# Sprite draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# sprites.js:162
func f_sprVar(p_id: Variant = null, p_mini: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_im: Variant = null
	var v_id: Variant = p_id
	var v_mini: Variant = p_mini
	v_a = J.getv(game.j_SPR, v_id)
	if (not J.truth(v_a)):
		return false
	v_im = (J.getv(v_a, "imM") if J.truth(v_mini) else J.getv(v_a, "im"))
	return (not (not (J.truth(v_im) and J.truth(J.getv(v_im, "naturalWidth")))))
	return null

# sprites.js:168
func f_sprYuklendi() -> Variant:
	return (J.ge(game.j_SPR_TAMAM, game.j_SPR_ISTEK) if J.gt(game.j_SPR_ISTEK, 0.0) else J.gt(game.j_SPR_ISTEK, 0.0))
	return null

# sprites.js:173
func f_sprKare(p_id: Variant = null, p_klip: Variant = null, p_t: Variant = null, p_u: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_c: Variant = null
	var v_i: Variant = null
	var v_id: Variant = p_id
	var v_klip: Variant = p_klip
	var v_t: Variant = p_t
	var v_u: Variant = p_u
	v_a = J.getv(game.j_SPR, v_id)
	v_c = (J.getv(J.getv(v_a, "klip"), v_klip) if J.truth(v_a) else v_a)
	if (not J.truth(v_c)):
		return 0.0
	if (not J.eq(v_u, null) and not J.eq(v_u, null)):
		return game.math_utils.f_clamp(floor((v_u * J.getv(v_c, "n"))), 0.0, (J.getv(v_c, "n") - 1.0))
	v_i = floor((v_t * J.getv(v_c, "fps")))
	return (fmod(J.n(J.add(fmod(J.n(v_i), J.n(J.getv(v_c, "n"))), J.getv(v_c, "n"))), J.n(J.getv(v_c, "n"))) if J.truth(J.getv(v_c, "d")) else game.math_utils.f_clamp(v_i, 0.0, (J.getv(v_c, "n") - 1.0)))
	return null

# sprites.js:191
func f_sprCiz(p_id: Variant = null, p_klip: Variant = null, p_t: Variant = null, p_x: Variant = null, p_y: Variant = null, p_o: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_mini: Variant = null
	var v_im: Variant = null
	var v_c: Variant = null
	var v_kw: Variant = null
	var v_kh: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_f: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_eskiA: Variant = null
	var v_kirp: Variant = null
	var v_id: Variant = p_id
	var v_klip: Variant = p_klip
	var v_t: Variant = p_t
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_o: Variant = p_o
	v_o = (v_o if J.truth(v_o) else {})
	v_a = J.getv(game.j_SPR, v_id)
	if (not J.truth(v_a)):
		return false
	v_mini = (not (not J.truth(J.getv(v_o, "mini"))))
	v_im = (J.getv(v_a, "imM") if J.truth(v_mini) else J.getv(v_a, "im"))
	if ((not J.truth(v_im)) or (not J.truth(J.getv(v_im, "naturalWidth")))):
		return false
	v_c = J.getv(J.getv(v_a, "klip"), v_klip)
	if (not J.truth(v_c)):
		return false
	v_kw = (J.getv(v_a, "kwM") if J.truth(v_mini) else J.getv(v_a, "kw"))
	v_kh = (J.getv(v_a, "khM") if J.truth(v_mini) else J.getv(v_a, "kh"))
	v_ax = (J.getv(v_a, "axM") if J.truth(v_mini) else J.getv(v_a, "ax"))
	v_ay = (J.getv(v_a, "ayM") if J.truth(v_mini) else J.getv(v_a, "ay"))
	v_f = (game.math_utils.f_clamp(J.getv(v_o, "kare"), 0.0, (J.getv(v_c, "n") - 1.0)) if not J.eq(J.getv(v_o, "kare"), null) else game.sprite_draw.f_sprKare(v_id, v_klip, v_t, J.getv(v_o, "u")))
	v_sx = (fmod(J.n(v_f), J.n(J.getv(v_a, "sut"))) * v_kw)
	v_sy = (J.getv(v_c, "s") * v_kh)
	v_dx = (floor(v_x + 0.5) - v_ax)
	v_dy = (floor(v_y + 0.5) - v_ay)
	v_eskiA = J.getv(game.j_ctx, "globalAlpha")
	if not J.eq(J.getv(v_o, "alpha"), null):
		J.setv(game.j_ctx, "globalAlpha", J.getv(v_o, "alpha"))
	J.setv(game.j_ctx, "imageSmoothingEnabled", false)
	v_kirp = not J.eq(J.getv(v_o, "kesAlt"), null)
	if J.truth(v_kirp):
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "beginPath", [])
		J.method(game.j_ctx, "rect", [(v_dx - 8.0), (v_dy - 8.0), J.add(v_kw, 16.0), J.add((J.getv(v_o, "kesAlt") - v_dy), 8.0)])
		J.method(game.j_ctx, "clip", [])
	if J.truth(J.getv(v_o, "flip")):
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [(floor(v_x + 0.5) * 2.0), 0.0])
		J.method(game.j_ctx, "scale", [(-J.n(1.0)), 1.0])
		J.method(game.j_ctx, "drawImage", [v_im, v_sx, v_sy, v_kw, v_kh, v_dx, v_dy, v_kw, v_kh])
		J.method(game.j_ctx, "restore", [])
	else:
		J.method(game.j_ctx, "drawImage", [v_im, v_sx, v_sy, v_kw, v_kh, v_dx, v_dy, v_kw, v_kh])
	if J.truth(v_kirp):
		J.method(game.j_ctx, "restore", [])
	J.setv(game.j_ctx, "globalAlpha", v_eskiA)
	return true
	return null

# sprites.js:234
func f_sprSoket(p_id: Variant = null, p_ad: Variant = null, p_x: Variant = null, p_y: Variant = null, p_mini: Variant = null, p_flip: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_s: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_dx: Variant = null
	var v_id: Variant = p_id
	var v_ad: Variant = p_ad
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_mini: Variant = p_mini
	var v_flip: Variant = p_flip
	v_a = J.getv(game.j_SPR, v_id)
	if ((not J.truth(v_a)) or (not J.truth(J.getv(v_a, "soket")))):
		return null
	v_s = (J.getv((J.getv(v_a, "soketM") if J.truth(J.getv(v_a, "soketM")) else J.getv(v_a, "soket")), v_ad) if J.truth(v_mini) else J.getv(J.getv(v_a, "soket"), v_ad))
	if (not J.truth(v_s)):
		return null
	v_ax = (J.getv(v_a, "axM") if J.truth(v_mini) else J.getv(v_a, "ax"))
	v_ay = (J.getv(v_a, "ayM") if J.truth(v_mini) else J.getv(v_a, "ay"))
	v_dx = (J.getv(v_s, 0.0) - v_ax)
	return {"x": J.add(floor(v_x + 0.5), ((-J.n(v_dx)) if J.truth(v_flip) else v_dx)), "y": J.add(floor(v_y + 0.5), (J.getv(v_s, 1.0) - v_ay))}
	return null

# sprites.js:249
func f_sprMusteri(p_c: Variant = null, p_t: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_id: Variant = null
	var v_klip: Variant = null
	var v_flip: Variant = null
	var v_c: Variant = p_c
	var v_t: Variant = p_t
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	v_L = J.getv(v_c, "look")
	if ((not J.truth(v_L)) or (not J.truth(J.getv(v_L, "kalip")))):
		return false
	v_id = J.getv(game.j_SPR_KALIP, J.getv(v_L, "kalip"))
	if ((not J.truth(v_id)) or (not J.truth(game.sprite_draw.f_sprVar(v_id, false)))):
		return false
	v_klip = "idle"
	v_flip = false
	if J.eq(J.getv(v_c, "state"), "leave"):
		v_klip = "walk_side"
		v_flip = J.lt((1.0 if J.gt(J.getv(v_c, "leaveDir"), 0.0) else (-J.n(1.0))), 0.0)
	else:
		if J.eq(J.getv(v_c, "state"), "walkin"):
			v_klip = "walk_side"
			v_flip = J.lt(((J.getv(v_c, "tx") if not J.eq(J.getv(v_c, "tx"), null) else J.getv(v_c, "x")) - J.getv(v_c, "x")), 0.0)
		else:
			if (J.eq(J.getv(v_c, "mood"), "happy") or J.eq(J.getv(v_c, "mood"), "served")):
				v_klip = "greet"
	return game.sprite_draw.f_sprCiz(v_id, v_klip, J.add(v_t, ((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0) * 0.13)), v_x, J.add(v_y, 12.0), {"flip": v_flip})
	return null

# sprites.js:275
func f_sprDuygu(p_hx: Variant = null, p_hy: Variant = null, p_mood: Variant = null, p_t: Variant = null) -> Variant:
	var v_ang: Variant = null
	var v_vx: Variant = null
	var v_vy: Variant = null
	var v_hx: Variant = p_hx
	var v_hy: Variant = p_hy
	var v_mood: Variant = p_mood
	var v_t: Variant = p_t
	v_ang = J.eq(v_mood, "angry")
	if (J.truth(v_ang) and J.truth(game.f_chance(0.05))):
		game.effects.f_smoke(J.add(v_hx, game.math_utils.f_rnd((-J.n(11.0)), 11.0)), (v_hy - 13.0), 1.0, "rgba(230,90,60,.55)")
	if (J.truth(v_ang) and J.gt(sin((v_t * 8.0)), 0.0)):
		v_vx = J.add(v_hx, 8.0)
		v_vy = (v_hy - 9.0)
		game.f_px(v_vx, v_vy, "#e04a3a")
		game.f_px(J.add(v_vx, 1.0), (v_vy - 1.0), "#e04a3a")
		game.f_px(J.add(v_vx, 2.0), v_vy, "#e04a3a")
		game.f_px(J.add(v_vx, 1.0), J.add(v_vy, 1.0), "#e04a3a")
	if (J.eq(v_mood, "served") and J.truth(game.f_chance(0.06))):
		game.effects.f_part({"x": J.add(v_hx, game.math_utils.f_rnd((-J.n(9.0)), 9.0)), "y": (v_hy - 10.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(24.0)), (-J.n(12.0))), "life": 0.9, "col": "#e2483a", "g": (-J.n(8.0)), "sz": 2.0})
	return null
