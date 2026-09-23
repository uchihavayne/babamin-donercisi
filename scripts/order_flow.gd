# Order extension points. Behavior: systems/order_system.gd; visuals: rendering/order_draw.gd.
# REMAKE: yeni tezgahin HD katmani (counter_design_hd.gd) arada
extends "res://scripts/counter_design_hd.gd"

const ORDER_FIELDS := {"meat":"meat", "pickle":"pickleN", "yogurt":"yogurtN", "fries":"friesN"}
var chosen_order: Dictionary = {}

var order_system = preload("res://scripts/systems/order_system.gd").new(self)
var order_draw = preload("res://scripts/rendering/order_draw.gd").new(self)

func order_text(tr_text: String, en_text: String) -> String:
	return order_system.order_text(tr_text, en_text)

func f_startDay() -> Variant:
	return order_system.f_startDay()

func order_items(owner: Dictionary) -> Array:
	return order_system.order_items(owner)

func order_live(owner: Dictionary) -> bool:
	return order_system.order_live(owner)

func order_next(owner: Dictionary) -> int:
	return order_system.order_next(owner)

func order_select(owner: Dictionary) -> void:
	order_system.order_select(owner)

func order_bind(w: Dictionary, owner: Dictionary, index: int) -> void:
	order_system.order_bind(w, owner, index)

func order_reserved(owner: Dictionary, index: int) -> bool:
	return order_system.order_reserved(owner, index)

func f_newWrap(preferred_board: Variant = null) -> Variant:
	return order_system.f_newWrap(preferred_board)

func f_phoneClick() -> Variant:
	return order_system.f_phoneClick()

func f_secimUyuyor(w: Variant = null, recipe: Variant = null) -> Variant:
	return order_system.f_secimUyuyor(w, recipe)

func order_matches(w: Dictionary, recipe: Dictionary) -> bool:
	return order_system.order_matches(w, recipe)

func order_problem(w: Dictionary, recipe: Dictionary) -> String:
	return order_system.order_problem(w, recipe)

func f_wrapFull(w: Variant = null) -> Variant:
	return order_system.f_wrapFull(w)

func f_wrapQuality(w: Variant = null) -> Variant:
	return order_system.f_wrapQuality(w)

func f_wrapKimlik(w: Variant = null) -> Variant:
	return order_system.f_wrapKimlik(w)

func f_finishRoll(index: Variant = null) -> Variant:
	return order_system.f_finishRoll(index)

func order_match_index(w: Dictionary, owner: Dictionary) -> int:
	return order_system.order_match_index(w, owner)

func order_reject(w: Dictionary, owner: Dictionary) -> void:
	order_system.order_reject(w, owner)

func f_deliver(customer: Variant = null) -> Variant:
	return order_system.f_deliver(customer)

func f_giveToCourier() -> Variant:
	return order_system.f_giveToCourier()

func order_bubble_rect(customer: Dictionary) -> Rect2:
	return order_draw.order_bubble_rect(customer)

func order_icon(item: Dictionary, x: float, y: float, time: float) -> void:
	order_draw.order_icon(item, x, y, time)

func order_ingredient(ingredient: String, x: float, y: float) -> void:
	order_draw.order_ingredient(ingredient, x, y)

func order_badge(ingredient: String, x: float, y: float, omitted: bool) -> void:
	order_draw.order_badge(ingredient, x, y, omitted)

func f_drawOrderBubble(customer: Variant = null, time: Variant = null) -> Variant:
	return order_draw.f_drawOrderBubble(customer, time)

func f_drawPreparation(time: Variant = null) -> Variant:
	var result: Variant = super.f_drawPreparation(time)
	order_draw.draw_preparation_overlay(time)
	return result

func draw_order_receipt(time: float) -> void:
	order_draw.draw_order_receipt(time)
