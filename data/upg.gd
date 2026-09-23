# Editable equipment purchase/level prices. Economy notes: ECONOMY.md.
extends RefCounted

const VALUE = [
	{
		"id": "knife",
		"name": "Bıçak",
		"desc": "Döner daha kolay kesilir",
		"st": "spit",
		"tag": [
			44,
			60
		],
		"lvName": [
			"Keskin bıçak",
			"Çift taraflı bıçak",
			"Profesyonel satır",
			"Otomatik kesim makinesi"
		],
		"lv": [
			{
				"p": 100
			},
			{
				"p": 360
			},
			{
				"p": 1100
			},
			{
				"p": 3600
			}
		]
	},
	{
		"id": "tongs",
		"name": "Servis Maşası",
		"desc": "Tek tıkta daha çok malzeme",
		"st": "meat",
		"tag": [
			128,
			92
		],
		"lvName": [
			"Büyük maşa",
			"Çift maşa",
			"Porsiyon kepçesi"
		],
		"lv": [
			{
				"p": 110
			},
			{
				"p": 480
			},
			{
				"p": 1600
			}
		]
	},
	{
		"id": "pknife",
		"name": "Patates Bıçağı",
		"desc": "Hızlı doğrar, çuvaldan çok çıkar",
		"st": "cut",
		"tag": [
			300,
			132
		],
		"lvName": [
			"Keskin bıçak",
			"Doğrama aparatı",
			"Dilimleme presi",
			"Otomatik doğrayıcı"
		],
		"lv": [
			{
				"p": 100
			},
			{
				"p": 380
			},
			{
				"p": 1200
			},
			{
				"p": 3800
			}
		]
	},
	{
		"id": "fryer",
		"name": "Fritöz",
		"desc": "Hızlı kızartma, geniş sepet",
		"st": "fryer",
		"tag": [
			312,
			62
		],
		"lvName": [
			"Güçlü rezistans",
			"Geniş sepet",
			"Çift hazne",
			"Otomatik fritöz"
		],
		"lv": [
			{
				"p": 150
			},
			{
				"p": 520
			},
			{
				"p": 1500
			},
			{
				"p": 4400
			}
		]
	},
	{
		"id": "paper",
		"name": "Kağıt Makinesi",
		"desc": "Kağıdı makine takar",
		"st": "paper",
		"tag": [
			204,
			132
		],
		"lvName": [
			"Kağıt makinesi",
			"Otomatik sarma"
		],
		"lv": [
			{
				"p": 180
			},
			{
				"p": 1400
			}
		]
	},
	{
		"id": "grill",
		"name": "Izgara",
		"desc": "Dürümü kızart, pahalı sat",
		"st": "grill",
		"tag": [
			250,
			100
		],
		"lvName": [
			"Izgara",
			"Hızlı ızgara",
			"Çift ızgara",
			"Otomatik ızgara"
		],
		"lv": [
			{
				"p": 260
			},
			{
				"p": 1000
			},
			{
				"p": 2700
			},
			{
				"p": 6500
			}
		]
	},
	{
		"id": "drink",
		"name": "İçecek Standı",
		"desc": "Kola & Fanta sat",
		"st": "drinkM",
		"tag": [
			232,
			62
		],
		"lvName": [
			"İçecek standı",
			"Hızlı dolum",
			"Basınçlı dolum",
			"Otomatik dolum"
		],
		"lv": [
			{
				"p": 220
			},
			{
				"p": 850
			},
			{
				"p": 2400
			},
			{
				"p": 5800
			}
		]
	},
	{
		"id": "fbox",
		"name": "Patates Porsiyon",
		"desc": "Kutuda patates sat",
		"st": "fbox",
		"tag": [
			386,
			132
		],
		"lvName": [
			"Porsiyon kutusu",
			"Otomatik porsiyon"
		],
		"lv": [
			{
				"p": 180
			},
			{
				"p": 1250
			}
		]
	},
	{
		"id": "ayran",
		"name": "Ayran Kazanı",
		"desc": "Ayran sat — stoktan doldurulur",
		"st": "ayran",
		"tag": [
			268,
			62
		],
		"lvName": [
			"Ayran kazanı",
			"Büyük kazan"
		],
		"lv": [
			{
				"p": 260
			},
			{
				"p": 1550
			}
		]
	},
	{
		"id": "sweet",
		"name": "Tatlı Tepsisi",
		"desc": "Halka tatlısı sat",
		"st": "sweet",
		"tag": [
			352,
			152
		],
		"lvName": [
			"Tatlı tepsisi",
			"Şerbetli vitrin"
		],
		"lv": [
			{
				"p": 360
			},
			{
				"p": 2100
			}
		]
	},
	{
		"id": "garnish",
		"name": "Domates & Biber",
		"desc": "İskender yanına garnitür, tabak pahalanır",
		"gerek": "iskender",
		"st": "garnish",
		"tag": [
			226,
			96
		],
		"lvName": [
			"Domates & biber tepsisi",
			"Büyük tepsi"
		],
		"lv": [
			{
				"p": 500
			},
			{
				"p": 2800
			}
		]
	},
	{
		"id": "sauce",
		"name": "Sos Standı",
		"desc": "Acı & sarımsak sos — dürüm daha pahalı",
		"st": "sauce",
		"tag": [
			340,
			112
		],
		"lvName": [
			"Acı & sarımsak sos",
			"Sarılmış dürüme de sos"
		],
		"lv": [
			{
				"p": 300
			},
			{
				"p": 2300
			}
		]
	},
	{
		"id": "iskender",
		"name": "İskender Tabağı",
		"desc": "Pide + döner + tereyağı + yoğurt",
		"st": "board",
		"tag": [
			156,
			112
		],
		"lvName": [
			"İskender tabağı",
			"Hızlı porsiyon",
			"Otomatik tabak"
		],
		"lv": [
			{
				"p": 800
			},
			{
				"p": 3200
			},
			{
				"p": 8500
			}
		]
	},
	{
		"id": "board",
		"name": "Geniş Tezgâh",
		"desc": "Aynı anda 2–3 dürüm",
		"st": "board",
		"tag": [
			124,
			132
		],
		"lvName": [
			"2 dürüm",
			"3 dürüm"
		],
		"lv": [
			{
				"p": 280
			},
			{
				"p": 1600
			}
		]
	},
	{
		"id": "helper",
		"name": "Çırak",
		"desc": "Para toplar, stok doldurur, çöpü atar",
		"st": "crate",
		"tag": [
			406,
			96
		],
		"lvName": [
			"Paraları toplar",
			"Stok doldurur",
			"Çöpü boşaltır"
		],
		"lv": [
			{
				"p": 380
			},
			{
				"p": 1800
			},
			{
				"p": 5000
			}
		]
	},
	{
		"id": "phone",
		"name": "Telefon & Motor",
		"desc": "Paket sipariş — çok daha kârlı",
		"st": "phone",
		"tag": [
			24,
			90
		],
		"lvName": [
			"Telefon hattı + motor",
			"Sık sipariş",
			"Hızlı kurye"
		],
		"lv": [
			{
				"p": 550
			},
			{
				"p": 2300
			},
			{
				"p": 5800
			}
		]
	},
	{
		"id": "uncle",
		"name": "Dayı",
		"desc": "Gün sonunda siparişi kurtarır",
		"st": "uncle",
		"tag": [
			24,
			148
		],
		"lvName": [
			"1 kurtarma",
			"2 kurtarma",
			"4 kurtarma"
		],
		"lv": [
			{
				"p": 240
			},
			{
				"p": 1050
			},
			{
				"p": 2800
			}
		]
	},
	{
		"id": "store",
		"name": "Depo",
		"desc": "Daha çok turşu / yoğurt",
		"st": "crate",
		"tag": [
			406,
			62
		],
		"lvName": [
			"Büyük kutu",
			"Depo rafı",
			"Soğuk oda"
		],
		"lv": [
			{
				"p": 100
			},
			{
				"p": 400
			},
			{
				"p": 1200
			}
		]
	},
	{
		"id": "security",
		"name": "Güvenlik",
		"desc": "Gece hırsızına karşı dükkânı koru",
		"st": "shutter",
		"tag": [
			420,
			45
		],
		"lvName": [
			"Kepenk kilidi",
			"Alarm sistemi",
			"Güvenlik kamerası",
			"Çelik kepenk + kayıt"
		],
		"lv": [
			{
				"p": 300
			},
			{
				"p": 1300
			},
			{
				"p": 3500
			},
			{
				"p": 7500
			}
		]
	},
	{
		"id": "sign",
		"name": "Tabela & Reklam",
		"desc": "Çok müşteri, yüksek fiyat",
		"st": "wall",
		"tag": [
			306,
			44
		],
		"lvName": [
			"Işıklı tabela",
			"El ilanı",
			"Şehir reklamı"
		],
		"lv": [
			{
				"p": 220
			},
			{
				"p": 850
			},
			{
				"p": 2300
			}
		]
	},
	{
		"id": "expand",
		"name": "Dükkânı Büyüt",
		"desc": "Duvarı yık, sıra uzasın",
		"st": "wall",
		"tag": [
			176,
			62
		],
		"lvName": [
			"+1 müşteri sırası",
			"+1 sıra daha",
			"Geniş salon"
		],
		"lv": [
			{
				"p": 480
			},
			{
				"p": 1950
			},
			{
				"p": 5000
			}
		]
	},
	{
		"id": "secim",
		"name": "Malzeme Seçimi",
		"desc": "Müşteri seçer, dürüm pahalanır",
		"st": "pickle",
		"tag": [
			96,
			45
		],
		"lvName": [
			"Müşteri tercihi",
			"Zor müşteriler"
		],
		"lv": [
			{
				"p": 450
			},
			{
				"p": 2600
			}
		]
	},
	{
		"id": "jenerator",
		"name": "Jeneratör",
		"desc": "Elektrik kesintisini kısaltır",
		"st": "grill",
		"tag": [
			216,
			45
		],
		"lvName": [
			"Akü yedeği",
			"Küçük jeneratör",
			"Kesintisiz güç"
		],
		"lv": [
			{
				"p": 650
			},
			{
				"p": 2600
			},
			{
				"p": 6800
			}
		]
	},
	{
		"id": "paint",
		"name": "Boya & Dekor",
		"desc": "Duvar rengi, müşteri sabrı",
		"st": "wall",
		"tag": [
			96,
			44
		],
		"lvName": [
			"Mavi fayans",
			"Yeşil fayans",
			"Lüks turuncu"
		],
		"lv": [
			{
				"p": 90
			},
			{
				"p": 330
			},
			{
				"p": 900
			}
		]
	}
]
