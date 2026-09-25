extends SceneTree

var game: Node
var checks := 0
var failures: Array[String] = []
var old_balance: Dictionary
var current_prices: Dictionary
var current_upgrades: Array

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func fresh(up := {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.weather = "sun"
	game.j_G.ferman = null; game.j_G.lider = null

func ready_wrap() -> Dictionary:
	return {"kind":"wrap", "meat":4, "pickleN":4, "yogurtN":4, "friesN":4,
		"sauce":null, "state":"ready", "paper":true,
		"grilled":bool(game.J.method(game.j_TUN,"grillOn",[game.j_G])), "burnt":false}

func sale(items: Array, patience := 0.7) -> void:
	# Ready food is a fixture. The real order validation, pricing, tipping,
	# coin collection and day-end debt rules still execute unchanged.
	game.j_G.customers = []
	game.customer_system.f_spawnCustomer()
	var customer: Dictionary = game.j_G.customers.back()
	customer.state = "wait"; customer.x = customer.tx; customer.homeless = false
	customer.mac = false; customer.items = items; customer.done = []
	customer.patience = patience; customer.earn = 0
	for item in items: customer.done.append(false)
	for item in items:
		game.j_G.hand = ready_wrap() if item.kind == "wrap" else item.duplicate(true)
		game.f_deliver(customer)
	while not game.j_G.coins.is_empty(): game.payment_system.f_collectCoin(0, true)

func test_payments() -> void:
	fresh()
	sale([{"kind":"wrap"}], 0.7)
	check(game.j_G.money == 23 and game.j_G.stat.earned == 23,
		"one ordinary wrap pays exactly 20 plus 3 tip")
	game.session_system.f_endDay()
	# BIRLESIK (8. tur): ilk 5 gun taksit yok, 6. gunden itibaren %18
	check(game.j_G.money == 23 and game.j_G.stat.debtPaid == 0,
		"the first five days keep the whole income (no debt payment yet)")
	fresh(); game.j_G.day = 6.0
	sale([{"kind":"wrap"}], 0.7)
	game.session_system.f_endDay()
	check(game.j_G.money == 19 and game.j_G.stat.debtPaid == 4,
		"from day six the day-end debt is 18 percent; displayed and spendable income agree")
	var exact := true
	for total in range(1, 301):
		var count := clampi(int(floor(total / 10.0 + 0.5)), 1, 6)
		var paid := 0
		for i in count: paid += game.payment_system.coin_share(total, count, i)
		exact = exact and paid == total
	check(exact, "all 1..300-unit receipts distribute exact coin totals")
	fresh({"drink":1, "fbox":1})
	sale([{"kind":"wrap"},{"kind":"drink","type":"cola"},{"kind":"fbox"}], 1.0)
	check(game.j_G.stat.wraps == 1 and game.j_G.stat.drinks == 1 and game.j_G.stat.boxes == 1,
		"a full combo is validated through the live delivery path")
	check(game.j_G.money == 59 and game.j_G.stat.earned == 59,
		"20+13+15 combo plus rounded tip deposits exactly 59")
	fresh({"phone":1})
	game.j_G.phone.state = "order"; game.j_G.phone.order = [{"kind":"wrap"}]
	game.j_G.phone.done = [false]; game.j_G.phone.timer = 40
	game.j_G.courier.state = "in"; game.j_G.courier.pay = 0
	game.j_G.hand = ready_wrap()
	check(game.f_giveToCourier() and game.j_G.courier.pay == 38,
		"courier applies the existing 1.9 multiplier to the new menu price")
	game.j_G.courier.state = "away"; game.j_G.courier.t = 100; game.j_G.luck = 0
	game.phone_system.f_updatePhone(0.01)
	check(game.j_G.money == 38 and game.j_G.stat.earned == 38,
		"returning courier deposits the same payment once")
	game.phone_system.f_updatePhone(0.01)
	check(game.j_G.money == 38, "courier cannot pay twice")

func test_upgrades() -> void:
	fresh(); game.j_G.scene = "shop"
	game.j_G.money = 100000
	check(not game.upgrade_system.buy("tongs") and game.j_G.money == 100000,
		"tongs need the wide counter (a second board) first")
	game.j_G.up = {"board": 1}
	var tongs_price := 0
	for u in game.j_UPG:
		if u.id == "tongs": tongs_price = int(u.lv[0].p)
	game.j_G.money = tongs_price - 1
	check(not game.upgrade_system.buy("tongs") and game.j_G.money == tongs_price - 1 and not game.j_G.up.has("tongs"),
		"insufficient funds never buy a level or deduct money")
	game.j_G.money = tongs_price
	check(game.upgrade_system.buy("tongs") and game.j_G.money == 0 and game.j_G.up.tongs == 1,
		"first tongs upgrade costs exactly its listed price")
	check(game.J.method(game.j_TUN,"meatPerClick",[game.j_G]) >= game.j_MEAT_NEED and game.J.method(game.j_TUN,"tongsTargets",[game.j_G]) == 2,
		"one click is a full portion; buying tongs serves a second item per click")
	check(game.f_loadGame().up.tongs == 1 and game.f_loadGame().money == 0,
		"purchased equipment and spent cash persist in the save")
	game.save_system.f_loadAndGo()
	check(game.j_G.up.tongs == 1 and game.j_G.money == 0,
		"loading the save keeps the owned level and exact balance")
	game.j_G.scene = "shop"; game.j_G.money = 100000
	check(not game.upgrade_system.buy("garnish") and not game.upgrade_system.buy("missing"),
		"prerequisites and invalid upgrade ids remain enforced")
	game.upgrade_system.buy("iskender")
	check(game.upgrade_system.buy("garnish"), "owning the prerequisite unlocks garnish")
	var timings: Array = []
	for level in range(4):
		timings.append(game.J.method(game.j_TUN,"shaveCd",[game.j_G]))
		check(not game.J.method(game.j_TUN,"autoShave",[game.j_G]),
			"knife stays manual before its final level: " + str(level))
		check(game.upgrade_system.buy("knife"), "knife level can be bought: " + str(level+1))
	check(game.J.method(game.j_TUN,"autoShave",[game.j_G]), "automatic cutter unlocks only at level four")
	var money: float = game.j_G.money
	check(not game.upgrade_system.buy("knife") and game.j_G.money == money,
		"maxed equipment cannot be bought or charged again")
	check(timings == [0.5,0.38,0.3,0.24] and game.MEAT_PER_CUT == 3,
		"knife rhythm and three-unit yield remain as requested")
	game.j_G.scene = "play"
	check(not game.upgrade_system.buy("store"), "purchases only occur in the shop")
	var prices_increase := true
	var preview_fits := true
	var preview_is_read_only := true
	for upgrade in game.j_UPG:
		var previous_price := 0
		for level in upgrade.lv.size():
			game.j_G.up[upgrade.id] = level
			var cost: int = game.upgrade_system.price(upgrade)
			prices_increase = prices_increase and cost > previous_price
			previous_price = cost
			for language in ["tr","en","de","es","fr","pt"]:
				game.localization.f_setLang(language)
				var before := JSON.stringify(game.j_G.up)
				var preview: String = game.upgrade_system.preview(upgrade)
				preview_fits = preview_fits and game.f_textW(preview) <= 220
				preview_is_read_only = preview_is_read_only and before == JSON.stringify(game.j_G.up)
	check(prices_increase, "all 24 equipment price curves strictly increase per level")
	check(preview_fits, "upgrade effects fit the existing card in all six languages")
	check(preview_is_read_only, "previewing a level never changes owned equipment")
	game.localization.f_setLang("tr")

func simulate(legacy: bool, orders_per_day: int) -> Array:
	game.j_PRICE = old_balance.prices.duplicate(true) if legacy else current_prices.duplicate(true)
	game.j_UPG = current_upgrades.duplicate(true)
	if legacy:
		for upgrade in game.j_UPG:
			for i in upgrade.lv.size(): upgrade.lv[i].p = old_balance.upgrades[upgrade.id][i]
	game.session_system.f_resetProgress()
	var schedule: Array = []
	# Fixed workload isolates money pacing. It is not a simulated human or an
	# assertion that everyone finishes this many orders in a real timed day.
	var plan := ["knife","drink","fryer","paper","store","board","tongs","secim","grill","helper","phone","knife"]
	var next := 0
	for day in range(1, 13):
		game.j_G.day = day
		game.f_startDay(); game.j_G.weather = "sun"; game.j_G.ferman = null; game.j_G.lider = null
		for order in orders_per_day:
			var items: Array = [{"kind":"wrap"}]
			if game.j_G.up.get("drink",0) > 0 and order % 3 == 0:
				items.append({"kind":"drink","type":"cola"})
			sale(items)
		game.session_system.f_endDay()
		var spendable: int = game.j_G.money
		var bought: Array = []
		game.j_G.scene = "shop"
		while next < plan.size() and game.upgrade_system.buy(plan[next]):
			bought.append(plan[next]); next += 1
		schedule.append({"day":day,"gross":game.j_G.stat.earned,"debt_paid":game.j_G.stat.debtPaid,
			"cash_before_shop":spendable,"purchases":bought,"cash_after_shop":game.j_G.money})
	return schedule

func first_purchase(schedule: Array, id: String) -> int:
	for day in schedule:
		if id in day.purchases: return day.day
	return -1

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/economy-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	old_balance = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/economy-0.6.1.json"))
	current_prices = game.j_PRICE.duplicate(true); current_upgrades = game.j_UPG.duplicate(true)
	test_payments(); test_upgrades()
	var scenarios := {}
	for orders in [6,8,10]:
		var before := simulate(true,orders)
		var after := simulate(false,orders)
		# BIRLESIK (8. tur, oyuncu elestirisi "en basit sey icin 7-8 tur"): ilk
		# seviyeler 0.7.0 fiyatinda, sonrakiler pahali; ilk 5 gun taksit yok ->
		# ilk yararli alim 1. gun, ilk yeni urun en gec 4. gun.
		check(first_purchase(after,"knife") == 1 and first_purchase(before,"knife") > 1,
			"first useful purchase is reachable on day one at " + str(orders) + " orders")
		check(first_purchase(after,"drink") in range(2,5),
			"first additional product unlock arrives on days 2..4 at " + str(orders) + " orders")
		check(after[0].cash_before_shop > before[0].cash_before_shop,
			"starter day's take-home earnings increase at " + str(orders) + " orders")
		scenarios[str(orders)] = {"before":before,"after":after}
	var report := {"checks":checks,"failures":failures,"scenarios":scenarios,
		"assumptions":"12 fixed-workload days; 6/8/10 accurate wrap orders, 70% patience, sunny weather, drink on every third order once owned. Actual delivery, payments, debt, purchases and saves. No human input timing, phone/branch income, penalties or night events. Both curves use exact coin allocation."}
	var file := FileAccess.open("res://validation/economy-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("ECONOMY ",JSON.stringify({"checks":checks,"failures":failures}))
	game.free(); await process_frame; quit(0 if failures.is_empty() else 1)
