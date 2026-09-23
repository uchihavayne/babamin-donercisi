# Window draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:1462
func f_bakeWinOver() -> Variant:
	var _cells: Dictionary = {"iy": [null], "ih": [null]}
	var v_Wn: Variant = null
	var v_G0: Variant = null
	var v_c: Variant = null
	var v_g2: Variant = null
	var v_old: Variant = null
	var v_ox: Variant = null
	var v_oy: Variant = null
	var v_ix: Variant = null
	var v_iw: Variant = null
	var v_i: Variant = null
	var v_m1: Variant = null
	var v_m2: Variant = null
	var v_sy2: Variant = null
	var v_v: Variant = null
	v_Wn = J.getv(game.j_LAY, "win")
	v_G0 = J.getv(game.j_LAY, "glass")
	v_c = Canvas.new()
	J.setv(v_c, "width", J.add(J.getv(v_Wn, "w"), 12.0))
	J.setv(v_c, "height", J.add(J.getv(v_Wn, "h"), 16.0))
	v_g2 = J.method(v_c, "getContext", ["2d"])
	J.setv(v_g2, "imageSmoothingEnabled", false)
	v_old = game.j_ctx
	game.j_ctx = v_g2
	v_ox = 6.0
	v_oy = 4.0
	v_ix = J.add(v_ox, (J.getv(v_G0, "x") - J.getv(v_Wn, "x")))
	_cells["iy"][0] = J.add(v_oy, (J.getv(v_G0, "y") - J.getv(v_Wn, "y")))
	v_iw = J.getv(v_G0, "w")
	_cells["ih"][0] = J.getv(v_G0, "h")
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [v_ix, _cells["iy"][0], v_iw, _cells["ih"][0]])
	J.method(game.j_ctx, "clip", [])
	J.setv(game.j_ctx, "globalAlpha", 0.08)
	v_i = 0.0
	while J.lt(v_i, _cells["ih"][0]):
		game.f_fr(J.add(J.add(v_ix, 26.0), v_i), J.add(_cells["iy"][0], v_i), 26.0, 1.0, "#ffffff")
		game.f_fr(J.add(J.add(v_ix, 62.0), v_i), J.add(_cells["iy"][0], v_i), 11.0, 1.0, "#ffffff")
		game.f_fr(J.add(J.add(v_ix, 152.0), v_i), J.add(_cells["iy"][0], v_i), 18.0, 1.0, "#ffffff")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.05)
	game.f_fr(v_ix, _cells["iy"][0], v_iw, floor((_cells["ih"][0] * 0.45) + 0.5), "#cfe6f2")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	v_m1 = J.add(v_ix, floor((float(v_iw) / float(3.0)) + 0.5))
	v_m2 = J.add(v_ix, floor((float((v_iw * 2.0)) / float(3.0)) + 0.5))
	J.method([v_m1, v_m2], "forEach", [game.window_draw._closure_56.bind({"206:iy": _cells["iy"], "206:ih": _cells["ih"]})])
	game.f_fr(v_ox, v_oy, J.getv(v_Wn, "w"), 5.0, "#333940")
	game.f_fr(v_ox, v_oy, J.getv(v_Wn, "w"), 4.0, "#4c545d")
	game.f_hl(v_ox, v_oy, J.getv(v_Wn, "w"), "#79838d")
	game.f_fr(v_ox, (J.add(v_oy, J.getv(v_Wn, "h")) - 5.0), J.getv(v_Wn, "w"), 5.0, "#2b3037")
	game.f_fr(v_ox, v_oy, 5.0, J.getv(v_Wn, "h"), "#333940")
	game.f_fr(v_ox, v_oy, 4.0, J.getv(v_Wn, "h"), "#4c545d")
	game.f_vl(v_ox, v_oy, J.getv(v_Wn, "h"), "#79838d")
	game.f_fr((J.add(v_ox, J.getv(v_Wn, "w")) - 5.0), v_oy, 5.0, J.getv(v_Wn, "h"), "#2b3037")
	game.f_vl((J.add(v_ox, J.getv(v_Wn, "w")) - 1.0), v_oy, J.getv(v_Wn, "h"), "#1d2126")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_fr(v_ix, _cells["iy"][0], v_iw, 3.0, "#000")
	game.f_fr(v_ix, _cells["iy"][0], 3.0, _cells["ih"][0], "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_sy2 = (J.add(v_oy, J.getv(v_Wn, "h")) - 2.0)
	game.f_fr((v_ox - 6.0), v_sy2, J.add(J.getv(v_Wn, "w"), 12.0), 7.0, "#8d8577")
	game.f_fr((v_ox - 6.0), v_sy2, J.add(J.getv(v_Wn, "w"), 12.0), 6.0, "#c9c2b0")
	game.f_hl((v_ox - 6.0), v_sy2, J.add(J.getv(v_Wn, "w"), 12.0), "#e8e2d0")
	v_v = 0.0
	while J.lt(v_v, 22.0):
		J.setv(game.j_ctx, "globalAlpha", 0.18)
		game.f_hl(J.add((v_ox - 4.0), (game.f_hash1((v_v * 3.9)) * J.add(J.getv(v_Wn, "w"), 4.0))), J.add(J.add(v_sy2, 1.0), fmod(J.n(v_v), J.n(4.0))), J.add(5.0, (game.f_hash1(v_v) * 9.0)), "#8d8577")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_v = J.add(v_v, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr((v_ox - 6.0), J.add(v_sy2, 6.0), J.add(J.getv(v_Wn, "w"), 12.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.j_ctx = v_old
	game.j_WINOVER = {"c": v_c, "ox": v_ox, "oy": v_oy}
	return null

# art.js:1516
func f_drawWallCam(p_t: Variant = null, p_alert: Variant = null) -> Variant:
	var v_cx0: Variant = null
	var v_cy0: Variant = null
	var v_on: Variant = null
	var v_t: Variant = p_t
	var v_alert: Variant = p_alert
	v_cx0 = 424.0
	v_cy0 = 30.0
	game.f_fr(J.add(v_cx0, 10.0), (v_cy0 - 2.0), 5.0, 8.0, "#3a4149")
	game.f_hl(J.add(v_cx0, 10.0), (v_cy0 - 2.0), 5.0, "#5f6a75")
	game.f_fr(v_cx0, J.add(v_cy0, 3.0), 15.0, 8.0, "#2b3037")
	game.f_fr(J.add(v_cx0, 1.0), J.add(v_cy0, 4.0), 13.0, 6.0, "#4a545f")
	game.f_hl(J.add(v_cx0, 1.0), J.add(v_cy0, 4.0), 13.0, "#6d7a86")
	game.f_fr((v_cx0 - 4.0), J.add(v_cy0, 5.0), 5.0, 5.0, "#1b1f26")
	game.f_disc((v_cx0 - 2.0), J.add(v_cy0, 7.0), 2.0, "#0d1015")
	game.f_px((v_cx0 - 3.0), J.add(v_cy0, 6.0), "#8fb4d8")
	v_on = J.gt(sin((v_t * 6.0)), 0.0)
	game.f_disc(J.add(v_cx0, 12.0), J.add(v_cy0, 6.0), 1.0, ("#ff4a3a" if J.truth(v_on) else "#5a2a26"))
	if (J.truth(v_on) and J.truth(v_alert)):
		J.setv(game.j_ctx, "globalAlpha", 0.16)
		game.f_disc(J.add(v_cx0, 12.0), J.add(v_cy0, 6.0), 5.0, "#ff4a3a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:1532
func f_drawShutter(p_k: Variant = null) -> Variant:
	var v_G0: Variant = null
	var v_hgt: Variant = null
	var v_yy: Variant = null
	var v_band: Variant = null
	var v_vx: Variant = null
	var v_sp: Variant = null
	var v_rh: Variant = null
	var v_rr: Variant = null
	var v_k: Variant = p_k
	v_G0 = J.getv(game.j_LAY, "glass")
	v_k = game.math_utils.f_clamp(v_k, 0.0, 1.0)
	v_hgt = floor((J.getv(v_G0, "h") * v_k) + 0.5)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [J.getv(v_G0, "x"), J.getv(v_G0, "y"), J.getv(v_G0, "w"), J.getv(v_G0, "h")])
	J.method(game.j_ctx, "clip", [])
	if J.gt(v_hgt, 2.0):
		v_yy = 0.0
		while J.lt(v_yy, (v_hgt - 3.0)):
			v_band = fmod(J.n(v_yy), J.n(3.0))
			game.f_fr(J.getv(v_G0, "x"), J.add(J.getv(v_G0, "y"), v_yy), J.getv(v_G0, "w"), 1.0, ("#6d757e" if J.eq(v_band, 0.0) else ("#98a1aa" if J.eq(v_band, 1.0) else "#565e66")))
			v_yy = J.add(v_yy, 1.0)
		v_vx = J.add(J.getv(v_G0, "x"), 4.0)
		while J.lt(v_vx, J.add(J.getv(v_G0, "x"), J.getv(v_G0, "w"))):
			J.setv(game.j_ctx, "globalAlpha", 0.16)
			game.f_vl(v_vx, J.getv(v_G0, "y"), (v_hgt - 3.0), "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			J.setv(game.j_ctx, "globalAlpha", 0.1)
			game.f_vl(J.add(v_vx, 1.0), J.getv(v_G0, "y"), (v_hgt - 3.0), "#ffffff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_vx = J.add(v_vx, 11.0)
		v_sp = 0.0
		while J.lt(v_sp, 20.0):
			J.setv(game.j_ctx, "globalAlpha", 0.1)
			game.f_fr(J.add(J.getv(v_G0, "x"), (game.f_hash1((v_sp * 3.1)) * J.getv(v_G0, "w"))), J.add(J.getv(v_G0, "y"), (game.f_hash1((v_sp * 5.7)) * max(1.0, (v_hgt - 6.0)))), J.add(3.0, (game.f_hash1(v_sp) * 7.0)), 2.0, "#3a2a22")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_sp = J.add(v_sp, 1.0)
		game.f_fr(J.getv(v_G0, "x"), (J.add(J.getv(v_G0, "y"), v_hgt) - 4.0), J.getv(v_G0, "w"), 4.0, "#353b42")
		game.f_fr(J.getv(v_G0, "x"), (J.add(J.getv(v_G0, "y"), v_hgt) - 4.0), J.getv(v_G0, "w"), 3.0, "#5b636c")
		game.f_hl(J.getv(v_G0, "x"), (J.add(J.getv(v_G0, "y"), v_hgt) - 4.0), J.getv(v_G0, "w"), "#9aa3ac")
		game.f_fr((J.add(J.getv(v_G0, "x"), (float(J.getv(v_G0, "w")) / float(2.0))) - 7.0), (J.add(J.getv(v_G0, "y"), v_hgt) - 3.0), 14.0, 3.0, "#262b31")
		game.f_hl((J.add(J.getv(v_G0, "x"), (float(J.getv(v_G0, "w")) / float(2.0))) - 7.0), (J.add(J.getv(v_G0, "y"), v_hgt) - 3.0), 14.0, "#6f777f")
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_fr(J.getv(v_G0, "x"), J.add(J.getv(v_G0, "y"), v_hgt), J.getv(v_G0, "w"), 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	if J.lt(v_k, 0.98):
		v_rh = floor(J.add(3.0, ((1.0 - v_k) * 6.0)) + 0.5)
		game.f_fr((J.getv(v_G0, "x") - 2.0), J.add((J.getv(v_G0, "y") - v_rh), 1.0), J.add(J.getv(v_G0, "w"), 4.0), v_rh, "#3f464e")
		game.f_fr((J.getv(v_G0, "x") - 2.0), J.add((J.getv(v_G0, "y") - v_rh), 1.0), J.add(J.getv(v_G0, "w"), 4.0), (v_rh - 1.0), "#6d757e")
		v_rr = 1.0
		while J.lt(v_rr, (v_rh - 1.0)):
			game.f_hl((J.getv(v_G0, "x") - 2.0), J.add(J.add((J.getv(v_G0, "y") - v_rh), 1.0), v_rr), J.add(J.getv(v_G0, "w"), 4.0), "#4d555d")
			v_rr = J.add(v_rr, 2.0)
		game.f_hl((J.getv(v_G0, "x") - 2.0), J.add((J.getv(v_G0, "y") - v_rh), 1.0), J.add(J.getv(v_G0, "w"), 4.0), "#9aa3ac")
	return null

func _closure_56(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_mx: Variant = null
	v_mx = J.arg(_args, 0)
	game.f_fr((v_mx - 2.0), _captures["206:iy"][0], 5.0, _captures["206:ih"][0], "#333940")
	game.f_fr((v_mx - 2.0), _captures["206:iy"][0], 4.0, _captures["206:ih"][0], "#4c545d")
	game.f_vl((v_mx - 2.0), _captures["206:iy"][0], _captures["206:ih"][0], "#79838d")
	game.f_vl(J.add(v_mx, 2.0), _captures["206:iy"][0], _captures["206:ih"][0], "#23282e")
	return null

