# KESME EFEKTI (birlesik surum, 12. tur). Kullanici: "patatesi keserken patates havaya mi ucsun, guzel kesilme efekti
# ve animasyonu olsa, goze guzel gelen". Efekt SALT GORSELDIR (potato_system.kd_*): ziplayan dilimler, havaya firlayip celik
# kaba yagan dilimler, vurus ezilmesi, kap sallanmasi, yukari sayan sayac. Cizim pikselleri tests/kesme_efekt_visual.gd'de;
# bu test MANTIGI ve "oyunu degistirmez" sozunu kilitler:
#  1) saflik: ayni betikli kesim oturumu efektli ve efektsiz (kd_kapali) oynayinca oyun durumu (G), kesim boyunca rastgele sayi
#     akisi ve sonuc (raw) birebir ayni; efekt G'ye alan eklemez, rastgele sayi tuketmez
#  2) vurus: ezilme 0 -> 1 -> 0 egrisi, bicak fazi vurustan baslar ve tavanda kalir
#  3) yeni dilim: floor(prog * 7) artinca dilim kesik yuzden ziplar, 0,24 sn'de siraya iner; yuklemede ve yeni patatesle ziplama yok;
#     havadaki dilim tahtada cizilmez (f_dilimHavada), inince cizilir
#  4) patates bitince: 7 dilim kaba ucar, raw tam cutYield kadar artar (efekt kaydirmaz), sayac monoton yukari sayar, hepsi inince
#     tam deger ve bekleyen 0; her inis kap sallar / sayaci vurgular
#  4b) BUTUN PATATES havada: ilk vurus patatesi havaya firlatir, vuruslar surerken havada asili kalir (hic tahtaya inmez, ~6-9 px, tavani
#     asmaz), vuruslar bitince iner ve tamamen durur (egim dahil), inerken ezilir; patates yokken vurus bir sey kaldirmaz; patates
#     bitince havadaki patates gider ve dilimler onun yuksekliginden kalkar
#  5) temizlik ve sinir: yeni gun her seyi sifirlar; guncelleme durup art arda bitse bile havadaki dilim sayisi sinirli, bekleyen
#     porsiyon eksiye dusmez ve takilip kalmaz
#  6) otomasyon (4. kademe otomatik dograyici) tamamlanmalarinda da calisir, sinirli kalir
#   godot --headless --path . --script tests/kesme_efekt.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func yeni_oyun() -> Node:
	var o: Node = load("res://scripts/platform_game.gd").new()
	o.storage.path = "res://artifacts/kesme-efekt-save.json"; o.storage.values = {}
	root.add_child(o); o.set_process(false); o.j_MUTED = true
	o.localization.f_setLang("tr")
	return o

func step(n: int = 1) -> void:
	for i in n: game.advance(1.0 / 60)

# donanim ayari (equipment_tuning): j_TUN baglanmis cagrilabilirler tutar, bagimsiz degiskenler dizi olarak verilir
func tun(ad: String) -> float:
	return float(game.j_TUN[ad].call([game.j_G]))

func kur(seviye: Dictionary = {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.prologueSeen = true
	for k in seviye: game.j_G.up[k] = float(seviye[k])
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null

# betikli kesim oturumu: patates al, in, basili tutarak dograt (her 0,17 sn'de vurus), tahtadan fritoze koy
func oturum(kapali: bool) -> Dictionary:
	game = yeni_oyun()
	game.random_state = 424242
	game.potato_system.kd_kapali = kapali
	kur()
	var G: Dictionary = game.j_G
	G.cut.potato = false; G.cut.prog = 0.0
	game.potato_system.f_potatoTake()
	step(30)
	var vt := 0.0
	var vurus := 0
	for kare in 600:
		if not bool(G.cut.potato): break
		G.cut.cutting = true; G.cut.hold = 0.12
		vt -= 1.0 / 60.0
		if vt <= 0.0:
			vt = 0.17
			game.potato_system.f_slashAt()
			vurus += 1
		step()
	# rastgele sayi akisi KESIM BITER BITMEZ olculur: oyun bir sure sonra akisi kendiliginden yeniden esitliyor (fritoze koyduktan
	# ~50 kare sonra iki oturumun akisi birlesiyor), sonda karsilastirmak efektin tukettigi sayiyi gizlerdi
	var rnd_kesim: int = game.random_state
	step(60)
	var raw_bitis: float = float(G.cut.raw)
	game.potato_system.f_fryerClick()
	step(90)
	var d := {"durum": var_to_str(G), "rnd": game.random_state, "rnd_kesim": rnd_kesim, "raw": raw_bitis, "vurus": vurus, "ucan": game.potato_system.kd_ucan.size()}
	game.free()
	return d

func run() -> void:
	# 1) saflik
	var a: Dictionary = await oturum(false)
	var b: Dictionary = await oturum(true)
	check(int(a.vurus) >= 8 and float(a.raw) >= 26.0, "betikli oturum gercekten dograttı: %d vurus, raw %s" % [a.vurus, a.raw])
	check(a.durum == b.durum, "efektli ve efektsiz oturumda oyun durumu (G) birebir ayni")
	check(int(a.rnd_kesim) == int(b.rnd_kesim), "kesim boyunca rastgele sayi akisi ayni (efekt rastgele sayi tuketmez): %d / %d" % [a.rnd_kesim, b.rnd_kesim])
	check(float(a.raw) == float(b.raw), "raw ayni")
	check(int(a.ucan) == 0, "oturum sonunda havada dilim kalmaz")
	game = yeni_oyun()
	kur()
	var G: Dictionary = game.j_G
	var P = game.potato_system
	check(not P.kd_kapali and P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0 and P.kd_n == -1, "yeni gunde efekt durumu bos")
	# 2) vurus egrileri
	P.f_kesimVurus()
	check(P.kd_vurus == 0.0 and P.kd_vurusNo == 1, "vurus sayaci sifirlanir, vurus numarasi artar")
	check(is_equal_approx(P.f_kesimEzilme(), 0.0) and is_equal_approx(P.f_bicakFazi(), 0.0), "vurus aninda ezilme 0 (hizla artacak), bicak en ustte")
	P.f_kesimEfektGuncelle(0.03)
	check(is_equal_approx(P.f_kesimEzilme(), 1.0), "0,03 sn sonra ezilme tepede (%s)" % P.f_kesimEzilme())
	var onceki: float = 1.0
	var azaldi := true
	for i in 12:
		P.f_kesimEfektGuncelle(0.02)
		var e: float = P.f_kesimEzilme()
		if e > onceki + 0.0001: azaldi = false
		onceki = e
	check(azaldi and P.f_kesimEzilme() == 0.0, "ezilme tepeden sonra tek yonlu soner ve 0'a iner (%s)" % P.f_kesimEzilme())
	P.f_kesimEfektGuncelle(1.0)
	check(P.f_bicakFazi() > 0.99 and P.f_bicakFazi() < 1.0, "bicak fazi tavanda kalir (<1: sonraki vurusa hazir): %s" % P.f_bicakFazi())
	# 3) yeni dilim ziplamasi
	G.cut.potato = true; G.cut.prog = 0.6; G.cut.cutting = false
	P.f_kesimEfektTemizle()
	P.f_kesimEfektGuncelle(0.0)
	check(P.kd_ucan.is_empty() and P.kd_n == 4, "ilk gorusta (yukleme) ziplama yok, sayi senkronlanir (kd_n %d)" % P.kd_n)
	G.cut.prog = 0.0
	P.f_kesimEfektGuncelle(0.0)
	check(P.kd_n == 0 and P.kd_ucan.is_empty(), "yeni patates (ilerleme basa dondu): ziplama yok")
	G.cut.prog = 0.16     # floor(0.16 * 7) = 1 dilim
	P.f_kesimEfektGuncelle(0.0)
	check(P.kd_ucan.size() == 1 and P.kd_ucan[0].tur == "zipla" and int(P.kd_ucan[0].i) == 0, "ilk dilim ziplar")
	check(P.f_dilimHavada(0) and not P.f_dilimHavada(1), "havadaki dilim tahtada cizilmez, digerleri cizilir")
	var c0: Dictionary = P.kd_ucan[0]
	var bas: Variant = P.f_dilimKonum(c0)
	var kesik: float = P.f_kesikYuzX(0.16)
	check(abs(float(bas.x) - (kesik + 1.0)) < 0.001, "dilim kesik yuzden kalkar (x %s, kesik+1 %s)" % [bas.x, kesik + 1.0])
	var orta_c: Dictionary = c0.duplicate(); orta_c.t = float(c0.dur) * 0.5
	var orta: Variant = P.f_dilimKonum(orta_c)
	check(float(orta.y) < float(bas.y) - 6.0, "yayin tepesinde baslangictan en az 6 piksel yukarida (%s -> %s)" % [bas.y, orta.y])
	var son_c: Dictionary = c0.duplicate(); son_c.t = float(c0.dur)
	var son: Variant = P.f_dilimKonum(son_c)
	var yer: Vector2 = P.f_dilimYeri(0, kesik) + Vector2(1.0, 4.0)
	check(abs(float(son.x) - yer.x) < 0.001 and abs(float(son.y) - yer.y) < 0.001, "dilim tahtadaki yerine tam iner (fark %s,%s)" % [son.x - yer.x, son.y - yer.y])
	check(abs(float(son.aci)) < 0.001, "inerken dik (aci 0): %s" % son.aci)
	for i in 14: P.f_kesimEfektGuncelle(1.0 / 60.0)
	check(P.f_dilimHavada(0), "0,233 sn'de (14 kare) dilim hala havada (sure 0,24)")
	P.f_kesimEfektGuncelle(1.0 / 60.0)
	check(P.kd_ucan.is_empty() and not P.f_dilimHavada(0), "0,25 sn sonra dilim inmis ve tahtada cizilir")
	G.cut.prog = 0.45     # 3 dilim: ikisi birden ziplar
	P.f_kesimEfektGuncelle(0.0)
	check(P.kd_ucan.size() == 2 and P.f_dilimHavada(1) and P.f_dilimHavada(2), "iki yeni dilim ayni anda ziplar")
	P.f_kesimEfektGuncelle(1.0)
	check(P.kd_ucan.is_empty(), "ziplayanlar sureyi doldurunca kalkar (tavan aşilmaz)")
	# 4) patates bitince
	P.f_kesimEfektTemizle()
	G.cut.potato = true; G.cut.prog = 0.999; G.cut.cutting = true; G.cut.hold = 0.2; G.cut.raw = 3.0
	P.f_kesimEfektGuncelle(0.0)
	var yield_: float = tun("cutYield")
	P.f_updateCut(0.1)     # prog >= 1: patates biter
	check(not bool(G.cut.potato) and float(G.cut.raw) == 3.0 + yield_, "patates bitti, raw tam cutYield kadar artti (%s -> %s)" % [3.0, G.cut.raw])
	var kap_n := 0
	for d in P.kd_ucan: if d.tur == "kap": kap_n += 1
	check(kap_n == P.KD_DILIM, "7 dilim kaba ucar (%d)" % kap_n)
	check(abs(P.kd_bekleyen - yield_) < 0.001, "bekleyen porsiyon = eklenen porsiyon (%s / %s)" % [P.kd_bekleyen, yield_])
	check(abs(P.f_sayacPorsiyon(float(G.cut.raw)) - 3.0) < 0.001, "sayac baslangicta eski degeri gosterir (%s)" % P.f_sayacPorsiyon(float(G.cut.raw)))
	var son_deger: float = P.f_sayacPorsiyon(float(G.cut.raw))
	var degerler := {}
	var monoton := true
	var kap_sallandi := false
	var sayac_vurgulandi := false
	var inis_say := 0
	for i in 60:
		var onceki_n: int = P.kd_ucan.size()
		P.f_kesimEfektGuncelle(1.0 / 60.0)
		inis_say += maxi(0, onceki_n - P.kd_ucan.size())
		var v: float = P.f_sayacPorsiyon(float(G.cut.raw))
		if v < son_deger - 0.0001: monoton = false
		son_deger = v
		degerler[snappedf(v, 0.01)] = true
		if P.kd_kap > 0.5: kap_sallandi = true
		if P.kd_sayac > 0.5: sayac_vurgulandi = true
	check(monoton, "sayac yalniz yukari sayar")
	check(degerler.size() >= 6, "sayac asama asama sayar (ara deger sayisi %d): her inen dilim sayaci artirir, sona ziplamaz" % degerler.size())
	check(kap_sallandi and sayac_vurgulandi, "inislerde celik kap sallanir ve sayac vurgulanir")
	check(P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0, "hepsi inince havada dilim ve bekleyen porsiyon kalmaz")
	check(abs(P.f_sayacPorsiyon(float(G.cut.raw)) - float(G.cut.raw)) < 0.0001, "sayac sonunda gercek raw'a esit")
	check(inis_say == P.KD_DILIM, "7 dilimin hepsi indi (%d)" % inis_say)
	# 4b) butun patates havada
	kur()
	G = game.j_G; P = game.potato_system
	G.cut.potato = true; G.cut.prog = 0.0; G.cut.cutting = false
	P.f_kesimEfektTemizle()
	P.f_kesimEfektGuncelle(0.0)
	check(P.kd_py == 0.0 and P.kd_pv == 0.0 and P.kd_pa == 0.0, "dinlenmede patates tahtada, egim yok")
	P.f_kesimVurus()
	check(P.kd_pv > 70.0 and P.kd_pv <= P.KD_KALDIR + 0.001, "ilk vurus patatesi havaya firlatir (hiz %s)" % P.kd_pv)
	P.f_kesimEfektGuncelle(1.0 / 60.0)
	check(P.kd_py > 0.5, "firlatilan patates yukselir (%s)" % P.kd_py)
	var en_alt := 999.0
	var en_ust := 0.0
	var inis_max := 0.0
	var vt2 := 0.0
	for kare in 120:                                  # 2 sn boyunca 0,17 sn'de bir vurus
		vt2 -= 1.0 / 60.0
		if vt2 <= 0.0:
			vt2 = 0.17
			P.f_kesimVurus()
		P.f_kesimEfektGuncelle(1.0 / 60.0)
		if kare >= 20:
			en_alt = minf(en_alt, P.kd_py)
			en_ust = maxf(en_ust, P.kd_py)
		inis_max = maxf(inis_max, P.kd_inis)
	check(en_alt > 3.0, "vuruslar surerken patates havada asili kalir, tahtaya inmez (en alcak %.2f px)" % en_alt)
	check(en_ust <= P.KD_TAVAN + 0.001 and en_ust < 11.0 and en_ust > 5.0, "tavani asmaz, ~6-9 px'de asili kalir (en yuksek %.2f px)" % en_ust)
	check(inis_max == 0.0, "havada asiliyken inis ezilmesi yok")
	var inerken := 0.0
	for kare in 60:                                   # vuruslar bitti
		P.f_kesimEfektGuncelle(1.0 / 60.0)
		inerken = maxf(inerken, P.kd_inis)
	check(inerken > 0.9, "inince patates ezilir (inis %.2f)" % inerken)
	check(P.kd_py == 0.0 and P.kd_pv == 0.0 and P.kd_pa == 0.0 and P.kd_pw == 0.0 and P.kd_inis == 0.0, "vuruslar bitince patates iner ve tamamen durur (egim, hiz, ezilme sifir)")
	G.cut.potato = false
	P.f_kesimVurus(); P.f_kesimEfektGuncelle(0.1)
	check(P.kd_pv == 0.0 and P.kd_py == 0.0, "patates yokken vurus bir sey kaldirmaz")
	G.cut.potato = true; G.cut.prog = 0.999; G.cut.cutting = true; G.cut.hold = 0.2
	P.f_kesimEfektGuncelle(0.0)
	P.f_kesimVurus(); P.f_kesimEfektGuncelle(0.1)
	var yuk_bitis: float = P.kd_py
	check(yuk_bitis > 2.0, "bitmeden once patates havada (%.2f px)" % yuk_bitis)
	var ay_bitis: float = float(game.j_ST.cut.y) + P.KESME_PATATES.y
	P.f_updateCut(0.1)
	check(not bool(G.cut.potato) and P.kd_py == 0.0 and P.kd_pa == 0.0, "patates bitince havadaki patates gider")
	var yukseklerden := 0
	for d in P.kd_ucan:
		if d.tur == "kap" and float(d.y0) < ay_bitis - 1.0 - 1.0: yukseklerden += 1
	check(yukseklerden >= 1, "kalan patates kismi havadaki yuksekliginden kalkar (%d dilim yukaridan basladi)" % yukseklerden)
	# 5) temizlik ve sinir
	P.f_kesimTamam(26.0)
	check(not P.kd_ucan.is_empty() and P.kd_bekleyen > 0.0, "tamamlanma efekti baslar")
	game.f_startDay()
	check(P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0 and P.kd_n == -1 and P.kd_kap == 0.0 and P.kd_sayac == 0.0, "yeni gun efekt durumunu sifirlar")
	for i in 30: P.f_kesimTamam(26.0)     # guncelleme hic calismadan art arda bitis
	check(P.kd_ucan.size() <= P.KD_EN_COK, "guncelleme durunca da havadaki dilim sayisi sinirli (%d <= %d)" % [P.kd_ucan.size(), P.KD_EN_COK])
	check(P.kd_bekleyen >= 0.0 and P.kd_bekleyen <= 26.0 * 30.0, "bekleyen porsiyon eksiye dusmez (%s)" % P.kd_bekleyen)
	P.f_kesimEfektGuncelle(2.0)
	check(P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0, "sinira takilanlar bile bitince bekleyen sifirlanir, takilip kalmaz (%s)" % P.kd_bekleyen)
	P.f_kesimEfektTemizle()
	P.kd_kapali = true
	var no0: int = P.kd_vurusNo
	var vurus0: float = P.kd_vurus
	P.f_kesimVurus(); P.f_kesimTamam(26.0); P.f_kesimEfektGuncelle(0.5)
	check(P.kd_ucan.is_empty() and P.kd_vurusNo == no0 and P.kd_vurus == vurus0 and P.kd_bekleyen == 0.0, "kapaliyken kancalar bos doner, hicbir durum degismez")
	P.kd_kapali = false
	game.free()
	# 6) otomasyon: 4. kademe otomatik dograyici art arda patates bitirir
	game = yeni_oyun()
	kur({"pknife": 4})
	G = game.j_G; P = game.potato_system
	check(bool(game.j_TUN["autoCut"].call([G])), "4. kademede otomatik dograyici acik")
	G.cut.potato = false; G.cut.raw = 0.0
	var en_cok := 0
	var bitis := 0
	var raw_onceki := 0.0
	for kare in 60 * 14:
		step()
		en_cok = maxi(en_cok, P.kd_ucan.size())
		if float(G.cut.raw) > raw_onceki + 0.5: bitis += 1
		raw_onceki = float(G.cut.raw)
		if float(G.cut.raw) >= tun("fryCap") * 2.0 - 0.5: break
	check(bitis >= 1, "otomatik dograyici en az bir patates bitirdi (%d)" % bitis)
	check(en_cok > 0 and en_cok <= P.KD_EN_COK, "otomasyonda efekt calisir ve sinirli kalir (en cok %d)" % en_cok)
	step(90)
	check(P.kd_ucan.is_empty() and P.kd_bekleyen == 0.0, "otomasyon sonrasi hepsi yerine oturdu")
	check(abs(P.f_sayacPorsiyon(float(G.cut.raw)) - float(G.cut.raw)) < 0.0001, "otomasyonda sayac gercek raw'a esit")
	game.free()
	for f in failures: push_error(f)
	print("KESME EFEKT ", JSON.stringify({"failures": failures}))
	quit(0 if failures.is_empty() else 1)
