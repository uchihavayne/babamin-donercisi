# Text draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# core.js:428
func f_fontAtlas(p_col: Variant = null) -> Variant:
	var v_keys: Variant = null
	var v_c: Variant = null
	var v_g: Variant = null
	var v_map: Variant = null
	var v_ox: Variant = null
	var v_k: Variant = null
	var v_ch: Variant = null
	var v_gl: Variant = null
	var v_y: Variant = null
	var v_row: Variant = null
	var v_x: Variant = null
	var v_col: Variant = p_col
	if J.truth(J.getv(game.j__atlas, v_col)):
		return J.getv(game.j__atlas, v_col)
	v_keys = J.keys(game.j_FONT)
	v_c = Canvas.new()
	J.setv(v_c, "width", (J.getv(v_keys, "length") * 6.0))
	J.setv(v_c, "height", game.j_FONT_H)
	v_g = J.method(v_c, "getContext", ["2d"])
	J.setv(v_g, "fillStyle", v_col)
	v_map = {}
	v_ox = 0.0
	v_k = 0.0
	while J.lt(v_k, J.getv(v_keys, "length")):
		v_ch = J.getv(v_keys, v_k)
		v_gl = J.getv(game.j_FONT, v_ch)
		J.setv(v_map, v_ch, v_ox)
		v_y = 0.0
		while J.lt(v_y, J.getv(J.getv(v_gl, "rows"), "length")):
			v_row = J.getv(J.getv(v_gl, "rows"), v_y)
			v_x = 0.0
			while J.lt(v_x, J.getv(v_gl, "w")):
				if J.eq(J.getv(v_row, J.add(J.getv(v_gl, "x0"), v_x)), "#"):
					J.method(v_g, "fillRect", [J.add(v_ox, v_x), v_y, 1.0, 1.0])
				v_x = J.add(v_x, 1.0)
			v_y = J.add(v_y, 1.0)
		v_ox = J.add(v_ox, 6.0)
		v_k = J.add(v_k, 1.0)
	J.setv(game.j__atlas, v_col, {"cv": v_c, "map": v_map})
	return J.getv(game.j__atlas, v_col)
	return null

# core.js:456
func f_txt(p_s: Variant = null, p_x: Variant = null, p_y: Variant = null, p_col: Variant = null, p_o: Variant = null) -> Variant:
	var v_sc: Variant = null
	var v_mono: Variant = null
	var v_w: Variant = null
	var v_ax: Variant = null
	var v_oc: Variant = null
	var v_dy: Variant = null
	var v_dx: Variant = null
	var v_s: Variant = p_s
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_col: Variant = p_col
	var v_o: Variant = p_o
	v_s = game.localization.f_T(v_s)
	v_o = (v_o if J.truth(v_o) else {})
	v_sc = (J.getv(v_o, "sc") if J.truth(J.getv(v_o, "sc")) else 1.0)
	v_s = J.add("", v_s)
	v_mono = J.getv(v_o, "mono")
	v_w = game.f_textW(v_s, 1.0, v_mono)
	v_ax = v_x
	if J.eq(J.getv(v_o, "align"), "c"):
		v_ax = (v_x - floor((float((v_w * v_sc)) / float(2.0))))
	else:
		if J.eq(J.getv(v_o, "align"), "r"):
			v_ax = (v_x - (v_w * v_sc))
	v_ax = floor(v_ax + 0.5)
	v_y = floor(v_y + 0.5)
	if J.truth(J.getv(v_o, "outline")):
		v_oc = (J.getv(game.j_P, "ui5") if J.eq(J.getv(v_o, "outline"), true) else J.getv(v_o, "outline"))
		v_dy = (-J.n(1.0))
		while J.le(v_dy, 1.0):
			v_dx = (-J.n(1.0))
			while J.le(v_dx, 1.0):
				if (J.truth(v_dx) or J.truth(v_dy)):
					game.f_drawStr(v_s, J.add(v_ax, (v_dx * v_sc)), J.add(v_y, (v_dy * v_sc)), v_oc, v_sc, v_mono)
				v_dx = J.add(v_dx, 1.0)
			v_dy = J.add(v_dy, 1.0)
	else:
		if J.truth(J.getv(v_o, "shadow")):
			game.f_drawStr(v_s, J.add(v_ax, v_sc), J.add(v_y, v_sc), (J.getv(v_o, "shcol") if J.truth(J.getv(v_o, "shcol")) else "rgba(0,0,0,.5)"), v_sc, v_mono)
	game.f_drawStr(v_s, v_ax, v_y, v_col, v_sc, v_mono)
	return (v_w * v_sc)
	return null

