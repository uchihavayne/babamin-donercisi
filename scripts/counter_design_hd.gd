# YENI TEZGAHIN HD GORSELLERI (remake). counter_design.gd onayli yerlesimi ve
# durum mantigini (LED rengi, doluluk, kayma, kesim sallanmasi) aynen korur;
# HD acikken govdeler Blender parcalariyla (blender/models/tezgah2_hd.py,
# atlas "tezgah2") cizilir. HD kapaliysa ya da parca yoksa super cagrilir,
# yani onayli prosedurel cizim degismeden calisir.
# Rastgele cagri yok: tasarim zaten oyunun rastgeleligini kullanmiyor.
extends "res://scripts/counter_design.gd"

func _t2() -> Dictionary:
	return atlas("tezgah2")

func t2_hd() -> bool:
	return counter_design_enabled and hd("tezgah2") and not _t2().is_empty()

# tema 0 celigi tasarimda #91999b; diger temalar j_COUNTER_PAL[tema].base.
# Celik parca #91999b tonunda render edildi -> oran modulate olarak basilir.
func _celik_renk() -> Color:
	var tema := counter_theme()
	if tema == 0: return Color.WHITE
	var b := Color(str(j_COUNTER_PAL[tema].base))
	var o := Color("#91999b")
	return Color(b.r / o.r, b.g / o.g, b.b / o.b)

func f_drawCounter() -> Variant:
	if not t2_hd(): return super.f_drawCounter()
	var A := _t2()
	hd_ciz(A, "tezgah_celik", 0.0, 0.0, 1.0, false, _celik_renk())
	hd_ciz(A, "tezgah_ust", 0.0, 0.0)
	hd_ciz(A, "tezgah_alt", 0.0, 0.0)
	return null

# Dayi servis bolmesinde, tezgahin ONUNDE duruyor: donerin otomatik kesim rayi
# (sisin solu) bolmeye denk geliyor. Dayi sistan SONRA cizilir ki ray onun
# arkasinda kalsin (eskiden rayin ustune biniyordu).
var _dayi_sonra := false

func f_drawCounterProps(time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCounterProps(time)
	hd_ciz(_t2(), "servis", 0.0, 0.0)
	_dayi_sonra = shop_background.f_dayiVar() and (j_G.courier == null or j_G.courier.state == "in")
	return null

func f_drawSpit(p_sp: Variant = null, p_t: Variant = null) -> Variant:
	var sonuc: Variant = super.f_drawSpit(p_sp, p_t)
	if _dayi_sonra:
		_dayi_sonra = false
		j_ctx.save()
		j_ctx.translate(4,130)
		j_ctx.scale(0.82,0.82)
		game_sprites_chef(p_t)
		j_ctx.restore()
	return sonuc

# counter_design.f_drawChef bos doner (Dayi tezgah ONUNDE ciziliyor); asil
# cizim game_sprites -> game.gd zincirinde
func game_sprites_chef(time: Variant) -> void:
	chef_draw.f_drawChef(0, 0, j_G.chef, time)

# LED: tasarimdaki durum rengi, HD'de ic parlama + ust isik
func _led(x: float, y: float, w: float, h: float, renk: String) -> void:
	f_fr(x, y, w, h, renk)
	var c := Color(renk)
	if c.v > 0.45:
		draw_context.rect_hd(x * 2.0 + 1.0, y * 2.0 + 1.0, w * 2.0 - 3.0, 1.0, c.lightened(0.55))
		draw_context.globalAlpha = 0.25
		draw_context.rect_hd(x * 2.0 - 1.0, y * 2.0 - 1.0, w * 2.0 + 2.0, h * 2.0 + 2.0, c)
		draw_context.globalAlpha = 1.0

func f_drawPreparation(time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPreparation(time)
	var st: Dictionary = j_ST.board
	hd_ciz(_t2(), "tahta", st.x, st.y)
	var count: int = tun_design("boards")
	var scale_value := 1.8 if count == 1 else (1.22 if count == 2 else 0.9)
	for i in count:
		var cx: float = wrap_system.f_boardCX(i)
		if count > 1:
			if i == int(j_G.act):
				# secili bolum: ince altin cizgi + yumusak parilti
				draw_context.globalAlpha = 0.35
				f_hl(cx - 17, st.y + st.h - 8, 34, "#f3d896")
				draw_context.globalAlpha = 1.0
				draw_context.rect_hd((cx - 17) * 2.0, (st.y + st.h - 7) * 2.0, 68.0, 1.0, Color("#f3d896"))
			if i > 0:
				# bolme cizgisi: oluk (koyu) + alt kenar isigi
				var bx: float = st.x + i * st.w / count
				draw_context.rect_hd(bx * 2.0, (st.y + 5) * 2.0, 1.0, (st.h - 16) * 2.0, Color("#a27440"))
				draw_context.rect_hd(bx * 2.0 + 1.0, (st.y + 5) * 2.0, 1.0, (st.h - 16) * 2.0, Color("#e3bb82"))
		var item: Variant = j_G.boards[i]
		if item == null: continue
		var cy: float = wrap_system.f_boardCY() - sin(float(item.get("pop", 0)) * PI) * 2
		# tek urun (1.8 olcek): lavas tahtanin tum derinligini kapliyor, alt kenari
		# on kenara tasiyordu (kullanici: "tahtanin ustunde durmuyor, havada").
		# Yalniz cizim yukari alinir; hedef/tiklama noktasi (f_boardCY) ayni.
		if count == 1:
			cy -= 3.5
		match item.kind:
			"pide": plate_draw.f_drawPideBoard(cx, cy, item, time, scale_value)
			"plate": plate_draw.f_drawPlate(cx, cy, item, time, scale_value)
			_:
				if item.state == "open": wrap_draw.f_drawWrapOpen(cx, cy, item, time, scale_value)
				else: wrap_draw.f_drawWrapRolled(cx, cy, item, time, scale_value)
	return null

# Ekmek altligi: yiginlar tabaksiz, altligin USTUNE oturur (tezgah2 ekmek_*).
# Iskender acikken game_draw once pide yiginini (f_drawPideStack), sonra
# lavasi ctx.translate(0, 12) icinde ciziyor: lavas parcasi o kaymayi geri alir.
func f_drawBreadStack(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawBreadStack(x, y, w, h, label)
	var A := _t2()
	if tun_design("iskOn"):
		hd_ciz(A, "ekmek_lavas_on", x, y - 12.0)
		return null
	hd_ciz(A, "altlik", x, y + 3)
	hd_ciz(A, "ekmek_lavas_tek", x, y)
	return null

func f_drawPideStack(x: Variant = null, y: Variant = null, w: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPideStack(x, y, w)
	var A := _t2()
	hd_ciz(A, "altlik", x, y + 3)
	hd_ciz(A, "ekmek_pide_arka", x, y)
	return null

func f_drawPaperStation(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, level: Variant = null, busy: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPaperStation(x, y, w, h, level, busy, time)
	if float(level) > 0:
		hd_ciz(_t2(), "kagit_makine", x, y)
		_led(x + 3, y + 3, 3, 3, "#e79d38" if float(busy) > 0 else "#8abc65")
		if float(level) > 1: _led(x + w - 7, y + 3, 4, 3, "#1e413d")
		return null
	hd_ciz(_t2(), "kagit_yigin", x, y)
	return null

func f_drawFryer(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawFryer(x, y, w, h, state, time)
	# Kullanici: onceki (remake) fritoz daha iyi -> ayni model 51x43 yuvada
	# (on camdan gorunen yag, sepet yagin icinde, ekranli panel)
	if f_hdFritoz(x, y, w, h, state, time): return null
	var A := _t2()
	hd_ciz(A, "fritoz_govde", x, y)
	if state.state != "idle" and j_G.get("flyF") == null:   # cubuklar ucuyorsa sepette henuz yok
		# patatesler yalniz yag penceresinin icinde (kirpilir); bkz. counter_design.f_drawFryer
		j_ctx.save()
		j_ctx.beginPath(); j_ctx.rect(x + 8, y + 13, w - 16, h - 26); j_ctx.clip()
		j_ctx.globalAlpha = 1.0 - 0.9 * clampf(J.n(state.get("gir", 0.0)), 0.0, 1.0)   # inisten hemen sonra belirginlesir
		for i in 14:
			var px: float = x + 13 + fmod(i * 7.0, w - 26)
			var py: float = y + 15 + fmod(i * 3.0, maxf(1, h - 31))
			f_fryStick(px, py, 1.0, float(i), 1.0)
		j_ctx.restore()
	if state.state == "fry":
		# kabarcik: yarim piksel, yukselip sonen parlak nokta
		for i in 5:
			var ky: float = fmod(float(time) * 12 + i * 5, 9)
			draw_context.globalAlpha = 1.0 - ky / 10.0
			draw_context.rect_hd((x + 12 + i * 6) * 2.0, (y + 15 + ky) * 2.0, 2.0, 2.0, Color("#f6dc80"))
			draw_context.rect_hd((x + 12 + i * 6) * 2.0, (y + 15 + ky) * 2.0, 1.0, 1.0, Color("#fff6d6"))
		draw_context.globalAlpha = 1.0
	hd_ciz(A, "fritoz_kol", x, y)
	_led(x + 7, y + h - 8, 5, 4, "#86c966" if state.state == "done" else ("#e66e38" if state.state == "fry" else "#3f5545"))
	return null

func f_drawGrill(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null, capacity: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawGrill(x, y, w, h, state, time, capacity)
	hd_ciz(_t2(), "izgara_govde", x, y)
	_led(x + 6, y + h - 8, 4, 4, "#78b856" if not state.slots.is_empty() else "#42584b")
	return null

# PATATES DOGRAMA (kullanici: "dumduz patates doguruyoruz, animasyon/efekt
# ekle"): remake'in kesim asamalari (patates sagdan kisalir, kesik yuzu acik),
# dogranan dilimler yanda birikir, oyunun kendi bicak izleri (C.slash) cizilir,
# satir kesim yuzune inip kalkar; darbe aninda kirintilar (zaman+hash, oyunun
# rastgele ureticisine dokunmaz).
# TAHTA GENISLETILDI (kullanici: "patates kesme tahtasini daha buyuk, genis, anlasilabilir yap, ama upgradeler
# ustuste binmesin"): tahta 51 -> 63 mantik px; sol sutun / sag taraf 1:1, aradaki duz sutun yatay uzatilir.
# Ic yerlesim soldan saga UC BOLGE: [patates + dilimler][satir][celik kap + cig cubuklar + sayac].
# Sabit noktalar potato_system'de (KESME_*): ucan patatesin inis noktasi, kesik izleri, cubuk kalkis noktasi.
func f_drawCutBoard(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCutBoard(x, y, w, h, state, time)
	var A := _t2()
	var TZ := atlas("tezgah")
	var T: float = float(time)
	_kesme_tahtasi(A, x, y, float(w))
	var pk: Vector2 = potato_system.f_kapNoktasi(x, y, w)
	# kesme efekti (salt gorsel): yalniz OYUN tahtasinda (dukkan ekrani sahte durumla cizer), hook adi "kesme_efekt"
	var kd: bool = hd("kesme_efekt") and is_same(state, j_G.cut)
	var kap_oy: float = potato_system.f_kapSallanma() if kd else 0.0
	var raw_g: float = potato_system.f_sayacPorsiyon(float(state.raw)) if kd else float(state.raw)
	var ax: float = x + potato_system.KESME_PATATES.x
	var ay: float = y + potato_system.KESME_PATATES.y
	# bos tahta: patatesin gelecegi yerde soluk izli patates (dil gerektirmez, "patates buraya" der).
	# Kanca adi "kesme_iz" (HD_KAPALI=kesme_iz ile kapanir; piksel olcen testler baseline'i izsiz almak icin kapatir)
	if hd("kesme_iz") and not state.potato and j_G.get("flyP") == null and not TZ.is_empty() and A.parca.has("patates_butun"):
		hd_ciz(A, "patates_butun", ax + 2.0, ay + 0.5, 0.26, false, Color(0.62, 0.42, 0.24))
	# celik kap: hazir cig cubuklar icinde, yani "kesilenler buraya gider" gorunur
	if not TZ.is_empty() and TZ.parca.has("kesme_kap"):
		var kp: Array = TZ.parca["kesme_kap"]
		hd_ciz(TZ, "kesme_kap", pk.x - float(kp[4]), pk.y - float(kp[5]) + kap_oy)
		var n := mini(15, int(raw_g) * 2)
		for i in n:
			var sira := int(i / 5)
			hd_ciz(TZ, "cig_cubuk", pk.x + 2.0 + (i % 5) * 2.4, pk.y + 10.0 - sira * 4.0 + kap_oy)
		if raw_g >= 1.0:
			# kap acikligina oturan kucuk sayac: kac porsiyon cig patates hazir (dilimler inerken yukari sayar, her inista parlar)
			var vurgu: float = potato_system.kd_sayac if kd else 0.0
			text_draw.f_txt(str(int(raw_g)), pk.x + 16.0, pk.y - 4.5 + kap_oy - (1.0 if vurgu > 0.55 else 0.0), "#ffffff" if vurgu > 0.25 else "#f8ecc0", {"align": "r", "outline": "rgba(0,0,0,.55)"})
	var satir_x: float = x + potato_system.KESME_SATIR_X
	var satir_y: float = y + h / 2 - 6
	if state.potato and not TZ.is_empty():
		var prog: float = clampf(float(state.prog), 0.0, 1.0)
		var pw := clampi(int(maxf(2.0, floorf(11.0 * (1.0 - prog) + .5))), 2, 11)
		# inis ezilmesi (akicilik cilasi): patates tahtaya inince alt kenari sabit kalip kisaca ezilir, hafif yaylanir
		var ln: float = clampf(J.n(state.get("land", 0.0)), 0.0, 1.0)
		if ln > 0.0 and pw == 11 and TZ.parca.has("patates_11"):
			var u := 1.0 - ln
			var sy: float = 1.0 - 0.2 * exp(-5.0 * u) * cos(10.0 * u)
			var pp: Array = TZ.parca["patates_11"]
			var yuk: float = float(pp[3]) / float(TZ.hd)          # parca yuksekligi (mantik px)
			var alt: float = ay + float(pp[5]) + yuk               # alt kenar (tahtada sabit)
			hd_ciz(TZ, "patates_11", ax, (alt - yuk * sy) / sy - float(pp[5]), 1.0, false, Color.WHITE, sy)
		else:
			# kesme efekti: patates vuruslarla HAVADA asili kalir (yuk_p), sallanir (egim), vurusta ezilir (ez), inince ezilir (inis)
			var ez: float = potato_system.f_kesimEzilme() if kd else 0.0
			var yuk_p: float = potato_system.kd_py if kd else 0.0
			var egim: float = potato_system.kd_pa if kd else 0.0
			var inis: float = potato_system.kd_inis if kd else 0.0
			var ad_p := "patates_%d" % pw
			if (yuk_p > 0.0 or egim != 0.0 or inis > 0.0 or ez > 0.02) and TZ.parca.has(ad_p):
				if yuk_p > 0.25:
					# tahtadaki golge: yukseldikce kuculur ve silikles
					draw_context.globalAlpha = maxf(0.07, 0.24 - yuk_p * 0.012)
					f_ell(ax + 1.0, ay + 7.5, maxf(4.0, 8.5 - yuk_p * 0.28), maxf(1.0, 2.4 - yuk_p * 0.08), "#000")
					draw_context.globalAlpha = 1.0
				var sy: float = 1.0 - 0.14 * ez - 0.20 * inis * inis
				var sarsi: float = (0.5 if potato_system.kd_vurusNo % 2 == 0 else -0.5) * ez
				if absf(egim) < 0.002:
					_patates_ezik(TZ, ad_p, ax + sarsi, ay - yuk_p, sy)
				else:
					# egik: parcanin merkezi etrafinda doner, alt kenar (olcek icin) sabit
					var pp: Array = TZ.parca[ad_p]
					var hd_k: float = float(TZ.hd)
					var yuk_s: float = float(pp[3]) / hd_k
					var ust: float = ay - yuk_p + float(pp[5])
					draw_context.texture_hd_donuk(TZ.tex, Rect2(pp[0], pp[1], pp[2], pp[3]), ax + sarsi + float(pp[4]) + float(pp[2]) / hd_k / 2.0,
						ust + yuk_s - yuk_s * sy / 2.0, egim, 1.0, sy, 1.0)
			else:
				hd_ciz(TZ, ad_p, ax, ay)
		var kesik: float = ax - 11.0 + 2.0 * pw
		# dogranmis dilimler: kesik yuzun saginda, hafif egik dizilir (havada olan dilim inene kadar yerinde cizilmez)
		for i in int(floorf(prog * 7.0)):
			if kd and potato_system.f_dilimHavada(i): continue
			hd_ciz(TZ, "patates_dilim", kesik + 3.0 + i * 2.6, ay - 5.0 + (i % 2) * 0.5)
		var kaldir: float = potato_system.kd_py if kd else 0.0
		if kaldir > 0.2 and state.get("slash") != null:
			# bicak izleri havadaki patatesin yuksekliginde cizilir (G'deki izler tahta seviyesinde dogar; kopya, G'ye dokunulmaz)
			var izler: Array = []
			for s0 in state.slash:
				var s1: Dictionary = (s0 as Dictionary).duplicate()
				s1.y = float(s1.y) - kaldir
				izler.append(s1)
			chopping_draw.f_drawSlash({"slash": izler})
		else:
			chopping_draw.f_drawSlash(state)
		if prog > 0: counter_draw.f_bar(x + 5, y + h - 6, w - 10, 3, prog, "#eacf88")
		if state.cutting:
			# dogrudan kesik yuze iner: hizli inis, kisa bekleme, yavas kalkis
			# kesme efekti aciksa bicak GERCEK vurusla ayni anda iner (ses + ezilme + dilim ayni karede); degilse eski sabit tempo
			var p := potato_system.f_bicakFazi() if kd else fposmod(T * 5.0, 1.0)
			var yuk := (1.0 - p / 0.22) if p < 0.22 else (0.0 if p < 0.36 else (p - 0.36) / 0.64)
			satir_x = kesik + 0.5
			# bicak havadaki patatesin yuksekligini izler; ust sinir fritozun sayac ekranini (tahtanin 6-14 px ustu) kapatmasin diye y - 4'te kesilir
			satir_y = maxf(y + 7.0 - yuk * 9.0 - kaldir, y - 4.0)
			if p >= 0.22 and p < 0.5:
				_dogrma_kirinti(kesik + 1.0, y + 17.0 - kaldir, (p - 0.22) / 0.28, float(potato_system.kd_vurusNo) if kd else floorf(T * 5.0))
	elif state.potato:
		hd_ciz(A, "patates_butun", x + w / 2, y + h / 2)
	hd_ciz(A, "satir", satir_x, f_hdYarimPx(satir_y))
	if kd and not TZ.is_empty(): _kesme_ucanlar(TZ)
	return null

# dilim ucusu: ziplayan (kesik yuzden siraya) ve havaya firlayan (siradan celik kaba) dilimler; iz + inise dogru kuculme / solma
func _kesme_ucanlar(TZ: Dictionary) -> void:
	if not TZ.parca.has("patates_dilim"): return
	var pr: Array = TZ.parca["patates_dilim"]
	var src := Rect2(pr[0], pr[1], pr[2], pr[3])
	for c in potato_system.kd_ucan:
		var kap: bool = c.tur == "kap"
		for iz in ([2, 1, 0] if kap else [1, 0]):
			var cc: Dictionary = c.duplicate()
			cc.t = float(c.t) - 0.022 * float(iz)
			var kk: Variant = potato_system.f_dilimKonum(cc)
			if kk == null: continue
			var al: float = 1.0 if iz == 0 else (0.24 if iz == 1 else 0.1)
			var ol: float = 1.0
			if kap:
				al *= 1.0 - clampf((float(kk.k) - 0.86) / 0.14, 0.0, 1.0)     # kabin icine inerken solar
				ol = lerpf(1.2, 0.85, float(kk.k))                            # yayin ustunde iri (kameraya yakin), inerken kuculur
			draw_context.texture_hd_donuk(TZ.tex, src, roundf(float(kk.x) * 2.0) / 2.0, roundf(float(kk.y) * 2.0) / 2.0, float(kk.aci), ol, ol, al)

# alt kenari sabit, dikey olcekli patates (inis ve vurus ezilmesi)
func _patates_ezik(TZ: Dictionary, ad: String, ax: float, ay: float, sy: float) -> void:
	var pp: Array = TZ.parca[ad]
	var yuk: float = float(pp[3]) / float(TZ.hd)
	var alt: float = ay + float(pp[5]) + yuk
	hd_ciz(TZ, ad, ax, (alt - yuk * sy) / sy - float(pp[5]), 1.0, false, Color.WHITE, sy)

# genisletilmis tahta: kesme_tahta parcasi KES (46) sutunundan ikiye bolunur, aradaki 1 piksellik duz sutun
# (cizik yok) yatay uzatilir. Tahta 51 mantik px'e esitse ya da kucukse parca aynen cizilir.
func _kesme_tahtasi(A: Dictionary, x: float, y: float, w: float) -> void:
	var p: Array = A.parca["kesme_tahta"]
	var hdk: float = float(A.hd)
	var ekstra: int = roundi((w - float(p[2]) / hdk) * hdk)      # eklenecek HD piksel
	if ekstra <= 0:
		hd_ciz(A, "kesme_tahta", x, y)
		return
	const KES := 46
	var lx: float = x + float(p[4])
	var ly: float = y + float(p[5])
	draw_context.texture_hd(A.tex, Rect2(p[0], p[1], KES, p[3]), lx, ly)
	draw_context.texture_hd_rect(A.tex, Rect2(float(p[0]) + KES, p[1], 1, p[3]), lx + KES / hdk, ly, ekstra / hdk, float(p[3]) / hdk)
	draw_context.texture_hd(A.tex, Rect2(float(p[0]) + KES, p[1], float(p[2]) - KES, p[3]), lx + (KES + ekstra) / hdk, ly)

# darbe kirintilari: 5 minik nisasta parcasi kesik yuzden disari savrulur
func _dogrma_kirinti(x: float, y: float, k: float, vurus: float) -> void:
	var ctx = draw_context
	ctx.globalAlpha = clampf(1.0 - k, 0.0, 1.0)
	for i in 5:
		var a: float = f_hash1(vurus * 3.7 + i * 1.9) * PI - PI
		var hiz: float = 4.0 + f_hash1(vurus * 5.1 + i) * 5.0
		var px: float = x + cos(a) * hiz * k
		var py: float = y + sin(a) * hiz * k * 0.7 + 6.0 * k * k
		ctx.rect_hd(roundf(px * 2.0), roundf(py * 2.0), 2.0, 1.0 + float(i % 2), Color("#f6ecc6") if i % 2 == 0 else Color("#dcc681"))
	ctx.globalAlpha = 1.0

func f_drawPotatoBin(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPotatoBin(x, y, w, h, time)
	hd_ciz(_t2(), "patates_kasa", x, y)
	return null

# Depo cekmecesi: yalniz cekmece (kullanici 6. tur: "depodaki ikonlara gerek
# yok"; stoklar cekmece acilinca panelde gorunuyor). Acilirken kayar.
func f_drawCrate(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, opened: Variant = null, time: Variant = null, progress: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCrate(x, y, w, h, opened, time, progress)
	hd_ciz(_t2(), "stok_bos", x, f_hdYarimPx(y - J.n(progress) * 4))
	return null

func f_drawTrash(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, time: Variant = null, emptying: Variant = null, fullness: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawTrash(x, y, w, h, time, emptying, fullness)
	hd_ciz(_t2(), "cop", x, y)
	if J.n(fullness) > 0:
		for i in mini(5, int(fullness)): f_fr(x + 6 + i * 3, y + 3 + (i % 2), 3, 2, "#c9b482")
	if J.n(emptying) > 0: f_hl(x + 7, y + h - 3, w - 14, "#e4d38e")
	return null

func f_drawSauceStation(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, on: Variant = null, isk: Variant = null, fx: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawSauceStation(x, y, w, h, on, isk, fx, time)
	var A := _t2()
	for i in 3:
		if not J.truth(isk if i == 2 else on): continue
		var bottle: Dictionary = j_SAUCE_DEF[i]
		var cx: float = x + (i + .5) * w / 3
		var lift: float = round(sin(clampf(float(fx.get(bottle.id, 0)) if fx is Dictionary else 0.0, 0, 1) * PI) * 2)
		draw_context.globalAlpha = 0.45
		f_ell(cx, y + h - 2, 6, 2, "#4f5a5c")
		draw_context.globalAlpha = 1.0
		hd_ciz(A, "sise_%d" % i, cx, y + h - 2 - lift)
	return null

func f_drawIcecekKasasi(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, divisions: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawIcecekKasasi(x, y, w, h, divisions, time)
	var A := _t2()
	var taps: Array = drink_system.f_icecekMusluklari()
	hd_ciz(A, "icecek_govde", x, y)
	var n := clampi(taps.size(), 1, 3)
	for i in taps.size():
		var type: String = taps[i]
		var cx: float = x + (i + .5) * w / taps.size()
		var segment: float = w / taps.size() - 4
		var tip: String = type if type in ["fanta", "cola", "ayran"] else "ayran"
		hd_ciz(A, "musluk_%d_%s" % [n, tip], f_hdYarimPx(cx - segment / 2), y + 4)
		if j_G.drinkM is Dictionary and j_G.drinkM.pours.get(type) != null:
			var color: String = {"fanta": "#e59a32", "cola": "#a83e2d", "ayran": "#c9dcc6"}.get(type, "#c9dcc6")
			# akis: 1.5 px genis, kenarda parlak dalga (yarim piksel)
			for sy in range(32, 43):
				draw_context.rect_hd((cx - 0.5) * 2.0, (y + sy) * 2.0, 3.0, 2.0, Color(color))
				if sin(float(time) * 20 + sy) > 0:
					draw_context.rect_hd((cx - 0.5) * 2.0, (y + sy) * 2.0, 1.0, 2.0, Color("#f1d5a0" if type != "ayran" else "#fff7e3"))
	return null

# Tatli: bakir baklava tepsisi + kalan sayiya gore 0..6 baklava dilimi
# (kullanici: "tatli tepsisini duzenle, yetersiz")
func f_drawSweetTray(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, n: Variant = null, maximum: Variant = null, time: Variant = null, fx: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawSweetTray(x, y, w, h, n, maximum, time, fx)
	var A := _t2()
	hd_ciz(A, "tatli_tepsi", x, y)
	var adet: int = ceili(clampf(float(n) / maxf(1, float(maximum)), 0, 1) * 6)
	var bump: float = roundf(sin(clampf(J.n(fx), 0.0, 1.0) * PI) * 2.0)
	for i in adet:
		hd_ciz(A, "baklava_dilim", x + 8 + (i % 3) * 9, y + 8 + int(i / 3) * 8 - bump)
	f_trayFlash(x, y, w, h, J.n(fx))
	return null
