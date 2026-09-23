# Math utils. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# core.js:98
func f_clamp(p_v: Variant = null, p_a: Variant = null, p_b: Variant = null) -> Variant:
	var v_v: Variant = p_v
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	return (v_a if J.lt(v_v, v_a) else (v_b if J.gt(v_v, v_b) else v_v))
	return null

# core.js:99
func f_lerp(p_a: Variant = null, p_b: Variant = null, p_t: Variant = null) -> Variant:
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	var v_t: Variant = p_t
	return J.add(v_a, ((v_b - v_a) * v_t))
	return null

# core.js:100
func f_approach(p_a: Variant = null, p_b: Variant = null, p_d: Variant = null) -> Variant:
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	var v_d: Variant = p_d
	return (min(J.add(v_a, v_d), v_b) if J.lt(v_a, v_b) else max((v_a - v_d), v_b))
	return null

# core.js:101
func f_sat(p_v: Variant = null) -> Variant:
	var v_v: Variant = p_v
	return (0.0 if J.lt(v_v, 0.0) else (1.0 if J.gt(v_v, 1.0) else v_v))
	return null

# core.js:102
func f_ease(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	return ((v_t * v_t) * (3.0 - (2.0 * v_t)))
	return null

# core.js:103
func f_easeOut(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	return (1.0 - ((1.0 - v_t) * (1.0 - v_t)))
	return null

# core.js:104
func f_easeIn(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	return (v_t * v_t)
	return null

# core.js:105
func f_easeOutBack(p_t: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_t: Variant = p_t
	v_c = 1.70158
	return J.add(J.add(1.0, (J.add(v_c, 1.0) * pow((v_t - 1.0), 3.0))), (v_c * pow((v_t - 1.0), 2.0)))
	return null

# core.js:106
func f_easeOutElastic(p_t: Variant = null) -> Variant:
	var v_p: Variant = null
	var v_t: Variant = p_t
	if J.le(v_t, 0.0):
		return 0.0
	if J.ge(v_t, 1.0):
		return 1.0
	v_p = 0.35
	return J.add((pow(2.0, ((-J.n(10.0)) * v_t)) * sin((float(((v_t - (float(v_p) / float(4.0))) * (2.0 * J.getv({"PI": PI}, "PI")))) / float(v_p)))), 1.0)
	return null

# core.js:107
func f_easeInOut(p_t: Variant = null) -> Variant:
	var v_t: Variant = p_t
	return (((2.0 * v_t) * v_t) if J.lt(v_t, 0.5) else (1.0 - (float(pow(J.add(((-J.n(2.0)) * v_t), 2.0), 2.0)) / float(2.0))))
	return null

# core.js:109
func f_rnd(p_a: Variant = null, p_b: Variant = null) -> Variant:
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	if J.eq(v_a, null):
		return game.random_unit()
	if J.eq(v_b, null):
		return (game.random_unit() * v_a)
	return J.add(v_a, (game.random_unit() * (v_b - v_a)))
	return null

# core.js:110
func f_rndi(p_a: Variant = null, p_b: Variant = null) -> Variant:
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	return floor(game.math_utils.f_rnd(v_a, J.add(v_b, 1.0)))
	return null

# core.js:111
func f_pick(p_arr: Variant = null) -> Variant:
	var v_arr: Variant = p_arr
	return J.getv(v_arr, floor((game.random_unit() * J.getv(v_arr, "length"))))
	return null

# core.js:112
func f_chance(p_p: Variant = null) -> Variant:
	var v_p: Variant = p_p
	return J.lt(game.random_unit(), v_p)
	return null

# core.js:113
func f_shuffle(p_a: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_j: Variant = null
	var v_t: Variant = null
	var v_a: Variant = p_a
	v_i = (J.getv(v_a, "length") - 1.0)
	while J.gt(v_i, 0.0):
		v_j = floor((game.random_unit() * J.add(v_i, 1.0)))
		v_t = J.getv(v_a, v_i)
		J.setv(v_a, v_i, J.getv(v_a, v_j))
		J.setv(v_a, v_j, v_t)
		v_i = (v_i - 1.0)
	return v_a
	return null

# core.js:115
func f_dist(p_x1: Variant = null, p_y1: Variant = null, p_x2: Variant = null, p_y2: Variant = null) -> Variant:
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_x1: Variant = p_x1
	var v_y1: Variant = p_y1
	var v_x2: Variant = p_x2
	var v_y2: Variant = p_y2
	v_dx = (v_x2 - v_x1)
	v_dy = (v_y2 - v_y1)
	return sqrt(J.add((v_dx * v_dx), (v_dy * v_dy)))
	return null

# core.js:116
func f_inRect(p_px: Variant = null, p_py: Variant = null, p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_px: Variant = p_px
	var v_py: Variant = p_py
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	return (J.lt(v_py, J.add(v_y, v_h)) if ((J.ge(v_px, v_x) and J.lt(v_px, J.add(v_x, v_w))) and J.ge(v_py, v_y)) else (J.ge(v_py, v_y) if (J.ge(v_px, v_x) and J.lt(v_px, J.add(v_x, v_w))) else (J.lt(v_px, J.add(v_x, v_w)) if J.ge(v_px, v_x) else J.ge(v_px, v_x))))
	return null

# core.js:118
func f_fmtMoney(p_n: Variant = null) -> Variant:
	var v_neg: Variant = null
	var v_s: Variant = null
	var v_out: Variant = null
	var v_i: Variant = null
	var v_n: Variant = p_n
	v_n = floor((v_n if J.truth(v_n) else 0.0) + 0.5)
	v_neg = J.lt(v_n, 0.0)
	if J.truth(v_neg):
		v_n = (-J.n(v_n))
	v_s = J.add("", v_n)
	v_out = ""
	v_i = 0.0
	while J.lt(v_i, J.getv(v_s, "length")):
		if (J.gt(v_i, 0.0) and J.eq(fmod(J.n((J.getv(v_s, "length") - v_i)), J.n(3.0)), 0.0)):
			v_out = J.add(v_out, ".")
		v_out = J.add(v_out, J.getv(v_s, v_i))
		v_i = J.add(v_i, 1.0)
	return J.add(("-" if J.truth(v_neg) else ""), v_out)
	return null

# core.js:129
func f_fmtShort(p_n: Variant = null) -> Variant:
	var v_n: Variant = p_n
	v_n = floor((v_n if J.truth(v_n) else 0.0) + 0.5)
	if J.ge(v_n, 1000000.0):
		return J.add(J.method((float(v_n) / float(1000000.0)), "toFixed", [(1.0 if J.ge(v_n, 10000000.0) else 2.0)]), "M")
	if J.ge(v_n, 10000.0):
		return J.add(floor((float(v_n) / float(1000.0)) + 0.5), "K")
	return game.math_utils.f_fmtMoney(v_n)
	return null

# core.js:135
func f_fmtTime(p_sec: Variant = null) -> Variant:
	var v_m: Variant = null
	var v_s: Variant = null
	var v_sec: Variant = p_sec
	v_sec = max(0.0, ceil(v_sec))
	v_m = floor((float(v_sec) / float(60.0)))
	v_s = fmod(J.n(v_sec), J.n(60.0))
	return J.add(J.add(J.add(v_m, ":"), ("0" if J.lt(v_s, 10.0) else "")), v_s)
	return null

