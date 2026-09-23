# Incident draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:4574
func f_drawKedi(p_t: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_govde: Variant = null
	var v_koyu: Variant = null
	var v_acik: Variant = null
	var v_yuru: Variant = null
	var v_sek: Variant = null
	var v_b: Variant = null
	var v_kt: Variant = null
	var v_ky2: Variant = null
	var v_mw: Variant = null
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdKedi(p_t): return null
	v_K = J.getv(game.j_G, "kedi")
	if ((not J.truth(v_K)) or J.eq(J.getv(v_K, "faz"), "yok")):
		return null
	v_x = floor(J.getv(v_K, "x") + 0.5)
	v_y = game.event_system.f_kediY()
	v_govde = "#4a4038"
	v_koyu = "#332c26"
	v_acik = "#6b5c50"
	J.setv(game.j_ctx, "globalAlpha", 0.26)
	game.f_ell(v_x, v_y, 8.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.eq(J.getv(v_K, "faz"), "yiyor"):
		game.f_fr((v_x - 6.0), (v_y - 6.0), 12.0, 6.0, v_govde)
		game.f_fr((v_x - 6.0), (v_y - 6.0), 12.0, 2.0, v_acik)
		game.f_fr(J.add(v_x, 4.0), (v_y - 9.0), 5.0, 5.0, v_govde)
		game.f_px(J.add(v_x, 5.0), (v_y - 8.0), v_koyu)
		game.f_px(J.add(v_x, 7.0), (v_y - 8.0), v_koyu)
		game.f_fr((v_x - 8.0), (v_y - 8.0), 3.0, 2.0, v_govde)
		return null
	v_yuru = (J.eq(J.getv(v_K, "faz"), "gelis") if J.eq(J.getv(v_K, "faz"), "gelis") else J.eq(J.getv(v_K, "faz"), "gidis"))
	v_sek = (floor((sin((v_t * 9.0)) * 1.0) + 0.5) if J.truth(v_yuru) else 0.0)
	if J.truth(v_yuru):
		game.f_fr((v_x - 7.0), J.add((v_y - 7.0), v_sek), 13.0, 6.0, v_govde)
		game.f_fr((v_x - 7.0), J.add((v_y - 7.0), v_sek), 13.0, 2.0, v_acik)
		v_b = floor((sin((v_t * 11.0)) * 1.5) + 0.5)
		game.f_fr((v_x - 5.0), J.add((v_y - 2.0), v_sek), 2.0, 2.0, v_koyu)
		game.f_fr(J.add(v_x, 3.0), J.add(((v_y - 2.0) - v_b), v_sek), 2.0, 2.0, v_koyu)
		game.f_fr(J.add(v_x, 4.0), J.add((v_y - 12.0), v_sek), 6.0, 6.0, v_govde)
		game.f_px(J.add(v_x, 5.0), J.add((v_y - 13.0), v_sek), v_govde)
		game.f_px(J.add(v_x, 8.0), J.add((v_y - 13.0), v_sek), v_govde)
		game.f_px(J.add(v_x, 6.0), J.add((v_y - 10.0), v_sek), "#c8e070")
		game.f_px(J.add(v_x, 8.0), J.add((v_y - 10.0), v_sek), "#c8e070")
		v_kt = (sin((v_t * 6.0)) * 2.0)
		game.f_fr((v_x - 10.0), J.add(J.add((v_y - 10.0), floor(v_kt + 0.5)), v_sek), 3.0, 2.0, v_govde)
	else:
		game.f_fr((v_x - 4.0), (v_y - 10.0), 8.0, 10.0, v_govde)
		game.f_fr((v_x - 4.0), (v_y - 10.0), 3.0, 10.0, v_acik)
		game.f_fr((v_x - 4.0), (v_y - 2.0), 8.0, 2.0, v_koyu)
		game.f_fr((v_x - 4.0), (v_y - 16.0), 8.0, 6.0, v_govde)
		game.f_px((v_x - 4.0), (v_y - 17.0), v_govde)
		game.f_px((v_x - 3.0), (v_y - 18.0), v_govde)
		game.f_px(J.add(v_x, 3.0), (v_y - 17.0), v_govde)
		game.f_px(J.add(v_x, 2.0), (v_y - 18.0), v_govde)
		game.f_px((v_x - 2.0), (v_y - 14.0), "#c8e070")
		game.f_px(J.add(v_x, 1.0), (v_y - 14.0), "#c8e070")
		game.f_px(v_x, (v_y - 12.0), "#d8a0a0")
		v_ky2 = floor((sin((v_t * 3.2)) * 2.0) + 0.5)
		game.f_fr(J.add(v_x, 4.0), J.add((v_y - 4.0), v_ky2), 5.0, 2.0, v_govde)
		game.f_fr(J.add(v_x, 8.0), J.add((v_y - 7.0), v_ky2), 2.0, 4.0, v_govde)
	if J.gt(J.getv(v_K, "miyav"), 0.0):
		J.setv(game.j_ctx, "globalAlpha", game.math_utils.f_clamp(J.getv(v_K, "miyav"), 0.0, 1.0))
		v_mw = J.add(game.f_textW("miyav"), 6.0)
		game.f_rrect((v_x - (float(v_mw) / float(2.0))), (v_y - 30.0), v_mw, 10.0, 3.0, "rgba(20,16,14,.82)")
		game.text_draw.f_txt("miyav", v_x, (v_y - 28.0), "#ffe6b0", {"align": "c"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:4673
func f_drawKesinti(p_t: Variant = null) -> Variant:
	var v_K: Variant = null
	var v_acilma: Variant = null
	var v_cx: Variant = null
	var v_top: Variant = null
	var v_H0: Variant = null
	var v_hx: Variant = null
	var v_hy: Variant = null
	var v_hw: Variant = null
	var v_hh: Variant = null
	var v_pcx: Variant = null
	var v_pcy: Variant = null
	var v_titre: Variant = null
	var v_g: Variant = null
	var v_yay: Variant = null
	var v_gw2: Variant = null
	var v_gh2: Variant = null
	var v_i: Variant = null
	var v_seg: Variant = null
	var v_ey: Variant = null
	var v_fl: Variant = null
	var v_kalan: Variant = null
	var v_ms: Variant = null
	var v_mw: Variant = null
	var v_t: Variant = p_t
	v_K = J.getv(game.j_G, "kesinti")
	if (not J.truth(v_K)):
		return null
	if (J.eq(J.getv(v_K, "faz"), "bekle") and J.gt(J.getv(v_K, "uyari"), 0.0)):
		if J.gt(sin((v_t * 34.0)), 0.4):
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#000010")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		return null
	if not J.eq(J.getv(v_K, "faz"), "kesik"):
		return null
	v_acilma = game.math_utils.f_clamp((float(J.getv(v_K, "t")) / float(2.2)), 0.0, 1.0)
	J.setv(game.j_ctx, "globalAlpha", (0.84 - (v_acilma * 0.14)))
	game.f_fr(0.0, 0.0, game.j_W, J.getv(game.j_LAY, "floorY"), "#04060f")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_cx = J.getv(J.getv(game.j_LAY, "spit"), "cx")
	v_top = J.getv(J.getv(game.j_LAY, "spit"), "top")
	v_H0 = (J.getv(J.getv(game.j_LAY, "spit"), "bot") - v_top)
	v_hx = J.add(v_cx, 19.0)
	v_hy = J.add(v_top, 2.0)
	v_hw = 17.0
	v_hh = (v_H0 - 14.0)
	v_pcx = J.add(v_hx, (float(v_hw) / float(2.0)))
	v_pcy = J.add(v_hy, (float(v_hh) / float(2.0)))
	v_titre = J.add(0.5, ((0.5 * sin((v_t * 5.3))) * sin((v_t * 1.7))))
	# REMAKE kancasi
	if not game.f_hdKesintiIsik(v_pcx, v_pcy, (v_hx - 6.0), (v_hy - 4.0), v_titre):
		v_g = 0.0
		while J.lt(v_g, 9.0):
			v_yay = J.add(1.0, (v_g * 0.42))
			J.setv(game.j_ctx, "globalAlpha", ((0.075 - (v_g * 0.0072)) * J.add(0.82, (v_titre * 0.18))))
			v_gw2 = floor(((v_hw * v_yay) * 2.6) + 0.5)
			v_gh2 = floor((v_hh * J.add(1.0, (v_g * 0.16))) + 0.5)
			game.f_fr(floor((v_pcx - (float(v_gw2) / float(2.0))) + 0.5), floor((v_pcy - (float(v_gh2) / float(2.0))) + 0.5), v_gw2, v_gh2, "#ff7a1e")
			v_g = J.add(v_g, 1.0)
		J.setv(game.j_ctx, "globalAlpha", J.add(0.2, (v_titre * 0.07)))
		game.f_fr((v_hx - 6.0), (v_hy - 4.0), J.add(v_hw, 12.0), J.add(v_hh, 8.0), "#ffa03c")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 6.0):
		v_seg = floor((float((v_hh - 8.0)) / float(6.0)))
		v_ey = J.add(J.add(v_hy, 4.0), (v_i * v_seg))
		v_fl = J.add(0.55, (0.45 * sin(J.add((v_t * 6.0), (v_i * 1.9)))))
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.35 * v_fl)))
		game.f_fr(J.add(v_hx, 3.0), v_ey, (v_hw - 6.0), max(1.0, (v_seg - 4.0)), "#e0500f")
		J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (0.4 * v_fl)))
		game.f_fr(J.add(v_hx, 4.0), J.add(v_ey, 1.0), (v_hw - 8.0), max(1.0, (v_seg - 5.0)), "#ff9c2e")
		J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.35 * v_fl)))
		game.f_fr(J.add(v_hx, 5.0), J.add(v_ey, 1.0), (v_hw - 10.0), max(1.0, (v_seg - 6.0)), "#ffe08a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (v_titre * 0.05)))
	game.f_fr((v_cx - 20.0), v_top, 22.0, v_H0, "#ff8a2a")
	J.setv(game.j_ctx, "globalAlpha", J.add(0.1, (v_titre * 0.04)))
	game.f_fr((v_hx - 40.0), (J.getv(game.j_LAY, "surfY") - 3.0), 74.0, 5.0, "#ff9c3c")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_kalan = max(0.0, ceil((J.getv(v_K, "sure") - J.getv(v_K, "t"))))
	v_ms = J.add(game.localization.f_T("ELEKTRİK: "), v_kalan)
	v_mw = J.add(game.f_textW(v_ms), 12.0)
	game.f_rrect(((float(game.j_W) / float(2.0)) - (float(v_mw) / float(2.0))), 84.0, v_mw, 13.0, 3.0, "rgba(10,10,20,.85)")
	game.f_rrectOut(((float(game.j_W) / float(2.0)) - (float(v_mw) / float(2.0))), 84.0, v_mw, 13.0, 3.0, "#ffb23c")
	game.text_draw.f_txt(v_ms, (float(game.j_W) / float(2.0)), 87.0, "#ffd257", {"align": "c"})
	return null

# game.js:4844
func f_drawRakip(p_t: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_sal: Variant = null
	var v_bw: Variant = null
	var v_bx: Variant = null
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdRakip(p_t): return null
	v_R = J.getv(game.j_G, "rakip")
	if ((not J.truth(v_R)) or J.eq(J.getv(v_R, "faz"), "yok")):
		return null
	v_x = floor(J.getv(v_R, "x") + 0.5)
	v_y = (J.getv(J.getv(J.getv(game.j_LAY, "custSlots"), 0.0), "y") if J.truth(J.getv(J.getv(game.j_LAY, "custSlots"), 0.0)) else 152.0)
	v_sal = (sin((v_t * 2.2)) * 0.8)
	v_y = floor(J.add(v_y, v_sal) + 0.5)
	game.f_fr((v_x - 13.0), (v_y - 30.0), 26.0, 31.0, "#2f4450")
	game.f_fr((v_x - 13.0), (v_y - 30.0), 26.0, 2.0, "#3d5a68")
	game.f_fr((v_x - 12.0), (v_y - 30.0), 7.0, 30.0, "#3d5a68")
	game.f_fr((v_x - 9.0), (v_y - 16.0), 18.0, 17.0, "#c9d2d8")
	game.f_fr((v_x - 9.0), (v_y - 16.0), 18.0, 2.0, "#e4ebef")
	game.f_fr((v_x - 14.0), (v_y - 18.0), 28.0, 5.0, "#2f4450")
	game.f_fr((v_x - 14.0), (v_y - 18.0), 28.0, 2.0, "#3d5a68")
	game.f_px((v_x - 4.0), (v_y - 16.0), "#b98b6a")
	game.f_px(J.add(v_x, 3.0), (v_y - 16.0), "#b98b6a")
	game.f_fr((v_x - 3.0), (v_y - 34.0), 6.0, 5.0, "#a87a54")
	game.f_fr((v_x - 8.0), (v_y - 46.0), 16.0, 14.0, "#b98b6a")
	game.f_fr((v_x - 8.0), (v_y - 46.0), 16.0, 3.0, "#a87a54")
	game.f_fr((v_x - 9.0), (v_y - 48.0), 18.0, 5.0, "#2a2018")
	game.f_fr((v_x - 9.0), (v_y - 46.0), 2.0, 6.0, "#2a2018")
	game.f_fr(J.add(v_x, 7.0), (v_y - 46.0), 2.0, 6.0, "#2a2018")
	game.f_fr((v_x - 3.0), (v_y - 37.0), 6.0, 2.0, "#2a2018")
	game.f_px((v_x - 4.0), (v_y - 41.0), "#1a1410")
	game.f_px(J.add(v_x, 3.0), (v_y - 41.0), "#1a1410")
	game.f_fr((v_x - 5.0), (v_y - 43.0), 3.0, 1.0, "#2a2018")
	game.f_fr(J.add(v_x, 2.0), (v_y - 43.0), 3.0, 1.0, "#2a2018")
	game.f_fr((v_x - 9.0), (v_y - 50.0), 18.0, 3.0, "#2f6a8a")
	game.f_fr((v_x - 9.0), (v_y - 48.0), 18.0, 1.0, "#1f4a62")
	if (J.gt(J.getv(v_R, "sonT"), 0.0) and J.truth(J.getv(v_R, "son"))):
		v_bw = J.add(game.f_textW(game.localization.f_T(J.getv(v_R, "son"))), 10.0)
		v_bx = game.math_utils.f_clamp((v_x - (float(v_bw) / float(2.0))), 4.0, ((game.j_W - v_bw) - 4.0))
		J.setv(game.j_ctx, "globalAlpha", game.math_utils.f_clamp(J.getv(v_R, "sonT"), 0.0, 1.0))
		game.f_rrect(v_bx, (v_y - 68.0), v_bw, 13.0, 3.0, "rgba(24,18,14,.88)")
		game.f_rrectOut(v_bx, (v_y - 68.0), v_bw, 13.0, 3.0, "#6b5a48")
		game.f_fr((v_x - 2.0), (v_y - 56.0), 4.0, 3.0, "rgba(24,18,14,.88)")
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_R, "son")), J.add(v_bx, (float(v_bw) / float(2.0))), (v_y - 65.0), "#f0e2c8", {"align": "c"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

