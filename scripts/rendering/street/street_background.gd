# Street background. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:69
func f_mixHex(p_a: Variant = null, p_b: Variant = null, p_k: Variant = null) -> Variant:
	var v_pa: Variant = null
	var v_pb: Variant = null
	var v_r0: Variant = null
	var v_g0: Variant = null
	var v_b0: Variant = null
	var v_r1: Variant = null
	var v_g1: Variant = null
	var v_b1: Variant = null
	var v_a: Variant = p_a
	var v_b: Variant = p_b
	var v_k: Variant = p_k
	v_pa = J.parse_int(J.method(v_a, "slice", [1.0]), 16.0)
	v_pb = J.parse_int(J.method(v_b, "slice", [1.0]), 16.0)
	v_r0 = (int(J.n((int(J.n(v_pa)) >> int(J.n(16.0))))) & int(J.n(255.0)))
	v_g0 = (int(J.n((int(J.n(v_pa)) >> int(J.n(8.0))))) & int(J.n(255.0)))
	v_b0 = (int(J.n(v_pa)) & int(J.n(255.0)))
	v_r1 = (int(J.n((int(J.n(v_pb)) >> int(J.n(16.0))))) & int(J.n(255.0)))
	v_g1 = (int(J.n((int(J.n(v_pb)) >> int(J.n(8.0))))) & int(J.n(255.0)))
	v_b1 = (int(J.n(v_pb)) & int(J.n(255.0)))
	return J.add(J.add(J.add(J.add(J.add(J.add("rgb(", floor(game.math_utils.f_lerp(v_r0, v_r1, v_k) + 0.5)), ","), floor(game.math_utils.f_lerp(v_g0, v_g1, v_k) + 0.5)), ","), floor(game.math_utils.f_lerp(v_b0, v_b1, v_k) + 0.5)), ")")
	return null

# art.js:77
# BIRLESIK (6. tur performans): karede onlarca kez cagriliyor (~16 us); cam
# olculeri degismedikce ayni sozluk (yalniz okunur) doner.
var _stm: Dictionary = {}
var _stm_anahtar := Vector4(-1, -1, -1, -1)
func f_stM() -> Variant:
	var v_G0: Variant = null
	v_G0 = J.getv(game.j_LAY, "glass")
	var anahtar := Vector4(J.n(v_G0.x), J.n(v_G0.y), J.n(v_G0.w), J.n(v_G0.h))
	if anahtar == _stm_anahtar: return _stm
	_stm_anahtar = anahtar
	_stm = {"gx": J.getv(v_G0, "x"), "gy": J.getv(v_G0, "y"), "gw": J.getv(v_G0, "w"), "gh": J.getv(v_G0, "h"), "base": J.add(J.getv(v_G0, "y"), 50.0), "walkY": J.add(J.getv(v_G0, "y"), 57.0), "roadY": J.add(J.getv(v_G0, "y"), 58.0), "roadH": 26.0, "farY": J.add(J.getv(v_G0, "y"), 70.0), "nearY": J.add(J.getv(v_G0, "y"), 82.0), "curb2": J.add(J.getv(v_G0, "y"), 84.0)}
	return _stm

# art.js:397
func f_bakeStreet() -> Variant:
	var v_M: Variant = null
	var v_gx: Variant = null
	var v_gy: Variant = null
	var v_gw: Variant = null
	var v_gh: Variant = null
	var v_TEMA: Variant = null
	var v_y: Variant = null
	var v_cl: Variant = null
	var v_cxx: Variant = null
	var v_cyy: Variant = null
	var v_cw: Variant = null
	var v_kat: Variant = null
	var v_solukluk: Variant = null
	var v_yukseklik: Variant = null
	var v_adim: Variant = null
	var v_kaydir: Variant = null
	var v_sayi: Variant = null
	var v_f: Variant = null
	var v_tohum: Variant = null
	var v_fw: Variant = null
	var v_fx0: Variant = null
	var v_fh: Variant = null
	var v_fy0: Variant = null
	var v_wy: Variant = null
	var v_wx: Variant = null
	var v_pcy: Variant = null
	var v_bx: Variant = null
	var v_bi: Variant = null
	var v_rakipSlot: Variant = null
	var v_rakipDurum: Variant = null
	var v_CP: Variant = null
	var v_bw: Variant = null
	var v_enYuksek: Variant = null
	var v_bh: Variant = null
	var v_hx: Variant = null
	var v_hb: Variant = null
	var v_hn: Variant = null
	var v_yon2: Variant = null
	var v_ux: Variant = null
	var v_hk: Variant = null
	var v_s1: Variant = null
	var v_n: Variant = null
	var v_dsh: Variant = null
	var v_zb: Variant = null
	var v_s2: Variant = null
	# REMAKE kancasi
	if game.f_hdSokakArka(): return null
	v_M = game.street_background.f_stM()
	v_gx = J.getv(v_M, "gx")
	v_gy = J.getv(v_M, "gy")
	v_gw = J.getv(v_M, "gw")
	v_gh = J.getv(v_M, "gh")
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [v_gx, v_gy, v_gw, v_gh])
	J.method(game.j_ctx, "clip", [])
	v_TEMA = game.city_system.f_sehirTema()
	v_y = 0.0
	while J.lt(v_y, 56.0):
		game.f_fr(v_gx, J.add(v_gy, v_y), v_gw, 1.0, game.street_background.f_mixHex(J.getv(J.getv(v_TEMA, "gok"), 0.0), J.getv(J.getv(v_TEMA, "gok"), 1.0), game.math_utils.f_clamp((float(v_y) / float(44.0)), 0.0, 1.0)))
		v_y = J.add(v_y, 1.0)
	v_cl = 0.0
	while J.lt(v_cl, 5.0):
		v_cxx = J.add(J.add(v_gx, 6.0), (game.f_hash1((v_cl * 5.3)) * (v_gw - 24.0)))
		v_cyy = J.add(J.add(v_gy, 3.0), (game.f_hash1((v_cl * 2.1)) * 14.0))
		v_cw = J.add(9.0, (game.f_hash1((v_cl * 1.7)) * 8.0))
		J.setv(game.j_ctx, "globalAlpha", 0.75)
		game.f_ell(v_cxx, J.add(v_cyy, 1.0), v_cw, 3.0, "#dfeaf2")
		game.f_ell(v_cxx, v_cyy, v_cw, 3.0, "#ffffff")
		game.f_ell((v_cxx - (v_cw * 0.5)), J.add(v_cyy, 1.0), (v_cw * 0.55), 2.0, "#ffffff")
		game.f_ell(J.add(v_cxx, (v_cw * 0.55)), J.add(v_cyy, 1.0), (v_cw * 0.45), 2.0, "#f4fafd")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_cl = J.add(v_cl, 1.0)
	if J.truth(J.getv(v_TEMA, "imza")):
		game.signature_draw.f_drawImza(J.getv(v_TEMA, "imza"), J.add(v_gx, floor((v_gw * 0.7) + 0.5)), J.getv(v_M, "base"))
	v_kat = 0.0
	while J.lt(v_kat, 2.0):
		v_solukluk = (0.2 if J.eq(v_kat, 0.0) else 0.34)
		v_yukseklik = (14.0 if J.eq(v_kat, 0.0) else 0.0)
		v_adim = (26.0 if J.eq(v_kat, 0.0) else 30.0)
		v_kaydir = ((-J.n(14.0)) if J.eq(v_kat, 0.0) else (-J.n(10.0)))
		v_sayi = J.add(ceil((float(v_gw) / float(v_adim))), 2.0)
		v_f = 0.0
		while J.lt(v_f, v_sayi):
			v_tohum = J.add((v_f * 3.7), (v_kat * 17.3))
			v_fw = J.add(18.0, floor((game.f_hash1(v_tohum) * 24.0)))
			v_fx0 = J.add(J.add(v_gx, v_kaydir), (v_f * v_adim))
			v_fh = J.add(J.add(20.0, v_yukseklik), floor((game.f_hash1((v_tohum * 1.9)) * 20.0)))
			v_fy0 = (J.getv(v_M, "base") - v_fh)
			if J.lt(v_fy0, J.add(v_gy, 2.0)):
				v_fy0 = J.add(v_gy, 2.0)
			J.setv(game.j_ctx, "globalAlpha", v_solukluk)
			game.f_fr(v_fx0, v_fy0, v_fw, (J.getv(v_M, "base") - v_fy0), (J.getv(J.getv(v_TEMA, "bina"), 0.0) if J.eq(v_kat, 0.0) else J.getv(J.getv(v_TEMA, "bina"), 1.0)))
			game.f_fr(v_fx0, v_fy0, v_fw, 2.0, game.street_background.f_mixHex(J.getv(J.getv(v_TEMA, "bina"), 0.0), "#ffffff", 0.18))
			if J.gt(game.f_hash1((v_tohum * 5.1)), 0.62):
				game.f_fr(J.add(v_fx0, 4.0), (v_fy0 - 4.0), 5.0, 4.0, J.getv(J.getv(v_TEMA, "bina"), 0.0))
				game.f_fr(J.add(v_fx0, 3.0), (v_fy0 - 5.0), 7.0, 1.0, game.street_background.f_mixHex(J.getv(J.getv(v_TEMA, "bina"), 0.0), "#ffffff", 0.18))
			if J.gt(game.f_hash1((v_tohum * 8.3)), 0.7):
				game.f_vl((J.add(v_fx0, v_fw) - 6.0), (v_fy0 - 6.0), 6.0, game.street_background.f_mixHex(J.getv(J.getv(v_TEMA, "bina"), 0.0), "#ffffff", 0.18))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_wy = 0.0
			while J.lt(v_wy, 6.0):
				v_wx = 0.0
				while J.lt(v_wx, 3.0):
					if J.lt(game.f_hash1(J.add(J.add((v_tohum * 11.0), (v_wy * 3.3)), (v_wx * 1.9))), 0.48):
						v_wx = J.add(v_wx, 1.0)
						continue
					v_pcy = J.add(J.add(v_fy0, 5.0), (v_wy * 6.0))
					if J.gt(J.add(v_pcy, 4.0), (J.getv(v_M, "base") - 2.0)):
						break
					J.setv(game.j_ctx, "globalAlpha", (v_solukluk * 0.8))
					game.f_fr(J.add(J.add(v_fx0, 4.0), (v_wx * 6.0)), v_pcy, 3.0, 4.0, "#e6f0f6")
					J.setv(game.j_ctx, "globalAlpha", 1.0)
					v_wx = J.add(v_wx, 1.0)
				v_wy = J.add(v_wy, 1.0)
			v_f = J.add(v_f, 1.0)
		v_kat = J.add(v_kat, 1.0)
	v_bx = (v_gx - 16.0)
	v_bi = 0.0
	v_rakipSlot = 3.0
	v_rakipDurum = game.rival_building.f_rakipCepheDurum()
	v_CP = (J.getv(v_TEMA, "cephe") if J.truth(J.getv(v_TEMA, "cephe")) else {"boyAz": 24.0, "boyCok": 34.0, "genAz": 46.0, "genCok": 66.0, "tarz": "dukkan"})
	while J.lt(v_bx, J.add(J.add(v_gx, v_gw), 10.0)):
		v_bw = J.add(J.getv(v_CP, "genAz"), floor((game.f_hash1((v_bi * 4.3)) * (J.getv(v_CP, "genCok") - J.getv(v_CP, "genAz")))))
		v_enYuksek = ((J.getv(v_M, "base") - v_gy) - 16.0)
		v_bh = J.add(J.getv(v_CP, "boyAz"), floor((game.f_hash1((v_bi * 9.1)) * max(1.0, (J.getv(v_CP, "boyCok") - J.getv(v_CP, "boyAz"))))))
		if J.gt(v_bh, v_enYuksek):
			v_bh = v_enYuksek
		if ((J.eq(v_bi, v_rakipSlot) and J.truth(v_rakipDurum)) and J.eq(J.getv(v_CP, "tarz"), "dukkan")):
			v_bw = 58.0
			game.building_draw.f_drawBuilding(v_bx, J.getv(v_M, "base"), v_bw, min(v_bh, 30.0), v_bi, v_gy, J.getv(v_CP, "tarz"), v_rakipDurum)
		else:
			game.building_draw.f_drawBuilding(v_bx, J.getv(v_M, "base"), v_bw, v_bh, v_bi, v_gy, J.getv(v_CP, "tarz"))
		v_bx = J.add(v_bx, J.add(v_bw, 3.0))
		v_bi = J.add(v_bi, 1.0)
	if J.eq(J.getv(v_CP, "tarz"), "beton"):
		v_hx = J.add(v_gx, floor((v_gw * 0.34) + 0.5))
		v_hb = J.add(J.getv(v_M, "base"), 2.0)
		game.f_fr(v_hx, (v_hb - 40.0), 2.0, 40.0, "#4a4e54")
		game.f_fr(v_hx, (v_hb - 40.0), 1.0, 40.0, "#6a6e74")
		game.f_fr((v_hx - 5.0), (v_hb - 39.0), 12.0, 1.0, "#4a4e54")
		v_hn = 0.0
		while J.lt(v_hn, 2.0):
			v_yon2 = (1.0 if J.truth(v_hn) else (-J.n(1.0)))
			v_ux = J.add(v_hx, (6.0 if J.truth(v_hn) else (-J.n(6.0))))
			v_hk = 0.0
			while J.lt(v_hk, 5.0):
				game.f_fr(J.add(v_ux, (v_yon2 * v_hk)), ((v_hb - 42.0) - v_hk), 1.0, J.add(3.0, (v_hk * 2.0)), "#3e4248")
				v_hk = J.add(v_hk, 1.0)
			game.f_fr(J.add(v_ux, (v_yon2 * 4.0)), (v_hb - 47.0), 1.0, 12.0, "#5a5e64")
			v_hn = J.add(v_hn, 1.0)
		game.f_fr((v_hx - 1.0), (v_hb - 41.0), 4.0, 3.0, "#5a5e64")
	game.f_fr(v_gx, J.add(J.getv(v_M, "base"), 1.0), v_gw, 7.0, game.street_background.f_mixHex(J.getv(v_TEMA, "kaldirim"), "#000000", 0.16))
	game.f_fr(v_gx, J.add(J.getv(v_M, "base"), 1.0), v_gw, 6.0, J.getv(v_TEMA, "kaldirim"))
	v_s1 = (v_gx - 3.0)
	while J.lt(v_s1, J.add(v_gx, v_gw)):
		game.f_vl(J.add(v_s1, (5.0 if J.truth(fmod(J.n((int(J.n((float(v_s1) / float(13.0)))) | int(J.n(0.0)))), J.n(2.0))) else 0.0)), J.add(J.getv(v_M, "base"), 1.0), 6.0, "#a9b0b7")
		v_s1 = J.add(v_s1, 13.0)
	game.f_hl(v_gx, J.add(J.getv(v_M, "base"), 1.0), v_gw, "#dbe1e6")
	game.f_fr(v_gx, J.add(J.getv(v_M, "base"), 7.0), v_gw, 2.0, "#858c93")
	game.f_hl(v_gx, J.add(J.getv(v_M, "base"), 7.0), v_gw, "#cbd1d7")
	game.f_fr(v_gx, J.getv(v_M, "roadY"), v_gw, J.getv(v_M, "roadH"), J.getv(v_TEMA, "yol"))
	v_n = 0.0
	while J.lt(v_n, 190.0):
		J.setv(game.j_ctx, "globalAlpha", 0.26)
		game.f_px(J.add(v_gx, (game.f_hash1((v_n * 3.1)) * v_gw)), J.add(J.add(J.getv(v_M, "roadY"), 2.0), (game.f_hash1((v_n * 5.7)) * (J.getv(v_M, "roadH") - 4.0))), ("#565b62" if J.gt(game.f_hash1(v_n), 0.5) else "#35383e"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_n = J.add(v_n, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.18)
	game.f_fr(J.add(v_gx, 150.0), J.add(J.getv(v_M, "roadY"), 4.0), 40.0, 9.0, "#000")
	game.f_fr(J.add(v_gx, 40.0), J.add(J.getv(v_M, "roadY"), 15.0), 26.0, 6.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_dsh = J.add(v_gx, 3.0)
	while J.lt(v_dsh, J.add(v_gx, v_gw)):
		game.f_fr(v_dsh, (J.add(J.getv(v_M, "roadY"), floor((float(J.getv(v_M, "roadH")) / float(2.0)) + 0.5)) - 1.0), 11.0, 2.0, "#d9cf98")
		game.f_hl(v_dsh, (J.add(J.getv(v_M, "roadY"), floor((float(J.getv(v_M, "roadH")) / float(2.0)) + 0.5)) - 1.0), 11.0, "#f2ebc4")
		v_dsh = J.add(v_dsh, 20.0)
	v_zb = 0.0
	while J.lt(v_zb, 5.0):
		game.f_fr(J.add(J.add(v_gx, 196.0), (v_zb * 8.0)), J.add(J.getv(v_M, "roadY"), 1.0), 5.0, (J.getv(v_M, "roadH") - 2.0), "rgba(232,236,240,.72)")
		v_zb = J.add(v_zb, 1.0)
	game.f_fr(v_gx, J.getv(v_M, "curb2"), v_gw, 2.0, "#858c93")
	game.f_hl(v_gx, J.getv(v_M, "curb2"), v_gw, "#cbd1d7")
	game.f_fr(v_gx, J.add(J.getv(v_M, "curb2"), 2.0), v_gw, ((J.add(v_gy, v_gh) - J.getv(v_M, "curb2")) - 2.0), J.getv(v_TEMA, "kaldirim"))
	v_s2 = J.add(v_gx, 5.0)
	while J.lt(v_s2, J.add(v_gx, v_gw)):
		game.f_vl(v_s2, J.add(J.getv(v_M, "curb2"), 2.0), ((J.add(v_gy, v_gh) - J.getv(v_M, "curb2")) - 2.0), "#9aa1a8")
		v_s2 = J.add(v_s2, 15.0)
	game.f_hl(v_gx, J.add(J.getv(v_M, "curb2"), 2.0), v_gw, "#d2d8dd")
	J.method(game.j_ctx, "restore", [])
	return null

# art.js:551
func f_drawSokakAgaci(p_tx: Variant = null, p_ty: Variant = null, p_tip: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_py0: Variant = null
	var v_pxx: Variant = null
	var v_p: Variant = null
	var v_pa: Variant = null
	var v_hd: Variant = null
	var v_lf2: Variant = null
	var v_lf3: Variant = null
	var v_lf: Variant = null
	var v_tx: Variant = p_tx
	var v_ty: Variant = p_ty
	var v_tip: Variant = p_tip
	# REMAKE kancasi
	if game.f_hdSokakAgaci(p_tx, p_ty, p_tip): return null
	if J.eq(v_tip, "palmiye"):
		game.f_fr((v_tx - 4.0), (v_ty - 2.0), 9.0, 3.0, "#5a4a32")
		v_s = 0.0
		while J.lt(v_s, 23.0):
			game.f_px(J.add(v_tx, floor((sin((v_s * 0.16)) * 2.0) + 0.5)), ((v_ty - 2.0) - v_s), ("#87694a" if J.eq(fmod(J.n(v_s), J.n(3.0)), 0.0) else "#6b533a"))
			v_s = J.add(v_s, 1.0)
		v_py0 = (v_ty - 26.0)
		v_pxx = J.add(v_tx, floor((sin((23.0 * 0.16)) * 2.0) + 0.5))
		v_p = 0.0
		while J.lt(v_p, 7.0):
			v_pa = J.add((-J.n(2.95)), (v_p * 0.49))
			game.f_ln(v_pxx, v_py0, J.add(v_pxx, (cos(v_pa) * 13.0)), J.add(v_py0, (sin(v_pa) * 9.0)), "#2f6a34")
			game.f_ln(v_pxx, v_py0, J.add(v_pxx, (cos(v_pa) * 10.0)), J.add(v_py0, (sin(v_pa) * 7.0)), "#3f8a4a")
			game.f_ln(v_pxx, v_py0, J.add(v_pxx, (cos(v_pa) * 6.0)), J.add(v_py0, (sin(v_pa) * 4.0)), "#4d9a58")
			v_p = J.add(v_p, 1.0)
		v_hd = 0.0
		while J.lt(v_hd, 4.0):
			game.f_px(J.add((v_pxx - 2.0), v_hd), J.add(v_py0, 2.0), "#b0862a")
			v_hd = J.add(v_hd, 1.0)
		return null
	if J.eq(v_tip, "sakura"):
		game.f_fr((v_tx - 4.0), (v_ty - 2.0), 9.0, 3.0, "#5a4a32")
		game.f_fr((v_tx - 1.0), (v_ty - 19.0), 3.0, 18.0, "#5a4436")
		game.f_vl((v_tx - 1.0), (v_ty - 19.0), 18.0, "#75594a")
		game.f_ln(v_tx, (v_ty - 13.0), (v_tx - 5.0), (v_ty - 18.0), "#5a4436")
		game.f_ln(v_tx, (v_ty - 15.0), J.add(v_tx, 5.0), (v_ty - 19.0), "#5a4436")
		game.f_ell(v_tx, (v_ty - 24.0), 11.0, 7.0, "#c9738f")
		game.f_ell((v_tx - 5.0), (v_ty - 26.0), 7.0, 5.0, "#e090aa")
		game.f_ell(J.add(v_tx, 5.0), (v_ty - 23.0), 7.0, 5.0, "#e090aa")
		game.f_ell((v_tx - 1.0), (v_ty - 28.0), 6.0, 4.0, "#f7b8ce")
		v_lf2 = 0.0
		while J.lt(v_lf2, 9.0):
			game.f_px(J.add((v_tx - 8.0), (game.f_hash1((v_lf2 * 3.7)) * 16.0)), J.add((v_ty - 29.0), (game.f_hash1((v_lf2 * 5.1)) * 12.0)), "#ffd8e6")
			v_lf2 = J.add(v_lf2, 1.0)
		return null
	if J.eq(v_tip, "budanmis"):
		game.f_fr((v_tx - 4.0), (v_ty - 2.0), 9.0, 3.0, "#5a4a32")
		game.f_fr((v_tx - 1.0), (v_ty - 22.0), 3.0, 21.0, "#6b6252")
		game.f_vl((v_tx - 1.0), (v_ty - 22.0), 21.0, "#877c68")
		game.f_fr((v_tx - 9.0), (v_ty - 31.0), 19.0, 10.0, "#2f5a30")
		game.f_fr((v_tx - 8.0), (v_ty - 31.0), 17.0, 9.0, "#3d6f39")
		game.f_hl((v_tx - 7.0), (v_ty - 31.0), 15.0, "#4d8544")
		v_lf3 = 0.0
		while J.lt(v_lf3, 10.0):
			game.f_px(J.add((v_tx - 8.0), (game.f_hash1((v_lf3 * 3.7)) * 17.0)), J.add((v_ty - 30.0), (game.f_hash1((v_lf3 * 5.1)) * 8.0)), "#5b9a4e")
			v_lf3 = J.add(v_lf3, 1.0)
		return null
	game.f_fr((v_tx - 4.0), (v_ty - 2.0), 9.0, 3.0, "#5a4a32")
	game.f_fr((v_tx - 1.0), (v_ty - 20.0), 3.0, 19.0, "#6b533a")
	game.f_vl((v_tx - 1.0), (v_ty - 20.0), 19.0, "#87694a")
	game.f_ln(v_tx, (v_ty - 14.0), (v_tx - 4.0), (v_ty - 18.0), "#6b533a")
	game.f_ln(v_tx, (v_ty - 16.0), J.add(v_tx, 4.0), (v_ty - 20.0), "#6b533a")
	game.f_ell(v_tx, (v_ty - 25.0), 11.0, 8.0, "#2f5a30")
	game.f_ell((v_tx - 4.0), (v_ty - 27.0), 7.0, 6.0, "#3d6f39")
	game.f_ell(J.add(v_tx, 5.0), (v_ty - 24.0), 7.0, 5.0, "#3d6f39")
	game.f_ell((v_tx - 1.0), (v_ty - 29.0), 6.0, 4.0, "#4d8544")
	v_lf = 0.0
	while J.lt(v_lf, 8.0):
		game.f_px(J.add((v_tx - 8.0), (game.f_hash1((v_lf * 3.7)) * 16.0)), J.add((v_ty - 30.0), (game.f_hash1((v_lf * 5.1)) * 12.0)), "#63a052")
		v_lf = J.add(v_lf, 1.0)
	return null

# art.js:607
func f_drawSehirIkonu(p_x: Variant = null, p_y: Variant = null, p_id: Variant = null, p_t: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_kk: Variant = null
	var v_jj: Variant = null
	var v_pp: Variant = null
	var v_oi: Variant = null
	var v_pd: Variant = null
	var v_pa2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_id: Variant = p_id
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdSehirIkonu(p_x, p_y, p_id, p_t): return null
	if J.eq(v_id, "simit"):
		game.f_fr((v_x - 3.0), (v_y - 11.0), 16.0, 9.0, "#8a2318")
		game.f_fr((v_x - 2.0), (v_y - 11.0), 14.0, 8.0, "#c0392b")
		game.f_hl((v_x - 2.0), (v_y - 11.0), 14.0, "#e2604f")
		game.f_fr((v_x - 4.0), (v_y - 14.0), 18.0, 3.0, "#e8ecef")
		game.f_hl((v_x - 4.0), (v_y - 14.0), 18.0, "#ffffff")
		v_s = 0.0
		while J.lt(v_s, 3.0):
			game.f_ring(J.add(J.add(v_x, 1.0), (v_s * 4.0)), (v_y - 7.0), 2.0, "#c9a03a")
			v_s = J.add(v_s, 1.0)
		game.f_disc(J.add(v_x, 1.0), (v_y - 1.0), 2.0, "#3a3f45")
		game.f_disc(J.add(v_x, 9.0), (v_y - 1.0), 2.0, "#3a3f45")
		return null
	if J.eq(v_id, "sutun"):
		game.f_fr(v_x, (v_y - 19.0), 11.0, 19.0, "#3a4048")
		game.f_fr(J.add(v_x, 1.0), (v_y - 19.0), 9.0, 18.0, "#5a4a6a")
		game.f_hl(J.add(v_x, 1.0), (v_y - 19.0), 9.0, "#7a6a8a")
		game.f_fr(J.add(v_x, 2.0), (v_y - 16.0), 7.0, 6.0, "#d8a03c")
		game.f_fr(J.add(v_x, 3.0), (v_y - 14.0), 5.0, 1.0, "#6b4a10")
		game.f_fr(J.add(v_x, 2.0), (v_y - 8.0), 7.0, 5.0, "#c0392b")
		game.f_fr(J.add(v_x, 3.0), (v_y - 6.0), 5.0, 1.0, "#6b1a12")
		game.f_fr((v_x - 1.0), (v_y - 22.0), 13.0, 3.0, "#2f343a")
		game.f_hl((v_x - 1.0), (v_y - 22.0), 13.0, "#5a636b")
		return null
	if J.eq(v_id, "kulube"):
		game.f_fr((v_x - 1.0), (v_y - 23.0), 13.0, 23.0, "#7a1810")
		game.f_fr(v_x, (v_y - 22.0), 11.0, 22.0, "#c0392b")
		game.f_hl(v_x, (v_y - 22.0), 11.0, "#e2604f")
		v_kk = 0.0
		while J.lt(v_kk, 3.0):
			v_jj = 0.0
			while J.lt(v_jj, 2.0):
				game.f_fr(J.add(J.add(v_x, 1.0), (v_jj * 5.0)), J.add((v_y - 20.0), (v_kk * 6.0)), 4.0, 5.0, "#2c3b45")
				v_jj = J.add(v_jj, 1.0)
			v_kk = J.add(v_kk, 1.0)
		game.f_fr((v_x - 2.0), (v_y - 26.0), 15.0, 4.0, "#7a1810")
		game.f_fr((v_x - 1.0), (v_y - 26.0), 13.0, 3.0, "#c0392b")
		game.f_hl((v_x - 1.0), (v_y - 26.0), 13.0, "#e2604f")
		return null
	if J.eq(v_id, "sarisari"):
		game.f_fr((v_x - 4.0), (v_y - 11.0), 19.0, 11.0, "#6b533a")
		game.f_fr((v_x - 3.0), (v_y - 11.0), 17.0, 10.0, "#8a6a48")
		game.f_fr((v_x - 5.0), (v_y - 14.0), 21.0, 3.0, "#3f8a4a")
		game.f_hl((v_x - 5.0), (v_y - 14.0), 21.0, "#63b46f")
		v_pp = 0.0
		while J.lt(v_pp, 7.0):
			game.f_fr(J.add((v_x - 4.0), (v_pp * 3.0)), (v_y - 11.0), 2.0, 3.0, J.getv(["#e8b62c", "#c0392b", "#3f6fbd", "#e07a2a", "#7a4a9a", "#2aa08a", "#e2604f"], v_pp))
			v_pp = J.add(v_pp, 1.0)
		game.f_fr(J.add(v_x, 2.0), (v_y - 8.0), 6.0, 4.0, "#e8ecef")
		game.f_hl(J.add(v_x, 2.0), (v_y - 8.0), 6.0, "#ffffff")
		return null
	if J.eq(v_id, "kafe"):
		game.f_ell(J.add(v_x, 4.0), (v_y - 10.0), 6.0, 2.0, "#e8ecef")
		game.f_vl(J.add(v_x, 4.0), (v_y - 9.0), 8.0, "#6f777f")
		game.f_fr(J.add(v_x, 3.0), (v_y - 2.0), 3.0, 2.0, "#4d545b")
		game.f_px(J.add(v_x, 3.0), (v_y - 12.0), "#c0392b")
		game.f_px(J.add(v_x, 4.0), (v_y - 13.0), "#c0392b")
		game.f_fr((v_x - 3.0), (v_y - 8.0), 2.0, 8.0, "#2f6a4a")
		game.f_fr((v_x - 4.0), (v_y - 13.0), 4.0, 6.0, "#3f8a5a")
		game.f_fr(J.add(v_x, 9.0), (v_y - 8.0), 2.0, 8.0, "#2f6a4a")
		game.f_fr(J.add(v_x, 9.0), (v_y - 13.0), 4.0, 6.0, "#3f8a5a")
		return null
	if J.eq(v_id, "otomat"):
		game.f_fr((v_x - 1.0), (v_y - 21.0), 14.0, 21.0, "#2f343a")
		game.f_fr(v_x, (v_y - 20.0), 12.0, 20.0, "#e8ecef")
		game.f_fr(J.add(v_x, 1.0), (v_y - 19.0), 10.0, 12.0, "#16202c")
		v_oi = 0.0
		while J.lt(v_oi, 6.0):
			game.f_fr(J.add(J.add(v_x, 2.0), (fmod(J.n(v_oi), J.n(3.0)) * 3.0)), J.add((v_y - 18.0), (floor((float(v_oi) / float(3.0))) * 5.0)), 2.0, 4.0, J.getv(["#c0392b", "#3f6fbd", "#e8b62c", "#3f8a4a", "#e07a2a", "#e8ecef"], v_oi))
			v_oi = J.add(v_oi, 1.0)
		game.f_fr(J.add(v_x, 1.0), (v_y - 6.0), 10.0, 2.0, "#8f979f")
		game.f_fr(J.add(v_x, 2.0), (v_y - 3.0), 4.0, 1.0, "#4d545b")
		J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (0.06 * sin((v_t * 2.0)))))
		game.f_fr((v_x - 3.0), (v_y - 23.0), 18.0, 24.0, "#bfe8ff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		return null
	if J.eq(v_id, "musluk"):
		game.f_fr(J.add(v_x, 2.0), (v_y - 11.0), 7.0, 11.0, "#8a2318")
		game.f_fr(J.add(v_x, 3.0), (v_y - 11.0), 5.0, 10.0, "#c0392b")
		game.f_hl(J.add(v_x, 3.0), (v_y - 11.0), 5.0, "#e2604f")
		game.f_fr(J.add(v_x, 1.0), (v_y - 13.0), 9.0, 2.0, "#8a2318")
		game.f_fr(J.add(v_x, 4.0), (v_y - 15.0), 3.0, 2.0, "#c0392b")
		game.f_fr(v_x, (v_y - 8.0), 2.0, 3.0, "#8a2318")
		game.f_fr(J.add(v_x, 9.0), (v_y - 8.0), 2.0, 3.0, "#8a2318")
		if J.truth(game.f_chance(0.045)):
			game.effects.f_smoke(J.add(v_x, 16.0), (v_y - 1.0), 1.0, "rgba(220,228,236,.42)")
		return null
	if J.eq(v_id, "palmiye"):
		game.f_fr(J.add(v_x, 1.0), (v_y - 6.0), 9.0, 6.0, "#9a7a52")
		game.f_fr(J.add(v_x, 2.0), (v_y - 6.0), 7.0, 5.0, "#c09868")
		game.f_hl(J.add(v_x, 2.0), (v_y - 6.0), 7.0, "#d8b088")
		game.f_fr(J.add(v_x, 4.0), (v_y - 17.0), 3.0, 11.0, "#6b533a")
		game.f_vl(J.add(v_x, 4.0), (v_y - 17.0), 11.0, "#87694a")
		v_pd = 0.0
		while J.lt(v_pd, 6.0):
			v_pa2 = J.add((-J.n(2.85)), (v_pd * 0.55))
			game.f_ln(J.add(v_x, 5.0), (v_y - 18.0), J.add(J.add(v_x, 5.0), (cos(v_pa2) * 9.0)), J.add((v_y - 18.0), (sin(v_pa2) * 6.0)), "#2f6a34")
			game.f_ln(J.add(v_x, 5.0), (v_y - 18.0), J.add(J.add(v_x, 5.0), (cos(v_pa2) * 6.0)), J.add((v_y - 18.0), (sin(v_pa2) * 4.0)), "#4d9a58")
			v_pd = J.add(v_pd, 1.0)
		return null
	game.f_fr(v_x, (v_y - 12.0), 7.0, 12.0, "#8a2318")
	game.f_fr(v_x, (v_y - 12.0), 6.0, 11.0, "#c0392b")
	game.f_hl(v_x, (v_y - 12.0), 6.0, "#e2604f")
	game.f_fr(J.add(v_x, 1.0), (v_y - 10.0), 4.0, 1.0, "#3a1a14")
	game.f_vl(J.add(v_x, 3.0), v_y, 1.0, "#5a636b")
	return null

