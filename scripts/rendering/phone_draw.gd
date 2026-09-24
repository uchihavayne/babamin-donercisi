# Phone draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2408
func f_drawMotoBadge(p_t: Variant = null) -> Variant:
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_t: Variant = p_t
	if (not J.truth(game.helper_system.f_motoBroken())):
		return null
	v_bx = J.add(J.getv(J.getv(game.j_ST, "uncle"), "x"), 2.0)
	v_by = 186.0
	# BIRLESIK: yeni tezgahta Dayi bolmeyi dolduruyor; 186'da gobeginin ustune
	# biniyordu -> bolmenin altina (ayak hizasi)
	if game.get("counter_design_enabled"): v_by = 238.0
	J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.3 * sin((v_t * 5.0)))))
	game.f_rrect(v_bx, v_by, 44.0, 22.0, 3.0, "rgba(20,14,12,.85)")
	game.f_rrectOut(v_bx, v_by, 44.0, 22.0, 3.0, J.getv(game.j_P, "bad"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	# REMAKE kancasi: HD motosiklet ikonu
	if not J.truth(game.f_hdMotoIkon(J.add(v_bx, 10.0), J.add(v_by, 6.0))):
		game.f_ln(J.add(v_bx, 6.0), J.add(v_by, 15.0), J.add(v_bx, 13.0), J.add(v_by, 8.0), "#c7ced5")
		game.f_fr(J.add(v_bx, 4.0), J.add(v_by, 13.0), 4.0, 4.0, "#9aa3ab")
		game.f_px(J.add(v_bx, 5.0), J.add(v_by, 14.0), "#5a636b")
	game.text_draw.f_txt("BOZUK", J.add(v_bx, 24.0), J.add(v_by, 3.0), J.getv(game.j_P, "bad"), {"align": "c"})
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtShort(J.getv(J.getv(game.j_G, "moto"), "cost"))), J.add(v_bx, 24.0), J.add(v_by, 12.0), J.getv(game.j_P, "au0"), {"align": "c"})
	return null

# game.js:4013
func f_drawPhone(p_t: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_p: Variant = null
	var v_sh: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_r: Variant = null
	var v_c: Variant = null
	var v_hy: Variant = null
	var v_k: Variant = null
	var v_w2: Variant = null
	var v_rr: Variant = null
	var v_bo: Variant = null
	var v_n: Variant = null
	var v_pw: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_d2: Variant = null
	var v_i2: Variant = null
	var v_ix: Variant = null
	var v_iy: Variant = null
	var v_oi: Variant = null
	var v_ic: Variant = null
	var v_ay: Variant = null
	var v_t: Variant = p_t
	if (not J.truth(game.phone_system.f_phoneActive())):
		if (J.truth(game.phone_system.f_fermanKuryeYasak()) and J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G]))):
			game.regulation_draw.f_drawPhoneMuhurlu(v_t)
		return null
	v_s = J.getv(game.j_ST, "phone")
	v_p = J.getv(game.j_G, "phone")
	v_sh = (floor((sin((v_t * 40.0)) * 1.5) + 0.5) if J.eq(J.getv(v_p, "state"), "ring") else 0.0)
	v_x = J.add(J.getv(v_s, "x"), v_sh)
	v_y = J.getv(v_s, "y")
	# REMAKE kancasi
	if not game.f_hdTelefon(v_x, v_y, J.eq(J.getv(v_p, "state"), "ring"), v_sh):
		game.f_fr(J.add(v_x, 2.0), J.add(v_y, 6.0), 20.0, 22.0, "#2b2f36")
		game.f_fr(J.add(v_x, 3.0), J.add(v_y, 6.0), 18.0, 21.0, "#3f454e")
		game.f_hl(J.add(v_x, 3.0), J.add(v_y, 6.0), 18.0, "#5c646e")
		v_r = 0.0
		while J.lt(v_r, 3.0):
			v_c = 0.0
			while J.lt(v_c, 3.0):
				game.f_fr(J.add(J.add(v_x, 6.0), (v_c * 4.0)), J.add(J.add(v_y, 12.0), (v_r * 4.0)), 3.0, 3.0, "#8a929b")
				game.f_px(J.add(J.add(v_x, 6.0), (v_c * 4.0)), J.add(J.add(v_y, 12.0), (v_r * 4.0)), "#c6ccd2")
				v_c = J.add(v_c, 1.0)
			v_r = J.add(v_r, 1.0)
		v_hy = J.add(J.add(v_y, (1.0 if J.eq(J.getv(v_p, "state"), "ring") else 2.0)), v_sh)
		game.f_fr(v_x, v_hy, 24.0, 5.0, "#1f2329")
		game.f_fr(J.add(v_x, 1.0), v_hy, 22.0, 4.0, "#c0281c")
		game.f_hl(J.add(v_x, 2.0), v_hy, 20.0, "#e2483a")
		game.f_fr(v_x, v_hy, 4.0, 6.0, "#c0281c")
		game.f_fr(J.add(v_x, 20.0), v_hy, 4.0, 6.0, "#c0281c")
		game.f_hl(v_x, v_hy, 4.0, "#e2483a")
		game.f_hl(J.add(v_x, 20.0), v_hy, 4.0, "#e2483a")
		v_k = 0.0
		while J.lt(v_k, 6.0):
			game.f_px(J.add(J.add(v_x, 12.0), floor((sin((v_k * 1.2)) * 2.0) + 0.5)), J.add(J.add(v_hy, 6.0), v_k), "#1f2329")
			v_k = J.add(v_k, 1.0)
	if J.eq(J.getv(v_p, "state"), "ring"):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.4 * sin((v_t * 14.0)))))
		v_w2 = 0.0
		while J.lt(v_w2, 3.0):
			v_rr = J.add(J.add(6.0, (v_w2 * 4.0)), fmod(J.n((v_t * 14.0)), J.n(4.0)))
			game.f_px(J.add(J.add(v_x, 26.0), v_rr), (J.add(v_y, 12.0) - (v_w2 * 2.0)), J.getv(game.j_P, "au0"))
			game.f_px(J.add(J.add(v_x, 26.0), v_rr), J.add(J.add(v_y, 12.0), (v_w2 * 2.0)), J.getv(game.j_P, "au0"))
			game.f_px(J.add(J.add(v_x, 25.0), v_rr), J.add(v_y, 12.0), J.getv(game.j_P, "au0"))
			v_w2 = J.add(v_w2, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_bo = (sin((v_t * 8.0)) * 2.0)
		game.text_draw.f_txt("!", J.add(v_x, 28.0), J.add((v_y - 2.0), v_bo), J.getv(game.j_P, "bad"), {"align": "c", "outline": true, "sc": 2.0})
		# BIRLESIK (6. tur): toplu siparis calarken "xN" rozeti
		if J.truth(J.getv(v_p, "toplu")):
			var rx: float = J.n(v_x) + 34.0
			var ry: float = J.n(v_y) - 4.0 + J.n(v_bo) * 0.5
			game.f_rrect(rx, ry, 16.0, 10.0, 2.0, "#3f8a4a")
			game.f_rrectOut(rx, ry, 16.0, 10.0, 2.0, "#1e3a14")
			game.text_draw.f_txt("x" + str(int(J.n(J.getv(v_p, "topluN")))), rx + 8.0, ry + 2.0, "#fff2b0", {"align": "c"})
		J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.3 * sin((v_t * 8.0)))))
		game.f_rrectOut((J.getv(v_s, "x") - 2.0), (J.getv(v_s, "y") - 2.0), J.add(J.getv(v_s, "w"), 4.0), J.add(J.getv(v_s, "h"), 4.0), 3.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	# BIRLESIK: yeni paket fisi oyun nesnesinde (order_flow); modulun kendisinde
	# aranınca hic bulunmuyor, eski fis (farkli sos isaretleri) ciziliyordu.
	if game.has_method("draw_order_receipt"):
		game.call("draw_order_receipt", v_t)
		return null
	if J.eq(J.getv(v_p, "state"), "order"):
		v_n = J.getv(J.getv(v_p, "order"), "length")
		v_pw = J.add(14.0, (v_n * 13.0))
		v_px0 = 4.0
		v_py0 = J.add(J.add(J.getv(v_s, "y"), J.getv(v_s, "h")), 2.0)
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_rrect(J.add(v_px0, 1.0), J.add(v_py0, 2.0), v_pw, 26.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_px0, v_py0, v_pw, 26.0, 2.0, "#efe6c8")
		game.f_rrect(J.add(v_px0, 1.0), J.add(v_py0, 1.0), (v_pw - 2.0), 24.0, 2.0, "#fdf6de")
		game.f_rrectOut(v_px0, v_py0, v_pw, 26.0, 2.0, "#b09a68")
		v_d2 = 0.0
		while J.lt(v_d2, (v_pw - 4.0)):
			game.f_px(J.add(J.add(v_px0, 2.0), v_d2), J.add(v_py0, 1.0), "#d8cba8")
			v_d2 = J.add(v_d2, 4.0)
		game.text_draw.f_txt("PAKET", J.add(v_px0, 3.0), J.add(v_py0, 3.0), "#a03a2a")
		v_i2 = 0.0
		while J.lt(v_i2, v_n):
			v_ix = J.add(J.add(v_px0, 10.0), (v_i2 * 13.0))
			v_iy = J.add(v_py0, 17.0)
			if J.truth(J.getv(J.getv(v_p, "done"), v_i2)):
				J.setv(game.j_ctx, "globalAlpha", 0.3)
			v_oi = J.getv(J.getv(v_p, "order"), v_i2)
			v_ic = ("wrap" if J.eq(J.getv(v_oi, "kind"), "wrap") else ("iskender" if J.eq(J.getv(v_oi, "kind"), "plate") else (J.getv(v_oi, "type") if J.eq(J.getv(v_oi, "kind"), "drink") else ("sweet" if J.eq(J.getv(v_oi, "kind"), "sweet") else "fbox"))))
			game.icon_draw.f_icon(v_ic, v_ix, v_iy, v_t)
			if (J.eq(J.getv(v_oi, "kind"), "wrap") and J.truth(J.getv(v_oi, "sauce"))):
				game.f_disc(J.add(v_ix, 6.0), (v_iy - 6.0), 4.0, "#2a2018")
				game.f_disc(J.add(v_ix, 6.0), (v_iy - 6.0), 3.0, ("#c0281c" if J.eq(J.getv(v_oi, "sauce"), "hot") else "#e6dfc8"))
				game.f_px(J.add(v_ix, 6.0), (v_iy - 9.0), ("#5a8a2a" if J.eq(J.getv(v_oi, "sauce"), "hot") else "#a89a78"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			if J.truth(J.getv(J.getv(v_p, "done"), v_i2)):
				game.icon_draw.f_drawCheck(v_ix, v_iy, J.getv(game.j_P, "ok"))
			v_i2 = J.add(v_i2, 1.0)
		if ((not J.truth(J.getv(game.j_G, "courier"))) or J.eq(J.getv(J.getv(game.j_G, "courier"), "state"), "in")):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.4, (0.3 * sin((v_t * 5.0)))))
			v_ay = J.add(J.add(v_py0, 30.0), (sin((v_t * 5.0)) * 2.0))
			game.f_fr(J.add(v_px0, 20.0), v_ay, 3.0, 6.0, J.getv(game.j_P, "au0"))
			game.f_px(J.add(v_px0, 19.0), J.add(v_ay, 5.0), J.getv(game.j_P, "au0"))
			game.f_px(J.add(v_px0, 23.0), J.add(v_ay, 5.0), J.getv(game.j_P, "au0"))
			game.f_px(J.add(v_px0, 20.0), J.add(v_ay, 7.0), J.getv(game.j_P, "au0"))
			game.f_px(J.add(v_px0, 22.0), J.add(v_ay, 7.0), J.getv(game.j_P, "au0"))
			game.f_px(J.add(v_px0, 21.0), J.add(v_ay, 8.0), J.getv(game.j_P, "au0"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:4095
func f_drawCourier(p_t: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_pr: Variant = null
	var v_t: Variant = p_t
	v_c = J.getv(game.j_G, "courier")
	if ((not J.truth(v_c)) or J.eq(J.getv(v_c, "state"), "in")):
		return null
	if J.eq(J.getv(v_c, "state"), "away"):
		v_bx = 6.0
		v_by = 150.0
		J.setv(game.j_ctx, "globalAlpha", 0.85)
		game.f_rrect(v_bx, v_by, 56.0, 16.0, 3.0, "rgba(20,14,12,.8)")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrectOut(v_bx, v_by, 56.0, 16.0, 3.0, J.getv(game.j_P, "ui4"))
		game.phone_draw.f_drawScooter(J.add(v_bx, 12.0), J.add(v_by, 10.0), v_t, 0.6)
		game.text_draw.f_txt("YOLDA", J.add(v_bx, 34.0), J.add(v_by, 5.0), J.getv(game.j_P, "au0"), {"align": "c"})
		v_pr = (1.0 - game.math_utils.f_clamp((float(J.getv(v_c, "t")) / float(J.method(game.j_TUN, "courierTime", [game.j_G]))), 0.0, 1.0))
		game.counter_draw.f_bar(J.add(v_bx, 2.0), J.add(v_by, 13.0), 52.0, 3.0, (1.0 - v_pr), J.getv(game.j_P, "ok"))
		return null
	game.phone_draw.f_drawScooter(J.getv(v_c, "x"), 236.0, v_t, 1.0)
	return null

# game.js:4113
func f_drawScooter(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_sc: Variant = null) -> Variant:
	var v_wob: Variant = null
	var v_s: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	# REMAKE kancasi
	if game.f_hdScooter(p_x, p_y, p_t, p_sc): return null
	v_wob = floor((sin((v_t * 22.0)) * 0.6) + 0.5)
	J.method(game.j_ctx, "save", [])
	if not J.eq(v_sc, 1.0):
		J.method(game.j_ctx, "translate", [v_x, v_y])
		J.method(game.j_ctx, "scale", [v_sc, v_sc])
		J.method(game.j_ctx, "translate", [(-J.n(v_x)), (-J.n(v_y))])
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_x, J.add(v_y, 6.0), 16.0, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_disc((v_x - 10.0), J.add(v_y, 2.0), 4.0, "#1f2329")
	game.f_disc((v_x - 10.0), J.add(v_y, 2.0), 2.0, "#5c646e")
	game.f_disc(J.add(v_x, 10.0), J.add(v_y, 2.0), 4.0, "#1f2329")
	game.f_disc(J.add(v_x, 10.0), J.add(v_y, 2.0), 2.0, "#5c646e")
	game.f_rrect((v_x - 12.0), (v_y - 4.0), 24.0, 7.0, 3.0, "#8e1c14")
	game.f_rrect((v_x - 12.0), (v_y - 5.0), 24.0, 7.0, 3.0, "#c0281c")
	game.f_hl((v_x - 9.0), (v_y - 5.0), 18.0, "#e2483a")
	game.f_fr(J.add(v_x, 8.0), (v_y - 12.0), 5.0, 9.0, "#c0281c")
	game.f_fr(J.add(v_x, 9.0), (v_y - 12.0), 3.0, 8.0, "#e2483a")
	game.f_fr(J.add(v_x, 12.0), (v_y - 10.0), 2.0, 3.0, J.getv(game.j_P, "au0"))
	game.f_fr(J.add(v_x, 7.0), (v_y - 14.0), 8.0, 2.0, "#3f454e")
	game.f_fr((v_x - 16.0), (v_y - 12.0), 9.0, 8.0, "#3f6ba8")
	game.f_fr((v_x - 15.0), (v_y - 12.0), 7.0, 7.0, "#4f81c4")
	game.f_hl((v_x - 15.0), (v_y - 12.0), 7.0, "#6b9ad8")
	v_s = J.getv(game.j_SKINS, 0.0)
	game.f_fr((v_x - 5.0), (v_y - 16.0), 9.0, 12.0, "#f4efe2")
	game.f_fr((v_x - 5.0), (v_y - 16.0), 4.0, 12.0, J.getv(game.j_P, "red1"))
	game.f_ell(v_x, J.add((v_y - 20.0), v_wob), 5.0, 5.0, J.getv(v_s, 1.0))
	game.f_ell(v_x, J.add((v_y - 21.0), v_wob), 5.0, 4.0, J.getv(v_s, 0.0))
	game.f_fr((v_x - 5.0), J.add((v_y - 25.0), v_wob), 11.0, 5.0, J.getv(game.j_P, "red2"))
	game.f_fr((v_x - 4.0), J.add((v_y - 25.0), v_wob), 9.0, 4.0, J.getv(game.j_P, "red1"))
	game.f_fr((v_x - 3.0), J.add((v_y - 19.0), v_wob), 7.0, 2.0, "#f4f4f0")
	if J.truth(game.f_chance(0.35)):
		game.effects.f_smoke((v_x - 16.0), J.add(v_y, 2.0), 1.0, "rgba(120,110,100,.5)")
	J.method(game.j_ctx, "restore", [])
	return null

