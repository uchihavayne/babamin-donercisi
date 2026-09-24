# REMAKE GORSELLERI
#
# Aktarilmis game.gd'nin cizim fonksiyonlarina takilan yeni (Blender + shader)
# cizimler. Sinif zinciri:
#   pixel_primitives.gd -> native_platform.gd -> remake_gorsel.gd -> game.gd
# game.gd'de yalniz kisa kanca satirlari var ("if f_sisHD(...)"): eski
# prosedurel cizim kanca false dondururse AYNEN calisir. Boylece her alan
# tek tek yenilenir, yarim kalan alan eski haliyle oynanabilir kalir.
#
# F2: yeni / eski gorsel arasinda gec (gelistirme ve karsilastirma icin).
extends "res://scripts/native_platform.gd"

const SIS_SHADER := preload("res://shaders/sis.gdshader")

# HD acik/kapali (F2). Degisince pisirilmis katmanlar atilir: GPU pisirme
# dokusu CPU tuvaline kopyalanamaz, eski yol yeniden pisirsin.
var hd_acik := true:
	set(v):
		if hd_acik == v: return
		hd_acik = v
		if get("screen_canvas") is GpuCanvas: get("screen_canvas").olcek_hd = v
		for ad in ["j_BG", "j_WINOVER", "j_STONEFG", "j_CLAYER"]:
			set(ad, null)
		var shop: Variant = get("j_SHOP")
		if shop is Dictionary: shop.bake = null
var _sis_mat: ShaderMaterial

# platform_game._input bunu ilk is cagirir (super zinciri yok); true = tuketildi
func hd_tus(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		hd_acik = not hd_acik
		print("REMAKE gorseller: ", "ACIK" if hd_acik else "KAPALI (eski cizim)")
		return true
	return false

# BIRLESIK SURUM: oyun fonksiyonlari modullere dagitildi (game.<modul>.f_x).
# _c("f_x", ...) once oyun nesnesinde arar (ozellestirilmis/sanal girisler:
# game.gd ve alt siniflari), yoksa modullerde; bulunan hedef onbellege alinir.
const _YOK := &"__yok__"
var _c_hedef: Dictionary = {}

func _c(ad: String, a0: Variant = _YOK, a1: Variant = _YOK, a2: Variant = _YOK, a3: Variant = _YOK, a4: Variant = _YOK, a5: Variant = _YOK, a6: Variant = _YOK, a7: Variant = _YOK, a8: Variant = _YOK, a9: Variant = _YOK) -> Variant:
	var args: Array = []
	for v in [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9]:
		if v is StringName and v == _YOK: break
		args.append(v)
	return c_hedef(ad).callv(ad, args)

func c_hedef(ad: String) -> Object:
	var h: Variant = _c_hedef.get(ad)
	if h != null: return h
	if has_method(ad): h = self
	else:
		for p in get_property_list():
			if not (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
			var o: Variant = get(p.name)
			if o is RefCounted and o.has_method(ad) and o.get("game") == self:
				h = o
				break
	if h == null:
		push_error("HD: fonksiyon bulunamadi: " + ad)
		h = self
	_c_hedef[ad] = h
	return h

# ---------------------------------------------------------------- HD atlas
# assets/remake/<ad>/atlas.png + atlas.json (blender/hd_atlas.py uretir)
var _atlaslar: Dictionary = {}

func atlas(ad: String) -> Dictionary:
	if _atlaslar.has(ad): return _atlaslar[ad]
	var kok := "res://assets/remake/%s/" % ad
	var veri: Variant = null
	if FileAccess.file_exists(kok + "atlas.json"):
		veri = JSON.parse_string(FileAccess.get_file_as_string(kok + "atlas.json"))
	var tex: Texture2D = load(kok + "atlas.png") if ResourceLoader.exists(kok + "atlas.png") else null
	var A: Dictionary = {}
	if veri is Dictionary and tex != null:
		A = {"tex": tex, "parca": veri.parca, "hd": float(veri.hd)}
	_atlaslar[ad] = A
	return A

# Atlas parcasini, capa noktasi (x, y)'ye gore ciz. dx/dy mantik pikseli
# (blender/hd_atlas.py: kirpilmis parcanin capaya gore konumu).
func hd_ciz(A: Dictionary, ad: String, x: float, y: float, alpha: float = 1.0, ayna: bool = false, renk: Color = Color.WHITE, dikey: float = 1.0) -> void:
	var p: Variant = A.parca.get(ad)
	if p == null: return
	# ayna: parca CAPANIN dikey ekseni etrafinda cevrilir (kendi kutusunun
	# ortasinda degil); asimetrik parcalar (biber) yoksa kayar
	var lx: float = (x - p[4] - p[2] / float(A.hd)) if ayna else (x + p[4])
	if absf(dikey - 1.0) > .001:
		draw_context.texture_hd_y(A.tex, Rect2(p[0], p[1], p[2], p[3]), lx, y + p[5], dikey, alpha, ayna, renk)
		return
	draw_context.texture_hd(A.tex, Rect2(p[0], p[1], p[2], p[3]), lx, y + p[5], alpha, ayna, renk)

func hd_gpu() -> bool:
	return hd_acik and draw_context is GpuCanvas

# Hata ayiklama: HD_KAPALI=patates,et ortam degiskeniyle tek tek kancalar kapanir
var _hd_kapali: PackedStringArray = OS.get_environment("HD_KAPALI").split(",", false)
func hd(ad: String) -> bool:
	return hd_acik and draw_context is GpuCanvas and not _hd_kapali.has(ad) and _duz()

# texture_hd yalniz oteleme (+ yatay ayna) biliyor. Donen ya da olcekli ctx
# icinde (ucan et, elde tutulan yiyecek...) HD parca yanlis yere/boya cizilir:
# oralarda eski cizim calissin.
func _duz() -> bool:
	var t: Transform2D = draw_context.transform
	return absf(absf(t.x.x) - 1.0) < .001 and absf(t.y.y - 1.0) < .001 and absf(t.x.y) < .001 and absf(t.y.x) < .001

# Olcek varyantli parcalar icin (durum, tabak): donmesiz, esit olcekli ctx
func hd_olcekli(ad: String) -> bool:
	if not (hd_acik and draw_context is GpuCanvas) or _hd_kapali.has(ad): return false
	var t: Transform2D = draw_context.transform
	return t.x.x > 0 and absf(t.x.x - t.y.y) < .001 and absf(t.x.y) < .001 and absf(t.y.x) < .001

# dizideki en yakin deger (varyant secimi: parcanin boyu -> hazir boylardan biri)
static func en_yakin(dizi: Array, v: float) -> int:
	var en: int = dizi[0]
	for d in dizi:
		if absf(float(d) - v) < absf(float(en) - v): en = d
	return en

# ---------------------------------------------------------------- dayi
# chars.js drawChef'in canliligi AYNEN: butun hareketler t'den turetilir,
# ayrica durum tutulmaz. Blender katmanlari (blender/models/dayi_hd.py)
# orijinal cizim sirasiyla ust uste konur: golge, bacak, govde, kollar,
# boyun, kafa (+ kafa donusu), fes, puskul, kaslar, gozler, burun, allik,
# biyik, agiz. Oyunda kullanilan modlar: idle, slice, happy.
func f_dayiHD(x: Variant, y: Variant, st: Variant, t: Variant) -> bool:
	if not hd_acik or not (draw_context is GpuCanvas): return false
	# BIRLESIK: yeni tezgahta Dayi servis bolmesinde 0.82 olcekli ciziliyor;
	# o olcekte ayrica render edilmis atlas (dayi_hd.py DAYI_OLCEK=0.82)
	var sx: float = draw_context.transform.x.x
	var A: Dictionary
	if absf(sx - 1.0) < .001: A = atlas("dayi")
	elif absf(sx - 0.82) < .001: A = atlas("dayi82")
	else: return false
	if A.is_empty(): return false
	var tt: float = J.n(t)
	var mod := str(J.getv(st, "mode"))
	var zipla := -absf(sin(tt * 7.0)) * 3.0 if mod == "happy" else 0.0
	var dongu := fposmod(tt, 7.4) / 7.4
	var jest_tip := int(fposmod(floor(tt / 7.4), 3.0))
	var jest_var := mod == "idle" and jest_tip < 2 and dongu > .55 and dongu < .82
	var jest_k := sin((dongu - .55) / .27 * PI) if jest_var else 0.0
	# BEKLEME (birlesik surum, kullanici: "saga sola kayiyor, titriyor"):
	# eskiden BUTUN govde (ayaklar dahil) tam piksel adimlarla +-1.3 kayip
	# +-1 inip kalkiyordu. Simdi ayaklar yerde sabit; nefes yalniz ust govdeyi
	# 0..1 px kaldirir, agirlik aktarimi +-0.5 px, bas nefesi hafif gecikmeyle
	# izler; hepsi yarim piksel (HD) adimli.
	var nefes := sin(tt * 1.6) * 0.5 + 0.5
	var nefes_bas := sin(tt * 1.6 - 0.7) * 0.5 + 0.5
	var lx: float = J.n(x)
	var ly: float = J.n(y) + floor(zipla + .5)
	var ox: float = lx + f_hdYarimPx(sin(tt * .52) * 0.5)
	var oy: float = ly - f_hdYarimPx(nefes)
	var kafa_don: float = f_hdYarimPx(sin(tt * .43) * 0.8)
	var kafa_y: float = ly - f_hdYarimPx(nefes_bas)
	# golge (yari saydam elips, eski cizimle ayni)
	draw_context.globalAlpha = 0.32
	f_ell(lx + 23.0, ly + 152.0, 21.0, 4.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "bacak", lx, ly)
	hd_ciz(A, "govde", ox, oy)
	# BIRLESIK: doneri oyuncu keser; Dayi kesime yardim etmez (kullanici). Eskiden
	# "slice" modunda havada bicak sallar gibi kol oynatiyordu ("doneri
	# kesmiyormus gibi hareket"). Artik kesim sirasinda bekleme pozunda durur,
	# jest yapmaz, gozleriyle sise bakar.
	match mod:
		"slice":
			hd_ciz(A, "kol_sol_bosta", ox, oy)
			hd_ciz(A, "kol_sag_bosta", ox, oy)
		"happy":
			hd_ciz(A, "kol_sol_mutlu", ox, oy)
			hd_ciz(A, "kol_sag_mutlu", ox, oy)
		_:
			hd_ciz(A, "kol_sol_bosta", ox, oy)
			var n := clampi(roundi(jest_k * 8.0), 0, 8)
			if n == 0: hd_ciz(A, "kol_sag_bosta", ox, oy)
			else: hd_ciz(A, "kol_sag_jest_%s_%d" % ["fes" if jest_tip == 1 else "biyik", n], ox, oy)
	hd_ciz(A, "boyun", ox, oy)
	var kx: float = ox + kafa_don
	hd_ciz(A, "kafa", kx, kafa_y)
	hd_ciz(A, "fes", kx, kafa_y)
	hd_ciz(A, "puskul_%d" % clampi(roundi(sin(tt * 2.2) * 3.0) + 3, 0, 6), kx, kafa_y)
	var kas_kalk := mod == "happy" or roundi(jest_k) >= 1
	hd_ciz(A, "kas_ust" if kas_kalk else "kas", kx, kafa_y)
	# eski: 0.77 sn'lik pencerenin tamaminda kapali. HD: basinda kisa kirpma
	# (yari -> kapali -> yari); pencere secimi ayni.
	var kirp_faz := fposmod(tt * 1.3, 1.0)
	var kirp: bool = J.n(f_hash1(floor(tt * 1.3))) > .90 and kirp_faz < 0.22 and A.parca.has("goz_yari")
	if kirp and kirp_faz >= 0.05 and kirp_faz < 0.15:
		hd_ciz(A, "goz_kapali", kx, kafa_y)
	elif kirp:
		hd_ciz(A, "goz_yari", kx, kafa_y)
	elif J.n(f_hash1(floor(tt * 1.3))) > .90 and not A.parca.has("goz_yari"):
		hd_ciz(A, "goz_kapali", kx, kafa_y)
	else:
		var bak := 1 if mod == "slice" or sin(tt * .6) > 0.0 else 0
		hd_ciz(A, "goz_acik_%d" % bak, kx, kafa_y)
	hd_ciz(A, "burun", kx, kafa_y)
	hd_ciz(A, "allik", kx, kafa_y)
	hd_ciz(A, "biyik", kx, kafa_y)
	hd_ciz(A, "agiz_mutlu" if mod == "happy" else "agiz", kx, kafa_y)
	return true

# ---------------------------------------------------------------- doner sisi
# art.js drawSpit'teki et konisi + taze kesim yuzu. Mil, isitici, tepe
# domatesi, alt tabla ve bicak simdilik eski cizim (sonraki adimlar).
func f_sisHD(sp: Variant, cx: Variant, cone_top: Variant, cone_h: Variant) -> bool:
	if not hd_acik or not (draw_context is GpuCanvas):
		return false
	if _sis_mat == null:
		_sis_mat = ShaderMaterial.new()
		_sis_mat.shader = SIS_SHADER
		_sis_mat.set_shader_parameter("doku", load("res://assets/remake/sis/sis_doku.png"))
		_sis_mat.set_shader_parameter("yukseklik", load("res://assets/remake/sis/sis_yukseklik.png"))
	var params := Color(
		clampf(J.n(sp.mass), 0.0, 1.0),
		clampf(J.n(sp.roast) / 1.5, 0.0, 1.0),
		fposmod(J.n(sp.rot), TAU) / TAU,
		clampf(J.n(sp.cutDepth) / 20.0, 0.0, 1.0))
	_sis_mat.set_shader_parameter("mono", draw_context.mono)
	draw_context.shader_quad(J.n(cx) - 23.0, J.n(cone_top) - 1.0, 47.0, J.n(cone_h) + 2.0,
		_sis_mat.get_rid(), params)
	_sis_damla(J.n(cx), J.n(cone_top), J.n(cone_h), clampf(J.n(sp.mass), 0.0, 1.0))
	return true

# Konin alt kivrimindan tablaya ara sira dusen yag damlasi (ortam canliligi).
# Tabla sisten SONRA cizildigi icin damla tabla kenarinin arkasinda kaybolur.
# Zamana ve sabit hash'e bagli: oyunun rastgele ureticisine dokunmaz.
func _sis_damla(cx: float, top: float, h: float, kutle: float) -> void:
	var G: Variant = get("j_G")
	var T: float = J.n(G.get("t", 0.0)) if G is Dictionary else 0.0
	var ctx: GpuCanvas = draw_context
	for d in 2:
		var dongu := 2.3 + d * 0.9
		var no := floorf((T + d * 1.1) / dongu)
		var k := fposmod(T + d * 1.1, dongu)
		if k > 0.5: continue
		var h1 := fposmod(sin((no + d * 7.0) * 12.9898) * 43758.5453, 1.0)
		var ty := 0.74 + h1 * 0.1
		var r := 19.0 * (0.45 + 0.55 * kutle) * maxf(0.1, 1.0 - pow((ty - 0.62) / 0.38, 2.0) * 0.9)
		var x := cx + (-1.0 if d == 0 else 1.0) * (r - 1.0)
		var y0 := top + ty * h
		var y := y0 + 0.5 * 150.0 * k * k
		var uz := 1.0 + clampf(k * 5.0, 0.0, 1.5)
		ctx.globalAlpha = 0.9
		_hr(x, y, 1.0, uz, "#d88a2e")
		_hr(x, y, 0.5, 0.5, "#fff0c0")
	ctx.globalAlpha = 1.0


# ---------------------------------------------------------------- tepsiler
# art.js trayBase / trayInnerShade / drawTepsiKasasi / drawTepsiCami ve
# fillPaint'in parca cizimleri. Yerlesim algoritmasi (fillPaint) AYNEN
# calisiyor; yalniz govde ve parcalar Blender HD (blender/models/tepsi_hd.py).
# Parca varyanti eski kodun hash formulleriyle seciliyor: ayni k -> ayni
# bicim, ayni yon, ayni ton. Arka siralar golgede (sh), parca basi kizarma
# tonu (_etTon) renk carpani olarak veriliyor.
const KUVETLER := [46, 34, 42]

# tepsi parca adi: eski tezgah WxH28 -> "<on>_W"; yeni tezgah (counter_design)
# 44x32 / 44x27 / 34x27 -> "<on>_WxH"; atlasta yoksa bos
func _kuvet_ad(on: String, w: Variant, h: Variant) -> String:
	var W := int(J.n(w))
	var H := int(J.n(h))
	if H == 28 and W in KUVETLER: return "%s_%d" % [on, W]
	var ad := "%s_%dx%d" % [on, W, H]
	var A := atlas("tepsi")
	return ad if not A.is_empty() and A.parca.has(ad) else ""

func f_hdKuvet(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("kuvet"): return false
	var ad := _kuvet_ad("kuvet", w, h)
	if ad == "": return false
	hd_ciz(atlas("tepsi"), ad, J.n(x), J.n(y))
	return true

func f_hdKuvetGolge(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("golge"): return false
	var ad := _kuvet_ad("golge", w, h)
	if ad == "": return false
	hd_ciz(atlas("tepsi"), ad, J.n(x), J.n(y), 0.16)
	return true

func f_hdKasa(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("kasa") or int(J.n(w)) != 102: return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	draw_context.globalAlpha = 0.30
	f_fr(J.n(x) + 1, J.n(y) + J.n(h), J.n(w), 3, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "kasa_102", J.n(x), J.n(y))
	return true

func f_hdCam(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("cam") or int(J.n(w)) != 102: return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	draw_context.globalAlpha = 0.13
	f_fr(J.n(x) - 1, J.n(y) - 1, J.n(w) + 2, J.n(h) + 2, "#cfe4f2")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "cam_102", J.n(x), J.n(y), 0.22)
	return true

# ucan et ctx.scale(1, don) icinde ciziliyor: dikey olcek HD'de de calissin
func hd_dikey(ad: String) -> bool:
	if not (hd_acik and draw_context is GpuCanvas) or _hd_kapali.has(ad): return false
	var t: Transform2D = draw_context.transform
	return absf(absf(t.x.x) - 1.0) < .001 and t.y.y > .05 and absf(t.x.y) < .001 and absf(t.y.x) < .001

func f_hdEt(x: Variant, y: Variant, sh: Variant, k: Variant, sz: Variant) -> bool:
	if not hd_dikey("et"): return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	var kk: float = J.n(k)
	var s: float = J.n(sz)
	var bicim := int(floor(J.n(f_hash1(kk * 2.71)) * 100.0)) % 10
	var yy: float = J.n(y) + roundf((J.n(f_hash1(kk * 7.9)) - .5) * 3.0)
	var ton: float = 0.92 + J.n(f_hash1(kk * 1.37)) * 0.24
	var ad: String
	var ayna := false
	if bicim < 4:
		ad = "et_duz_%d" % en_yakin([6, 9, 12, 14], 6 + int(s * 8))
		ayna = J.n(f_hash1(kk * 2.3)) > .5
	elif bicim < 7:
		ad = "et_kivrik_%d" % en_yakin([7, 10, 13], 7 + int(s * 6))
		ayna = J.n(f_hash1(kk * 5.9)) > .5
	elif bicim < 9:
		ad = "et_katli_%d" % en_yakin([8, 12], 6 + int(s * 8))
		ayna = J.n(f_hash1(kk * 5.1)) > .5
	else:
		ad = "et_tiknaz_%d" % (7 if s > .5 else 5)
	var m := clampf(J.n(sh) * ton, 0.0, 1.2)
	hd_ciz(A, ad, J.n(x), yy, 1.0, ayna, Color(m, m, m), float(draw_context.transform.y.y))
	return true

func f_hdTursu(x: Variant, y: Variant, sh: Variant, k: Variant, sz: Variant) -> bool:
	if not hd("tursu"): return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	var m := clampf(J.n(sh), 0.0, 1.2)
	hd_ciz(A, "tursu_7" if J.n(sz) > .5 else "tursu_6", roundf(J.n(x)), roundf(J.n(y)), 1.0,
		J.n(f_hash1(J.n(k) * 2.71)) > .5, Color(m, m, m))
	return true

func f_hdPatates(x: Variant, y: Variant, sh: Variant, k: Variant, sz: Variant) -> bool:
	if not hd("patates"): return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	var kk: float = J.n(k)
	var s: float = J.n(sz)
	var ton: float = J.n(f_hash1(kk * 6.1))
	var mod: float = J.n(f_hash1(kk * 3.7))
	var ad: String
	if mod < .38:
		ad = "patates_yatik_%d" % en_yakin([6, 9, 12], 6 + int(s * 7))
	elif mod < .78:
		ad = "patates_%s_%d" % ["sag" if J.n(f_hash1(kk * 8.3)) > .5 else "sol", en_yakin([8, 11], 6 + int(s * 7))]
	else:
		ad = "patates_dik_%d" % en_yakin([6, 9], 4 + int(s * 5))
	var m := clampf(J.n(sh) * (0.86 if ton > .74 else (1.08 if ton < .26 else 1.0)), 0.0, 1.2)
	hd_ciz(A, ad, roundf(J.n(x)), roundf(J.n(y)), 1.0, false, Color(m, m, m))
	return true

func f_hdDomates(x: Variant, y: Variant, r: Variant) -> bool:
	if not hd("domates"): return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	hd_ciz(A, "domates_6", roundf(J.n(x)), roundf(J.n(y)))
	return true

func f_hdBiber(x: Variant, y: Variant, h: Variant, flip: Variant) -> bool:
	if not hd("biber"): return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	var boy := clampi(int(J.n(h) if h != null else 13.0), 12, 14)
	hd_ciz(A, "biber_%d" % boy, J.n(x), J.n(y), 1.0, J.n(flip) < 0)
	return true

func f_hdYogurtTepsi(x: Variant, y: Variant, w: Variant, h: Variant, n: Variant, mx: Variant, t: Variant, fx: Variant) -> bool:
	if not hd("yogurt"): return false
	# eski tezgah 34x28, yeni tezgah (counter_design) 44x32
	var yeni := int(J.n(w)) == 44 and int(J.n(h)) == 32
	if int(J.n(w)) != 34 and not yeni: return false
	var A := atlas("tepsi")
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var f: float = J.n(fx)
	var ek := "_44x32" if yeni else "_34"
	hd_ciz(A, "kuvet" + ek, X, Y)
	if J.n(n) > 0:
		var lvl := clampf(J.n(n) / maxf(1.0, J.n(mx)), 0.0, 1.0)
		var bump := roundf(sin(f * PI) * 2.0)
		hd_ciz(A, ("yogurt_44x32_%d" if yeni else "yogurt_%d") % clampi(roundi(lvl * 8.0), 1, 8), X, Y - bump)
	hd_ciz(A, "golge" + ek, X, Y, 0.16)
	_c("f_trayFlash", x, y, w, h, f)           # game.gd alt sinifta; fx bos gelebilir (fx || 0)
	return true


# ---------------------------------------------------------------- kucuk istasyonlar
# art.js drawBreadStack / drawPideStack / drawPotatoBin / drawSweetTray /
# drawTrash / drawCrate / drawWallCam. Govdeler Blender HD
# (blender/models/istasyon_hd.py); durum (doluluk, cekmece kaymasi, kapak
# sallanmasi, yanip sonme) ve etiket yazilari orijinaldeki gibi kodla.
# RASTGELE CAGRILAR AYNEN KORUNUYOR (cop tozu): cizim oyunun rastgele
# ureticisini tuketiyor, sira degisirse oyun eski surumden sapar.
func _P() -> Dictionary:
	return get("j_P")

func f_hdLavas(x: Variant, y: Variant, w: Variant, h: Variant, label: Variant) -> bool:
	# eski tezgah 42; yeni tezgah (counter_design) 44 -> ortalanir
	if not hd("lavas") or int(J.n(w)) not in [42, 44]: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	hd_ciz(A, "lavas_yigin", J.n(x) + (J.n(w) - 42.0) / 2.0, J.n(y))
	if not (label is String and label == ""):
		_c("f_txt", label if J.truth(label) else "LAVAŞ", J.n(x) + J.n(w) / 2.0, J.n(y) + 30.0,
			"rgba(255,255,255,.55)", {"align": "c", "outline": "rgba(0,0,0,.4)"})
	return true

func f_hdPide(x: Variant, y: Variant, w: Variant) -> bool:
	# eski tezgah 42; yeni tezgah 48 -> ortalanir
	if not hd("pide") or int(J.n(w)) not in [42, 48]: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	hd_ciz(A, "pide_yigin", J.n(x) + (J.n(w) - 42.0) / 2.0, J.n(y))
	return true

func f_hdPatatesDolap(x: Variant, y: Variant, w: Variant, h: Variant, t: Variant) -> bool:
	if not hd("patates_dolap") or int(J.n(w)) != 44 or int(J.n(h)) != 38: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	hd_ciz(A, "patates_dolap", J.n(x), J.n(y))
	return true

func f_hdTatli(x: Variant, y: Variant, w: Variant, h: Variant, n: Variant, mx: Variant, t: Variant, fx: Variant) -> bool:
	if not hd("tatli") or int(J.n(w)) != 34 or int(J.n(h)) != 34: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	hd_ciz(A, "tatli_arka", X, Y)
	var bump := floorf(sin(J.n(fx) * PI) * 2.0 + .5)
	var cnt := mini(4, int(ceil(clampf(J.n(n) / maxf(1.0, J.n(mx)), 0.0, 1.0) * 4.0)))
	for i in cnt:
		var col := i % 2
		var row := i / 2
		hd_ciz(A, "baklava", X + 10 + col * 14, Y + Hh - 22 - row * 8 - bump)
	hd_ciz(A, "tatli_on", X, Y)
	_c("f_txt", "TATLI", X + W / 2.0, Y + Hh - 7, _P().au1, {"align": "c", "outline": "rgba(0,0,0,.6)"})
	return true

func f_hdCop(x: Variant, y: Variant, w: Variant, h: Variant, t: Variant, bosalt: Variant, dolu: Variant) -> bool:
	if not hd("cop") or int(J.n(w)) != 30 or int(J.n(h)) != 28: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	var B: float = J.n(bosalt)
	var d := clampf(J.n(dolu), 0.0, 1.35)
	f_fr(X - 2, Y - 2, W + 4, Hh + 4, "rgba(0,0,0,.30)")
	hd_ciz(A, "cop_govde", X, Y)
	var sal := sin(B * 26.0) * 2.0 if B > 0 else 0.0
	hd_ciz(A, "cop_kapak", X, Y + 4 + floorf(sal + .5))
	if d > .02:
		var yh := floorf((Hh - 10) * minf(1.0, d) + .5)
		var ty := Y + Hh - 3 - yh
		for q in int(yh):
			var ww := W - 6 - floorf(absf(sin(q * .7)) * 2.0 + .5)
			f_fr(X + 3, ty + q, ww, 1, "#6b6258" if q < 2 else "#443e37")
		_c("f_copIcerik", X, Y, W, Hh, minf(1.0, d))
		if d > 1:
			draw_context.globalAlpha = .45 + .3 * sin(J.n(t) * 6.0)
			f_rc(X - 1, Y - 1, W + 2, Hh + 2, _P().bad)
			draw_context.globalAlpha = 1.0
	var V: Dictionary = get("j_VIEW")
	_c("f_txt", "ÇÖP", X + W / 2.0, minf(Y + Hh + 2, J.n(get("j_H")) - J.n(V.bot) - 9),
		"rgba(255,255,255,.42)", {"align": "c", "outline": "rgba(0,0,0,.5)"})
	if B > 0 and J.truth(_c("f_chance", .5)):
		_c("f_part", {"x": X + J.n(_c("f_rnd", 2.0, W - 2)), "y": Y + Hh - 4, "vx": J.n(_c("f_rnd", -8.0, 8.0)),
			"vy": J.n(_c("f_rnd", -18.0, -6.0)), "life": .5, "col": "rgba(120,110,100,.5)", "g": 60.0, "sz": 1.0})
	return true

func f_hdStok(x: Variant, y: Variant, w: Variant, h: Variant, open: Variant, t: Variant, acik: Variant) -> bool:
	if not hd("stok") or int(J.n(w)) != 34 or int(J.n(h)) != 34: return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	var k := clampf(J.n(acik) if acik != null else (1.0 if J.truth(open) else 0.0), 0.0, 1.0)
	var kay := floorf(k * 22.0 + .5)
	hd_ciz(A, "stok_oyuk", X, Y)
	var dx := X - kay
	var dy := Y + 2
	var dw := W
	var dh := Hh - 4
	if kay > 0:
		f_fr(dx + dw, dy + 2, kay, dh - 4, "#4e3a18")
		draw_context.globalAlpha = .35
		f_fr(dx + dw, dy + 2, kay, 3, "#000")
		draw_context.globalAlpha = 1.0
		f_hl(dx + dw, dy + 2, kay, "#6d5228")
	draw_context.globalAlpha = .30
	f_fr(dx + 1, dy + dh, dw, 2, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "stok_cekmece", dx, dy)
	if k > .25:
		hd_ciz(A, "stok_ic", dx, dy, minf(1.0, (k - .25) / .5))
	hd_ciz(A, "stok_onyuz", dx, dy)
	_c("f_txt", "STOK", dx + 5 + (dw - 5) / 2.0, dy + 3, "rgba(255,240,210,.55)", {"align": "c"})
	if k < .1:
		draw_context.globalAlpha = .16 + .12 * sin(J.n(t) * 3.0)
		f_rc(X, Y, W, Hh, _P().au0)
		draw_context.globalAlpha = 1.0
	return true

func f_hdKamera(t: Variant, alert: Variant) -> bool:
	if not hd("kamera"): return false
	var A := atlas("istasyon")
	if A.is_empty(): return false
	hd_ciz(A, "kamera", 424.0, 30.0)
	var on := sin(J.n(t) * 6.0) > 0
	f_disc(436.0, 36.0, 1.0, "#ff4a3a" if on else "#5a2a26")
	if on and J.truth(alert):
		draw_context.globalAlpha = .16
		f_disc(436.0, 36.0, 5.0, "#ff4a3a")
		draw_context.globalAlpha = 1.0
	return true


# ---------------------------------------------------------------- alt tezgah
# servis tahtasi, patates kesme tahtasi, izgara, kagit, sos rafi, patates
# kutusu rafi. Govdeler Blender HD (blender/models/tezgah_hd.py). Oyun
# durumu (patatesin kalan boyu, dilim sayisi, korlar, yuvalar, kagit cikisi,
# sise sikma, kilitler) ve yazilar orijinal art.js akisiyla kodda.
# Rastgele cagrilar (izgara dumani, kagit kirintisi) ayni sirada.
func _tz() -> Dictionary:
	return atlas("tezgah")

func f_hdTahta(golge: bool) -> bool:
	if not hd("tahta"): return false
	var A := _tz()
	if A.is_empty(): return false
	var st: Dictionary = get("j_ST").board
	var X: float = J.n(st.x)
	var Y: float = J.n(st.y)
	# BIRLESIK: yeni tezgahin 150x48 tahtasi (kendi golgesiyle, tezgah2 atlasi)
	if int(J.n(st.w)) == 150:
		var B := atlas("tezgah2")
		if B.is_empty() or not B.parca.has("tahta"): return false
		hd_ciz(B, "tahta", X, Y)
		return true
	if int(J.n(st.w)) != 94: return false
	if golge:
		draw_context.globalAlpha = .3
		f_rrect(X + 3, Y + 10, 90.0, 34.0, 3.0, "#000")
		draw_context.globalAlpha = 1.0
	hd_ciz(A, "tahta", X, Y)
	return true

func f_hdKesme(x: Variant, y: Variant, w: Variant, h: Variant, C: Variant, t: Variant) -> bool:
	if not hd("kesme") or int(J.n(w)) != 48 or int(J.n(h)) != 46: return false
	var A := _tz()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	draw_context.globalAlpha = .3
	f_rrect(X + 3, Y + 8, W - 4, Hh - 12, 3.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "kesme_tahta", X, Y)
	var cx := X + W / 2.0 - 6.0
	if J.truth(J.getv(C, "potato")):
		var prog: float = J.n(J.getv(C, "prog"))
		var pw := int(maxf(2.0, floorf(11.0 * (1.0 - prog) + .5)))
		hd_ciz(A, "patates_%d" % clampi(pw, 2, 11), cx, Y + 20)
		for i in int(floorf(prog * 6.0)):
			hd_ciz(A, "patates_dilim", cx + 8 + i * 3, Y + 16)
		_c("f_drawSlash", C)
		if prog > 0.0 and prog < 1.0:
			_c("f_bar", X + 6, Y - 4, W - 12, 5.0, prog, _P().p1)
	else:
		_c("f_txt", "PATATES", X + W / 2.0, Y + 20, "rgba(60,40,24,.45)", {"align": "c"})
	var bx := X + W - 17
	var by := Y + Hh - 22
	hd_ciz(A, "kesme_kap", X, Y)
	var raw: float = minf(10.0, J.n(J.getv(C, "raw")))
	var r := 0
	while r < raw:
		hd_ciz(A, "cig_cubuk", bx + 2 + (r % 5) * 2.4, by + 9 - floorf(r / 5.0) * 4.0)
		r += 1
	if J.n(J.getv(C, "raw")) > 0:
		_c("f_txt", J.add("", J.getv(C, "raw")), bx + 14, by - 8, "#f8ecc0", {"align": "r", "outline": "rgba(0,0,0,.5)"})
	return true

func f_hdIzgara(x: Variant, y: Variant, w: Variant, h: Variant, Gr: Variant, t: Variant, cap: Variant) -> bool:
	if not hd("izgara") or int(J.n(w)) != 68 or int(J.n(h)) != 46: return false
	var A := _tz()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	var T: float = J.n(t)
	hd_ciz(A, "izgara_govde", X, Y)
	# korlar: cubuklarin ALTINDA yanip sonuyor
	var gy0 := Y + 13
	var gy1 := Y + 24
	for e in 14:
		var ex: float = X + 5 + J.n(f_hash1(e * 3.1)) * (W - 12)
		var ey: float = gy0 + 1 + J.n(f_hash1(e * 7.7)) * (gy1 - gy0 - 3)
		var nabiz := .45 + .35 * sin(T * 3.0 + e * 1.7)
		var E := atlas("efekt")
		if not E.is_empty() and E.parca.has("kor_0"):
			# HD kor: catlakli sicak cekirdek + tintli yumusak hale (ayni nabiz)
			hd_ciz(E, "duman_5", ex + 1.0, ey + 1.0, nabiz * 0.35, false, Color(1.0, 0.42, 0.1))
			hd_ciz(E, "kor_%d" % (e % 3), ex + 1.0, ey + 1.0, nabiz)
		else:
			draw_context.globalAlpha = nabiz
			f_fr(ex, ey, 2.0, 2.0, "#e0500f")
			f_px(ex, ey, "#ff7a2a")
			draw_context.globalAlpha = 1.0
	hd_ciz(A, "izgara_cubuk", X, Y)
	var kap: float = J.n(cap) if J.truth(cap) else 1.0
	var sut := kap if kap <= 2 else 2.0
	var satir := 1.0 if kap <= 2 else 2.0
	var gen := W - 8
	var sy := 0
	while sy < satir:
		var sx := 0
		while sx < sut:
			var n := sy * sut + sx
			if n >= kap: break
			var cx2 := floorf(X + 4 + (gen / sut) * (sx + .5) + .5)
			var cy2 := floorf(Y + (23.0 if satir == 1 else 15.0 + sy * 16.0) + .5)
			var yw := floorf(gen / sut + .5) - 4.0
			var yh := 16.0 if satir == 1 else 13.0
			draw_context.globalAlpha = .3
			f_fr(cx2 - yw / 2.0, cy2 - yh / 2.0, yw, yh, "#000")
			draw_context.globalAlpha = 1.0
			f_rc(cx2 - yw / 2.0, cy2 - yh / 2.0, yw, yh, "#8a929a")
			for e2 in 3:
				draw_context.globalAlpha = .22 + .18 * sin(T * 3.4 + n * 2.1 + e2)
				f_px(cx2 - 4 + e2 * 4, cy2 + (2.0 if e2 % 2 == 1 else -2.0), "#ff7a2a")
				draw_context.globalAlpha = 1.0
			sx += 1
		sy += 1
	_c("f_txt", "IZGARA", X + W / 2.0, Y + Hh - 7, "rgba(255,255,255,.5)", {"align": "c", "outline": "rgba(0,0,0,.45)"})
	var sl = J.getv(Gr, "slots")
	if J.truth(sl) and J.truth(J.getv(sl, "length")) and J.truth(_c("f_chance", .1)):
		_c("f_smoke", X + J.n(_c("f_rnd", 6.0, W - 6)), Y + 10, 1.0, "rgba(255,245,225,.45)")
	return true

func f_hdKagit(x: Variant, y: Variant, w: Variant, h: Variant, level: Variant, busy: Variant, t: Variant) -> bool:
	if not hd("kagit") or int(J.n(w)) != 24 or int(J.n(h)) != 46: return false
	var A := _tz()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	var lv: float = J.n(level)
	var B: float = J.n(busy)
	var T: float = J.n(t)
	if lv == 0.0:
		hd_ciz(A, "kagit_aski", X, Y)
		return true
	var oto := lv >= 2
	var mx := X + 1
	var mw := W - 2
	var my := Y + 8
	var mh := Hh - 12
	draw_context.globalAlpha = .3
	f_fr(mx + 1, my + 2, mw, mh, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "kagit_makine", X, Y)
	if oto:
		hd_ciz(A, "kagit_oto", X, Y)
		var wa := T * 8.0
		f_px(floorf(mx + mw - 5 + cos(wa) * 1.4 + .5), floorf(my - 8 + sin(wa) * 1.4 + .5), "#d3d8de")
	var led := ("#7dff7a" if sin(T * 16.0) > 0 else "#2a6a28") if (B > 0 or oto) else "#7a4040"
	f_disc(mx + mw - 4, my - 3, 1.0, led)
	var kby := my + mh - 11
	var uz := floorf(9.0 * (1.0 - B) + .5) if B > 0 else 0.0
	if uz > 0:
		f_fr(mx + 2, kby + 4, mw - 4, uz, "#b9b3a2")
		f_fr(mx + 2, kby + 4, mw - 5, uz - 1, "#f8f4e8")
		f_hl(mx + 3, kby + 6, mw - 7, "#d8352c")
		if uz > 5:
			f_hl(mx + 3, kby + 9, mw - 7, "#2f5f9e")
		var z2 := 0
		while z2 < mw - 4:
			f_px(mx + 2 + z2, kby + 3 + uz + (1.0 if z2 % 3 == 1 else 0.0), "#cfc9b8")
			z2 += 1
		if J.truth(_c("f_chance", .3)):
			_c("f_part", {"x": mx + J.n(_c("f_rnd", 3.0, mw - 3)), "y": kby + 4, "vx": J.n(_c("f_rnd", -8.0, 8.0)),
				"vy": J.n(_c("f_rnd", -16.0, -4.0)), "life": .3, "col": "#fdfaf0", "g": 90.0, "sz": 1.0})
	if lv >= 2:
		_c("f_txt", "OTO", X + W / 2.0, Y + Hh - 6, _P().ok, {"align": "c", "outline": "rgba(0,0,0,.6)"})
	return true

func f_hdSos(x: Variant, y: Variant, w: Variant, h: Variant, on: Variant, isk: Variant, fx: Variant, t: Variant) -> bool:
	if not hd("sos") or int(J.n(w)) != 48 or int(J.n(h)) != 48: return false
	var A := _tz()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	draw_context.globalAlpha = .28
	f_fr(X + 2, Y + 40, W - 4, 3.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "sos_raf", X, Y)
	draw_context.globalAlpha = .32
	f_fr(X + 1, Y + 6, W - 2, 28.0, "#2a2018")
	draw_context.globalAlpha = 1.0
	var defs: Array = get("j_SAUCE_DEF")
	var boy: Array = get("j_SISE_BOY")
	for i in 3:
		var d: Dictionary = defs[i]
		var S: Dictionary = boy[i]
		var acik := J.truth(isk if i == 2 else on)
		var cx0: float = J.n(_c("f_sauceSlotX", float(i))) + 5.0
		var sq := 0.0
		if J.truth(fx) and J.n(J.getv(fx, d.id)) > 0:
			sq = J.n(J.getv(fx, d.id))
		var lift := floorf(sin(clampf(sq, 0.0, 1.0) * PI) * 5.0 + .5)
		var taban := Y + 34 - lift
		if lift > 0:
			draw_context.globalAlpha = .2
			f_ell(cx0, Y + 35, 6.0, 2.0, "#000")
			draw_context.globalAlpha = 1.0
		if not acik:
			draw_context.globalAlpha = .26
		hd_ciz(A, "sise_%d" % i, cx0, taban)
		var hw := float(int(J.n(S.w)) >> 1)
		if sq > 0:
			var ezy := taban - floorf(J.n(S.gov) * .55 + .5)
			f_fr(cx0 - hw - 2, ezy, J.n(S.w) + 4, 6.0, d.c1)
			f_px(cx0 - hw - 2, ezy, d.c0)
			f_px(cx0 + hw + 1, ezy, d.c0)
		if not acik:
			f_fr(cx0 - 3, taban - 8, 6.0, 5.0, "#8a929b")
			f_rc(cx0 - 2, taban - 12, 4.0, 5.0, "#8a929b")
		draw_context.globalAlpha = 1.0
	_c("f_txt", "SOS", X + W / 2.0, Y + 41, "rgba(255,255,255,.5)", {"align": "c", "outline": "rgba(0,0,0,.5)"})
	return true

func f_hdKutu(x: Variant, y: Variant, w: Variant, h: Variant, ready: Variant, t: Variant) -> bool:
	var yeni := int(J.n(w)) == 46 and int(J.n(h)) == 36
	if not hd("kutu") or (not yeni and (int(J.n(w)) != 38 or int(J.n(h)) != 46)): return false
	var A := _tz()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var Hh: float = J.n(h)
	var cx := X + W / 2.0
	var ry := Y + 5
	draw_context.globalAlpha = .3
	f_fr(X + 2, ry + 11, W - 4, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	if yeni:
		var B := atlas("tezgah2")
		if B.is_empty(): return false
		hd_ciz(B, "kutu_raf_46", X, Y)
	else:
		hd_ciz(A, "kutu_raf", X, Y)
	hd_ciz(A, "kutu_bos", X, Y, .74)
	var n := mini(2, int(J.n(ready)))
	for r in n:
		var fxx := floorf(cx + (0.0 if n == 1 else (-8.0 if r == 0 else 8.0)) + .5)
		_c("f_drawFriesCup", fxx, Y + Hh - 14, "ok", J.n(t) + r)
	if n == 0:
		draw_context.globalAlpha = .22
		f_ell(cx, Y + Hh - 5, 8.0, 2.0, "#000")
		draw_context.globalAlpha = 1.0
	draw_context.globalAlpha = .25
	f_hl(X + 1, Y + Hh - 4, W - 2, "#000")
	draw_context.globalAlpha = 1.0
	return true


# ---------------------------------------------------------------- ust sira makineler
# icecek kasasi + makinesi (yukseltme kademeleri), ayran kazani, fritoz.
# Govdeler Blender HD (blender/models/makine_hd.py). Akislar, ibre, ekran,
# isiklar, yag dalgasi, kabarciklar, sepetteki patates, yazilar kodda;
# rastgele cagrilar (parcacik, duman) orijinal sirada.
func _mk() -> Dictionary:
	return atlas("makine")

func _uv(ad: String) -> float:
	return J.n(_c("f_UV", get("j_G"), ad))

func f_hdIcecekKasa(x: Variant, y: Variant, w: Variant, h: Variant, bolme: Variant, t: Variant) -> bool:
	var b := int(J.n(bolme))
	if not hd("icecek") or int(J.n(w)) != 62 or int(J.n(h)) != 34 or b < 1 or b > 3: return false
	var A := _mk()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	draw_context.globalAlpha = .3
	f_fr(X + 1, Y + 34 + 14, 62.0, 3.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "icecek_kasa_%d" % b, X, Y)
	return true

func f_hdIcecek(x: Variant, y: Variant, w: Variant, h: Variant, D: Variant, t: Variant) -> bool:
	var W := int(J.n(w))
	if not hd("icecek") or int(J.n(h)) != 32 or (W != 62 and W != 34): return false
	var A := _mk()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var T: float = J.n(t)
	var kd := clampf(_uv("drink"), 1.0, 4.0)
	draw_context.globalAlpha = .3
	f_fr(X + 1, Y + 2, W, 32.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "icecek_govde_%d" % W, X, Y)
	# dokulen icecek
	var oY := Y + 2 + 11 + 1
	var oH := 32.0 - (oY - Y) - 4.0
	for m in 2:
		var mx := X + 7 + m * (W - 15)
		var tip := "fanta" if m == 0 else "cola"
		if J.truth(D) and J.truth(J.getv(D, "pours")) and not J.eq(J.getv(J.getv(D, "pours"), tip), null):
			_akis(mx, oY + 7, oH - 8, T, 20.0, "#d8641c" if m == 0 else "#8e1c14", "#f0821c" if m == 0 else "#c0281c", "#ffc070" if m == 0 else "#e8604a")
			if J.truth(_c("f_chance", .4)):
				_c("f_part", {"x": mx, "y": oY + oH - 2, "vx": J.n(_c("f_rnd", -8.0, 8.0)), "vy": J.n(_c("f_rnd", -16.0, -4.0)),
					"life": .3, "col": "#ffb03c" if m == 0 else "#e05a48", "g": 120.0, "sz": 1.0})
	if kd >= 2:
		var sx := X + (W >> 1)
		hd_ciz(A, "icecek_gosterge", sx, Y - 5)
		f_ln(sx, Y - 5, sx + floorf(cos(T * 2.0) * 2.0 + .5), Y - 5 + floorf(sin(T * 2.0) * 2.0 + .5), "#c0281c")
	if kd >= 3:
		hd_ciz(A, "icecek_tank", X - 4, Y)
		hd_ciz(A, "icecek_tank", X + W, Y)
	if kd >= 4:
		var dx := X + (W >> 1) - 8
		hd_ciz(A, "icecek_ekran", dx, Y - 8)
		for d in 5:
			f_px(dx + 3 + d * 2, Y - 6, "#7dff7a" if sin(T * 4.0 + d) > 0 else "#2a6a28")
	return true

func f_hdAyran(x: Variant, y: Variant, w: Variant, h: Variant, n: Variant, mx: Variant, Av: Variant, t: Variant) -> bool:
	var Hh := int(J.n(h))
	if not hd("ayran") or int(J.n(w)) != 28 or (Hh != 40 and Hh != 46): return false
	var A := _mk()
	if A.is_empty(): return false
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var T: float = J.n(t)
	var lvl := clampf(J.n(n) / maxf(1.0, J.n(mx)), 0.0, 1.0)
	var r := 12 if _uv("ayran") >= 2 else 10
	var cx := floorf(X + 14 + .5)
	var by := Y + 8
	var bh := Hh - 18
	draw_context.globalAlpha = .28
	f_ell(cx, by + bh + 4, float(r), 2.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "ayran_%d_%d" % [r, bh], X, Y)
	var ey := by + 5
	var wx := cx - r + 4
	var wy := ey + 11 + 2
	var wh := by + bh - wy - 3
	if wh > 4:
		var fh := maxf(0.0, floorf((wh - 2) * lvl + .5))
		f_fr(wx + 1, wy + 1 + (wh - 2 - fh), 2.0, fh, "#f6f4ea")
		if fh > 1:
			f_px(wx + 1, wy + 1 + (wh - 2 - fh), "#ffffff")
	var tx := cx + r - 7
	var ty := by + bh - 9
	if J.truth(Av) and J.truth(J.getv(Av, "pour")):
		_akis(tx + 1.0, ty + 7, 8.0, T, 22.0, "#d8d4c8", "#f4f2ea", "#ffffff")
		if J.truth(_c("f_chance", .35)):
			_c("f_part", {"x": tx + 1, "y": ty + 15, "vx": J.n(_c("f_rnd", -6.0, 6.0)), "vy": J.n(_c("f_rnd", -14.0, -4.0)),
				"life": .3, "col": "#ffffff", "g": 110.0, "sz": 1.0})
	return true

func f_hdFritoz(x: Variant, y: Variant, w: Variant, h: Variant, F: Variant, t: Variant) -> bool:
	# eski tezgah 58x44; yeni tezgah (counter_design) 51x43 -> "_51" parcalar
	var yeni := int(J.n(w)) == 51 and int(J.n(h)) == 43
	if not hd("fritoz") or (not yeni and (int(J.n(w)) != 58 or int(J.n(h)) != 44)): return false
	var A := _mk()
	if A.is_empty() or (yeni and not A.parca.has("fritoz_govde_51")): return false
	var ek := "_51" if yeni else ""
	var X: float = J.n(x)
	var Y: float = J.n(y)
	var W: float = J.n(w)
	var T: float = J.n(t)
	var P := _P()
	var durum = J.getv(F, "state")
	var vatX := X + 5
	var vatW := W - 10.0
	var vatY := Y + 10
	var vatH := 19.0
	var vatB := vatY + vatH
	var oilY := vatY + 2
	hd_ciz(A, "fritoz_govde" + ek, X, Y)
	for sp in 6:
		f_px(X + 8 + J.n(f_hash1(sp * 2.7)) * (W - 18), Y + 1 + J.n(f_hash1(sp * 5.1)) * 4.0, "rgba(196,164,92,.45)")
	_yag_yuzey(vatX, vatW, oilY, T, "#c9a03a")
	if J.eq(durum, "fry"):
		for b in 12:
			var bx2: float = vatX + 1 + J.n(f_hash1(b * 3.1)) * (vatW - 3)
			var by2 := fmod(T * (18.0 + b * 4.0) + b * 9.0, vatH - 4)
			_kabarcik(bx2, vatB - 1 - by2, "#e6c463")
			if J.truth(_c("f_chance", .006)):
				_c("f_part", {"x": bx2, "y": oilY, "vx": J.n(_c("f_rnd", -4.0, 4.0)), "vy": J.n(_c("f_rnd", -18.0, -8.0)),
					"life": .5, "col": "#ffe9a3", "g": 30.0, "sz": 1.0})
	var fkd := _uv("fryer")
	var bskH := 13.0
	var bskY: float = vatY - 2 + (J.n(J.getv(F, "basketY")) if J.truth(J.getv(F, "basketY")) else 0.0)
	var yarim := float(int(vatW) >> 1)
	var sepetler: Array = [[vatX + 3, yarim - 5], [vatX + yarim + 2, yarim - 5]] if fkd >= 3 else [[vatX + 4, vatW - 8]]
	var load: float = J.n(J.getv(F, "load"))
	var bskX := 0.0
	var bskW := 0.0
	for s in sepetler:
		bskX = s[0]
		bskW = s[1]
		if bskY + bskH < vatB:
			draw_context.globalAlpha = .3
			f_fr(bskX + 1, bskY + bskH, bskW - 2, minf(2.0, vatB - (bskY + bskH)), "#000")
			draw_context.globalAlpha = 1.0
		hd_ciz(A, "fritoz_sepet_%d" % int(bskW), bskX, bskY)
		if load > 0:
			var golden: bool = J.eq(durum, "done") or J.n(J.getv(F, "prog")) > .6
			var fcol: Array = [P.p0, P.p1, P.p2] if golden else ["#f5e3b0", "#e8d59a", "#cbb87e"]
			var kont := "#5a3f10" if golden else "#8d7c52"
			var adet := minf(16.0, 3.0 + load * 2.0)
			var i2 := 0
			while i2 < adet:
				var yat := J.n(f_hash1(i2 * 9.1)) > .45
				var fw := 6.0 if yat else 2.0
				var fh := 2.0 if yat else 4.0
				var fx := bskX + 2 + floorf(J.n(f_hash1(i2 * 1.7)) * ((bskW - 5) - fw))
				var fy := bskY + 3 + floorf(J.n(f_hash1(i2 * 4.3)) * ((bskH - 5) - fh))
				f_fr(fx + 1, fy + 1, fw, fh, kont)
				f_fr(fx, fy, fw, fh, fcol[2])
				f_fr(fx, fy, fw - (1.0 if yat else 0.0), fh - (0.0 if yat else 1.0), fcol[1])
				f_px(fx, fy, fcol[0])
				i2 += 1
		if load > 0 and bskY + bskH < oilY and J.truth(_c("f_chance", .1)):
			_c("f_part", {"x": bskX + J.n(_c("f_rnd", 2.0, bskW - 2)), "y": bskY + bskH, "vx": 0.0, "vy": J.n(_c("f_rnd", 4.0, 12.0)),
				"life": .35, "col": "#c9a03a", "g": 90.0, "sz": 1.0})
		var batUst := maxf(bskY, oilY)
		var batAlt := minf(bskY + bskH, vatB)
		if batAlt > batUst:
			draw_context.globalAlpha = .36
			f_fr(bskX - 1, batUst, bskW + 2, batAlt - batUst, "#c9a03a")
			draw_context.globalAlpha = .32
			f_fr(bskX - 1, batUst, bskW + 2, 1.0, "#ffe9a3")
			draw_context.globalAlpha = 1.0
		if bskY + bskH < vatB - 1:
			draw_context.globalAlpha = .3
			f_fr(bskX, maxf(oilY + 1, bskY + bskH), bskW, minf(3.0, (vatB - 1) - (bskY + bskH)), "#5a3f10")
			draw_context.globalAlpha = 1.0
	_yag_yuzey(vatX, vatW, oilY, T, "#d8b44a")
	if J.eq(durum, "fry"):
		for fb in 6:
			var fbx: float = bskX + 1 + J.n(f_hash1(fb * 7.3)) * (bskW - 2)
			var fby := fmod(T * (22.0 + fb * 5.0) + fb * 13.0, (vatB - oilY) - 2)
			_kabarcik(fbx, vatB - 2 - fby, "#ffe9a3")
	hd_ciz(A, "fritoz_on" + ek, X, Y)
	for s in sepetler:
		hd_ciz(A, "fritoz_sap", s[0] + s[1] - 5, bskY + 1)
	var pY := vatB + 3
	var pX := X + 3
	var pW := W - 6
	var ekran = "OK" if J.eq(durum, "done") else ("180" if J.eq(durum, "idle") else J.add("", maxf(0.0, ceilf(J.n(J.getv(F, "dur")) - J.n(J.getv(F, "t"))))))
	_c("f_txt", ekran, pX + 13, pY + 1, "#7dff7a" if J.eq(durum, "done") else ("#c08040" if J.eq(durum, "idle") else "#ff9a4a"), {"align": "c"})
	var kx := pX + pW - 7
	var ky := pY + 4
	f_ln(kx, ky, kx + cos(T) * 2.0, ky + sin(T) * 2.0, "#2f3740")
	var ledOn: bool = J.eq(durum, "fry")
	f_px(kx - 9, ky, "#ff7a3a" if ledOn else "#4a2a22")
	if ledOn:
		draw_context.globalAlpha = .3
		f_disc(kx - 9, ky, 2.0, "#ff7a3a")
		draw_context.globalAlpha = 1.0
	if J.eq(durum, "fry") and J.truth(_c("f_chance", .07)):
		_c("f_smoke", vatX + J.n(_c("f_rnd", 2.0, vatW - 2)), vatY, 1.0, "rgba(255,240,210,.5)")
	if fkd >= 3:
		hd_ciz(A, "fritoz_bolme" + ek, X, Y)
	if fkd >= 4:
		hd_ciz(A, "fritoz_oto" + ek, X, Y)
		f_disc(vatX + vatW - 4, vatY - 10, 1.0, "#7dff7a" if sin(T * 9.0) > 0 else "#2a6a28")
	return true


# ---------------------------------------------------------------- dukkan arka plani
# ui.js drawShop: arka plan eskiden bir kez CPU tuvaline cizilip piksel piksel
# gri tona cevriliyor (bakeShop), sonra resim olarak basiliyordu. Oyle olunca
# HD gorseller dukkanda hic gorunmuyordu. Simdi her karede canli ve GPU'da,
# ayni ton formulu mono kipinde her ilkele uygulanarak ciziliyor (t = 0: pisirilen
# goruntu gibi duragan).
func f_hdDukkanArka() -> bool:
	if not hd("dukkan") or not hd_gpu(): return false
	f_fr(0, 0, get("j_W"), get("j_H"), "#000")
	draw_context.mono = true
	_c("f_drawShopStatic", 0.0, true)
	draw_context.mono = false
	draw_context.globalAlpha = 1.0
	return true


# ---------------------------------------------------------------- tezgah govdesi
# art.js drawCounter (CLAYER: drawCounterRaw + drawCounterProps bir kez pisirilir).
# HD: renk secenegine (G.custom.counter -> COUNTER_PAL) gore tek Blender parcasi
# (blender/models/govde_hd.py); sol yuvarlatma ve sag tas kemer kesigi parcaya
# orijinal formulle islenmis.
func f_hdTezgahGovde() -> bool:
	if not hd("govde") or not hd_gpu(): return false
	var A := atlas("govde")
	if A.is_empty(): return false
	var G: Dictionary = get("j_G")
	var pal: Array = get("j_COUNTER_PAL")
	var i := 0
	if J.truth(G.get("custom")) and J.truth(G.custom.get("counter")):
		i = int(fposmod(J.n(G.custom.counter), pal.size()))
	hd_ciz(A, "govde_%d" % i, 0.0, 0.0)
	return true


# ---------------------------------------------------------------- durum
# food.js drawWrapOpen / drawWrapRolled icindeki govde parcalari (fonksiyonun
# ORTASINDAKI kancalar). Bu noktada ctx olcekli (servis tahtasi 1/.74/.58,
# izgara .8/.62/.58): Blender parcasi her olcekte ayri render edildi, donusumun
# olcegine en yakin varyant seciliyor (texture_hd konumu olcekliyor, boyutu
# parcanin kendi piksel olcusu). Dolgu, tup animasyonu, isaretler kodda.
# 180/122/90: birlesik surumun yeni tahtasi (1/2/3 urun)
const DURUM_OLCEK := [100, 80, 74, 62, 58, 180, 122, 90, 50]
func _durum_olcek(izinli: Array) -> int:
	var sc := absf(float(draw_context.transform.x.x))
	var en := -1
	var fark := 1.0
	for o in izinli:
		var f := absf(sc - o / 100.0)
		if f < fark:
			fark = f
			en = o
	return en if fark < .025 else -1

func f_hdLavasAcik(cx: Variant, cy: Variant) -> bool:
	if not hd_olcekli("durum"): return false
	var o := _durum_olcek([100, 74, 58, 180, 122, 90])
	if o < 0: return false
	var A := atlas("durum")
	if A.is_empty(): return false
	hd_ciz(A, "durum_acik_%d" % o, J.n(cx), J.n(cy))
	return true

# BIRLESIK: acik durumun malzeme katmanlari (sargi atlasi). Yerlesim yalniz
# oran = sayi / 4'e bagli; 1..4 disi (kesirli / fazlasi) oran 1'de doyar.
const SARGI_OLCEK := [180, 122, 90, 100]

func f_hdSargiUst(tur: String, n: Variant, cx: Variant, cy: Variant) -> bool:
	if not hd_olcekli("sargi"): return false
	var o := _durum_olcek(SARGI_OLCEK)
	if o < 0: return false
	var oran := clampf(J.n(n) / 4.0, 0.0, 1.0)
	var k := roundi(oran * 4.0)
	if k < 1 or absf(oran * 4.0 - k) > .001: return false
	var A := atlas("sargi")
	var ad := "ust_%s_%d_%d" % [tur, k, o]
	if A.is_empty() or not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(cx), J.n(cy))
	return true

# BIRLESIK (3. tur, kullanici: "malzemeler durumun icinde karismiyor, layer
# olarak ust uste biniyor"): et x patates x tursu seviyelerinin her birlesimi
# lavasla TEK 3B sahnede render edildi (blender/models/dolgu_hd.py; atlas
# dolgu<olcek>). Yogurt ve sos etin yigin seviyesine gore ustune dokulur.
# Kesirli miktar bir ust seviyeye yuvarlanir (0 disinda en az 1).
func _sargi_kademe(n: Variant, gerek: Variant) -> int:
	var v := J.n(n)
	if v <= 0.0: return 0
	return clampi(ceili(v / maxf(J.n(gerek), 1.0) * 4.0 - 0.001), 1, 4)

func _dolgu_atlas() -> Dictionary:
	if not hd_olcekli("sargi"): return {}
	var o := _durum_olcek(SARGI_OLCEK)
	if o < 0: return {}
	return atlas("dolgu%d" % o)

func f_hdSargiDolgu(et: Variant, pat: Variant, tur: Variant, cx: Variant, cy: Variant) -> bool:
	var A := _dolgu_atlas()
	if A.is_empty(): return false
	var e := _sargi_kademe(et, get("j_MEAT_NEED"))
	var p := _sargi_kademe(pat, get("j_FRIES_NEED"))
	var t := _sargi_kademe(tur, get("j_PICKLE_NEED"))
	if e + p + t == 0: return true
	var ad := "d_%d_%d_%d" % [e, p, t]
	if not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(cx), J.n(cy))
	return true

func f_hdSargiYogurt(n: Variant, et: Variant, cx: Variant, cy: Variant) -> bool:
	var A := _dolgu_atlas()
	if A.is_empty(): return false
	var ad := "y_%d_%d" % [_sargi_kademe(n, get("j_YOGURT_NEED")), _sargi_kademe(et, get("j_MEAT_NEED"))]
	if not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(cx), J.n(cy))
	return true

func f_hdSargiSosDok(tur: Variant, et: Variant, cx: Variant, cy: Variant) -> bool:
	var A := _dolgu_atlas()
	if A.is_empty(): return false
	var ad := "s_%s_%d" % ["hot" if J.eq(tur, "hot") else "garlic", _sargi_kademe(et, get("j_MEAT_NEED"))]
	if not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(cx), J.n(cy))
	return true

func f_hdSargiSos(tur: Variant, cx: Variant, cy: Variant) -> bool:
	if not hd_olcekli("sargi"): return false
	var o := _durum_olcek(SARGI_OLCEK)
	if o < 0: return false
	var A := atlas("sargi")
	var ad := "ust_sos_%s_%d" % ["hot" if J.eq(tur, "hot") else "garlic", o]
	if A.is_empty() or not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(cx), J.n(cy))
	return true

func f_hdDurumGovde(cx: Variant, cy: Variant, kiz: Variant, yanik: Variant) -> bool:
	if not hd_olcekli("durum"): return false
	var o := _durum_olcek(DURUM_OLCEK)
	if o < 0: return false
	var A := atlas("durum")
	if A.is_empty(): return false
	var kademe := "yanik" if J.truth(yanik) else "k%d" % (int(roundf(clampf(J.n(kiz), 0.0, 1.0) * 5.0)) * 20)
	hd_ciz(A, "durum_%s_%d" % [kademe, o], J.n(cx), J.n(cy))
	return true

# BIRLESIK (6. tur): sarma animasyonunun tupu (durum_hd.durum_tup, TUP_N
# kademe). y: tupun ekrandaki merkezi; golge tupun altina yapisik.
const TUP_N := 10
func f_hdSarmaTup(roll: Variant, cx: Variant, y: Variant, th: Variant, tw: Variant) -> bool:
	if not hd_olcekli("durum"): return false
	var o := _durum_olcek(SARGI_OLCEK)
	if o < 0: return false
	var A := atlas("durum")
	var ad := "durum_tup_%d_%d" % [clampi(roundi(J.n(roll) * TUP_N), 1, TUP_N), o]
	if A.is_empty() or not A.parca.has(ad): return false
	draw_context.globalAlpha = 0.22
	f_ell(J.n(cx) + 0.5, J.n(y) + J.n(th) / 2.0 - 0.6, J.n(tw) / 2.0 - 1.0, 1.4, "#3a2410")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, ad, J.n(cx), J.n(y))
	return true

func f_hdKagitArka(cx: Variant, cy: Variant, po: Variant, pt: Variant) -> bool:
	if not hd_olcekli("durum"): return false
	var o := _durum_olcek(DURUM_OLCEK)
	if o < 0: return false
	var A := atlas("durum")
	if A.is_empty(): return false
	hd_ciz(A, "durum_kagit_arka_%d" % o, J.n(cx), J.n(cy) + J.n(po), 1.0 - J.n(pt) * .3)
	return true

func f_hdKagitOn(cx: Variant, cy: Variant, po: Variant, pt: Variant) -> bool:
	if not hd_olcekli("durum"): return false
	var o := _durum_olcek(DURUM_OLCEK)
	if o < 0: return false
	var A := atlas("durum")
	if A.is_empty(): return false
	hd_ciz(A, "durum_kagit_%d" % o, J.n(cx), floorf(J.n(cy) - 6.5 + J.n(po) + .5) + 6.5, 1.0 - J.n(pt) * .15)
	return true


# ---------------------------------------------------------------- yiyecek kaplari
# food.js drawPlate (tabak govdesi, olcek varyantli; icerik kodda),
# drawFriesCup, drawCup (cam arka/on; icecek seviyesi kodda), drawSweetPlate.
# Blender: blender/models/yiyecek_hd.py
func f_hdTabak(cx: Variant, cy: Variant) -> bool:
	if not hd_olcekli("tabak"): return false
	var o := _durum_olcek([100, 85, 74, 58, 180, 122, 90])
	if o < 0: return false
	var A := atlas("yiyecek")
	if A.is_empty(): return false
	hd_ciz(A, "tabak_%d" % o, J.n(cx), J.n(cy))
	return true

func f_hdPatatesKutusu(cx: Variant, cy: Variant, q: Variant, t: Variant) -> bool:
	if not hd("patates_kutusu"): return false
	var A := atlas("yiyecek")
	if A.is_empty(): return false
	var X: float = J.n(cx)
	var Y: float = J.n(cy)
	draw_context.globalAlpha = .22
	f_ell(X, Y + 9, 8.0, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "patates_kutusu_bos" if J.eq(q, "bos") else "patates_kutusu_ok", X, Y)
	return true

func f_hdKupa(cx: Variant, cy: Variant, kind: Variant, fill: Variant, t: Variant) -> bool:
	if not hd("kupa"): return false
	var A := atlas("yiyecek")
	if A.is_empty(): return false
	var X: float = J.n(cx)
	var Y: float = J.n(cy)
	var P := _P()
	var c0 := "#ffffff"
	var c1 := "#e4e2d8"
	if J.eq(kind, "cola"):
		c0 = "#8a3a20"; c1 = "#4a1c10"
	elif J.eq(kind, "orange") or J.eq(kind, "fanta"):
		c0 = P.or0; c1 = P.or1
	draw_context.globalAlpha = .22
	f_ell(X, Y + 10, 6.0, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "kupa_arka", X, Y)
	var lh := floorf(14.0 * clampf(J.n(fill), 0.0, 1.0) + .5)
	var y2 := 0
	while y2 < lh:
		var w2 := 5.0 + floorf((15 - y2) * .12 + .5)
		f_fr(X - w2 + 1, Y + 8 - y2, w2 * 2 - 2, 1.0, c0 if y2 == lh - 1 else c1)
		y2 += 1
	if lh > 0:
		f_hl(X - 4, Y + 8 - lh + 1, 8.0, c0)
	if J.eq(kind, "cola") and lh > 3:
		# kabarciklar: eski her saniye rastgele yere zipliyordu; HD'de dipten
		# yukari yukselip yuzeyde kaybolur (yarim piksel)
		for b in 4:
			var hb := J.n(f_hash1(b * 3.1))
			var yuk := fposmod(J.n(t) * (5.0 + hb * 4.0) + hb * lh, maxf(1.0, lh - 1.0))
			_kabarcik(X - 3 + b * 2 + sin(J.n(t) * 3.0 + b) * 0.25, Y + 6 - yuk, "#a9713f")
	hd_ciz(A, "kupa_on_kirmizi" if J.eq(kind, "cola") else "kupa_on_mavi", X, Y)
	return true

func f_hdTatliTabagi(cx: Variant, cy: Variant, t: Variant) -> bool:
	if not hd("tatli_tabagi"): return false
	var A := atlas("yiyecek")
	var B := atlas("istasyon")
	if A.is_empty() or B.is_empty(): return false
	var X: float = J.n(cx)
	var Y: float = J.n(cy)
	draw_context.globalAlpha = .22
	f_ell(X, Y + 6, 12.0, 3.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "tatli_tabagi", X, Y)
	for i in 3:
		hd_ciz(B, "baklava", X - 7 + i * 7, Y - 5 - (i % 2) * 2)
	return true


# ---------------------------------------------------------------- musteriler
# chars.js drawCustomer: govde, boyun, eller, kafa, kulak, burun, sac,
# aksesuar (sapka/pusu/bant), biyik, sakal, gozluk Blender HD parcalari
# (blender/models/musteri_hd.py). Parcalar GRI TON KODLU: ayni parca her ten /
# sac / gomlek rengiyle shaders/ton.gdshader uzerinden boyaniyor (CARPAN:
# taban renk x ton*2 = art.js shadeCol; PALET: ten paletinin 4 tonu).
# Yuz ifadesi (kas, goz, agiz), yanak, kirisik, cil, ben, kalip kiyafetleri,
# ofke/sevinc efektleri ve rastgele cagrilar kodda (orijinal sira).
var _ton_carpan: ShaderMaterial = null
var _ton_palet: ShaderMaterial = null

func _ton(kip: int) -> RID:
	if _ton_carpan == null:
		var sh: Shader = load("res://shaders/ton.gdshader")
		_ton_carpan = ShaderMaterial.new()
		_ton_carpan.shader = sh
		_ton_carpan.set_shader_parameter("kip", 0)
		_ton_palet = ShaderMaterial.new()
		_ton_palet.shader = sh
		_ton_palet.set_shader_parameter("kip", 1)
		var skins: Array = get("j_SKINS")
		var img := Image.create(4, skins.size(), false, Image.FORMAT_RGBA8)
		for r in skins.size():
			for c in 4:
				img.set_pixel(c, r, Color.html(skins[r][c]))
		_ton_palet.set_shader_parameter("palet", ImageTexture.create_from_image(img))
		_ton_palet.set_shader_parameter("satirlar", skins.size())
	var m: ShaderMaterial = _ton_palet if kip == 1 else _ton_carpan
	m.set_shader_parameter("mono", draw_context.mono)
	return m.get_rid()

func _ms() -> Dictionary:
	return atlas("musteri")

# ton kodlu parca: kip 0 carpan (renk = taban), kip 1 palet (renk.r = ten satiri)
func hd_ton(A: Dictionary, ad: String, x: float, y: float, kip: int, renk: Color, ayna := false, eksen := 0.0, mat := RID()) -> bool:
	var p: Variant = A.parca.get(ad)
	if p == null: return false
	# ayna: capa + eksen noktasindan gecen dikey eksen etrafinda
	var lx: float = (x + 2.0 * eksen - p[4] - p[2] / float(A.hd)) if ayna else (x + p[4])
	draw_context.texture_hd_mat(A.tex, Rect2(p[0], p[1], p[2], p[3]), lx, y + p[5], mat if mat.is_valid() else _ton(kip), renk, 1.0, ayna)
	return true

func _ten(skin: Variant) -> Color:
	var n: int = (get("j_SKINS") as Array).size()
	return Color(clampf(J.n(skin), 0.0, n - 1.0) / float(n - 1), 0, 0, 1)

func _musteri_hazir(A: Dictionary, adlar: Array) -> bool:
	if A.is_empty(): return false
	for ad in adlar:
		if not A.parca.has(ad): return false
	return true

func f_hdMusteriGovde(x: Variant, by: Variant, bw: Variant, sh: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "govde_%d" % int(J.n(bw))
	if not _musteri_hazir(A, [ad]): return false
	return hd_ton(A, ad, J.n(x), J.n(by), 0, _renk(sh))

func f_hdMusteriEller(x: Variant, by: Variant, bw: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	if not _musteri_hazir(A, ["el"]): return false
	var X: float = J.n(x)
	var Y: float = J.n(by) + 27
	var W: float = J.n(bw)
	hd_ton(A, "el", X - W / 2.0 - 1, Y, 1, _ten(skin))
	hd_ton(A, "el", X + W / 2.0, Y, 1, _ten(skin))
	return true

func f_hdMusteriBoyunAlt(x: Variant, by: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	if not _musteri_hazir(A, ["boyun_alt"]): return false
	return hd_ton(A, "boyun_alt", J.n(x), J.n(by), 1, _ten(skin))

func f_hdMusteriBoyunUst(hx: Variant, hy: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	if not _musteri_hazir(A, ["boyun_ust"]): return false
	return hd_ton(A, "boyun_ust", J.n(hx), J.n(hy), 1, _ten(skin))

func f_hdMusteriKafa(hx: Variant, hy: Variant, sekil: Variant, hw: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "kafa_%d_%d" % [int(J.n(sekil)), int(J.n(hw))]
	if not _musteri_hazir(A, [ad]): return false
	return hd_ton(A, ad, J.n(hx), J.n(hy), 1, _ten(skin))

func f_hdMusteriKulak(hx: Variant, hy: Variant, tip: Variant, kuG: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var k := int(J.n(tip))
	var ad := "kulak_%d" % k
	if not _musteri_hazir(A, [ad]): return false
	var G: float = J.n(kuG) + (1.0 if k == 1 else 0.0)
	hd_ton(A, ad, J.n(hx) - G, J.n(hy) + 2, 1, _ten(skin))
	hd_ton(A, ad, J.n(hx) + G, J.n(hy) + 2, 1, _ten(skin))
	return true

func f_hdMusteriBurun(hx: Variant, fy: Variant, n: Variant, skin: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "burun_%d" % int(J.n(n))
	if not _musteri_hazir(A, [ad]): return false
	return hd_ton(A, ad, J.n(hx), J.n(fy), 1, _ten(skin))

func f_hdMusteriSac(hx: Variant, hy: Variant, hw: Variant, stil: Variant, hc: Variant) -> bool:
	if not hd("musteri"): return false
	var s := int(J.n(stil))
	if s < 0 or s > 10: return false
	var A := _ms()
	var ad := "sac_%d_%d" % [s, int(J.n(hw))]
	if not _musteri_hazir(A, [ad]): return false
	hd_ton(A, ad, J.n(hx), J.n(hy), 0, _renk(hc))
	if s == 2:
		hd_ciz(A, "sac_2p_%d" % int(J.n(hw)), J.n(hx), J.n(hy))
	return true

func f_hdMusteriAks(hx: Variant, hy: Variant, hw: Variant, L: Variant, sh: Variant) -> bool:
	if not hd("musteri"): return false
	var acc = J.getv(L, "acc")
	var A := _ms()
	var G := int(J.n(hw))
	if J.eq(acc, "cap"):
		if not _musteri_hazir(A, ["sapka_%d" % G]): return false
		return hd_ton(A, "sapka_%d" % G, J.n(hx), J.n(hy), 0, _renk(_c("f_shadeCol", sh, .8)))
	if J.eq(acc, "kufiya"):
		if not _musteri_hazir(A, ["pusu_%d" % G]): return false
		hd_ciz(A, "pusu_%d" % G, J.n(hx), J.n(hy))
		return true
	if J.eq(acc, "band"):
		if not _musteri_hazir(A, ["bant_%d" % G]): return false
		hd_ciz(A, "bant_%d" % G, J.n(hx), J.n(hy))
		return true
	return false

func f_hdMusteriBiyik(hx: Variant, fy: Variant, agzU: Variant, byG: Variant, hc: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "biyik_%d" % int(J.n(byG))
	if not _musteri_hazir(A, [ad]): return false
	return hd_ton(A, ad, J.n(hx), J.n(fy) + 6 + J.n(agzU), 0, _renk(hc))

func f_hdMusteriSakal(hx: Variant, hy: Variant, skG: Variant, skA: Variant, hc: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "sakal_%d_%d" % [int(J.n(skG)), int(J.n(skA))]
	if not _musteri_hazir(A, [ad]): return false
	return hd_ton(A, ad, J.n(hx), J.n(hy), 0, _renk(hc))

func f_hdMusteriGozluk(hx: Variant, fy: Variant, tip: Variant, icE: Variant) -> bool:
	if not hd("musteri"): return false
	var A := _ms()
	var ad := "gozluk_%d_%d" % [int(J.n(tip)), int(J.n(icE))]
	if not _musteri_hazir(A, [ad]): return false
	hd_ciz(A, ad, J.n(hx), J.n(fy))
	return true

# ---------------------------------------------------------------- musteri kaliplari
# chars.js drawKalipGovde / drawKalipBas. Blender'da her kiyafet renk
# bolgelerine ayrilmis (blender/models/kalip_hd.py): ana (kalip rengi), sh
# (alttaki gomlek), seri (kalibin seri rengi) CARPAN; ten PALET; sabit NORMAL.
# Bolgeler render'da birbirini holdout ile ortuyor: cizim sirasi serbest.
const KALIP_GOVDE := ["isci", "memur", "ogrenci", "yasli", "turist", "sporcu", "kurye", "sofor"]

func _kalip_katmanlar(A: Dictionary, onek: String, x: float, y: float, renkler: Dictionary, skin: Variant) -> bool:
	var ciz := false
	for b in ["ana", "sh", "seri", "ten", "sabit"]:
		var ad := "%s_%s" % [onek, b]
		if not A.parca.has(ad): continue
		ciz = true
		if b == "sabit":
			hd_ciz(A, ad, x, y)
		elif b == "ten":
			hd_ton(A, ad, x, y, 1, _ten(skin))
		else:
			hd_ton(A, ad, x, y, 0, _renk(renkler[b]))
	return ciz

func f_hdKalipGovde(id: Variant, x: Variant, by: Variant, bw: Variant, sh: Variant, s: Variant, L: Variant) -> bool:
	if not hd("kalip") or not (id is String) or not KALIP_GOVDE.has(id): return false
	var bwi := int(J.n(bw))
	if bwi != 18 and bwi != 26 and bwi != 32: return false
	var A := atlas("kalip")
	if A.is_empty() or not A.parca.has("kg_%s_%d_ana" % [id, bwi]): return false
	var R: Dictionary = get("j_KALIP_RENK")[id]
	var ana = _c("f_kalipAna", id, J.getv(L, "seed"))
	return _kalip_katmanlar(A, "kg_%s_%d" % [id, bwi], J.n(x), J.n(by), {"ana": ana, "sh": sh, "seri": R.seri}, J.getv(L, "skin"))

func f_hdKalipBas(id: Variant, hx: Variant, hy: Variant, hw: Variant, s: Variant, L: Variant) -> bool:
	if not hd("kalip") or not (id is String): return false
	if not ["isci", "turist", "kurye", "sofor"].has(id): return false
	var G := int(J.n(hw))
	var A := atlas("kalip")
	var onek := "kb_%s_%d" % [id, G]
	if A.is_empty() or not (A.parca.has(onek + "_ana") or A.parca.has(onek + "_sabit")): return false
	var R: Dictionary = get("j_KALIP_RENK")[id]
	var seed: float = J.n(J.getv(L, "seed")) if J.truth(J.getv(L, "seed")) else 1.0
	var renk: Variant = "#808080"
	if id == "kurye":
		renk = R.kask[int(floor(J.n(f_hash1(seed * 7.3)) * R.kask.size()))]
	elif id == "sofor":
		renk = R.kasket[int(floor(J.n(f_hash1(seed * 11.9)) * R.kasket.size()))]
	return _kalip_katmanlar(A, onek, J.n(hx), J.n(hy), {"ana": renk}, J.getv(L, "skin"))


# ---------------------------------------------------------------- tepsi dolgusu onbellegi
# art.js fillPaint her karede her tepsi icin onlarca parcanin yerini hash'lerle
# hesapliyor (et tepsisi tek basina ~7 ms). Sonuc yalniz girdilere bagli
# (seviye drawFill'de 40 kademeye yuvarlaniyor): ilk cizim GPU tuvalinde
# kaydedilir, sonra kayit basilir. Anahtar: konum, olcu, seviye, tohum, parca
# cizici, kirpma, HD durumu. Kamera sarsintisi otelemesi oynatirken eklenir.
var _dolum: Dictionary = {}

func f_dolumHD(x: float, y: float, w: Variant, h: Variant, lvl: float, seed: Variant, item: Variant) -> Variant:
	if not hd_gpu() or not _duz():
		return _c("f_fillPaint", x, y, w, h, lvl, seed, item)
	var c = draw_context
	var ox := floorf(c.transform.origin.x + .5)
	var oy := floorf(c.transform.origin.y + .5)
	var kr: Rect2i = c.clip_rect
	var anahtar := "%d|%d|%s|%s|%.4f|%s|%s|%d|%d|%d|%d|%s" % [int(x), int(y), str(w), str(h), lvl, str(seed), str(item),
		kr.position.x - int(ox), kr.position.y - int(oy), kr.size.x, kr.size.y, str(c.mono)]
	var e: Variant = _dolum.get(anahtar)
	if e == null:
		c.kayit_basla()
		var sonuc: Variant = _c("f_fillPaint", x, y, w, h, lvl, seed, item)
		var liste: Array = c.kayit_bitir()
		if _dolum.size() > 400: _dolum.clear()
		_dolum[anahtar] = [liste, sonuc, ox, oy]
		return sonuc
	c.kayit_oynat(e[0], ox - e[2], oy - e[3])
	return e[1]

# ---------------------------------------------------------------- ikon onbellegi
# food.js icon: siparis balonlarindaki ikonlar her karede yuzlerce dikdortgen/
# elips (balonlar ~8 ms). Cizim zamana bagli degil ve tam sayi otelemeye gore
# degismez: ikon basina bir kez kaydedilir, konumuna otelenerek basilir.
# Yalniz kirpma yokken, ekranin icinde ve baska bir kayit surmuyorken.
var _ikon: Dictionary = {}
var _ikon_ic := false

func f_ikonOnbellek(id: Variant, x: Variant, y: Variant, t: Variant) -> bool:
	if _ikon_ic or not hd_gpu() or not _duz(): return false
	var c = draw_context
	if c._kayitta or c.clip_rect.size.x < 100000: return false
	var X: float = J.n(x) + c.transform.origin.x
	var Y: float = J.n(y) + c.transform.origin.y
	if X < 24 or X > 456 or Y < 24 or Y > 246: return false
	var bx := floorf(X)
	var by := floorf(Y)
	var anahtar := "%s|%.3f|%.3f|%.3f|%s|%s" % [str(id), X - bx, Y - by, float(c.globalAlpha), str(c.globalCompositeOperation), str(c.mono)]
	var e: Variant = _ikon.get(anahtar)
	if e == null:
		c.kayit_basla()
		_ikon_ic = true
		_c("f_icon", id, x, y, t)
		_ikon_ic = false
		if _ikon.size() > 300: _ikon.clear()
		_ikon[anahtar] = [c.kayit_bitir(), bx, by]
	else:
		c.kayit_oynat(e[0], bx - e[1], by - e[2])
	return true

# ---------------------------------------------------------------- hizli kalp
# food.js drawHeart 7x6 deseni her piksel icin metin indeksleyerek ciziyor
# (aktarimda dinamik J.getv: balon basina ~0.4 ms). Ayni pikseller, hazir
# satir araliklariyla.
const KALP := [[1, 2, 4, 5], [0, 6], [0, 6], [1, 5], [2, 4], [3, 3]]
func f_kalpHizli(cx: Variant, cy: Variant, sc: Variant, col: Variant) -> bool:
	if not hd_gpu() or J.n(sc) != 1.0: return false
	var X: float = J.n(cx) - 3.0
	var Y: float = J.n(cy) - 3.0
	for y in KALP.size():
		var ar: Array = KALP[y]
		var i := 0
		while i < ar.size():
			f_fr(X + ar[i], Y + y, ar[i + 1] - ar[i] + 1, 1.0, col)
			i += 2
	f_px(J.n(cx) - 2.0, J.n(cy) - 2.0, "rgba(255,255,255,.7)")
	return true


# ---------------------------------------------------------------- GPU pisirme
# Arka plan / vitrin cercevesi gibi pisirilen katmanlar HD'de GPU'da (scripts/gpu_bake.gd).
const GpuBake = preload("res://scripts/gpu_bake.gd")
func f_hdBakeTuval() -> Variant:
	if hd_gpu() and not _hd_kapali.has("bake"):
		return GpuBake.new()
	return Canvas.new()

# Tas on plan (art.js bakeStoneFG): arka planin sol/sag kemer disinda kalan
# kismi kisilerin ONUNE ikinci kez basiliyor. Eskiden her satir icin iki
# drawImage ile CPU tuvaline kopyalaniyordu; GPU'da arka plan dokusu iki
# ucgen seridiyle (kemer siniri satir satir) tek cizimde basilir.
var _tas_seritler: Dictionary = {}   # dayiVar -> [sol PackedVector2Array, sag]

func f_hdTasOnPlanPisir() -> bool:
	var bg: Variant = get("j_BG")
	return bg != null and bg.has_method("doku")

func _tas_serit(sag: bool) -> Array:
	var W: float = J.n(get("j_W"))
	var H: float = J.n(get("j_H"))
	var noktalar := PackedVector2Array()
	var uvler := PackedVector2Array()
	var idx := PackedInt32Array()
	for y in int(H):
		var e: float = J.n(_c("f_archR", float(y))) if sag else J.n(_c("f_archL", float(y)))
		var x0: float = e if sag else 0.0
		var x1: float = W if sag else e
		if x1 <= x0: continue
		var n := noktalar.size()
		for p in [Vector2(x0, y), Vector2(x1, y), Vector2(x1, y + 1), Vector2(x0, y + 1)]:
			noktalar.append(p)
			uvler.append(Vector2(p.x / W, p.y / H))
		idx.append_array([n, n + 1, n + 2, n, n + 2, n + 3])
	return [noktalar, uvler, idx]

func f_hdTasOnPlan() -> bool:
	if not hd_gpu() or not f_hdTasOnPlanPisir(): return false
	var bg: Variant = get("j_BG")
	bg.bitir()
	var anahtar := str(_c("f_dayiVar"))
	if not _tas_seritler.has(anahtar):
		_tas_seritler[anahtar] = [_tas_serit(false), _tas_serit(true)]
	var c = draw_context
	for s in _tas_seritler[anahtar]:
		c.dokulu_ucgenler(s[0], s[1], s[2], bg.doku())
	return true


# ---------------------------------------------------------------- duvar karolari ve tas kemer (pisirme icinde)
# art.js bakeBG: karo dongusu ve stoneBand piksel pikseldi. HD'de Blender ton
# dokusu (blender/models/duvar_hd.py) + paletten renk veren shader, tek dortgen.
# Yalniz GPU pisirme tuvalinde (dortgen shader'i pisirme viewport'una gider).
func _v3(c: Variant) -> Vector3:
	var k := _renk(c)
	return Vector3(k.r, k.g, k.b)

func f_hdDuvar(cols: Variant) -> bool:
	if not hd("duvar") or not (draw_context is GpuCanvas) or not draw_context.bake: return false
	var m := ShaderMaterial.new()
	m.shader = load("res://shaders/duvar.gdshader")
	m.set_shader_parameter("karo", load("res://assets/remake/duvar/karo.png"))
	for i in 5:
		m.set_shader_parameter("p%d" % i, _v3(cols[i]))
	var W: float = J.n(get("j_W"))
	var alt: float = J.n(get("j_LAY").floorY) + 4.0
	var y0 := -8.0
	var h := ceilf((alt - y0) / 18.0) * 18.0
	m.set_shader_parameter("bolge", Vector4(0.0, y0, W, h))
	draw_context.tutulan.append(m)
	draw_context.shader_quad(0.0, y0, W, h, m.get_rid(), Color.WHITE)
	return true

func f_hdTasBant(taraf: float, tasp: Variant) -> bool:
	if not hd("tas") or not (draw_context is GpuCanvas) or not draw_context.bake: return false
	var W: float = J.n(get("j_W"))
	var alt := int(J.n(get("j_LAY").floorY) + 12.0)
	var img := Image.create(1, 270, false, Image.FORMAT_RF)
	var enaz := W
	var encok := 0.0
	var kenarlar: Array = []
	for y in 270:
		var e: float = J.n(_c("f_archL", float(y))) if taraf < 0 else J.n(_c("f_archR", float(y)))
		img.set_pixel(0, y, Color(e, 0, 0))
		if y < alt:
			kenarlar.append(e)
			enaz = minf(enaz, e)
			encok = maxf(encok, e)
	var m := ShaderMaterial.new()
	m.shader = load("res://shaders/tas.gdshader")
	m.set_shader_parameter("tasdoku", load("res://assets/remake/duvar/tas.png"))
	m.set_shader_parameter("kenar", ImageTexture.create_from_image(img))
	for i in 5:
		m.set_shader_parameter("t%d" % i, _v3(tasp[i]))
	m.set_shader_parameter("taraf", taraf)
	var x0 := 0.0 if taraf < 0 else enaz
	var x1 := encok if taraf < 0 else W
	m.set_shader_parameter("bolge", Vector4(x0, 0.0, x1 - x0, float(alt)))
	draw_context.tutulan.append(m)
	draw_context.shader_quad(x0, 0.0, x1 - x0, float(alt), m.get_rid(), Color.WHITE)
	# kemer agzi kenari: art.js'teki gibi derz + koyu ton + golge
	for y in kenarlar.size():
		var e: float = kenarlar[y]
		if taraf < 0:
			f_px(e - 1.0, y, tasp[4])
			f_px(e - 2.0, y, tasp[3])
			f_px(e, y, "rgba(0,0,0,.35)")
		else:
			f_px(e, y, tasp[4])
			f_px(e + 1.0, y, tasp[3])
			f_px(e - 1.0, y, "rgba(0,0,0,.35)")
	return true


# ---------------------------------------------------------------- sokak: yaya ve arac
# art.js drawPed / drawVehicle. Blender: blender/models/sokak_hd.py. Yaya
# govdesi 8 karelik yurume tablosunun her karesi icin bolge gecisleri (pantolon,
# gomlek, ten CARPAN; ayakkabi sabit); bas/sac/sapka/goz ayri. Sola yururken
# (dir < 0) x+.5 ekseninde ayna. Arac govdesi CAR_PAL satirli PALET (l b d),
# camlar/farlar sabit, tekerlek 8 donme karesi; fren lambasi ve golgeler kodda.
const YAYA_FR := [[3, -3, 4, 4, 0, 2], [2, -2, 4, 4, -1, 1], [0, 0, 5, 4, -1, 0], [-2, 2, 4, 4, -1, -1],
	[-3, 3, 4, 4, 0, -2], [-2, 2, 4, 4, -1, -1], [0, 0, 4, 5, -1, 0], [2, -2, 4, 4, -1, 1]]
var _arac_mat: ShaderMaterial = null

func _sabit_ayna(A: Dictionary, ad: String, x: float, y: float, ayna: bool, eksen: float) -> void:
	var p: Variant = A.parca.get(ad)
	if p == null: return
	var lx: float = (x + 2.0 * eksen - p[4] - p[2] / float(A.hd)) if ayna else (x + p[4])
	draw_context.texture_hd(A.tex, Rect2(p[0], p[1], p[2], p[3]), lx, y + p[5], 1.0, ayna)

# ---------------------------------------------------------------- mac atkilari
# Takim renk ciftleri (sari-kirmizi, sari-lacivert, siyah-beyaz, bordo-mavi,
# yesil-beyaz); tohuma gore secilir. Oyunun rastgele ureticisine dokunmaz.
const ATKI_RENK := [["#f7c81a", "#c8102e"], ["#fcd116", "#14285a"], ["#16161a", "#f2f2f2"], ["#7a1c2e", "#5aa6dc"], ["#1f8a3a", "#f2f2f2"]]

func _atki_renk(seed: float) -> Array:
	return ATKI_RENK[int(J.n(f_hash1(seed * 5.31 + 0.9)) * ATKI_RENK.size()) % ATKI_RENK.size()]

# Musteri: boyna sarili serit (2 renk seritli) + bir yandan sarkan uc ve puskul.
# (x, by) govdenin ust-orta noktasi, bw govde genisligi; HD piksel ayrinti.
func f_hdAtki(x: Variant, by: Variant, bw: Variant, seed: Variant) -> void:
	if not hd("musteri"): return
	var R := _atki_renk(J.n(seed))
	var c0 := Color(R[0])
	var c1 := Color(R[1])
	var X: float = J.n(x) * 2.0
	var Y: float = J.n(by) * 2.0
	var W: float = roundf(J.n(bw) * 0.62) * 2.0
	var x0 := roundf(X - W / 2.0)
	# boyun sargisi: 3 kat serit (ust kat biraz dar), kat arasi golge
	for kat in 3:
		var kx := x0 + (2.0 if kat == 0 else 0.0)
		var kw := W - (4.0 if kat == 0 else 0.0)
		var ky := Y - 3.0 + kat * 2.0
		var i := 0.0
		while i < kw:
			var c := c0 if int((i + kat * 3.0) / 3.0) % 2 == 0 else c1
			_hp(kx + i, ky, minf(3.0, kw - i), 2.0, c.darkened(0.18) if kat == 2 else c)
			i += 3.0
	_hp(x0 + 1.0, Y + 3.0, W - 2.0, 1.0, Color(0, 0, 0, 0.25))
	# sarkan uc: govdenin onunde, sag tarafta (tohuma gore sol/sag)
	var sag := J.n(f_hash1(J.n(seed) * 2.9)) > 0.5
	var ux := (X + W * 0.18) if sag else (X - W * 0.18 - 5.0)
	var j := 0.0
	while j < 14.0:
		var c2 := c0 if int(j / 3.0) % 2 == 0 else c1
		_hp(ux, Y + 3.0 + j, 5.0, minf(3.0, 14.0 - j), c2)
		j += 3.0
	_hp(ux + 4.0, Y + 3.0, 1.0, 14.0, Color(0, 0, 0, 0.18))
	# puskul
	for f in 3:
		_hp(ux + f * 2.0, Y + 17.0, 1.0, 2.0, c1.lightened(0.2))

# Yaya: kucuk boyun seridi + kisa sarkan uc (sokak olcusu)
func _yaya_atki(X: float, yy: float, gw2: int, K: float, ayna: bool) -> void:
	var R := _atki_renk(K + 3.0)
	var c0 := Color(R[0])
	var c1 := Color(R[1])
	var x0 := roundf((X - gw2 / 2.0) * 2.0)
	var y0 := roundf((yy - 8.5) * 2.0)
	var i := 0.0
	while i < gw2 * 2.0:
		_hp(x0 + i, y0, minf(2.0, gw2 * 2.0 - i), 2.0, c0 if int(i / 2.0) % 2 == 0 else c1)
		i += 2.0
	var ux := x0 + (gw2 * 2.0 - 3.0 if not ayna else 1.0)
	_hp(ux, y0 + 2.0, 2.0, 2.0, c1)
	_hp(ux, y0 + 4.0, 2.0, 2.0, c0)

func f_hdYaya(x: Variant, y: Variant, k: Variant, dir: Variant, t: Variant, sc: Variant, umb: Variant) -> bool:
	if not hd("sokak"): return false
	var A := atlas("sokak")
	if A.is_empty() or not A.parca.has("yaya_0_4_gomlek"): return false
	# yarim piksel konum: yavas yuruyuste 1 px'lik sicrama yerine akici kayma
	var X := f_hdYarimPx(x)
	var Y := f_hdYarimPx(y)
	var K: float = J.n(k)
	var D: float = J.n(dir)
	var P0: Dictionary = _c("f_pedKimlik", k)
	var shirt: Variant = P0.shirt
	var gw2 := 4 + int(J.n(P0.genis))
	var ph := int(floor(fposmod(J.n(t) * J.n(P0.tempo) + K * 1.7, 8.0)))
	var FR: Array = YAYA_FR[ph]
	var boy: float = J.n(P0.boy)
	var by: float = float(FR[4]) + boy
	var arm: float = float(FR[5])
	var yy := Y + by
	draw_context.globalAlpha = .24
	f_ell(X, Y, 3.0 + J.n(P0.genis), 1.0, "#000")
	draw_context.globalAlpha = 1.0
	var ayna := D < 0
	var onek := "yaya_%d_%d_" % [ph, gw2]
	hd_ton(A, onek + "pant", X, yy, 0, _renk(P0.pant), ayna, .5)
	hd_ton(A, onek + "gomlek", X, yy, 0, _renk(shirt), ayna, .5)
	hd_ton(A, onek + "ten", X, yy, 0, _renk(P0.skin), ayna, .5)
	_sabit_ayna(A, onek + "sabit", X, yy, ayna, .5)
	if J.truth(P0.ceket):
		hd_ton(A, "yaya_ceket_%d" % gw2, X, yy, 0, _renk(shirt), ayna, .5)
	var gx0 := X - floorf(gw2 / 2.0)
	var esya := int(J.n(P0.esya))
	# tasinan esya: HD izgarada (govdeyle ayni yarim piksel konum)
	if esya == 1:
		_hr(gx0 + gw2, yy - 2 + arm, 2.0, 3.0, "#7a4a2a")
		_hr(gx0 + gw2, yy - 2 + arm, 1.0, 1.0, "#a8703a")
	elif esya == 2:
		var ex := gx0 - (1.0 if D > 0 else -float(gw2))
		_hr(ex, yy - 7, 2.0, 5.0, "#3f5a7a")
		_hr(ex, yy - 7, 1.0, 1.0, "#5a7a9a")
	elif esya == 3:
		_hr(gx0 + gw2, yy - 2 + arm, 2.0, 3.0, "#dfe6ea")
		_hr(gx0 + gw2, yy - 2 + arm, 2.0, 1.0, "#ffffff")
	elif esya == 4:
		_hr(gx0 + gw2, yy - 3 + arm, 2.0, 2.0, "#e8e2d0")
		_hr(gx0 + gw2, yy - 4 + arm, 1.0, 1.0, "#a83a2a")
	# mac cikisi: taraftarlarin cogu takim atkili (ekrandaki yazi yerine)
	if J.truth(_c("f_macDalgada")) and J.n(f_hash1(K * 2.3 + 0.7)) < 0.8:
		_yaya_atki(X, yy, gw2, K, ayna)
	hd_ton(A, "yaya_bas_ten", X, yy, 0, _renk(P0.skin), ayna, .5)
	var sac := int(J.n(P0.sac))
	hd_ton(A, "yaya_sac_%d" % clampi(sac, 0, 3), X, yy, 0, _renk(P0.hair), ayna, .5)
	if J.truth(P0.sapka):
		hd_ton(A, "yaya_sapka", X, yy, 0, _renk(shirt), ayna, .5)
	# gozler art.js'te yone gore bir piksel kayiyor: aynada eksen x (govde x+.5)
	_sabit_ayna(A, "yaya_bas_sabit", X, yy, ayna, 0.0)
	if J.truth(umb) and A.parca.has("semsiye_kubbe"):
		# BIRLESIK: dilimli HD semsiye (sokak_hd.semsiye), kisinin rengiyle
		var PS0: Array = get("j_PED_SHIRT")
		hd_ton(A, "semsiye_kubbe", X, yy, 0, _renk(PS0[int(fposmod(K * 4.0, PS0.size()))]), ayna, .5)
		_sabit_ayna(A, "semsiye_sap", X, yy, ayna, .5)
	elif J.truth(umb):
		var PS: Array = get("j_PED_SHIRT")
		f_ell(X, yy - 15 + boy, 6.0, 2.0, "#2f4f6a")
		f_ell(X, yy - 16 + boy, 6.0, 2.0, PS[int(fposmod(K * 4.0, PS.size()))])
		f_vl(X, yy - 15 + boy, 5.0, "#5a4a32")
		f_px(X - 5, yy - 14 + boy, "#2f4f6a")
		f_px(X + 5, yy - 14 + boy, "#2f4f6a")
	return true

func _arac_palet() -> RID:
	if _arac_mat == null:
		var pal: Array = get("j_CAR_PAL")
		var img := Image.create(3, pal.size(), false, Image.FORMAT_RGBA8)
		for r in pal.size():
			img.set_pixel(0, r, Color.html(pal[r].l))
			img.set_pixel(1, r, Color.html(pal[r].b))
			img.set_pixel(2, r, Color.html(pal[r].d))
		_arac_mat = ShaderMaterial.new()
		_arac_mat.shader = load("res://shaders/ton.gdshader")
		_arac_mat.set_shader_parameter("kip", 1)
		_arac_mat.set_shader_parameter("sutunlar", 3)
		_arac_mat.set_shader_parameter("satirlar", pal.size())
		_arac_mat.set_shader_parameter("palet", ImageTexture.create_from_image(img))
	_arac_mat.set_shader_parameter("mono", draw_context.mono)
	return _arac_mat.get_rid()

func _as(v: float, S: float) -> float:
	return floorf(v * S + .5)

func f_hdArac(x: Variant, y: Variant, sc: Variant, tip: Variant, ci: Variant, dir: Variant, t: Variant, duruyor: Variant) -> bool:
	if not hd("sokak"): return false
	var S: float = J.n(sc)
	var sca := 100 if absf(S - 1.0) < .01 else (86 if absf(S - .86) < .01 else 0)
	var ti := int(J.n(tip))
	if sca == 0 or ti < 0 or ti > 5: return false
	var A := atlas("sokak")
	if A.is_empty() or not A.parca.has("arac_%d_%d_govde" % [ti, sca]): return false
	var Lg: float = J.n(_c("f_vehLen", tip, sc))
	# yarim piksel konum (akici surus); stop / teker golgesi de HD izgarada
	var X := f_hdYarimPx(x)
	var Y := f_hdYarimPx(y)
	var cx := X + floorf(Lg / 2.0 + .5)
	var ayna := J.n(dir) < 0
	var wr := maxf(2.0, _as(3.0, S))
	var bodyH := _as(7.0, S)
	var by := Y - wr - bodyH
	draw_context.globalAlpha = .3
	f_ell(X + Lg / 2.0, Y, Lg / 2.0 - 1.0, maxf(1.0, _as(2.0, S)), "#000")
	draw_context.globalAlpha = 1.0
	var pal: Array = get("j_CAR_PAL")
	var satir := int(fposmod(J.n(ci), pal.size()))
	hd_ton(A, "arac_%d_%d_govde" % [ti, sca], cx, Y, 1, Color(satir / float(pal.size() - 1), 0, 0, 1), ayna, 0.0, _arac_palet())
	var sab := "arac_%d_%d_sabit" % [ti, sca]
	if A.parca.has(sab):
		hd_ciz(A, sab, cx, Y, 1.0, ayna)
	var dur := J.truth(duruyor)
	var stopC := "#ff5a48" if dur else "#d8352c"
	var sw := maxf(1.0, _as(2.0, S))
	_hr(_ekran_x(ayna, cx, X, 0.0, sw), by + _as(2.0, S), sw, _as(2.0, S), stopC)
	if dur:
		draw_context.globalAlpha = .35
		_hr(_ekran_x(ayna, cx, X, -1.0, _as(3.0, S)), by + _as(1.0, S), _as(3.0, S), _as(4.0, S), "#ff5a48")
		draw_context.globalAlpha = 1.0
	var wy2 := Y - wr
	var wsp := 0.0 if dur else (-9.0 if ayna else 9.0)
	var kare := int(floor(fposmod(J.n(t) * wsp, TAU) / TAU * 8.0))
	for ofs in [_as(9.0 if ti == 2 else 8.0, S), Lg - _as(10.0 if ti == 2 else 9.0, S)]:
		hd_ciz(A, "teker_%d" % kare, _ekran_x(ayna, cx, X, ofs, 1.0), wy2)
	draw_context.globalAlpha = .35
	_hr(_ekran_x(ayna, cx, X, _as(5.0, S), _as(7.0, S)), wy2 - wr, _as(7.0, S), 1.0, "#000")
	_hr(_ekran_x(ayna, cx, X, Lg - _as(13.0, S), _as(7.0, S)), wy2 - wr, _as(7.0, S), 1.0, "#000")
	draw_context.globalAlpha = 1.0
	return true

# aynali arac: sol uca gore ofset -> ekran x'i (art.js translate/scale(-1) ekseni cx)
func _ekran_x(ayna: bool, cx: float, X: float, ofs: float, w: float) -> float:
	return (2.0 * cx - (X + ofs) - w) if ayna else (X + ofs)


# ---------------------------------------------------------------- arayuz ikonlari
# food.js icon: siparis balonu, HUD, dukkan. Blender HD (blender/models/ikon_hd.py).
# Olcekli ctx (balonun acilma animasyonu) icinde eski cizim/onbellek devrede.
# icecekler: makinedeki bardakla ayni cam bardak ikonu (birlesik surum)
const IKON_AD := {"orange": "bardak_fanta", "fanta": "bardak_fanta", "cola": "bardak_cola", "ayran": "bardak_ayran", "fries": "fbox"}
func f_hdIkon(id: Variant, x: Variant, y: Variant) -> bool:
	if not hd("ikon") or not (id is String): return false
	var ad: String = IKON_AD.get(id, id)
	var A := atlas("ikon")
	if A.is_empty() or not A.parca.has("ikon_" + ad): return false
	hd_ciz(A, "ikon_" + ad, J.n(x), J.n(y))
	return true


# ---------------------------------------------------------------- vitrin, kepenk, duvar susleri
# art.js bakeWinOver (vitrin cercevesi pisirmesi), drawShutter, drawTabela,
# boya yukseltmesi lambasi, drawPoster. Blender: blender/models/vitrin_hd.py.
func f_hdPencere(ox: Variant, oy: Variant) -> bool:
	if not hd("vitrin"): return false
	var A := atlas("vitrin")
	if A.is_empty() or not A.parca.has("pencere"): return false
	var LAY: Dictionary = get("j_LAY")
	var X := J.n(ox)
	var Y := J.n(oy)
	hd_ciz(A, "cam_isik", X + J.n(LAY.glass.x) - J.n(LAY.win.x), Y + J.n(LAY.glass.y) - J.n(LAY.win.y))
	hd_ciz(A, "esik_golge", X, Y)
	hd_ciz(A, "pencere", X, Y)
	return true

# Kepenk: sac dokusu ALTTAN kirpilir, yani kepenk inerken lameller alt kolla
# birlikte asagi kayar (eski cizimde desen cama sabitti). Rulo kutusu
# yuksekligi (3..9) art.js'teki gibi acildikca buyur.
func f_hdKepenk(k: Variant) -> bool:
	if not hd("kepenk"): return false
	var A := atlas("vitrin")
	if A.is_empty() or not A.parca.has("kepenk_sac"): return false
	var G: Dictionary = get("j_LAY").glass
	var gx: float = J.n(G.x)
	var gy: float = J.n(G.y)
	var K := clampf(J.n(k), 0.0, 1.0)
	# yarim piksel (HD satiri) hassasiyet: kepenk inip kalkarken akici
	var hgt := floorf(J.n(G.h) * K * 2.0 + .5) / 2.0
	var ctx: GpuCanvas = draw_context
	ctx.save()
	ctx.beginPath()
	ctx.rect(G.x, G.y, G.w, G.h)
	ctx.clip()
	if hgt > 2.0:
		var p: Array = A.parca.kepenk_sac
		var sat := minf((hgt - 3.0) * A.hd, p[3])
		if sat > 0:
			ctx.texture_hd(A.tex, Rect2(p[0], p[1] + p[3] - sat, p[2], sat), gx + p[4], gy)
		hd_ciz(A, "kepenk_golge", gx, gy + hgt)
		hd_ciz(A, "kepenk_alt", gx, gy + hgt - 4.0)
	ctx.restore()
	if K < .98:
		var rh := clampi(int(floorf(3.0 + (1.0 - K) * 6.0 + .5)), 3, 9)
		hd_ciz(A, "kepenk_rulo_%d" % rh, gx, gy - rh + 1.0)
	return true

# Tabela genisligi yaziya gore degisiyor: sol / orta karo (16 px, son karo
# kirpilir) / sag. Yazi ve ampul yanip sonmesi art.js ile ayni.
func f_hdTabela(sx: Variant, sy: Variant, t: Variant) -> bool:
	if not hd("tabela"): return false
	var A := atlas("vitrin")
	if A.is_empty() or not A.parca.has("tabela_orta"): return false
	var SX := J.n(sx)
	var SY := J.n(sy)
	var sw: float = J.n(_c("f_tabelaGen"))
	hd_ciz(A, "tabela_sol", SX, SY)
	var o: Array = A.parca.tabela_orta
	var karo: float = o[2] / float(A.hd)
	var x := SX + 10.0
	var son := SX + sw - 10.0
	while x < son - .01:
		var w := minf(karo, son - x)
		draw_context.texture_hd(A.tex, Rect2(o[0], o[1], roundf(w * A.hd), o[3]), x + o[4], SY + o[5])
		x += w
	hd_ciz(A, "tabela_sag", SX + sw, SY)
	var P: Dictionary = get("j_P")
	var ad: Variant = _c("f_tabelaAd")
	var alt: Variant = _c("f_tabelaAlt")
	_c("f_txt", ad, SX + sw / 2.0, SY + 5.0, P.au0, {"align": "c", "outline": "#8e1c14"})
	if J.truth(alt):
		_c("f_txt", alt, SX + sw / 2.0, SY + 15.0, P.white, {"align": "c"})
	var T := J.n(t)
	for i in int(floorf(sw / 14.0)):
		var acik := sin(T * 4.0 + i) > -.3
		var bx := SX + 8.0 + i * 14.0
		if acik:
			hd_ciz(A, "ampul_isik", bx, SY + 27.0)
		hd_ciz(A, "ampul_acik" if acik else "ampul_kapali", bx, SY + 27.0)
	return true

func f_hdLamba() -> bool:
	if not hd("lamba"): return false
	var A := atlas("vitrin")
	if A.is_empty() or not A.parca.has("lamba"): return false
	hd_ciz(A, "lamba", 0.0, 0.0)
	hd_ciz(A, "lamba_isik", 0.0, 0.0)
	_lamba_tozu(120.0, 21.0)
	return true

# Isik konisinde yavasca suzulen toz zerrecikleri (ortam canliligi). Konum
# yalniz zamandan ve sabit hash'ten: oyunun rastgele ureticisine dokunmaz.
func _lamba_tozu(lx: float, ly: float) -> void:
	var G: Variant = get("j_G")
	var T: float = J.n(G.get("t", 0.0)) if G is Dictionary else 0.0
	var ctx: GpuCanvas = draw_context
	for i in 9:
		var h1 := fposmod(sin(i * 12.9898) * 43758.5453, 1.0)
		var h2 := fposmod(sin(i * 78.233) * 43758.5453, 1.0)
		var h3 := fposmod(sin(i * 39.425) * 43758.5453, 1.0)
		var r := fposmod(T * (0.8 + h1 * 1.2) + h2 * 24.0, 24.0)
		var yari := 3.5 + r
		var x := lx + (h3 * 2.0 - 1.0) * yari * 0.8 + sin(T * (0.7 + h2) + i) * 1.5
		var kenar := 1.0 - absf(x - lx) / maxf(1.0, yari)
		var a := clampf(kenar * 1.5, 0.0, 1.0) * (0.25 + 0.35 * (0.5 + 0.5 * sin(T * (1.3 + h1) + i * 2.0)))
		a *= clampf(r / 3.0, 0.0, 1.0) * clampf((24.0 - r) / 4.0, 0.0, 1.0)
		if a <= 0.02: continue
		ctx.globalAlpha = a
		_hr(x, ly + 1.0 + r, 0.5, 0.5, "#fff3c8")
	ctx.globalAlpha = 1.0

func f_hdAfis(kind: Variant, x: Variant, y: Variant) -> bool:
	var tur := int(J.n(kind))
	if tur < 1 or tur > 3: return false
	# BIRLESIK: yeni tezgahta afis ctx.scale(0.64) icinde (atlas "afis64")
	var A: Dictionary
	if hd("afis"): A = atlas("vitrin")
	elif hd_olcekli("afis") and absf(draw_context.transform.x.x - 0.64) < .001: A = atlas("afis64")
	else: return false
	if A.is_empty() or not A.parca.has("afis_%d" % tur): return false
	var X := 106.0 if x == null else J.n(x)
	var Y := 50.0 if y == null else J.n(y)
	hd_ciz(A, "afis_%d" % tur, X, Y)
	if tur == 2:
		_c("f_txt", "DÖNER", X + 20.0, Y + 4.0, "#c0281c", {"align": "c"})
		_c("f_txt", "TAZE", X + 20.0, Y + 25.0, "#2f5f9e", {"align": "c"})
	return true


# ---------------------------------------------------------------- sokak arka plani
# art.js bakeStreet (gok, bulut, simge yapi, uzak siluet, binalar, kaldirim, yol):
# sehir basina tek Blender goruntusu (blender/models/sokak_arka_hd.py, bina
# yerlesimi ayni hash1 dizisi). Rakip dukkanin zemin kati gune/hikayeye bagli:
# yerlesim dongusuyle 4. binanin yeri bulunup eski cizimle basilir.
func f_hdSokakArka() -> bool:
	if not hd("sokak_arka"): return false
	var A := atlas("sokak_arka")
	var tema: Variant = _c("f_sehirTema")
	if not (tema is Dictionary): return false
	var ad := "sokak_%s" % tema.id
	if A.is_empty() or not A.parca.has(ad): return false
	var M: Dictionary = _c("f_stM")
	hd_ciz(A, ad, J.n(M.gx), J.n(M.gy))
	var CP: Variant = tema.get("cephe")
	if not (CP is Dictionary) or CP.tarz != "dukkan": return true
	var durum: Variant = _c("f_rakipCepheDurum")
	if not J.truth(durum): return true
	var bx: float = J.n(M.gx) - 16.0
	for bi in 4:
		var bw: float = J.n(CP.genAz) + floorf(J.n(f_hash1(bi * 4.3)) * (J.n(CP.genCok) - J.n(CP.genAz)))
		if bi == 3:
			var BLD: Array = get("j_BLD")
			_c("f_rakipZemin", bx, J.n(M.base), 58.0, J.n(M.base) - 15.0, BLD[3 % BLD.size()], durum)
		bx += bw + 3.0
	return true


# ---------------------------------------------------------------- sokak esyalari
# art.js drawStreetProps / drawSokakAgaci / drawSehirIkonu / drawNearProps.
# Blender: blender/models/sokak_esya_hd.py. Durumlar (lamba acik, trafik ve
# yaya lambasi) ayri parca; trafik parlamasi beyaz doku + renk carpani.
const AGAC_TIP := {"palmiye": "agac_palmiye", "sakura": "agac_sakura", "budanmis": "agac_budanmis"}
const SEHIR_IKON := ["simit", "sutun", "kulube", "sarisari", "kafe", "otomat", "musluk", "palmiye"]

func _esya() -> Dictionary:
	if not hd("sokak_esya"): return {}
	var A := atlas("sokak_esya")
	if A.is_empty() or not A.parca.has("trafik_govde"): return {}
	return A

func f_hdSokakAgaci(tx: Variant, ty: Variant, tip: Variant) -> bool:
	var A := _esya()
	if A.is_empty(): return false
	hd_ciz(A, AGAC_TIP.get(tip, "agac_yaprak"), J.n(tx), J.n(ty))
	return true

func f_hdSehirIkonu(x: Variant, y: Variant, id: Variant, t: Variant) -> bool:
	var A := _esya()
	if A.is_empty(): return false
	var ad: String = id if id in SEHIR_IKON else "posta"
	var X := J.n(x)
	var Y := J.n(y)
	hd_ciz(A, "sehir_" + ad, X, Y)
	if ad == "otomat":
		draw_context.globalAlpha = 0.16 + 0.06 * sin(J.n(t) * 2.0)
		f_fr(X - 3.0, Y - 23.0, 18.0, 24.0, "#bfe8ff")
		draw_context.globalAlpha = 1.0
	elif ad == "musluk":
		# eski cizimle ayni rastgele sayi tuketimi (duman olasiligi)
		if J.truth(_c("f_chance", 0.045)):
			_c("f_smoke", X + 16.0, Y - 1.0, 1.0, "rgba(220,228,236,.42)")
	return true

func f_hdSokakEsya(t: Variant, lamba_acik: Variant) -> bool:
	var A := _esya()
	if A.is_empty(): return false
	var M: Dictionary = _c("f_stM")
	var gx: float = J.n(M.gx)
	var base: float = J.n(M.base)
	var tema: Variant = _c("f_sehirTema")
	var TM: Dictionary = tema if tema is Dictionary else {}
	_c("f_drawSokakAgaci", gx + 118.0, base + 7.0, TM.get("agac"))
	var lx := gx + 46.0
	var ly := base + 8.0
	hd_ciz(A, "lamba", lx, ly)
	if J.truth(lamba_acik):
		hd_ciz(A, "lamba_isik", lx, ly)
		hd_ciz(A, "lamba_acik", lx, ly)
	hd_ciz(A, "durak", gx + 150.0, base + 8.0)
	_c("f_drawSehirIkonu", gx + 78.0, base + 8.0, TM.get("ikon"), t)
	var trx := gx + 224.0
	var ty := base + 8.0
	hd_ciz(A, "trafik_govde", trx, ty)
	var st: Variant = get("j_TLIGHT").state
	var ad := "trafik_kirmizi" if st == "red" else ("trafik_sari" if st == "yellow" else "trafik_yesil")
	var hy := ty - 34.0 if st == "red" else (ty - 30.0 if st == "yellow" else ty - 27.0)
	var hc := "#e2483a" if st == "red" else ("#e0c23a" if st == "yellow" else "#3fbf5a")
	hd_ciz(A, ad, trx, ty)
	hd_ciz(A, "trafik_isik", trx, hy, 0.22 + 0.1 * sin(J.n(t) * 4.0), false, Color.html(hc))
	var pwx := trx - 30.0
	hd_ciz(A, "yaya_govde", pwx, ty)
	hd_ciz(A, "yaya_yuru" if st == "red" else "yaya_dur", pwx, ty)
	return true

func f_hdYakinEsya() -> bool:
	var A := _esya()
	if A.is_empty(): return false
	var M: Dictionary = _c("f_stM")
	var G: Dictionary = get("j_LAY").glass
	var gx: float = J.n(M.gx)
	var pby: float = J.n(G.y) + J.n(G.h) - 1.0
	draw_context.globalAlpha = 0.28
	f_ell(gx + 97.0, pby, 11.0, 2.0, "#000")
	f_ell(gx + 241.0, pby, 8.0, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "bisiklet", gx + 90.0, pby)
	hd_ciz(A, "cop", gx + 236.0, pby)
	return true


# ---------------------------------------------------------------- musteri yuz ifadeleri
# chars.js drawCustomer yuz blogu: kaslar, gozler, agiz. Durum mantigi aynen
# (ofke, sevinc, sabirsizlik, kirpma, goz bebeginin gezinmesi, kadin kirpigi,
# goz / kapak / kas / agiz tipleri); sekiller 2x izgarada yeniden ciziliyor.
# Blender parcasi degil: 5 px'lik gozde 3B golge bir sey katmiyor, cesit
# sayisi ise (6 goz x 6 kapak x 4 ruh hali x bakis) cok buyuk.
func _hp(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_context.rect_hd(x, y, w, h, c)

# mantik piksel biriminde (yarim piksel konum olabilir) HD dikdortgen
func _hr(x: float, y: float, w: float, h: float, c: Variant) -> void:
	draw_context.rect_hd(roundf(x * 2.0), roundf(y * 2.0), w * 2.0, h * 2.0, _renk(c))

func f_hdKaslar(kSol: Variant, kSag: Variant, browY: Variant, kaW: Variant, kaH: Variant, kaD: Variant, kaC: Variant, kas: Variant, ang: Variant, hap: Variant) -> bool:
	if not hd("yuz"): return false
	var c := _renk(kaC)
	var koyu := c.darkened(0.3)
	var W := int(J.n(kaW)) * 2
	var H := J.n(kaH) * 2.0
	var by := J.n(browY) * 2.0
	var bd := J.n(kaD) * 2.0
	var tip := int(J.n(kas))
	var ofke := J.truth(ang)
	var sevinc := J.truth(hap)
	var uzat := 2 if ofke else 0            # art.js: ofkede ic uca bir piksel tasar
	var N := W + uzat
	for taraf in 2:
		var x0 := J.n(kSol if taraf == 0 else kSag) * 2.0
		for i in N:
			var t := i / float(N - 1)            # 0 dis uc .. 1 ic uc
			var top: float
			var kal: float
			if ofke:
				top = by + bd - 2.0 + roundf(4.0 * t)
				kal = H - 1.0 + roundf(t * 1.5)
			elif sevinc:
				top = by - 2.0 + roundf(1.5 - 2.5 * sin(PI * clampf(t * 1.1, 0.0, 1.0)))
				kal = 2.0 + roundf(sin(PI * t))
			elif tip == 3:
				top = by - 1.0 + roundf(2.5 * t)
				kal = 3.0 + roundf(t)
			elif tip == 4:
				top = by + roundf(2.0 - 2.0 * sin(PI * t))
				kal = 2.0 + roundf(sin(PI * t))
			else:
				top = by + bd + roundf(1.0 - 1.4 * sin(PI * (0.25 + 0.6 * t)))
				kal = maxf(2.0, H - 1.0 + roundf(t))
			if i == 0:                           # dis uc incelir
				top += 1.0
				kal = maxf(1.0, kal - 2.0)
			var col := x0 + (i if taraf == 0 else W - 1 - i)
			_hp(col, top, 1.0, kal, c)
			if kal >= 3.0 and t > 0.3:
				_hp(col, top + kal - 1.0, 1.0, 1.0, koyu)
	return true

# goz aki satir araligi (HD): bicim art.js gozAki ile ayni aileden
func _goz_satir(bicim: int, i: int, W: int, H: int, yon: float) -> Vector2i:
	match bicim:
		1:
			var u := absf(i - (H - 1) / 2.0) / maxf(1.0, (H - 1) / 2.0)
			var kis := mini(maxi(0, (W - 6) / 2), int(roundf(pow(u, 1.8) * 3.2)))
			return Vector2i(kis, W - kis)
		2:
			var cy := H / 2.0
			var v := (i + 0.5 - cy) / cy
			var yari := W / 2.0 * sqrt(maxf(0.0, 1.0 - v * v))
			return Vector2i(int(roundf(W / 2.0 - yari)), int(roundf(W / 2.0 + yari)))
		_:
			var kose := 1 if (i == 0 or i == H - 1) else 0
			return Vector2i(kose, W - kose)

func f_hdGozler(gSol: Variant, gSag: Variant, fy: Variant, gzW: Variant, gzH: Variant, gzD: Variant, bbW: Variant, bbH: Variant, gzC: Variant,
		hap: Variant, ang: Variant, imp: Variant, blink: Variant, kadin: Variant, F: Variant, L: Variant, s: Variant, t: Variant) -> bool:
	if not hd("yuz"): return false
	var goz := _renk(gzC)
	var S3 := _renk(s[3])
	var S2 := _renk(s[2])
	var kapak := S3.darkened(0.45)
	var FY := J.n(fy)
	var D := J.n(gzD)
	var W := int(J.n(gzW)) * 2
	var H := int(J.n(gzH)) * 2
	var sevinc := J.truth(hap)
	var ofke := J.truth(ang)
	var kad := J.truth(kadin)
	for taraf in 2:
		var g := J.n(gSol if taraf == 0 else gSag)
		var yon := -1.0 if taraf == 0 else 1.0
		var x := g * 2.0
		# dis kose: sol gozde sol, sag gozde sag
		var dis_x := x if taraf == 0 else x + W - 1.0
		if sevinc:
			var bas := x if taraf == 0 else x - 4.0
			for i in 13:
				var u := i / 12.0
				var yy := (FY + 1.0 + D) * 2.0 - roundf(6.0 * sin(PI * u))
				_hp(bas + i, yy, 1.0, 2.0, goz)
			if kad:
				_hp(bas - 1.0 if taraf == 0 else bas + 13.0, (FY - 1.0 + D) * 2.0, 1.0, 2.0, kapak)
			continue
		# REMAKE: eski kirpma 0.625 sn'lik pencerenin TAMAMINDA kapaliydi
		# (uykulu). HD'de pencerenin basinda kisa kirpma: yari -> kapali -> yari.
		var yari_kapak := false
		var kirp_faz := fposmod(J.n(t) * 1.6, 1.0)
		var kirp := J.truth(blink) and not ofke
		if kirp and (kirp_faz < 0.06 or (kirp_faz >= 0.18 and kirp_faz < 0.26)):
			yari_kapak = true
		if kirp and kirp_faz >= 0.06 and kirp_faz < 0.18:
			for i in W:
				var yy2 := (FY + D) * 2.0 + roundf(1.2 * sin(PI * i / float(W - 1)))
				_hp(x + i, yy2, 1.0, 2.0, S3)
			_hp(dis_x - yon, (FY + D) * 2.0 + 1.0, 1.0, 1.0, kapak)
			continue
		var bicim := int(J.n(F.get("gozB", 0.0))) if F.get("gozB") != null else 0
		var ust := (FY - 2.0 + D) * 2.0
		var ak_bas := 0
		var ak_son := H
		if bicim == 3:
			ak_bas = 4
		elif bicim == 4:
			ak_bas = maxi(1, (int(J.n(gzH)) - 2) >> 1) * 2
			ak_son = ak_bas + 4
		for i in range(ak_bas, ak_son):
			var sp := _goz_satir(bicim, i - ak_bas, W, ak_son - ak_bas, yon)
			var l := sp.x
			var r := sp.y
			if bicim == 5:
				# dis koseye yakin iki sutun bir satir asagida baslar
				if i - ak_bas < 2:
					if taraf == 0: l = maxi(l, 4)
					else: r = mini(r, W - 4)
			if r > l:
				_hp(x + l, ust + i, r - l, 1.0, Color.WHITE)
		# ust kapak cizgisi / agir kapak
		if bicim == 3:
			_hp(x, ust, W, 3.0, S2)
			_hp(x, ust + 3.0, W, 1.0, S3)
		elif bicim == 4:
			_hp(x, ust + ak_bas - 2.0, W, 2.0, S3)
		else:
			var sp0 := _goz_satir(bicim, 0, W, H, yon)
			_hp(x + sp0.x, ust, sp0.y - sp0.x, 1.0, Color(kapak, 0.85))
			if int(J.n(F.get("goz", 0.0))) == 5:
				_hp(x, ust, W, 2.0, S3)
		# iris + bebek + parilti
		var gB := bicim
		var bbw := J.n(bbW) * 2.0
		var pH := 2.0 if gB == 4 else (minf(J.n(bbH), J.n(gzH) - 2.0) if gB == 3 else J.n(bbH))
		var akUst := 2.0 if gB == 3 else (maxf(1.0, float((int(J.n(gzH)) - 2) >> 1)) if gB == 4 else 0.0)
		var akH := (J.n(gzH) - 2.0) if gB == 3 else (2.0 if gB == 4 else J.n(gzH))
		var lx := 1.0 if ofke else floorf(sin(J.n(t) * 0.8 + J.n(L.seed)) + 0.5)
		var ly := 1.0 if J.truth(imp) else 0.0
		var pY := (FY - 2.0 + D + akUst + floorf((akH - pH) / 2.0) + ly) * 2.0
		var px0 := (g + 1.0 + lx) * 2.0
		var ph := maxf(1.0, pH) * 2.0
		_hp(px0, pY + 1.0, bbw, ph - 2.0, goz)
		_hp(px0 + 1.0, pY, bbw - 2.0, 1.0, goz)
		_hp(px0 + 1.0, pY + ph - 1.0, bbw - 2.0, 1.0, goz)
		if bbw >= 4.0 and ph >= 4.0:
			_hp(px0 + 1.0, pY + 1.0, bbw - 2.0, ph - 2.0, goz.darkened(0.55))
		_hp(px0 + 1.0, pY + 1.0, 1.0, 1.0, Color(1, 1, 1, 0.9))
		if yari_kapak:
			# ust kapak gozun yarisina inmis: ust yari ten, kenarda kapak cizgisi
			var yk := float(maxi(2, (H >> 1)))
			_hp(x, ust - 1.0, W, yk + 1.0, S3)
			_hp(x, ust + yk, W, 1.0, kapak)
		if kad:
			var ky := (FY - 3.0 + D) * 2.0
			_hp(dis_x + yon * 1.0, ky + 1.0, 1.0, 1.0, kapak)
			_hp(dis_x + yon * 2.0, ky, 1.0, 1.0, kapak)
			_hp(dis_x + yon * 3.0, ky + 2.0, 1.0, 1.0, kapak)
			_hp(dis_x + yon * 2.0, ky + 3.0, 1.0, 1.0, kapak)
		if ofke:
			var rx := g * 2.0 if taraf == 0 else (g + J.n(gzW) - 1.0) * 2.0
			_hp(rx, (FY - 3.0) * 2.0, 2.0, 2.0, Color8(224, 74, 58))
	return true

func f_hdAgiz(hx: Variant, my: Variant, agD: Variant, hap: Variant, ang: Variant, imp: Variant, kadin: Variant, agiz: Variant, s: Variant) -> bool:
	if not hd("yuz"): return false
	var X := J.n(hx) * 2.0
	var Y := J.n(my) * 2.0
	var d := J.n(agD) * 2.0
	var kad := J.truth(kadin)
	if J.truth(hap):
		var x0 := X - 8.0 - d
		var w := 18.0 + 2.0 * d
		var koyu := Color8(0x6d, 0x2f, 0x28)
		var satir := [0.0, 0.0, 1.0, 1.0, 3.0, 5.0]
		for r in 6:
			var k: float = satir[r]
			_hp(x0 + k, Y + r, w - 2.0 * k, 1.0, koyu)
		_hp(x0 + 2.0, Y, w - 4.0, 2.0, Color.WHITE)
		_hp(x0 + 5.0, Y + 4.0, w - 10.0, 2.0, Color8(0xc9, 0x58, 0x4a))
		_hp(x0 + 6.0, Y + 6.0, w - 12.0, 1.0, _renk(s[2]))
		return true
	if J.truth(ang):
		var x0 := X - 8.0 - d
		var w := 18.0 + 2.0 * d
		_hp(x0 + 1.0, Y, w - 2.0, 6.0, Color8(0x6d, 0x2f, 0x28))
		_hp(x0, Y + 1.0, w, 4.0, Color8(0x6d, 0x2f, 0x28))
		_hp(x0 + 2.0, Y + 1.0, w - 4.0, 2.0, Color.WHITE)
		for k in range(3, int(w) - 3, 4):
			_hp(x0 + k, Y + 1.0, 1.0, 2.0, Color8(0xc8, 0xc0, 0xb8))
		_hp(x0 + 3.0, Y + 4.0, w - 6.0, 1.0, Color.WHITE)
		_hp(x0 - 2.0, Y - 2.0, 2.0, 2.0, _renk(s[2]))
		_hp(x0 + w, Y - 2.0, 2.0, 2.0, _renk(s[2]))
		return true
	if J.truth(imp):
		var c := Color8(0xc4, 0x40, 0x5a) if kad else Color8(0x8d, 0x3a, 0x30)
		var x0 := X - 8.0 - d
		var w := 16.0 + 2.0 * d
		_hp(x0, Y + 2.0, w - 2.0, 2.0, c)
		_hp(x0 + w - 3.0, Y + 1.0, 3.0, 2.0, c)
		_hp(x0 + w - 1.0, Y, 1.0, 1.0, c)
		return true
	var tip := int(J.n(agiz))
	if kad:
		var x0 := X - 6.0 - d
		var w := 14.0 + 2.0 * d
		var ust := Color8(0xe2, 0x60, 0x7a)
		var alt := Color8(0xc4, 0x40, 0x5a)
		_hp(x0 + 1.0, Y, w / 2.0 - 2.0, 1.0, ust)
		_hp(x0 + w / 2.0 + 1.0, Y, w / 2.0 - 2.0, 1.0, ust)
		_hp(x0, Y + 1.0, w, 1.0, ust)
		_hp(x0, Y + 2.0, w, 1.0, alt.darkened(0.25))
		_hp(x0 + 1.0, Y + 3.0, w - 2.0, 1.0, alt)
		_hp(x0 + 3.0, Y + 3.0, 2.0, 1.0, alt.lightened(0.3))
		return true
	if tip == 3:
		var x0 := X - 6.0 - d
		var w := 14.0 + 2.0 * d
		_hp(x0 + 1.0, Y, w - 2.0, 1.0, Color8(0xa8, 0x54, 0x4a))
		_hp(x0, Y + 1.0, w, 2.0, Color8(0x8d, 0x3a, 0x30))
		_hp(x0 + 2.0, Y + 3.0, w - 4.0, 1.0, Color8(0x6d, 0x2f, 0x28))
		return true
	if tip == 4:
		var x0 := X - 4.0 - d
		var w := 10.0 + 2.0 * d
		_hp(x0 + 1.0, Y, w - 2.0, 1.0, Color8(0x7d, 0x35, 0x2c))
		_hp(x0, Y + 1.0, w, 1.0, Color8(0x7d, 0x35, 0x2c).darkened(0.1))
		return true
	var x1 := X - 6.0 - d
	var w1 := 14.0 + 2.0 * d
	var cz := Color8(0x8d, 0x3a, 0x30)
	_hp(x1 + 1.0, Y, w1 - 2.0, 2.0, cz)
	_hp(x1, Y - 1.0, 1.0, 2.0, cz)
	_hp(x1 + w1 - 1.0, Y - 1.0, 1.0, 2.0, cz)
	_hp(x1 + 4.0, Y + 2.0, w1 - 8.0, 1.0, Color(_renk(s[2]), 0.7))
	return true


# ---------------------------------------------------------------- HD temel sekiller
# pixel_primitives'in yuvarlak sekilleri (yuvarlak kose dikdortgen, disk, elips,
# halka) 2x izgarada: arayuz panelleri, balonlar, dugmeler ve henuz Blender'a
# tasinmamis prosedurel cizimler (hikaye, gece olaylari) ayni anda HD kenar
# kazanir. Dis sinirlar eski cizimle ayni; yalniz basamaklar yarim piksel.
# Donen / olcekli ctx, CPU tuvali veya HD kapaliyken eski yol (super).
func _prim_hd() -> bool:
	return hd_acik and draw_context is GpuCanvas and not _hd_kapali.has("prim") and _duz()

# yarim genislikten satir araligi: merkez C (HD), yari h -> [C-h, C+h) tam sayiya
func _hd_satir(C: float, yari: float) -> Vector2:
	var l := roundf(C - yari)
	var r := roundf(C + yari)
	return Vector2(l, r)

func f_rrect(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(x, y, w, h, r, c)
	var X := float(int(x)) * 2.0
	var Y := float(int(y)) * 2.0
	var W := float(int(w)) * 2.0
	var H := float(int(h)) * 2.0
	if W <= 0 or H <= 0: return null
	var col := _renk(c)
	var R := minf(float(r) * 2.0, minf(W, H) / 2.0)
	var ctx: GpuCanvas = draw_context
	var ri := int(ceilf(R))
	ctx.rect_hd(X, Y + ri, W, H - 2 * ri, col)
	var i := 0
	while i < ri:
		var v := R - i - 0.5
		var d := roundf(R - sqrt(maxf(0.0, R * R - v * v)))
		# ayni girintili satirlari birlestir
		var j := i + 1
		while j < ri:
			var v2 := R - j - 0.5
			if roundf(R - sqrt(maxf(0.0, R * R - v2 * v2))) != d: break
			j += 1
		ctx.rect_hd(X + d, Y + i, W - 2.0 * d, j - i, col)
		ctx.rect_hd(X + d, Y + H - j, W - 2.0 * d, j - i, col)
		i = j
	return null

func f_rrectOut(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(x, y, w, h, r, c)
	var X := float(int(x)) * 2.0
	var Y := float(int(y)) * 2.0
	var W := float(int(w)) * 2.0
	var H := float(int(h)) * 2.0
	if W <= 0 or H <= 0: return null
	var col := _renk(c)
	var R := minf(float(r) * 2.0, minf(W, H) / 2.0)
	var t := 2.0
	var ctx: GpuCanvas = draw_context
	var Ri := maxf(0.0, R - t)
	var Hi := H - 2.0 * t
	# satir tanimi (girinti, yan serit genisligi; -1 = dolu satir); ayni tanimli
	# ardisik satirlar TEK dikdortgen (baslik vinyeti 60 buyuk cerceve ciziyor)
	var onceki := Vector2(-2, -2)
	var bas := 0
	# duz kenar araligi: girinti 0, serit t (koseler disinda hesap gerekmez)
	var duz0 := int(ceilf(maxf(maxf(R, t + Ri), t)))
	var duz1 := int(floorf(minf(minf(H - R, t + Hi - Ri), H - t)))
	var i := 0
	while i <= int(H):
		var tanim := Vector2(-3, -3)
		if i >= duz0 and i < duz1 - 1:
			tanim = Vector2(0.0, t)
			if tanim == onceki:
				i = duz1 - 1
				continue
		elif i < int(H):
			var dis := 0.0
			if i < R: dis = roundf(R - sqrt(maxf(0.0, R * R - (R - i - 0.5) * (R - i - 0.5))))
			elif i >= H - R: dis = roundf(R - sqrt(maxf(0.0, R * R - (i + 0.5 - (H - R)) * (i + 0.5 - (H - R)))))
			if i < t or i >= H - t:
				tanim = Vector2(dis, -1.0)
			else:
				var k := i - t
				var ic := 0.0
				if k < Ri: ic = roundf(Ri - sqrt(maxf(0.0, Ri * Ri - (Ri - k - 0.5) * (Ri - k - 0.5))))
				elif k >= Hi - Ri: ic = roundf(Ri - sqrt(maxf(0.0, Ri * Ri - (k + 0.5 - (Hi - Ri)) * (k + 0.5 - (Hi - Ri)))))
				tanim = Vector2(dis, maxf(t, t + ic - dis))
		if tanim != onceki:
			if onceki.x >= 0:
				var n := float(i - bas)
				if onceki.y < 0:
					ctx.rect_hd(X + onceki.x, Y + bas, W - 2.0 * onceki.x, n, col)
				else:
					ctx.rect_hd(X + onceki.x, Y + bas, onceki.y, n, col)
					ctx.rect_hd(X + W - onceki.x - onceki.y, Y + bas, onceki.y, n, col)
			onceki = tanim
			bas = i
		i += 1
	return null

func f_disc(cx: Variant = null, cy: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(cx, cy, r, c)
	# eski disk kutup satirlarini atliyor (2r+1 genis, 2r-1 yuksek): dikeyde r - .5
	var rf := float(r)
	return _hd_elips(floorf(float(cx) + .5), floorf(float(cy) + .5), rf, maxf(0.0, rf - 0.5), _renk(c))

func f_ell(cx: Variant = null, cy: Variant = null, rx: Variant = null, ry: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(cx, cy, rx, ry, c)
	if float(ry) == 0.0: return null
	return _hd_elips(floorf(float(cx) + .5), floorf(float(cy) + .5), float(rx), float(ry), _renk(c))

# eski disk/elips pikselin merkezinden (cx+.5) rx+.5 yaricapla kapliyor
func _hd_elips(cx: float, cy: float, rx: float, ry: float, col: Color) -> Variant:
	var ctx: GpuCanvas = draw_context
	var CX := cx * 2.0 + 1.0
	var CY := cy * 2.0 + 1.0
	var RX := rx * 2.0 + 1.0
	var RY := ry * 2.0 + 1.0
	var n := int(RY)
	var onceki := Vector2(-1, -1)
	var bas := 0
	for j in range(-n, n + 1):
		var v := (j + 0.5) / RY
		var sp := Vector2(-1, -1)
		if absf(v) < 1.0 and j < n:
			sp = _hd_satir(CX, RX * sqrt(1.0 - v * v))
		if sp != onceki:
			if onceki.x >= 0 and onceki.y > onceki.x:
				ctx.rect_hd(onceki.x, CY + bas, onceki.y - onceki.x, j - bas, col)
			onceki = sp
			bas = j
	return null

func f_ring(cx: Variant = null, cy: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(cx, cy, r, c)
	var ctx: GpuCanvas = draw_context
	var col := _renk(c)
	var CX := floorf(float(cx) + .5) * 2.0 + 1.0
	var CY := floorf(float(cy) + .5) * 2.0 + 1.0
	var RO := float(r) * 2.0 + 1.0
	var RI := maxf(0.0, RO - 2.0)
	var n := int(RO)
	for j in range(-n, n):
		var yc := j + 0.5
		if absf(yc) >= RO: continue
		var dis := sqrt(RO * RO - yc * yc)
		if absf(yc) >= RI:
			var s := _hd_satir(CX, dis)
			ctx.rect_hd(s.x, CY + j, s.y - s.x, 1.0, col)
		else:
			var ic := sqrt(RI * RI - yc * yc)
			var so := _hd_satir(CX, dis)
			var si := _hd_satir(CX, ic)
			if si.x > so.x: ctx.rect_hd(so.x, CY + j, si.x - so.x, 1.0, col)
			if so.y > si.y: ctx.rect_hd(si.y, CY + j, so.y - si.y, 1.0, col)
	return null

# cizgi: 2x izgarada, 2x2 HD damga (kalinlik ayni, capraz basamaklar yarim piksel)
func f_ln(x0: Variant = null, y0: Variant = null, x1: Variant = null, y1: Variant = null, c: Variant = null) -> Variant:
	if not _prim_hd(): return super(x0, y0, x1, y1, c)
	var col := _renk(c)
	var ctx: GpuCanvas = draw_context
	var ax := float(int(x0)) * 2.0
	var ay := float(int(y0)) * 2.0
	var bx := float(int(x1)) * 2.0
	var by := float(int(y1)) * 2.0
	var n := int(maxf(absf(bx - ax), absf(by - ay)))
	if n == 0:
		ctx.rect_hd(ax, ay, 2.0, 2.0, col)
		return null
	# ayni satirdaki ardisik damgalari tek dikdortgende birlestir
	var sx := roundf(ax)
	var sy := roundf(ay)
	var ex := sx
	for i in range(1, n + 1):
		var t := i / float(n)
		var px := roundf(ax + (bx - ax) * t)
		var py := roundf(ay + (by - ay) * t)
		if py == sy and absf(px - ex) <= 1.0:
			ex = px
			continue
		ctx.rect_hd(minf(sx, ex), sy, absf(ex - sx) + 2.0, 2.0, col)
		sx = px
		sy = py
		ex = px
	ctx.rect_hd(minf(sx, ex), sy, absf(ex - sx) + 2.0, 2.0, col)
	return null


# ---------------------------------------------------------------- kesim araclari
# art.js drawKesimBicagi (4 kademe), drawSpit oto tiras makinesi.
# Blender: blender/models/arac_hd.py
func f_hdBicak(ux: Variant, uy: Variant, yon: Variant, kademe: Variant) -> bool:
	if not hd("arac"): return false
	var A := atlas("arac")
	var k := clampi(int(floorf(J.n(kademe) + 0.5)), 0, 3)
	var ad := "bicak_%d" % k
	if A.is_empty() or not A.parca.has(ad): return false
	var d := J.n(yon) if J.truth(yon) else -1.0
	hd_ciz(A, ad, floorf(J.n(ux) + 0.5), floorf(J.n(uy) + 0.5), 1.0, d > 0.0)
	return true

func f_hdOtoTiras(rx0: Variant, top: Variant, t: Variant) -> bool:
	if not hd("arac"): return false
	var A := atlas("arac")
	if A.is_empty() or not A.parca.has("oto_motor"): return false
	var X := J.n(rx0)
	var Y := J.n(top)
	hd_ciz(A, "oto_ray", X, Y)
	hd_ciz(A, "oto_motor", X, Y)
	var wa := J.n(t) * 9.0
	var cx := (X + 1.5) * 2.0
	var cy := (Y - 9.5) * 2.0
	for i in 6:                      # donen teker cubugu (yarim piksel adimli)
		var r := 1.0 + i
		_hp(roundf(cx + cos(wa) * r) - 1.0, roundf(cy + sin(wa) * r) - 1.0, 2.0, 2.0, Color8(0x2f, 0x37, 0x40))
	return true

func f_hdOtoLed(rx0: Variant, top: Variant, yanik: bool) -> void:
	var x := (J.n(rx0) - 4.8) * 2.0
	var y := (J.n(top) - 13.6) * 2.0
	if yanik:
		_hp(x - 1.0, y - 1.0, 5.0, 5.0, Color(0.49, 1.0, 0.48, 0.25))
	_hp(x, y, 3.0, 3.0, Color8(0x7d, 0xff, 0x7a) if yanik else Color8(0x2a, 0x6a, 0x28))
	if yanik: _hp(x, y, 1.0, 1.0, Color.WHITE)

func f_hdOtoAraba(rx0: Variant, cy2: Variant) -> bool:
	if not hd("arac"): return false
	var A := atlas("arac")
	if A.is_empty() or not A.parca.has("oto_araba"): return false
	hd_ciz(A, "oto_araba", J.n(rx0), J.n(cy2))
	return true

# et talasi (parcacik): art.js drawEtDilimi egrisi 2x ornekle
func f_hdEtDilimi(x: Variant, y: Variant, kv: Variant, k: Variant, sc: Variant) -> bool:
	if not hd("arac"): return false
	var S := J.n(sc) if J.truth(sc) else 1.0
	var K := J.n(k)
	var boy := floorf((5.0 + J.n(f_hash1(K * 3.1)) * 3.0) * S + 0.5)
	var don := J.n(f_hash1(K * 7.7)) * 0.9 - 0.45
	var X := floorf(J.n(x) + 0.5)
	var Y := floorf(J.n(y) + 0.5)
	var KV := J.n(kv)
	var kabuk := Color8(0x7e, 0x44, 0x12)
	var koyu := Color8(0x9c, 0x57, 0x18)
	var govde := Color8(0xbd, 0x70, 0x24)
	var acik := Color8(0xee, 0xb4, 0x63)
	var n := int(boy) * 7            # kivrik talasta ardisik ornekler bosluk birakmasin
	for i in n:
		var u := i / float(n - 1) if n > 1 else 0.5
		var a := u * PI * 1.35 * KV + don
		var cx := roundf((X + sin(a) * boy * 0.55) * 2.0)
		var cy := roundf((Y + (1.0 - cos(a)) * boy * 0.4 - roundf(boy * 0.2)) * 2.0)
		var kal := 2.0 + (2.0 if (u > 0.18 and u < 0.82) else 0.0)
		_hp(cx, cy, 2.0, kal + 2.0, kabuk)
		_hp(cx, cy, 2.0, 2.0, govde if u < 0.5 else koyu)
		if kal > 2.0:
			_hp(cx, cy + 2.0, 2.0, 2.0, acik if u < 0.55 else govde)
	_hp(roundf((X + sin(don) * boy * 0.55) * 2.0), roundf((Y - roundf(boy * 0.2)) * 2.0), 2.0, 1.0, Color8(0xff, 0xd2, 0x91))
	return true

# ---------------------------------------------------------------- imlec
# food.js drawCursor: ok (isaret), yumruk (tutma), bicak. Maskeler bir kez
# 2x cozunurlukte isaretli mesafe alanindan uretilir (murekkep kenar, beyaz ic).
var _imlec_doku: Dictionary = {}

func _sdf_kutu(p: Vector2, a: Vector2, b: Vector2, r: float) -> float:
	var c := (a + b) * 0.5
	var h := (b - a) * 0.5 - Vector2(r, r)
	var q := (p - c).abs() - h
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - r

func _sdf_cokgen(p: Vector2, P: PackedVector2Array) -> float:
	var d := INF
	var ic := false
	var n := P.size()
	for i in n:
		var a := P[i]
		var b := P[(i + 1) % n]
		var ab := b - a
		var t := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		d = minf(d, (p - (a + ab * t)).length())
		if ((a.y > p.y) != (b.y > p.y)) and (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x):
			ic = not ic
	return -d if ic else d

func _imlec_uret(tur: String) -> ImageTexture:
	# mantik 10x12 alan, 2x
	var W := 22
	var H := 24
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var ok := PackedVector2Array([Vector2(1.0, 0.0), Vector2(8.2, 7.0), Vector2(5.0, 7.0), Vector2(2.4, 10.8), Vector2(1.0, 10.8)])
	var murekkep := Color8(0x24, 0x1a, 0x20)
	for j in H:
		for i in W:
			var p := Vector2((i + 0.5) / 2.0, (j + 0.5) / 2.0)
			var d: float
			if tur == "ok":
				d = _sdf_cokgen(p, ok)
			else:
				d = _sdf_kutu(p, Vector2(1.6, 0.2), Vector2(4.6, 6.0), 1.4)
				d = minf(d, _sdf_kutu(p, Vector2(0.2, 4.2), Vector2(8.0, 9.2), 2.2))
				d = minf(d, _sdf_kutu(p, Vector2(5.4, 1.8), Vector2(8.0, 6.0), 1.2))
			if d > 0.0: continue
			if d > -0.75:
				img.set_pixel(i, j, murekkep)
			else:
				var gol := d > -1.25 and (p.x > 4.5 or p.y > 7.5)
				img.set_pixel(i, j, Color8(0xd4, 0xd8, 0xe0) if gol else Color.WHITE)
	if tur == "yumruk":
		# parmak araligi cizgileri
		for j in range(12, 17):
			img.set_pixel(10, j, murekkep)
			img.set_pixel(13, j, murekkep)
	return ImageTexture.create_from_image(img)

func f_hdImlec(x: Variant, y: Variant, mode: Variant) -> bool:
	if not hd("imlec"): return false
	var X := floorf(J.n(x) + 0.5)
	var Y := floorf(J.n(y) + 0.5)
	if mode == "knife":
		var ink := Color8(0x2b, 0x20, 0x18)
		_hp(X * 2 - 2, Y * 2 - 2, 6, 25, ink)
		_hp(X * 2 - 1, Y * 2 - 4, 4, 2, ink)
		_hp(X * 2, Y * 2 - 5, 2, 1, ink)
		_hp(X * 2, Y * 2 - 1, 3, 22, Color8(0xe8, 0xee, 0xf4))
		_hp(X * 2, Y * 2 - 3, 2, 2, Color8(0xe8, 0xee, 0xf4))
		_hp(X * 2, Y * 2 - 1, 1, 22, Color.WHITE)
		_hp(X * 2 + 2, Y * 2 + 2, 1, 19, Color8(0xb6, 0xc0, 0xc9))
		var P: Dictionary = get("j_P")
		_hp(X * 2 - 4, Y * 2 + 22, 10, 10, _renk(P.wd2))
		_hp(X * 2 - 4, Y * 2 + 22, 10, 2, _renk(P.wd1))
		_hp(X * 2 - 4, Y * 2 + 31, 10, 1, ink)
		return true
	var tur := "yumruk" if mode == "grab" else "ok"
	if not _imlec_doku.has(tur):
		_imlec_doku[tur] = _imlec_uret(tur)
	var tex: ImageTexture = _imlec_doku[tur]
	draw_context.texture_hd(tex, Rect2(0, 0, tex.get_width(), tex.get_height()), X, Y)
	return true


# ---------------------------------------------------------------- olay karakterleri
# art.js drawAsker / drawGozcu / drawThief / drawRakip / drawKedi / drawScooter,
# denetci panosu. Blender: blender/models/olay_hd.py. Hareket formulleri ve
# rastgele sayi tuketimi (f_chance) eski cizimle ayni.
func _olay() -> Dictionary:
	if not hd("olay"): return {}
	var A := atlas("olay")
	if A.is_empty() or not A.parca.has("asker_govde"): return {}
	return A

func f_hdAsker(x: Variant, y: Variant, t: Variant, dir: Variant, faz: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var X := f_hdYarimPx(x)
	var Y := f_hdYarimPx(y)
	var ayna := J.n(dir) <= 0.0
	var f := J.n(t) * 5.4 + J.n(faz)
	draw_context.globalAlpha = 0.24
	f_ell(X, Y, 3.0, 1.0, "#000")
	draw_context.globalAlpha = 1.0
	var ph := int(floorf(fposmod(f, 8.0)))
	var ka := int(floorf(sin(f) + 0.5))
	var ex := X + 0.5 if ayna else X
	hd_ciz(A, "asker_bacak_%d" % ph, ex, Y, 1.0, ayna)
	hd_ciz(A, "asker_govde", ex, Y, 1.0, ayna)
	hd_ciz(A, "asker_kol_%d" % clampi(ka + 1, 0, 2), ex, Y, 1.0, ayna)
	return true

func f_hdGozcu(x: Variant, y: Variant, t: Variant, bakiyor: Variant, sorgu: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var X := f_hdYarimPx(x)
	var Y := f_hdYarimPx(y)
	var bak := J.truth(bakiyor)
	var sor := J.truth(sorgu)
	var cephe := bak or sor
	var gz: Variant = get("j_G").get("gozcu")
	var yon := -1.0 if (J.truth(gz) and J.n(gz.dir) < 0.0) else 1.0
	var T := J.n(t)
	draw_context.globalAlpha = 0.26
	f_ell(X, Y, 4.0 if cephe else 3.0, 1.0, "#000")
	draw_context.globalAlpha = 1.0
	if cephe:
		hd_ciz(A, "gozcu_cephe_bacak", X, Y)
		hd_ciz(A, "gozcu_cephe_sor" if sor else "gozcu_cephe_bak", X, Y)
	else:
		var ayna := yon < 0.0
		var ex := X + 0.5 if ayna else X
		hd_ciz(A, "gozcu_bacak_%d" % int(floorf(fposmod(T * 6.0, 8.0))), ex, Y, 1.0, ayna)
		hd_ciz(A, "gozcu_yan", ex, Y, 1.0, ayna)
		var ka := floorf(sin(T * 6.0) + 0.5)
		_hp((X + (2.0 if yon > 0.0 else -3.0)) * 2.0, (Y - 8.0 + ka) * 2.0, 2.0, 3.0, Color8(0x19, 0x1c, 0x21))
	if sor:
		var uy := Y - 22.0 + floorf(sin(T * 9.0) + 0.5)
		_hr(X, uy, 1.0, 3.0, "#e2483a")
		_hr(X, uy + 4.0, 1.0, 1.0, "#e2483a")
		draw_context.globalAlpha = 0.3
		f_disc(X, uy + 2.0, 4.0, "#e2483a")
		draw_context.globalAlpha = 1.0
	if bak:
		draw_context.globalAlpha = 0.45 + 0.45 * sin(T * 7.0)
		_hp(X * 2.0, (Y - 14.4) * 2.0, 2.0, 2.0, Color8(0xff, 0xf3, 0xc0))
		draw_context.globalAlpha = 1.0
	return true

func f_hdHirsiz(x: Variant, y: Variant, t: Variant, phase: Variant, running: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var T := J.n(t)
	var kos := J.truth(running)
	var sway := sin(T * 11.0) * 1.2 if (J.n(phase) == 0.0 or kos) else 0.0
	var bob := sin(T * 2.2) * 0.8
	var X := f_hdYarimPx(J.n(x) + sway)
	var Y := f_hdYarimPx(J.n(y) + bob)
	draw_context.globalAlpha = 0.38
	f_ell(X, Y + 1.0, 14.0, 3.0, "#000")
	draw_context.globalAlpha = 1.0
	var ao := floorf(sin(T * 15.0) * 4.0 + 0.5) / 2.0 if kos else 0.0
	hd_ciz(A, "hirsiz_govde", X, Y)
	hd_ciz(A, "hirsiz_kol_sol", X, Y + ao)
	hd_ciz(A, "hirsiz_kol_sag", X, Y - ao)
	hd_ciz(A, "hirsiz_bas", X, Y)
	var sx := X + 20.0
	var sy := Y - 30.0 + 8.0 - ao + floorf(sin(T * 6.0) * 1.2 + 0.5)
	draw_context.globalAlpha = 0.3
	f_ell(sx, sy + 15.0, 8.0, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	hd_ciz(A, "hirsiz_canta", sx, sy)
	return true

# "govde": yalniz gövde (musteri katmani), "balon": yalniz konusma balonu,
# "": ikisi (eski tek gecis)
var rakip_kip := ""

func f_hdRakip(t: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var G: Dictionary = get("j_G")
	var R: Variant = G.get("rakip")
	if not J.truth(R) or R.faz == "yok": return true
	var X := floorf(J.n(R.x) + 0.5)
	var slots: Variant = get("j_LAY").get("custSlots")
	var Y := J.n(slots[0].y) if (slots is Array and slots.size() > 0 and J.truth(slots[0])) else 152.0
	Y = floorf(Y + sin(J.n(t) * 2.2) * 0.8 + 0.5)
	if rakip_kip != "balon": hd_ciz(A, "rakip", X, Y)
	if rakip_kip != "govde" and J.n(R.get("sonT", 0.0)) > 0.0 and J.truth(R.get("son")):
		var metin: Variant = _c("f_T", R.son)
		var bw: float = J.n(_c("f_textW", metin)) + 10.0
		var bx := clampf(X - bw / 2.0, 4.0, J.n(get("j_W")) - bw - 4.0)
		draw_context.globalAlpha = clampf(J.n(R.sonT), 0.0, 1.0)
		f_rrect(bx, Y - 68.0, bw, 13.0, 3.0, "rgba(24,18,14,.88)")
		f_rrectOut(bx, Y - 68.0, bw, 13.0, 3.0, "#6b5a48")
		f_fr(X - 2.0, Y - 56.0, 4.0, 3.0, "rgba(24,18,14,.88)")
		_c("f_txt", metin, bx + bw / 2.0, Y - 65.0, "#f0e2c8", {"align": "c"})
		draw_context.globalAlpha = 1.0
	return true

func f_hdKedi(t: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var K: Variant = get("j_G").get("kedi")
	if not J.truth(K) or K.faz == "yok": return true
	var X := floorf(J.n(K.x) + 0.5)
	var Y: float = J.n(_c("f_kediY"))
	var T := J.n(t)
	draw_context.globalAlpha = 0.26
	f_ell(X, Y, 8.0, 2.0, "#000")
	draw_context.globalAlpha = 1.0
	if K.faz == "yiyor":
		hd_ciz(A, "kedi_yiyor", X, Y)
	elif K.faz == "gelis" or K.faz == "gidis":
		var sek := floorf(sin(T * 9.0) + 0.5)
		var b := floorf(sin(T * 11.0) * 1.5 + 0.5)
		var kt := floorf(sin(T * 6.0) * 2.0 + 0.5)
		# kedi hep SOLA yurur (sagdan gelir, soldan gider); eski cizimde bas saga
		# bakiyordu (geri geri yuruyordu) -> yuruyus kareleri aynali
		hd_ciz(A, "kedi_kuyruk", X, Y + sek + kt, 1.0, true)
		hd_ciz(A, "kedi_bacak_arka", X, Y + sek, 1.0, true)
		hd_ciz(A, "kedi_yuru", X, Y + sek, 1.0, true)
		hd_ciz(A, "kedi_bacak_on", X, Y + sek - b, 1.0, true)
	else:
		hd_ciz(A, "kedi_otur_kuyruk", X, Y + floorf(sin(T * 3.2) * 2.0 + 0.5))
		hd_ciz(A, "kedi_otur", X, Y)
	if J.n(K.get("miyav", 0.0)) > 0.0:
		draw_context.globalAlpha = clampf(J.n(K.miyav), 0.0, 1.0)
		var mw: float = J.n(_c("f_textW", "miyav")) + 6.0
		f_rrect(X - mw / 2.0, Y - 30.0, mw, 10.0, 3.0, "rgba(20,16,14,.82)")
		_c("f_txt", "miyav", X, Y - 28.0, "#ffe6b0", {"align": "c"})
		draw_context.globalAlpha = 1.0
	return true

func _olcekli_ciz(A: Dictionary, ad: String, x: float, y: float, sc: float) -> void:
	var p: Variant = A.parca.get(ad)
	if p == null: return
	draw_context.texture_hd(A.tex, Rect2(p[0], p[1], p[2], p[3]), x + p[4] * sc, y + p[5] * sc)

func f_hdScooter(x: Variant, y: Variant, t: Variant, sc: Variant) -> bool:
	var A := _olay()
	if A.is_empty(): return false
	var S := J.n(sc) if J.truth(sc) else 1.0
	var ek := ""
	if absf(S - 0.6) < 0.01: ek = "_60"
	elif absf(S - 1.0) > 0.01: return false
	var X := J.n(x)
	var Y := J.n(y)
	var wob := floorf(sin(J.n(t) * 22.0) * 0.6 + 0.5)
	# BIRLESIK: kurye cikarken sola gider (x 24 -> -60) ama model saga bakiyordu
	# (kullanici: "motor animasyonu ters, diger tarafa bakmasi lazim").
	# Cikista ayna; donuste (saga gider) oldugu gibi.
	var cr: Variant = get("j_G").get("courier")
	var ayna: bool = S == 1.0 and cr is Dictionary and cr.get("state") == "leaving"
	draw_context.globalAlpha = 0.28
	f_ell(X, Y + 6.0 * S, 16.0 * S, maxf(1.0, 3.0 * S), "#000")
	draw_context.globalAlpha = 1.0
	if ayna:
		hd_ciz(A, "scooter_arac", X, Y, 1.0, true)
		hd_ciz(A, "scooter_surucu", X, Y, 1.0, true)
		hd_ciz(A, "scooter_bas", X, Y + wob, 1.0, true)
	else:
		_olcekli_ciz(A, "scooter_arac" + ek, X, Y, S)
		_olcekli_ciz(A, "scooter_surucu" + ek, X, Y, S)
		_olcekli_ciz(A, "scooter_bas" + ek, X, Y + wob * S, S)
	if J.truth(_c("f_chance", 0.35)):
		_c("f_smoke", X + (16.0 if ayna else -16.0), Y + 2.0, 1.0, "rgba(120,110,100,.5)")
	return true

func f_hdPano(bx: Variant, by: Variant) -> bool:
	var A := _olay()
	if A.is_empty() or not A.parca.has("pano"): return false
	hd_ciz(A, "pano", J.n(bx), J.n(by))
	return true


# ---------------------------------------------------------------- telefon, denetim lambasi, gece
# game.js drawPhone / drawPhoneMuhurlu / drawDenetimLambasi, ui.js drawNight
# (alarm, kilit, fener), drawKesinti (izgara kor isigi). Blender: gece_hd.py
func _gece() -> Dictionary:
	if not hd("gece"): return {}
	var A := atlas("gece")
	if A.is_empty() or not A.parca.has("telefon_govde"): return {}
	return A

func f_hdTelefon(x: Variant, y: Variant, caliyor: bool, sh: Variant) -> bool:
	var A := _gece()
	if A.is_empty(): return false
	var X := J.n(x)
	var Y := J.n(y)
	hd_ciz(A, "telefon_govde", X, Y)
	hd_ciz(A, "telefon_ahize", X, Y + (1.0 if caliyor else 2.0) + J.n(sh))
	return true

func f_hdTelefonMuhur() -> bool:
	var A := _gece()
	if A.is_empty(): return false
	var s: Dictionary = get("j_ST").phone
	var X := J.n(s.x)
	var Y := J.n(s.y)
	hd_ciz(A, "telefon_govde_m", X, Y)
	hd_ciz(A, "telefon_ahize_m", X, Y + 2.0)
	hd_ciz(A, "telefon_bant", X, Y)
	return true

func f_hdDenetimLambasi(t: Variant) -> bool:
	var A := _gece()
	if A.is_empty(): return false
	if not J.truth(get("j_G").get("ferman")): return true
	var k: Array = _c("f_denetimLambaKutu")
	var x := J.n(k[0])
	var y := J.n(k[1])
	var s := J.n(_c("f_denetimSeviye"))
	var yaniyor := s >= 1.0
	var isiniyor := s > 0.0 and s < 1.0
	var pz := 0.5 + 0.5 * sin(J.n(t) * (7.0 if yaniyor else 3.0))
	hd_ciz(A, "denetim_govde", x, y)
	if s > 0.0:
		draw_context.globalAlpha = (0.18 if isiniyor else 0.3) + 0.22 * pz * s
		f_disc(x + 7.0, y + 9.0, 8.0 + (pz * 3.0 if yaniyor else 0.0), "#ff5a44" if yaniyor else "#e0a03a")
		draw_context.globalAlpha = 1.0
	hd_ciz(A, "denetim_cam_%d" % (2 if yaniyor else (1 if isiniyor else 0)), x, y)
	if s > 0.0:
		draw_context.globalAlpha = 0.5 + 0.5 * pz
		_hp((x + 5.0) * 2.0, (y + 8.0) * 2.0, 6.0, 3.0, Color.WHITE)
		draw_context.globalAlpha = 1.0
	if yaniyor:
		draw_context.globalAlpha = 0.16 + 0.1 * pz
		f_fr(x - 10.0, y + 2.0, 34.0, 20.0, "#c8321e")
		draw_context.globalAlpha = 1.0
	return true

func f_hdAlarm(ax: Variant, ay: Variant, acik: Variant) -> bool:
	var A := _gece()
	if A.is_empty(): return false
	hd_ciz(A, "alarm_1" if J.truth(acik) else "alarm_0", J.n(ax), J.n(ay))
	return true

func f_hdKilit(lx: Variant, ly: Variant) -> bool:
	var A := _gece()
	if A.is_empty(): return false
	hd_ciz(A, "kilit", J.n(lx), J.n(ly))
	return true

func f_hdFener(tx: Variant, ty: Variant, t: Variant) -> bool:
	var A := _gece()
	if A.is_empty(): return false
	var a := 0.83 + 0.33 * sin(J.n(t) * 9.0)
	hd_ciz(A, "fener_isik", J.n(tx), J.n(ty), a)
	_hp((J.n(tx) + 8.0) * 2.0, (J.n(ty) - 20.0) * 2.0, 3.0, 2.0, Color8(0xff, 0xf6, 0xc8))
	return true

# ELEKTRIK KESINTISI (birlesik surum): tam ekran shader (shaders/kesinti.gdshader)
# karanlik + ocaktan gauss sonumlu titrek sicak hale + pencereden soguk isik;
# ocak rezistanslari karanligin USTUNE parlak cizilir (tek isik kaynagi onlar).
var _kesinti_mat: ShaderMaterial

func f_hdKesinti(t: Variant, acilma: Variant) -> bool:
	if not hd("kesinti"): return false
	if _kesinti_mat == null:
		_kesinti_mat = ShaderMaterial.new()
		_kesinti_mat.shader = load("res://shaders/kesinti.gdshader")
	var LAY: Dictionary = get("j_LAY")
	var W: float = J.n(get("j_W"))
	var H: float = J.n(LAY.floorY)
	var cx: float = J.n(LAY.spit.cx)
	var top: float = J.n(LAY.spit.top)
	var H0: float = J.n(LAY.spit.bot) - top
	var hx := cx + 19.0
	var hy := top + 2.0
	var hh := H0 - 14.0
	var T := J.n(t)
	var titre := 0.5 + 0.5 * sin(T * 5.3) * sin(T * 1.7)
	var G: Dictionary = LAY.glass
	_kesinti_mat.set_shader_parameter("boyut", Vector2(W, H))
	_kesinti_mat.set_shader_parameter("isik", Vector2(hx + 8.5, hy + hh / 2.0))
	_kesinti_mat.set_shader_parameter("cam", Vector4(J.n(G.x), J.n(G.y), J.n(G.w), J.n(G.h)))
	_kesinti_mat.set_shader_parameter("karanlik", 0.84 - J.n(acilma) * 0.14)
	_kesinti_mat.set_shader_parameter("titre", titre)
	draw_context.tutulan.append(_kesinti_mat)
	draw_context.shader_quad(0.0, 0.0, W, H, _kesinti_mat.get_rid(), Color.WHITE)
	# rezistanslar: karanligin ustunde tam parlak
	var seg := floorf((hh - 8.0) / 6.0)
	for i in 6:
		var fl := 0.55 + 0.45 * sin(T * 6.0 + i * 1.9)
		if not f_hdIsiticiEleman(hx + 3.0, hy + 4.0 + i * seg, fl):
			f_fr(hx + 3.0, hy + 4.0 + i * seg, 11.0, maxf(1.0, seg - 4.0), "#e0500f")
	return true

func f_hdKesintiIsik(pcx: Variant, pcy: Variant, hx: Variant, hy: Variant, titre: Variant) -> bool:
	var A := _gece()
	if A.is_empty() or not A.parca.has("kesinti_ic"): return false
	var tr := J.n(titre)
	hd_ciz(A, "kesinti_isik", J.n(pcx), J.n(pcy), 0.82 + tr * 0.18)
	hd_ciz(A, "kesinti_ic", J.n(hx), J.n(hy), 0.2 + tr * 0.07)
	return true


# ---------------------------------------------------------------- prolog (hikaye) sahneleri
# prologue.js: panel 400x150 (40, 44). Sabit katmanlar Blender'dan
# (blender/models/prolog_hd.py); hareketli parcalar eski formullerle
# konumlanir, kucuk isik/kor efektleri eski cizimle kalir. Rastgele sayi
# tuketimi (f_chance, f_rnd) ayni sirada.
func _prolog(ad: String) -> Dictionary:
	if not hd("prolog"): return {}
	var A := atlas("prolog")
	if A.is_empty() or not A.parca.has(ad): return {}
	return A

func f_hdProShopDay(t: Variant, _k: Variant) -> bool:
	var A := _prolog("p1_arka")
	if A.is_empty(): return false
	var T := J.n(t)
	hd_ciz(A, "p1_arka", 40.0, 44.0)
	# ocak korlari + sicak hale (pro1Ocak)
	for i in 5:
		var kor := sin(T * 3.0 + i * 1.7) > -0.2
		_c("f_pb", -66.0 + i * 6.0, -21.0, -62.0 + i * 6.0, -18.0, (("#ffb04a" if i % 2 == 1 else "#ff7a2a") if kor else "#a83a12"))
	_c("f_pbA", -76.0, -26.0, -28.0, 22.0, "#ff9a3a", 0.18 + 0.05 * sin(T * 2.1))
	_c("f_pbA", -86.0, -32.0, 86.0, -22.0, "#ffb84a", 0.1)
	var kol := floorf(sin(T * 1.9) * 2.0 + 0.5)
	hd_ciz(A, "p1_baba_govde", 40.0, 44.0)
	hd_ciz(A, "p1_baba_kol", 40.0, 44.0 - kol)
	hd_ciz(A, "p1_baba_bas" if fposmod(T * 0.7, 4.0) > 0.12 else "p1_baba_bas_kirp", 40.0, 44.0)
	hd_ciz(A, "p1_tezgah", 40.0, 44.0)
	_c("f_proSis", -52.0, -22.0, 18.0, 11.0, 2.8, T)
	if J.truth(_c("f_chance", 0.3)):
		_c("f_part", {"x": J.n(_c("f_pbx", -52.0)) + J.n(_c("f_rnd", -7.0, 7.0)), "y": _c("f_pby", 16.0), "vx": _c("f_rnd", -5.0, 5.0), "vy": _c("f_rnd", -20.0, -9.0), "life": 1.1, "col": "rgba(255,235,205,.35)", "g": -14.0, "sz": 1.0})
	# cam, cerceve, tente, tabela (pro1On)
	_c("f_proYansima", -76.0, -4.0, 4.0, 74.0, 0.15)
	_c("f_proYansima", -69.0, -4.0, 2.0, 74.0, 0.11)
	_c("f_proYansima", 64.0, -4.0, 3.0, 72.0, 0.13)
	_c("f_proYansima", 71.0, -4.0, 2.0, 72.0, 0.09)
	hd_ciz(A, "p1_on", 40.0, 44.0)
	# sokak (pro1Sokak)
	_c("f_txt", "USTA DÖNER", _c("f_pbx", 0.0), _c("f_pby", 55.0), "#ffd75e", {"align": "c", "sc": 1.0, "outline": "#7a1a12"})
	for i in 12:
		var yan := sin(T * 4.0 + i * 0.7) > -0.3
		var bx := -86.0 + i * 16.0
		if yan:
			draw_context.globalAlpha = 0.35
			f_disc(J.n(_c("f_pbx", bx)), J.n(_c("f_pby", 39.0)), 3.0, "#fff0b0")
			draw_context.globalAlpha = 1.0
		_hp(J.n(_c("f_pbx", bx - 2.0)) * 2.0 + 1.0, J.n(_c("f_pby", 41.0)) * 2.0 + 1.0, 6.0, 6.0, Color8(0xff, 0xf0, 0xb0) if yan else Color8(0x8a, 0x7a, 0x4a))
	for i in 3:
		var sal := floorf(sin(T * 1.3 + i) * 1.2 + 0.5)
		hd_ciz(A, "p1_kisi_%d" % i, 40.0 + sal, 44.0)
	var mu := fposmod(T * 0.1, 1.35)
	if mu < 1.0:
		var yx := 60.0 - mu * 210.0
		var faz := T * 7.0
		var bacak := clampi(int(floorf(sin(faz) * 3.0 + 0.5)), -3, 3)
		var zip := 1 if sin(faz * 2.0) > 0.0 else 0
		hd_ciz(A, "p1_yuru_%d_%d" % [bacak, zip], 240.0 + yx, 44.0)
	hd_ciz(A, "p1_lamba_isik", 40.0, 44.0)
	hd_ciz(A, "p1_lamba", 40.0, 44.0)
	_c("f_proBirds", T, 40.0, 44.0, 400.0, 3.0, 0.09)
	_huzmeler(16, 64.0, 22.0, 8, 0.07 + 0.03 * sin(T), "#ffe9a0")
	return true

# prolog sis dilimi (prologue.js proSis): ayni profil ve et renkleri 2x satirla
func f_hdProSis(cx: Variant, z0: Variant, z1: Variant, r0: Variant, r1: Variant, t: Variant) -> bool:
	if not _prim_hd(): return false
	var PR: Array = get("j_PRO_SIS_PROFIL")
	var son := PR.size() - 1
	var n := J.n(z1) - J.n(z0)
	var sx := (240.0 + J.n(cx)) * 2.0
	var sy := (133.0 - J.n(z1)) * 2.0
	var R0 := J.n(r0)
	var R1 := J.n(r1)
	var T := J.n(t)
	var bant := [[-1.0, -0.58, 0.6], [-0.58, -0.18, 0.82], [-0.18, 0.24, 1.08], [0.24, 0.62, 1.3], [0.62, 1.0, 0.88]]
	var H := int(n * 2.0)
	for m in H:
		var v := m / float(H - 1)
		var fi := v * son
		var f0 := mini(son, int(fi))
		var pr: float = PR[f0] + (PR[mini(f0 + 1, son)] - PR[f0]) * (fi - f0)
		var rr := (R1 + (R0 - R1) * pr) * (1.0 + 0.035 * sin(v * 11.0 + T * 0.8)) * 2.0
		var zz := J.n(z1) - m / 2.0
		var lay := sin(zz * 0.62 + sin(zz * 0.19) * 1.6)
		var dilim := -0.16 if fposmod(fposmod(zz, 7.0) + 7.0, 7.0) < 1.0 else 0.0
		var w2 := maxf(2.0, roundf(rr))
		_hp(sx - w2 - 2.0, sy + m, w2 * 2.0 + 4.0, 1.0, _renk("#40200a"))
		for b in bant:
			var xa := roundf(sx + b[0] * w2)
			var xb := roundf(sx + b[1] * w2)
			if xb > xa:
				_hp(xa, sy + m, xb - xa, 1.0, _renk(f_meatCol(0.85, b[2] + lay * 0.1 + dilim)))
		_hp(sx + w2 - 3.0, sy + m, 3.0, 1.0, _renk(f_meatCol(0.95, 0.46 + lay * 0.06)))
	var dk := sin(T * 1.4) * 0.72
	draw_context.globalAlpha = 0.34
	for m in range(4, H - 4, 2):
		var v3 := 1.0 - m / float(H - 1)
		var w3 := maxf(2.0, roundf((R1 + (R0 - R1) * v3) * 2.0))
		_hp(roundf(sx + dk * w3), sy + m, 2.0, 2.0, _renk("#5a3418"))
	draw_context.globalAlpha = 1.0
	return true


func _pbx(x: float) -> float: return 240.0 + x
func _pby(z: float) -> float: return 133.0 - z
func _pb(x0: float, z0: float, x1: float, z1: float, c: String) -> void:
	_c("f_pb", x0, z0, x1, z1, c)
func _pbA(x0: float, z0: float, x1: float, z1: float, c: String, a: float) -> void:
	_c("f_pbA", x0, z0, x1, z1, c, a)
func _rnd(a: float, b: float) -> Variant:
	return _c("f_rnd", a, b)

# sahne 2: babanin yakin plani
func f_hdProFather(t: Variant, _k: Variant) -> bool:
	var A := _prolog("p2_arka")
	if A.is_empty() or not A.parca.has("p2_kol"): return false
	var T := J.n(t)
	hd_ciz(A, "p2_arka", 40.0, 44.0)
	var X := -136.0
	hd_ciz(A, "p2_ocak_arka", 40.0, 44.0)
	for i in 12:
		var bz := -43.0 + i * 7.0
		var yan := sin(T * 2.2 + i * 0.8) > -0.35
		_pb(X - 25.0, bz, X + 25.0, bz + 5.0, "#c0421a" if yan else "#7a2c0c")
		_pb(X - 25.0, bz + 1.0, X + 25.0, bz + 4.0, "#ff7a2a" if yan else "#a83a12")
		_pb(X - 25.0, bz + 2.0, X + 25.0, bz + 3.0, "#ffb04a" if yan else "#c0421a")
		_pb(X - 25.0, bz + 5.0, X + 25.0, bz + 6.0, "#1c1c24")
	hd_ciz(A, "p2_ocak_on", 40.0, 44.0)
	_c("f_proSis", X, -40.0, 30.0, 20.0, 5.0, T)
	hd_ciz(A, "p2_ocak_ust", 40.0, 44.0)
	_pbA(X - 6.0, -48.0, X + 4.0, -44.0, "#7a3f12", 0.35)
	hd_ciz(A, "p2_hale", 40.0, 44.0, clampf(0.88 + 0.26 * sin(T * 1.7), 0.0, 1.0))
	hd_ciz(A, "p2_baba", 40.0, 44.0)
	hd_ciz(A, "p2_goz_kapali" if fposmod(T * 0.62, 4.4) < 0.13 else "p2_goz_acik", 40.0, 44.0)
	hd_ciz(A, "p2_puskul", 40.0 + floorf(sin(T * 1.6) * 3.0 + 0.5), 44.0)
	hd_ciz(A, "p2_kol", 40.0, 44.0)
	if J.truth(_c("f_chance", 0.14)):
		_c("f_part", {"x": _pbx(-34.0) + J.n(_rnd(-16.0, 16.0)), "y": _pby(-24.0), "vx": _rnd(-5.0, 5.0), "vy": _rnd(-20.0, -9.0), "life": 1.1, "col": "rgba(255,235,205,.4)", "g": -12.0, "sz": 1.0})
	hd_ciz(A, "p2_atmosfer", 40.0, 44.0)
	return true

# sahne 3: kapali dukkan, kar
func f_hdProClosed(t: Variant, _k: Variant) -> bool:
	var A := _prolog("p3_arka")
	if A.is_empty() or not A.parca.has("p3_kagit"): return false
	var T := J.n(t)
	hd_ciz(A, "p3_arka", 40.0, 44.0)
	var kalk := maxf(0.0, sin(T * 1.1)) * 3.0
	hd_ciz(A, "p3_kagit", 40.0, 44.0)
	_pb(-64.0 - kalk, -8.0, -58.0, -3.0 + kalk, "#8a8474")
	var alev := floorf(sin(T * 9.0) * 0.5 + sin(T * 5.3) * 0.5 + 0.5)
	_pb(-144.0, -26.0, -142.0, -21.0 + alev, "#ffd75e")
	_pb(-144.0, -24.0, -143.0, -22.0 + alev, "#fff6d8")
	for i in 7:
		_pbA(-147.0 - i * 2.0, -30.0 - i * 1.5, -139.0 + i * 2.0, -20.0 + i * 2.0, "#ffb04a", 0.055 + 0.012 * sin(T * 6.0 + i))
	var gx := 40.0
	var gy := 44.0
	var gw := 400.0
	var gh := 150.0
	for i in 70:
		var kx := gx + fposmod(J.n(f_hash1(i * 3.1)) * gw + sin(T * 0.5 + i) * 14.0 + T * 9.0, gw)
		var ky := gy + fposmod(J.n(f_hash1(i * 7.7)) * gh + T * (16.0 + J.n(f_hash1(i)) * 26.0), gh)
		var b := 4.0 if i % 5 == 0 else 2.0
		draw_context.globalAlpha = 0.55 + J.n(f_hash1(i * 2.3)) * 0.4
		_hp(roundf(kx * 2.0), roundf(ky * 2.0), b, b, Color8(0xea, 0xf2, 0xff))
	draw_context.globalAlpha = 0.1 + 0.04 * sin(T * 0.7)
	f_fr(gx, gy + gh - 22.0, gw, 4.0, "#ffffff")
	draw_context.globalAlpha = 1.0
	return true

# sahne 4: icra yazisi
func f_hdProDebt(t: Variant, _k: Variant) -> bool:
	var A := _prolog("p4_arka")
	if A.is_empty() or not A.parca.has("p4_eller"): return false
	var T := J.n(t)
	hd_ciz(A, "p4_arka", 40.0, 44.0)
	var sal := sin(T * 1.1) * 2.0
	hd_ciz(A, "p4_lamba", 40.0 + sal, 44.0)
	hd_ciz(A, "p4_koni", 40.0 + floorf(sal + 0.5), 44.0)
	var sw := floorf(sin(T * 1.2) + 0.5)
	_pbA(-70.0 + sw, -22.0, 82.0 + sw, 58.0, "#000000", 0.4)
	hd_ciz(A, "p4_kagit", 40.0 + sw, 44.0)
	_c("f_txt", "İCRA VE İFLAS MÜDÜRLÜĞÜ", _pbx(2.0 + sw), _pby(55.0), "#4a4438", {"align": "c"})
	_c("f_txt", "TOPLAM BORÇ", _pbx(-2.0 + sw), _pby(9.0), "#7a3428", {"align": "c"})
	_c("f_txt", "$5.000.000", _pbx(-2.0 + sw), _pby(2.0), "#a8201a", {"align": "c", "sc": 2.0})
	var PRO: Dictionary = get("j_PRO")
	var stampK := clampf((J.n(PRO.t) - 2.0) * 3.2, 0.0, 1.0)
	if stampK > 0.0:
		var drop := floorf((1.0 - stampK) * 30.0 + 0.5)
		var mz := 22.0 + drop
		if stampK > 0.95 and stampK < 1.0:
			_c("f_shake", 2.0)
		draw_context.globalAlpha = 0.9 * (0.4 + 0.6 * stampK)
		f_ring(_pbx(44.0 + sw), _pby(mz), 16.0, "#a8201a")
		f_ring(_pbx(44.0 + sw), _pby(mz), 15.0, "#a8201a")
		f_ring(_pbx(44.0 + sw), _pby(mz), 11.0, "#a8201a")
		_c("f_txt", "ÖDENMEDİ", _pbx(44.0 + sw), _pby(mz + 3.0), "#a8201a", {"align": "c"})
		draw_context.globalAlpha = 1.0
		if stampK >= 1.0:
			_pbA(52.0 + sw, 6.0, 64.0 + sw, 12.0, "#a8201a", 0.35)
	hd_ciz(A, "p4_eller", 40.0, 44.0)
	if J.truth(_c("f_chance", 0.1)):
		_c("f_part", {"x": _pbx(146.0) + J.n(_rnd(-5.0, 5.0)), "y": _pby(18.0), "vx": _rnd(-4.0, 4.0), "vy": _rnd(-16.0, -7.0), "life": 1.0, "col": "rgba(255,225,180,.30)", "g": -10.0, "sz": 1.0})
	hd_ciz(A, "p4_vinyet", 40.0, 44.0)
	return true

# sahne 5: anahtar, kepenk acilisi
func f_hdProKey(t: Variant, _k: Variant) -> bool:
	var A := _prolog("p5_arka")
	if A.is_empty() or not A.parca.has("p5_el"): return false
	var T := J.n(t)
	hd_ciz(A, "p5_arka", 40.0, 44.0)
	_pb(-75.0, -30.0, -73.0, 6.0, "#9aa3ab")
	_c("f_proSis", -74.0, -26.0, 4.0, 9.0, 2.4, T)
	for i in 5:
		var kor := sin(T * 3.0 + i * 1.7) > -0.2
		_pb(-88.0 + i * 6.0, -26.0, -84.0 + i * 6.0, -23.0, (("#ffb04a" if i % 2 == 1 else "#ff7a2a") if kor else "#a83a12"))
	hd_ciz(A, "p5_tezgah", 40.0, 44.0)
	for i in 9:
		_pbA(-136.0, -30.0 + i * 4.0, 136.0, -26.0 + i * 4.0, "#ffb04a", 0.13 - i * 0.014)
	hd_ciz(A, "p5_cerceve", 40.0, 44.0)
	var PRO: Dictionary = get("j_PRO")
	var ac := clampf((J.n(PRO.t) - 0.4) * 0.55, 0.0, 1.0)
	var alt := floorf(-30.0 + ac * 32.0 + 0.5)
	var ctx: GpuCanvas = draw_context
	ctx.save()
	ctx.beginPath()
	ctx.rect(40.0, _pby(24.0), 400.0, 194.0 - _pby(24.0))
	ctx.clip()
	hd_ciz(A, "p5_kepenk", 40.0, 44.0 - (alt + 30.0))
	ctx.restore()
	hd_ciz(A, "p5_on", 40.0, 44.0)
	var isik := ac * (0.055 + 0.01 * sin(T * 1.6))
	for r in 18:
		_pbA(-136.0 - r * 3.0, -33.0 - r * 0.6, 136.0 + r * 3.0, -31.0 - r * 0.6, "#ffcf7a", isik)
	_pbA(-140.0, alt - 4.0, 140.0, alt + 2.0, "#ffd08a", 0.3 * ac)
	_c("f_txt", "USTA DÖNER", _pbx(0.0), _pby(55.0), "#e8c070", {"align": "c", "outline": "#7a1a12"})
	var kal := floorf(sin(T * 1.5) * 2.0 + 0.5)
	hd_ciz(A, "p5_el", 40.0, 44.0 - kal)
	for i in 7:
		_pbA(92.0 - i * 5.0, -27.0 - i * 2.0 + kal, 100.0 + i * 5.0, -15.0 + i * 2.0 + kal, "#fff0b0", 0.1)
	var isl := [[88.0, -6.0], [118.0, -34.0], [74.0, -30.0]]
	for i in 3:
		if sin(T * 3.2 + i * 2.1) < 0.4: continue
		var ix: float = isl[i][0]
		var iz: float = isl[i][1]
		_pb(ix - 4.0, iz + kal, ix + 4.0, iz + 1.0 + kal, "#fff6d8")
		_pb(ix, iz - 4.0 + kal, ix + 1.0, iz + 5.0 + kal, "#fff6d8")
	if J.truth(_c("f_chance", 0.16)):
		_c("f_part", {"x": _pbx(106.0) + J.n(_rnd(-14.0, 14.0)), "y": _pby(-21.0) + J.n(_rnd(-12.0, 12.0)), "vx": _rnd(-6.0, 6.0), "vy": _rnd(-14.0, -4.0), "life": 0.7, "col": get("j_P").au0, "g": -4.0, "sz": 1.0, "type": "star"})
	_c("f_proBirds", T, 40.0, 44.0, 400.0, 4.0, 0.12)
	_huzmeler(14, 360.0, -20.0, 6, 0.03 + 0.012 * sin(T * 1.5), "#ffd75e")
	return true


# ---------------------------------------------------------------- baslik logosu
# logo.js logoCiz: ayni Blender katmanlari (blender/models/logo_anim_hd.py) 2x.
# Atesleme/titreme karesi, sis turu, dil gecisi ve parilti zamanlamasi eski
# koddan; parilti egik serit logo_parilti.gdshader ile altin harf maskesinde.
var _logo_hd: Dictionary = {}
var _parilti_mat: ShaderMaterial = null

func _logo_yukle() -> Dictionary:
	if _logo_hd.is_empty():
		var kok := "res://assets/remake/logo/"
		if not FileAccess.file_exists(kok + "logo.json"): return {}
		var veri: Variant = JSON.parse_string(FileAccess.get_file_as_string(kok + "logo.json"))
		if not (veri is Dictionary): return {}
		var tex := {"arka": load(kok + "arka.png"), "sis": load(kok + "sis.png")}
		for dil in veri.on:
			tex["on_" + dil] = load(kok + "on_%s.png" % dil)
			tex["maske_" + dil] = load(kok + "maske_%s.png" % dil)
		_logo_hd = {"veri": veri, "tex": tex}
	return _logo_hd

func f_hdLogo(t: Variant, cx: Variant, y: Variant, dil: Variant, u: Variant) -> bool:
	if not hd("logo"): return false
	var LG := _logo_yukle()
	if LG.is_empty() or not LG.veri.on.has(dil): return false
	var V: Dictionary = LG.veri
	var tex: Dictionary = LG.tex
	var T := J.n(t)
	var X := floorf(J.n(cx) - J.n(V.cx) + 0.5)
	var Y := J.n(y)
	var ctx: GpuCanvas = draw_context
	var A: Dictionary = V.arka
	var k := int(J.n(_c("f_logoIsiticiKare", t)))
	var sa := int(A.sut)
	ctx.texture_hd(tex.arka, Rect2((k % sa) * A.kw, (k / sa) * A.kh, A.kw, A.kh), X + J.n(A.x), Y + J.n(A.y))
	var S: Dictionary = V.sis
	var eski_sis: Dictionary = get("j_LOGO_VERI").sis
	var n := int(J.n(eski_sis.n))
	var f := int(floorf(T * n / J.n(eski_sis.turSn))) % n
	var ss := int(S.sut)
	ctx.texture_hd(tex.sis, Rect2((f % ss) * S.kw, (f / ss) * S.kh, S.kw, S.kh), X + J.n(S.x), Y + J.n(S.y))
	var O: Dictionary = V.on[dil]
	ctx.texture_hd(tex["on_" + dil], Rect2(0, 0, O.w, O.h), X + J.n(O.x), Y + J.n(O.y))
	var LOGO: Dictionary = get("j_LOGO")
	var PAR := J.n(get("j_LOGO_PARILTI"))
	var p := -1.0
	if T - J.n(LOGO.dilT) < PAR:
		p = (T - J.n(LOGO.dilT)) / PAR
	elif J.n(u) > 1.4:
		var faz := fposmod(J.n(u) - 1.4, J.n(get("j_LOGO_PARILTI_ARA")))
		if faz < PAR:
			p = faz / PAR
	if p >= 0.0:
		if _parilti_mat == null:
			_parilti_mat = ShaderMaterial.new()
			_parilti_mat.shader = load("res://shaders/logo_parilti.gdshader")
		_parilti_mat.set_shader_parameter("boyut", Vector2(O.w / 2.0, O.h / 2.0))
		ctx.texture_hd_mat(tex["maske_" + dil], Rect2(0, 0, O.w, O.h), X + J.n(O.x), Y + J.n(O.y), _parilti_mat.get_rid(), Color(p, 0, 0, 1))
	return true


# ---------------------------------------------------------------- iskender pide tahtasi
# food.js drawPideBoard: dilimler (kesilmemis / kup) ve dograma bicagi
# Blender parcasi (blender/models/pide_hd.py), 4 olcek (tahta ctx.scale icinde).
const PIDE_OLCEK := [100, 85, 74, 58, 180, 122, 90]

func f_hdPideDilimler(cx: Variant, cy: Variant, n: Variant) -> bool:
	if not hd_olcekli("pide"): return false
	var o := _durum_olcek(PIDE_OLCEK)
	if o < 0: return false
	var A := atlas("pide")
	if A.is_empty() or not A.parca.has("pide_serit_0_%d" % o): return false
	var N := int(J.n(n))
	for q in 5:
		hd_ciz(A, ("pide_kup_%d_%d" if q < N else "pide_serit_%d_%d") % [q, o], J.n(cx), J.n(cy))
	return true

func f_hdPideBicak(x: Variant, agiz: Variant) -> bool:
	if not hd_olcekli("pide"): return false
	var o := _durum_olcek(PIDE_OLCEK)
	if o < 0: return false
	var A := atlas("pide")
	if A.is_empty() or not A.parca.has("pide_bicak_%d" % o): return false
	hd_ciz(A, "pide_bicak_%d" % o, J.n(x), J.n(agiz))
	return true

# kilitli istasyon ortusundeki asma kilit (game.js lockedStation): gece atlasindaki kilit
func f_hdKilitIkon(cx: Variant, cy: Variant) -> bool:
	if not hd("kilitli"): return false
	var A := atlas("gece")
	if A.is_empty() or not A.parca.has("kilit"): return false
	hd_ciz(A, "kilit", floorf(J.n(cx)), floorf(J.n(cy)) - 1.0)
	return true


# ---------------------------------------------------------------- dukkan zemini
# art.js bakeBG zemin seridi: blender/zemin_hd.py ton dokusu (palet indeksi) +
# sehrin 4 tonluk zemin paleti (shaders/ton.gdshader PALET kipi).
var _zemin_mat: Dictionary = {}

func f_hdZemin(tema: Variant) -> bool:
	if not hd("zemin") or not (tema is Dictionary): return false
	var tip: String = str(tema.get("zeminTip", "ahsap"))
	if not tip in ["ahsap", "beton", "dama", "mermer"]: tip = "ahsap"
	var yol := "res://assets/remake/zemin/%s.png" % tip
	if not ResourceLoader.exists(yol): return false
	var tex: Texture2D = load(yol)
	var Z: Array = tema.zemin
	var anah := "%s|%s|%s" % [tip, Z[0], Z[3]]
	var m: ShaderMaterial = _zemin_mat.get(anah)
	if m == null:
		var img := Image.create(4, 1, false, Image.FORMAT_RGBA8)
		for i in 4: img.set_pixel(i, 0, Color.html(Z[i]))
		m = ShaderMaterial.new()
		m.shader = load("res://shaders/ton.gdshader")
		m.set_shader_parameter("kip", 1)
		m.set_shader_parameter("satirlar", 1)
		m.set_shader_parameter("sutunlar", 4)
		m.set_shader_parameter("palet", ImageTexture.create_from_image(img))
		m.set_shader_parameter("doku_uniform", true)
		m.set_shader_parameter("doku_ton", tex)
		_zemin_mat[anah] = m
	m.set_shader_parameter("mono", draw_context.mono)
	var fy: float = J.n(get("j_LAY").floorY)
	draw_context.shader_quad(0.0, fy, tex.get_width() / 2.0, tex.get_height() / 2.0, m.get_rid(), Color(0, 0, 0, 1))
	return true


# ---------------------------------------------------------------- ucan para, kar, cam damlasi
# food.js drawCoin / art.js drawKar, drawCamDamla — Blender parcalari (efekt_hd.py).
# Para 5 donme fazinda gercek 3B render (rakam kabartma), kar tanesi kristal,
# cam damlasi mercek golgeli; kiragi seridi tek doku.
func f_hdPara(x: Variant, y: Variant, v: Variant, t: Variant, ph: Variant) -> bool:
	if not hd("para"): return false
	var A := atlas("efekt")
	if A.is_empty() or not A.parca.has("para_a_5"): return false
	var X := J.n(x)
	var Y := J.n(y)
	var sp := absf(sin(J.n(t) * 3.0 + (J.n(ph) if J.truth(ph) else 0.0)))
	var rx := int(maxf(1.0, floorf(5.0 * sp + 0.5)))
	var ctx: GpuCanvas = draw_context
	# eski kod globalAlpha'yi MUTLAK yaziyor (ucan parada solma bu yuzden yok) — ayni
	ctx.globalAlpha = 0.25
	f_ell(X, Y + 4.0, 5.0, 2.0, "#000")
	ctx.globalAlpha = 1.0
	hd_ciz(A, "para_%s_%d" % ["a" if J.n(v) >= 25.0 else "g", rx], X, Y)
	return true

func f_hdKar(K: Variant, Gl: Variant) -> bool:
	if not hd("kar"): return false
	var A := atlas("efekt")
	if A.is_empty() or not A.parca.has("kar_b"): return false
	var ctx: GpuCanvas = draw_context
	var n := int(J.n(J.getv(K, "length")))
	for i in n:
		var k: Variant = J.getv(K, float(i))
		var x := floorf(J.n(J.getv(k, "x")) + 0.5)
		var y := floorf(J.n(J.getv(k, "y")) + 0.5)
		if J.n(J.getv(k, "r")) > 1.0:
			hd_ciz(A, "kar_b", x, y)
		else:
			ctx.globalAlpha = 0.88
			hd_ciz(A, "kar_k", x, y)
			ctx.globalAlpha = 1.0
	# cam kenarindaki kiragi: alfa dokuya pisirildi (eski kod globalAlpha .34)
	var gx := J.n(J.getv(Gl, "x"))
	var gy := J.n(J.getv(Gl, "y"))
	hd_ciz(A, "kirag_ust", gx, gy)
	hd_ciz(A, "kirag_alt", gx, gy + J.n(J.getv(Gl, "h")) - 8.0)
	return true

func f_hdCamDamla(D: Variant) -> bool:
	if not hd("damla"): return false
	var A := atlas("efekt")
	if A.is_empty() or not A.parca.has("damla_2_3"): return false
	var ctx: GpuCanvas = draw_context
	var iz_a := Color("#cfe4f2")
	var iz_b := Color("#eaf6ff")
	var n := int(J.n(J.getv(D, "length")))
	for i in n:
		var d: Variant = J.getv(D, float(i))
		var x := floorf(J.n(J.getv(d, "x")) + 0.5)
		var y := floorf(J.n(J.getv(d, "y")) + 0.5)
		var iz := J.n(J.getv(d, "iz"))
		if iz > 1.0:
			var i0 := floorf(iz + 0.5)
			var i1 := floorf(i0 * 0.7 + 0.5)
			ctx.globalAlpha = 0.26
			_hp(x * 2.0, (y - i0) * 2.0, 2.0, i0 * 2.0, iz_a)
			ctx.globalAlpha = 0.16
			_hp((x - 1.0) * 2.0, (y - i1) * 2.0, 2.0, i1 * 2.0, iz_b)
			ctx.globalAlpha = 1.0
		var r := J.n(J.getv(d, "r"))
		ctx.globalAlpha = 0.72
		if r < 1.1:
			hd_ciz(A, "damla_k", x, y)
		else:
			var rx := clampi(int(floorf(r + 0.5)), 1, 2)
			var ry := clampi(int(floorf(r * 1.25 + 0.5)), rx, rx + 1)
			hd_ciz(A, "damla_%d_%d" % [rx, ry], x, y)
		ctx.globalAlpha = 1.0
		var carp := J.n(J.getv(d, "carp"))
		if carp > 0.0:
			ctx.globalAlpha = carp * 0.55
			f_ring(x, y, floorf(1.0 + (1.0 - carp) * 3.0 + 0.5), "#eaf6ff")
			ctx.globalAlpha = 1.0
	return true


# ---------------------------------------------------------------- gazete, ikonlar, moto rozeti
# ui.js gazeteArma / gazeteSusleme / gazete kagidi, drawCheck, drawX, drawMotoBadge.
# Blender parcalari: blender/models/ufak_hd.py
func f_hdGazeteArma(cx: Variant, cy: Variant) -> bool:
	if not hd("gazete"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("arma"): return false
	hd_ciz(A, "arma", floorf(J.n(cx) + 0.5), floorf(J.n(cy) + 0.5))
	return true

func f_hdGazeteSusleme(x: Variant, y: Variant, yon: Variant) -> bool:
	if not hd("gazete"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("susleme"): return false
	hd_ciz(A, "susleme", floorf(J.n(x) + 0.5), floorf(J.n(y) + 0.5), 1.0, J.n(yon) < 0.0)
	return true

# Gazete kagidi: 16 px'lik dikey tekrarlanabilir doku, panel boyu kadar dosenir.
func f_hdGazeteKagit(x: Variant, y: Variant, pw: Variant, ph: Variant) -> bool:
	if not hd("gazete"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("kagit"): return false
	var X := J.n(x)
	var Y := J.n(y)
	var W := J.n(pw)
	var H := J.n(ph)
	var ctx: GpuCanvas = draw_context
	ctx.globalAlpha = 0.46
	f_fr(X + 5.0, Y + 6.0, W, H, "#000")
	ctx.globalAlpha = 1.0
	f_fr(X, Y, W, H, "#b8ad8e")
	var p: Array = A.parca["kagit"]
	var iw: float = minf(W - 2.0, float(p[2]) / float(A.hd))
	var kalan := H - 2.0
	var yy := Y + 1.0
	while kalan > 0.0:
		var yuk: float = minf(16.0, kalan)
		ctx.texture_hd(A.tex, Rect2(p[0], p[1], iw * A.hd, yuk * A.hd), X + 1.0, yy)
		yy += yuk
		kalan -= yuk
	f_hl(X + 1.0, Y + 1.0, W - 2.0, "#f4ecd4")
	ctx.globalAlpha = 0.13
	f_fr(X + floorf(W / 2.0 + 0.5), Y + 2.0, 1.0, H - 4.0, "#6a5f45")
	ctx.globalAlpha = 1.0
	return true

func f_hdOnay(cx: Variant, cy: Variant, col: Variant) -> bool:
	if not hd("ikon"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("onay"): return false
	hd_ciz(A, "onay", floorf(J.n(cx) + 0.5), floorf(J.n(cy) + 0.5), 1.0, false, _renk(col))
	return true

func f_hdCarpi(cx: Variant, cy: Variant, col: Variant) -> bool:
	if not hd("ikon"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("carpi"): return false
	hd_ciz(A, "carpi", floorf(J.n(cx) + 0.5), floorf(J.n(cy) + 0.5), 1.0, false, _renk(col))
	return true

func f_hdMotoIkon(x: Variant, y: Variant) -> bool:
	if not hd("ikon"): return false
	var A := atlas("ufak")
	if A.is_empty() or not A.parca.has("moto_ikon"): return false
	hd_ciz(A, "moto_ikon", floorf(J.n(x) + 0.5), floorf(J.n(y) + 0.5))
	return true


# ---------------------------------------------------------------- arayuz: panel ve dugme
# ui.js panel() / button() butun ekranlarda kullaniliyor. Parcalar 9 DILIM:
# koseler birebir, kenarlar esnetilir, panel ici 64 px'lik kagit dokusuyla
# doseniyor (esnetme dokuyu sivastirir).
func hd_dilim9(A: Dictionary, ad: String, x: float, y: float, w: float, h: float, kose: float,
		renk: Color = Color.WHITE, alpha: float = 1.0, orta: bool = true) -> void:
	var p: Variant = A.parca.get(ad)
	if p == null: return
	var hd := float(A.hd)
	var sw := float(p[2]) / hd
	var sh := float(p[3]) / hd
	var k: float = minf(kose, minf(w, h) / 2.0)
	var ks: float = minf(kose, minf(sw, sh) / 2.0)
	var sx := [0.0, ks, sw - ks, sw]
	var dx := [0.0, k, w - k, w]
	var sy := [0.0, ks, sh - ks, sh]
	var dy := [0.0, k, h - k, h]
	var ctx: GpuCanvas = draw_context
	for i in 3:
		for j in 3:
			if i == 1 and j == 1 and not orta: continue
			var sw2: float = sx[i + 1] - sx[i]
			var sh2: float = sy[j + 1] - sy[j]
			var dw2: float = dx[i + 1] - dx[i]
			var dh2: float = dy[j + 1] - dy[j]
			if sw2 <= 0.0 or sh2 <= 0.0 or dw2 <= 0.0 or dh2 <= 0.0: continue
			ctx.texture_hd_rect(A.tex, Rect2(float(p[0]) + sx[i] * hd, float(p[1]) + sy[j] * hd, sw2 * hd, sh2 * hd),
				x + dx[i], y + dy[j], dw2, dh2, alpha, renk)

# Tekrarlanabilir dokuyu (panel ici) alana doser; kenardaki artik parca kirpilir.
func hd_dose(A: Dictionary, ad: String, x: float, y: float, w: float, h: float) -> void:
	var p: Variant = A.parca.get(ad)
	if p == null or w <= 0.0 or h <= 0.0: return
	var hd := float(A.hd)
	var tw := float(p[2]) / hd
	var th := float(p[3]) / hd
	var ctx: GpuCanvas = draw_context
	var gy := 0.0
	while gy < h:
		var hh: float = minf(th, h - gy)
		var gx := 0.0
		while gx < w:
			var ww: float = minf(tw, w - gx)
			ctx.texture_hd(A.tex, Rect2(float(p[0]), float(p[1]), ww * hd, hh * hd), x + gx, y + gy)
			gx += ww
		gy += hh

func f_hdPanel(x: Variant, y: Variant, w: Variant, h: Variant, title: Variant) -> bool:
	if not hd("panel"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("panel"): return false
	var X := J.n(x)
	var Y := J.n(y)
	var W := J.n(w)
	var H := J.n(h)
	var ctx: GpuCanvas = draw_context
	ctx.globalAlpha = 0.35
	f_rrect(X + 2.0, Y + 3.0, W, H, 4.0, "#000")
	ctx.globalAlpha = 1.0
	hd_dose(A, "panel_ic", X + 3.0, Y + 3.0, W - 6.0, H - 6.0)
	hd_dilim9(A, "panel", X, Y, W, H, 12.0, Color.WHITE, 1.0, false)
	f_rrectOut(X, Y, W, H, 4.0, J.getv(get("j_P"), "ui5"))
	if J.truth(title):
		var tw: float = J.n(_c("f_textW", title)) + 12.0
		hd_dilim9(A, "baslik", X + W / 2.0 - tw / 2.0, Y - 6.0, tw, 13.0, 6.0)
		_c("f_txt", title, X + W / 2.0, Y - 3.0, J.getv(get("j_P"), "ui0"), {"align": "c", "shadow": 1.0})
	return true

func f_hdDugme(x: Variant, y: Variant, w: Variant, h: Variant, c1: Variant, c2: Variant, off: Variant) -> bool:
	if not hd("dugme"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("dugme_govde"): return false
	var X := J.n(x)
	var Y := J.n(y) + J.n(off)
	var W := J.n(w)
	var H := J.n(h)
	var ctx: GpuCanvas = draw_context
	ctx.globalAlpha = 0.3
	f_rrect(X + 1.0, J.n(y) + 3.0, W, H, 3.0, "#000")
	ctx.globalAlpha = 1.0
	hd_dilim9(A, "dugme_govde", X, Y, W, H, 6.0, _renk(c2))
	hd_dilim9(A, "dugme_yuz", X, Y, W, H - 2.0, 6.0, _renk(c1))
	return true


# ---------------------------------------------------------------- siparis balonu + HUD kutulari
# ui.js drawOrderBubble / drawHUD. Balon acilirken ctx.scale icinde ciziliyor:
# hd_olcekli + texture_hd_rect olcegi de uyguluyor.
func f_hdBalon(bx: Variant, by: Variant, bw: Variant, bh: Variant, acil: Variant, tailX: Variant) -> bool:
	if not hd_olcekli("balon"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("balon"): return false
	var X := J.n(bx)
	var Y := J.n(by)
	var W := J.n(bw)
	var H := J.n(bh)
	var ac := J.truth(acil)
	var ctx: GpuCanvas = draw_context
	ctx.globalAlpha = 0.32
	f_rrect(X + 1.0, Y + 3.0, W, H, 4.0, "#000")
	ctx.globalAlpha = 1.0
	hd_dilim9(A, "balon_acil" if ac else "balon", X, Y, W, H, 8.0)
	hd_ciz(A, "kuyruk_acil" if ac else "kuyruk", floorf(J.n(tailX) + 0.5) - 5.0, Y + H - 2.0)
	return true

# BIRLESIK SURUM: yeni siparis balonu (rendering/order_draw.gd). Govde ayni 9
# dilim HD balon; secili sipariste altin cerceve, acil (sabir < .3) kirmizi.
func f_hdSiparisBalon(x: float, y: float, w: float, h: float, acil: bool, secili: bool, kuyruk_x: float) -> bool:
	if not hd("balon"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("balon"): return false
	var ctx: GpuCanvas = draw_context
	var a0: float = float(ctx.globalAlpha)
	ctx.globalAlpha = a0 * 0.32
	f_rrect(x + 1.0, y + 2.0, w, h, 3.0, "#35271d")
	ctx.globalAlpha = a0
	hd_dilim9(A, "balon_acil" if acil else "balon", x, y, w, h, 8.0)
	hd_ciz(A, "kuyruk_acil" if acil else "kuyruk", floorf(kuyruk_x + 0.5) - 5.0, y + h - 2.0)
	if secili and not acil:
		f_rrectOut(x, y, w, h, 3.0, "#e8b453")
		ctx.globalAlpha = a0 * 0.35
		f_rrectOut(x - 1.0, y - 1.0, w + 2.0, h + 2.0, 4.0, "#ffe7a0")
		ctx.globalAlpha = a0
	return true

# hazirlama seridindeki zeminsiz malzeme ikonu (ikon_hd.py mal_*)
func f_hdMalzeme(m: String, x: float, y: float) -> bool:
	if not hd("cip"): return false
	var A := atlas("ikon")
	var ad := "ikon_mal_%s" % m
	if A.is_empty() or not A.parca.has(ad): return false
	hd_ciz(A, ad, x, y)
	return true

# yeni balonun malzeme cipi (ikon_hd.py cip): istenen krem, istemiyor pembe + capraz
func f_hdCip(m: String, x: float, y: float, yasak: bool) -> bool:
	if not hd("cip"): return false
	var A := atlas("ikon")
	var ad := "ikon_cip_%s%s" % [m, "_yok" if yasak else ""]
	if A.is_empty() or not A.parca.has(ad): return false
	hd_ciz(A, ad, x, y)
	return true

func f_hdHudGun(x: Variant, y: Variant, kompakt: Variant) -> bool:
	if not hd("hud"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("gun_kutu"): return false
	var ctx: GpuCanvas = draw_context
	var X := J.n(x)
	var Y := J.n(y)
	ctx.globalAlpha = 0.3
	f_rrect(X + 1.0, Y + 2.0, 30.0, 26.0 if not J.truth(kompakt) else 16.0, 3.0, "#000")
	ctx.globalAlpha = 1.0
	hd_ciz(A, "gun_kutu_k" if J.truth(kompakt) else "gun_kutu", X, Y)
	return true

func f_hdHudSure(x: Variant, y: Variant, kompakt: Variant) -> bool:
	if not hd("hud"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("sure_kutu"): return false
	var ctx: GpuCanvas = draw_context
	var X := J.n(x)
	var Y := J.n(y)
	ctx.globalAlpha = 0.3
	f_rrect(X + 1.0, Y + 2.0, 42.0, 16.0 if J.truth(kompakt) else 20.0, 3.0, "#000")
	ctx.globalAlpha = 1.0
	hd_ciz(A, "sure_kutu_k" if J.truth(kompakt) else "sure_kutu", X, Y)
	return true

func f_hdHudPara(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("hud"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("para_plaka"): return false
	hd_dilim9(A, "para_plaka", J.n(x), J.n(y), J.n(w), J.n(h), 6.0)
	return true

func f_hdHudMola(x: Variant, y: Variant) -> bool:
	if not hd("hud"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("mola_dugme"): return false
	hd_ciz(A, "mola_dugme", J.n(x), J.n(y))
	return true


# ---------------------------------------------------------------- lider ziyareti
# game.js drawLider: iki koruma (x +- 26) ve ortada lider; tufek disa bakar.
func f_hdLider(x: Variant, y: Variant) -> bool:
	if not hd("lider"): return false
	var A := atlas("olay")
	if A.is_empty() or not A.parca.has("lider"): return false
	var X := floorf(J.n(x) + 0.5)
	var Y := J.n(y)
	var ctx: GpuCanvas = draw_context
	for m in 2:
		var mx: float = X + (26.0 if m == 1 else -26.0)
		ctx.globalAlpha = 0.22
		f_ell(mx, Y, 5.0, 2.0, "#000")
		ctx.globalAlpha = 1.0
		hd_ciz(A, "lider_koruma", mx, Y, 1.0, m == 0)
	ctx.globalAlpha = 0.28
	f_ell(X, Y, 6.0, 2.0, "#000")
	ctx.globalAlpha = 1.0
	hd_ciz(A, "lider", X, Y)
	return true


# ---------------------------------------------------------------- parcaciklar
# core.js psDraw: duman -> yumusak top sprite'i, yildiz -> keskin parilti,
# px -> HD izgarada yarim piksel konum (daha akici hareket). Halka ve et
# dilimi eski yoldan (zaten HD). Sira, alfa ve renk eski kodla ayni.
func f_hdPsDraw(PS: Variant) -> bool:
	if not hd("parcacik") or not (PS is Array): return false
	var A := atlas("efekt")
	if A.is_empty() or not A.parca.has("duman_6"): return false
	var ctx: GpuCanvas = draw_context
	ctx.globalAlpha = 1.0
	for p in PS:
		if not (p is Dictionary): continue
		var k: float = J.n(p.get("t")) / maxf(0.0001, J.n(p.get("life")))
		var tip: String = str(p.get("type", "px"))
		var x: float = J.n(p.get("x"))
		var y: float = J.n(p.get("y"))
		var sz: float = J.n(p.get("sz")) if J.truth(p.get("sz")) else 1.0
		match tip:
			"smoke":
				var c := _renk(p.get("col"))
				var R := clampi(roundi((sz + k * 3.0) * 0.5 * 2.0), 2, 12)
				hd_ciz(A, "duman_%d" % R, x, y, (1.0 - k) * 0.5 * c.a, false, Color(c.r, c.g, c.b))
			"star":
				var c := _renk(p.get("col"))
				var R := clampi(roundi(maxf(1.0, sz * (1.0 - k * 0.4)) * 2.0), 2, 8)
				hd_ciz(A, "parilti_%d" % R, x + 0.5, y + 0.5, (1.0 - k * k) * c.a, false, Color(c.r, c.g, c.b))
			"ring":
				ctx.globalAlpha = 1.0 - k
				f_ring(x, y, 1.0 + k * (J.n(p.get("sz")) if J.truth(p.get("sz")) else 10.0), p.get("col"))
				ctx.globalAlpha = 1.0
			"et":
				if k > 0.82: ctx.globalAlpha = 1.0 - (k - 0.82) * 5.6
				_c("f_drawEtDilimi", x, y, 0.35 + k * 1.05, p.get("k") if J.truth(p.get("k")) else 1.0, p.get("sc") if J.truth(p.get("sc")) else 1.0)
				ctx.globalAlpha = 1.0
			_:
				ctx.globalAlpha = (1.0 - (k - 0.75) * 4.0) if k > 0.75 else 1.0
				_hp(roundf((x - sz * 0.5) * 2.0), roundf((y - sz * 0.5) * 2.0), sz * 2.0, sz * 2.0, _renk(p.get("col")))
				ctx.globalAlpha = 1.0
	return true


# Hareketli karakter konumu: HD acik ve GPU tuvalinde yarim piksel (2x izgara)
# adimla yuvarlanir -> nefes/salinim daha akici. Eski yolda tam piksel.
func f_hdYarimPx(v: Variant) -> float:
	if hd_acik and draw_context is GpuCanvas and not _hd_kapali.has("yarimpx"):
		return floorf(J.n(v) * 2.0 + 0.5) / 2.0
	return floorf(J.n(v) + 0.5)


# ---------------------------------------------------------------- doner isiticisi
# art.js drawSpit isitici paneli: Blender kasa + petekli seramik elemanlar
# (blender/models/isitici_hd.py). Titreme formulu (fl) ve parcacik RNG'si oyunda.
func f_hdIsiticiGovde(hx: Variant, hy: Variant) -> bool:
	if not hd("isitici"): return false
	var A := atlas("isitici")
	if A.is_empty() or not A.parca.has("isitici_govde"): return false
	hd_ciz(A, "isitici_govde", J.n(hx), J.n(hy))
	return true

func f_hdIsiticiEleman(x: Variant, y: Variant, fl: Variant) -> bool:
	var A := atlas("isitici")
	if A.is_empty(): return false
	var X := J.n(x)
	var Y := J.n(y)
	var f := J.n(fl)
	hd_ciz(A, "eleman_taban", X, Y)
	hd_ciz(A, "eleman_kor", X, Y, 0.3 + 0.4 * f)
	hd_ciz(A, "eleman_oz", X, Y, 0.25 + 0.3 * f)
	return true

func f_hdSicakIsik(x: Variant, y: Variant, alfa: Variant) -> bool:
	var A := atlas("isitici")
	if A.is_empty() or not A.parca.has("sicak_isik"): return false
	hd_ciz(A, "sicak_isik", J.n(x), J.n(y), J.n(alfa))
	return true


# ---------------------------------------------------------------- musteri sabir tupu
# ui.js drawOrderBubble sonu: 7x26 cerceve + 4 px sivi. HD: cam kapsul
# (arayuz_hd sabir_tup / sabir_parilti), sivi silindir golgeli, menisku acik.
func f_hdSabir(px0: Variant, py0: Variant, pv: Variant, pc: Variant) -> bool:
	if not hd("sabir"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("sabir_tup"): return false
	var X := J.n(px0) - 1.0
	var Y := J.n(py0) - 1.0
	hd_ciz(A, "sabir_tup", X, Y)
	var v := clampf(J.n(pv), 0.0, 1.0)
	var c := _renk(pc)
	var dip := (J.n(py0) + 23.0) * 2.0
	var ust := roundf(dip - 46.0 * v)
	if dip - ust >= 1.0:
		var x0 := (J.n(px0) + 1.0) * 2.0
		_hp(x0, ust, 8.0, dip - ust, c)
		_hp(x0, ust, 2.0, dip - ust, c.lightened(0.2))
		_hp(x0 + 6.0, ust, 2.0, dip - ust, c.darkened(0.25))
		_hp(x0, ust, 8.0, 1.0, c.lightened(0.5))
	hd_ciz(A, "sabir_parilti", X, Y)
	return true


# ---------------------------------------------------------------- HUD hava rozeti
# ui.js drawHUD: rozet zemini ve yazi eski; ikon Blender (ufak_hd hava_*), damla /
# kar tanesi / isin konumlari ayni formul, yuvarlamasiz (yarim piksel akici).
func f_hdHava(tur: String, x: Variant, y: Variant, t: Variant) -> bool:
	if not hd("hava"): return false
	var U := atlas("ufak")
	if U.is_empty() or not U.parca.has("hava_bulut"): return false
	var X := J.n(x)
	var Y := J.n(y)
	var T := J.n(t)
	match tur:
		"rain":
			hd_ciz(U, "hava_bulut", X, Y)
			for i in 3:
				hd_ciz(U, "hava_damla", X + 3.0 + i * 4.0, Y + 6.0 + fposmod(T * 22.0 + i * 4.0, 6.0))
		"kar":
			var E := atlas("efekt")
			hd_ciz(U, "hava_bulut_kar", X, Y)
			for i in 3:
				if not E.is_empty():
					hd_ciz(E, "kar_k", X + 3.0 + i * 4.0, Y + 6.0 + fposmod(T * 12.0 + i * 4.0, 6.0))
		"sicak":
			for i in 8:
				var a := i * 0.785 + sin(T * 1.6) * 0.12
				hd_ciz(U, "hava_isin", X + 7.0 + cos(a) * 6.0, Y + 5.0 + sin(a) * 6.0)
			hd_ciz(U, "hava_gunes", X + 7.0, Y + 5.0)
	return true


# Musteri iceri/disari yururken adim ziplamasi (yalniz HD): yan salinimla ayni
# ritim (sin(t*11)), her adimda 1 px yukari. Eski cizimde yok; oyun mantigi degismez.
func f_hdAdim(c: Variant, t: Variant) -> float:
	if not (hd_acik and draw_context is GpuCanvas) or _hd_kapali.has("adim"): return 0.0
	var st := str(J.getv(c, "state"))
	if st != "walkin" and st != "leave": return 0.0
	return -absf(sin(J.n(t) * 11.0)) * 1.0


# Fritoz yag yuzeyi: eski her mantik pikselinde bir px (dikeyde tam piksele
# yuvarli). HD: her HD sutununda ayni sinus, yarim piksel yukseklikte.
func _yag_yuzey(vatX: float, vatW: float, oilY: float, T: float, renk: String) -> void:
	var c := _renk(renk)
	for i in int(vatW * 2.0):
		var lx := vatX + i * 0.5
		var yy := oilY + sin(T * 3.0 + (lx - vatX) * .4) * .8
		draw_context.rect_hd(roundf(lx * 2.0), roundf(yy * 2.0), 1.0, 2.0, c)

# Kabarcik: 2x2 HD cekirdek + ustte parlak nokta, yarim piksel konum.
func _kabarcik(x: float, y: float, renk: String) -> void:
	var c := _renk(renk)
	var X := roundf(x * 2.0)
	var Y := roundf(y * 2.0)
	draw_context.rect_hd(X, Y, 2.0, 2.0, c)
	draw_context.rect_hd(X, Y, 1.0, 1.0, c.lightened(0.5))


# Dokulen sivi akisi (icecek / ayran musluklari). Eski: her satirda 1 px'lik
# iki nokta, sin>0'a gore bir piksel saga-sola ziplayan akis. HD: her HD
# satirinda yarim piksel salinan 1.5 px'lik akis (koyu kenar + govde + parlak
# cizgi), dipte kucuk birikinti. Zaman/RNG ayni (parcaciklar kodda).
func _akis(mx: float, y0: float, boy: float, T: float, hiz: float, koyu: String, govde: String, parlak: String) -> void:
	var ck := _renk(koyu)
	var cg := _renk(govde)
	var cp := _renk(parlak)
	var n := int(boy * 2.0)
	for i in n:
		var s := i * 0.5
		var sal := sin(T * hiz + s * 0.8) * 0.22 + sin(T * hiz * 0.53 + s * 1.7) * 0.12
		var X := roundf((mx - 0.5 + sal) * 2.0)
		var Y := roundf((y0 + s) * 2.0)
		draw_context.rect_hd(X - 1.0, Y, 1.0, 1.0, ck)
		draw_context.rect_hd(X, Y, 2.0, 1.0, cg)
		if (i + int(T * 30.0)) % 5 < 2:
			draw_context.rect_hd(X, Y, 1.0, 1.0, cp)
	var dip := roundf((y0 + boy) * 2.0)
	draw_context.rect_hd(roundf((mx - 1.5) * 2.0), dip, 6.0, 1.0, cg)
	draw_context.rect_hd(roundf((mx - 1.0) * 2.0), dip - 1.0, 4.0, 1.0, cp)


# Prolog isik huzmeleri: eski duz dikdortgenler; HD yumusak kenarli huzme
# sprite'i (efekt_hd huzme_6/8). Toplam isik esit kalsin diye alfa 1.5 kat.
func _huzmeler(n: int, x0: float, adim: float, gen: int, alfa: float, renk: String) -> void:
	var E := atlas("efekt")
	var ad := "huzme_%d" % gen
	if E.is_empty() or not E.parca.has(ad):
		draw_context.globalAlpha = alfa
		for i in n:
			f_fr(x0 + i * adim, 44.0, float(gen), 150.0, renk)
		draw_context.globalAlpha = 1.0
		return
	var c := _renk(renk)
	for i in n:
		hd_ciz(E, ad, x0 + i * adim, 44.0, minf(1.0, alfa * 1.5), false, c)


# ---------------------------------------------------------------- basarim rozeti + bildirim
# ui.js bsRozet / drawBasarimToast: rozet = cukur yuva + kademe renginde
# pahli halka (notr sprite, modulate); bildirim = altin pahli 9 dilim plaka.
func f_hdRozet(x: Variant, y: Variant, renk: Variant) -> bool:
	if not hd("rozet"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("rozet_halka"): return false
	hd_ciz(A, "rozet_taban", J.n(x), J.n(y))
	hd_ciz(A, "rozet_halka", J.n(x), J.n(y), 1.0, false, _renk(renk))
	return true

func f_hdBildirimPlaka(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("rozet"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("bildirim_plaka"): return false
	hd_dilim9(A, "bildirim_plaka", J.n(x), J.n(y), J.n(w), J.n(h), 8.0)
	return true


func f_hdKoyuKart(x: Variant, y: Variant, w: Variant, h: Variant) -> bool:
	if not hd("kart"): return false
	var A := atlas("arayuz")
	if A.is_empty() or not A.parca.has("koyu_kart"): return false
	hd_dilim9(A, "koyu_kart", J.n(x), J.n(y), J.n(w), J.n(h), 8.0)
	return true


# ui.js yokRozet: siparisteki "istemiyorum" cipi (tursu / yogurt / patates)
func f_hdYok(x: Variant, y: Variant, m: Variant) -> bool:
	if not hd("ikon"): return false
	var A := atlas("ikon")
	var ad := "ikon_yok_%s" % (str(m) if str(m) in ["pickle", "yogurt"] else "fries")
	if A.is_empty() or not A.parca.has(ad): return false
	hd_ciz(A, ad, J.n(x), J.n(y))
	return true
