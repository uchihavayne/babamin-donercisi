# Panel / mola gecisleri (akicilik cilasi: "mola menusu ve butun paneller sert kesmeyle aciliyor, kapaniyor").
# SALT GORSEL: oyun durumu (G), rastgele sayi, girdi ve vurus testleri degismez; butun durum bu modulun
# alanlarindadir (kaydedilmez).
#
#  1) KARARTMA - panellerin (mola, ses, rekor, basarim, sube, borc, kisisellestirme, defter) ve baslik ekraninin
#     arka plan karartmasi tek yerden (f_dim) cizilir. Gorunen opaklik, istenen degere sabit sureli yumusak bir
#     gecisle varir: acilista 0'dan, paneller arasi gecista eski degerden yenisine. Kapanista f_son() karartmayi
#     sonene kadar soldurur. Sahne degisince (mola <-> oyun disinda) karartma sifirlanir: baska sahnelerin kendi
#     karartmasi vardir, onceki sahnenin karartmasi yeni sahneye sizmaz (f_tick).
#  2) PANEL GIRISI - panel govdesi (f_basla / f_bitir) acilista beliriverip ustten suzulur ve hafif sekerek
#     oturur. Yalniz oteleme kullanilir (HD parcalar korunur; olcek yok) ve yalniz CIZIM kayar: tiklama /
#     hedef dikdortgenleri ayni kalir, yani girdi hemen son konumdadir. Belirme, GpuCanvas.grup_basla ile
#     panelin tum cizim ogelerinin toplu opakligidir (CPU tuvalinde belirme yoktur, yalniz kayma).
#
# Gecis bitince cizim eski (sert kesmeli) cizimle BIRE BIR aynidir: f_dim son durumda tam hedef opaklikla,
# f_basla sifir otelemeyle (hic save / translate yapmadan) calisir. Kanca adi "panel_gecis":
# HD_KAPALI=panel_gecis (ya da kapali_zorla) eski sert kesmeyi geri getirir. f_tick hic cagrilmadiysa
# (dogrudan cizim yapan arac / test) gecis olmaz, her sey anlik cizilir.
extends "res://scripts/core/game_module.gd"

const DIM_ACIL := 0.16    # karartmanin acilis suresi (sn)
const DIM_KAPA := 0.12    # karartmanin sonme suresi (sn)
const PANEL_SURE := 0.20  # panel girisi: kayma suresi (sn)
const PANEL_SOLUK := 0.12 # panel girisi: belirme suresi (sn; kayma bitmeden tamamlanir)
const PANEL_BAS_A := 0.15 # ilk karedeki opaklik (paneller arasi gecista bir kare bos kalmasin)
const PANEL_OFS := 14.0   # panelin basladigi yukseklik farki (mantiksal px)

var kapali_zorla := false

var _kare := 0            # f_tick sayaci (0: hic tick yok -> her sey anlik)
var _dt := 0.0            # bu karenin suresi
var _sahne := ""          # onceki karedeki sahne
var _snap := false        # sahne degisti: bu karedeki ilk f_dim anlik oturur
# karartma
var _gor := 0.0           # gorunen opaklik
var _hedef := 0.0         # animasyonun hedefi
var _bas := 0.0           # animasyonun basladigi deger
var _t := 1.0             # animasyon ilerlemesi (sn)
var _sure := DIM_ACIL
var _renk := "#0d0a08"
var _adim_kare := -1      # animasyonun son ilerledigi kare
var _cagrildi := false    # bu karede f_dim cagrildi
# panel
var _pk := ""             # panel kimligi
var _pt := 99.0           # panel girisi ilerlemesi (sn)
var _p_kare := -9         # panelin son cizildigi kare
var _p_derin := 0         # ic ice f_basla sayaci (yalniz en distaki kayar)
var _kayma := 0.0         # su an uygulanan dikey oteleme (px)
var _kayma_son := 0.0     # son f_basla'nin hesapladigi kayma (f_bitir sonrasi da kalir; test / izleme)
var _kayma_acik := false  # f_basla bir save / translate yapti mi
var _grup_acik := false   # f_basla bir grup opakligi acti mi

func kapali() -> bool:
	return kapali_zorla or game._hd_kapali.has("panel_gecis")

# kare basi: oyun dongusu (core/game_loop.gd f_frame) her karede bir kez cagirir
func f_tick(dt: float) -> void:
	_kare += 1
	_dt = maxf(dt, 0.0)
	_cagrildi = false
	var s: String = str(game.j_G.scene) if game.j_G != null else ""
	if s != _sahne:
		# mola <-> oyun ayni goruntunun uzantisidir (karartma sureklidir); baska her gecis yeni bir ekrandir
		var cift: bool = (s == "play" and _sahne == "pause") or (s == "pause" and _sahne == "play")
		if not cift:
			_gor = 0.0
			_hedef = 0.0
			_t = _sure
			_snap = true
		_sahne = s

# ---------------------------------------------------------------- karartma
func _ilerle(hedef: float) -> void:
	if _adim_kare == _kare: return
	_adim_kare = _kare
	if _snap or _kare == 0 or kapali():
		_gor = hedef
		_hedef = hedef
		_t = _sure
		return
	if hedef != _hedef:
		_bas = _gor
		_hedef = hedef
		_t = 0.0
		_sure = DIM_ACIL if hedef > _gor else DIM_KAPA
	if _t < _sure:
		_t = minf(_t + _dt, _sure)
		if _t >= _sure:
			_gor = _hedef
		else:
			var p: float = _t / _sure
			_gor = _bas + (_hedef - _bas) * (1.0 - (1.0 - p) * (1.0 - p))

# tam ekran karartma (eski: globalAlpha = a; f_fr(0, 0, W, H, renk); globalAlpha = 1)
func f_dim(a: float, renk: String) -> void:
	_cagrildi = true
	_renk = renk
	if kapali() or _kare == 0:
		# eski sert kesme: hedef opaklik hemen (durum da hedefte tutulur)
		_gor = a
		_hedef = a
		_t = _sure
		_adim_kare = _kare
		_ciz(a)
		return
	_ilerle(a)
	_ciz(a * (_gor / _hedef if _hedef > 0.0 else 1.0))

# f_dim panel govdesinin DISINDA (f_basla'dan once) cagrilmali: tam ekran karartma panelle birlikte kaymaz
func _ciz(a: float) -> void:
	if a <= 0.0: return
	var ctx: Variant = game.j_ctx
	J.setv(ctx, "globalAlpha", a)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, _renk)
	J.setv(ctx, "globalAlpha", 1.0)

# kare sonu (sahne cizildikten sonra): karartma bu karede cizilmediyse sonmesini surdurur
func f_son() -> void:
	_snap = false
	if _cagrildi: return
	if kapali() or _kare == 0:
		_gor = 0.0
		_hedef = 0.0
		_t = _sure
		return
	_ilerle(0.0)
	_ciz(_gor)

# ---------------------------------------------------------------- panel girisi
func _kayma_hesapla(t: float) -> float:
	if t >= PANEL_SURE: return 0.0
	var e: float = float(game.math_utils.f_easeOutBack(t / PANEL_SURE))
	return roundf(-PANEL_OFS * (1.0 - e))

func _belirme_hesapla(t: float) -> float:
	if t >= PANEL_SOLUK: return 1.0
	return PANEL_BAS_A + (1.0 - PANEL_BAS_A) * float(game.math_utils.f_easeOut(t / PANEL_SOLUK))

# panel govdesini cizmeden once cagrilir (karartma disarida kalmali: once f_dim, sonra f_basla)
func f_basla(kimlik: String) -> void:
	_p_derin += 1
	if _p_derin > 1: return
	if kapali() or _kare == 0:
		_kayma_son = 0.0
		return
	if kimlik != _pk or _kare - _p_kare > 1:
		_pk = kimlik
		_pt = 0.0
	elif _p_kare != _kare:
		_pt += _dt
	_p_kare = _kare
	var k: float = _kayma_hesapla(_pt)
	var a: float = _belirme_hesapla(_pt)
	_kayma_son = k
	if k == 0.0 and a >= 1.0: return
	var ctx: Variant = game.j_ctx
	J.method(ctx, "save", [])
	J.method(ctx, "translate", [0.0, k])
	_kayma = k
	_kayma_acik = true
	if a < 1.0 and ctx.has_method("grup_basla"):
		ctx.grup_basla(a)
		_grup_acik = true

func f_bitir() -> void:
	_p_derin = maxi(_p_derin - 1, 0)
	if _p_derin > 0 or not _kayma_acik: return
	var ctx: Variant = game.j_ctx
	if _grup_acik:
		ctx.grup_bitir()
		_grup_acik = false
	J.method(ctx, "restore", [])
	_kayma = 0.0
	_kayma_acik = false
