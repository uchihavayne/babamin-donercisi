# Scene integration points: only virtual overrides and artwork tool callbacks.
# Regular calls go directly to their owning module. See CODE_MAP.md.
extends "res://scripts/core/game_state.gd"

const MEAT_PER_CUT = preload("res://scripts/systems/equipment/cutting_system.gd").MEAT_PER_CUT

# Core
var audio_cues = preload("res://scripts/core/audio_cues.gd").new(self)
var effects = preload("res://scripts/core/effects.gd").new(self)
var game_loop = preload("res://scripts/core/game_loop.gd").new(self)
var game_setup = preload("res://scripts/core/game_setup.gd").new(self)
var localization = preload("res://scripts/core/localization.gd").new(self)
var math_utils = preload("res://scripts/core/math_utils.gd").new(self)

# Systems
var achievement_conditions = preload("res://scripts/systems/achievement_conditions.gd").new(self)
var achievement_system = preload("res://scripts/systems/achievement_system.gd").new(self)
var appearance_system = preload("res://scripts/systems/customers/appearance_system.gd").new(self)
var assembly_system = preload("res://scripts/systems/orders/assembly_system.gd").new(self)
var city_system = preload("res://scripts/systems/city_system.gd").new(self)
var customer_system = preload("res://scripts/systems/customer_system.gd").new(self)
var cutting_system = preload("res://scripts/systems/equipment/cutting_system.gd").new(self)
var drag_system = preload("res://scripts/systems/orders/drag_system.gd").new(self)
var drink_system = preload("res://scripts/systems/equipment/drink_system.gd").new(self)
var equipment_system = preload("res://scripts/systems/equipment_system.gd").new(self)
var equipment_tuning = preload("res://scripts/systems/equipment_tuning.gd").new(self)
var event_system = preload("res://scripts/systems/event_system.gd").new(self)
var fries_box_system = preload("res://scripts/systems/equipment/fries_box_system.gd").new(self)
var gameplay_input = preload("res://scripts/systems/gameplay_input.gd").new(self)
var grill_system = preload("res://scripts/systems/equipment/grill_system.gd").new(self)
var helper_system = preload("res://scripts/systems/customers/helper_system.gd").new(self)
var household_system = preload("res://scripts/systems/events/household_system.gd").new(self)
var leader_system = preload("res://scripts/systems/events/leader_system.gd").new(self)
var paper_system = preload("res://scripts/systems/equipment/paper_system.gd").new(self)
var payment_system = preload("res://scripts/systems/payment_system.gd").new(self)
var phone_system = preload("res://scripts/systems/customers/phone_system.gd").new(self)
var potato_system = preload("res://scripts/systems/equipment/potato_system.gd").new(self)
var progression_system = preload("res://scripts/systems/progression_system.gd").new(self)
var recipe_system = preload("res://scripts/systems/recipe_system.gd").new(self)
var regulation_system = preload("res://scripts/systems/events/regulation_system.gd").new(self)
var rival_system = preload("res://scripts/systems/events/rival_system.gd").new(self)
var save_system = preload("res://scripts/systems/save_system.gd").new(self)
var session_system = preload("res://scripts/systems/session_system.gd").new(self)
var stock_system = preload("res://scripts/systems/equipment/stock_system.gd").new(self)
var traffic_system = preload("res://scripts/systems/traffic_system.gd").new(self)
var weather_system = preload("res://scripts/systems/events/weather_system.gd").new(self)
var wrap_system = preload("res://scripts/systems/orders/wrap_system.gd").new(self)
var upgrade_system = preload("res://scripts/systems/upgrade_system.gd").new(self)

# Rendering
var achievement_draw = preload("res://scripts/rendering/ui/achievement_draw.gd").new(self)
var branch_draw = preload("res://scripts/rendering/ui/branch_draw.gd").new(self)
var building_draw = preload("res://scripts/rendering/street/building_draw.gd").new(self)
var character_draw = preload("res://scripts/rendering/character_draw.gd").new(self)
var chef_draw = preload("res://scripts/rendering/characters/chef_draw.gd").new(self)
var chopping_draw = preload("res://scripts/rendering/stations/chopping_draw.gd").new(self)
var costume_draw = preload("res://scripts/rendering/characters/costume_draw.gd").new(self)
var counter_draw = preload("res://scripts/rendering/counter_draw.gd").new(self)
var customer_draw = preload("res://scripts/rendering/characters/customer_draw.gd").new(self)
var day_end_draw = preload("res://scripts/rendering/day_end_draw.gd").new(self)
var debug_draw = preload("res://scripts/rendering/ui/debug_draw.gd").new(self)
var decor_draw = preload("res://scripts/rendering/decor_draw.gd").new(self)
var drink_draw = preload("res://scripts/rendering/stations/drink_draw.gd").new(self)
var equipment_draw = preload("res://scripts/rendering/equipment_draw.gd").new(self)
var food_draw = preload("res://scripts/rendering/food_draw.gd").new(self)
var fryer_draw = preload("res://scripts/rendering/stations/fryer_draw.gd").new(self)
var game_draw = preload("res://scripts/rendering/game_draw.gd").new(self)
var garnish_draw = preload("res://scripts/rendering/stations/garnish_draw.gd").new(self)
var household_draw = preload("res://scripts/rendering/ui/household_draw.gd").new(self)
var hud_draw = preload("res://scripts/rendering/ui/hud_draw.gd").new(self)
var icon_draw = preload("res://scripts/rendering/ui/icon_draw.gd").new(self)
var incident_draw = preload("res://scripts/rendering/events/incident_draw.gd").new(self)
var ingredient_draw = preload("res://scripts/rendering/ingredient_draw.gd").new(self)
var ingredient_pixels = preload("res://scripts/rendering/food/ingredient_pixels.gd").new(self)
var interface_draw = preload("res://scripts/rendering/interface_draw.gd").new(self)
var language_draw = preload("res://scripts/rendering/ui/language_draw.gd").new(self)
var legacy_order_draw = preload("res://scripts/rendering/ui/legacy_order_draw.gd").new(self)
var logo_draw = preload("res://scripts/rendering/logo_draw.gd").new(self)
var mount_draw = preload("res://scripts/rendering/street/mount_draw.gd").new(self)
var newspaper_draw = preload("res://scripts/rendering/ui/newspaper_draw.gd").new(self)
var night_draw = preload("res://scripts/rendering/ui/night_draw.gd").new(self)
var packaging_draw = preload("res://scripts/rendering/stations/packaging_draw.gd").new(self)
var pedestrian_draw = preload("res://scripts/rendering/street/pedestrian_draw.gd").new(self)
var phone_draw = preload("res://scripts/rendering/phone_draw.gd").new(self)
var plate_draw = preload("res://scripts/rendering/food/plate_draw.gd").new(self)
var portrait_draw = preload("res://scripts/rendering/characters/portrait_draw.gd").new(self)
var preparation_draw = preload("res://scripts/rendering/preparation_draw.gd").new(self)
var regulation_draw = preload("res://scripts/rendering/events/regulation_draw.gd").new(self)
var rival_building = preload("res://scripts/rendering/street/rival_building.gd").new(self)
var rival_panel_draw = preload("res://scripts/rendering/ui/rival_panel_draw.gd").new(self)
var sauce_draw = preload("res://scripts/rendering/stations/sauce_draw.gd").new(self)
var settings_draw = preload("res://scripts/rendering/ui/settings_draw.gd").new(self)
var shop_background = preload("res://scripts/rendering/shop_background.gd").new(self)
var shop_draw = preload("res://scripts/rendering/shop_draw.gd").new(self)
var signature_draw = preload("res://scripts/rendering/signature_draw.gd").new(self)
var spit_draw = preload("res://scripts/rendering/food/spit_draw.gd").new(self)
var sprite_draw = preload("res://scripts/rendering/sprite_draw.gd").new(self)
var story_canvas = preload("res://scripts/rendering/story/story_canvas.gd").new(self)
var story_closed = preload("res://scripts/rendering/story/story_closed.gd").new(self)
var story_debt = preload("res://scripts/rendering/story/story_debt.gd").new(self)
var story_draw = preload("res://scripts/rendering/story_draw.gd").new(self)
var story_father = preload("res://scripts/rendering/story/story_father.gd").new(self)
var story_key = preload("res://scripts/rendering/story/story_key.gd").new(self)
var story_shop = preload("res://scripts/rendering/story/story_shop.gd").new(self)
var street_actors = preload("res://scripts/rendering/street/street_actors.gd").new(self)
var street_background = preload("res://scripts/rendering/street/street_background.gd").new(self)
var street_draw = preload("res://scripts/rendering/street_draw.gd").new(self)
var text_draw = preload("res://scripts/rendering/text_draw.gd").new(self)
var title_draw = preload("res://scripts/rendering/ui/title_draw.gd").new(self)
var tray_draw = preload("res://scripts/rendering/food/tray_draw.gd").new(self)
var tutorial_draw = preload("res://scripts/rendering/ui/tutorial_draw.gd").new(self)
var vehicle_draw = preload("res://scripts/rendering/street/vehicle_draw.gd").new(self)
var weather_draw = preload("res://scripts/rendering/events/weather_draw.gd").new(self)
var window_draw = preload("res://scripts/rendering/street/window_draw.gd").new(self)
var wrap_draw = preload("res://scripts/rendering/food/wrap_draw.gd").new(self)

# Keep these virtual calls: platform, counter, order and atlas layers override them.
func f_chance(p_p: Variant = null) -> Variant:
	return math_utils.f_chance(p_p)

func initialize_game() -> void:
	game_setup.initialize_game()

func f_drawChef(p_x: Variant = null, p_y: Variant = null, p_st: Variant = null, p_t: Variant = null) -> Variant:
	return chef_draw.f_drawChef(p_x, p_y, p_st, p_t)

func f_drawCustomer(p_c: Variant = null, p_t: Variant = null) -> Variant:
	return customer_draw.f_drawCustomer(p_c, p_t)

func f_drawCounter() -> Variant:
	return counter_draw.f_drawCounter()

func f_drawCounterRaw() -> Variant:
	return counter_draw.f_drawCounterRaw()

func f_drawCounterProps(p_t: Variant = null) -> Variant:
	return counter_draw.f_drawCounterProps(p_t)

func f_drawTrash(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null, p_bosalt: Variant = null, p_dolu: Variant = null) -> Variant:
	return counter_draw.f_drawTrash(p_x, p_y, p_w, p_h, p_t, p_bosalt, p_dolu)

func f_drawFryer(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_F: Variant = null, p_t: Variant = null) -> Variant:
	return fryer_draw.f_drawFryer(p_x, p_y, p_w, p_h, p_F, p_t)

func f_drawPotatoBin(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null) -> Variant:
	return equipment_draw.f_drawPotatoBin(p_x, p_y, p_w, p_h, p_t)

func f_potBinPaint(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	return equipment_draw.f_potBinPaint(p_x, p_y, p_w, p_h)

func f_drawDrinkMachine(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_D: Variant = null, p_t: Variant = null) -> Variant:
	return drink_draw.f_drawDrinkMachine(p_x, p_y, p_w, p_h, p_D, p_t)

func f_drawSweetTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	return garnish_draw.f_drawSweetTray(p_x, p_y, p_w, p_h, p_n, p_max, p_t, p_fx)

func f_drawAyranTank(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_A: Variant = null, p_t: Variant = null) -> Variant:
	return drink_draw.f_drawAyranTank(p_x, p_y, p_w, p_h, p_n, p_max, p_A, p_t)

func f_drawGrill(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_Gr: Variant = null, p_t: Variant = null, p_cap: Variant = null) -> Variant:
	return equipment_draw.f_drawGrill(p_x, p_y, p_w, p_h, p_Gr, p_t, p_cap)

func f_drawBreadStack(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null) -> Variant:
	return equipment_draw.f_drawBreadStack(p_x, p_y, p_w, p_h, p_label)

func f_drawPideStack(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null) -> Variant:
	return equipment_draw.f_drawPideStack(p_x, p_y, p_w)

func f_drawPaperStation(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_level: Variant = null, p_busy: Variant = null, p_t: Variant = null) -> Variant:
	return packaging_draw.f_drawPaperStation(p_x, p_y, p_w, p_h, p_level, p_busy, p_t)

func f_drawIcecekKasasi(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_bolme: Variant = null, p_t: Variant = null) -> Variant:
	return drink_draw.f_drawIcecekKasasi(p_x, p_y, p_w, p_h, p_bolme, p_t)

func f_drawTepsiKasasi(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_bolmeler: Variant = null) -> Variant:
	return packaging_draw.f_drawTepsiKasasi(p_x, p_y, p_w, p_h, p_bolmeler)

func f_drawTepsiCami(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null) -> Variant:
	return packaging_draw.f_drawTepsiCami(p_x, p_y, p_w, p_h, p_t)

func f_drawCrate(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_open: Variant = null, p_t: Variant = null, p_acik: Variant = null) -> Variant:
	return equipment_draw.f_drawCrate(p_x, p_y, p_w, p_h, p_open, p_t, p_acik)

func f_sauceSlotX(p_i: Variant = null) -> Variant:
	return sauce_draw.f_sauceSlotX(p_i)

func f_drawSauceStation(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_on: Variant = null, p_isk: Variant = null, p_fx: Variant = null, p_t: Variant = null) -> Variant:
	return sauce_draw.f_drawSauceStation(p_x, p_y, p_w, p_h, p_on, p_isk, p_fx, p_t)

func f_drawCursor(p_x: Variant = null, p_y: Variant = null, p_mode: Variant = null, p_held: Variant = null, p_t: Variant = null) -> Variant:
	return food_draw.f_drawCursor(p_x, p_y, p_mode, p_held, p_t)

func f_drawPlay(p_t: Variant = null) -> Variant:
	return game_draw.f_drawPlay(p_t)

func f_drawPreparation(p_t: Variant = null) -> Variant:
	return preparation_draw.f_drawPreparation(p_t)

func f_lockedStation(p_s: Variant = null, p_label: Variant = null, p_t: Variant = null) -> Variant:
	return preparation_draw.f_lockedStation(p_s, p_label, p_t)

func f_drawShaveHint(p_t: Variant = null) -> Variant:
	return preparation_draw.f_drawShaveHint(p_t)

func f_drawPoster(p_kind: Variant = null, p_t: Variant = null, p_x: Variant = null, p_y: Variant = null) -> Variant:
	return decor_draw.f_drawPoster(p_kind, p_t, p_x, p_y)

func f_drawHoverHint(p_t: Variant = null) -> Variant:
	return tutorial_draw.f_drawHoverHint(p_t)

func f_drawKesimBicagi(p_ux: Variant = null, p_uy: Variant = null, p_yon: Variant = null, p_kademe: Variant = null) -> Variant:
	return spit_draw.f_drawKesimBicagi(p_ux, p_uy, p_yon, p_kademe)

func f_drawSpit(p_sp: Variant = null, p_t: Variant = null) -> Variant:
	return spit_draw.f_drawSpit(p_sp, p_t)

func f_trayInnerShade(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	return tray_draw.f_trayInnerShade(p_x, p_y, p_w, p_h)

func f_trayFlash(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_fx: Variant = null) -> Variant:
	return tray_draw.f_trayFlash(p_x, p_y, p_w, p_h, p_fx)

func f_trayBase(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	return tray_draw.f_trayBase(p_x, p_y, p_w, p_h)

func f_drawFill(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_lvl: Variant = null, p_seed: Variant = null, p_item: Variant = null) -> Variant:
	return tray_draw.f_drawFill(p_x, p_y, p_w, p_h, p_lvl, p_seed, p_item)

func f_pickleSlice(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	return ingredient_pixels.f_pickleSlice(p_x, p_y, p_sh, p_k, p_sz)

func f_meatStrip(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	return ingredient_pixels.f_meatStrip(p_x, p_y, p_sh, p_k, p_sz)

func f_fryStick(p_x: Variant = null, p_y: Variant = null, p_sh: Variant = null, p_k: Variant = null, p_sz: Variant = null) -> Variant:
	return ingredient_pixels.f_fryStick(p_x, p_y, p_sh, p_k, p_sz)

func f_drawYogurtTray(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_n: Variant = null, p_max: Variant = null, p_t: Variant = null, p_fx: Variant = null) -> Variant:
	return ingredient_draw.f_drawYogurtTray(p_x, p_y, p_w, p_h, p_n, p_max, p_t, p_fx)

func f_drawCutBoard(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_C: Variant = null, p_t: Variant = null) -> Variant:
	return chopping_draw.f_drawCutBoard(p_x, p_y, p_w, p_h, p_C, p_t)

func f_button(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null, p_col: Variant = null, p_hot: Variant = null) -> Variant:
	return interface_draw.f_button(p_x, p_y, p_w, p_h, p_label, p_col, p_hot)

func f_drawOrderBubble(p_c: Variant = null, p_t: Variant = null) -> Variant:
	return legacy_order_draw.f_drawOrderBubble(p_c, p_t)

func f_langButtons(p_x: Variant = null, p_y: Variant = null) -> Variant:
	return language_draw.f_langButtons(p_x, p_y)

func f_drawPause(p_t: Variant = null) -> Variant:
	return interface_draw.f_drawPause(p_t)

func f_tinyBtn(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_label: Variant = null, p_col: Variant = null) -> Variant:
	return debug_draw.f_tinyBtn(p_x, p_y, p_w, p_h, p_label, p_col)

func f_volSlider(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_deger: Variant = null, p_tur: Variant = null, p_renk: Variant = null, p_t: Variant = null) -> Variant:
	return settings_draw.f_volSlider(p_x, p_y, p_w, p_deger, p_tur, p_renk, p_t)

func f_proKat(p_ad: Variant = null, p_ciz: Variant = null) -> Variant:
	return story_canvas.f_proKat(p_ad, p_ciz)

func f_deliver(p_c: Variant = null) -> Variant:
	return customer_system.f_deliver(p_c)

func f_phoneClick() -> Variant:
	return phone_system.f_phoneClick()

func f_giveToCourier() -> Variant:
	return phone_system.f_giveToCourier()

func f_updateShave(p_dt: Variant = null) -> Variant:
	return cutting_system.f_updateShave(p_dt)

func f_doSlice() -> Variant:
	return cutting_system.f_doSlice()

func f_updateCut(p_dt: Variant = null) -> Variant:
	return potato_system.f_updateCut(p_dt)

func f_wrapFull(p_w: Variant = null) -> Variant:
	return recipe_system.f_wrapFull(p_w)

func f_secimUyuyor(p_w: Variant = null, p_ord: Variant = null) -> Variant:
	return recipe_system.f_secimUyuyor(p_w, p_ord)

func f_wrapKimlik(p_w: Variant = null) -> Variant:
	return recipe_system.f_wrapKimlik(p_w)

func f_wrapQuality(p_w: Variant = null) -> Variant:
	return recipe_system.f_wrapQuality(p_w)

func f_newWrap(preferred_board: Variant = null) -> Variant:
	return wrap_system.f_newWrap(preferred_board)

func f_activeWrap(p_yerVar: Variant = null) -> Variant:
	return wrap_system.f_activeWrap(p_yerVar)

func f_sauceIdxAt(p_mx: Variant = null) -> Variant:
	return assembly_system.f_sauceIdxAt(p_mx)

func f_finishRoll(p_idx: Variant = null) -> Variant:
	return wrap_system.f_finishRoll(p_idx)

func f_hitST(p_k: Variant = null) -> Variant:
	return session_system.f_hitST(p_k)

func f_startDay() -> Variant:
	return session_system.f_startDay()
