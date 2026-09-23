# Newspaper draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:709
func f_drawGazete(p_t: Variant = null, p_k: Variant = null) -> Variant:
	var _cells: Dictionary = {"liste": [null], "satirH": [null], "haberH": [null], "liderVar": [null]}
	var v_kalkan: Variant = null
	var v_dun: Variant = null
	var v_q: Variant = null
	var v_hala: Variant = null
	var v_w: Variant = null
	var v_pw: Variant = null
	var v_yukseklik: Variant = null
	var v_duzen: Variant = null
	var v_son: Variant = null
	var v_nh: Variant = null
	var v_sozVar: Variant = null
	var v_kalkanGoster: Variant = null
	var v_ph: Variant = null
	var v_d0: Variant = null
	var v_kv: Variant = null
	var v_hh: Variant = null
	var v_haber: Variant = null
	var v_kk: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_d1: Variant = null
	var v_my: Variant = null
	var v_hy: Variant = null
	var v_m: Variant = null
	var v_f: Variant = null
	var v_ry: Variant = null
	var v_mn: Variant = null
	var v_cy: Variant = null
	var v_fw: Variant = null
	var v_fh: Variant = null
	var v_nx: Variant = null
	var v_nw: Variant = null
	var v_n: Variant = null
	var v_hb: Variant = null
	var v_ny: Variant = null
	var v_ay: Variant = null
	var v_bh: Variant = null
	var v_et2: Variant = null
	var v_et: Variant = null
	var v_ad: Variant = null
	var v_tw: Variant = null
	var v_t: Variant = p_t
	var v_k: Variant = p_k
	v_yukseklik = game.newspaper_draw._closure_271.bind({"878:liste": _cells["liste"], "878:satirH": _cells["satirH"], "878:haberH": _cells["haberH"], "878:liderVar": _cells["liderVar"]})
	_cells["liste"][0] = game.progression_system.f_fermanSec(J.getv(game.j_G, "day"))
	v_kalkan = []
	if J.gt(J.getv(game.j_G, "day"), 1.0):
		v_dun = game.progression_system.f_fermanSec((J.getv(game.j_G, "day") - 1.0))
		v_q = 0.0
		while J.lt(v_q, J.getv(v_dun, "length")):
			v_hala = false
			v_w = 0.0
			while J.lt(v_w, J.getv(_cells["liste"][0], "length")):
				if J.eq(J.getv(J.getv(_cells["liste"][0], v_w), "id"), J.getv(J.getv(v_dun, v_q), "id")):
					v_hala = true
				v_w = J.add(v_w, 1.0)
			if (not J.truth(v_hala)):
				J.method(v_kalkan, "push", [J.getv(v_dun, v_q)])
			v_q = J.add(v_q, 1.0)
	_cells["liderVar"][0] = (game.progression_system.f_liderGunu(J.getv(game.j_G, "fgun"), J.getv(game.j_G, "day")) if J.eq(J.kind(J.ref(game.progression_system.f_liderGunu, 2)), "function") else J.eq(J.kind(J.ref(game.progression_system.f_liderGunu, 2)), "function"))
	v_pw = 304.0
	_cells["satirH"][0] = 21.0
	_cells["haberH"][0] = 19.0
	v_duzen = [[4.0, true, true], [3.0, true, true], [4.0, false, true], [3.0, false, true], [2.0, false, true], [1.0, false, true], [1.0, false, false], [0.0, false, false]]
	v_son = J.getv(v_duzen, (J.getv(v_duzen, "length") - 1.0))
	v_nh = J.getv(v_son, 0.0)
	v_sozVar = J.getv(v_son, 1.0)
	v_kalkanGoster = J.getv(v_son, 2.0)
	v_ph = J.invoke(v_yukseklik, [v_nh, v_sozVar, (J.gt(J.getv(v_kalkan, "length"), 0.0) if J.truth(v_kalkanGoster) else v_kalkanGoster)])
	v_d0 = 0.0
	while J.lt(v_d0, J.getv(v_duzen, "length")):
		v_kv = (J.gt(J.getv(v_kalkan, "length"), 0.0) if J.truth(J.getv(J.getv(v_duzen, v_d0), 2.0)) else J.getv(J.getv(v_duzen, v_d0), 2.0))
		v_hh = J.invoke(v_yukseklik, [J.getv(J.getv(v_duzen, v_d0), 0.0), J.getv(J.getv(v_duzen, v_d0), 1.0), v_kv])
		if J.ge(J.getv(game.interface_draw.f_panelKutu(0.0, v_hh), 1.0), v_hh):
			v_nh = J.getv(J.getv(v_duzen, v_d0), 0.0)
			v_sozVar = J.getv(J.getv(v_duzen, v_d0), 1.0)
			v_kalkanGoster = J.getv(J.getv(v_duzen, v_d0), 2.0)
			v_ph = v_hh
			break
		v_d0 = J.add(v_d0, 1.0)
	if (not J.truth(v_kalkanGoster)):
		v_kalkan = []
	v_haber = game.progression_system.f_haberSec(J.getv(game.j_G, "day"), v_nh)
	v_kk = game.interface_draw.f_panelKutu(0.0, v_ph)
	v_ph = J.getv(v_kk, 1.0)
	v_x = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
	v_y = floor(game.math_utils.f_lerp((-J.n(v_ph)), J.getv(v_kk, 0.0), game.math_utils.f_easeOutBack(v_k)) + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.46)
	game.f_fr(J.add(v_x, 5.0), J.add(v_y, 6.0), v_pw, v_ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, v_y, v_pw, v_ph, "#b8ad8e")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), (v_ph - 2.0), "#e6dcbe")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_pw - 2.0), "#f4ecd4")
	J.setv(game.j_ctx, "globalAlpha", 0.1)
	v_d1 = 0.0
	while J.lt(v_d1, 30.0):
		game.f_px(J.add(J.add(v_x, 4.0), floor((game.f_hash1((v_d1 * 3.7)) * (v_pw - 8.0)))), J.add(J.add(v_y, 4.0), floor((game.f_hash1((v_d1 * 8.3)) * (v_ph - 8.0)))), "#6a5f45")
		v_d1 = J.add(v_d1, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.13)
	game.f_fr(J.add(v_x, floor((float(v_pw) / float(2.0)) + 0.5)), J.add(v_y, 2.0), 1.0, (v_ph - 4.0), "#6a5f45")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_my = J.add(v_y, 4.0)
	game.newspaper_draw.f_gazeteArma(J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_my, 1.0))
	game.newspaper_draw.f_gazeteSusleme(J.add(v_x, 30.0), J.add(v_my, 8.0), 1.0)
	game.newspaper_draw.f_gazeteSusleme((J.add(v_x, v_pw) - 30.0), J.add(v_my, 8.0), (-J.n(1.0)))
	game.text_draw.f_txt(game.localization.f_T("DEMİRKENT HABER"), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_my, 17.0), "#1e1a14", {"align": "c", "sc": 2.0})
	game.f_fr(J.add(v_x, 10.0), J.add(v_my, 35.0), (v_pw - 20.0), 1.0, "#2a251c")
	game.f_fr(J.add(v_x, 10.0), J.add(v_my, 37.0), (v_pw - 20.0), 2.0, "#2a251c")
	game.text_draw.f_txt(J.add(game.localization.f_T("GÜN "), J.getv(game.j_G, "day")), J.add(v_x, 12.0), J.add(v_my, 42.0), "#5a5142")
	game.text_draw.f_txt(game.localization.f_T("RESMİ GAZETE"), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_my, 42.0), "#5a5142", {"align": "c"})
	game.text_draw.f_txt(game.localization.f_T("BEDELSİZ"), (J.add(v_x, v_pw) - 12.0), J.add(v_my, 42.0), "#5a5142", {"align": "r"})
	game.text_draw.f_txt(J.add(J.add(J.add(J.add(game.localization.f_T("Hava: "), game.localization.f_T(game.progression_system.f_gazeteHava(J.getv(game.j_G, "day")))), "   "), game.progression_system.f_gazeteDerece(J.getv(game.j_G, "day"))), game.localization.f_T(" derece")), J.add(v_x, 12.0), J.add(v_my, 51.0), "#7a7360")
	game.text_draw.f_txt(J.add(game.localization.f_T("Baskı: "), J.add(40000.0, floor((game.f_hash1((J.getv(game.j_G, "day") * 2.9)) * 9000.0)))), (J.add(v_x, v_pw) - 12.0), J.add(v_my, 51.0), "#7a7360", {"align": "r"})
	game.f_fr(J.add(v_x, 10.0), J.add(v_my, 58.0), (v_pw - 20.0), 1.0, "#8a8065")
	v_hy = J.add(v_my, 62.0)
	v_m = 0.0
	while J.lt(v_m, J.getv(_cells["liste"][0], "length")):
		v_f = J.getv(_cells["liste"][0], v_m)
		v_ry = J.add(v_hy, (v_m * _cells["satirH"][0]))
		v_mn = (J.getv(game.j_FERMAN_MANSET, J.getv(v_f, "id")) if J.truth(J.getv(game.j_FERMAN_MANSET, J.getv(v_f, "id"))) else J.getv(v_f, "metin"))
		game.text_draw.f_txt(game.localization.f_T(v_mn), J.add(v_x, (float(v_pw) / float(2.0))), v_ry, "#1e1a14", {"align": "c"})
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_f, "metin")), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_ry, 10.0), "#8a2318", {"align": "c"})
		if J.lt(v_m, (J.getv(_cells["liste"][0], "length") - 1.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.35)
			game.f_hl(J.add(v_x, 60.0), J.add(v_ry, 19.0), (v_pw - 120.0), "#8a8065")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_m = J.add(v_m, 1.0)
	v_cy = J.add(J.add(v_hy, (J.getv(_cells["liste"][0], "length") * _cells["satirH"][0])), 2.0)
	game.f_fr(J.add(v_x, 10.0), (v_cy - 3.0), (v_pw - 20.0), 1.0, "#8a8065")
	v_fw = 46.0
	v_fh = ((v_nh * _cells["haberH"][0]) - 4.0)
	game.newspaper_draw.f_gazeteFoto(J.add(v_x, 12.0), J.add(v_cy, 2.0), v_fw, min(v_fh, 30.0))
	if J.gt(v_fh, 34.0):
		game.newspaper_draw.f_gazeteSutun(J.add(v_x, 12.0), J.add(v_cy, 36.0), (v_fw - 2.0), floor((float((v_fh - 34.0)) / float(4.0))), 2.3)
	v_nx = J.add(J.add(J.add(v_x, 12.0), v_fw), 8.0)
	v_nw = (v_pw - J.add(v_fw, 34.0))
	v_n = 0.0
	while J.lt(v_n, J.getv(v_haber, "length")):
		v_hb = J.getv(v_haber, v_n)
		v_ny = J.add(J.add(v_cy, 2.0), (v_n * _cells["haberH"][0]))
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_hb, 0.0)), v_nx, v_ny, "#2a2620")
		game.text_draw.f_txt(game.localization.f_T(J.getv(v_hb, 1.0)), v_nx, J.add(v_ny, 9.0), "#6a6455")
		if J.lt(v_n, (J.getv(v_haber, "length") - 1.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.28)
			game.f_hl(v_nx, J.add(v_ny, 17.0), v_nw, "#8a8065")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_n = J.add(v_n, 1.0)
	v_ay = J.add(J.add(v_cy, 4.0), (J.getv(v_haber, "length") * _cells["haberH"][0]))
	if J.truth(_cells["liderVar"][0]):
		game.f_fr(J.add(v_x, 10.0), (v_ay - 3.0), (v_pw - 20.0), 1.0, "#8a8065")
		game.f_fr(J.add(v_x, 10.0), v_ay, (v_pw - 20.0), 14.0, "#8e1c14")
		game.f_fr(J.add(v_x, 10.0), v_ay, (v_pw - 21.0), 13.0, "#b83228")
		game.f_hl(J.add(v_x, 11.0), v_ay, (v_pw - 23.0), "#d8493a")
		game.text_draw.f_txt(game.localization.f_T("LİDER BUGÜN ESNAFI ZİYARET EDECEK"), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_ay, 3.0), "#ffe9d0", {"align": "c"})
		v_ay = J.add(v_ay, 18.0)
	if J.truth(v_sozVar):
		v_bh = (30.0 if J.truth(J.getv(v_kalkan, "length")) else 20.0)
		game.f_fr(J.add(v_x, 10.0), (v_ay - 2.0), (v_pw - 20.0), v_bh, "#dcd2b4")
		game.f_rc(J.add(v_x, 10.0), (v_ay - 2.0), (v_pw - 20.0), v_bh, "#a8a08a")
		game.f_fr(J.add(v_x, 10.0), (v_ay - 2.0), 3.0, v_bh, "#8e1c14")
		game.text_draw.f_txt(game.localization.f_T("LİDERİN SÖZÜ"), J.add(v_x, 20.0), J.add(v_ay, 1.0), "#8a2318")
		game.text_draw.f_txt(game.localization.f_T(game.progression_system.f_liderSozu(J.getv(game.j_G, "day"))), J.add(v_x, 20.0), J.add(v_ay, 10.0), "#4a4436")
		if J.truth(J.getv(v_kalkan, "length")):
			v_et2 = game.localization.f_T("KALKAN FERMAN: ")
			game.text_draw.f_txt(v_et2, J.add(v_x, 20.0), J.add(v_ay, 19.0), "#5a5142")
			game.text_draw.f_txt(J.add(game.localization.f_T(J.getv(J.getv(v_kalkan, 0.0), "metin")), (J.add(" +", (J.getv(v_kalkan, "length") - 1.0)) if J.gt(J.getv(v_kalkan, "length"), 1.0) else "")), J.add(J.add(v_x, 20.0), game.f_textW(v_et2)), J.add(v_ay, 19.0), "#2f6a3a")
		v_ay = J.add(v_ay, J.add(v_bh, 4.0))
	else:
		if J.truth(J.getv(v_kalkan, "length")):
			game.f_fr(J.add(v_x, 10.0), (v_ay - 3.0), (v_pw - 20.0), 1.0, "#8a8065")
			v_et = game.localization.f_T("KALKAN FERMAN: ")
			v_ad = J.add(game.localization.f_T(J.getv(J.getv(v_kalkan, 0.0), "metin")), (J.add(" +", (J.getv(v_kalkan, "length") - 1.0)) if J.gt(J.getv(v_kalkan, "length"), 1.0) else ""))
			v_tw = J.add(game.f_textW(v_et), game.f_textW(v_ad))
			game.text_draw.f_txt(v_et, (J.add(v_x, (float(v_pw) / float(2.0))) - (float(v_tw) / float(2.0))), J.add(v_ay, 1.0), "#5a5142")
			game.text_draw.f_txt(v_ad, J.add((J.add(v_x, (float(v_pw) / float(2.0))) - (float(v_tw) / float(2.0))), game.f_textW(v_et)), J.add(v_ay, 1.0), "#2f6a3a")
			v_ay = J.add(v_ay, 15.0)
	game.text_draw.f_txt(game.localization.f_T("Fermanı duvardaki kâğıttan tekrar okuyabilirsin."), J.add(v_x, (float(v_pw) / float(2.0))), J.add(v_ay, 2.0), "#6a6455", {"align": "c"})
	if (J.gt(J.getv(game.j_G, "sceneT"), 0.4) and J.truth(game.f_button(((float(game.j_W) / float(2.0)) - 52.0), J.add(v_ay, 12.0), 104.0, 18.0, "DÜKKÂNI AÇ", "#3f8a4a", true))):
		J.method(game.j_SFX, "bell", [])
		game.f_startDay()
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	return null

# ui.js:867
func f_gazeteArma(p_cx: Variant = null, p_cy: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_K: Variant = null
	var v_i: Variant = null
	var v_uz: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	v_cx = floor(v_cx + 0.5)
	v_cy = floor(v_cy + 0.5)
	v_S = "#1e1a14"
	v_K = "#e6dcbe"
	v_i = 0.0
	while J.lt(v_i, 5.0):
		v_uz = J.add(5.0, (v_i * 3.0))
		game.f_fr(((v_cx - 5.0) - v_uz), J.add(J.add(v_cy, 3.0), (v_i * 2.0)), v_uz, 2.0, v_S)
		game.f_fr(J.add(v_cx, 6.0), J.add(J.add(v_cy, 3.0), (v_i * 2.0)), v_uz, 2.0, v_S)
		v_i = J.add(v_i, 1.0)
	game.f_fr((v_cx - 3.0), J.add(v_cy, 2.0), 7.0, 8.0, v_S)
	game.f_fr((v_cx - 2.0), J.add(v_cy, 10.0), 5.0, 2.0, v_S)
	game.f_fr((v_cx - 1.0), J.add(v_cy, 12.0), 3.0, 1.0, v_S)
	game.f_fr((v_cx - 4.0), v_cy, 3.0, 3.0, v_S)
	game.f_fr(J.add(v_cx, 2.0), v_cy, 3.0, 3.0, v_S)
	game.f_px((v_cx - 5.0), J.add(v_cy, 1.0), v_S)
	game.f_px(J.add(v_cx, 5.0), J.add(v_cy, 1.0), v_S)
	game.f_fr((v_cx - 2.0), (v_cy - 2.0), 5.0, 1.0, v_S)
	game.f_px((v_cx - 2.0), (v_cy - 3.0), v_S)
	game.f_px(v_cx, (v_cy - 4.0), v_S)
	game.f_px(J.add(v_cx, 2.0), (v_cy - 3.0), v_S)
	game.f_px(v_cx, J.add(v_cy, 4.0), v_K)
	game.f_fr((v_cx - 2.0), J.add(v_cy, 5.0), 5.0, 1.0, v_K)
	game.f_fr((v_cx - 1.0), J.add(v_cy, 6.0), 3.0, 1.0, v_K)
	game.f_px((v_cx - 2.0), J.add(v_cy, 7.0), v_K)
	game.f_px(J.add(v_cx, 2.0), J.add(v_cy, 7.0), v_K)
	return null

# ui.js:894
func f_gazeteSusleme(p_x: Variant = null, p_y: Variant = null, p_yon: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_yon: Variant = p_yon
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_S = "#2a251c"
	v_i = 0.0
	while J.lt(v_i, 9.0):
		game.f_px(J.add(v_x, (v_yon * v_i)), J.add(v_y, (0.0 if J.lt(v_i, 3.0) else ((-J.n(1.0)) if J.lt(v_i, 6.0) else 0.0))), v_S)
		v_i = J.add(v_i, 1.0)
	game.f_px(J.add(v_x, (v_yon * 10.0)), (v_y - 2.0), v_S)
	game.f_px(J.add(v_x, (v_yon * 11.0)), (v_y - 3.0), v_S)
	game.f_px(J.add(v_x, (v_yon * 10.0)), J.add(v_y, 2.0), v_S)
	game.f_px(J.add(v_x, (v_yon * 11.0)), J.add(v_y, 3.0), v_S)
	game.f_fr((v_x - (0.0 if J.gt(v_yon, 0.0) else 2.0)), (v_y - 1.0), 2.0, 3.0, v_S)
	return null

# ui.js:903
func f_gazeteSutun(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_n: Variant = null, p_tohum: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_uz: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_n: Variant = p_n
	var v_tohum: Variant = p_tohum
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	J.setv(game.j_ctx, "globalAlpha", 0.52)
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_uz = floor((v_w * J.add(0.55, (game.f_hash1(J.add(v_tohum, (v_i * 1.9))) * 0.45))) + 0.5)
		game.f_fr(v_x, J.add(v_y, (v_i * 4.0)), v_uz, 1.0, "#4a4436")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# ui.js:913
func f_gazeteFoto(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_mx: Variant = null
	var v_tb: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	game.f_fr(v_x, v_y, v_w, v_h, "#9a927e")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), "#c2bba4")
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	v_i = 1.0
	while J.lt(v_i, (v_h - 1.0)):
		game.f_fr(J.add(v_x, 1.0), J.add(v_y, v_i), (v_w - 2.0), 1.0, "#6a6455")
		v_i = J.add(v_i, 2.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_mx = J.add(v_x, floor((float(v_w) / float(2.0)) + 0.5))
	v_tb = (J.add(v_y, v_h) - 3.0)
	game.f_fr((v_mx - 9.0), v_tb, 18.0, 2.0, "#4a4436")
	game.f_fr((v_mx - 6.0), (v_tb - 3.0), 12.0, 3.0, "#5a5142")
	game.f_fr((v_mx - 2.0), (v_tb - 15.0), 5.0, 12.0, "#3a352a")
	game.f_fr((v_mx - 1.0), (v_tb - 18.0), 3.0, 3.0, "#3a352a")
	game.f_px(v_mx, (v_tb - 19.0), "#2a251c")
	game.f_fr((v_mx - 13.0), (v_tb - 10.0), 1.0, 10.0, "#4a4436")
	game.f_fr(J.add(v_mx, 12.0), (v_tb - 10.0), 1.0, 10.0, "#4a4436")
	game.f_fr((v_mx - 12.0), (v_tb - 10.0), 4.0, 3.0, "#8a2318")
	game.f_fr(J.add(v_mx, 9.0), (v_tb - 10.0), 4.0, 3.0, "#8a2318")
	return null

func _closure_271(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_alt: Variant = null
	var v_nh: Variant = null
	var v_sozVar: Variant = null
	var v_kalkanVar: Variant = null
	v_nh = J.arg(_args, 0)
	v_sozVar = J.arg(_args, 1)
	v_kalkanVar = J.arg(_args, 2)
	v_alt = ((34.0 if J.truth(v_kalkanVar) else 24.0) if J.truth(v_sozVar) else (15.0 if J.truth(v_kalkanVar) else 0.0))
	return J.add(J.add(J.add(J.add(J.add(J.add(55.0, (J.getv(_captures["878:liste"][0], "length") * _captures["878:satirH"][0])), 8.0), (v_nh * _captures["878:haberH"][0])), (18.0 if J.truth(_captures["878:liderVar"][0]) else 0.0)), v_alt), 32.0)
	return null
