# Localization. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# i18n.js:4996
func f_dilVar(p_k: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_k: Variant = p_k
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_DILLER, "length")):
		if J.eq(J.getv(J.getv(game.j_DILLER, v_i), "kod"), v_k):
			return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# i18n.js:5001
func f_T(p_s: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_v: Variant = null
	var v_s: Variant = p_s
	if ((J.eq(game.j_LANG, "tr") or J.eq(v_s, null)) or J.eq(v_s, null)):
		return v_s
	v_d = J.getv(game.j_SOZLUK, game.j_LANG)
	if (not J.truth(v_d)):
		return v_s
	v_v = J.getv(v_d, v_s)
	return (v_s if J.eq(v_v, null) else v_v)
	return null

# i18n.js:5009
func f_loadLang() -> Variant:
	var v_v: Variant = null
	var v_e: Variant = null
	v_v = J.method(game.j_localStorage, "getItem", [game.j_LANGKEY])
	if (J.truth(v_v) and J.truth(game.localization.f_dilVar(v_v))):
		game.j_LANG = v_v
	return null

# i18n.js:5016
func f_setLang(p_l: Variant = null) -> Variant:
	var v_e: Variant = null
	var v_l: Variant = p_l
	if (not J.truth(game.localization.f_dilVar(v_l))):
		return null
	game.j_LANG = v_l
	J.method(game.j_localStorage, "setItem", [game.j_LANGKEY, v_l])
	if J.eq(J.kind(J.ref(game.game_loop.f_invalidateLayers, 0)), "function"):
		game.game_loop.f_invalidateLayers()
	if not J.eq(J.kind(game.j_SHOP), "undefined"):
		J.setv(game.j_SHOP, "bake", null)
	return null
