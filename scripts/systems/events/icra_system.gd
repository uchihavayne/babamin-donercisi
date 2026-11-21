# Icra (birlesik surum, 12. tur, kullanici istegi: "icrayi mekanige cevir: asgari taksit, kacirinca uyari,
# sonra kepenk muhurlenmesi"). Bkz. ECONOMY.md "13. tur", REHBER.md.
#
# Borc taksiti (kazancin %18'i, j_DEBT_CUT) artik GUNLUK kesilmez, BIRIKIR; her HAFTA (7) gunde bir icra memuru
# SABAHLEYIN kapida bekler (dukkan cubugundaki "GUN N" dugmesine basinca, gece olayindan once) ve birikeni KASADAN
# tahsil eder. Toplam taksit orani ayni kalir; degisen yalniz ZAMANLAMA: o haftanin taksiti dukkandan cikmadan once
# kasada KALMALIDIR (gunun kazanci o aksam harcanmissa memur gelirken kasa bostur): "rezerv ayir" gerilimi.
#   - kasa yeter            -> HESAP TAMAM (ihtar silinir)
#   - kasa yetmez, 1. kusur -> tahsilat kasadaki kadar olur, kalan + %20 gecikme zammi birikir; IHTAR
#   - kasa yetmez, ust uste 2. kusur -> KEPENK MUHURU: 1 / 2 / 3 gun (her muhurde bir uzar) gelirsiz kaybedilir
#     (takvim ilerler, gun sayaci atlar), ihtar sifirlanir, devreden borc birikmeye devam eder.
#   - borcun tamami birikmis ve kasadaysa memur beklemez: son taksit gun sonunda hemen tahsil edilir (eski davranis)
# Oyun bitmez (icradan satis yok): ceza, kaybedilen gunlerdir (yaris hissi) ve kaybedilen gelirdir.
# Oynanan sehir Demirkent (ferman) ise ya da borc bittiyse icra yoktur (o ekonomi baska: household_system).
# Durum G.icra (kayda girer; "sonuc" arayuz karti oldugundan girmez). Arayuz: rendering/ui/icra_draw.gd.
extends "res://scripts/core/game_module.gd"

const ILK_GUN := 13.0              # ilk icra: 13. gunun sabahi (6.-12. gunlerin taksiti birikmistir)
const HAFTA := 7.0                 # icra gunleri arasi gun
const TOLERANS := 0.02             # istenenin %2'sinden azi eksik kalirsa (yuvarlama payi) kusur sayilmaz
const GECIKME := 0.20              # odenemeyen kismin %20'si gecikme zammi olarak birikene eklenir
const MUHUR_GUN := [1.0, 2.0, 3.0] # n. muhur kac gun surer (sonrakiler hep sonuncusu)

func f_yeni() -> Dictionary:
	return {"birikim": 0.0, "sonraki": ILK_GUN, "ihtar": 0.0, "muhur": 0.0, "atla": 0.0, "ziyaret": 0.0, "ihtarSayisi": 0.0, "sonuc": null}

# G.icra her zaman gecerli bir sozluk olur (eski kayit / yeni oyun: ilk erisimde kurulur)
func f_durum() -> Dictionary:
	var d: Variant = J.getv(game.j_G, "icra")
	if not (d is Dictionary):
		d = f_yeni()
		J.setv(game.j_G, "icra", d)
	return d

# kayittan yukleme: yalniz bilinen alanlar, sonlu ve negatif olmayan sayilar; ihtar 0/1, bekleyen muhur gunu en cok
# son muhur suresi. Bozuk ya da eski (alan yok) kayit: taze durum, ilk ziyaret en erken bir hafta sonra.
func f_yukle(v: Variant, gun: float) -> Dictionary:
	var d := f_yeni()
	if v is Dictionary:
		for k in ["birikim", "sonraki", "ihtar", "muhur", "atla", "ziyaret", "ihtarSayisi"]:
			var x: Variant = v.get(k)
			if (typeof(x) == TYPE_FLOAT or typeof(x) == TYPE_INT) and is_finite(float(x)):
				d[k] = maxf(0.0, float(x))
		d.ihtar = minf(1.0, floorf(float(d.ihtar)))
		d.atla = minf(float(MUHUR_GUN[MUHUR_GUN.size() - 1]), floorf(float(d.atla)))
		if float(d.sonraki) < 1.0: d.sonraki = ILK_GUN
	else:
		d.sonraki = maxf(ILK_GUN, gun + HAFTA)
	J.setv(game.j_G, "icra", d)
	return d

# kayda yazilacak hali (arayuz karti "sonuc" haric)
func f_kayit() -> Dictionary:
	var d: Dictionary = f_durum().duplicate()
	d.erase("sonuc")
	return d

# icra isliyor mu: borc var ve oynanan sehir Demirkent (ferman) degil
func f_aktif() -> bool:
	return J.n(J.getv(game.j_G, "debt")) > 0.0 and not J.truth(game.progression_system.f_fermanSehri(game.j_G))

# birikmis (henuz odenmemis) taksit; borcu asmaz
func f_birikim() -> float:
	return minf(J.n(f_durum().birikim), J.n(J.getv(game.j_G, "debt")))

# sonraki icra sabahina kac sabah var: 1 = yarin sabah (bu aksamki alimlar son sans); icra yoksa -1
func f_kalanGun() -> int:
	if not f_aktif(): return -1
	return maxi(1, int(J.n(f_durum().sonraki) - J.n(J.getv(game.j_G, "day"))))

# icra yaklasiyor mu (arayuz uyarisi): taksit birikmis ve memur en cok `esik` sabah icinde geliyor
func f_yaklasti(esik: int = 2) -> bool:
	if not f_aktif(): return false
	var k := f_kalanGun()
	return k >= 1 and k <= esik and f_birikim() > 0.0

# kasa birikimi karsilar mi (arayuz uyarisi rengi)
func f_yeterli() -> bool:
	return J.n(J.getv(game.j_G, "money")) >= f_birikim()

# gun sonunda (session_system.f_endDay, sube geliri eklendikten sonra) cagrilir: bugunun taksiti birikir; borcun tamami
# birikmis ve kasadaysa son taksit hemen tahsil edilir. Dondurur: bugun kasadan alinan tahsilat (stat.debtPaid ile ayni).
func f_gunSonu() -> float:
	var G: Dictionary = game.j_G
	var st: Dictionary = G.stat
	var I := f_durum()
	st["taksitBirikti"] = 0.0
	if not f_aktif() or J.n(G.day) < float(game.session_system.TAKSIT_GUN):
		return 0.0
	var borc: float = J.n(G.debt)
	# bugunun taksiti birikir (kazancin %18'i); toplam birikim borcu asmaz
	var gunluk: float = minf(borc - J.n(I.birikim), floorf(J.n(st.earned) * J.n(game.j_DEBT_CUT) + 0.5))
	if gunluk > 0.0:
		I.birikim = J.n(I.birikim) + gunluk
		st["taksitBirikti"] = gunluk
	# son taksit: borcun tamami birikmis ve kasada, memur beklemez
	if J.n(I.birikim) >= borc and J.n(G.money) >= borc:
		return f_ziyaret(false)
	return 0.0

# dukkan cubugundaki "GUN N" dugmesine basinca (gece olayindan ve gun artisindan ONCE): icra sabahi geldiyse memur kasadan
# alir. true = memur karti acildi (gun karti kapatilana kadar baslamaz); false = icra yok / sessiz gecti
func f_sabahZiyareti() -> bool:
	if not f_aktif(): return false
	var I := f_durum()
	if J.n(J.getv(game.j_G, "day")) + 1.0 < J.n(I.sonraki): return false
	f_ziyaret(true)
	if f_kartAcik():
		game.save_system.f_saveAll()   # tahsilat kasayi / borcu degistirdi: karti gorup uygulamayi kapatan kurtulamaz
	return f_kartAcik()

# memur kasadan alir; kusuru ihtar / muhur olarak isler. sabah: dukkan cubugundan (gun + 1. sabah); degilse gun sonu
# (son taksit). Dondurur: kasadan alinan tutar.
func f_ziyaret(sabah: bool) -> float:
	var G: Dictionary = game.j_G
	var I := f_durum()
	var gun: float = J.n(G.day) + (1.0 if sabah else 0.0)
	var vade: bool = sabah and gun >= J.n(I.sonraki)
	var borc: float = J.n(G.debt)
	var para: float = J.n(G.money)
	var istenen: float = minf(J.n(I.birikim), borc)
	var odenen: float = minf(istenen, para)
	var eksik: float = istenen - odenen
	if vade:
		I.sonraki = gun + HAFTA
	if istenen <= 0.0:
		return 0.0   # toplanacak bir sey yok (Demirkent donusu, bos hafta): memur sessizce gecer
	G.money = para - odenen
	G.debt = borc - odenen
	I.birikim = istenen - odenen
	G.stat["debtPaid"] = J.n(G.stat.get("debtPaid", 0.0)) + odenen
	var sonuc := {"gun": gun, "istenen": istenen, "odenen": odenen, "eksik": eksik, "zam": 0.0, "durum": "tamam", "atla": 0.0, "ilk": J.n(I.ziyaret) < 1.0}
	I.ziyaret = J.n(I.ziyaret) + 1.0
	if eksik > maxf(1.0, TOLERANS * istenen):
		# kusur: kalan + gecikme zammi birikmeye devam eder (borcu asmaz)
		var zam: float = minf(floorf(GECIKME * eksik + 0.5), maxf(0.0, J.n(G.debt) - J.n(I.birikim)))
		I.birikim = J.n(I.birikim) + zam
		sonuc.zam = zam
		I.ihtarSayisi = J.n(I.ihtarSayisi) + 1.0
		if J.n(I.ihtar) >= 1.0:
			# ust uste ikinci kusur: kepenk muhurlenir (n. muhur n gun; takvim atlar, sonraki icra tam bir hafta sonra)
			var n: float = float(MUHUR_GUN[mini(int(J.n(I.muhur)), MUHUR_GUN.size() - 1)])
			I.muhur = J.n(I.muhur) + 1.0
			I.ihtar = 0.0
			I.atla = J.n(I.atla) + n
			I.sonraki = J.n(I.sonraki) + n
			sonuc.durum = "muhur"
			sonuc.atla = n
		else:
			I.ihtar = 1.0
			sonuc.durum = "ihtar"
	else:
		I.ihtar = 0.0
	if J.n(G.debt) <= 0.0:
		# son taksit: borc bitti, kutlama (memur karti gerekmez)
		G.debt = 0.0
		I.birikim = 0.0
		if not J.truth(J.getv(G, "debtCleared")):
			G.debtCleared = true
			G.celeb = {"t": 0.0}
		return odenen
	I.sonuc = sonuc
	return odenen

# elle odeme (BORC ODE paneli) once bu haftanin birikmis taksitinden duser
func f_odendi(tutar: float) -> void:
	var I := f_durum()
	I.birikim = maxf(0.0, J.n(I.birikim) - maxf(0.0, tutar))

# BORC ODE paneli "TAKSITI ODE": birikmis taksiti kasadan oder (kasa yetmezse kasadaki kadar). true = bir sey odendi
func f_taksitiOde() -> bool:
	var b: float = f_birikim()
	if b <= 0.0 or J.n(J.getv(game.j_G, "money")) <= 0.0: return false
	return J.truth(game.branch_draw.f_payDebt(minf(b, J.n(J.getv(game.j_G, "money")))))

# yeni gune gecerken eklenecek gun sayisi: 1 + bekleyen muhur gunleri; bekleyeni sifirlar
func f_gunAtla() -> float:
	var I := f_durum()
	var n: float = 1.0 + maxf(0.0, J.n(I.atla))
	I.atla = 0.0
	return n

# dukkan cubugundaki "GUN N" dugmesinin gosterecegi gun (bekleyen muhur gunleri dahil)
func f_sonrakiGun() -> float:
	return J.n(J.getv(game.j_G, "day")) + 1.0 + maxf(0.0, J.n(f_durum().atla))

# gun sonu memur karti acik mi
func f_kartAcik() -> bool:
	return f_durum().get("sonuc") is Dictionary

func f_kartKapat() -> void:
	f_durum()["sonuc"] = null
