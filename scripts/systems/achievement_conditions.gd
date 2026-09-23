# Achievement conditions. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func _closure_163(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	v_c = J.arg(_args, 0)
	return (J.eq(J.getv(J.getv(v_c, "look"), "acc"), "glasses") if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
	return null

func _closure_164(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	v_c = J.arg(_args, 0)
	return (J.eq(J.getv(J.getv(v_c, "look"), "acc"), "cap") if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
	return null

func _closure_165(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	v_c = J.arg(_args, 0)
	return ((J.eq(J.getv(J.getv(v_c, "look"), "acc"), "beard") if J.eq(J.getv(J.getv(v_c, "look"), "acc"), "beard") else J.getv(J.getv(v_c, "look"), "mustache")) if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
	return null

func _closure_166(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	v_c = J.arg(_args, 0)
	return (J.eq(J.getv(J.getv(v_c, "look"), "tip"), "cocuk") if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
	return null

func _closure_167(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_c: Variant = null
	v_c = J.arg(_args, 0)
	return (J.method(J.regex("^#c9|^#c0|^#e2[34]", ""), "test", [(J.getv(J.getv(v_c, "look"), "shirtCol") if J.truth(J.getv(J.getv(v_c, "look"), "shirtCol")) else "")]) if J.truth(J.getv(v_c, "look")) else J.getv(v_c, "look"))
	return null

func _closure_168(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "sauce"), "hot") if J.truth(v_it) else v_it)
	return null

func _closure_169(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "sauce"), "garlic") if J.truth(v_it) else v_it)
	return null

func _closure_170(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "kind"), "fbox") if J.truth(v_it) else v_it)
	return null

func _closure_171(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "kind"), "drink") if J.truth(v_it) else v_it)
	return null

func _closure_172(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "kind"), "sweet") if J.truth(v_it) else v_it)
	return null

func _closure_173(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_it: Variant = null
	v_it = J.arg(_args, 0)
	return (J.eq(J.getv(v_it, "kind"), "plate") if J.truth(v_it) else v_it)
	return null

func _closure_176(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "wraps") if J.truth(J.getv(v_S, "wraps")) else 0.0)
	return null

func _closure_177(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "wraps") if J.truth(J.getv(v_S, "wraps")) else 0.0)
	return null

func _closure_178(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "wraps") if J.truth(J.getv(v_S, "wraps")) else 0.0)
	return null

func _closure_179(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "wraps") if J.truth(J.getv(v_S, "wraps")) else 0.0)
	return null

func _closure_180(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "isk") if J.truth(J.getv(v_S, "isk")) else 0.0)
	return null

func _closure_181(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "isk") if J.truth(J.getv(v_S, "isk")) else 0.0)
	return null

func _closure_182(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "drinks") if J.truth(J.getv(v_S, "drinks")) else 0.0)
	return null

func _closure_183(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "boxes") if J.truth(J.getv(v_S, "boxes")) else 0.0)
	return null

func _closure_184(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "sweets") if J.truth(J.getv(v_S, "sweets")) else 0.0)
	return null

func _closure_185(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "gunEnCok") if J.truth(J.getv(v_S, "gunEnCok")) else 0.0)
	return null

func _closure_186(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "earned") if J.truth(J.getv(v_S, "earned")) else 0.0)
	return null

func _closure_187(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "earned") if J.truth(J.getv(v_S, "earned")) else 0.0)
	return null

func _closure_188(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "earned") if J.truth(J.getv(v_S, "earned")) else 0.0)
	return null

func _closure_189(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "earned") if J.truth(J.getv(v_S, "earned")) else 0.0)
	return null

func _closure_190(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "best") if J.truth(J.getv(v_S, "best")) else 0.0)
	return null

func _closure_191(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "best") if J.truth(J.getv(v_S, "best")) else 0.0)
	return null

func _closure_192(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "best") if J.truth(J.getv(v_S, "best")) else 0.0)
	return null

func _closure_193(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "bahsis") if J.truth(J.getv(v_S, "bahsis")) else 0.0)
	return null

func _closure_194(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "debtPaid") if J.truth(J.getv(v_S, "debtPaid")) else 0.0)
	return null

func _closure_195(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "debtPaid") if J.truth(J.getv(v_S, "debtPaid")) else 0.0)
	return null

func _closure_196(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (1.0 if J.le(J.getv(v_G, "debt"), (float(game.j_DEBT_START) / float(2.0))) else 0.0)
	return null

func _closure_197(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (1.0 if (J.le(J.getv(v_G, "debt"), 0.0) or J.truth(J.getv(v_G, "debtCleared"))) else 0.0)
	return null

func _closure_198(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (1.0 if ((J.le(J.getv(v_G, "debt"), 0.0) or J.truth(J.getv(v_G, "debtCleared"))) and J.le(J.getv(v_G, "day"), 120.0)) else 0.0)
	return null

func _closure_199(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return game.equipment_system.f_upgTotalLv(v_G)
	return null

func _closure_200(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return game.equipment_system.f_upgTotalLv(v_G)
	return null

func _closure_201(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (1.0 if J.ge(game.equipment_system.f_upgTotalLv(v_G), game.achievement_system.f_bsUpgTavan()) else 0.0)
	return null

func _closure_202(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (J.getv(v_G, "branch") if J.truth(J.getv(v_G, "branch")) else 0.0)
	return null

func _closure_203(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (J.getv(v_G, "branch") if J.truth(J.getv(v_G, "branch")) else 0.0)
	return null

func _closure_204(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	var v_G: Variant = null
	v_S = J.arg(_args, 0)
	v_G = J.arg(_args, 1)
	return (1.0 if J.ge((J.getv(v_G, "branch") if J.truth(J.getv(v_G, "branch")) else 0.0), J.getv(game.j_BRANCH, "length")) else 0.0)
	return null

func _closure_205(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "phone") if J.truth(J.getv(v_S, "phone")) else 0.0)
	return null

func _closure_206(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "phone") if J.truth(J.getv(v_S, "phone")) else 0.0)
	return null

func _closure_207(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "moto") if J.truth(J.getv(v_S, "moto")) else 0.0)
	return null

func _closure_208(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "dayi") if J.truth(J.getv(v_S, "dayi")) else 0.0)
	return null

func _closure_209(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return game.achievement_system.f_bsSehirSayisi(v_S)
	return null

func _closure_210(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return game.achievement_system.f_bsSehirSayisi(v_S)
	return null

func _closure_211(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return game.achievement_system.f_bsSehirSayisi(v_S)
	return null

func _closure_212(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "days") if J.truth(J.getv(v_S, "days")) else 0.0)
	return null

func _closure_213(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "days") if J.truth(J.getv(v_S, "days")) else 0.0)
	return null

func _closure_214(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "days") if J.truth(J.getv(v_S, "days")) else 0.0)
	return null

func _closure_215(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "mukemmel") if J.truth(J.getv(v_S, "mukemmel")) else 0.0)
	return null

func _closure_216(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "mukemmel") if J.truth(J.getv(v_S, "mukemmel")) else 0.0)
	return null

func _closure_217(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "enSeri") if J.truth(J.getv(v_S, "enSeri")) else 0.0)
	return null

func _closure_218(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "enSeri") if J.truth(J.getv(v_S, "enSeri")) else 0.0)
	return null

func _closure_219(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "enSeri") if J.truth(J.getv(v_S, "enSeri")) else 0.0)
	return null

func _closure_220(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "temizSeri") if J.truth(J.getv(v_S, "temizSeri")) else 0.0)
	return null

func _closure_221(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "depoTam") if J.truth(J.getv(v_S, "depoTam")) else 0.0)
	return null

func _closure_222(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "buyukSiparis") if J.truth(J.getv(v_S, "buyukSiparis")) else 0.0)
	return null

func _closure_223(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "fgunEn") if J.truth(J.getv(v_S, "fgunEn")) else 0.0)
	return null

func _closure_224(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "fgunEn") if J.truth(J.getv(v_S, "fgunEn")) else 0.0)
	return null

func _closure_225(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "fgunEn") if J.truth(J.getv(v_S, "fgunEn")) else 0.0)
	return null

func _closure_226(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "evEn") if J.truth(J.getv(v_S, "evEn")) else 0.0)
	return null

func _closure_227(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "evEn") if J.truth(J.getv(v_S, "evEn")) else 0.0)
	return null

func _closure_228(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "evEn") if J.truth(J.getv(v_S, "evEn")) else 0.0)
	return null

func _closure_229(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "lider") if J.truth(J.getv(v_S, "lider")) else 0.0)
	return null

func _closure_230(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "lider") if J.truth(J.getv(v_S, "lider")) else 0.0)
	return null

func _closure_231(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "temizGun") if J.truth(J.getv(v_S, "temizGun")) else 0.0)
	return null

func _closure_232(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "kacak") if J.truth(J.getv(v_S, "kacak")) else 0.0)
	return null

func _closure_233(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "muhur") if J.truth(J.getv(v_S, "muhur")) else 0.0)
	return null

func _closure_234(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "yanik") if J.truth(J.getv(v_S, "yanik")) else 0.0)
	return null

func _closure_235(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (1.0 if J.gt((J.getv(v_S, "stolen") if J.truth(J.getv(v_S, "stolen")) else 0.0), 0.0) else 0.0)
	return null

func _closure_236(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "sifirGun") if J.truth(J.getv(v_S, "sifirGun")) else 0.0)
	return null

func _closure_237(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "lost") if J.truth(J.getv(v_S, "lost")) else 0.0)
	return null

func _closure_238(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "enBahsis") if J.truth(J.getv(v_S, "enBahsis")) else 0.0)
	return null

func _closure_239(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_S: Variant = null
	v_S = J.arg(_args, 0)
	return (J.getv(v_S, "fed") if J.truth(J.getv(v_S, "fed")) else 0.0)
	return null
