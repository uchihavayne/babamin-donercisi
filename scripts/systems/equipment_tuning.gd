# Equipment tuning. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# BIRLESIK (8. tur, oyuncu elestirisi: "ayni seye defalarca bastiriyorsun"):
# tek tik = tam porsiyon (cagiranlar ihtiyac ve stokla sinirlar). Masa artik
# ayni tikla 2-3 urune birden koyar; son seviyesi yan malzeme seti.
func meat_per_click(_args: Array, _captures: Dictionary = {}) -> Variant:
	return 99.0

func tongs_targets(_args: Array, _captures: Dictionary = {}) -> Variant:
	return game.equipment_system.f_LV([1.0, 2.0, 3.0, 3.0], game.equipment_system.f_UV(J.arg(_args, 0), "tongs"))

func tongs_set(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.n(game.equipment_system.f_UV(J.arg(_args, 0), "tongs")) >= 3.0

func shave_dist(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([155.0, 120.0, 88.0, 60.0, 42.0], game.equipment_system.f_UV(v_G, "knife"))
	return null

func shave_cd(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.5, 0.38, 0.3, 0.24, 0.18], game.equipment_system.f_UV(v_G, "knife"))
	return null

func auto_shave_cd(_args: Array, _captures: Dictionary = {}) -> Variant:
	return 0.16
	return null

func auto_shave(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "knife"), 4.0)
	return null

func meat_cap(_args: Array, _captures: Dictionary = {}) -> Variant:
	return 16.0
	return null

func cut_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([3.2, 2.3, 1.6, 1.0, 0.7], game.equipment_system.f_UV(v_G, "pknife"))
	return null

func cut_yield(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([26.0, 32.0, 40.0, 50.0, 62.0], game.equipment_system.f_UV(v_G, "pknife"))
	return null

func auto_cut(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "pknife"), 4.0)
	return null

func fry_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([8.5, 6.5, 4.8, 3.4, 2.4], game.equipment_system.f_UV(v_G, "fryer"))
	return null

func fry_cap(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([26.0, 32.0, 40.0, 50.0, 62.0], game.equipment_system.f_UV(v_G, "fryer"))
	return null

func auto_fry(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "fryer"), 4.0)
	return null

func fries_cap(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.add(J.method(game.j_TUN, "fryCap", [game.j_G]), 6.0)
	return null

func paper_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.85, 0.4, 0.2], game.equipment_system.f_UV(v_G, "paper"))
	return null

func auto_paper(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "paper"), 2.0)
	return null

func grill_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "grill"), 1.0)
	return null

func grill_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 3.4, 2.5, 1.8, 1.2], game.equipment_system.f_UV(v_G, "grill"))
	return null

func grill_cap(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 1.0, 2.0, 3.0, 4.0], game.equipment_system.f_UV(v_G, "grill"))
	return null

func grill_yanar(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_v: Variant = null
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	v_v = game.equipment_system.f_UV(v_G, "grill")
	return (J.le(v_v, 2.0) if J.ge(v_v, 1.0) else J.ge(v_v, 1.0))
	return null

func grill_yanma_sure(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	v_t = game.equipment_system.f_LV([0.0, 6.0, 8.0, 0.0, 0.0], game.equipment_system.f_UV(v_G, "grill"))
	return (floor((v_t * 0.7) + 0.5) if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "sicak")) else v_t)
	return null

func auto_grill(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "grill"), 4.0)
	return null

func drink_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "drink"), 1.0)
	return null

func pour_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 3.2, 2.2, 1.3, 0.6], game.equipment_system.f_UV(v_G, "drink"))
	return null

func auto_drink(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "drink"), 4.0)
	return null

func fbox_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "fbox"), 1.0)
	return null

func fbox_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 1.4, 0.5], game.equipment_system.f_UV(v_G, "fbox"))
	return null

func auto_box(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "fbox"), 2.0)
	return null

func garnish_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "garnish"), 1.0)
	return null

func garnish_max(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 14.0, 26.0], game.equipment_system.f_UV(v_G, "garnish"))
	return null

func sauce_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "sauce"), 1.0)
	return null

func sauce_late(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "sauce"), 2.0)
	return null

func isk_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "iskender"), 1.0)
	return null

func isk_meat(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([game.j_ISK_MEAT, game.j_ISK_MEAT, 4.0, 4.0], game.equipment_system.f_UV(v_G, "iskender"))
	return null

func auto_isk(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "iskender"), 3.0)
	return null

func ayran_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "ayran"), 1.0)
	return null

func sweet_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "sweet"), 1.0)
	return null

func ayran_max(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 14.0, 26.0], game.equipment_system.f_UV(v_G, "ayran"))
	return null

func sweet_max(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 10.0, 20.0], game.equipment_system.f_UV(v_G, "sweet"))
	return null

func boards(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([1.0, 2.0, 3.0], game.equipment_system.f_UV(v_G, "board"))
	return null

func auto_coin(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "helper"), 1.0)
	return null

func auto_stock(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "helper"), 2.0)
	return null

func auto_trash(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "helper"), 3.0)
	return null

func phone_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.ge(game.equipment_system.f_UV(v_G, "phone"), 1.0)
	return null

func phone_gap(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 42.0, 30.0, 22.0], game.equipment_system.f_UV(v_G, "phone"))
	return null

func courier_time(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t: Variant = null
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	v_t = game.equipment_system.f_LV([0.0, 13.0, 11.0, 7.0], game.equipment_system.f_UV(v_G, "phone"))
	return (floor((v_t * 1.55) + 0.5) if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "rain")) else v_t)
	return null

func courier_yavas(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (1.55 if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "rain")) else 1.0)
	return null

func hava_gelis(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	if (not J.truth(v_G)):
		return 1.0
	if J.eq(J.getv(v_G, "weather"), "kar"):
		return 1.4
	if J.eq(J.getv(v_G, "weather"), "sicak"):
		return 0.86
	return 1.0
	return null

func hava_sabir(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	if (not J.truth(v_G)):
		return 1.0
	if J.eq(J.getv(v_G, "weather"), "kar"):
		return 1.35
	if J.eq(J.getv(v_G, "weather"), "sicak"):
		return 0.8
	return 1.0
	return null

func hava_bahsis(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (1.45 if (J.truth(v_G) and J.eq(J.getv(v_G, "weather"), "kar")) else 1.0)
	return null

func secim_on(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.gt(game.equipment_system.f_UV(v_G, "secim"), 0.0)
	return null

func secim_en_cok(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 1.0, 2.0], game.equipment_system.f_UV(v_G, "secim"))
	return null

func secim_zam(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 4.0, 7.0], game.equipment_system.f_UV(v_G, "secim"))
	return null

func mac_sabir(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (0.72 if (J.truth(v_G) and J.truth(J.getv(v_G, "macDalga"))) else 1.0)
	return null

func mac_bahsis(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (1.55 if (J.truth(v_G) and J.truth(J.getv(v_G, "macDalga"))) else 1.0)
	return null

func kesinti_sure(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (game.equipment_system.f_LV([1.0, 0.62, 0.38, 0.0], game.equipment_system.f_UV(v_G, "jenerator")) * game.j_KESINTI_SURE)
	return null

func kesinti_var(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return J.lt(game.equipment_system.f_UV(v_G, "jenerator"), 3.0)
	return null

func uncle_uses(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.0, 1.0, 2.0, 4.0], game.equipment_system.f_UV(v_G, "uncle"))
	return null

func stock_max(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([24.0, 40.0, 64.0, 100.0], game.equipment_system.f_UV(v_G, "store"))
	return null

func refill_per(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([6.0, 9.0, 14.0, 22.0], game.equipment_system.f_UV(v_G, "store"))
	return null

func sec_level(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_UV(v_G, "security")
	return null

func thief_visit(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return (game.equipment_system.f_LV([1.0, 0.72, 0.5, 0.32, 0.16], game.equipment_system.f_UV(v_G, "security")) * game.j_THIEF_CHANCE)
	return null

func thief_steal(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([0.62, 0.42, 0.26, 0.13, 0.04], game.equipment_system.f_UV(v_G, "security"))
	return null

func sec_name(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_n: Variant = null
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	v_n = game.equipment_system.f_UV(v_G, "security")
	return ("" if J.eq(v_n, 0.0) else J.getv(["Kepenk kilidi", "Alarm", "Kamera", "Çelik kepenk"], (v_n - 1.0)))
	return null

func patience(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([1.0, 1.15, 1.3, 1.5], game.equipment_system.f_UV(v_G, "paint"))
	return null

func wall_style(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_UV(v_G, "paint")
	return null

func slots(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([2.0, 3.0, 4.0, 5.0], game.equipment_system.f_UV(v_G, "expand"))
	return null

func price_mul(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([1.0, 1.16, 1.34, 1.6], game.equipment_system.f_UV(v_G, "sign"))
	return null

func cust_mul(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_G: Variant = null
	v_G = J.arg(_args, 0)
	return game.equipment_system.f_LV([1.0, 1.25, 1.5, 1.9], game.equipment_system.f_UV(v_G, "sign"))
	return null
