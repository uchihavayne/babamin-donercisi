# TEZGAH YERLESIMI / PATATES TAHTASI (birlesik surum, 12. tur). Kullanici: "patates kesme tahtasini ve yerini daha duzgun
# yap, daha buyuk, biraz daha anlasilabilir, genis olsun ama diger upgradeler geldiginde ustuste binmesinler".
# Sag-alt serit (sos + kagit + tahta + kutu) tamamen doluydu; tahta 51 -> 63 px'e cikarken sos standi daraltilip sola alindi.
# Bu test yerlesimin BOZULMAMASI icin kilitler (cizimi gercek pencerede tests/patates_tahtasi_visual.gd olcer):
#  1) HICBIR iki istasyonun dokunma alani (j_ST) ust uste binmez (tek bilincli istisna: icecek makinesi + ayran kazani, makineye takili)
#  2) tahta genis (>= 60 x 36) ve fritozun altinda, sos / kagit sutununun sagi ile patates kutusunun solu arasindaki koridora oturur;
#     koridorun iki yaninda en az 2 piksel bosluk var, alt kenari tezgah kenarini (236) asmaz
#  3) HD'de cizilen parcalarin GERCEK kutulari (atlas olculeri) de kesismez: sos sisleri, kagit, kutu rafi, fritoz, izgara, tahta
#  4) tahtanin ic yerlesimi (patates, satir, celik kap, cubuk kalkis noktasi, ucan patatesin inis noktasi) tahtanin icinde ve birbirine binmez
#  5) tum upgrade seviyelerinde yerlesim ayni (rect'ler statik): hepsi maksimumken de kesisme yok
#   godot --headless --path . --script tests/tezgah_yerlesim.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func R(ad: String) -> Rect2:
	var s: Dictionary = game.j_ST[ad]
	return Rect2(float(s.x), float(s.y), float(s.w), float(s.h))

# atlas parcasinin cizildigi gercek kutu (mantik px): sol-ust = (x + dx, y + dy), boyut = HD / hd
func parca_kutu(atlas: Dictionary, ad: String, x: float, y: float) -> Rect2:
	var p: Array = atlas.parca[ad]
	return Rect2(x + float(p[4]), y + float(p[5]), float(p[2]) / float(atlas.hd), float(p[3]) / float(atlas.hd))

func atlas_oku(ad: String) -> Dictionary:
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/remake/%s/atlas.json" % ad))
	return v if v is Dictionary else {}

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/tezgah-yerlesim-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	game.session_system.f_resetProgress(); game.j_G.prologueSeen = true; game.f_startDay()
	# 1) hicbir iki istasyon ust uste binmez
	var izinli := [["drinkM", "ayran"], ["drinkM", "shutter"]]
	var anahtar: Array = game.j_ST.keys()
	var cakisan: Array = []
	for i in anahtar.size():
		for j in range(i + 1, anahtar.size()):
			var a: String = anahtar[i]
			var b: String = anahtar[j]
			if R(a).intersects(R(b)) and not ([a, b] in izinli or [b, a] in izinli): cakisan.append("%s x %s" % [a, b])
	check(cakisan.is_empty(), "istasyon dokunma alanlari ust uste binmez (cakisan: %s)" % str(cakisan))
	for a in anahtar: check(Rect2(0, 0, 480, 270).encloses(R(a)), "istasyon oyun alaninin icinde: " + a)
	# 2) tahta genis ve koridora oturur
	var cut := R("cut")
	check(cut.size.x >= 60.0 and cut.size.y >= 36.0, "tahta genis: %s (eskisi 51 x 37)" % str(cut.size))
	var fryer := R("fryer"); var sauce := R("sauce"); var paper := R("paper"); var fbox := R("fbox"); var grill := R("grill")
	check(cut.position.y >= fryer.end.y + 1.0, "tahta fritozun altinda, arada bosluk var (%s / %s)" % [cut.position.y, fryer.end.y])
	check(cut.end.y <= 236.0, "tahtanin alt kenari tezgah kenarini (236) asmaz (%s)" % cut.end.y)
	check(cut.position.x >= sauce.end.x + 2.0, "sos standiyla tahta arasi >= 2 px (%s)" % (cut.position.x - sauce.end.x))
	check(cut.position.x >= paper.end.x + 2.0, "kagit makinesiyle tahta arasi >= 2 px (%s)" % (cut.position.x - paper.end.x))
	check(cut.end.x + 2.0 <= fbox.position.x, "tahtayla patates kutusu arasi >= 2 px (%s)" % (fbox.position.x - cut.end.x))
	check(cut.end.x <= grill.end.x and cut.position.x >= sauce.position.x, "tahta sos sutunu ile izgara arasinda")
	# sos standi bosluksuz 3 sise tasir (tiklama indisi w / 3 ile bolunur): 12 pikselden dar olmamali
	check(sauce.size.x / 3.0 >= 12.0, "sos sisesi basina >= 12 px (%s)" % (sauce.size.x / 3.0))
	# 3) HD'de cizilen parcalarin gercek kutulari
	var A2 := atlas_oku("tezgah2")
	check(not A2.is_empty() and A2.has("parca"), "tezgah2 atlasi okunur")
	if not A2.is_empty():
		var kutular := {}
		kutular["fritoz"] = parca_kutu(A2, "fritoz_govde", fryer.position.x, fryer.position.y)
		kutular["izgara"] = parca_kutu(A2, "izgara_govde", grill.position.x, grill.position.y)
		kutular["kagit"] = parca_kutu(A2, "kagit_makine", paper.position.x, paper.position.y)
		kutular["kagit_yigin"] = parca_kutu(A2, "kagit_yigin", paper.position.x, paper.position.y)
		kutular["kutu_raf"] = parca_kutu(A2, "kutu_raf_46", fbox.position.x, fbox.position.y)
		for i in 3:
			var cx: float = sauce.position.x + (i + 0.5) * sauce.size.x / 3.0
			kutular["sise_%d" % i] = parca_kutu(A2, "sise_%d" % i, cx, sauce.position.y + sauce.size.y - 2.0)
		# tahta: sprite tahta alaninin icinde, ustten 3 px bosluklu (kesme_tahta dy = 3)
		var tahta := Rect2(cut.position.x, cut.position.y + 3.0, cut.size.x, 34.0)
		check(tahta.end.y <= 236.0, "tahta parcasinin alt kenari tezgah kenarini asmaz (%s)" % tahta.end.y)
		for ad in kutular:
			check(not tahta.intersects(kutular[ad]), "HD cizim: tahta parcasi %s ile ust uste binmez (%s / %s)" % [ad, str(tahta), str(kutular[ad])])
		# sos sisesinin sag kenari ile tahta arasi
		check(tahta.position.x - (kutular["sise_2"] as Rect2).end.x >= 1.5, "son sos sisesi ile tahta arasi >= 1,5 px (%s)" % (tahta.position.x - (kutular["sise_2"] as Rect2).end.x))
		# 4) ic yerlesim
		var P = game.potato_system
		var patates: Vector2 = Vector2(cut.position.x, cut.position.y) + P.KESME_PATATES
		var patates_kutu := Rect2(patates.x - 12.0, patates.y - 7.5, 24.0, 15.0)            # patates_11 (en buyuk asama)
		var kap_sol_ust: Vector2 = P.f_kapNoktasi(cut.position.x, cut.position.y, cut.size.x)
		var kap := Rect2(kap_sol_ust, Vector2(16, 16))
		var satir := Rect2(cut.position.x + P.KESME_SATIR_X - 0.5, cut.position.y + cut.size.y / 2.0 - 7.0, 8.0, 21.5)
		check(tahta.encloses(patates_kutu), "patates tahtanin icinde (%s)" % str(patates_kutu))
		check(tahta.encloses(kap), "celik kap tahtanin icinde (%s)" % str(kap))
		check(tahta.encloses(satir), "satir (dinlenme) tahtanin icinde (%s)" % str(satir))
		check(not patates_kutu.intersects(satir) and not patates_kutu.intersects(kap) and not satir.intersects(kap), "patates / satir / celik kap birbirine binmez")
		check(satir.position.x - patates_kutu.end.x >= 2.0 and kap.position.x - satir.end.x >= 1.5, "bolgeler arasi bosluk (patates-satir %s, satir-kap %s)" % [satir.position.x - patates_kutu.end.x, kap.position.x - satir.end.x])
		check(kap.end.y <= tahta.position.y + 28.0, "celik kap tahtanin yuzeyine oturur (alt kenar %s)" % kap.end.y)
		# cubuklar kabin icinde: en cok 15 cubuk (3 satir x 5), 2 px genislik, 2,4 aralik, 5 px boy
		var en_sag: float = kap_sol_ust.x + 2.0 + 4.0 * 2.4 + 2.0
		check(en_sag <= kap.end.x - 1.0, "cubuklar kabin icinde (en sag %s, kap sagi %s)" % [en_sag, kap.end.x])
		# ucan patatesin inis noktasi / cubuk kalkis noktasi (HD yolu): ayni ic yerlesimden
		game.hd_acik = true
		check(patates.is_equal_approx(Vector2(cut.position.x + 17.0, cut.position.y + 19.0)), "patatesin capasi tahtanin soluna gore sabit (17, 19)")
		var cubuk: Vector2 = kap_sol_ust + Vector2(8.0, 10.0)
		check(kap.has_point(cubuk), "cubuk kalkis noktasi celik kabin icinde (%s)" % str(cubuk))
	# 5) tum upgrade seviyelerinde ayni yerlesim (rect'ler statik, upgradeden etkilenmez)
	var onceki := {}
	for a in anahtar: onceki[a] = R(a)
	for u in game.j_UPG: game.j_G.up[u.id] = float(u.lv.size())
	game.f_startDay()
	for a in anahtar: check(R(a) == onceki[a], "upgrade'ler istasyon yerini degistirmez: " + a)
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("TEZGAH YERLESIM ", JSON.stringify({"istasyon": anahtar.size(), "failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
