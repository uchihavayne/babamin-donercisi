# Rival building. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:5123
func f_rakipZemin(p_bx: Variant = null, p_by: Variant = null, p_bw: Variant = null, p_gyy: Variant = null, p_B: Variant = null, p_durum: Variant = null) -> Variant:
	var v_t: Variant = null
	var v_kk: Variant = null
	var v_ix: Variant = null
	var v_iw: Variant = null
	var v_ub: Variant = null
	var v_k2: Variant = null
	var v_sg: Variant = null
	var v_ay: Variant = null
	var v_sx: Variant = null
	var v_band: Variant = null
	var v_col: Variant = null
	var v_vy: Variant = null
	var v_vh: Variant = null
	var v_sx2: Variant = null
	var v_kx: Variant = null
	var v_q: Variant = null
	var v_dx0: Variant = null
	var v_bx: Variant = p_bx
	var v_by: Variant = p_by
	var v_bw: Variant = p_bw
	var v_gyy: Variant = p_gyy
	var v_B: Variant = p_B
	var v_durum: Variant = p_durum
	v_t = ((J.getv(game.j_G, "t") if J.truth(J.getv(game.j_G, "t")) else 0.0) if (not J.eq(J.kind(game.j_G), "undefined") and J.truth(game.j_G)) else 0.0)
	if J.eq(v_durum, "insaat"):
		game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 5.0), 21.0, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.7))
		game.f_fr(J.add(v_bx, 4.0), v_gyy, (v_bw - 9.0), 15.0, "#5a5e64")
		v_kk = J.add(v_gyy, 1.0)
		while J.lt(v_kk, J.add(v_gyy, 15.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.34)
			game.f_hl(J.add(v_bx, 4.0), v_kk, (v_bw - 10.0), "#33373d")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_kk = J.add(v_kk, 2.0)
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 7.0), 5.0, "#6b6f75")
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 8.0), 4.0, "#8a8f96")
		J.setv(game.j_ctx, "globalAlpha", 0.8)
		game.f_ln(J.add(v_bx, 5.0), (v_gyy - 5.0), (J.add(v_bx, v_bw) - 9.0), (v_gyy - 2.0), "#d8c04a")
		game.f_ln(J.add(v_bx, 5.0), (v_gyy - 2.0), (J.add(v_bx, v_bw) - 9.0), (v_gyy - 5.0), "#d8c04a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_ix = J.add(v_bx, 3.0)
		v_iw = (v_bw - 7.0)
		game.f_fr(v_ix, (v_gyy - 8.0), 2.0, 23.0, "#8a6a3a")
		game.f_fr((J.add(v_ix, v_iw) - 2.0), (v_gyy - 8.0), 2.0, 23.0, "#8a6a3a")
		game.f_fr(v_ix, (v_gyy - 3.0), v_iw, 2.0, "#a8834a")
		game.f_fr(v_ix, J.add(v_gyy, 7.0), v_iw, 2.0, "#a8834a")
		game.f_hl(v_ix, (v_gyy - 3.0), v_iw, "#c39a58")
		game.f_hl(v_ix, J.add(v_gyy, 7.0), v_iw, "#c39a58")
		v_ub = 0.0
		while J.lt(v_ub, (v_iw - 2.0)):
			game.f_fr(J.add(J.add(v_ix, 1.0), v_ub), J.add(v_gyy, 13.0), 2.0, 2.0, "#e8c23a")
			game.f_fr(J.add(J.add(v_ix, 3.0), v_ub), J.add(v_gyy, 13.0), 2.0, 2.0, "#2a2620")
			v_ub = J.add(v_ub, 4.0)
		game.f_fr(J.add(v_bx, 2.0), v_by, (v_bw - 4.0), 1.0, "#cdd4da")
		return null
	if J.eq(v_durum, "kapali"):
		game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 5.0), 21.0, game.character_draw.f_shadeCol(J.getv(v_B, "wall"), 0.62))
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 7.0), 5.0, "#3a3a40")
		game.f_fr(J.add(v_bx, 3.0), (v_gyy - 6.0), (v_bw - 8.0), 4.0, "#4a4a52")
		game.f_fr(J.add(v_bx, 4.0), v_gyy, (v_bw - 9.0), 15.0, "#4e5258")
		v_k2 = J.add(v_gyy, 1.0)
		while J.lt(v_k2, J.add(v_gyy, 15.0)):
			J.setv(game.j_ctx, "globalAlpha", 0.38)
			game.f_hl(J.add(v_bx, 4.0), v_k2, (v_bw - 10.0), "#2e3238")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_k2 = J.add(v_k2, 2.0)
		game.f_fr((J.add(v_bx, (int(J.n(v_bw)) >> int(J.n(1.0)))) - 1.0), J.add(v_gyy, 13.0), 3.0, 3.0, "#7a7e84")
		J.setv(game.j_ctx, "globalAlpha", 0.85)
		game.f_ln(J.add(v_bx, 5.0), J.add(v_gyy, 1.0), (J.add(v_bx, v_bw) - 9.0), J.add(v_gyy, 13.0), "#a83a2a")
		game.f_ln(J.add(v_bx, 5.0), J.add(v_gyy, 13.0), (J.add(v_bx, v_bw) - 9.0), J.add(v_gyy, 1.0), "#a83a2a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(J.add(v_bx, 2.0), v_by, (v_bw - 4.0), 1.0, "#cdd4da")
		return null
	game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 5.0), 6.0, "#1c4256")
	game.f_fr(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 6.0), 5.0, "#2f6a8a")
	game.f_hl(J.add(v_bx, 2.0), (v_gyy - 6.0), (v_bw - 6.0), "#4a8fb4")
	v_sg = J.add(v_bx, 5.0)
	while J.lt(v_sg, (J.add(v_bx, v_bw) - 6.0)):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.7, (sin(J.add((v_t * 3.1), v_sg)) * 0.22)))
		game.f_fr(v_sg, (v_gyy - 4.0), 4.0, 2.0, "#ffd77a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_sg = J.add(v_sg, 6.0)
	v_ay = v_gyy
	v_sx = 0.0
	while J.lt(v_sx, (v_bw - 4.0)):
		v_band = (int(J.n((int(J.n((float(v_sx) / float(6.0)))) | int(J.n(0.0))))) & int(J.n(1.0)))
		v_col = ("#2f6a8a" if J.truth(v_band) else "#f2ece0")
		game.f_fr(J.add(J.add(v_bx, 2.0), v_sx), v_ay, 1.0, 5.0, v_col)
		if J.lt(fmod(J.n(v_sx), J.n(6.0)), 3.0):
			game.f_px(J.add(J.add(v_bx, 2.0), v_sx), J.add(v_ay, 5.0), v_col)
		v_sx = J.add(v_sx, 1.0)
	game.f_hl(J.add(v_bx, 2.0), v_ay, (v_bw - 4.0), "rgba(255,255,255,.4)")
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_fr(J.add(v_bx, 2.0), J.add(v_ay, 6.0), (v_bw - 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_vy = J.add(v_ay, 7.0)
	v_vh = ((v_by - v_vy) - 1.0)
	game.f_fr(J.add(v_bx, 3.0), v_vy, (v_bw - 7.0), v_vh, "#2f3d47")
	game.f_fr(J.add(v_bx, 4.0), J.add(v_vy, 1.0), (v_bw - 9.0), (v_vh - 2.0), "#3a2e26")
	J.setv(game.j_ctx, "globalAlpha", J.add(0.2, (sin((v_t * 1.9)) * 0.04)))
	game.f_fr(J.add(v_bx, 4.0), J.add(v_vy, 1.0), (v_bw - 9.0), (v_vh - 2.0), "#ffc46a")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_sx2 = J.add(v_bx, 7.0)
	game.f_fr(v_sx2, J.add(v_vy, 2.0), 4.0, (v_vh - 5.0), "#8a5f31")
	game.f_fr(v_sx2, J.add(v_vy, 2.0), 3.0, (v_vh - 5.0), "#c98436")
	game.f_fr((v_sx2 - 1.0), J.add(v_vy, 1.0), 6.0, 1.0, "#6b4a24")
	game.f_px(J.add(v_sx2, 1.0), (J.add(v_vy, v_vh) - 4.0), "#ffd257")
	game.f_fr(J.add(v_bx, 13.0), (v_by - 6.0), (v_bw - 20.0), 2.0, "#6b5a48")
	v_kx = J.add(J.add(v_bx, 18.0), floor((sin((v_t * 0.8)) * 2.0) + 0.5))
	if J.lt(J.add(v_kx, 4.0), (J.add(v_bx, v_bw) - 12.0)):
		game.f_fr(v_kx, (v_by - 12.0), 4.0, 7.0, "#2f4450")
		game.f_fr(J.add(v_kx, 1.0), (v_by - 15.0), 3.0, 3.0, "#b98b6a")
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	v_q = 0.0
	while J.lt(v_q, (v_vh - 2.0)):
		game.f_fr(J.add(J.add(v_bx, 6.0), v_q), J.add(J.add(v_vy, 1.0), v_q), 3.0, 1.0, "#ffffff")
		v_q = J.add(v_q, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_dx0 = (J.add(v_bx, v_bw) - 12.0)
	game.f_fr(v_dx0, v_vy, 9.0, J.add(v_vh, 1.0), "#1c4256")
	game.f_fr(J.add(v_dx0, 1.0), J.add(v_vy, 1.0), 7.0, v_vh, "#3f5f70")
	game.f_fr(J.add(v_dx0, 2.0), J.add(v_vy, 2.0), 5.0, 5.0, "#a8c6d4")
	game.f_px(J.add(v_dx0, 6.0), J.add(v_vy, floor((v_vh * 0.6) + 0.5)), "#f0d78a")
	game.f_fr(J.add(v_bx, 2.0), v_by, (v_bw - 4.0), 1.0, "#cdd4da")
	return null

# art.js:5234
func f_rakipCepheDurum() -> Variant:
	if (J.eq(J.kind(game.j_G), "undefined") or (not J.truth(game.j_G))):
		return "insaat"
	if J.truth(J.getv(game.j_G, "rakipKapandi")):
		return "kapali"
	return ("acik" if J.ge(J.getv(game.j_G, "day"), game.j_RAKIP_GUN) else "insaat")
	return null

