# Tutorial draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:3394
func f_hoverStation() -> Variant:
	var v_keys: Variant = null
	var v_i: Variant = null
	v_keys = ["spit", "meat", "pickle", "yogurt", "friesT", "drinkM", "ayran", "fryer", "potato", "crate", "bread", "board", "paper", "grill", "cut", "sauce", "garnish", "fbox", "sweet", "trash", "uncle"]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_keys, "length")):
		if J.truth(game.f_hitST(J.getv(v_keys, v_i))):
			return J.getv(v_keys, v_i)
		v_i = J.add(v_i, 1.0)
	return null
	return null

# game.js:3400
const ETIKET_GECIKME := 0.45
var _etiket_ad: Variant = null
var _etiket_bas := 0.0

func f_drawHoverHint(p_t: Variant = null) -> Variant:
	var v_hw0: Variant = null
	var v_hy0: Variant = null
	var v_h: Variant = null
	var v_s: Variant = null
	var v_nm: Variant = null
	var v_si: Variant = null
	var v_w: Variant = null
	var v_tx: Variant = null
	var v_ty: Variant = null
	var v_hw: Variant = null
	var v_hy: Variant = null
	var v_t: Variant = p_t
	if (J.truth(J.getv(J.getv(game.j_G, "crate"), "open")) or J.truth(J.getv(game.j_G, "drag"))):
		return null
	if (J.truth(game.j_TOUCH) and (not J.truth(J.getv(game.j_IN, "down")))):
		if J.gt(J.getv(game.j_G, "hintT"), 0.0):
			J.setv(game.j_ctx, "globalAlpha", min(1.0, (J.getv(game.j_G, "hintT") * 2.0)))
			v_hw0 = J.add(game.f_textW(J.getv(game.j_G, "hint")), 12.0)
			v_hy0 = ((game.j_H - J.getv(game.j_VIEW, "bot")) - 20.0)
			game.f_rrect(((float(game.j_W) / float(2.0)) - (float(v_hw0) / float(2.0))), v_hy0, v_hw0, 13.0, 3.0, "rgba(20,14,12,.88)")
			game.text_draw.f_txt(J.getv(game.j_G, "hint"), (float(game.j_W) / float(2.0)), J.add(v_hy0, 3.0), J.getv(game.j_P, "ui0"), {"align": "c"})
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		return null
	v_h = game.tutorial_draw.f_hoverStation()
	if J.eq(v_h, "spit"):
		v_h = null
	# BIRLESIK (6. tur, analiz madde 19): cerceve hemen yanar; ad etiketi fare
	# ayni istasyonda ETIKET_GECIKME kadar durunca yumusakca belirir (fareyi
	# gezdirirken etiketler ust uste yanip sonup istasyonlari ortmesin).
	var simdi: float = J.n(v_t)
	if v_h != _etiket_ad or simdi < _etiket_bas:
		_etiket_ad = v_h
		_etiket_bas = simdi
	var etiket_a: float = clampf((simdi - _etiket_bas - ETIKET_GECIKME) / 0.15, 0.0, 1.0)
	if J.truth(v_h):
		v_s = J.getv(game.j_ST, v_h)
		J.setv(game.j_ctx, "globalAlpha", 0.45)
		game.f_rrectOut((J.getv(v_s, "x") - 1.0), (J.getv(v_s, "y") - 1.0), J.add(J.getv(v_s, "w"), 2.0), J.add(J.getv(v_s, "h"), 2.0), 2.0, J.getv(game.j_P, "white"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_nm = J.getv(game.j_STNAME, v_h)
		v_nm = game.localization.f_T(v_nm)
		if (J.eq(v_h, "bread") and J.truth(J.method(game.j_TUN, "iskOn", [game.j_G]))):
			v_nm = game.localization.f_T(("Pide — iskender tabağı" if J.lt(J.getv(game.j_IN, "y"), J.add(J.getv(J.getv(game.j_ST, "bread"), "y"), 16.0)) else "Lavaş — dürüm"))
		if J.eq(v_h, "garnish"):
			v_nm = game.localization.f_T(("Domates dilimi" if J.lt(J.getv(game.j_IN, "x"), J.add(J.getv(J.getv(game.j_ST, "garnish"), "x"), (J.getv(J.getv(game.j_ST, "garnish"), "w") * 0.52))) else "Yeşil biber"))
			if (not J.truth(J.method(game.j_TUN, "garnishOn", [game.j_G]))):
				v_nm = J.add(v_nm, game.localization.f_T(" — kilitli"))
		if J.eq(v_h, "sauce"):
			v_si = game.f_sauceIdxAt(J.getv(game.j_IN, "x"))
			v_nm = game.localization.f_T(("Acı sos" if J.eq(v_si, 0.0) else ("Sarımsak sosu" if J.eq(v_si, 1.0) else "Tereyağı sosu (iskender)")))
			if (not J.truth(game.assembly_system.f_sauceOpen(v_si))):
				v_nm = J.add(v_nm, game.localization.f_T(" — kilitli"))
		v_w = J.add(game.f_textW(v_nm), 6.0)
		v_tx = game.math_utils.f_clamp((J.getv(game.j_IN, "x") - (float(v_w) / float(2.0))), 2.0, ((game.j_W - v_w) - 2.0))
		v_ty = (J.getv(v_s, "y") - 12.0)
		if J.lt(v_ty, J.add(J.getv(game.j_VIEW, "top"), 22.0)):
			v_ty = J.add(J.add(J.getv(v_s, "y"), J.getv(v_s, "h")), 3.0)
		if etiket_a > 0.0:
			J.setv(game.j_ctx, "globalAlpha", etiket_a)
			game.f_rrect(v_tx, v_ty, v_w, 11.0, 2.0, "rgba(20,14,12,.82)")
			game.text_draw.f_txt(v_nm, J.add(v_tx, 3.0), J.add(v_ty, 2.0), J.getv(game.j_P, "ui0"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.gt(J.getv(game.j_G, "hintT"), 0.0):
		J.setv(game.j_ctx, "globalAlpha", min(1.0, (J.getv(game.j_G, "hintT") * 2.0)))
		v_hw = J.add(game.f_textW(J.getv(game.j_G, "hint")), 12.0)
		v_hy = ((game.j_H - J.getv(game.j_VIEW, "bot")) - 20.0)
		game.f_rrect(((float(game.j_W) / float(2.0)) - (float(v_hw) / float(2.0))), v_hy, v_hw, 13.0, 3.0, "rgba(20,14,12,.88)")
		game.text_draw.f_txt(J.getv(game.j_G, "hint"), (float(game.j_W) / float(2.0)), J.add(v_hy, 3.0), J.getv(game.j_P, "ui0"), {"align": "c"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:3491
func f_tutHedefKutu() -> Variant:
	var v_step: Variant = null
	var v_r: Variant = null
	var v_s: Variant = null
	var v_co: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	if (J.lt(J.getv(game.j_G, "tut"), 0.0) or J.ge(J.getv(game.j_G, "tut"), J.getv(game.j_TUT, "length"))):
		return null
	v_step = J.getv(game.j_TUT, J.getv(game.j_G, "tut"))
	if (J.eq(J.getv(v_step, "st"), "crate") and J.truth(J.getv(J.getv(game.j_G, "crate"), "open"))):
		v_r = game.stock_system.f_cratePanelRect()
		return {"x": (J.getv(v_r, 0.0) - 3.0), "y": (J.getv(v_r, 1.0) - 3.0), "w": J.add(J.getv(v_r, 2.0), 6.0), "h": J.add(J.getv(v_r, 3.0), 6.0), "ok": [J.add(J.getv(v_r, 0.0), (float(J.getv(v_r, 2.0)) / float(2.0))), (J.getv(v_r, 1.0) - 5.0)], "panel": true}
	if J.truth(J.getv(v_step, "st")):
		v_s = J.getv(game.j_ST, J.getv(v_step, "st"))
		return {"x": (J.getv(v_s, "x") - 4.0), "y": (J.getv(v_s, "y") - 4.0), "w": J.add(J.getv(v_s, "w"), 8.0), "h": J.add(J.getv(v_s, "h"), 8.0), "ok": [J.add(J.getv(v_s, "x"), (float(J.getv(v_s, "w")) / float(2.0))), (J.getv(v_s, "y") - 6.0)]}
	if J.truth(J.getv(v_step, "para")):
		if J.truth(J.getv(J.getv(game.j_G, "coins"), "length")):
			v_co = J.getv(J.getv(game.j_G, "coins"), 0.0)
			return {"x": (J.getv(v_co, "x") - 11.0), "y": (J.getv(v_co, "y") - 11.0), "w": 22.0, "h": 22.0, "ok": [J.getv(v_co, "x"), (J.getv(v_co, "y") - 12.0)], "yuvarlak": true}
		return null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		if J.eq(J.getv(v_c, "state"), "wait"):
			return {"x": (J.getv(v_c, "x") - 20.0), "y": (J.getv(v_c, "y") - 58.0), "w": 40.0, "h": 62.0, "ok": [J.getv(v_c, "x"), (J.getv(v_c, "y") - 60.0)]}
		v_i = J.add(v_i, 1.0)
	return null
	return null

# game.js:3525
func f_drawTut(p_t: Variant = null) -> Variant:
	var v_step: Variant = null
	var v_kutu: Variant = null
	var v_k: Variant = null
	var v_hx: Variant = null
	var v_hy: Variant = null
	var v_hw: Variant = null
	var v_hh: Variant = null
	var v_nefes: Variant = null
	var v_HUDH: Variant = null
	var v_a: Variant = null
	var v_ust: Variant = null
	var v_kl: Variant = null
	var v_bo: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_kk: Variant = null
	var v_yazi: Variant = null
	var v_w2: Variant = null
	var v_cy: Variant = null
	var v_hedefOrta: Variant = null
	var v_nokta: Variant = null
	var v_d2: Variant = null
	var v_dx2: Variant = null
	var v_t: Variant = p_t
	if J.ge(J.getv(game.j_G, "tut"), J.getv(game.j_TUT, "length")):
		J.setv(game.j_TUTFX, "ilk", true)
		J.setv(game.j_TUTFX, "karart", 0.0)
		return null
	v_step = J.getv(game.j_TUT, J.getv(game.j_G, "tut"))
	v_kutu = game.tutorial_draw.f_tutHedefKutu()
	if J.truth(v_kutu):
		if J.truth(J.getv(game.j_TUTFX, "ilk")):
			J.setv(game.j_TUTFX, "x", J.getv(v_kutu, "x"))
			J.setv(game.j_TUTFX, "y", J.getv(v_kutu, "y"))
			J.setv(game.j_TUTFX, "w", J.getv(v_kutu, "w"))
			J.setv(game.j_TUTFX, "h", J.getv(v_kutu, "h"))
			J.setv(game.j_TUTFX, "ilk", false)
		else:
			v_k = 0.22
			J.setv(game.j_TUTFX, "x", J.add(J.getv(game.j_TUTFX, "x"), ((J.getv(v_kutu, "x") - J.getv(game.j_TUTFX, "x")) * v_k)))
			J.setv(game.j_TUTFX, "y", J.add(J.getv(game.j_TUTFX, "y"), ((J.getv(v_kutu, "y") - J.getv(game.j_TUTFX, "y")) * v_k)))
			J.setv(game.j_TUTFX, "w", J.add(J.getv(game.j_TUTFX, "w"), ((J.getv(v_kutu, "w") - J.getv(game.j_TUTFX, "w")) * v_k)))
			J.setv(game.j_TUTFX, "h", J.add(J.getv(game.j_TUTFX, "h"), ((J.getv(v_kutu, "h") - J.getv(game.j_TUTFX, "h")) * v_k)))
		J.setv(game.j_TUTFX, "karart", min(1.0, J.add(J.getv(game.j_TUTFX, "karart"), 0.04)))
		v_hx = floor(J.getv(game.j_TUTFX, "x") + 0.5)
		v_hy = floor(J.getv(game.j_TUTFX, "y") + 0.5)
		v_hw = floor(J.getv(game.j_TUTFX, "w") + 0.5)
		v_hh = floor(J.getv(game.j_TUTFX, "h") + 0.5)
		v_nefes = floor((sin((v_t * 3.0)) * (1.0 if J.truth(J.getv(v_kutu, "yuvarlak")) else 1.5)) + 0.5)
		v_hx = (v_hx - v_nefes)
		v_hy = (v_hy - v_nefes)
		v_hw = J.add(v_hw, (v_nefes * 2.0))
		v_hh = J.add(v_hh, (v_nefes * 2.0))
		v_HUDH = 24.0
		v_a = (0.62 * J.getv(game.j_TUTFX, "karart"))
		v_ust = max(v_HUDH, v_hy)
		J.setv(game.j_ctx, "globalAlpha", v_a)
		if J.gt(v_hy, v_HUDH):
			game.f_fr(0.0, v_HUDH, game.j_W, (v_hy - v_HUDH), "#0a0705")
		game.f_fr(0.0, J.add(v_ust, v_hh), game.j_W, max(0.0, ((game.j_H - v_ust) - v_hh)), "#0a0705")
		game.f_fr(0.0, v_ust, max(0.0, v_hx), max(0.0, (v_hh - (v_ust - v_hy))), "#0a0705")
		game.f_fr(J.add(v_hx, v_hw), v_ust, max(0.0, ((game.j_W - v_hx) - v_hw)), max(0.0, (v_hh - (v_ust - v_hy))), "#0a0705")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.3 * sin((v_t * 5.0)))))
		if J.truth(J.getv(v_kutu, "yuvarlak")):
			game.f_ring(J.add(v_hx, (float(v_hw) / float(2.0))), J.add(v_hy, (float(v_hh) / float(2.0))), floor((float(v_hw) / float(2.0)) + 0.5), J.getv(game.j_P, "au0"))
			game.f_ring(J.add(v_hx, (float(v_hw) / float(2.0))), J.add(v_hy, (float(v_hh) / float(2.0))), J.add(floor((float(v_hw) / float(2.0)) + 0.5), 2.0), J.getv(game.j_P, "au2"))
		else:
			game.f_rrectOut(v_hx, v_hy, v_hw, v_hh, 3.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		if (not J.truth(J.getv(v_kutu, "yuvarlak"))):
			v_kl = 4.0
			game.f_fr(v_hx, v_hy, v_kl, 1.0, J.getv(game.j_P, "au1"))
			game.f_fr(v_hx, v_hy, 1.0, v_kl, J.getv(game.j_P, "au1"))
			game.f_fr((J.add(v_hx, v_hw) - v_kl), v_hy, v_kl, 1.0, J.getv(game.j_P, "au1"))
			game.f_fr((J.add(v_hx, v_hw) - 1.0), v_hy, 1.0, v_kl, J.getv(game.j_P, "au1"))
			game.f_fr(v_hx, (J.add(v_hy, v_hh) - 1.0), v_kl, 1.0, J.getv(game.j_P, "au1"))
			game.f_fr(v_hx, (J.add(v_hy, v_hh) - v_kl), 1.0, v_kl, J.getv(game.j_P, "au1"))
			game.f_fr((J.add(v_hx, v_hw) - v_kl), (J.add(v_hy, v_hh) - 1.0), v_kl, 1.0, J.getv(game.j_P, "au1"))
			game.f_fr((J.add(v_hx, v_hw) - 1.0), (J.add(v_hy, v_hh) - v_kl), 1.0, v_kl, J.getv(game.j_P, "au1"))
		v_bo = (sin((v_t * 6.0)) * 2.0)
		v_ax = floor(J.getv(J.getv(v_kutu, "ok"), 0.0) + 0.5)
		v_ay = floor(J.add((J.getv(J.getv(v_kutu, "ok"), 1.0) - 10.0), v_bo) + 0.5)
		v_kk = 0.0
		while J.lt(v_kk, 6.0):
			game.f_fr((v_ax - v_kk), (J.add(v_ay, 6.0) - v_kk), J.add((v_kk * 2.0), 1.0), 1.0, (J.getv(game.j_P, "au1") if J.lt(v_kk, 4.0) else J.getv(game.j_P, "au0")))
			v_kk = J.add(v_kk, 1.0)
		game.f_fr((v_ax - 1.0), (v_ay - 4.0), 3.0, 8.0, J.getv(game.j_P, "au1"))
		game.f_fr((v_ax - 1.0), (v_ay - 4.0), 3.0, 2.0, J.getv(game.j_P, "au0"))
	v_yazi = game.localization.f_T(J.getv(v_step, "s"))
	v_w2 = J.add(game.f_textW(v_yazi), 30.0)
	v_cy = 28.0
	if J.truth(v_kutu):
		v_hedefOrta = J.add(J.getv(v_kutu, "y"), (float(J.getv(v_kutu, "h")) / float(2.0)))
		v_cy = (((game.j_H - J.getv(game.j_VIEW, "bot")) - 46.0) if J.lt(v_hedefOrta, (game.j_H * 0.52)) else J.add(J.getv(game.j_VIEW, "top"), 28.0))
		if J.truth(J.getv(v_kutu, "panel")):
			v_cy = ((game.j_H - J.getv(game.j_VIEW, "bot")) - 46.0)
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), 1.0), J.add(v_cy, 2.0), v_w2, 17.0, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), v_cy, v_w2, 17.0, 4.0, J.getv(game.j_P, "ui5"))
	game.f_rrect(J.add(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), 1.0), J.add(v_cy, 1.0), (v_w2 - 2.0), 15.0, 3.0, "#3a2c1e")
	game.f_rrectOut(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), v_cy, v_w2, 17.0, 4.0, J.getv(game.j_P, "au2"))
	game.f_disc(J.add(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), 10.0), J.add(v_cy, 8.0), 6.0, J.getv(game.j_P, "au2"))
	game.f_disc(J.add(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), 10.0), J.add(v_cy, 8.0), 5.0, "#5a4020")
	game.text_draw.f_txt(J.add("", J.add(J.getv(game.j_G, "tut"), 1.0)), J.add(((float(game.j_W) / float(2.0)) - (float(v_w2) / float(2.0))), 10.0), J.add(v_cy, 5.0), J.getv(game.j_P, "au0"), {"align": "c"})
	game.text_draw.f_txt(v_yazi, J.add((float(game.j_W) / float(2.0)), 8.0), J.add(v_cy, 5.0), J.getv(game.j_P, "ui0"), {"align": "c"})
	v_nokta = min(J.getv(game.j_TUT, "length"), 14.0)
	v_d2 = 0.0
	while J.lt(v_d2, v_nokta):
		v_dx2 = J.add(((float(game.j_W) / float(2.0)) - ((v_nokta - 1.0) * 3.0)), (v_d2 * 6.0))
		game.f_disc(v_dx2, J.add(v_cy, 22.0), 1.0, (J.getv(game.j_P, "ok") if J.lt(v_d2, J.getv(game.j_G, "tut")) else (J.getv(game.j_P, "au0") if J.eq(v_d2, J.getv(game.j_G, "tut")) else "rgba(255,255,255,.22)")))
		v_d2 = J.add(v_d2, 1.0)
	return null

