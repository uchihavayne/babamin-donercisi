# Baba'nin Defteri: kayip tarifler (12. tur, kullanici istegi). Duzenlenebilir veri.
# Her tarif bir DURUM (durum = dürüm) siparis sablonudur: mevcut sos / "yok" (istenmeyen malzeme)
# kurallari + istege bagli ek urunler (ek). Oyuncu sayfayi `gun`. gunun sonunda bulur; ilgili
# ekipman varsa musteriler tarifi ADIYLA ister ve dogru yapilirsa `carpan` kadar fazla ode.
#   id      kimlik (kayitta saklanir, DEGISTIRME)
#   ad      tarif adi (ceviri anahtari)
#   mesaj   Baba'nin notu (ceviri anahtari, ~60 harf)
#   gun     sayfanin bulundugu gun (kampanya ~80-100 gun; son sayfa borc bitmeden once)
#   sos     null / "hot" / "garlic"
#   yok     istenmeyen malzemeler ("pickle", "yogurt", "fries") - Malzeme Secimi yukseltmesi ister
#   ek      ayni siparisteki ek urunler: "fbox" (patates kutusu), "ayran", "cola", "sweet"
#   carpan  dürüm fiyatina carpan (dogru + tam kalite)
#   menu    tum siparis bitince eklenen menu bonusu orani (0 = yok)
#   gerek   siparis verilebilmesi icin gereken yükseltme kimlikleri (data/upg.gd)
extends RefCounted

const VALUE = [
	{"id": "acili", "ad": "Baba'nın Acılısı", "mesaj": "Acıyı seven bir daha gelir. Sosu esirgeme. — Baba",
		"gun": 3, "sos": "hot", "yok": [], "ek": [], "carpan": 1.6, "menu": 0.0, "gerek": ["sauce"]},
	{"id": "sarimsakli", "ad": "Annenin Sarımsaklısı", "mesaj": "Annenin sosu. Dükkânı bununla kurdum. — Baba",
		"gun": 8, "sos": "garlic", "yok": [], "ek": [], "carpan": 1.6, "menu": 0.0, "gerek": ["sauce"]},
	{"id": "tursusuz", "ad": "Turşusuz Sade", "mesaj": "Turşu sevmeyeni kırma, tarifi aklında tut. — Baba",
		"gun": 14, "sos": null, "yok": ["pickle"], "ek": [], "carpan": 1.7, "menu": 0.0, "gerek": ["secim"]},
	{"id": "yogurtsuz", "ad": "Yoğurtsuz Acı", "mesaj": "Acı ile yoğurt kavga eder; yoğurdu çıkar. — Baba",
		"gun": 21, "sos": "hot", "yok": ["yogurt"], "ek": [], "carpan": 1.8, "menu": 0.0, "gerek": ["sauce", "secim"]},
	{"id": "hafif", "ad": "Hafif Dürüm", "mesaj": "Hafif yiyene patatessiz, sarımsaklı dürüm. — Baba",
		"gun": 30, "sos": "garlic", "yok": ["fries"], "ek": [], "carpan": 1.8, "menu": 0.0, "gerek": ["sauce", "secim"]},
	{"id": "menu", "ad": "Efsane Menü", "mesaj": "Dürüm, patates, ayran: üçü gelirse bayram. — Baba",
		"gun": 42, "sos": "hot", "yok": [], "ek": ["fbox", "ayran"], "carpan": 1.5, "menu": 0.2, "gerek": ["sauce", "fbox", "ayran"]},
	{"id": "cifte", "ad": "Çifte Sade", "mesaj": "Yalnız et ve sos. Ustalık ister, değer. — Baba",
		"gun": 56, "sos": "garlic", "yok": ["pickle", "yogurt"], "ek": [], "carpan": 2.0, "menu": 0.0, "gerek": ["sauce", "secim2"]},
	{"id": "gece", "ad": "Gece Menüsü", "mesaj": "Gece gelenin hakkı tatlıdır. Hepsi hazır olsun. — Baba",
		"gun": 72, "sos": "garlic", "yok": [], "ek": ["fbox", "ayran", "sweet"], "carpan": 1.6, "menu": 0.25, "gerek": ["sauce", "fbox", "ayran", "sweet"]},
]
