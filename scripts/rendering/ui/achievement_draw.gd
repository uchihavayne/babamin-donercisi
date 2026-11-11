# Achievement draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# ui.js:2481
func f_drawStatsPanel(p_t: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_kk2: Variant = null
	var v_y: Variant = null
	var v_h: Variant = null
	var v_x: Variant = null
	var v_w: Variant = null
	var v_dar: Variant = null
	var v_rowSp: Variant = null
	var v_satSp: Variant = null
	var v_rows: Variant = null
	var v_i: Variant = null
	var v_col: Variant = null
	var v_row: Variant = null
	var v_rx: Variant = null
	var v_ry: Variant = null
	var v_by: Variant = null
	var v_pr: Variant = null
	var v_t: Variant = p_t
	v_S = (J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {})
	v_kk2 = game.interface_draw.f_panelKutu(18.0, 242.0)
	v_y = J.getv(v_kk2, 0.0)
	v_h = J.getv(v_kk2, 1.0)
	v_x = 78.0
	v_w = 324.0
	v_dar = J.lt(v_h, 238.0)
	v_rowSp = (18.0 if J.truth(v_dar) else 20.0)
	v_satSp = (14.0 if J.truth(v_dar) else 16.0)
	J.setv(game.j_ctx, "globalAlpha", 0.82)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "REKORLAR")
	v_rows = [["wrap", "Toplam dürüm", (J.getv(v_S, "wraps") if J.truth(J.getv(v_S, "wraps")) else 0.0)], ["iskender", "İskender", (J.getv(v_S, "isk") if J.truth(J.getv(v_S, "isk")) else 0.0)], ["cola", "Toplam içecek", (J.getv(v_S, "drinks") if J.truth(J.getv(v_S, "drinks")) else 0.0)], ["fbox", "Patates porsiyon", (J.getv(v_S, "boxes") if J.truth(J.getv(v_S, "boxes")) else 0.0)], ["sweet", "Tatlı", (J.getv(v_S, "sweets") if J.truth(J.getv(v_S, "sweets")) else 0.0)], [null, "Oynanan gün", (J.getv(v_S, "days") if J.truth(J.getv(v_S, "days")) else 0.0)], [null, "Kaçan müşteri", (J.getv(v_S, "lost") if J.truth(J.getv(v_S, "lost")) else 0.0)], [null, "Kaçan müşteri (gün ort.)", (floor((float((J.getv(v_S, "lost") if J.truth(J.getv(v_S, "lost")) else 0.0)) / float(J.getv(v_S, "days"))) + 0.5) if J.truth(J.getv(v_S, "days")) else 0.0)]]
	v_i = 0.0
	while J.lt(v_i, J.getv(v_rows, "length")):
		v_col = fmod(J.n(v_i), J.n(2.0))
		v_row = (int(J.n((float(v_i) / float(2.0)))) | int(J.n(0.0)))
		v_rx = J.add(J.add(v_x, 14.0), (v_col * 152.0))
		v_ry = J.add(J.add(v_y, 16.0), (v_row * v_rowSp))
		if J.truth(J.getv(J.getv(v_rows, v_i), 0.0)):
			if not game.f_hdIkon("lst_" + str(J.getv(J.getv(v_rows, v_i), 0.0)), J.add(v_rx, 6.0), J.add(v_ry, 5.0)):
				game.icon_draw.f_icon(J.getv(J.getv(v_rows, v_i), 0.0), J.add(v_rx, 6.0), J.add(v_ry, 5.0), v_t)
		game.text_draw.f_txt(J.getv(J.getv(v_rows, v_i), 1.0), J.add(v_rx, 16.0), J.add(v_ry, 2.0), J.getv(game.j_P, "ui4"))
		game.text_draw.f_txt(J.add("", J.getv(J.getv(v_rows, v_i), 2.0)), J.add(v_rx, 140.0), J.add(v_ry, 2.0), J.getv(game.j_P, "ink"), {"align": "r"})
		J.setv(game.j_ctx, "globalAlpha", 0.25)
		game.f_hl(v_rx, J.add(v_ry, 12.0), 140.0, J.getv(game.j_P, "ui2"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	v_by = J.add(J.add(v_y, 22.0), (ceil((float(J.getv(v_rows, "length")) / float(2.0))) * v_rowSp))
	game.text_draw.f_txt("En iyi gün", J.add(v_x, 20.0), v_by, J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney((J.getv(v_S, "best") if J.truth(J.getv(v_S, "best")) else 0.0))), (J.add(v_x, v_w) - 20.0), v_by, J.getv(game.j_P, "au2"), {"align": "r"})
	game.text_draw.f_txt("Toplam kazanç", J.add(v_x, 20.0), J.add(v_by, v_satSp), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney((J.getv(v_S, "earned") if J.truth(J.getv(v_S, "earned")) else 0.0))), (J.add(v_x, v_w) - 20.0), J.add(v_by, v_satSp), J.getv(game.j_P, "red1"), {"align": "r", "sc": 1.0})
	game.text_draw.f_txt("Ödenen borç", J.add(v_x, 20.0), J.add(v_by, (v_satSp * 2.0)), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney((J.getv(v_S, "debtPaid") if J.truth(J.getv(v_S, "debtPaid")) else 0.0))), (J.add(v_x, v_w) - 20.0), J.add(v_by, (v_satSp * 2.0)), J.getv(game.j_P, "ok"), {"align": "r"})
	game.text_draw.f_txt("Kalan borç", J.add(v_x, 20.0), J.add(v_by, (v_satSp * 3.0)), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney(J.getv(game.j_G, "debt"))), (J.add(v_x, v_w) - 20.0), J.add(v_by, (v_satSp * 3.0)), ("#a83a2a" if J.gt(J.getv(game.j_G, "debt"), 0.0) else J.getv(game.j_P, "ok")), {"align": "r"})
	game.text_draw.f_txt("Hijyen cezası", J.add(v_x, 20.0), J.add(v_by, (v_satSp * 4.0)), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney((J.getv(v_S, "fines") if J.truth(J.getv(v_S, "fines")) else 0.0))), (J.add(v_x, v_w) - 20.0), J.add(v_by, (v_satSp * 4.0)), "#a83a2a", {"align": "r"})
	game.text_draw.f_txt("Hırsıza kaptırılan", J.add(v_x, 20.0), J.add(v_by, (v_satSp * 5.0)), J.getv(game.j_P, "ui4"))
	game.text_draw.f_txt(J.add("$", game.math_utils.f_fmtMoney((J.getv(v_S, "stolen") if J.truth(J.getv(v_S, "stolen")) else 0.0))), (J.add(v_x, v_w) - 20.0), J.add(v_by, (v_satSp * 5.0)), "#a83a2a", {"align": "r"})
	v_pr = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_G, "debt")) / float(game.j_DEBT_START)), 0.0, 1.0))
	game.counter_draw.f_bar(J.add(v_x, 20.0), J.add(v_by, (v_satSp * 6.0)), (v_w - 40.0), 8.0, v_pr, J.getv(game.j_P, "ok"))
	game.text_draw.f_txt(J.add(game.localization.f_T("borç ödeme: %"), floor((v_pr * 100.0) + 0.5)), J.add(v_x, (float(v_w) / float(2.0))), J.add(J.add(v_by, (v_satSp * 6.0)), 1.0), J.getv(game.j_P, "ui5"), {"align": "c"})
	if J.truth(game.f_button((J.add(v_x, (float(v_w) / float(2.0))) - 40.0), (J.add(v_y, v_h) - 22.0), 80.0, 18.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
		J.setv(game.j_STATS, "open", false)
		J.method(game.j_SFX, "uiBack", [])
	return null

# ui.js:2755
# Rozet ikonu 14x14 yuvaya sigar. BIRLESIK (11. tur): HD ikonlarin bir kismi
# yuvadan buyuktu (patates kutusu 21 px, bardak 19 px, tabak 19 px); rozetten
# tasiyor, kilitli rozette karartma ortusunun disinda renkli kaliyordu. Kucuk
# tek tip "lst_" varyanti varsa o cizilir, yoksa ikon yuvaya kirpilir.
func rozet_ikon(ikon: Variant, x: Variant, y: Variant, t: Variant) -> void:
	var ad: String = "fbox" if str(ikon) == "fries" else str(ikon)
	if game.f_hdIkon("lst_" + ad, J.add(x, 8.0), J.add(y, 8.0)): return
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [J.add(x, 1.0), J.add(y, 1.0), 14.0, 14.0])
	J.method(game.j_ctx, "clip", [])
	game.icon_draw.f_icon(ikon, J.add(x, 8.0), J.add(y, 8.0), t)
	J.method(game.j_ctx, "restore", [])

func f_bsRozet(p_x: Variant = null, p_y: Variant = null, p_b: Variant = null, p_acik: Variant = null, p_sec: Variant = null, p_t: Variant = null) -> Variant:
	var v_hlk: Variant = null
	var v_o: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_b: Variant = p_b
	var v_acik: Variant = p_acik
	var v_sec: Variant = p_sec
	var v_t: Variant = p_t
	v_hlk = (J.getv(game.j_BS_KADEME, ((J.getv(v_b, "kademe") if J.truth(J.getv(v_b, "kademe")) else 1.0) - 1.0)) if J.truth(J.getv(game.j_BS_KADEME, ((J.getv(v_b, "kademe") if J.truth(J.getv(v_b, "kademe")) else 1.0) - 1.0))) else J.getv(game.j_BS_KADEME, 0.0))
	if J.truth(v_acik):
		# REMAKE kancasi: HD rozet (pahli kademe halkasi + cukur yuva)
		if not J.truth(game.f_hdRozet(v_x, v_y, v_hlk)):
			game.f_rrect(v_x, v_y, 16.0, 16.0, 3.0, game.character_draw.f_shadeCol(v_hlk, 0.45))
			game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), 14.0, 14.0, 3.0, "#3a3026")
			game.f_rrectOut(v_x, v_y, 16.0, 16.0, 3.0, v_hlk)
		rozet_ikon(J.getv(v_b, "ikon"), v_x, v_y, v_t)
	else:
		if not J.truth(game.f_hdRozet(v_x, v_y, "#4a4038")):
			game.f_rrect(v_x, v_y, 16.0, 16.0, 3.0, "#171310")
			game.f_rrect(J.add(v_x, 1.0), J.add(v_y, 1.0), 14.0, 14.0, 3.0, "#231d17")
			game.f_rrectOut(v_x, v_y, 16.0, 16.0, 3.0, "#4a4038")
		if J.truth(J.getv(v_b, "gizli")):
			game.text_draw.f_txt("?", J.add(v_x, 8.0), J.add(v_y, 5.0), "#8a7a64", {"align": "c"})
		else:
			rozet_ikon(J.getv(v_b, "ikon"), v_x, v_y, v_t)
			J.setv(game.j_ctx, "globalAlpha", 0.82)
			game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), 14.0, 14.0, "#231d17")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_rc(J.add(v_x, 7.0), J.add(v_y, 5.0), 3.0, 4.0, "#7a6c58")
			game.f_fr(J.add(v_x, 6.0), J.add(v_y, 8.0), 5.0, 4.0, "#6a5c48")
			game.f_fr(J.add(v_x, 6.0), J.add(v_y, 8.0), 5.0, 3.0, "#a8946e")
			game.f_px(J.add(v_x, 8.0), J.add(v_y, 10.0), "#463c2c")
		v_o = game.achievement_system.f_basarimOran(v_b)
		if J.gt(v_o, 0.0):
			game.f_fr(J.add(v_x, 2.0), J.add(v_y, 14.0), max(1.0, floor((12.0 * v_o) + 0.5)), 1.0, game.character_draw.f_shadeCol(v_hlk, 0.9))
	if J.truth(v_sec):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.55, (0.45 * sin((v_t * 6.0)))))
		game.f_rrectOut((v_x - 1.0), (v_y - 1.0), 18.0, 18.0, 4.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# ui.js:2790
func f_drawBasarimPanel(p_t: Variant = null) -> Variant:
	var v_kk: Variant = null
	var v_y: Variant = null
	var v_h: Variant = null
	var v_x: Variant = null
	var v_w: Variant = null
	var v_seritH: Variant = null
	var v_basY: Variant = null
	var v_kalan: Variant = null
	var v_rowH: Variant = null
	var v_acikN: Variant = null
	var v_hoverB: Variant = null
	var v_ry: Variant = null
	var v_g: Variant = null
	var v_gid: Variant = null
	var v_bx: Variant = null
	var v_n: Variant = null
	var v_i: Variant = null
	var v_b: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_uz: Variant = null
	var v_sy: Variant = null
	var v_det: Variant = null
	var v_k: Variant = null
	var v_dAcik: Variant = null
	var v_gizliKilit: Variant = null
	var v_v: Variant = null
	var v_e: Variant = null
	var v_t: Variant = p_t
	v_kk = game.interface_draw.f_panelKutu(14.0, 234.0)
	v_y = J.getv(v_kk, 0.0)
	v_h = J.getv(v_kk, 1.0)
	v_x = 26.0
	v_w = (game.j_W - 52.0)
	v_seritH = 32.0
	v_basY = J.add(v_y, 14.0)
	v_kalan = (((J.add(v_y, v_h) - 6.0) - v_seritH) - v_basY)
	v_rowH = game.math_utils.f_clamp(floor((float(v_kalan) / float(J.getv(game.j_BS_GRUP, "length")))), 17.0, 24.0)
	J.setv(game.j_ctx, "globalAlpha", 0.84)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(v_x, v_y, v_w, v_h, "BAŞARIMLAR")
	v_acikN = game.achievement_system.f_basarimSayisi()
	game.text_draw.f_txt(J.add(J.add(v_acikN, " / "), J.getv(game.j_BASARIM, "length")), (J.add(v_x, v_w) - 32.0), J.add(v_y, 4.0), (J.getv(game.j_P, "au3") if J.ge(v_acikN, J.getv(game.j_BASARIM, "length")) else J.getv(game.j_P, "ui3")), {"align": "r"})
	game.counter_draw.f_bar(J.add(v_x, 12.0), J.add(v_y, 4.0), 88.0, 6.0, (float(v_acikN) / float(J.getv(game.j_BASARIM, "length"))), J.getv(game.j_P, "au1"))
	v_hoverB = null
	v_ry = v_basY
	v_g = 0.0
	while J.lt(v_g, J.getv(game.j_BS_GRUP, "length")):
		v_gid = J.getv(J.getv(game.j_BS_GRUP, v_g), 0.0)
		game.text_draw.f_txt(J.getv(J.getv(game.j_BS_GRUP, v_g), 1.0), J.add(v_x, 10.0), (J.add(v_ry, (float((v_rowH - 8.0)) / float(2.0))) - 1.0), J.getv(game.j_P, "ui3"))
		v_bx = J.add(v_x, 78.0)
		v_n = 0.0
		v_i = 0.0
		while J.lt(v_i, J.getv(game.j_BASARIM, "length")):
			v_b = J.getv(game.j_BASARIM, v_i)
			if not J.eq(J.getv(v_b, "grup"), v_gid):
				v_i = J.add(v_i, 1.0)
				continue
			v_px0 = J.add(v_bx, (v_n * 19.0))
			v_py0 = J.add(v_ry, (float((v_rowH - 16.0)) / float(2.0)))
			v_uz = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), v_px0, v_py0, 17.0, 17.0)
			if J.truth(v_uz):
				v_hoverB = v_b
			game.achievement_draw.f_bsRozet(v_px0, v_py0, v_b, game.achievement_system.f_basarimAcik(J.getv(v_b, "id")), (v_uz if J.truth(v_uz) else J.eq(J.getv(game.j_BSP, "sec"), J.getv(v_b, "id"))), v_t)
			if (J.truth(v_uz) and J.truth(J.getv(game.j_IN, "pressed"))):
				J.setv(game.j_BSP, "sec", J.getv(v_b, "id"))
				J.method(game.j_SFX, "ui", [])
			v_n = J.add(v_n, 1.0)
			v_i = J.add(v_i, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.18)
		game.f_hl(J.add(v_x, 10.0), (J.add(v_ry, v_rowH) - 2.0), (v_w - 20.0), J.getv(game.j_P, "ui2"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_ry = J.add(v_ry, v_rowH)
		v_g = J.add(v_g, 1.0)
	v_sy = ((J.add(v_y, v_h) - v_seritH) - 3.0)
	v_det = (v_hoverB if J.truth(v_hoverB) else game.achievement_system.f_basarimById(J.getv(game.j_BSP, "sec")))
	if (not J.truth(v_det)):
		v_k = 0.0
		while (J.lt(v_k, J.getv(game.j_BASARIM, "length")) and (not J.truth(v_det))):
			if ((not J.truth(game.achievement_system.f_basarimAcik(J.getv(J.getv(game.j_BASARIM, v_k), "id")))) and (not J.truth(J.getv(J.getv(game.j_BASARIM, v_k), "gizli")))):
				v_det = J.getv(game.j_BASARIM, v_k)
			v_k = J.add(v_k, 1.0)
		if (not J.truth(v_det)):
			v_det = J.getv(game.j_BASARIM, 0.0)
	game.f_rrect(J.add(v_x, 6.0), v_sy, (v_w - 12.0), v_seritH, 3.0, "#211a14")
	game.f_rrectOut(J.add(v_x, 6.0), v_sy, (v_w - 12.0), v_seritH, 3.0, J.getv(game.j_P, "ui4"))
	v_dAcik = game.achievement_system.f_basarimAcik(J.getv(v_det, "id"))
	v_gizliKilit = ((not J.truth(v_dAcik)) if J.truth(J.getv(v_det, "gizli")) else J.getv(v_det, "gizli"))
	game.achievement_draw.f_bsRozet(J.add(v_x, 12.0), J.add(v_sy, (float((v_seritH - 16.0)) / float(2.0))), v_det, v_dAcik, false, v_t)
	game.text_draw.f_txt((game.localization.f_T("GİZLİ BAŞARIM") if J.truth(v_gizliKilit) else game.achievement_system.f_bsAd(v_det)), J.add(v_x, 34.0), J.add(v_sy, 5.0), (J.getv(game.j_P, "au0") if J.truth(v_dAcik) else J.getv(game.j_P, "ui0")))
	game.text_draw.f_txt((game.localization.f_T("Bulunca açılır") if J.truth(v_gizliKilit) else game.achievement_system.f_bsAc(v_det)), J.add(v_x, 34.0), J.add(v_sy, 16.0), J.getv(game.j_P, "ui1"))
	if J.truth(v_dAcik):
		game.text_draw.f_txt(J.add(game.localization.f_T("Gün "), J.getv(J.getv(game.j_G, "bs"), J.getv(v_det, "id"))), (J.add(v_x, v_w) - 16.0), J.add(v_sy, 5.0), J.getv(game.j_P, "ok"), {"align": "r"})
	else:
		if (not J.truth(v_gizliKilit)):
			v_v = 0.0
			v_v = floor((J.method(v_det, "oku", [(J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {}), game.j_G]) if J.truth(J.method(v_det, "oku", [(J.getv(game.j_G, "stats") if J.truth(J.getv(game.j_G, "stats")) else {}), game.j_G])) else 0.0))
			game.text_draw.f_txt(J.add(J.add(min(v_v, J.getv(v_det, "hedef")), " / "), J.getv(v_det, "hedef")), (J.add(v_x, v_w) - 16.0), J.add(v_sy, 5.0), J.getv(game.j_P, "ui1"), {"align": "r"})
			game.counter_draw.f_bar((J.add(v_x, v_w) - 96.0), J.add(v_sy, 17.0), 80.0, 6.0, game.achievement_system.f_basarimOran(v_det), J.getv(game.j_P, "au1"))
	if J.truth(game.f_button((J.add(v_x, v_w) - 24.0), J.add(v_y, 2.0), 18.0, 12.0, "X", J.getv(game.j_P, "red1"))):
		J.setv(game.j_BSP, "open", false)
		J.setv(game.j_BSP, "sec", null)
		J.method(game.j_SFX, "uiBack", [])
	return null

# ui.js:2854
func f_drawBasarimToast(p_t: Variant = null, p_dt: Variant = null) -> Variant:
	var v_it: Variant = null
	var v_sure: Variant = null
	var v_gir: Variant = null
	var v_cik: Variant = null
	var v_k: Variant = null
	var v_w: Variant = null
	var v_h: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_t: Variant = p_t
	var v_dt: Variant = p_dt
	if (not J.truth(J.getv(J.getv(game.j_BSQ, "kuyruk"), "length"))):
		return null
	if ((J.truth(J.getv(game.j_BSP, "open")) or J.truth(J.getv(game.j_STATS, "open"))) or J.truth(J.getv(game.j_SESP, "open"))):
		return null
	# BIRLESIK (11. tur): subeler / borc ode / kisisellestir / ev penceresi
	# acikken de bekler (pencerenin alt yazisini ve KAPAT dugmesini ortuyordu)
	if J.truth(game.j_BRP.open) or J.truth(game.j_PAYP.open) or J.truth(game.j_CUSTOM.open) or J.truth(game.j_EVP.open):
		return null
	v_it = J.getv(J.getv(game.j_BSQ, "kuyruk"), 0.0)
	J.setv(v_it, "t", J.add(J.getv(v_it, "t"), v_dt))
	v_sure = 3.4
	if J.gt(J.getv(v_it, "t"), v_sure):
		J.method(J.getv(game.j_BSQ, "kuyruk"), "shift", [])
		return null
	v_gir = game.math_utils.f_clamp((float(J.getv(v_it, "t")) / float(0.28)), 0.0, 1.0)
	v_cik = game.math_utils.f_clamp((float((v_sure - J.getv(v_it, "t"))) / float(0.3)), 0.0, 1.0)
	v_k = min(v_gir, v_cik)
	v_w = 176.0
	v_h = 30.0
	v_bx = floor(((float(game.j_W) / float(2.0)) - (float(v_w) / float(2.0))) + 0.5)
	v_by = floor((((game.j_H - J.getv(game.j_VIEW, "bot")) - 12.0) - (v_h * v_k)) + 0.5)
	J.setv(game.j_ctx, "globalAlpha", v_k)
	J.setv(game.j_ctx, "globalAlpha", (v_k * 0.4))
	game.f_rrect(J.add(v_bx, 2.0), J.add(v_by, 3.0), v_w, v_h, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", v_k)
	# REMAKE kancasi: HD bildirim plakasi (altin pahli 9 dilim)
	if not J.truth(game.f_hdBildirimPlaka(v_bx, v_by, v_w, v_h)):
		game.f_rrect(v_bx, v_by, v_w, v_h, 4.0, "#4a3a1e")
		game.f_rrect(J.add(v_bx, 1.0), J.add(v_by, 1.0), (v_w - 2.0), (v_h - 2.0), 4.0, "#2b2118")
		game.f_rrectOut(v_bx, v_by, v_w, v_h, 4.0, J.getv(game.j_P, "au0"))
	game.achievement_draw.f_bsRozet(J.add(v_bx, 7.0), J.add(v_by, 7.0), J.getv(v_it, "b"), true, false, v_t)
	game.text_draw.f_txt(game.localization.f_T("BAŞARIM AÇILDI"), J.add(v_bx, 29.0), J.add(v_by, 6.0), J.getv(game.j_P, "au2"))
	game.text_draw.f_txt(game.achievement_system.f_bsAd(J.getv(v_it, "b")), J.add(v_bx, 29.0), J.add(v_by, 17.0), J.getv(game.j_P, "ui0"))
	J.setv(game.j_ctx, "globalAlpha", (v_k * J.add(0.25, (0.25 * sin((v_t * 7.0))))))
	game.f_rrectOut((v_bx - 1.0), (v_by - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), 5.0, J.getv(game.j_P, "au1"))
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

