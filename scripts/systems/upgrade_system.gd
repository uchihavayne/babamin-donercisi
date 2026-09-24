# Upgrade rules and a preview derived from the actual tuning callbacks.
extends "res://scripts/core/game_module.gd"

const SPEED := {
	"knife":"shaveCd", "pknife":"cutTime", "fryer":"fryTime",
	"paper":"paperTime", "grill":"grillTime", "drink":"pourTime",
	"fbox":"fboxTime", "phone":"courierTime",
}
const CAPACITY := {
	"tongs":"meatPerClick", "pknife":"cutYield", "fryer":"fryCap",
	"grill":"grillCap", "ayran":"ayranMax", "sweet":"sweetMax",
	"garnish":"garnishMax", "board":"boards", "store":"stockMax",
	"uncle":"uncleUses", "expand":"slots", "secim":"secimEnCok",
}

func price(upgrade: Dictionary) -> Variant:
	var level := int(game.j_G.up.get(upgrade.id, 0))
	if level < 0 or level >= upgrade.lv.size(): return null
	return int(upgrade.lv[level].p)

func buy(id: String) -> bool:
	if game.j_G.scene != "shop": return false
	var upgrade: Variant = game.equipment_system.f_upgById(id)
	if not upgrade is Dictionary: return false
	if upgrade.has("gerek") and int(game.j_G.up.get(upgrade.gerek, 0)) <= 0: return false
	var cost: Variant = price(upgrade)
	if cost == null or game.j_G.money < cost: return false
	# BIRLESIK (6. tur, madde 13): ertesi gunun basinda istasyon parlar ve
	# "YENI: Fritoz 6.5sn > 4.8sn" bildirimi cikar (ne degistigi oyunda gorunsun)
	var ozet := preview(upgrade)
	if not (game.j_G.get("yeniAlim") is Array): game.j_G.yeniAlim = []
	game.j_G.yeniAlim.append({"id": id, "st": upgrade.get("st", ""), "ad": game.localization.f_T(upgrade.name), "ozet": ozet})
	game.j_G.money -= cost
	game.j_G.up[id] = int(game.j_G.up.get(id, 0)) + 1
	game.j_SHOP.bake = null
	game.j_G.best = maxf(game.j_G.best, game.j_G.day)
	game.save_system.f_saveAll()
	return true

func tune(key: String, state: Dictionary) -> float:
	return float(J.method(game.j_TUN, key, [state]))

func number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func transition(key: String, before: Dictionary, after: Dictionary, unit: String) -> String:
	var previous := tune(key, before)
	var next := tune(key, after)
	# A newly unlocked machine has no previous operating speed/capacity.
	if previous <= 0: return number(next) + unit
	return number(previous) + unit + " > " + number(next) + unit

func preview(upgrade: Dictionary) -> String:
	if price(upgrade) == null: return game.localization.f_T(upgrade.desc)
	var id: String = upgrade.id
	var before: Dictionary = game.j_G
	var after: Dictionary = before.duplicate()
	after.up = before.up.duplicate()
	after.up[id] = int(before.up.get(id, 0)) + 1
	var parts: Array[String] = []
	if SPEED.has(id): parts.append(transition(SPEED[id], before, after, "sn" if game.j_LANG == "tr" else "s"))
	if CAPACITY.has(id):
		var label: String = {"tr":"ADET ","en":"QTY ","de":"ANZ. ","fr":"QTÉ ","es":"CANT. ","pt":"QTD. "}.get(game.j_LANG,"QTY ")
		parts.append(label + transition(CAPACITY[id], before, after, ""))
	if parts.is_empty(): return game.localization.f_T(upgrade.desc)
	return " / ".join(parts)

func action_label(upgrade: Dictionary) -> String:
	if int(game.j_G.up.get(upgrade.id, 0)) == 0: return game.localization.f_T("SATIN AL")
	return {"tr":"GELİŞTİR","en":"UPGRADE","de":"VERBESSERN","fr":"AMÉLIORER","es":"MEJORAR","pt":"MELHORAR"}.get(game.j_LANG,"UPGRADE")
