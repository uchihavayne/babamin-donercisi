# Story draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:1235
func f_proStart() -> Variant:
	J.setv(game.j_PRO, "i", 0.0)
	J.setv(game.j_PRO, "t", 0.0)
	J.setv(game.j_PRO, "ch", 0.0)
	J.setv(game.j_G, "scene", "prologue")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

# prologue.js:1236
func f_proFinish() -> Variant:
	J.setv(game.j_G, "prologueSeen", true)
	game.save_system.f_saveAll()
	J.setv(game.j_G, "scene", "intro")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

# prologue.js:1242
func f_drawPrologue(p_t: Variant = null) -> Variant:
	var v_S: Variant = null
	var v_k: Variant = null
	var v_satir: Variant = null
	var v_li: Variant = null
	var v_full: Variant = null
	var v_total: Variant = null
	var v_shown: Variant = null
	var v_ty: Variant = null
	var v_i: Variant = null
	var v_line: Variant = null
	var v_take: Variant = null
	var v_big: Variant = null
	var v_barY: Variant = null
	var v_d: Variant = null
	var v_last: Variant = null
	var v_t: Variant = p_t
	v_S = J.getv(game.j_PRO_SCENES, J.getv(game.j_PRO, "i"))
	if (not J.truth(v_S)):
		game.story_draw.f_proFinish()
		return null
	J.setv(game.j_PRO, "t", J.add(J.getv(game.j_PRO, "t"), (float(1.0) / float(60.0))))
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0b0806")
	v_k = game.math_utils.f_clamp((J.getv(game.j_PRO, "t") * 1.1), 0.0, 1.0)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [40.0, 44.0, 400.0, 150.0])
	J.method(game.j_ctx, "clip", [])
	J.method(v_S, "draw", [v_t, v_k])
	J.method(game.j_ctx, "restore", [])
	game.f_rc(39.0, 43.0, 402.0, 152.0, "#2b2018")
	game.f_rc(38.0, 42.0, 404.0, 154.0, "#5a4230")
	J.setv(game.j_ctx, "globalAlpha", 0.5)
	game.f_rc(37.0, 41.0, 406.0, 156.0, "#2b2018")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.lt(v_k, 1.0):
		J.setv(game.j_ctx, "globalAlpha", (1.0 - v_k))
		game.f_fr(40.0, 44.0, 400.0, 150.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_satir = []
	v_li = 0.0
	while J.lt(v_li, J.getv(J.getv(v_S, "lines"), "length")):
		J.method(v_satir, "push", [game.localization.f_T(J.getv(J.getv(v_S, "lines"), v_li))])
		v_li = J.add(v_li, 1.0)
	v_full = J.method(v_satir, "join", ["\n"])
	v_total = J.getv(J.method(v_full, "replace", [J.regex("\\n", "g"), ""]), "length")
	J.setv(game.j_PRO, "ch", min(v_total, floor((max(0.0, (J.getv(game.j_PRO, "t") - 0.8)) * 17.0))))
	v_shown = 0.0
	v_ty = 206.0
	v_i = 0.0
	while J.lt(v_i, J.getv(v_satir, "length")):
		v_line = J.getv(v_satir, v_i)
		v_take = game.math_utils.f_clamp((J.getv(game.j_PRO, "ch") - v_shown), 0.0, J.getv(v_line, "length"))
		v_shown = J.add(v_shown, J.getv(v_line, "length"))
		if J.le(v_take, 0.0):
			break
		v_big = J.method(J.regex("^\\$", ""), "test", [v_line])
		game.text_draw.f_txt(J.method(v_line, "slice", [0.0, v_take]), (float(game.j_W) / float(2.0)), v_ty, ("#e2483a" if J.truth(v_big) else J.getv(game.j_P, "ui0")), {"align": "c", "sc": (2.0 if J.truth(v_big) else 0.0)})
		v_ty = J.add(v_ty, (20.0 if J.truth(v_big) else 12.0))
		v_i = J.add(v_i, 1.0)
	if ((J.lt(J.getv(game.j_PRO, "ch"), v_total) and J.gt(J.getv(game.j_PRO, "ch"), 0.0)) and J.truth(game.f_chance(0.22))):
		J.method(game.j_SFX, "tick", [])
	v_barY = ((game.j_H - J.getv(game.j_VIEW, "bot")) - 22.0)
	J.setv(game.j_ctx, "globalAlpha", 0.8)
	game.f_fr(0.0, v_barY, game.j_W, 22.0, "#0b0806")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(0.0, v_barY, game.j_W, "#3a2a1e")
	v_d = 0.0
	while J.lt(v_d, J.getv(game.j_PRO_SCENES, "length")):
		game.f_disc(J.add(((float(game.j_W) / float(2.0)) - ((J.getv(game.j_PRO_SCENES, "length") - 1.0) * 6.0)), (v_d * 12.0)), J.add(v_barY, 11.0), 2.0, (J.getv(game.j_P, "au0") if J.eq(v_d, J.getv(game.j_PRO, "i")) else "#4a3f34"))
		v_d = J.add(v_d, 1.0)
	if J.truth(game.f_button(6.0, J.add(v_barY, 4.0), 88.0, 14.0, "ATLA", "#5a4a3a")):
		J.method(game.j_SFX, "uiBack", [])
		game.story_draw.f_proFinish()
		return null
	v_last = J.eq(J.getv(game.j_PRO, "i"), (J.getv(game.j_PRO_SCENES, "length") - 1.0))
	if J.ge(J.getv(game.j_PRO, "ch"), v_total):
		if J.truth(game.f_button((game.j_W - 84.0), J.add(v_barY, 4.0), 78.0, 14.0, ("DÜKKÂNI AÇ" if J.truth(v_last) else "DEVAM"), ("#3f8a4a" if J.truth(v_last) else "#7a5a3a"), v_last)):
			J.method(game.j_SFX, "ui", [])
			if J.truth(v_last):
				game.story_draw.f_proFinish()
				return null
			J.setv(game.j_PRO, "i", J.add(J.getv(game.j_PRO, "i"), 1.0))
			J.setv(game.j_PRO, "t", 0.0)
			J.setv(game.j_PRO, "ch", 0.0)
			return null
	else:
		if (J.truth(J.getv(game.j_IN, "pressed")) and J.lt(J.getv(game.j_IN, "y"), (v_barY - 2.0))):
			J.setv(game.j_PRO, "t", J.add(J.add(0.8, (float(v_total) / float(17.0))), 0.01))
	if J.gt(J.getv(game.j_PRO, "t"), J.getv(v_S, "dur")):
		if J.truth(v_last):
			game.story_draw.f_proFinish()
			return null
		J.setv(game.j_PRO, "i", J.add(J.getv(game.j_PRO, "i"), 1.0))
		J.setv(game.j_PRO, "t", 0.0)
		J.setv(game.j_PRO, "ch", 0.0)
	game.effects.f_psDraw()
	game.effects.f_ftDraw()
	return null

func _closure_266(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_k: Variant = null
	v_t = J.arg(_args, 0)
	v_k = J.arg(_args, 1)
	game.story_shop.f_proShopDay(v_t, v_k)
	return null

func _closure_267(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_k: Variant = null
	v_t = J.arg(_args, 0)
	v_k = J.arg(_args, 1)
	game.story_father.f_proFather(v_t, v_k)
	return null

func _closure_268(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_k: Variant = null
	v_t = J.arg(_args, 0)
	v_k = J.arg(_args, 1)
	game.story_closed.f_proClosed(v_t, v_k)
	return null

func _closure_269(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_k: Variant = null
	v_t = J.arg(_args, 0)
	v_k = J.arg(_args, 1)
	game.story_debt.f_proDebt(v_t, v_k)
	return null

func _closure_270(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_k: Variant = null
	v_t = J.arg(_args, 0)
	v_k = J.arg(_args, 1)
	game.story_key.f_proKey(v_t, v_k)
	return null
