# Tarayicida (Web disa aktarimi) calisirken ortam bilgisi.
# Masaustu ve yerel mobil derlemelerde her sey "false" doner, JavaScriptBridge'e hic dokunulmaz.
# Neden: Godot'ta OS.has_feature("mobile") yalniz yerel Android / iOS'ta dogrudur; telefondaki TARAYICIDA
# false kalir. Bu yuzden oyun telefon tarayicisinda masaustu gibi (fare imleci, kucuk dugmeler, 60 FPS) acilirdi.
extends RefCounted

# Web disa aktarimi mi (tarayicida mi calisiyoruz)?
static func web() -> bool:
	return OS.has_feature("web")

# Birincil girdi parmak mi (telefon / tablet tarayicisi)? CSS "pointer: coarse" + en az bir dokunma noktasi.
# Dokunmatik ekranli dizustu bilgisayarlarin birincil girdisi fare / izleme dokunmatigi oldugundan "fine" doner:
# onlar masaustu kipinde acilir, ilk parmak dokunusunda oyun zaten dokunmatik kipe gecer (device_input.handle).
static func dokunmatik() -> bool:
	if not web(): return false
	var sonuc: Variant = JavaScriptBridge.eval("(window.matchMedia && window.matchMedia('(pointer: coarse)').matches && (navigator.maxTouchPoints || 0) > 0) ? 1 : 0", true)
	return int(sonuc if sonuc != null else 0) == 1

# Tarayicida ilk acilis dili: adres cubugundaki ?dil=xx parametresi (gomulu sayfa dili sabitlemek icin), yoksa tarayici dili.
# Iki harfli kucuk harf kod doner ("tr", "en"...), web degilse "". Gecerli dil mi diye bakmak cagirana aittir.
static func dil() -> String:
	if not web(): return ""
	var sonuc: Variant = JavaScriptBridge.eval("(function () { var d = ''; try { d = new URLSearchParams(location.search).get('dil') || ''; } catch (e) {} if (!d) d = (navigator.languages && navigator.languages[0]) || navigator.language || ''; return String(d).toLowerCase().slice(0, 2); })()", true)
	return str(sonuc) if sonuc != null else ""
