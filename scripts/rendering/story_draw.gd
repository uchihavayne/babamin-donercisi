# Story draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:1235
func f_proStart() -> Variant:
	J.setv(game.j_PRO, "epi", false)
	J.setv(game.j_PRO, "i", 0.0)
	J.setv(game.j_PRO, "t", 0.0)
	J.setv(game.j_PRO, "ch", 0.0)
	J.setv(game.j_G, "scene", "prologue")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

# prologue.js:1236
func f_proFinish() -> Variant:
	if J.truth(J.getv(game.j_PRO, "epi")):
		f_epiFinish()
		return null
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
	var liste: Variant = game.j_EPI_SCENES if J.truth(J.getv(game.j_PRO, "epi")) else game.j_PRO_SCENES
	v_S = J.getv(liste, J.getv(game.j_PRO, "i"))
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
	while J.lt(v_d, J.getv(liste, "length")):
		game.f_disc(J.add(((float(game.j_W) / float(2.0)) - ((J.getv(liste, "length") - 1.0) * 6.0)), (v_d * 12.0)), J.add(v_barY, 11.0), 2.0, (J.getv(game.j_P, "au0") if J.eq(v_d, J.getv(game.j_PRO, "i")) else "#4a3f34"))
		v_d = J.add(v_d, 1.0)
	if J.truth(game.f_button(6.0, J.add(v_barY, 4.0), 88.0, 14.0, "ATLA", "#5a4a3a")):
		J.method(game.j_SFX, "uiBack", [])
		game.story_draw.f_proFinish()
		return null
	v_last = J.eq(J.getv(game.j_PRO, "i"), (J.getv(liste, "length") - 1.0))
	if J.ge(J.getv(game.j_PRO, "ch"), v_total):
		if J.truth(game.f_button((game.j_W - 84.0), J.add(v_barY, 4.0), 78.0, 14.0, (("SERBEST OYUN" if J.truth(J.getv(game.j_PRO, "epi")) else "DÜKKÂNI AÇ") if J.truth(v_last) else "DEVAM"), ("#3f8a4a" if J.truth(v_last) else "#7a5a3a"), v_last)):
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

# BIRLESIK (6. tur): kapanis hikayesi (borc bitince, kutlamadan sonra).
func f_epiStart() -> Variant:
	# 12. tur: Demirkent'e gidilmisse, oradaki seceneklere gore bir sahne eklenir (hikaye_system.f_epiDemirkent); yoksa 5 temel sahne
	var v_liste: Array = game.j_EPI_TEMEL.duplicate()
	var v_dk: Array = game.hikaye_system.f_epiDemirkent()
	if not v_dk.is_empty():
		v_liste.insert(3, {"dur": 13.0, "lines": v_dk, "draw": _epi_demirkent.bind({})})
	game.j_EPI_SCENES = v_liste
	J.setv(game.j_PRO, "epi", true)
	J.setv(game.j_PRO, "i", 0.0)
	J.setv(game.j_PRO, "t", 0.0)
	J.setv(game.j_PRO, "ch", 0.0)
	J.setv(game.j_G, "scene", "prologue")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

# bitis: gun sonu ekranina (dukkana git) doner; oyun serbest surer (borc 0,
# kesinti yok).
func f_epiFinish() -> Variant:
	game.j_EPI_SCENES = game.j_EPI_TEMEL.duplicate()   # Demirkent sahnesi yalniz bu gosterim icindi
	J.setv(game.j_PRO, "epi", false)
	J.setv(game.j_G, "scene", "dayend")
	J.setv(game.j_G, "sceneT", 9.0)
	game.save_system.f_saveAll()
	return null

func _epi_borc(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.story_debt.f_proDebt(J.arg(_args, 0), J.arg(_args, 1))
	return null

# SON karti: panelin icinde koyu zemin, altin cerceve, oyunun ozeti.
func _epi_son(_args: Array, _captures: Dictionary = {}) -> Variant:
	var t: float = J.n(J.arg(_args, 0))
	var S: Dictionary = game.j_G.stats
	game.f_fr(40.0, 44.0, 400.0, 150.0, "#1a100a")
	# yumusak sicak isik: ic ice seyrek elipsler (tek elips duz bir disk gibi duruyordu)
	for r in 8:
		J.setv(game.j_ctx, "globalAlpha", (0.035 + 0.01 * sin(t * 1.3)))
		game.f_ell(240.0, 116.0, 60.0 + r * 14.0, 22.0 + r * 5.0, "#ffb04a")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rc(52.0, 54.0, 376.0, 130.0, "#8a6a2a")
	game.f_rc(55.0, 57.0, 370.0, 124.0, "#4a3418")
	game.text_draw.f_txt("SON", 240.0, 64.0, J.getv(game.j_P, "au0"), {"align": "c", "sc": 2.0, "shadow": 1.0})
	game.text_draw.f_txt("BABAMIN DÖNERCİSİ", 240.0, 88.0, "#e8c070", {"align": "c"})
	var satir := [["GÜN", str(int(J.n(game.j_G.day)))],
		["SATILAN DÜRÜM", str(int(J.n(S.get("wraps", 0))))],
		["SATILAN İSKENDER", str(int(J.n(S.get("isk", 0))))],
		["TOPLAM KAZANÇ", "$" + str(game.math_utils.f_fmtMoney(J.n(S.get("earned", 0))))],
		["ÖDENEN BORÇ", "$" + str(game.math_utils.f_fmtMoney(game.j_DEBT_START))]]
	for i in satir.size():
		var y := 106.0 + i * 13.0
		var k := clampf((J.n(game.j_PRO.t) - 0.4 - i * 0.35) * 3.0, 0.0, 1.0)
		if k <= 0.0: continue
		J.setv(game.j_ctx, "globalAlpha", k)
		game.text_draw.f_txt(satir[i][0], 228.0, y, J.getv(game.j_P, "ui3"), {"align": "r"})
		game.text_draw.f_txt(satir[i][1], 252.0, y, J.getv(game.j_P, "ok") if i >= 3 else J.getv(game.j_P, "ui0"), {"align": "l"})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(game.f_chance(0.2)):
		game.effects.f_part({"x": game.math_utils.f_rnd(60.0, 420.0), "y": 190.0, "vx": game.math_utils.f_rnd(-6.0, 6.0), "vy": game.math_utils.f_rnd(-22.0, -10.0), "life": 2.2, "col": J.getv(game.j_P, "au0"), "g": -2.0, "sz": 1.0, "type": "star"})
	return null

# Demirkent sahnesi: tek tip gri gokdelenler, birkac isikli pencere, onde kirmizi ferman bayragi; tavra gore ek ayrinti
# (muhur yedi: kepenge sari-siyah serit; aclari doyurdu: isikli pencerede buharli kase)
func _epi_demirkent(_args: Array, _captures: Dictionary = {}) -> Variant:
	var t: float = J.n(J.arg(_args, 0))
	var S: Variant = J.getv(game.j_G, "stats")
	var direnis: bool = S is Dictionary and J.n(S.get("muhur", 0.0)) >= 1.0
	var sifa: bool = S is Dictionary and J.n(S.get("fed", 0.0)) >= 5.0 and not direnis
	var bantlar := ["#1c1e26", "#262a34", "#323744", "#444a58", "#5a606e"]
	for i in bantlar.size():
		game.f_fr(40.0, 44.0 + float(i) * 24.0, 400.0, 25.0, bantlar[i])
	game.f_disc(372.0, 72.0, 13.0, "#8a8f9c")
	game.f_disc(368.0, 69.0, 13.0, "#444a58")
	for i in 13:
		var bx: float = 40.0 + float(i) * 31.0
		var bh: float = 74.0 + float((i * 7) % 3) * 7.0
		game.f_fr(bx, 194.0 - bh, 29.0, bh, "#2a2d36")
		game.f_fr(bx, 194.0 - bh, 29.0, 2.0, "#3a3e4a")
		for wy in range(0, int(bh) - 10, 11):
			for wx in range(4, 26, 8):
				var yak: bool = ((i * 5 + wy + wx * 3) % 19) == 0
				game.f_fr(bx + float(wx), 194.0 - bh + 7.0 + float(wy), 4.0, 5.0, "#e8b45a" if yak else "#1a1c24")
	# onde: ferman bayragi
	game.f_fr(98.0, 118.0, 2.0, 76.0, "#6a6458")
	var dalga: float = sin(t * 2.4) * 1.5
	game.f_fr(100.0, 120.0, 26.0 + dalga, 14.0, "#8e1c14")
	game.f_fr(100.0, 120.0, 26.0 + dalga, 2.0, "#b83228")
	# dukkan: isikli pencere + kepenk
	game.f_fr(186.0, 150.0, 60.0, 44.0, "#3a3e4a")
	game.f_fr(190.0, 156.0, 52.0, 38.0, "#e8b45a" if not direnis else "#4a4e5a")
	if direnis:
		for k in 6: game.f_fr(190.0, 156.0 + float(k) * 6.0, 52.0, 1.0, "#2a2d36")
		for k in 7:
			if k % 2 == 0: game.f_fr(190.0 + float(k) * 8.0, 168.0, 8.0, 6.0, "#e8b420")
			else: game.f_fr(190.0 + float(k) * 8.0, 168.0, 8.0, 6.0, "#2a2418")
	elif sifa:
		game.f_rc(206.0, 176.0, 20.0, 8.0, "#c9a06a")
		game.f_fr(208.0, 174.0, 16.0, 3.0, "#8a3a1e")
		for k in 3:
			var sy: float = 168.0 - float(k) * 6.0 - fmod(t * 8.0, 6.0)
			J.setv(game.j_ctx, "globalAlpha", 0.5)
			game.f_fr(212.0 + float(k) * 4.0 + sin(t * 3.0 + float(k)) * 1.5, sy, 2.0, 4.0, "#f2ead2")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

