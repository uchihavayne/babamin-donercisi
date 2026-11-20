# Potato system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# PATATES TAHTASI ic yerlesimi (HD, mantik px, tahtanin sol-ust kosesine gore). Tahta 63 px genisligindedir ve soldan saga
# uc bolgesi var: [patates + dilimler][satir][celik kap + cig cubuklar + sayac]. Cizim (counter_design_hd.f_drawCutBoard),
# ucan patatesin inis noktasi, kesik izleri ve cubuk kalkis noktasi AYNI sabitleri kullanir.
const KESME_PATATES := Vector2(17.0, 19.0)   # tahtadaki patatesin capasi (merkez)
const KESME_SATIR_X := 33.0                   # satirin dinlenme konumu (sag bolgenin solu)
const KESME_KAP_SAG := 20.0                   # celik kabin sag kenari, tahtanin sag kenarindan uzakligi + kap genisligi (16)
const KESME_KAP_UST := 14.0                   # celik kabin ust kenari, tahtanin ustunden

# celik kabin sol-ust kosesi (kesme_kap parcasi 16x16)
func f_kapNoktasi(x: Variant, y: Variant, w: Variant) -> Vector2:
	return Vector2(float(x) + float(w) - KESME_KAP_SAG, float(y) + KESME_KAP_UST)

# Patatesin tahtada OTURDUGU nokta (merkez, mantik pikseli). Ucus tam buraya iner, boylece inis aninda
# statik cizime "sicrama" olmaz: HD'de sprite capasi (counter_design_hd.f_drawCutBoard: KESME_PATATES), eski
# cizimde elipsin merkezi (counter_design.f_drawCutBoard: x+w/2, y+h/2). (flyP.x1/y1 eski cizgi icin kalir.)
func f_inisNoktasi() -> Vector2:
	var c: Dictionary = game.j_ST.cut
	if game.hd_ucan_acik(): return Vector2(float(c.x), float(c.y)) + KESME_PATATES
	return Vector2(float(c.x) + float(c.w) / 2.0, float(c.y) + float(c.h) / 2.0)

# bicak izlerinin yatay merkezi: HD'de patatesin biraz sagi, eski cizimde elipsin biraz solu (iki cizimde de patatesin ustunde)
func f_kesikX() -> float:
	var c: Dictionary = game.j_ST.cut
	if game.hd_ucan_acik(): return float(c.x) + KESME_PATATES.x + 2.5
	return float(c.x) + float(c.w) / 2.0 - 6.0

# ---------------------------------------------------------------- fritoze koyma ucusu
# Kullanici: "fritoze koy gecisi anlik". MANTIK AYNEN: f_fryerClick cubuklari alir, kizartma t=0'da baslar.
# Yalniz GORUNTU: ham cubuklar tahtadan sepete FRITOZ_UCUS sn ucar; inene kadar sepette patates gorunmez
# (G.flyF dolu); inince yag sicrar ve cizirdar. Oyun zamani / dengesi degismez.
const FRITOZ_UCUS := 0.30

# cubuklarin kalktigi nokta (tahtadaki ham yigin) ve sepet agzi; HD ile eski cizim biraz farkli yerlestirir
func f_cubukBaslangic() -> Vector2:
	var c: Dictionary = game.j_ST.cut
	if game.hd_ucan_acik(): return f_kapNoktasi(c.x, c.y, c.w) + Vector2(8.0, 10.0)   # HD: celik kaptaki cig_cubuk yigini
	return Vector2(float(c.x) + 20.0, float(c.y) + 22.0)                           # eski cizim: tahtaya serpili cubuklar

func f_sepetNoktasi() -> Vector2:
	var f: Dictionary = game.j_ST.fryer
	if game.hd_ucan_acik(): return Vector2(float(f.x) + float(f.w) / 2.0, float(f.y) + 15.0)
	return Vector2(float(f.x) + float(f.w) / 2.0, float(f.y) + 20.0)

# sepete inis: yag sicramasi (sabit desen: rastgele sayi tuketmez) + cizirti
func f_fritozInis() -> void:
	var b: Vector2 = f_sepetNoktasi()
	for i in 9:
		var a: float = -PI / 2.0 + (float(i) - 4.0) * 0.28
		var hiz: float = 26.0 + float((i * 7) % 5) * 7.0
		game.effects.f_part({"x": b.x + (float(i) - 4.0) * 1.6, "y": b.y, "vx": cos(a) * hiz * 0.7, "vy": sin(a) * hiz - 14.0,
			"life": 0.55, "col": "#ffe9a3" if i % 2 == 0 else "#e6c463", "g": 120.0, "sz": 1.0})
	J.setv(game.j_G.fryer, "gir", 1.0)   # sepetteki patates 0.14 sn'de belirginlesir (ani "pat" diye belirmesin)
	J.method(game.j_SFX, "sizzle", [])

# ---------------------------------------------------------------- kesme efekti (SALT GORSEL)
# Kullanici: "patatesi keserken patates havaya mi ucsun, guzel kesilme efekti ve animasyonu olsa, goze guzel gelen".
# KURAL, SURE, RASTGELE SAYI DIZISI VE KAYIT DEGISMEZ: durum G'de degil bu modulde durur (gun ici kayda girmez) ve hicbir
# yerde oyunun rastgele ureticisi cagrilmaz (sabit desenler). Uc olay:
#  1) bicak vurusu (f_slashAt): patates ezilip toparlanir; bicak vurusla AYNI ANDA iner (once ayri, sabit 0,2 sn'lik tempo)
#  2) tahtada yeni dilim belirince (floor(prog * 7) artinca) dilim kesik yuzden ziplayip siraya iner
#  3) patates bitince (raw artar) siradaki dilimler havaya firlayip celik kaba yagar; kap sallanir, sayac yukari sayar
#  4) BUTUN PATATES havada dograilir (kullanici: "havaya ucsun, havada keselim"): ilk vurus patatesi havaya firlatir, vuruslar surerken
#     havada asili kalip sallanir (her vurus kucuk bir tekme), bicak patatesin yuksekligini izler, altinda golgesi kalir; vuruslar
#     bitince iner ve ezilir. Dokunma alani / ilerleme / sure DEGISMEZ (tahta dikdortgeni ayni, ilerleme zamanla artar)
const KD_YER := 520.0               # havadaki patatesin yercekimi (px/sn^2)
const KD_KALDIR := 96.0             # bicak vurusunun patatesi yukari firlatma hizi (px/sn); yukseldikce tekme zayiflar: ~6-9 px'de asili kalir
const KD_TAVAN := 14.0              # patatesin tahtadan en yuksek konumu (px)
const KD_SALLA := 2.4               # vurusta patatesin egim darbesi (rad/sn)
const KD_DILIM := 7                 # bir patatesten tahtada gorunen dilim sayisi (counter_design_hd: floor(prog * 7))
const KD_ZIPLA := 0.24              # tek dilimin zipla suresi (sn)
const KD_UCUS := 0.34               # patates bitince dilimlerin kaba ucus suresi (sn)
const KD_ARALIK := 0.035            # dilimler arasi kalkis gecikmesi (sn)
const KD_VURUS := 0.20              # bir vurusun bicak fazi: inis + bekleme + kalkis (sn)
const KD_EN_COK := 28               # havadaki dilim tavani (guncelleme durursa / art arda bitince birikmesin)

var kd_kapali := false              # hata ayiklama / test: true iken butun efekt kancalari bos doner
var kd_ucan: Array = []             # ucan dilimler: {tur: "zipla" | "kap", i, t, dur, x0, y0, x1, y1, yay, aci0, spin, birim}
var kd_vurus: float = 9.0           # son bicak vurusundan beri gecen sure (sn)
var kd_vurusNo: int = 0             # vurus sayaci (kirinti desenini tohumlar)
var kd_n: int = -1                  # tahtada gorulen dilim sayisi (-1: henuz gorulmedi, yuklemede ziplama olmasin)
var kd_kesik: float = 0.0           # son karede kesik yuzun x'i (patates bitince dilimler buradan kalkar)
var kd_kap: float = 0.0             # celik kap sallanmasi (1 -> 0)
var kd_sayac: float = 0.0           # sayac vurgusu (1 -> 0)
var kd_bekleyen: float = 0.0        # kaba dogru ucan porsiyon: sayac dilimler inene kadar yukari saymaz
var kd_py: float = 0.0              # patatesin tahtadan yuksekligi (px, >= 0; 0 = tahtada)
var kd_pv: float = 0.0              # dikey hizi (px/sn, yukari +)
var kd_pa: float = 0.0              # egim acisi (rad)
var kd_pw: float = 0.0              # egim hizi (rad/sn)
var kd_inis: float = 0.0            # inis ezilmesi (1 -> 0)

func f_kesimEfektTemizle() -> void:
	kd_ucan = []
	kd_vurus = 9.0
	kd_n = -1
	kd_kesik = 0.0
	kd_kap = 0.0
	kd_sayac = 0.0
	kd_bekleyen = 0.0
	kd_py = 0.0
	kd_pv = 0.0
	kd_pa = 0.0
	kd_pw = 0.0
	kd_inis = 0.0

# kesik yuzun x'i: patates sagdan kisalir (counter_design_hd.f_drawCutBoard: ax - 11 + 2 * pw)
func f_kesikYuzX(prog: float) -> float:
	var c: Dictionary = game.j_ST.cut
	var pw := clampi(int(maxf(2.0, floorf(11.0 * (1.0 - clampf(prog, 0.0, 1.0)) + 0.5))), 2, 11)
	return float(c.x) + KESME_PATATES.x - 11.0 + 2.0 * pw

# tahtadaki i. dilimin SOL-UST kosesi (counter_design_hd ile ayni formul): kesik yuzun saginda hafif egik dizilir
func f_dilimYeri(i: int, kesik: float) -> Vector2:
	var c: Dictionary = game.j_ST.cut
	return Vector2(kesik + 3.0 + float(i) * 2.6, float(c.y) + KESME_PATATES.y - 5.0 + float(i % 2) * 0.5)

# bicak vurusu: ezilme + bicagin inisi bu ana baglanir
func f_kesimVurus() -> void:
	if kd_kapali: return
	kd_vurus = 0.0
	kd_vurusNo += 1
	if bool(game.j_G.cut.potato):
		# tekme: yukseldikce zayifla (tavana vurmasin, ~9 px'de asili kalsin); egim darbesi vurus yonune gore degisir
		kd_pv = maxf(kd_pv, KD_KALDIR * clampf(1.0 - kd_py / KD_TAVAN, 0.25, 1.0))
		kd_pw = KD_SALLA * (1.0 if kd_vurusNo % 2 == 0 else -1.0)

# ezilme (0..1): vurus anindan hemen sonra hizla artar, sonra yumusakca soner
func f_kesimEzilme() -> float:
	var t := kd_vurus
	if t < 0.03: return t / 0.03
	return pow(clampf(1.0 - (t - 0.03) / 0.16, 0.0, 1.0), 2.0)

# bicagin fazi (0..1): 0 = vurus an, 0.22 = temas, 1 = bir sonraki vurusa hazir (counter_design_hd.f_drawCutBoard ile ayni egri)
func f_bicakFazi() -> float:
	return clampf(kd_vurus / KD_VURUS, 0.0, 0.999)

# celik kabin saga/asagi oturmasi (yarim piksel adimlariyla; dilim inince 1 -> 0)
func f_kapSallanma() -> float:
	return roundf(kd_kap * kd_kap * 2.0) / 2.0

# sayacin gosterecegi porsiyon: yoldaki dilimler inene kadar yukari saymaz
func f_sayacPorsiyon(raw: float) -> float:
	return maxf(0.0, raw - kd_bekleyen)

# ucan dilimin merkezi (mantik piksel) ve donus acisi; t < 0 ise henuz kalkmadi (null)
# zipla: kesik yuzden o anki sira yerine (hedef canli: tahta kisaldikca kesik yuz kayar), kap: pile'dan kabin icine
func f_dilimKonum(c: Dictionary) -> Variant:
	var k := clampf(float(c.t) / float(c.dur), 0.0, 1.0)
	if float(c.t) < 0.0: return null
	var x1: float = float(c.x1)
	var y1: float = float(c.y1)
	if c.tur == "zipla":
		var hedef: Vector2 = f_dilimYeri(int(c.i), f_kesikYuzX(float(game.j_G.cut.prog))) + Vector2(1.0, 4.0)
		x1 = hedef.x
		y1 = hedef.y
	var yay: float = 4.0 * k * (1.0 - k) * float(c.yay)
	var x: float = lerpf(float(c.x0), x1, k)
	var y: float = lerpf(float(c.y0), y1, k) - yay
	var aci: float = float(c.aci0) * (1.0 - k) + float(c.spin) * k
	return {"x": x, "y": y, "aci": aci, "k": k}

# dilim i havada mi (tahtadaki yerinde henuz cizilmesin)
func f_dilimHavada(i: int) -> bool:
	for c in kd_ucan:
		if c.tur == "zipla" and int(c.i) == i: return true
	return false

# kanca adi "kesme_efekt" (HD_KAPALI=kesme_efekt): cizimi VE parcaciklari tek basina kapatir (mantik / sayac durumu calismaya devam eder)
func _kdGorunur() -> bool:
	return not game._hd_kapali.has("kesme_efekt")

func _kdIlis(c: Dictionary) -> void:
	# kaba inen dilim: kap sallanir, sayac vurgulanir, kucuk parilti (sabit desen)
	kd_kap = 1.0
	kd_sayac = 1.0
	kd_bekleyen = maxf(0.0, kd_bekleyen - float(c.birim))
	if not _kdGorunur(): return
	game.effects.f_part({"x": float(c.x1), "y": float(c.y1) - 2.0, "vx": 0.0, "vy": -7.0, "life": 0.2, "col": "#fff6c8", "g": 0.0, "sz": 1.0, "type": "star"})

func f_kesimEfektGuncelle(dt: float) -> void:
	if kd_kapali: return
	var C: Dictionary = game.j_G.cut
	kd_vurus += dt
	kd_kap = maxf(0.0, kd_kap - dt / 0.20)
	kd_sayac = maxf(0.0, kd_sayac - dt / 0.30)
	kd_inis = maxf(0.0, kd_inis - dt / 0.18)
	if bool(C.potato):
		# havadaki patates: yercekimi, tavan, inis ezilmesi, yay gibi sonumlenen egim
		if kd_py > 0.0 or kd_pv > 0.0:
			kd_pv -= KD_YER * dt
			kd_py += kd_pv * dt
			if kd_py >= KD_TAVAN:
				kd_py = KD_TAVAN
				kd_pv = minf(kd_pv, 0.0)
			if kd_py <= 0.0:
				if kd_pv < -40.0: kd_inis = 1.0
				kd_py = 0.0
				kd_pv = 0.0
		kd_pa += kd_pw * dt
		kd_pw -= (kd_pa * 90.0 + kd_pw * 9.0) * dt
		if absf(kd_pa) < 0.004 and absf(kd_pw) < 0.06 and kd_py == 0.0:
			kd_pa = 0.0                     # tam durunca kesin 0: dinlenme gorunumune birebir doner
			kd_pw = 0.0
	else:
		kd_py = 0.0
		kd_pv = 0.0
		kd_pa = 0.0
		kd_pw = 0.0
	if bool(C.potato):
		var prog := float(C.prog)
		var n := mini(KD_DILIM, int(floorf(prog * float(KD_DILIM))))
		kd_kesik = f_kesikYuzX(prog)
		var ay: float = float(game.j_ST.cut.y) + KESME_PATATES.y
		if kd_n < 0 or n < kd_n:
			kd_n = n                       # ilk gorus (yukleme) ya da yeni patates: ziplama yok
		elif n > kd_n:
			for j in range(kd_n, n):
				kd_ucan.append({"tur": "zipla", "i": j, "t": 0.0, "dur": KD_ZIPLA, "x0": kd_kesik + 1.0, "y0": ay - 1.0 - kd_py, "x1": 0.0, "y1": 0.0,
					"yay": 8.0 + float(j % 3) * 1.5, "aci0": -1.9 - 0.3 * float(j % 2), "spin": 0.0, "birim": 0.0})
			kd_n = n
	var i := kd_ucan.size() - 1
	while i >= 0:
		var c: Dictionary = kd_ucan[i]
		c.t = float(c.t) + dt
		if float(c.t) >= float(c.dur):
			if c.tur == "kap": _kdIlis(c)
			kd_ucan.remove_at(i)
		i -= 1
	var kapta := false
	for d in kd_ucan:
		if d.tur == "kap": kapta = true
	if not kapta: kd_bekleyen = 0.0     # hicbir dilim yolda degil: sayac tam (kayan nokta artigi kalmasin)

# patates bitti (raw artti): dilimler havaya firlar, celik kaba yagar. verim = eklenen porsiyon (sayac inen dilimle yukari sayar)
func f_kesimTamam(verim: float) -> void:
	if kd_kapali: return
	var c: Dictionary = game.j_ST.cut
	var pk: Vector2 = f_kapNoktasi(c.x, c.y, c.w)
	var kesik: float = kd_kesik if kd_kesik > 0.0 else f_kesikYuzX(0.95)
	var ay: float = float(c.y) + KESME_PATATES.y
	var gorunen := maxi(kd_n, 0)
	kd_ucan = kd_ucan.filter(func(d: Dictionary) -> bool: return d.tur != "zipla")
	for j in KD_DILIM:
		var bas: Vector2 = (f_dilimYeri(j, kesik) + Vector2(1.0, 4.0)) if j < gorunen else Vector2(kesik + 2.0, ay - 1.0 - kd_py)
		var hedef := pk + Vector2(4.0 + float(j % 5) * 2.4, 11.5)
		kd_ucan.append({"tur": "kap", "i": j, "t": -float(j) * KD_ARALIK, "dur": KD_UCUS, "x0": bas.x, "y0": bas.y, "x1": hedef.x, "y1": hedef.y,
			"yay": 13.0 + float(j % 3) * 2.5, "aci0": -0.5 + 0.3 * float(j % 3), "spin": (3.2 + 0.7 * float(j % 4)) * (1.0 if j % 2 == 0 else -1.0), "birim": verim / float(KD_DILIM)})
	kd_bekleyen += verim
	kd_n = -1
	kd_py = 0.0                          # patates bitti: havadaki patates gider (kalan kisim dilimlerle birlikte kaba ucar)
	kd_pv = 0.0
	kd_pa = 0.0
	kd_pw = 0.0
	kd_inis = 0.0
	while kd_ucan.size() > KD_EN_COK:
		var eski: Dictionary = kd_ucan.pop_front()
		if eski.tur == "kap": kd_bekleyen = maxf(0.0, kd_bekleyen - float(eski.birim))
	# kalkis "pof"u: dilimlerin kalktigi yerde parilti + nisasta tozu (sabit desen)
	if not _kdGorunur(): return
	var tx: float = kesik + 8.0
	game.effects.f_part({"x": tx, "y": ay - 4.0, "vx": 0.0, "vy": -4.0, "life": 0.22, "col": "#fff6c8", "g": 0.0, "sz": 2.0, "type": "star"})
	for q in 6:
		var a: float = -PI / 2.0 + (float(q) - 2.5) * 0.42
		game.effects.f_part({"x": tx + (float(q) - 2.5) * 1.5, "y": ay + 1.0, "vx": cos(a) * 20.0, "vy": sin(a) * (26.0 + float(q % 3) * 7.0),
			"life": 0.34, "col": "#f6ecc6" if q % 2 == 0 else "#dcc681", "g": 150.0, "sz": 1.0})

# game.js:1556
func f_potatoTake() -> Variant:
	if (J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) or J.truth(J.getv(game.j_G, "flyP"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Tahtada patates var")
		return null
	J.setv(game.j_G, "flyP", {"t": 0.0, "x0": J.add(J.getv(J.getv(game.j_ST, "potato"), "x"), 14.0), "y0": J.add(J.getv(J.getv(game.j_ST, "potato"), "y"), 8.0), "x1": (J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), (float(J.getv(J.getv(game.j_ST, "cut"), "w")) / float(2.0))) - 6.0), "y1": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 19.0)})
	J.method(game.j_SFX, "sack", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "potato"), "x"), 14.0), J.add(J.getv(J.getv(game.j_ST, "potato"), "y"), 8.0), 4.0, ["#b98b46", "#d8ab63"], {"spMax": 30.0, "up": 12.0})
	return null

# game.js:1564
func f_slashAt() -> Variant:
	var v_c: Variant = null
	var v_mx: Variant = null
	var v_taban: Variant = null
	var v_i: Variant = null
	v_c = J.getv(game.j_G, "cut")
	if (not J.truth(J.getv(v_c, "slash"))):
		J.setv(v_c, "slash", [])
	v_mx = game.potato_system.f_kesikX()
	J.setv(v_c, "yon", ((-J.n(1.0)) if J.eq(J.getv(v_c, "yon"), 1.0) else 1.0))
	v_taban = ((-J.n(0.72)) if J.gt(J.getv(v_c, "yon"), 0.0) else (-J.n(2.42)))
	J.method(J.getv(v_c, "slash"), "push", [{"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(6.0)), 8.0)), "y": J.add(J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 18.0), game.math_utils.f_rnd((-J.n(3.0)), 3.0)), "aci": J.add(v_taban, game.math_utils.f_rnd((-J.n(0.26)), 0.26)), "boy": game.math_utils.f_rnd(24.0, 34.0), "t": 1.0}])
	J.setv(v_c, "sayac", J.add((J.getv(v_c, "sayac") if J.truth(J.getv(v_c, "sayac")) else 0.0), 1.0))
	if J.eq(fmod(J.n(J.getv(v_c, "sayac")), J.n(3.0)), 0.0):
		J.method(J.getv(v_c, "slash"), "push", [{"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(4.0)), 6.0)), "y": J.add(J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 18.0), game.math_utils.f_rnd((-J.n(2.0)), 2.0)), "aci": J.add(((-J.n(2.42)) if J.gt(J.getv(v_c, "yon"), 0.0) else (-J.n(0.72))), game.math_utils.f_rnd((-J.n(0.2)), 0.2)), "boy": game.math_utils.f_rnd(20.0, 28.0), "t": 0.88}])
	while J.gt(J.getv(J.getv(v_c, "slash"), "length"), 8.0):
		J.method(J.getv(v_c, "slash"), "shift", [])
	game.potato_system.f_kesimVurus()
	game.effects.f_shake(0.1)
	J.method(game.j_SFX, "potato", [])
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.effects.f_part({"x": J.add(v_mx, game.math_utils.f_rnd((-J.n(4.0)), 8.0)), "y": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 17.0), "vx": game.math_utils.f_rnd((-J.n(46.0)), 46.0), "vy": game.math_utils.f_rnd((-J.n(58.0)), (-J.n(20.0))), "life": game.math_utils.f_rnd(0.28, 0.5), "col": game.math_utils.f_pick(["#f2e0a8", "#ffe9a3", "#dba53a", "#b98b46"]), "g": 320.0, "sz": 1.0, "floor": J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 25.0), "bounce": 0.2})
		v_i = J.add(v_i, 1.0)
	return null

# game.js:1607
func f_cutClick() -> Variant:
	var v_c: Variant = null
	v_c = J.getv(game.j_G, "cut")
	if (not J.truth(J.getv(v_c, "potato"))):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Önce çuvaldan patates al")
		return null
	J.setv(v_c, "cutting", true)
	J.setv(v_c, "hold", 0.25)
	game.potato_system.f_slashAt()
	return null

# game.js:1613
func f_updateCut(p_dt: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_si: Variant = null
	var v_dt: Variant = p_dt
	v_c = J.getv(game.j_G, "cut")
	if J.gt(J.getv(v_c, "hold"), 0.0):
		J.setv(v_c, "hold", (J.getv(v_c, "hold") - v_dt))
	else:
		J.setv(v_c, "cutting", false)
	if J.truth(J.getv(v_c, "slash")):
		v_si = (J.getv(J.getv(v_c, "slash"), "length") - 1.0)
		while J.ge(v_si, 0.0):
			J.setv(J.getv(J.getv(v_c, "slash"), v_si), "t", (J.getv(J.getv(J.getv(v_c, "slash"), v_si), "t") - (v_dt * 6.5)))
			if J.le(J.getv(J.getv(J.getv(v_c, "slash"), v_si), "t"), 0.0):
				J.method(J.getv(v_c, "slash"), "splice", [v_si, 1.0])
			v_si = (v_si - 1.0)
	if ((J.truth(J.getv(game.j_IN, "down")) and J.truth(game.f_hitST("cut"))) and J.truth(J.getv(v_c, "potato"))):
		J.setv(v_c, "cutting", true)
		J.setv(v_c, "hold", 0.12)
		J.setv(v_c, "chopT", ((J.getv(v_c, "chopT") if J.truth(J.getv(v_c, "chopT")) else 0.0) - v_dt))
		if J.le(J.getv(v_c, "chopT"), 0.0):
			J.setv(v_c, "chopT", 0.17)
			game.potato_system.f_slashAt()
	if (J.truth(J.getv(v_c, "potato")) and J.truth(J.getv(v_c, "cutting"))):
		J.setv(v_c, "prog", J.add(J.getv(v_c, "prog"), (float(v_dt) / float(J.method(game.j_TUN, "cutTime", [game.j_G])))))
		if J.ge(J.getv(v_c, "prog"), 1.0):
			J.setv(v_c, "prog", 0.0)
			J.setv(v_c, "potato", false)
			J.setv(v_c, "cutting", false)
			J.setv(v_c, "raw", J.add(J.getv(v_c, "raw"), J.method(game.j_TUN, "cutYield", [game.j_G])))
			game.potato_system.f_kesimTamam(float(J.method(game.j_TUN, "cutYield", [game.j_G])))
			game.event_system.f_addTrash(game.j_TRASH_PER_PEEL)
			game.event_system.f_copaAt(J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), (float(J.getv(J.getv(game.j_ST, "cut"), "w")) / float(2.0))), J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 16.0), ["#b98b46", "#8a6432", "#d8ab63"])
			J.method(game.j_SFX, "drop", [])
			game.effects.f_burst((J.add(J.getv(J.getv(game.j_ST, "cut"), "x"), J.getv(J.getv(game.j_ST, "cut"), "w")) - 10.0), J.add(J.getv(J.getv(game.j_ST, "cut"), "y"), 26.0), 8.0, ["#f2e0a8", "#ffe9a3"], {"spMax": 50.0, "up": 20.0})
			game.equipment_system.f_checkAuto()
	if J.truth(J.method(game.j_TUN, "autoCut", [game.j_G])):
		J.setv(v_c, "autoT", J.add(J.getv(v_c, "autoT"), v_dt))
		if J.gt(J.getv(v_c, "autoT"), 0.35):
			J.setv(v_c, "autoT", 0.0)
			if ((not J.truth(J.getv(v_c, "potato"))) and J.lt(J.getv(v_c, "raw"), (J.method(game.j_TUN, "fryCap", [game.j_G]) * 2.0))):
				J.setv(v_c, "potato", true)
				J.setv(v_c, "prog", 0.0)
				J.method(game.j_SFX, "sack", [])
			else:
				if J.truth(J.getv(v_c, "potato")):
					J.setv(v_c, "cutting", true)
					J.setv(v_c, "hold", 0.2)
					game.potato_system.f_slashAt()
	return null

# game.js:1654
func f_fryerClick() -> Variant:
	var v_f: Variant = null
	var v_n: Variant = null
	v_f = J.getv(game.j_G, "fryer")
	if (J.truth(game.event_system.f_kesintiVarMi()) and not J.eq(J.getv(v_f, "state"), "done")):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Elektrik yok — fritöz çalışmıyor")
		return null
	if J.eq(J.getv(v_f, "state"), "done"):
		game.potato_system.f_fryTake()
		return null
	if J.eq(J.getv(v_f, "state"), "fry"):
		game.session_system.f_say("Kızarıyor…")
		return null
	if J.le(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0):
		J.method(game.j_SFX, "bad", [])
		game.session_system.f_say("Doğranmış patates yok!")
		return null
	v_n = min(J.method(game.j_TUN, "fryCap", [game.j_G]), J.getv(J.getv(game.j_G, "cut"), "raw"))
	J.setv(J.getv(game.j_G, "cut"), "raw", (J.getv(J.getv(game.j_G, "cut"), "raw") - v_n))
	J.setv(v_f, "state", "fry")
	J.setv(v_f, "t", 0.0)
	J.setv(v_f, "dur", J.method(game.j_TUN, "fryTime", [game.j_G]))
	J.setv(v_f, "load", v_n)
	J.setv(v_f, "prog", 0.0)
	J.method(game.j_SFX, "basket", [])
	var b0: Vector2 = f_cubukBaslangic()
	var b1: Vector2 = f_sepetNoktasi()
	J.setv(game.j_G, "flyF", {"t": 0.0, "n": v_n, "x0": b0.x, "y0": b0.y, "x1": b1.x, "y1": b1.y})
	return null

# game.js:1667
func f_fryTake() -> Variant:
	var v_f: Variant = null
	var v_n: Variant = null
	v_f = J.getv(game.j_G, "fryer")
	v_n = min(J.getv(v_f, "load"), (J.method(game.j_TUN, "friesCap", []) - J.getv(game.j_G, "friesTray")))
	J.setv(game.j_G, "friesTray", J.add(J.getv(game.j_G, "friesTray"), v_n))
	J.setv(v_f, "state", "idle")
	J.setv(v_f, "load", 0.0)
	J.setv(v_f, "t", 0.0)
	J.method(game.j_SFX, "drop", [])
	game.effects.f_burst(J.add(J.getv(J.getv(game.j_ST, "fryer"), "x"), 20.0), J.add(J.getv(J.getv(game.j_ST, "fryer"), "y"), 14.0), 10.0, [J.getv(game.j_P, "p0"), J.getv(game.j_P, "p1"), "#fff"], {"spMax": 60.0, "up": 20.0})
	game.equipment_system.f_checkAuto()
	return null

# game.js:1676
func f_updateFryer(p_dt: Variant = null) -> Variant:
	var v_f: Variant = null
	var v_dt: Variant = p_dt
	v_f = J.getv(game.j_G, "fryer")
	if J.truth(game.event_system.f_kesintiVarMi()):
		if J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function"):
			game.f_sndLoop("fry", false)
		return null
	if J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function"):
		game.f_sndLoop("fry", (J.eq(J.getv(game.j_G, "scene"), "play") if J.eq(J.getv(v_f, "state"), "fry") else J.eq(J.getv(v_f, "state"), "fry")))
	J.setv(v_f, "basketY", game.math_utils.f_approach(J.getv(v_f, "basketY"), ((-J.n(5.0)) if J.eq(J.getv(v_f, "state"), "idle") else 7.0), (v_dt * 26.0)))
	if J.eq(J.getv(v_f, "state"), "idle"):
		if ((J.truth(J.method(game.j_TUN, "autoFry", [game.j_G])) and J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0)) and J.lt(J.getv(game.j_G, "friesTray"), J.method(game.j_TUN, "friesCap", []))):
			game.potato_system.f_fryerClick()
		return null
	J.setv(v_f, "t", J.add(J.getv(v_f, "t"), v_dt))
	J.setv(v_f, "prog", game.math_utils.f_clamp((float(J.getv(v_f, "t")) / float(J.getv(v_f, "dur"))), 0.0, 1.0))
	if J.eq(J.getv(v_f, "state"), "fry"):
		if J.truth(game.f_chance((v_dt * 14.0))):
			game.effects.f_part({"x": J.add(J.add(J.getv(J.getv(game.j_ST, "fryer"), "x"), 12.0), game.math_utils.f_rnd(0.0, (J.getv(J.getv(game.j_ST, "fryer"), "w") - 24.0))), "y": J.add(J.getv(J.getv(game.j_ST, "fryer"), "y"), 20.0), "vx": game.math_utils.f_rnd((-J.n(4.0)), 4.0), "vy": game.math_utils.f_rnd((-J.n(20.0)), (-J.n(8.0))), "life": 0.55, "col": "rgba(255,240,200,.45)", "g": (-J.n(14.0)), "sz": 1.0})
		if (not (J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function") and J.truth(game.f_sndLoop("fry", true)))):
			J.setv(v_f, "sz", J.add((J.getv(v_f, "sz") if J.truth(J.getv(v_f, "sz")) else 0.0), v_dt))
			if J.gt(J.getv(v_f, "sz"), 1.4):
				J.setv(v_f, "sz", 0.0)
				J.method(game.j_SFX, "fry", [])
	if (J.eq(J.getv(v_f, "state"), "fry") and J.ge(J.getv(v_f, "t"), J.getv(v_f, "dur"))):
		J.setv(v_f, "state", "done")
		J.method(game.j_SFX, "bell", [])
	if (J.eq(J.getv(v_f, "state"), "done") and J.truth(J.method(game.j_TUN, "autoFry", [game.j_G]))):
		game.potato_system.f_fryTake()
	return null

