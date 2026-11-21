# Sehir kurallari (birlesik surum, 12. tur, kullanici istegi: "her sehre metnindeki vaadi tutan bir kural"). Dizin = game.j_BRANCH
# dizini (0 Istanbul ... 8 Demirkent); Demirkent ferman modudur (kendi kurallari var) -> null. Oynanan sehir (G.city) bir kural tasirsa
# o gun kural gecerlidir; Babanin Dukkani (-1) kuralsizdir. Kural alanlari (hepsi isteğe bagli, yoksa 1 / 0):
#   gelis   musteri akisi carpani (cust_mul)        sabir   musteri sabri carpani (patience)    bahsis  bahsis carpani (hava_bahsis)
#   fiyat   satis fiyati carpani (price_mul)        yer     siradaki musteri yeri farki (slots; en az 2 kalir)
#   sure    gun suresi carpani (f_dayCfg)           ceza    hijyen denetim cezasi carpani      iddia   rakip bahisi tutari carpani
#   kusursuz / kusurlu  kusursuz teslimin / kusurlu teslimin fiyat carpani (Tokyo)
# Metinler: ad (baslik), kisa (sube panelindeki rozet), acik (gun giris kartindaki satir). Ceviriler sozluklerde.
# Her sehirde calisirken o subenin geliri ayrica ZIYARET_PRIM kadar artar (systems/city_rules.gd).
extends RefCounted

const VALUE = [
	{"ad": "KUYRUK", "kisa": "MÜŞTERİ +%25", "acik": "müşteri akışı %25 fazla • sabır biraz az", "gelis": 1.25, "sabir": 0.92},
	{"ad": "İDDİA", "kisa": "İDDİA ×2", "acik": "bahis kazancı ve cezası 2 kat", "iddia": 2.0},
	{"ad": "KAPANMAYAN KÖŞE", "kisa": "GÜN +%25", "acik": "gün %25 uzun: dükkân geç saate kadar açık", "sure": 1.25},
	{"ad": "BİTMEYEN KUYRUK", "kisa": "MÜŞTERİ +%40", "acik": "müşteri akışı %40 fazla • sabır az", "gelis": 1.4, "sabir": 0.85},
	{"ad": "KÜÇÜK VE TİTİZ", "kisa": "YER -1 • CEZA ×2", "acik": "1 yer az • ceza 2 kat • fiyat %15 fazla", "yer": -1, "ceza": 2.0, "fiyat": 1.15},
	{"ad": "TURİST AKINI", "kisa": "BAHŞİŞ +%80", "acik": "bahşiş %80 fazla • sabır az", "bahsis": 1.8, "sabir": 0.85},
	{"ad": "KUSURSUZLUK", "kisa": "KUSURSUZ +%25", "acik": "kusursuz teslim %25 fazla • kusurlu %20 eksik", "kusursuz": 1.25, "kusurlu": 0.8},
	{"ad": "UYUMAYAN ŞEHİR", "kisa": "GÜN VE MÜŞTERİ +%15", "acik": "gün %15 uzun • müşteri %15 fazla", "sure": 1.15, "gelis": 1.15},
	null,
]
