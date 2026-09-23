# Customer draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:546
func f_drawCustomer(p_c: Variant = null, p_t: Variant = null) -> Variant:
	var _cells: Dictionary = {"hh": [null], "KON": [null]}
	var v_L: Variant = null
	var v_s: Variant = null
	var v_hc: Variant = null
	var v_sh: Variant = null
	var v_bob: Variant = null
	var v_jitter: Variant = null
	var v_jump: Variant = null
	var v_sway: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_tip: Variant = null
	var v_cocuk: Variant = null
	var v_kadin: Variant = null
	var v_wide: Variant = null
	var v_hy: Variant = null
	var v_hx: Variant = null
	var v_by: Variant = null
	var v_bw: Variant = null
	var v_hy2: Variant = null
	var v_i: Variant = null
	var v_j: Variant = null
	var v_KLP: Variant = null
	var v_F: Variant = null
	var v_hw: Variant = null
	var v_yzS: Variant = null
	var v_konG: Variant = null
	var v_kr: Variant = null
	var v_kw: Variant = null
	var v_ky: Variant = null
	var v_ycx: Variant = null
	var v_ycR: Variant = null
	var v_kc: Variant = null
	var v_cw: Variant = null
	var v_cy: Variant = null
	var v_dyc: Variant = null
	var v_yar: Variant = null
	var v_ca: Variant = null
	var v_cb: Variant = null
	var v_kg: Variant = null
	var v_kuG: Variant = null
	var v_sacG: Variant = null
	var v_mood: Variant = null
	var v_ang: Variant = null
	var v_hap: Variant = null
	var v_imp: Variant = null
	var v_icE: Variant = null
	var v_fy: Variant = null
	var v_agzU: Variant = null
	var v_browY: Variant = null
	var v_kaW: Variant = null
	var v_kaH: Variant = null
	var v_kaD: Variant = null
	var v_kaC: Variant = null
	var v_kSol: Variant = null
	var v_kSag: Variant = null
	var v_blink: Variant = null
	var v_gzW: Variant = null
	var v_gzH: Variant = null
	var v_gzA: Variant = null
	var v_gzD: Variant = null
	var v_bbW: Variant = null
	var v_bbH: Variant = null
	var v_gzC: Variant = null
	var v_gSol: Variant = null
	var v_gSag: Variant = null
	var v_gB: Variant = null
	var v_lx: Variant = null
	var v_ly: Variant = null
	var v_pH: Variant = null
	var v_akUst: Variant = null
	var v_akH: Variant = null
	var v_pY: Variant = null
	var v_ynG: Variant = null
	var v_cl: Variant = null
	var v_cxx: Variant = null
	var v_cyy: Variant = null
	var v_ceG: Variant = null
	var v_byG: Variant = null
	var v_skG: Variant = null
	var v_b: Variant = null
	var v_bh: Variant = null
	var v_skA: Variant = null
	var v_my: Variant = null
	var v_agD: Variant = null
	var v_glT: Variant = null
	var v_glS: Variant = null
	var v_glG: Variant = null
	var v_glC: Variant = null
	var v_vx2: Variant = null
	var v_vy2: Variant = null
	var v_c: Variant = p_c
	var v_t: Variant = p_t
	v_konG = game.customer_draw._closure_84.bind({"361:hh": _cells["hh"], "361:KON": _cells["KON"]})
	v_L = J.getv(v_c, "look")
	v_s = J.getv(game.j_SKINS, J.getv(v_L, "skin"))
	v_hc = J.getv(game.j_HAIRCOLS, J.getv(v_L, "hairCol"))
	v_sh = (J.getv(v_L, "shirtCol") if J.truth(J.getv(v_L, "shirtCol")) else J.getv(game.j_SHIRTS, J.getv(v_L, "shirt")))
	v_bob = (sin(J.add((v_t * 2.0), J.getv(v_L, "seed"))) * (1.7 if J.eq(J.getv(v_c, "mood"), "angry") else 0.8))
	v_jitter = (floor(sin((v_t * 26.0)) + 0.5) if J.eq(J.getv(v_c, "mood"), "angry") else 0.0)
	v_jump = (((-J.n(abs(sin((v_t * 8.0))))) * 2.0) if (J.eq(J.getv(v_c, "mood"), "happy") or J.eq(J.getv(v_c, "mood"), "served")) else 0.0)
	v_sway = ((sin((v_t * 11.0)) * 1.2) if (J.eq(J.getv(v_c, "state"), "walkin") or J.eq(J.getv(v_c, "state"), "leave")) else 0.0)
	# REMAKE: HD'de salinim/nefes yarim piksel adimla (2x izgara); eskide tam piksel
	v_x = game.f_hdYarimPx(J.add(J.add(J.getv(v_c, "x"), v_jitter), v_sway))
	v_y = game.f_hdYarimPx(J.add(J.add(J.add(J.getv(v_c, "y"), v_bob), v_jump), game.f_hdAdim(v_c, v_t)))
	v_tip = (J.getv(v_L, "tip") if J.truth(J.getv(v_L, "tip")) else ("adam" if J.lt(game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0) * 2.3)), 0.42) else ("kadin" if J.lt(game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0) * 2.3)), 0.8) else "cocuk")))
	v_cocuk = J.eq(v_tip, "cocuk")
	v_kadin = J.eq(v_tip, "kadin")
	v_wide = ((-J.n(4.0)) if J.truth(v_cocuk) else (3.0 if J.truth(J.getv(v_L, "big")) else 0.0))
	v_hy = J.add((v_y - 42.0), (11.0 if J.truth(v_cocuk) else 0.0))
	v_hx = v_x
	if (J.eq(J.kind(J.ref(game.sprite_draw.f_sprMusteri, 4)), "function") and J.truth(game.sprite_draw.f_sprMusteri(v_c, v_t, v_x, v_y))):
		game.sprite_draw.f_sprDuygu(v_hx, v_hy, J.getv(v_c, "mood"), v_t)
		return null
	v_by = J.add((v_y - 30.0), (9.0 if J.truth(v_cocuk) else 0.0))
	v_bw = J.add(26.0, (v_wide * 2.0))
	# REMAKE kancasi
	if not game.f_hdMusteriGovde(v_x, v_by, v_bw, v_sh):
		game.f_ell(v_x, J.add(v_by, 5.0), (float(v_bw) / float(2.0)), 7.0, game.character_draw.f_shadeCol(v_sh, 0.72))
		game.f_fr((v_x - (float(v_bw) / float(2.0))), J.add(v_by, 5.0), v_bw, 26.0, game.character_draw.f_shadeCol(v_sh, 0.72))
		game.f_ell(v_x, J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 1.0), 6.0, v_sh)
		game.f_fr(J.add((v_x - (float(v_bw) / float(2.0))), 1.0), J.add(v_by, 4.0), (v_bw - 2.0), 26.0, v_sh)
		game.f_fr(J.add((v_x - (float(v_bw) / float(2.0))), 1.0), J.add(v_by, 5.0), 7.0, 25.0, game.character_draw.f_shadeCol(v_sh, 1.14))
		J.setv(game.j_ctx, "globalAlpha", 0.2)
		game.f_fr(J.add(v_x, 3.0), J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 3.0), 27.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(((v_x - (float(v_bw) / float(2.0))) - 3.0), J.add(v_by, 8.0), 5.0, 22.0, game.character_draw.f_shadeCol(v_sh, 0.8))
		game.f_fr(((v_x - (float(v_bw) / float(2.0))) - 3.0), J.add(v_by, 8.0), 4.0, 21.0, game.character_draw.f_shadeCol(v_sh, 0.92))
		game.f_fr((J.add(v_x, (float(v_bw) / float(2.0))) - 2.0), J.add(v_by, 8.0), 5.0, 22.0, game.character_draw.f_shadeCol(v_sh, 0.66))
	if J.eq(J.getv(v_c, "state"), "wait"):
		# REMAKE kancasi
		if not game.f_hdMusteriEller(v_x, v_by, v_bw, J.getv(v_L, "skin")):
			v_hy2 = J.add(v_by, 27.0)
			game.f_ell(((v_x - (float(v_bw) / float(2.0))) - 1.0), J.add(v_hy2, 1.0), 3.0, 3.0, J.getv(v_s, 2.0))
			game.f_ell(((v_x - (float(v_bw) / float(2.0))) - 1.0), v_hy2, 3.0, 3.0, J.getv(v_s, 1.0))
			game.f_px(((v_x - (float(v_bw) / float(2.0))) - 2.0), (v_hy2 - 1.0), J.getv(v_s, 0.0))
			game.f_ell(J.add(v_x, (float(v_bw) / float(2.0))), J.add(v_hy2, 1.0), 3.0, 3.0, J.getv(v_s, 2.0))
			game.f_ell(J.add(v_x, (float(v_bw) / float(2.0))), v_hy2, 3.0, 3.0, J.getv(v_s, 1.0))
			game.f_px(J.add(J.add(v_x, (float(v_bw) / float(2.0))), 1.0), (v_hy2 - 1.0), J.getv(v_s, 0.0))
	# REMAKE kancasi
	if not game.f_hdMusteriBoyunAlt(v_x, v_by, J.getv(v_L, "skin")):
		game.f_fr((v_x - 6.0), J.add(v_by, 2.0), 12.0, 4.0, game.character_draw.f_shadeCol(v_sh, 0.62))
		game.f_fr((v_x - 3.0), J.add(v_by, 1.0), 6.0, 5.0, J.getv(v_s, 1.0))
		game.f_ln((v_x - 5.0), J.add(v_by, 3.0), v_x, J.add(v_by, 7.0), game.character_draw.f_shadeCol(v_sh, 0.55))
		game.f_ln(J.add(v_x, 5.0), J.add(v_by, 3.0), v_x, J.add(v_by, 7.0), game.character_draw.f_shadeCol(v_sh, 0.55))
	if J.eq(fmod(J.n(J.getv(v_L, "seed")), J.n(3.0)), 0.0):
		v_i = 0.0
		while J.lt(v_i, 8.0):
			game.f_px(J.add((v_x - 9.0), fmod(J.n((v_i * 5.0)), J.n(19.0))), J.add(J.add(v_by, 10.0), fmod(J.n((v_i * 7.0)), J.n(18.0))), game.character_draw.f_shadeCol(v_sh, 1.35))
			v_i = J.add(v_i, 1.0)
	else:
		if J.eq(fmod(J.n(J.getv(v_L, "seed")), J.n(5.0)), 0.0):
			v_j = 0.0
			while J.lt(v_j, 3.0):
				game.f_hl(J.add((v_x - (float(v_bw) / float(2.0))), 1.0), J.add(J.add(v_by, 10.0), (v_j * 7.0)), (v_bw - 2.0), game.character_draw.f_shadeCol(v_sh, 0.84))
				v_j = J.add(v_j, 1.0)
	v_KLP = game.appearance_system.f_kalipKimlik(v_L)
	game.costume_draw.f_drawKalipGovde(v_KLP, v_x, v_by, v_bw, v_sh, v_s, v_L)
	# REMAKE kancasi
	if not game.f_hdMusteriBoyunUst(v_hx, v_hy, J.getv(v_L, "skin")):
		game.f_fr((v_hx - 4.0), J.add(v_hy, 10.0), 8.0, 6.0, J.getv(v_s, 2.0))
		game.f_fr((v_hx - 3.0), J.add(v_hy, 10.0), 6.0, 5.0, J.getv(v_s, 1.0))
	v_F = game.appearance_system.f_yuzKimlik(v_L)
	v_hw = (9.0 if J.truth(v_cocuk) else (12.0 if J.truth(J.getv(v_L, "big")) else 11.0))
	_cells["hh"][0] = 11.0
	v_yzS = (3.0 if J.truth(v_cocuk) else J.getv(v_F, "sekil"))
	_cells["KON"][0] = game.character_draw.f_kafaKontur(v_yzS, v_hw, _cells["hh"][0])
	# BIRLESIK: mac cikisi musterisi takim atkisi takar (ekrandaki yazi yerine)
	if J.truth(J.getv(v_c, "mac")):
		game.f_hdAtki(v_x, v_by, v_bw, J.getv(v_L, "seed"))
	# REMAKE kancasi
	if not game.f_hdMusteriKafa(v_hx, v_hy, v_yzS, v_hw, J.getv(v_L, "skin")):
		v_kr = 0.0
		while J.lt(v_kr, J.getv(_cells["KON"][0], "length")):
			v_kw = J.getv(_cells["KON"][0], v_kr)
			if J.le(v_kw, 0.0):
				v_kr = J.add(v_kr, 1.0)
				continue
			v_ky = J.add((v_hy - _cells["hh"][0]), v_kr)
			game.f_fr((v_hx - v_kw), v_ky, J.add((v_kw * 2.0), 1.0), 1.0, J.getv(v_s, 2.0))
			if J.ge(v_kw, 2.0):
				game.f_fr(J.add((v_hx - v_kw), 1.0), v_ky, ((v_kw * 2.0) - 1.0), 1.0, J.getv(v_s, 0.0))
			v_kr = J.add(v_kr, 1.0)
		v_ycx = J.add(v_hx, floor((v_hw * 0.36) + 0.5))
		v_ycR = max(3.0, floor((v_hw * 0.58) + 0.5))
		v_kc = 0.0
		while J.lt(v_kc, J.getv(_cells["KON"][0], "length")):
			v_cw = J.getv(_cells["KON"][0], v_kc)
			if J.lt(v_cw, 2.0):
				v_kc = J.add(v_kc, 1.0)
				continue
			v_cy = J.add((v_hy - _cells["hh"][0]), v_kc)
			v_dyc = (v_cy - J.add(v_hy, 1.0))
			if J.gt(abs(v_dyc), 8.0):
				v_kc = J.add(v_kc, 1.0)
				continue
			v_yar = floor(J.add((v_ycR * sqrt((1.0 - (float((v_dyc * v_dyc)) / float(64.0))))), 0.5))
			v_ca = max((v_ycx - v_yar), J.add((v_hx - v_cw), 1.0))
			v_cb = min(J.add(v_ycx, v_yar), (J.add(v_hx, v_cw) - 1.0))
			if J.ge(v_cb, v_ca):
				game.f_fr(v_ca, v_cy, J.add((v_cb - v_ca), 1.0), 1.0, J.getv(v_s, 1.0))
			v_kc = J.add(v_kc, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		v_kg = 4.0
		while J.lt(v_kg, (J.getv(_cells["KON"][0], "length") - 2.0)):
			if J.lt(J.getv(_cells["KON"][0], v_kg), 3.0):
				v_kg = J.add(v_kg, 1.0)
				continue
			game.f_fr((J.add(v_hx, J.getv(_cells["KON"][0], v_kg)) - 2.0), J.add((v_hy - _cells["hh"][0]), v_kg), 2.0, 1.0, J.getv(v_s, 2.0))
			v_kg = J.add(v_kg, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_kuG = J.invoke(v_konG, [2.0])
	# REMAKE kancasi
	if not game.f_hdMusteriKulak(v_hx, v_hy, J.getv(v_F, "kulak"), v_kuG, J.getv(v_L, "skin")):
		if J.eq(J.getv(v_F, "kulak"), 1.0):
			game.f_ell(((v_hx - v_kuG) - 1.0), J.add(v_hy, 2.0), 2.0, 4.0, J.getv(v_s, 1.0))
			game.f_ell(J.add(J.add(v_hx, v_kuG), 1.0), J.add(v_hy, 2.0), 2.0, 4.0, J.getv(v_s, 1.0))
			game.f_px(((v_hx - v_kuG) - 1.0), J.add(v_hy, 2.0), J.getv(v_s, 3.0))
			game.f_px(J.add(J.add(v_hx, v_kuG), 1.0), J.add(v_hy, 2.0), J.getv(v_s, 3.0))
			game.f_px(((v_hx - v_kuG) - 1.0), J.add(v_hy, 1.0), J.getv(v_s, 2.0))
			game.f_px(J.add(J.add(v_hx, v_kuG), 1.0), J.add(v_hy, 1.0), J.getv(v_s, 2.0))
		else:
			if J.eq(J.getv(v_F, "kulak"), 2.0):
				game.f_ell((v_hx - v_kuG), J.add(v_hy, 2.0), 1.0, 2.0, J.getv(v_s, 1.0))
				game.f_ell(J.add(v_hx, v_kuG), J.add(v_hy, 2.0), 1.0, 2.0, J.getv(v_s, 1.0))
				game.f_px((v_hx - v_kuG), J.add(v_hy, 2.0), J.getv(v_s, 2.0))
				game.f_px(J.add(v_hx, v_kuG), J.add(v_hy, 2.0), J.getv(v_s, 2.0))
			else:
				game.f_ell((v_hx - v_kuG), J.add(v_hy, 2.0), 2.0, 3.0, J.getv(v_s, 1.0))
				game.f_ell(J.add(v_hx, v_kuG), J.add(v_hy, 2.0), 2.0, 3.0, J.getv(v_s, 1.0))
				game.f_px((v_hx - v_kuG), J.add(v_hy, 2.0), J.getv(v_s, 2.0))
				game.f_px(J.add(v_hx, v_kuG), J.add(v_hy, 2.0), J.getv(v_s, 2.0))
	v_sacG = max(6.0, J.invoke(v_konG, [(-J.n(5.0))]))
	game.portrait_draw.f_drawHair(v_hx, v_hy, v_sacG, J.getv(v_L, "hair"), v_hc, v_s)
	game.portrait_draw.f_drawAcc(v_hx, v_hy, v_sacG, v_L, v_sh, v_hc)
	game.portrait_draw.f_drawKalipBas(v_KLP, v_hx, v_hy, v_sacG, v_s, v_L)
	v_mood = J.getv(v_c, "mood")
	v_ang = J.eq(v_mood, "angry")
	v_hap = (J.eq(v_mood, "happy") if J.eq(v_mood, "happy") else J.eq(v_mood, "served"))
	v_imp = ((not J.truth(v_hap)) if (not J.eq(J.getv(v_c, "patience"), null) and J.lt(J.getv(v_c, "patience"), 0.35)) else (J.lt(J.getv(v_c, "patience"), 0.35) if not J.eq(J.getv(v_c, "patience"), null) else not J.eq(J.getv(v_c, "patience"), null)))
	v_icE = max(0.0, min(2.0, floor(((11.0 - J.invoke(v_konG, [(-J.n(1.0))])) * 0.6) + 0.5)))
	v_fy = J.add(v_hy, ((1.0 if J.eq(J.getv(v_F, "oran"), null) else J.getv(v_F, "oran")) - 1.0))
	v_agzU = ((1.0 if J.eq(J.getv(v_F, "agizU"), null) else J.getv(v_F, "agizU")) - 1.0)
	v_browY = J.add((v_fy - 5.0), (2.0 if J.truth(v_ang) else 0.0))
	v_kaW = (4.0 if (J.eq(J.getv(v_F, "kas"), 2.0) or J.eq(J.getv(v_F, "kas"), 4.0)) else 5.0)
	v_kaH = (3.0 if J.eq(J.getv(v_F, "kas"), 1.0) else 2.0)
	v_kaD = (1.0 if J.eq(J.getv(v_F, "kas"), 1.0) else 0.0)
	v_kaC = (game.character_draw.f_shadeCol(v_hc, 1.5) if J.eq(J.getv(v_F, "yas"), 2.0) else v_hc)
	v_kSol = J.add((v_hx - 9.0), v_icE)
	v_kSag = (J.add(v_hx, 5.0) - v_icE)
	# REMAKE kancasi
	if not game.f_hdKaslar(v_kSol, v_kSag, v_browY, v_kaW, v_kaH, v_kaD, v_kaC, J.getv(v_F, "kas"), v_ang, v_hap):
		if J.truth(v_ang):
			game.f_fr(v_kSol, J.add(v_browY, v_kaD), v_kaW, v_kaH, v_kaC)
			game.f_px(J.add(v_kSol, v_kaW), J.add(v_browY, 2.0), v_kaC)
			game.f_px((v_kSol - 1.0), (v_browY - 1.0), v_kaC)
			game.f_fr(v_kSag, J.add(v_browY, v_kaD), v_kaW, v_kaH, v_kaC)
			game.f_px((v_kSag - 1.0), J.add(v_browY, 2.0), v_kaC)
			game.f_px(J.add(v_kSag, v_kaW), (v_browY - 1.0), v_kaC)
		else:
			if J.truth(v_hap):
				game.f_fr(v_kSol, (v_browY - 1.0), v_kaW, 1.0, v_kaC)
				game.f_px((v_kSol - 1.0), v_browY, v_kaC)
				game.f_fr(v_kSag, (v_browY - 1.0), v_kaW, 1.0, v_kaC)
				game.f_px(J.add(v_kSag, v_kaW), v_browY, v_kaC)
			else:
				if J.eq(J.getv(v_F, "kas"), 3.0):
					game.f_fr(v_kSol, v_browY, v_kaW, 2.0, v_kaC)
					game.f_px(J.add(v_kSol, v_kaW), J.add(v_browY, 1.0), v_kaC)
					game.f_px((v_kSol - 1.0), (v_browY - 1.0), v_kaC)
					game.f_fr(v_kSag, v_browY, v_kaW, 2.0, v_kaC)
					game.f_px((v_kSag - 1.0), J.add(v_browY, 1.0), v_kaC)
					game.f_px(J.add(v_kSag, v_kaW), (v_browY - 1.0), v_kaC)
				else:
					if J.eq(J.getv(v_F, "kas"), 4.0):
						game.f_fr(v_kSol, J.add(v_browY, 1.0), v_kaW, 1.0, v_kaC)
						game.f_hl(J.add(v_kSol, 1.0), v_browY, (v_kaW - 2.0), v_kaC)
						game.f_fr(v_kSag, J.add(v_browY, 1.0), v_kaW, 1.0, v_kaC)
						game.f_hl(J.add(v_kSag, 1.0), v_browY, (v_kaW - 2.0), v_kaC)
					else:
						game.f_fr(v_kSol, J.add(v_browY, v_kaD), v_kaW, v_kaH, v_kaC)
						game.f_fr(v_kSag, J.add(v_browY, v_kaD), v_kaW, v_kaH, v_kaC)
	v_blink = J.gt(game.f_hash1(J.add(floor((v_t * 1.6)), J.getv(v_L, "seed"))), 0.92)
	v_gzW = (6.0 if J.eq(J.getv(v_F, "goz"), 2.0) else 5.0)
	v_gzH = (3.0 if J.eq(J.getv(v_F, "goz"), 1.0) else (6.0 if J.eq(J.getv(v_F, "goz"), 2.0) else (4.0 if J.eq(J.getv(v_F, "goz"), 5.0) else 5.0)))
	v_gzA = J.add((1.0 if J.eq(J.getv(v_F, "goz"), 3.0) else ((-J.n(1.0)) if J.eq(J.getv(v_F, "goz"), 4.0) else 0.0)), ((1.0 if J.eq(J.getv(v_F, "aralik"), null) else J.getv(v_F, "aralik")) - 1.0))
	v_gzD = (1.0 if J.eq(J.getv(v_F, "goz"), 5.0) else 0.0)
	v_bbW = (3.0 if J.eq(J.getv(v_F, "goz"), 2.0) else 2.0)
	v_bbH = (2.0 if J.eq(J.getv(v_F, "goz"), 1.0) else (4.0 if J.eq(J.getv(v_F, "goz"), 2.0) else 3.0))
	v_gzC = (J.getv(game.j_GOZ_RENK, (J.getv(v_F, "gozR") if J.truth(J.getv(v_F, "gozR")) else 0.0)) if J.truth(J.getv(game.j_GOZ_RENK, (J.getv(v_F, "gozR") if J.truth(J.getv(v_F, "gozR")) else 0.0))) else "#2b2018")
	v_gSol = J.add(((v_hx - 9.0) - v_gzA), v_icE)
	v_gSag = (J.add(J.add(v_hx, 5.0), v_gzA) - v_icE)
	# REMAKE kancasi
	if not game.f_hdGozler(v_gSol, v_gSag, v_fy, v_gzW, v_gzH, v_gzD, v_bbW, v_bbH, v_gzC, v_hap, v_ang, v_imp, v_blink, v_kadin, v_F, v_L, v_s, v_t):
		if J.truth(v_hap):
			game.f_ln(v_gSol, J.add(J.add(v_fy, 1.0), v_gzD), J.add(v_gSol, 3.0), J.add((v_fy - 2.0), v_gzD), v_gzC)
			game.f_ln(J.add(v_gSol, 3.0), J.add((v_fy - 2.0), v_gzD), J.add(v_gSol, 6.0), J.add(J.add(v_fy, 1.0), v_gzD), v_gzC)
			game.f_ln((v_gSag - 2.0), J.add(J.add(v_fy, 1.0), v_gzD), J.add(v_gSag, 1.0), J.add((v_fy - 2.0), v_gzD), v_gzC)
			game.f_ln(J.add(v_gSag, 1.0), J.add((v_fy - 2.0), v_gzD), J.add(v_gSag, 4.0), J.add(J.add(v_fy, 1.0), v_gzD), v_gzC)
		else:
			if (J.truth(v_blink) and (not J.truth(v_ang))):
				game.f_fr(v_gSol, J.add(v_fy, v_gzD), v_gzW, 1.0, J.getv(v_s, 3.0))
				game.f_fr(v_gSag, J.add(v_fy, v_gzD), v_gzW, 1.0, J.getv(v_s, 3.0))
			else:
				v_gB = (J.getv(v_F, "gozB") if J.truth(J.getv(v_F, "gozB")) else 0.0)
				game.character_draw.f_gozAki(v_gSol, J.add((v_fy - 2.0), v_gzD), v_gzW, v_gzH, v_gB, (-J.n(1.0)), v_s)
				game.character_draw.f_gozAki(v_gSag, J.add((v_fy - 2.0), v_gzD), v_gzW, v_gzH, v_gB, 1.0, v_s)
				v_lx = (1.0 if J.truth(v_ang) else floor(sin(J.add((v_t * 0.8), J.getv(v_L, "seed"))) + 0.5))
				v_ly = (1.0 if J.truth(v_imp) else 0.0)
				v_pH = (2.0 if J.eq(v_gB, 4.0) else (min(v_bbH, (v_gzH - 2.0)) if J.eq(v_gB, 3.0) else v_bbH))
				v_akUst = (2.0 if J.eq(v_gB, 3.0) else (max(1.0, (int(J.n((v_gzH - 2.0))) >> int(J.n(1.0)))) if J.eq(v_gB, 4.0) else 0.0))
				v_akH = ((v_gzH - 2.0) if J.eq(v_gB, 3.0) else (2.0 if J.eq(v_gB, 4.0) else v_gzH))
				v_pY = J.add(J.add(J.add(J.add((v_fy - 2.0), v_gzD), v_akUst), floor((float((v_akH - v_pH)) / float(2.0)))), v_ly)
				game.f_fr(J.add(J.add(v_gSol, 1.0), v_lx), v_pY, v_bbW, max(1.0, v_pH), v_gzC)
				game.f_fr(J.add(J.add(v_gSag, 1.0), v_lx), v_pY, v_bbW, max(1.0, v_pH), v_gzC)
				game.f_px(J.add(J.add(v_gSol, 1.0), v_lx), v_pY, "#6a5a4a")
				game.f_px(J.add(J.add(v_gSag, 1.0), v_lx), v_pY, "#6a5a4a")
				if J.eq(J.getv(v_F, "goz"), 5.0):
					game.f_hl(v_gSol, (v_fy - 2.0), v_gzW, J.getv(v_s, 3.0))
					game.f_hl(v_gSag, (v_fy - 2.0), v_gzW, J.getv(v_s, 3.0))
				if J.truth(v_kadin):
					game.f_px((v_gSol - 1.0), J.add((v_fy - 3.0), v_gzD), "#2b2018")
					game.f_px((v_gSol - 2.0), J.add((v_fy - 2.0), v_gzD), "#2b2018")
					game.f_px(J.add(v_gSag, v_gzW), J.add((v_fy - 3.0), v_gzD), "#2b2018")
					game.f_px(J.add(J.add(v_gSag, v_gzW), 1.0), J.add((v_fy - 2.0), v_gzD), "#2b2018")
				if J.truth(v_ang):
					game.f_px(v_gSol, (v_fy - 3.0), "#e04a3a")
					game.f_px((J.add(v_gSag, v_gzW) - 1.0), (v_fy - 3.0), "#e04a3a")
	# REMAKE kancasi
	if not game.f_hdMusteriBurun(v_hx, v_fy, J.getv(v_F, "burun"), J.getv(v_L, "skin")):
		if J.eq(J.getv(v_F, "burun"), 1.0):
			game.f_ell(v_hx, J.add(v_fy, 4.0), 4.0, 3.0, J.getv(v_s, 2.0))
			game.f_ell((v_hx - 1.0), J.add(v_fy, 3.0), 4.0, 2.0, J.getv(v_s, 1.0))
			game.f_px((v_hx - 3.0), J.add(v_fy, 5.0), J.getv(v_s, 3.0))
			game.f_px(J.add(v_hx, 3.0), J.add(v_fy, 5.0), J.getv(v_s, 3.0))
		else:
			if J.eq(J.getv(v_F, "burun"), 2.0):
				game.f_fr((v_hx - 1.0), J.add(v_fy, 1.0), 2.0, 5.0, J.getv(v_s, 2.0))
				game.f_fr((v_hx - 1.0), J.add(v_fy, 1.0), 1.0, 4.0, J.getv(v_s, 1.0))
				game.f_ell(v_hx, J.add(v_fy, 5.0), 2.0, 2.0, J.getv(v_s, 2.0))
				game.f_px(J.add(v_hx, 1.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
			else:
				if J.eq(J.getv(v_F, "burun"), 3.0):
					game.f_fr((v_hx - 1.0), v_fy, 2.0, 6.0, J.getv(v_s, 2.0))
					game.f_fr((v_hx - 1.0), v_fy, 1.0, 5.0, J.getv(v_s, 1.0))
					game.f_px(J.add(v_hx, 1.0), J.add(v_fy, 1.0), J.getv(v_s, 1.0))
					game.f_px(J.add(v_hx, 2.0), J.add(v_fy, 3.0), J.getv(v_s, 2.0))
					game.f_ell(J.add(v_hx, 1.0), J.add(v_fy, 6.0), 3.0, 2.0, J.getv(v_s, 2.0))
					game.f_px(J.add(v_hx, 3.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
					game.f_px((v_hx - 2.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
				else:
					if J.eq(J.getv(v_F, "burun"), 4.0):
						game.f_ell(v_hx, J.add(v_fy, 5.0), 3.0, 2.0, J.getv(v_s, 2.0))
						game.f_ell((v_hx - 1.0), J.add(v_fy, 4.0), 2.0, 2.0, J.getv(v_s, 1.0))
						game.f_px((v_hx - 2.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
						game.f_px(J.add(v_hx, 2.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
						game.f_px(v_hx, J.add(v_fy, 3.0), J.getv(v_s, 1.0))
					else:
						game.f_ell(v_hx, J.add(v_fy, 4.0), 3.0, 3.0, J.getv(v_s, 2.0))
						game.f_ell((v_hx - 1.0), J.add(v_fy, 3.0), 3.0, 3.0, J.getv(v_s, 1.0))
						game.f_px((v_hx - 2.0), J.add(v_fy, 2.0), J.getv(v_s, 0.0))
						game.f_px(J.add(v_hx, 2.0), J.add(v_fy, 5.0), J.getv(v_s, 3.0))
	v_ynG = max(4.0, (J.invoke(v_konG, [4.0]) - 3.0))
	if J.truth(J.getv(v_F, "yanak")):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_ell((v_hx - v_ynG), J.add(v_fy, 4.0), 3.0, 2.0, "#e07a6a")
		game.f_ell(J.add(v_hx, v_ynG), J.add(v_fy, 4.0), 3.0, 2.0, "#e07a6a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if (J.ge(J.getv(v_F, "yas"), 1.0) and (not J.truth(v_cocuk))):
		J.setv(game.j_ctx, "globalAlpha", (0.55 if J.eq(J.getv(v_F, "yas"), 2.0) else 0.32))
		game.f_px(J.add((v_hx - v_ynG), 1.0), J.add(v_fy, 5.0), J.getv(v_s, 3.0))
		game.f_px(J.add((v_hx - v_ynG), 2.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
		game.f_px((J.add(v_hx, v_ynG) - 1.0), J.add(v_fy, 5.0), J.getv(v_s, 3.0))
		game.f_px((J.add(v_hx, v_ynG) - 2.0), J.add(v_fy, 6.0), J.getv(v_s, 3.0))
		if J.eq(J.getv(v_F, "yas"), 2.0):
			game.f_px(J.add((v_hx - v_ynG), 2.0), J.add(v_fy, 7.0), J.getv(v_s, 3.0))
			game.f_px((J.add(v_hx, v_ynG) - 2.0), J.add(v_fy, 7.0), J.getv(v_s, 3.0))
			game.f_hl(J.add(v_gSol, 1.0), J.add(J.add(v_fy, 3.0), v_gzD), (v_gzW - 1.0), J.getv(v_s, 3.0))
			game.f_hl(v_gSag, J.add(J.add(v_fy, 3.0), v_gzD), (v_gzW - 1.0), J.getv(v_s, 3.0))
			game.f_px((v_gSol - 2.0), (v_fy - 1.0), J.getv(v_s, 3.0))
			game.f_px((v_gSol - 3.0), v_fy, J.getv(v_s, 3.0))
			game.f_px(J.add(J.add(v_gSag, v_gzW), 1.0), (v_fy - 1.0), J.getv(v_s, 3.0))
			game.f_px(J.add(J.add(v_gSag, v_gzW), 2.0), v_fy, J.getv(v_s, 3.0))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(J.getv(v_F, "cil")):
		J.setv(game.j_ctx, "globalAlpha", 0.42)
		v_cl = 0.0
		while J.lt(v_cl, 9.0):
			v_ca = game.f_hash1(J.add(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 1.0) * 3.7), v_cl))
			v_cb = game.f_hash1(J.add(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 1.0) * 5.9), v_cl))
			v_cxx = J.add(v_hx, floor((((v_ca * 2.0) - 1.0) * J.add(v_ynG, 1.0)) + 0.5))
			v_cyy = J.add(J.add(v_fy, 2.0), floor((v_cb * 4.0) + 0.5))
			if J.le(abs((v_cxx - v_hx)), J.invoke(v_konG, [(v_cyy - v_fy)])):
				game.f_px(v_cxx, v_cyy, J.getv(v_s, 3.0))
			v_cl = J.add(v_cl, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.eq(J.getv(v_F, "ben"), 1.0):
		game.f_px(J.add((v_hx - v_ynG), 1.0), J.add(v_fy, 3.0), J.getv(v_s, 3.0))
	else:
		if J.eq(J.getv(v_F, "ben"), 2.0):
			game.f_px((J.add(v_hx, v_ynG) - 2.0), J.add(v_fy, 7.0), J.getv(v_s, 3.0))
		else:
			if J.eq(J.getv(v_F, "ben"), 3.0):
				game.f_px(J.add(v_hx, 3.0), (v_fy - 4.0), J.getv(v_s, 3.0))
	v_ceG = J.invoke(v_konG, [9.0])
	if ((J.eq(J.getv(v_F, "cene"), 1.0) and J.gt(v_ceG, 2.0)) and (not J.truth(v_cocuk))):
		game.f_px(v_hx, J.add(v_hy, 9.0), J.getv(v_s, 3.0))
		game.f_px(v_hx, J.add(v_hy, 10.0), J.getv(v_s, 3.0))
	else:
		if ((J.eq(J.getv(v_F, "cene"), 2.0) and J.gt(v_ceG, 2.0)) and (not J.truth(v_cocuk))):
			game.f_ell(v_hx, J.add(v_hy, 10.0), max(2.0, v_ceG), 2.0, J.getv(v_s, 2.0))
			J.setv(game.j_ctx, "globalAlpha", 0.4)
			game.f_hl(J.add((v_hx - v_ceG), 1.0), J.add(v_hy, 9.0), ((v_ceG * 2.0) - 1.0), J.getv(v_s, 3.0))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(J.getv(v_L, "mustache")):
		v_byG = max(4.0, min(7.0, (J.invoke(v_konG, [6.0]) - 1.0)))
		# REMAKE kancasi
		if not game.f_hdMusteriBiyik(v_hx, v_fy, v_agzU, v_byG, v_hc):
			game.f_fr((v_hx - v_byG), J.add(J.add(v_fy, 6.0), v_agzU), (v_byG * 2.0), 2.0, v_hc)
			game.f_px(((v_hx - v_byG) - 1.0), J.add(J.add(v_fy, 7.0), v_agzU), v_hc)
			game.f_px(J.add(v_hx, v_byG), J.add(J.add(v_fy, 7.0), v_agzU), v_hc)
	if J.eq(J.getv(v_L, "acc"), "beard"):
		v_skG = max(4.0, J.invoke(v_konG, [6.0]))
		# REMAKE kancasi
		if not game.f_hdMusteriSakal(v_hx, v_hy, v_skG, max(3.0, J.add(J.invoke(v_konG, [9.0]), 1.0)), v_hc):
			v_b = (-J.n(v_skG))
			while J.le(v_b, v_skG):
				v_bh = J.add(3.0, floor((sin((J.add(v_b, v_skG) * 0.7)) * 2.0) + 0.5))
				game.f_fr(J.add(v_hx, v_b), J.add(v_hy, 6.0), 1.0, J.add(v_bh, 3.0), v_hc)
				v_b = J.add(v_b, 1.0)
			v_skA = max(3.0, J.add(J.invoke(v_konG, [9.0]), 1.0))
			game.f_ell(v_hx, J.add(v_hy, 10.0), v_skA, 3.0, v_hc)
			game.f_ell(v_hx, J.add(v_hy, 11.0), max(2.0, (v_skA - 2.0)), 2.0, game.character_draw.f_shadeCol(v_hc, 1.2))
	v_my = J.add(J.add(v_fy, (9.0 if J.truth(J.getv(v_L, "mustache")) else 8.0)), v_agzU)
	v_agD = (1.0 if J.eq(J.getv(v_F, "agiz"), 1.0) else ((-J.n(1.0)) if J.eq(J.getv(v_F, "agiz"), 2.0) else 0.0))
	v_agD = min(v_agD, max((-J.n(1.0)), (J.invoke(v_konG, [8.0]) - 5.0)))
	# REMAKE kancasi
	if not game.f_hdAgiz(v_hx, v_my, v_agD, v_hap, v_ang, v_imp, v_kadin, J.getv(v_F, "agiz"), v_s):
		if J.truth(v_hap):
			game.f_fr(((v_hx - 4.0) - v_agD), v_my, J.add(9.0, (v_agD * 2.0)), 3.0, "#6d2f28")
			game.f_hl(((v_hx - 3.0) - v_agD), J.add(v_my, 3.0), J.add(7.0, (v_agD * 2.0)), "#c9584a")
			game.f_hl(((v_hx - 3.0) - v_agD), v_my, J.add(7.0, (v_agD * 2.0)), "#ffffff")
		else:
			if J.truth(v_ang):
				game.f_fr(((v_hx - 4.0) - v_agD), v_my, J.add(9.0, (v_agD * 2.0)), 3.0, "#6d2f28")
				game.f_hl(((v_hx - 4.0) - v_agD), v_my, J.add(9.0, (v_agD * 2.0)), "#ffffff")
				game.f_px(((v_hx - 5.0) - v_agD), (v_my - 1.0), J.getv(v_s, 2.0))
				game.f_px(J.add(J.add(v_hx, 5.0), v_agD), (v_my - 1.0), J.getv(v_s, 2.0))
			else:
				if J.truth(v_imp):
					game.f_hl(((v_hx - 4.0) - v_agD), J.add(v_my, 1.0), J.add(8.0, (v_agD * 2.0)), ("#c4405a" if J.truth(v_kadin) else "#8d3a30"))
					game.f_px(J.add(J.add(v_hx, 4.0), v_agD), v_my, ("#c4405a" if J.truth(v_kadin) else "#8d3a30"))
				else:
					if J.truth(v_kadin):
						game.f_fr(((v_hx - 3.0) - v_agD), v_my, J.add(7.0, (v_agD * 2.0)), 2.0, "#c4405a")
						game.f_hl(((v_hx - 3.0) - v_agD), v_my, J.add(7.0, (v_agD * 2.0)), "#e2607a")
					else:
						if J.eq(J.getv(v_F, "agiz"), 3.0):
							game.f_fr(((v_hx - 3.0) - v_agD), v_my, J.add(7.0, (v_agD * 2.0)), 2.0, "#8d3a30")
							game.f_hl(((v_hx - 2.0) - v_agD), v_my, J.add(5.0, (v_agD * 2.0)), "#a8544a")
						else:
							if J.eq(J.getv(v_F, "agiz"), 4.0):
								game.f_hl(((v_hx - 2.0) - v_agD), v_my, J.add(5.0, (v_agD * 2.0)), "#7d352c")
							else:
								game.f_hl(((v_hx - 3.0) - v_agD), v_my, J.add(7.0, (v_agD * 2.0)), "#8d3a30")
	if J.eq(J.getv(v_L, "acc"), "glasses"):
		v_glT = (J.getv(v_L, "glTip") if not J.eq(J.getv(v_L, "glTip"), null) else floor((game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 0.0) * 31.7)) * 4.0)))
		v_glS = J.add((v_hx - 10.0), v_icE)
		v_glG = (J.add(v_hx, 4.0) - v_icE)
		v_glC = ("#5a4a3a" if J.eq(v_glT, 2.0) else "#2b2018")
		# REMAKE kancasi
		if not game.f_hdMusteriGozluk(v_hx, v_fy, v_glT, v_icE):
			if J.eq(v_glT, 1.0):
				game.f_ring(J.add(v_glS, 3.0), v_fy, 3.0, v_glC)
				game.f_ring(J.add(v_glG, 3.0), v_fy, 3.0, v_glC)
				game.f_hl(J.add(v_glS, 7.0), v_fy, ((v_glG - v_glS) - 6.0), v_glC)
				J.setv(game.j_ctx, "globalAlpha", 0.2)
				game.f_disc(J.add(v_glS, 3.0), v_fy, 2.0, "#ffffff")
				game.f_disc(J.add(v_glG, 3.0), v_fy, 2.0, "#ffffff")
				J.setv(game.j_ctx, "globalAlpha", 1.0)
				game.f_px(J.add(v_glS, 2.0), (v_fy - 1.0), "rgba(255,255,255,.8)")
				game.f_px(J.add(v_glG, 2.0), (v_fy - 1.0), "rgba(255,255,255,.8)")
			else:
				if J.eq(v_glT, 2.0):
					game.f_rc(J.add(v_glS, 1.0), (v_fy - 2.0), 5.0, 5.0, v_glC)
					game.f_rc(J.add(v_glG, 1.0), (v_fy - 2.0), 5.0, 5.0, v_glC)
					game.f_hl(J.add(v_glS, 6.0), v_fy, ((v_glG - v_glS) - 5.0), v_glC)
					game.f_px(v_glS, (v_fy - 1.0), v_glC)
					game.f_px(J.add(v_glG, 6.0), (v_fy - 1.0), v_glC)
					J.setv(game.j_ctx, "globalAlpha", 0.16)
					game.f_fr(J.add(v_glS, 2.0), (v_fy - 1.0), 3.0, 3.0, "#ffffff")
					game.f_fr(J.add(v_glG, 2.0), (v_fy - 1.0), 3.0, 3.0, "#ffffff")
					J.setv(game.j_ctx, "globalAlpha", 1.0)
				else:
					if J.eq(v_glT, 3.0):
						game.f_fr(v_glS, (v_fy - 3.0), 7.0, 7.0, "#1c1610")
						game.f_fr(v_glG, (v_fy - 3.0), 7.0, 7.0, "#1c1610")
						game.f_fr(J.add(v_glS, 1.0), (v_fy - 2.0), 5.0, 5.0, "#33455e")
						game.f_fr(J.add(v_glG, 1.0), (v_fy - 2.0), 5.0, 5.0, "#33455e")
						game.f_hl(J.add(v_glS, 7.0), (v_fy - 1.0), ((v_glG - v_glS) - 6.0), "#1c1610")
						game.f_px(J.add(v_glS, 1.0), (v_fy - 2.0), "rgba(255,255,255,.55)")
						game.f_px(J.add(v_glG, 1.0), (v_fy - 2.0), "rgba(255,255,255,.55)")
					else:
						game.f_rc(v_glS, (v_fy - 3.0), 7.0, 7.0, v_glC)
						game.f_rc(v_glG, (v_fy - 3.0), 7.0, 7.0, v_glC)
						game.f_hl(J.add(v_glS, 7.0), v_fy, ((v_glG - v_glS) - 6.0), v_glC)
						J.setv(game.j_ctx, "globalAlpha", 0.22)
						game.f_fr(J.add(v_glS, 1.0), (v_fy - 2.0), 5.0, 5.0, "#ffffff")
						game.f_fr(J.add(v_glG, 1.0), (v_fy - 2.0), 5.0, 5.0, "#ffffff")
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						game.f_px(J.add(v_glS, 2.0), (v_fy - 2.0), "rgba(255,255,255,.8)")
						game.f_px(J.add(v_glG, 2.0), (v_fy - 2.0), "rgba(255,255,255,.8)")
	if (J.truth(v_ang) and J.truth(game.f_chance(0.05))):
		game.effects.f_smoke(J.add(v_hx, game.math_utils.f_rnd((-J.n(11.0)), 11.0)), (v_hy - 13.0), 1.0, "rgba(230,90,60,.55)")
	if J.truth(v_ang):
		v_vx2 = J.add(v_hx, 8.0)
		v_vy2 = (v_hy - 9.0)
		if J.gt(sin((v_t * 8.0)), 0.0):
			game.f_px(v_vx2, v_vy2, "#e04a3a")
			game.f_px(J.add(v_vx2, 1.0), (v_vy2 - 1.0), "#e04a3a")
			game.f_px(J.add(v_vx2, 2.0), v_vy2, "#e04a3a")
			game.f_px(J.add(v_vx2, 1.0), J.add(v_vy2, 1.0), "#e04a3a")
	if (J.eq(v_mood, "served") and J.truth(game.f_chance(0.06))):
		game.effects.f_part({"x": J.add(v_hx, game.math_utils.f_rnd((-J.n(9.0)), 9.0)), "y": (v_hy - 10.0), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(24.0)), (-J.n(12.0))), "life": 0.9, "col": "#e2483a", "g": (-J.n(8.0)), "sz": 2.0})
	return null

func _closure_84(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_ki: Variant = null
	var v_dy: Variant = null
	v_dy = J.arg(_args, 0)
	v_ki = J.add(v_dy, _captures["361:hh"][0])
	return (J.getv(_captures["361:KON"][0], v_ki) if (J.ge(v_ki, 0.0) and J.lt(v_ki, J.getv(_captures["361:KON"][0], "length"))) else 0.0)
	return null

