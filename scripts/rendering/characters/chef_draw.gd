# Chef draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:33
func f_drawChef(p_x: Variant = null, p_y: Variant = null, p_st: Variant = null, p_t: Variant = null) -> Variant:
	var _cells: Dictionary = {"KEN": [null], "GOV": [null], "ISK": [null], "GLG": [null]}
	var v_bob: Variant = null
	var v_breathe: Variant = null
	var v_s: Variant = null
	var v_agirlik: Variant = null
	var v_zipla: Variant = null
	var v_dongu: Variant = null
	var v_jestTip: Variant = null
	var v_jestVar: Variant = null
	var v_jestK: Variant = null
	var v_kafaDon: Variant = null
	var v_hx: Variant = null
	var v_fz: Variant = null
	var v_hy: Variant = null
	var v_by: Variant = null
	var v_lgy: Variant = null
	var v_lgh: Variant = null
	var v_slTop: Variant = null
	var v_slAlt: Variant = null
	var v_slH: Variant = null
	var v_ayrimU: Variant = null
	var v_solBacak: Variant = null
	var v_sagBacak: Variant = null
	var v_bacakSerit: Variant = null
	var v_lr: Variant = null
	var v_lu: Variant = null
	var v_yy0: Variant = null
	var v_gen: Variant = null
	var v_lx0: Variant = null
	var v_t1: Variant = null
	var v_ara: Variant = null
	var v_oy: Variant = null
	var v_solG: Variant = null
	var v_sagX: Variant = null
	var v_sagG: Variant = null
	var v_kv: Variant = null
	var v_kvx: Variant = null
	var v_blY: Variant = null
	var v_blSet: Variant = null
	var v_bi2: Variant = null
	var v_bl: Variant = null
	var v_i: Variant = null
	var v_d: Variant = null
	var v_im: Variant = null
	var v_iy: Variant = null
	var v_kuy: Variant = null
	var v_kuh: Variant = null
	var v_w2: Variant = null
	var v_pu: Variant = null
	var v_armSw: Variant = null
	var v_b2: Variant = null
	var v_omzX: Variant = null
	var v_omzY: Variant = null
	var v_dinX: Variant = null
	var v_dinY: Variant = null
	var v_hedX: Variant = null
	var v_hedY: Variant = null
	var v_elX: Variant = null
	var v_elY: Variant = null
	var v_kk: Variant = null
	var v_u4: Variant = null
	var v_ax2: Variant = null
	var v_ay2: Variant = null
	var v_tsw: Variant = null
	var v_kasY: Variant = null
	var v_blink: Variant = null
	var v_lookx: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_st: Variant = p_st
	var v_t: Variant = p_t
	v_bacakSerit = game.chef_draw._closure_80.bind({"350:KEN": _cells["KEN"], "350:GOV": _cells["GOV"], "350:ISK": _cells["ISK"], "350:GLG": _cells["GLG"]})
	if J.truth(game.j_NOCHEF):
		return null
	# REMAKE kancasi: HD Dayi (Blender katmanlari) cizerse eski cizim atlanir
	if game.f_dayiHD(v_x, v_y, v_st, v_t):
		return null
	v_bob = (sin((v_t * 1.7)) * 1.0)
	v_breathe = (sin((v_t * 2.4)) * 0.7)
	v_s = J.getv(game.j_SKINS, 0.0)
	v_agirlik = (sin((v_t * 0.52)) * 1.3)
	v_zipla = (((-J.n(abs(sin((v_t * 7.0))))) * 3.0) if J.eq(J.getv(v_st, "mode"), "happy") else 0.0)
	v_dongu = (float(fmod(J.n(v_t), J.n(7.4))) / float(7.4))
	v_jestTip = fmod(J.n(floor((float(v_t) / float(7.4)))), J.n(3.0))
	v_jestVar = (J.lt(v_dongu, 0.82) if ((J.eq(J.getv(v_st, "mode"), "idle") and J.lt(v_jestTip, 2.0)) and J.gt(v_dongu, 0.55)) else (J.gt(v_dongu, 0.55) if (J.eq(J.getv(v_st, "mode"), "idle") and J.lt(v_jestTip, 2.0)) else (J.lt(v_jestTip, 2.0) if J.eq(J.getv(v_st, "mode"), "idle") else J.eq(J.getv(v_st, "mode"), "idle"))))
	v_jestK = (sin(((float((v_dongu - 0.55)) / float(0.27)) * J.getv({"PI": PI}, "PI"))) if J.truth(v_jestVar) else 0.0)
	v_kafaDon = floor((sin((v_t * 0.43)) * 1.4) + 0.5)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "translate", [floor(v_agirlik + 0.5), floor(v_zipla + 0.5)])
	v_hx = J.add(v_x, 23.0)
	v_fz = J.add(v_y, v_bob)
	v_hy = J.add(J.add(v_y, 30.0), v_bob)
	v_by = J.add(J.add(v_y, 50.0), v_bob)
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_ell(v_hx, J.add(J.add(v_y, 152.0), v_bob), 21.0, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_lgy = J.add(v_by, 66.0)
	v_lgh = 30.0
	v_slTop = J.add(v_by, 58.0)
	v_slAlt = (J.add(v_lgy, v_lgh) - 4.0)
	v_slH = (v_slAlt - v_slTop)
	v_ayrimU = 0.52
	_cells["KEN"][0] = "#1e3a63"
	_cells["GOV"][0] = "#35619a"
	_cells["ISK"][0] = "#5285c4"
	_cells["GLG"][0] = "#20406e"
	v_solBacak = null
	v_sagBacak = null
	v_lr = 0.0
	while J.lt(v_lr, v_slH):
		v_lu = (float(v_lr) / float((v_slH - 1.0)))
		v_yy0 = J.add(v_slTop, v_lr)
		v_gen = floor((J.add(26.0, (sin(((v_lu * J.getv({"PI": PI}, "PI")) * 0.82)) * 16.0)) - (v_lu * 3.0)) + 0.5)
		v_lx0 = floor((J.add(v_x, 23.0) - (float(v_gen) / float(2.0))) + 0.5)
		if J.lt(v_lu, v_ayrimU):
			J.invoke(v_bacakSerit, [v_lx0, v_gen, v_yy0])
			v_lr = J.add(v_lr, 1.0)
			continue
		v_t1 = (float((v_lu - v_ayrimU)) / float((1.0 - v_ayrimU)))
		v_ara = J.add(1.0, floor((v_t1 * 2.0) + 0.5))
		v_oy = (floor(J.add(v_x, 23.0) + 0.5) - (int(J.n(v_ara)) >> int(J.n(1.0))))
		v_solG = (v_oy - v_lx0)
		v_sagX = J.add(v_oy, v_ara)
		v_sagG = (J.add(v_lx0, v_gen) - v_sagX)
		J.invoke(v_bacakSerit, [v_lx0, v_solG, v_yy0])
		J.invoke(v_bacakSerit, [v_sagX, v_sagG, v_yy0])
		J.setv(game.j_ctx, "globalAlpha", 0.26)
		game.f_fr(v_oy, v_yy0, v_ara, 1.0, "#0e1c33")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_solBacak = [v_lx0, v_solG]
		v_sagBacak = [v_sagX, v_sagG]
		v_lr = J.add(v_lr, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.16)
	v_kv = 0.0
	while J.lt(v_kv, 3.0):
		v_kvx = J.add(J.add(v_x, 12.0), (v_kv * 11.0))
		game.f_ln(v_kvx, J.add(v_slTop, 8.0), J.add(v_kvx, 2.0), J.add(v_slTop, 22.0), "#14284a")
		v_kv = J.add(v_kv, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_blY = (v_slAlt - 4.0)
	v_blSet = [v_solBacak, v_sagBacak]
	v_bi2 = 0.0
	while J.lt(v_bi2, 2.0):
		v_bl = J.getv(v_blSet, v_bi2)
		if ((not J.truth(v_bl)) or J.lt(J.getv(v_bl, 1.0), 3.0)):
			v_bi2 = J.add(v_bi2, 1.0)
			continue
		game.f_fr(J.getv(v_bl, 0.0), v_blY, J.getv(v_bl, 1.0), 4.0, "#16294a")
		game.f_fr(J.add(J.getv(v_bl, 0.0), 1.0), v_blY, (J.getv(v_bl, 1.0) - 2.0), 3.0, "#2b4d80")
		game.f_hl(J.add(J.getv(v_bl, 0.0), 1.0), v_blY, (J.getv(v_bl, 1.0) - 2.0), "#4a7ab8")
		v_bi2 = J.add(v_bi2, 1.0)
	game.f_fr(J.add(v_x, 4.0), J.add(v_lgy, 26.0), 16.0, 4.0, "#8a5230")
	game.f_fr(J.add(v_x, 25.0), J.add(v_lgy, 26.0), 16.0, 4.0, "#8a5230")
	game.f_hl(J.add(v_x, 4.0), J.add(v_lgy, 26.0), 16.0, "#a5713f")
	game.f_hl(J.add(v_x, 25.0), J.add(v_lgy, 26.0), 16.0, "#a5713f")
	game.f_ell(J.add(v_x, 11.0), J.add(v_lgy, 33.0), 10.0, 4.0, "#3a2418")
	game.f_ell(J.add(v_x, 11.0), J.add(v_lgy, 32.0), 10.0, 4.0, "#5b3a20")
	game.f_hl(J.add(v_x, 6.0), J.add(v_lgy, 30.0), 10.0, "#7a5230")
	game.f_ell(J.add(v_x, 33.0), J.add(v_lgy, 33.0), 10.0, 4.0, "#3a2418")
	game.f_ell(J.add(v_x, 33.0), J.add(v_lgy, 32.0), 10.0, 4.0, "#5b3a20")
	game.f_hl(J.add(v_x, 28.0), J.add(v_lgy, 30.0), 10.0, "#7a5230")
	game.f_ell(v_hx, J.add(v_by, 6.0), 23.0, 9.0, "#ded8c8")
	game.f_fr(J.add(v_x, 1.0), J.add(v_by, 6.0), 45.0, 62.0, "#ded8c8")
	game.f_fr(J.add(v_x, 2.0), J.add(v_by, 5.0), 43.0, 62.0, "#f4efe2")
	game.f_ell(v_hx, J.add(v_by, 5.0), 22.0, 8.0, "#f4efe2")
	game.f_ell(J.add(v_hx, 1.0), J.add(J.add(v_by, 52.0), v_breathe), 21.0, 13.0, "#f8f4e8")
	J.setv(game.j_ctx, "globalAlpha", 0.14)
	game.f_ell(J.add(v_hx, 5.0), J.add(v_by, 56.0), 16.0, 8.0, "#a89a80")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 4.0):
		J.setv(game.j_ctx, "globalAlpha", 0.16)
		game.f_ln(J.add(J.add(v_x, 12.0), (v_i * 7.0)), J.add(v_by, 16.0), J.add(J.add(v_x, 10.0), (v_i * 7.0)), J.add(v_by, 34.0), "#a89a80")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	game.f_fr(J.add(v_x, 1.0), J.add(v_by, 5.0), 15.0, 58.0, J.getv(game.j_P, "red3"))
	game.f_fr(J.add(v_x, 2.0), J.add(v_by, 5.0), 13.0, 57.0, J.getv(game.j_P, "red1"))
	game.f_fr(J.add(v_x, 3.0), J.add(v_by, 7.0), 10.0, 54.0, J.getv(game.j_P, "red0"))
	game.f_ell(J.add(v_x, 8.0), J.add(v_by, 6.0), 8.0, 5.0, J.getv(game.j_P, "red1"))
	game.f_fr(J.add(v_x, 31.0), J.add(v_by, 5.0), 15.0, 58.0, J.getv(game.j_P, "red3"))
	game.f_fr(J.add(v_x, 32.0), J.add(v_by, 5.0), 13.0, 57.0, J.getv(game.j_P, "red1"))
	game.f_fr(J.add(v_x, 33.0), J.add(v_by, 7.0), 10.0, 54.0, J.getv(game.j_P, "red0"))
	game.f_ell(J.add(v_x, 38.0), J.add(v_by, 6.0), 8.0, 5.0, J.getv(game.j_P, "red1"))
	game.f_vl(J.add(v_x, 15.0), J.add(v_by, 6.0), 57.0, J.getv(game.j_P, "au1"))
	game.f_vl(J.add(v_x, 16.0), J.add(v_by, 6.0), 57.0, J.getv(game.j_P, "au2"))
	game.f_vl(J.add(v_x, 30.0), J.add(v_by, 6.0), 57.0, J.getv(game.j_P, "au1"))
	game.f_vl(J.add(v_x, 31.0), J.add(v_by, 6.0), 57.0, J.getv(game.j_P, "au2"))
	v_d = 0.0
	while J.lt(v_d, 4.0):
		game.f_disc(J.add(v_x, 11.0), J.add(J.add(v_by, 16.0), (v_d * 11.0)), 1.0, J.getv(game.j_P, "au0"))
		game.f_disc(J.add(v_x, 36.0), J.add(J.add(v_by, 16.0), (v_d * 11.0)), 1.0, J.getv(game.j_P, "au0"))
		v_d = J.add(v_d, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.55)
	v_im = 0.0
	while J.lt(v_im, 5.0):
		v_iy = J.add(J.add(v_by, 12.0), (v_im * 10.0))
		game.f_ln(J.add(v_x, 5.0), v_iy, J.add(v_x, 8.0), J.add(v_iy, 3.0), J.getv(game.j_P, "au2"))
		game.f_ln(J.add(v_x, 8.0), J.add(v_iy, 3.0), J.add(v_x, 5.0), J.add(v_iy, 6.0), J.getv(game.j_P, "au2"))
		game.f_ln(J.add(v_x, 42.0), v_iy, J.add(v_x, 39.0), J.add(v_iy, 3.0), J.getv(game.j_P, "au2"))
		game.f_ln(J.add(v_x, 39.0), J.add(v_iy, 3.0), J.add(v_x, 42.0), J.add(v_iy, 6.0), J.getv(game.j_P, "au2"))
		v_im = J.add(v_im, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_kuy = J.add(v_by, 57.0)
	v_kuh = 12.0
	game.f_fr(J.add(v_x, 2.0), v_kuy, 44.0, v_kuh, "#5e1a14")
	game.f_fr(J.add(v_x, 3.0), v_kuy, 42.0, (v_kuh - 1.0), "#8e2b20")
	game.f_fr(J.add(v_x, 3.0), J.add(v_kuy, 1.0), 42.0, (v_kuh - 4.0), "#a8392a")
	game.f_hl(J.add(v_x, 4.0), J.add(v_kuy, 1.0), 40.0, "#c4523c")
	J.setv(game.j_ctx, "globalAlpha", 0.85)
	game.f_hl(J.add(v_x, 4.0), J.add(v_kuy, 3.0), 40.0, J.getv(game.j_P, "au2"))
	game.f_hl(J.add(v_x, 4.0), (J.add(v_kuy, v_kuh) - 4.0), 40.0, J.getv(game.j_P, "au2"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.2)
	v_w2 = 0.0
	while J.lt(v_w2, 5.0):
		game.f_ln(J.add(J.add(v_x, 8.0), (v_w2 * 8.0)), J.add(v_kuy, 2.0), J.add(J.add(v_x, 10.0), (v_w2 * 8.0)), (J.add(v_kuy, v_kuh) - 2.0), "#40100c")
		v_w2 = J.add(v_w2, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(J.add(v_x, 33.0), J.add(v_kuy, 1.0), 9.0, (v_kuh - 2.0), "#7a2419")
	game.f_fr(J.add(v_x, 34.0), J.add(v_kuy, 2.0), 7.0, (v_kuh - 4.0), "#a8392a")
	game.f_hl(J.add(v_x, 35.0), J.add(v_kuy, 2.0), 5.0, "#c4523c")
	game.f_px(J.add(v_x, 37.0), J.add(v_kuy, 5.0), "#5e1a14")
	game.f_fr(J.add(v_x, 36.0), (J.add(v_kuy, v_kuh) - 1.0), 5.0, 7.0, "#7a2419")
	game.f_fr(J.add(v_x, 36.0), (J.add(v_kuy, v_kuh) - 1.0), 4.0, 6.0, "#983224")
	v_pu = 0.0
	while J.lt(v_pu, 4.0):
		game.f_px(J.add(J.add(v_x, 36.0), v_pu), J.add(J.add(v_kuy, v_kuh), 6.0), "#5e1a14")
		v_pu = J.add(v_pu, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.34)
	game.f_hl(J.add(v_x, 6.0), J.add(v_kuy, v_kuh), 36.0, "#0e1c33")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.18)
	game.f_hl(J.add(v_x, 7.0), J.add(J.add(v_kuy, v_kuh), 1.0), 34.0, "#0e1c33")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_armSw = ((sin((J.getv(v_st, "armT") * 15.0)) * 5.0) if J.eq(J.getv(v_st, "mode"), "slice") else 0.0)
	if J.eq(J.getv(v_st, "mode"), "slice"):
		game.f_fr(J.add(v_x, 38.0), J.add(v_by, 8.0), 10.0, 20.0, "#e2dccc")
		game.f_fr(J.add(v_x, 39.0), J.add(v_by, 8.0), 9.0, 19.0, "#f8f4e8")
		game.f_fr(J.add(v_x, 42.0), J.add(J.add(v_by, 22.0), v_armSw), 8.0, 12.0, J.getv(v_s, 1.0))
		game.f_fr(J.add(v_x, 42.0), J.add(J.add(v_by, 22.0), v_armSw), 8.0, 11.0, J.getv(v_s, 0.0))
		game.f_ell(J.add(v_x, 46.0), J.add(J.add(v_by, 32.0), v_armSw), 5.0, 5.0, J.getv(v_s, 1.0))
		game.f_ell(J.add(v_x, 46.0), J.add(J.add(v_by, 31.0), v_armSw), 5.0, 4.0, J.getv(v_s, 0.0))
		game.f_fr((v_x - 1.0), J.add(v_by, 14.0), 10.0, 22.0, "#e2dccc")
		game.f_fr(v_x, J.add(v_by, 14.0), 9.0, 21.0, "#f8f4e8")
		game.f_ell(J.add(v_x, 4.0), J.add(v_by, 37.0), 5.0, 5.0, J.getv(v_s, 1.0))
		game.f_ell(J.add(v_x, 4.0), J.add(v_by, 36.0), 5.0, 4.0, J.getv(v_s, 0.0))
	else:
		if J.eq(J.getv(v_st, "mode"), "happy"):
			game.f_fr((v_x - 3.0), (v_by - 12.0), 10.0, 24.0, "#f8f4e8")
			game.f_ell(J.add(v_x, 2.0), (v_by - 14.0), 5.0, 5.0, J.getv(v_s, 0.0))
			game.f_fr(J.add(v_x, 40.0), (v_by - 12.0), 10.0, 24.0, "#f8f4e8")
			game.f_ell(J.add(v_x, 45.0), (v_by - 14.0), 5.0, 5.0, J.getv(v_s, 0.0))
		else:
			if J.eq(J.getv(v_st, "mode"), "box"):
				game.f_fr(J.add(v_x, 2.0), J.add(v_by, 22.0), 42.0, 24.0, "#a87840")
				game.f_fr(J.add(v_x, 3.0), J.add(v_by, 22.0), 40.0, 23.0, "#d8a464")
				game.f_hl(J.add(v_x, 3.0), J.add(v_by, 22.0), 40.0, "#eccb92")
				v_b2 = 0.0
				while J.lt(v_b2, 4.0):
					game.f_hl(J.add(v_x, 6.0), J.add(J.add(v_by, 27.0), (v_b2 * 5.0)), 34.0, "#c09055")
					v_b2 = J.add(v_b2, 1.0)
				game.f_fr(J.add(v_x, 20.0), J.add(v_by, 22.0), 7.0, 24.0, "#b8894e")
				game.text_draw.f_txt("ET", J.add(v_x, 23.0), J.add(v_by, 30.0), "#6d4a22", {"align": "c"})
				game.f_fr((v_x - 2.0), J.add(v_by, 16.0), 10.0, 16.0, "#f8f4e8")
				game.f_ell(J.add(v_x, 3.0), J.add(v_by, 34.0), 5.0, 5.0, J.getv(v_s, 1.0))
				game.f_fr(J.add(v_x, 38.0), J.add(v_by, 16.0), 10.0, 16.0, "#f8f4e8")
				game.f_ell(J.add(v_x, 43.0), J.add(v_by, 34.0), 5.0, 5.0, J.getv(v_s, 1.0))
			else:
				game.f_fr((v_x - 2.0), J.add(v_by, 8.0), 10.0, 31.0, "#e2dccc")
				game.f_fr((v_x - 1.0), J.add(v_by, 8.0), 9.0, 30.0, "#f8f4e8")
				game.f_ell(J.add(v_x, 3.0), J.add(v_by, 9.0), 6.0, 4.0, "#f8f4e8")
				J.setv(game.j_ctx, "globalAlpha", 0.16)
				game.f_fr((v_x - 2.0), J.add(v_by, 9.0), 3.0, 30.0, "#000")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				game.f_fr((v_x - 2.0), J.add(v_by, 34.0), 10.0, 3.0, "#d8d2c0")
				game.f_ell(J.add(v_x, 3.0), J.add(J.add(v_by, 41.0), v_breathe), 5.0, 5.0, J.getv(v_s, 1.0))
				game.f_ell(J.add(v_x, 3.0), J.add(J.add(v_by, 40.0), v_breathe), 5.0, 4.0, J.getv(v_s, 0.0))
				v_omzX = J.add(v_x, 43.0)
				v_omzY = J.add(v_by, 10.0)
				v_dinX = J.add(v_x, 44.0)
				v_dinY = (J.add(v_by, 41.0) - v_breathe)
				v_hedX = J.add(v_hx, 12.0)
				v_hedY = J.add(v_hy, ((-J.n(4.0)) if J.eq(v_jestTip, 1.0) else 9.0))
				v_elX = floor(J.add(v_dinX, ((v_hedX - v_dinX) * v_jestK)) + 0.5)
				v_elY = floor(J.add(v_dinY, ((v_hedY - v_dinY) * v_jestK)) + 0.5)
				v_kk = 0.0
				while J.le(v_kk, 16.0):
					v_u4 = (float(v_kk) / float(16.0))
					v_ax2 = floor(J.add(v_omzX, ((v_elX - v_omzX) * v_u4)) + 0.5)
					v_ay2 = floor(J.add(v_omzY, ((v_elY - v_omzY) * v_u4)) + 0.5)
					game.f_fr((v_ax2 - 4.0), (v_ay2 - 2.0), 9.0, 4.0, "#e2dccc")
					game.f_fr((v_ax2 - 3.0), (v_ay2 - 2.0), 8.0, 3.0, "#f8f4e8")
					v_kk = J.add(v_kk, 1.0)
				game.f_ell((v_omzX - 1.0), J.add(v_omzY, 1.0), 6.0, 4.0, "#f8f4e8")
				game.f_fr((v_elX - 4.0), (v_elY - 4.0), 9.0, 3.0, "#d8d2c0")
				game.f_ell(v_elX, J.add(v_elY, 1.0), 5.0, 5.0, J.getv(v_s, 1.0))
				game.f_ell(v_elX, v_elY, 5.0, 4.0, J.getv(v_s, 0.0))
	game.f_fr((v_hx - 6.0), J.add(v_hy, 13.0), 12.0, 8.0, J.getv(v_s, 2.0))
	game.f_fr((v_hx - 5.0), J.add(v_hy, 13.0), 10.0, 7.0, J.getv(v_s, 1.0))
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_fr((v_hx - 6.0), J.add(v_hy, 13.0), 12.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_hx = J.add(v_hx, v_kafaDon)
	game.f_ell(v_hx, v_hy, 15.0, 14.0, J.getv(v_s, 2.0))
	game.f_ell((v_hx - 1.0), (v_hy - 1.0), 14.0, 13.0, J.getv(v_s, 0.0))
	game.f_ell(J.add(v_hx, 5.0), J.add(v_hy, 2.0), 10.0, 11.0, J.getv(v_s, 1.0))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_ell(J.add(v_hx, 10.0), J.add(v_hy, 2.0), 5.0, 8.0, J.getv(v_s, 2.0))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell((v_hx - 15.0), J.add(v_hy, 3.0), 3.0, 5.0, J.getv(v_s, 1.0))
	game.f_px((v_hx - 16.0), J.add(v_hy, 3.0), J.getv(v_s, 2.0))
	game.f_ell(J.add(v_hx, 15.0), J.add(v_hy, 3.0), 3.0, 5.0, J.getv(v_s, 1.0))
	game.f_px(J.add(v_hx, 16.0), J.add(v_hy, 3.0), J.getv(v_s, 2.0))
	game.f_fr((v_hx - 16.0), (v_hy - 4.0), 5.0, 10.0, "#eeeeea")
	game.f_fr(J.add(v_hx, 12.0), (v_hy - 4.0), 5.0, 10.0, "#eeeeea")
	game.f_ell((v_hx - 14.0), J.add(v_hy, 5.0), 4.0, 4.0, "#dcdcd6")
	game.f_ell(J.add(v_hx, 14.0), J.add(v_hy, 5.0), 4.0, 4.0, "#dcdcd6")
	game.f_fr((v_hx - 13.0), J.add(v_fz, 5.0), 27.0, 14.0, J.getv(game.j_P, "red3"))
	game.f_fr((v_hx - 12.0), J.add(v_fz, 5.0), 25.0, 13.0, J.getv(game.j_P, "red2"))
	game.f_fr((v_hx - 11.0), J.add(v_fz, 6.0), 21.0, 12.0, J.getv(game.j_P, "red1"))
	game.f_fr((v_hx - 10.0), J.add(v_fz, 7.0), 9.0, 10.0, J.getv(game.j_P, "red0"))
	game.f_hl((v_hx - 11.0), J.add(v_fz, 6.0), 21.0, "#f28a70")
	game.f_ell(v_hx, J.add(v_fz, 5.0), 14.0, 3.0, J.getv(game.j_P, "red1"))
	game.f_ell(v_hx, J.add(v_fz, 4.0), 14.0, 3.0, "#e8674f")
	game.f_ell((v_hx - 4.0), J.add(v_fz, 3.0), 6.0, 1.0, "#f4a08a")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl((v_hx - 12.0), J.add(v_fz, 18.0), 25.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_tsw = (sin((v_t * 2.2)) * 3.0)
	game.f_ln(J.add(v_hx, 11.0), J.add(v_fz, 4.0), J.add(J.add(v_hx, 15.0), v_tsw), J.add(v_fz, 16.0), "#241a14")
	game.f_ln(J.add(v_hx, 11.0), J.add(v_fz, 4.0), J.add(J.add(v_hx, 14.0), v_tsw), J.add(v_fz, 15.0), "#3a2a20")
	game.f_disc(J.add(J.add(v_hx, 15.0), v_tsw), J.add(v_fz, 17.0), 2.0, "#241a14")
	game.f_px(J.add(J.add(v_hx, 14.0), v_tsw), J.add(v_fz, 16.0), "#4a3a2a")
	v_kasY = (((v_hy - 6.0) - (1.0 if J.eq(J.getv(v_st, "mode"), "happy") else 0.0)) - floor(v_jestK + 0.5))
	game.f_fr((v_hx - 11.0), v_kasY, 7.0, 3.0, "#efefe9")
	game.f_px((v_hx - 12.0), J.add(v_kasY, 1.0), "#efefe9")
	game.f_px((v_hx - 12.0), J.add(v_kasY, 2.0), "#dcdcd6")
	game.f_px((v_hx - 4.0), (v_kasY - 1.0), "#efefe9")
	game.f_fr(J.add(v_hx, 4.0), v_kasY, 7.0, 3.0, "#efefe9")
	game.f_px(J.add(v_hx, 11.0), J.add(v_kasY, 1.0), "#efefe9")
	game.f_px(J.add(v_hx, 11.0), J.add(v_kasY, 2.0), "#dcdcd6")
	game.f_px(J.add(v_hx, 3.0), (v_kasY - 1.0), "#efefe9")
	v_blink = J.gt(game.f_hash1(floor((v_t * 1.3))), 0.9)
	if J.truth(v_blink):
		game.f_fr((v_hx - 10.0), v_hy, 6.0, 1.0, J.getv(v_s, 3.0))
		game.f_fr(J.add(v_hx, 4.0), v_hy, 6.0, 1.0, J.getv(v_s, 3.0))
	else:
		game.f_fr((v_hx - 10.0), (v_hy - 3.0), 6.0, 6.0, "#ffffff")
		game.f_fr(J.add(v_hx, 4.0), (v_hy - 3.0), 6.0, 6.0, "#ffffff")
		v_lookx = (1.0 if J.eq(J.getv(v_st, "mode"), "slice") else (1.0 if J.gt(sin((v_t * 0.6)), 0.0) else 0.0))
		game.f_fr(J.add((v_hx - 8.0), v_lookx), (v_hy - 1.0), 3.0, 3.0, "#2b2018")
		game.f_fr(J.add(J.add(v_hx, 6.0), v_lookx), (v_hy - 1.0), 3.0, 3.0, "#2b2018")
		game.f_px(J.add((v_hx - 8.0), v_lookx), (v_hy - 1.0), "#6a5a4a")
		game.f_px(J.add(J.add(v_hx, 6.0), v_lookx), (v_hy - 1.0), "#6a5a4a")
	game.f_ell((v_hx - 1.0), J.add(v_hy, 5.0), 6.0, 6.0, J.getv(v_s, 3.0))
	game.f_ell((v_hx - 1.0), J.add(v_hy, 4.0), 6.0, 5.0, J.getv(v_s, 1.0))
	game.f_ell((v_hx - 1.0), J.add(v_hy, 3.0), 5.0, 4.0, J.getv(v_s, 0.0))
	game.f_ell((v_hx - 3.0), J.add(v_hy, 2.0), 3.0, 2.0, "#fff0dc")
	game.f_px(J.add(v_hx, 4.0), J.add(v_hy, 6.0), J.getv(v_s, 3.0))
	game.f_px((v_hx - 6.0), J.add(v_hy, 6.0), J.getv(v_s, 3.0))
	game.f_hl((v_hx - 5.0), J.add(v_hy, 9.0), 10.0, J.getv(v_s, 2.0))
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_ell((v_hx - 11.0), J.add(v_hy, 6.0), 4.0, 3.0, "#e07a68")
	game.f_ell(J.add(v_hx, 9.0), J.add(v_hy, 6.0), 4.0, 3.0, "#e07a68")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_hx - 10.0), J.add(v_hy, 10.0), 20.0, 4.0, "#f4f4f0")
	game.f_fr((v_hx - 13.0), J.add(v_hy, 9.0), 5.0, 4.0, "#f4f4f0")
	game.f_fr(J.add(v_hx, 8.0), J.add(v_hy, 9.0), 5.0, 4.0, "#f4f4f0")
	game.f_px((v_hx - 14.0), J.add(v_hy, 8.0), "#f4f4f0")
	game.f_px(J.add(v_hx, 13.0), J.add(v_hy, 8.0), "#f4f4f0")
	game.f_px((v_hx - 15.0), J.add(v_hy, 7.0), "#e8e8e2")
	game.f_px(J.add(v_hx, 14.0), J.add(v_hy, 7.0), "#e8e8e2")
	game.f_hl((v_hx - 9.0), J.add(v_hy, 10.0), 18.0, "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_hl((v_hx - 8.0), J.add(v_hy, 13.0), 16.0, "#c8c8c2")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.eq(J.getv(v_st, "mode"), "happy"):
		game.f_fr((v_hx - 7.0), J.add(v_hy, 14.0), 15.0, 4.0, "#7a3a30")
		game.f_hl((v_hx - 6.0), J.add(v_hy, 17.0), 13.0, "#c9584a")
		game.f_hl((v_hx - 6.0), J.add(v_hy, 14.0), 13.0, "#ffffff")
		game.f_ln((v_hx - 12.0), J.add(v_hy, 11.0), (v_hx - 10.0), J.add(v_hy, 14.0), J.getv(v_s, 3.0))
		game.f_ln(J.add(v_hx, 11.0), J.add(v_hy, 11.0), J.add(v_hx, 9.0), J.add(v_hy, 14.0), J.getv(v_s, 3.0))
	else:
		game.f_hl((v_hx - 4.0), J.add(v_hy, 14.0), 9.0, "#a86a5a")
	J.method(game.j_ctx, "restore", [])
	return null

func _closure_80(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_bx0: Variant = null
	var v_bw0: Variant = null
	var v_yy0: Variant = null
	v_bx0 = J.arg(_args, 0)
	v_bw0 = J.arg(_args, 1)
	v_yy0 = J.arg(_args, 2)
	if J.lt(v_bw0, 3.0):
		return null
	game.f_fr(v_bx0, v_yy0, v_bw0, 1.0, _captures["350:KEN"][0])
	game.f_fr(J.add(v_bx0, 1.0), v_yy0, (v_bw0 - 2.0), 1.0, _captures["350:GOV"][0])
	game.f_px(J.add(v_bx0, 1.0), v_yy0, _captures["350:ISK"][0])
	game.f_px((J.add(v_bx0, v_bw0) - 2.0), v_yy0, _captures["350:GLG"][0])
	return null

