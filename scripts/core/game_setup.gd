# Game setup. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func initialize_game() -> void:
	# REMAKE: HTML surumu __DEV_BUILD'i test derlemesinde aciyordu (T ile test
	# paneli, ekranda DEV dugmesi). Godot karsiligi: editorden / debug export'ta acik,
	# release export'ta kapali.
	# Otomatik testlerde (--test) kapali: taban projenin piksel anlik
	# goruntuleri DEV dugmesiz kaydedildi.
	game.j_window = {"__DEV_BUILD": OS.is_debug_build() and not "--test" in OS.get_cmdline_user_args(), "__ERRS": []}
	game.j_navigator = {"maxTouchPoints": 0}
	game.j_localStorage = game.storage
	# i18n.js
	game.j_LANG = "en"
	game.j_LANGKEY = "doner_lang"
	game.j_EN = preload("res://data/en.gd").VALUE.duplicate(true)
	game.j_DILLER = [{"kod": "tr", "ad": "Türkçe", "ingAd": "Turkish", "bayrak": "tr"}, {"kod": "en", "ad": "English", "ingAd": "English", "bayrak": "gb"}, {"kod": "de", "ad": "Deutsch", "ingAd": "German", "bayrak": "de"}, {"kod": "es", "ad": "Español", "ingAd": "Spanish", "bayrak": "es"}, {"kod": "fr", "ad": "Français", "ingAd": "French", "bayrak": "fr"}, {"kod": "pt", "ad": "Português", "ingAd": "Portuguese", "bayrak": "br"}]
	game.j_SOZLUK = {"en": game.j_EN}
	J.setv(game.j_SOZLUK, "de", preload("res://data/dictionary_de.gd").VALUE.duplicate(true))
	J.setv(game.j_SOZLUK, "es", preload("res://data/dictionary_es.gd").VALUE.duplicate(true))
	J.setv(game.j_SOZLUK, "fr", preload("res://data/dictionary_fr.gd").VALUE.duplicate(true))
	J.setv(game.j_SOZLUK, "pt", preload("res://data/dictionary_pt.gd").VALUE.duplicate(true))
	# core.js
	game.j_W = 480.0
	game.j_H = 270.0
	game.j_cv = game.screen_canvas
	game.j_ctx = J.method(game.j_cv, "getContext", ["2d", {"alpha": false}])
	J.setv(game.j_ctx, "imageSmoothingEnabled", false)
	game.j_TOUCH = (J.has(game.j_window, "ontouchstart") if J.has(game.j_window, "ontouchstart") else J.gt(J.getv(game.j_navigator, "maxTouchPoints"), 0.0))
	game.j_VIEW = {"top": 0.0, "bot": 0.0, "right": 0.0}
	game.j_VIEW_UST_MAX = 34.0
	game.j_VIEW_ALT_MAX = 12.0
	game.j_VIEW_SAG_MAX = 8.0
	if J.truth(J.getv(game.j_window, "visualViewport")):
		pass
	game.f_fitScreen()
	game.j_TAU = (J.getv({"PI": PI}, "PI") * 2.0)
	game.j_P = {"ink": "#241a20", "ink2": "#3a2a30", "white": "#fffaf0", "bone": "#efe4d2", "st0": "#e6e6ea", "st1": "#c8c9d2", "st2": "#a4a5b3", "st3": "#7d7e8d", "st4": "#5b5c69", "tl0": "#6ba7c4", "tl1": "#4d87a6", "tl2": "#3a6c88", "tl3": "#2c5369", "tl4": "#1e3c4e", "grout": "#25485c", "mt0": "#f2f4f6", "mt1": "#d3d8de", "mt2": "#aeb5be", "mt3": "#878e99", "mt4": "#5f6672", "mt5": "#41474f", "wd0": "#a8703f", "wd1": "#8a5730", "wd2": "#6b4122", "wd3": "#4e2e17", "m0": "#ffd9a0", "m1": "#f0b269", "m2": "#d18c42", "m3": "#a5622a", "m4": "#78421a", "m5": "#4d290f", "raw": "#e79f8c", "raw2": "#c97a68", "f0": "#fff3b0", "f1": "#ffd257", "f2": "#ff9c2e", "f3": "#ef5f22", "f4": "#b8331a", "g0": "#cfe08a", "g1": "#a8c257", "g2": "#7fa138", "g3": "#5b7726", "g4": "#3d5219", "s0": "#fffdf2", "s1": "#efe7d0", "s2": "#d6cbae", "s3": "#b3a684", "p0": "#ffe9a3", "p1": "#f7cc63", "p2": "#dba53a", "p3": "#a97724", "p4": "#7d5417", "cola": "#43220f", "cola2": "#6b3a1c", "or0": "#ffb03c", "or1": "#f0821c", "ay0": "#f6f4ea", "au0": "#fff2a8", "au1": "#ffd34e", "au2": "#e0a41f", "au3": "#a97113", "red0": "#e05a48", "red1": "#c33c2c", "red2": "#96271c", "red3": "#6d1a12", "skin0": "#ffdcb0", "skin1": "#f0bd8a", "skin2": "#cf9560", "skin3": "#a06f42", "ok": "#78d06a", "warn": "#ffcb3d", "bad": "#e8483a", "blue": "#57a9e0", "blue2": "#3b7fb5", "pur": "#9a6bcf", "pink": "#f090b8", "ui0": "#fdf3dd", "ui1": "#e5cfa4", "ui2": "#b99a68", "ui3": "#7d603a", "ui4": "#4a3722", "ui5": "#2b1f14", "sh": "rgba(0,0,0,.30)", "sh2": "rgba(0,0,0,.55)"}
	game.j_BAYER = [0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0]
	game.j_GLYPHS = preload("res://data/glyphs.gd").VALUE.duplicate(true)
	game.j_FONT = {}
	game.j_FONT_H = 8.0
	J.invoke(game.game_setup._closure_1.bind({}), [])
	game.j__atlas = {}
	game.j_IN = {"x": 0.0, "y": 0.0, "downX": 0.0, "downY": 0.0, "down": false, "pressed": false, "released": false, "keys": {}, "kp": {}, "downTime": 0.0, "over": null, "hot": null}
	game.j_TEXTIN = {"active": false, "value": "", "max": 14.0, "done": false, "cancel": false}
	game.j_CAM = {"sx": 0.0, "sy": 0.0, "shake": 0.0, "flash": 0.0, "flashCol": "#fff"}
	game.j_PS = []
	game.j_FT = []
	game.j_AC = null
	game.j_MASTER = null
	game.j_MUTED = false
	game.j_MUSBUS = null
	game.j_SFXBUS = null
	game.j_VOLKEY = "doner_ses"
	game.j_VOL = {"mus": 65.0, "sfx": 100.0}
	game.j_POUR = null
	game.j_AMB = null
	game.j_SFX = {"chop": game.audio_cues._closure_3.bind({}), "slice": game.audio_cues._closure_4.bind({}), "pick": game.audio_cues._closure_5.bind({}), "drop": game.audio_cues._closure_6.bind({}), "bad": game.audio_cues._closure_7.bind({}), "coin": game.audio_cues._closure_8.bind({}), "cash": game.audio_cues._closure_9.bind({}), "ding": game.audio_cues._closure_10.bind({}), "serve": game.audio_cues._closure_11.bind({}), "pour": game.audio_cues._closure_12.bind({}), "fry": game.audio_cues._closure_13.bind({}), "sizzle": game.audio_cues._closure_14.bind({}), "ui": game.audio_cues._closure_15.bind({}), "uiBack": game.audio_cues._closure_16.bind({}), "levelup": game.audio_cues._closure_17.bind({}), "fail": game.audio_cues._closure_19.bind({}), "pop": game.audio_cues._closure_21.bind({}), "angry": game.audio_cues._closure_22.bind({}), "bell": game.audio_cues._closure_23.bind({}), "knife": game.audio_cues._closure_24.bind({}), "rain": game.audio_cues._closure_25.bind({}), "stamp": game.audio_cues._closure_26.bind({}), "fine": game.audio_cues._closure_27.bind({}), "moto": game.audio_cues._closure_29.bind({}), "phone": game.audio_cues._closure_30.bind({}), "door": game.audio_cues._closure_31.bind({}), "crinkle": game.audio_cues._closure_32.bind({}), "squirt": game.audio_cues._closure_33.bind({}), "plate": game.audio_cues._closure_34.bind({}), "steam": game.audio_cues._closure_35.bind({}), "horn": game.audio_cues._closure_36.bind({}), "carPass": game.audio_cues._closure_37.bind({}), "footstep": game.audio_cues._closure_38.bind({}), "glass": game.audio_cues._closure_39.bind({}), "shutter": game.audio_cues._closure_40.bind({}), "fanfare": game.audio_cues._closure_41.bind({}), "slam": game.audio_cues._closure_44.bind({}), "potato": game.audio_cues._closure_45.bind({}), "sack": game.audio_cues._closure_46.bind({}), "basket": game.audio_cues._closure_47.bind({}), "scoop": game.audio_cues._closure_48.bind({}), "wrap": game.audio_cues._closure_49.bind({}), "roll": game.audio_cues._closure_50.bind({}), "drawer": game.audio_cues._closure_51.bind({}), "tick": game.audio_cues._closure_52.bind({}), "warn": game.audio_cues._closure_53.bind({})}
	game.j_SAVEKEY = "doner_efsanesi_v1"
	game.j_SAVE_SEMA = 2.0
	game.j_SAVE_DURUM = "ok"
	game.j_SAVE_UYARILDI = false
	# sprites.js
	game.j_SPR = preload("res://data/spr.gd").VALUE.duplicate(true)
	game.j_SPR_KALIP = {"kralice": "kralice", "kuzeyli": "kuzeyli", "cirak": "cirak", "bilge": "bilge", "kimyager": "kimyager"}
	game.j_SPR_ISTEK = 0.0
	game.j_SPR_TAMAM = 0.0
	game.j_SPR_BASLADI = false
	# audio.js
	game.j_SND = {"fry": {"url": "res://assets/audio/asset_00.mp3", "vol": 0.55, "loop": true, "tur": "sfx", "dS": 3.4, "dE": 4.9}, "coin": {"url": "res://assets/audio/asset_01.m4a", "vol": 0.6, "tur": "sfx"}, "street": {"url": "res://assets/audio/asset_02.mp3", "vol": 0.3, "loop": true, "tur": "sfx"}, "rain": {"url": "res://assets/audio/asset_03.mp3", "vol": 0.42, "loop": true, "tur": "sfx"}, "korna1": {"url": "res://assets/audio/asset_04.wav", "vol": 0.2, "tur": "sfx"}, "korna2": {"url": "res://assets/audio/asset_05.wav", "vol": 0.17, "tur": "sfx"}, "camYagmur": {"url": "res://assets/audio/asset_06.wav", "vol": 0.34, "loop": true, "tur": "sfx"}}
	game.j_SNDOK = false
	# music.js
	game.j_MUS = {"on": true, "timer": null, "step": 0.0, "next": 0.0, "tempo": 0.135, "gain": null, "mode": "menu"}
	game.j_SCALE = [293.66, 311.13, 369.99, 392.0, 440.0, 466.16, 523.25, 587.33]
	game.j_MEL = [[0.0, 6.0], [(-J.n(1.0)), 0.0], [2.0, 5.0], [(-J.n(1.0)), 0.0], [3.0, 6.0], [(-J.n(1.0)), 0.0], [2.0, 4.0], [(-J.n(1.0)), 0.0], [4.0, 7.0], [(-J.n(1.0)), 0.0], [3.0, 5.0], [(-J.n(1.0)), 0.0], [1.0, 5.0], [(-J.n(1.0)), 0.0], [0.0, 6.0], [(-J.n(1.0)), 0.0]]
	game.j_MEL2 = [[7.0, 7.0], [(-J.n(1.0)), 0.0], [6.0, 5.0], [5.0, 5.0], [4.0, 6.0], [(-J.n(1.0)), 0.0], [3.0, 5.0], [2.0, 4.0], [3.0, 6.0], [(-J.n(1.0)), 0.0], [2.0, 5.0], [(-J.n(1.0)), 0.0], [0.0, 7.0], [(-J.n(1.0)), 0.0], [(-J.n(1.0)), 0.0], [(-J.n(1.0)), 0.0]]
	game.j_BASS = [73.42, 0.0, 0.0, 0.0, 98.0, 0.0, 0.0, 0.0, 73.42, 0.0, 0.0, 0.0, 110.0, 0.0, 0.0, 0.0]
	# art.js
	game.j_LAY = {"ledgeY": 148.0, "ledgeH": 11.0, "win": {"x": 150.0, "y": 30.0, "w": 272.0, "h": 100.0}, "glass": {"x": 154.0, "y": 34.0, "w": 264.0, "h": 92.0}, "surfY": 159.0, "lipY": 247.0, "floorY": 258.0, "rowA": 168.0, "rowB": 200.0, "spit": {"cx": 80.0, "top": 58.0, "bot": 168.0}, "chef": {"x": 4.0, "y": 108.0}, "custSlots": [{"x": 142.0, "y": 152.0}, {"x": 208.0, "y": 152.0}, {"x": 274.0, "y": 152.0}, {"x": 340.0, "y": 152.0}, {"x": 404.0, "y": 152.0}]}
	game.j_ST = {"spit": {"x": 58.0, "y": 50.0, "w": 46.0, "h": 126.0}, "meat": {"x": 58.0, "y": 168.0, "w": 46.0, "h": 28.0}, "pickle": {"x": 108.0, "y": 168.0, "w": 34.0, "h": 28.0}, "yogurt": {"x": 142.0, "y": 168.0, "w": 34.0, "h": 28.0}, "friesT": {"x": 176.0, "y": 168.0, "w": 34.0, "h": 28.0}, "garnish": {"x": 214.0, "y": 168.0, "w": 42.0, "h": 28.0}, "drinkM": {"x": 260.0, "y": 146.0, "w": 62.0, "h": 50.0}, "ayran": {"x": 294.0, "y": 150.0, "w": 28.0, "h": 46.0}, "fryer": {"x": 326.0, "y": 152.0, "w": 58.0, "h": 44.0}, "potato": {"x": 386.0, "y": 160.0, "w": 44.0, "h": 38.0}, "crate": {"x": 438.0, "y": 190.0, "w": 34.0, "h": 34.0}, "bread": {"x": 44.0, "y": 200.0, "w": 42.0, "h": 46.0}, "board": {"x": 90.0, "y": 199.0, "w": 94.0, "h": 47.0}, "paper": {"x": 188.0, "y": 200.0, "w": 24.0, "h": 46.0}, "grill": {"x": 216.0, "y": 200.0, "w": 68.0, "h": 46.0}, "cut": {"x": 288.0, "y": 200.0, "w": 48.0, "h": 46.0}, "sauce": {"x": 340.0, "y": 198.0, "w": 48.0, "h": 48.0}, "fbox": {"x": 392.0, "y": 200.0, "w": 38.0, "h": 46.0}, "sweet": {"x": 438.0, "y": 150.0, "w": 34.0, "h": 34.0}, "trash": {"x": 440.0, "y": 228.0, "w": 30.0, "h": 28.0}, "uncle": {"x": 2.0, "y": 96.0, "w": 46.0, "h": 162.0}, "phone": {"x": 6.0, "y": 44.0, "w": 26.0, "h": 30.0}, "shutter": {"x": 150.0, "y": 30.0, "w": 272.0, "h": 100.0}}
	game.j_BLD = [{"wall": "#c9a883", "trim": "#8a6a48", "awn": "#c0281c", "sign": "#2f4f6a"}, {"wall": "#a7bfcb", "trim": "#6d8492", "awn": "#2f6a8a", "sign": "#7a3a2a"}, {"wall": "#c8a0a6", "trim": "#8e6a70", "awn": "#3f8a4a", "sign": "#4a3a6a"}, {"wall": "#bfb491", "trim": "#867c60", "awn": "#b0862a", "sign": "#2f5f3a"}, {"wall": "#9fb0a4", "trim": "#6b7a70", "awn": "#8a3a6a", "sign": "#5a4a2a"}]
	game.j_BLD_BETON = [{"wall": "#7a7e84", "trim": "#565a60", "awn": "#6a4a44", "sign": "#4a4e54"}, {"wall": "#6e7278", "trim": "#4a4e54", "awn": "#5a4440", "sign": "#3e4248"}, {"wall": "#868a90", "trim": "#5e6268", "awn": "#6a5450", "sign": "#52565c"}, {"wall": "#666a70", "trim": "#44484e", "awn": "#584442", "sign": "#3a3e44"}, {"wall": "#7e8288", "trim": "#5a5e64", "awn": "#644c48", "sign": "#464a50"}]
	game.j__binekT = (-J.n(1.0))
	game.j_EJD = {"faz": "yok", "t": 0.0}
	game.j_EJD_SURE = {"ucus": 2.2, "inis": 0.7, "iner": 1.5, "biner": 1.5, "kalkis": 2.4}
	game.j_SUP = {"faz": "yok", "t": 0.0}
	game.j_SUP_SURE = {"ucus": 1.6, "iner": 1.2, "biner": 1.2, "kalkis": 1.5}
	game.j_KAR = {"faz": "yok", "t": 0.0}
	game.j_KAR_SURE = {"gelis": 2.2, "kapiAc": 0.6, "iner": 1.6, "kapiKapa": 0.6, "kapiAc2": 0.6, "biner": 1.6, "kapiKapa2": 0.6, "gidis": 2.4}
	game.j_KAR_SIRA = ["yok", "gelis", "kapiAc", "iner", "kapiKapa", "bekle", "kapiAc2", "biner", "kapiKapa2", "gidis"]
	game.j_CAR_PAL = [{"b": "#c0392b", "d": "#8a2318", "l": "#e2604f"}, {"b": "#e8b62c", "d": "#a87c15", "l": "#ffd76a"}, {"b": "#e8ecef", "d": "#a8b0b8", "l": "#ffffff"}, {"b": "#2f6a8a", "d": "#1e4661", "l": "#4f9ec0"}, {"b": "#3f8a4a", "d": "#276030", "l": "#63b46f"}, {"b": "#4a5560", "d": "#2e363f", "l": "#6f7d8a"}, {"b": "#e07a2a", "d": "#a35316", "l": "#ffa055"}, {"b": "#7a4a9a", "d": "#53306c", "l": "#a273c0"}, {"b": "#2aa08a", "d": "#177063", "l": "#4fc9b0"}, {"b": "#22262c", "d": "#101317", "l": "#3d444c"}]
	game.j_PED_SHIRT = ["#3f6fbd", "#8a4a7a", "#3f8a4a", "#b0602a", "#4a5560", "#a83a2a", "#2f8a8a", "#6a4a9a", "#c9a23a", "#7a3a3a", "#356a4a", "#5a6a8a"]
	game.j_PED_PANT = ["#2f3740", "#4a3a2a", "#33414f", "#3a3a44", "#5a4a3a", "#26303a"]
	game.j_PED_SKIN = ["#f0bd8a", "#d9a273", "#b57f52", "#8a5c38", "#e0ae7e", "#6d4526"]
	game.j_PED_HAIR = ["#2b2018", "#5a3a1e", "#3a2a20", "#7a6a58", "#1a1410", "#8a6a3a", "#a89078"]
	game.j_PED_SHIRT_BETON = ["#5a6068", "#4a5058", "#5c6350", "#6a6458", "#454b54", "#67635a", "#515760", "#5e5a52", "#4e5a52", "#6a6e74", "#585e56", "#4a4e54"]
	game.j_WINOVER = null
	game.j_LANE_DIR = [1.0, (-J.n(1.0))]
	game.j_TLIGHT = {"state": "green", "t": 0.0, "GREEN": 11.0, "YELLOW": 2.0, "RED": 7.0}
	game.j_TRAF = []
	game.j_TRAFCITY = null
	game.j_TRAF_VARSAYILAN = [[0.0, 0.0, 0.0, 30.0], [0.0, 2.0, 2.0, 23.0], [0.0, 3.0, 4.0, 34.0], [1.0, 1.0, 1.0, 33.0], [1.0, 3.0, 3.0, 39.0], [1.0, 0.0, 5.0, 27.0]]
	game.j_KORNA = {"bek": 4.0, "son": 0.0}
	game.j_WALKERS = [{"sp": 7.0, "off": 0.1, "k": 0.0, "dir": 1.0}, {"sp": 5.8, "off": 0.58, "k": 1.0, "dir": (-J.n(1.0))}, {"sp": 8.2, "off": 0.34, "k": 2.0, "dir": 1.0}, {"sp": 6.6, "off": 0.8, "k": 5.0, "dir": (-J.n(1.0))}, {"sp": 6.2, "off": 0.22, "k": 7.0, "dir": 1.0}, {"sp": 7.6, "off": 0.68, "k": 9.0, "dir": (-J.n(1.0))}]
	game.j_CROSSERS = [{"k": 3.0, "p": 0.0, "hiz": 15.0, "bekle": 0.0, "git": 0.0, "kay": 0.0}, {"k": 8.0, "p": 0.0, "hiz": 13.0, "bekle": 1.4, "git": 0.0, "kay": 0.0}]
	game.j__carSnd = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	game.j_BG = null
	game.j_BGDECOR = 0.0
	game.j_STONEFG = null
	game.j_BGDAYI = null
	game.j_BGCITY = null
	game.j_BGRAKIP = null
	game.j_CX0 = 44.0
	game.j_CLAYER = null
	game.j_COUNTER_PAL = [{"base": "#c3c9d0", "hi": "#ffffff", "lo": "#2f343b", "lip": "#aeb5be", "edge": "#f6f8fa"}, {"base": "#a8bccd", "hi": "#e6f2fb", "lo": "#26384a", "lip": "#8fa6bb", "edge": "#dceaf6"}, {"base": "#c9a271", "hi": "#f6e2c0", "lo": "#4a3520", "lip": "#a5794a", "edge": "#e8c99a"}, {"base": "#c99a6a", "hi": "#ffdcae", "lo": "#5a3a1e", "lip": "#a87a44", "edge": "#f0c88e"}]
	game.j__mcC = {}
	game.j__mcQ = []
	game.j_ASIN_LUT = J.invoke(game.game_setup._closure_74.bind({}), [])
	game.j_BICAK_KADEME = [{"boy": 19.0, "yuk": 1.0, "cift": false, "celik": ["#767f88", "#a2abb3", "#c4ccd3"], "sapK": "#4e2e17", "sapG": "#6b4122", "sapI": "#8a5730", "bilezik": "#7a6c5c", "bilezikI": "#9a8a76", "percin": 0.0, "sapUz": 7.0, "sapKal": 1.0}, {"boy": 25.0, "yuk": 1.0, "cift": false, "celik": ["#5a636c", "#c9d2da", "#eef4f8"], "sapK": "#141414", "sapG": "#242830", "sapI": "#3a4048", "bilezik": "#8f9aa4", "bilezikI": "#eef4f8", "percin": 2.0, "sapUz": 8.0, "sapKal": 2.0}, {"boy": 27.0, "yuk": 0.0, "cift": true, "celik": ["#5a636c", "#c9d2da", "#eef4f8"], "sapK": "#141414", "sapG": "#242830", "sapI": "#3a4048", "bilezik": "#8f9aa4", "bilezikI": "#eef4f8", "percin": 3.0, "sapUz": 9.0, "sapKal": 2.0}, {"boy": 29.0, "yuk": 2.0, "cift": false, "celik": ["#4a525a", "#b6c0c9", "#ffffff"], "sapK": "#141414", "sapG": "#242830", "sapI": "#565e68", "bilezik": "#a97113", "bilezikI": "#ffd34e", "percin": 3.0, "sapUz": 10.0, "sapKal": 3.0}]
	game.j_FILLCACHE = {}
	game.j_FILLN = 0.0
	game.j_ET = {"kabuk": "#7e4412", "koyu": "#9c5718", "orta": "#bd7024", "et": "#d98f38", "ic": "#eeb463", "isik": "#ffd291", "yag": "#fff0cc", "kömür": "#52290a"}
	game.j__etTon = 1.0
	game.j_PT = {"koyu": "#7a5410", "govde": "#d9ab3e", "acik": "#f0d271", "altin": "#e8bf52", "kizarmis": "#b8801f", "uc": "#8a5c12", "isik": "#fff0b8", "tuz": "#ffffff"}
	game.j_POTBIN = null
	game.j_SAUCE_DEF = [{"id": "hot", "c0": "#8e1c14", "c1": "#e2382a", "c2": "#ff7a62", "cap": "#3a2a24"}, {"id": "garlic", "c0": "#bdb6a2", "c1": "#f6f2e6", "c2": "#ffffff", "cap": "#6f7a84"}, {"id": "butter", "c0": "#a8700f", "c1": "#f0b53c", "c2": "#ffd77a", "cap": "#7a4f16"}]
	game.j_SISE_BOY = [{"w": 11.0, "gov": 17.0, "omuz": 5.0, "boyun": 3.0}, {"w": 14.0, "gov": 12.0, "omuz": 4.0, "boyun": 3.0}, {"w": 12.0, "gov": 15.0, "omuz": 5.0, "boyun": 3.0}]
	# sehir.js
	game.j_SEHIR = preload("res://data/sehir.gd").VALUE.duplicate(true)
	game.j_BOYA_KAT = [[null, 1.0, 0.0], [0.56, 0.9, 0.0], [0.33, 0.8, 0.01], [0.07, 0.78, 0.05]]
	# food.js
	game.j_PIDE_KAL = 5.2
	game.j_PIDE_DER = 3.4
	# chars.js
	game.j_SKINS = [["#ffdcb0", "#f0bd8a", "#cf9560", "#a06f42"], ["#f6c99a", "#dda674", "#b8834f", "#8d5f34"], ["#d9a273", "#bd8354", "#96633a", "#6e4726"], ["#b07a45", "#8a5730", "#6b4122", "#4e2e17"], ["#ffe6c8", "#f2c9a2", "#d2a175", "#a87a50"], ["#f0d0a8", "#d8b088", "#b08a5c", "#856240"], ["#e8c4a0", "#cea67e", "#a87f56", "#7d5a38"], ["#c48f60", "#a67044", "#82522c", "#5d391c"], ["#9a6a3e", "#78502a", "#5a3a1c", "#3f2712"]]
	game.j_HAIRCOLS = ["#2b1d16", "#4a3020", "#7a5230", "#a8763c", "#d8d2c8", "#8e8e94", "#e8e4dc", "#5a2f1c"]
	game.j_SHIRTS = ["#4a7fc0", "#c95a4a", "#5aa86a", "#d8a03c", "#8a6ac0", "#3f9fa8", "#c96a9a", "#8a8f96", "#e0e4e8", "#5c6470"]
	game.j_NOCHEF = false
	game.j_GOZ_RENK = ["#2b2018", "#33557e", "#3c6347", "#6a5230"]
	game.j_FERMAN_TULUM = "#5c6350"
	game.j_KALIP_ACIK = true
	game.j_KALIP = [{"id": "yok", "w": 30.0, "tip": "hepsi"}, {"id": "isci", "w": 8.0, "tip": "buyuk", "baslik": true}, {"id": "memur", "w": 8.0, "tip": "buyuk"}, {"id": "ogrenci", "w": 8.0, "tip": "hepsi"}, {"id": "yasli", "w": 7.0, "tip": "buyuk"}, {"id": "turist", "w": 5.0, "tip": "buyuk", "baslik": true}, {"id": "sporcu", "w": 6.0, "tip": "hepsi"}, {"id": "kurye", "w": 5.0, "tip": "buyuk", "baslik": true}, {"id": "sofor", "w": 5.0, "tip": "buyuk", "baslik": true}, {"id": "kuzeyli", "w": 0.0, "tip": "buyuk"}, {"id": "kimyager", "w": 0.0, "tip": "buyuk", "baslik": true}, {"id": "cirak", "w": 0.0, "tip": "hepsi"}, {"id": "kralice", "w": 0.0, "tip": "kadin"}, {"id": "bilge", "w": 0.0, "tip": "buyuk", "baslik": true}]
	game.j_OZEL_ARA_MIN = 10.0
	game.j_OZEL_ARA_MAK = 15.0
	game.j_OZEL_ILK_MIN = 4.0
	game.j_OZEL_ILK_MAK = 8.0
	game.j_OZEL_SANS = 0.16
	game.j_KALIP_TEST = false
	game.j_OZEL_KALIP = {"kuzeyli": 1.0, "kimyager": 1.0, "cirak": 1.0, "kralice": 1.0, "bilge": 1.0}
	game.j_OZEL_ACIK = false
	game.j_KALIP_KIMLIK = {"kuzeyli": {"tip": "adam", "skin": 1.0, "big": true, "yuz": {"sekil": 2.0, "goz": 1.0, "gozR": 1.0, "burun": 3.0, "kas": 1.0, "agiz": 4.0, "gozB": 0.0, "oran": 1.0, "aralik": 1.0}}, "kimyager": {"tip": "adam", "skin": 1.0, "big": false, "yuz": {"sekil": 0.0, "goz": 5.0, "gozR": 2.0, "burun": 1.0, "kas": 2.0, "agiz": 4.0, "gozB": 3.0, "oran": 1.0, "aralik": 1.0}}, "cirak": {"tip": "adam", "skin": 1.0, "big": false, "yuz": {"sekil": 3.0, "goz": 2.0, "gozR": 2.0, "burun": 0.0, "kas": 0.0, "agiz": 0.0, "gozB": 2.0, "oran": 1.0, "aralik": 1.0}}, "kralice": {"tip": "kadin", "skin": 0.0, "big": false, "yuz": {"sekil": 4.0, "goz": 2.0, "gozR": 1.0, "burun": 0.0, "kas": 4.0, "agiz": 3.0, "gozB": 1.0, "oran": 1.0, "aralik": 1.0}}, "bilge": {"tip": "adam", "skin": 0.0, "big": false, "yuz": {"sekil": 1.0, "goz": 5.0, "gozR": 3.0, "burun": 2.0, "kas": 1.0, "agiz": 4.0, "gozB": 3.0, "oran": 1.0, "aralik": 1.0}}}
	game.j__kalipSira = 0.0
	game.j_KALIP_RENK = {"isci": {"ana": ["#c8781e", "#7a7a52", "#b8621c"], "seri": "#f0ece0"}, "memur": {"ana": ["#2f3a52", "#3a3340", "#2b3b3a"], "seri": "#c04a3a"}, "ogrenci": {"ana": ["#4a4f5c", "#3f5a72", "#5c4a5e"], "seri": "#d8b84a"}, "yasli": {"ana": ["#7a6650", "#5a5f6b", "#7a5a5e"], "seri": "#c8b898"}, "turist": {"ana": ["#3aa8a0", "#d8a03c", "#c96a9a"], "seri": "#fdf3dd"}, "sporcu": {"ana": ["#3a5f9a", "#9a3a46", "#357a54"], "seri": "#f4f4f0"}, "kurye": {"ana": ["#c4dc46", "#e8c020", "#96cc44"], "seri": "#e8e4d8", "kask": ["#d8352c", "#f0ece4", "#2b3038"]}, "sofor": {"ana": ["#7a6a52", "#6b5a62", "#5a6b6b"], "seri": "#c85a3a", "kasket": ["#3a3a42", "#4a3f32", "#38424e"]}, "kuzeyli": {"ana": ["#232830", "#2b2620", "#1e2430"], "seri": "#6a5138", "kurk": ["#4f463a", "#5a5148", "#3f382e"]}, "kimyager": {"ana": ["#d8c22a", "#c9b420", "#e0cc38"], "seri": "#3c4650"}, "cirak": {"ana": ["#1a1d26", "#20242e", "#161a22"], "seri": "#9a2632"}, "kralice": {"ana": ["#436a7e", "#3d6070", "#4a7286"], "seri": "#d8ac35"}, "bilge": {"ana": ["#70707a", "#666672", "#7a7a84"], "seri": "#54402a"}}
	# data.js
	game.j_PRICE = game.recipe_system.PRICE.duplicate(true)
	game.j_MEAT_NEED = game.recipe_system.MEAT_NEED
	game.j_FRIES_NEED = game.recipe_system.FRIES_NEED
	game.j_PICKLE_NEED = game.recipe_system.PICKLE_NEED
	game.j_YOGURT_NEED = game.recipe_system.YOGURT_NEED
	game.j_PLATE_YOGURT = game.recipe_system.PLATE_YOGURT
	game.j_PIDE_NEED = game.recipe_system.PIDE_NEED
	game.j_TOMATO_NEED = game.recipe_system.TOMATO_NEED
	game.j_PEPPER_NEED = game.recipe_system.PEPPER_NEED
	game.j_ISK_MEAT = game.recipe_system.ISK_MEAT
	game.j_PHONE_MUL = 1.9
	game.j_RAIN_CHANCE = 0.16
	game.j_MAC_ARA_MIN = 8.0
	game.j_MAC_ARA_MAK = 12.0
	game.j_MAC_ILK = 6.0
	game.j_MAC_BAS = 0.4
	game.j_MAC_BIT = 0.68
	game.j_MAC_HIZ = 0.34
	game.j_ILK_MUSTERI = 10.0
	game.j_KEDI_GUN = 4.0
	game.j_KEDI_SANS = 0.3
	game.j_KEDI_BEKLE = 26.0
	game.j_KESINTI_GUN = 8.0
	game.j_KESINTI_SANS = 0.16
	game.j_KESINTI_SURE = 34.0
	game.j_SECIM_MALZEME = ["pickle", "yogurt", "fries"]
	game.j_SECIM_AD = {"pickle": "turşusuz", "yogurt": "yoğurtsuz", "fries": "patatessiz"}
	game.j_SECIM_KISA = {"pickle": "Turşu", "yogurt": "Yoğurt", "fries": "Patates"}
	game.j_RAKIP_GUN = 10.0
	game.j_RAKIP_ARA_MIN = 5.0
	game.j_RAKIP_ARA_MAK = 8.0
	game.j_RAKIP_PES = 6.0
	game.j_BAHIS = [{"id": "durum", "on": "Bugün", "son": "dürüm satamazsın.", "para": false, "hedef": game.rival_system._closure_87.bind({}), "olc": game.rival_system._closure_88.bind({})}, {"id": "para", "on": "Bugün kasaya", "son": "koyamazsın.", "para": true, "hedef": game.rival_system._closure_89.bind({}), "olc": game.rival_system._closure_90.bind({})}, {"id": "kacan", "on": "", "son": "Bugün en az bir müşteri kaçırırsın.", "para": false, "hedef": game.rival_system._closure_91.bind({}), "olc": game.rival_system._closure_92.bind({})}, {"id": "bahsis", "on": "Bugün toplam", "son": "bahşiş alamazsın.", "para": true, "hedef": game.rival_system._closure_93.bind({}), "olc": game.rival_system._closure_94.bind({})}]
	game.j_RAKIP_SELAM_ILK = ["Karşıya dükkân açtım. Komşuyuz artık.", "Yeni komşun benim. Karşıdaki dükkân.", "Karşıdaki dükkân bana ait. Tanışalım."]
	game.j_RAKIP_SELAM = ["Yine ben. Sıkıldın mı benden?", "Kepenk açık, demek iş var.", "Geçerken uğradım. Bir bakayım dedim.", "Dün seni izledim. Fena değilsin.", "Karşıdan bakıyorum, tezgâh boş duruyor."]
	game.j_RAKIP_KABUL = ["Tamam. Akşam hesaplaşırız.", "Anlaştık. Kepenk inince görüşürüz.", "Sözün söz. Akşama bakarız."]
	game.j_RAKIP_RET = ["Korktun demek. Anlıyorum.", "Peki. Belki başka gün.", "Olsun. Ben yine gelirim."]
	game.j_RAKIP_CEKIL = ["Cevap yok. Ben gidiyorum.", "Meşgulsün galiba. Sonra konuşuruz."]
	game.j_FINE_MIN = 150.0
	game.j_FINE_MAX = 400.0
	game.j_TRASH_PER_PEEL = 0.045
	game.j_TRASH_PER_ITEM = 0.055
	game.j_TRASH_PER_SALE = 0.012
	game.j_INSPECT_DAY = 4.0
	game.j_INSPECT_CHANCE = 0.28
	game.j_THIEF_DAY = 12.0
	game.j_THIEF_CHANCE = 0.24
	game.j_THIEF_MIN = 0.08
	game.j_THIEF_MAX = 0.2
	game.j_MOTO_DAY = 8.0
	game.j_MOTO_CHANCE = 0.055
	game.j_HOMELESS_DAY = 5.0
	game.j_HOMELESS_CHANCE = 0.3
	game.j_LUCK_MAX = 6.0
	game.j_LUCK_FIND_MIN = 50.0
	game.j_LUCK_FIND_MAX = 200.0
	game.j_DEBT_START = 5000000.0
	game.j_DEBT_CUT = 0.18
	game.j_UPG = preload("res://data/upg.gd").VALUE.duplicate(true)
	game.j_TUN = {
		"meatPerClick": game.equipment_tuning.meat_per_click.bind({}),
		"shaveDist": game.equipment_tuning.shave_dist.bind({}),
		"shaveCd": game.equipment_tuning.shave_cd.bind({}),
		"autoShaveCd": game.equipment_tuning.auto_shave_cd.bind({}),
		"autoShave": game.equipment_tuning.auto_shave.bind({}),
		"meatCap": game.equipment_tuning.meat_cap.bind({}),
		"cutTime": game.equipment_tuning.cut_time.bind({}),
		"cutYield": game.equipment_tuning.cut_yield.bind({}),
		"autoCut": game.equipment_tuning.auto_cut.bind({}),
		"fryTime": game.equipment_tuning.fry_time.bind({}),
		"fryCap": game.equipment_tuning.fry_cap.bind({}),
		"autoFry": game.equipment_tuning.auto_fry.bind({}),
		"friesCap": game.equipment_tuning.fries_cap.bind({}),
		"paperTime": game.equipment_tuning.paper_time.bind({}),
		"autoPaper": game.equipment_tuning.auto_paper.bind({}),
		"grillOn": game.equipment_tuning.grill_on.bind({}),
		"grillTime": game.equipment_tuning.grill_time.bind({}),
		"grillCap": game.equipment_tuning.grill_cap.bind({}),
		"grillYanar": game.equipment_tuning.grill_yanar.bind({}),
		"grillYanmaSure": game.equipment_tuning.grill_yanma_sure.bind({}),
		"autoGrill": game.equipment_tuning.auto_grill.bind({}),
		"drinkOn": game.equipment_tuning.drink_on.bind({}),
		"pourTime": game.equipment_tuning.pour_time.bind({}),
		"autoDrink": game.equipment_tuning.auto_drink.bind({}),
		"fboxOn": game.equipment_tuning.fbox_on.bind({}),
		"fboxTime": game.equipment_tuning.fbox_time.bind({}),
		"autoBox": game.equipment_tuning.auto_box.bind({}),
		"garnishOn": game.equipment_tuning.garnish_on.bind({}),
		"garnishMax": game.equipment_tuning.garnish_max.bind({}),
		"sauceOn": game.equipment_tuning.sauce_on.bind({}),
		"sauceLate": game.equipment_tuning.sauce_late.bind({}),
		"iskOn": game.equipment_tuning.isk_on.bind({}),
		"iskMeat": game.equipment_tuning.isk_meat.bind({}),
		"autoIsk": game.equipment_tuning.auto_isk.bind({}),
		"ayranOn": game.equipment_tuning.ayran_on.bind({}),
		"sweetOn": game.equipment_tuning.sweet_on.bind({}),
		"ayranMax": game.equipment_tuning.ayran_max.bind({}),
		"sweetMax": game.equipment_tuning.sweet_max.bind({}),
		"boards": game.equipment_tuning.boards.bind({}),
		"autoCoin": game.equipment_tuning.auto_coin.bind({}),
		"autoStock": game.equipment_tuning.auto_stock.bind({}),
		"autoTrash": game.equipment_tuning.auto_trash.bind({}),
		"phoneOn": game.equipment_tuning.phone_on.bind({}),
		"phoneGap": game.equipment_tuning.phone_gap.bind({}),
		"courierTime": game.equipment_tuning.courier_time.bind({}),
		"courierYavas": game.equipment_tuning.courier_yavas.bind({}),
		"havaGelis": game.equipment_tuning.hava_gelis.bind({}),
		"havaSabir": game.equipment_tuning.hava_sabir.bind({}),
		"havaBahsis": game.equipment_tuning.hava_bahsis.bind({}),
		"secimOn": game.equipment_tuning.secim_on.bind({}),
		"secimEnCok": game.equipment_tuning.secim_en_cok.bind({}),
		"secimZam": game.equipment_tuning.secim_zam.bind({}),
		"macSabir": game.equipment_tuning.mac_sabir.bind({}),
		"macBahsis": game.equipment_tuning.mac_bahsis.bind({}),
		"kesintiSure": game.equipment_tuning.kesinti_sure.bind({}),
		"kesintiVar": game.equipment_tuning.kesinti_var.bind({}),
		"uncleUses": game.equipment_tuning.uncle_uses.bind({}),
		"stockMax": game.equipment_tuning.stock_max.bind({}),
		"refillPer": game.equipment_tuning.refill_per.bind({}),
		"secLevel": game.equipment_tuning.sec_level.bind({}),
		"thiefVisit": game.equipment_tuning.thief_visit.bind({}),
		"thiefSteal": game.equipment_tuning.thief_steal.bind({}),
		"secName": game.equipment_tuning.sec_name.bind({}),
		"patience": game.equipment_tuning.patience.bind({}),
		"wallStyle": game.equipment_tuning.wall_style.bind({}),
		"slots": game.equipment_tuning.slots.bind({}),
		"priceMul": game.equipment_tuning.price_mul.bind({}),
		"custMul": game.equipment_tuning.cust_mul.bind({})
	}
	game.j_LINES_WAIT = ["Acele et usta!", "Çok acıktım…", "Hızlı olsun abi", "Ne kadar sürer?", "Bekliyorum ha!", "Kokusu güzel!"]
	game.j_LINES_HAPPY = ["Ellerine sağlık!", "Efsane olmuş!", "Bir numara!", "Yine geleceğim", "Harika döner!", "Nefis!"]
	game.j_LINES_ANGRY = ["Çok beklettin!", "Gidiyorum ben!", "Rezalet!", "Bir daha gelmem!", "Yeter artık!"]
	game.j_LINES_CHEAP = ["Eksik kalmış be!", "Bu ne ya, az koymuşsun", "Yarım dürüm mü bu?", "Parasını da yarım veririm", "Doymadım ki!"]
	game.j_LINES_WRONG = ["Bu benim değil!", "Yanlış sipariş!", "Ben bunu istemedim"]
	game.j_KALIP_REPLIK = {"kuzeyli": "Nöbet bitti. Ayaz bastırdı, sıcak bir şey iyi gider.", "kimyager": "Adımı bilmiyorsun ama siparişimi biliyorsun.", "cirak": "Süpürgeyi kapıya park ettim, çekmesinler.", "kralice": "Ejderhaları dışarı park ettim. Çabuk ol.", "bilge": "Sıra bende. Kimse öne geçemez."}
	game.j_LINES_SECIM = ["Ben böyle istememiştim!", "Söylediğimi koymamışsın.", "Bunu istemiyordum ya…", "Siparişimi dinlemedin."]
	game.j_LINES_SAUCE = ["Sosunu unuttun!", "Ben acılı istemiştim", "Sos nerede usta?", "Sossuz olur mu hiç?"]
	game.j_LINES_THIEF_WIN = ["Kasadan aldığını götürdü…", "Kepengi zorlamış!", "Gece dükkâna giren olmuş."]
	game.j_LINES_THIEF_LOSE = ["Alarm çaldı, kaçtı!", "Kepengi açamadı.", "Kamerayı görünce kaçtı.", "Kilide takıldı, gitti."]
	game.j_LINES_MOTO = ["Motor çalışmıyor usta…", "Dayı: \"Marşa basıyorum, ses yok.\"", "Motorun bujisi gitmiş."]
	game.j_LINES_HOMELESS = ["Bir lokma… Allah razı olsun.", "İki gündür bir şey yemedim.", "Karnım çok aç usta…"]
	game.j_LINES_HOMELESS_OK = ["Allah bereket versin!", "Elin dert görmesin.", "Bunu unutmam usta."]
	game.j_LINES_LUCK = ["Yolda para buldum usta!", "Bak ne buldum!", "Şansımız açık bugün."]
	game.j_LINES_INSPECT_OK = ["Tertemiz, helal olsun!", "Böyle devam usta.", "Not: temiz mutfak."]
	game.j_LINES_INSPECT_BAD = ["Bu ne pislik böyle!", "Çöpler taşmış, ceza yazıyorum.", "Hijyen sıfır. Ceza!"]
	game.j_POSTERS = ["Yok", "Halı", "Döner Afişi", "Babanın Fotoğrafı"]
	game.j_COUNTER_STYLES = ["Çelik", "Mavi", "Ahşap", "Bakır"]
	game.j_TIPS_LOAD = ["Dönerin üstünde imleci yukarı-aşağı gezdir, et kesilir.", "Dürümü sarmak için aşağıdan yukarı sürükle.", "Turşu ve yoğurt çabuk biter — kutudan doldurmayı unutma.", "Bir patates yaklaşık 6 dürümlük kızartma çıkarır.", "Dürümü önce sar, sonra ızgaraya at.", "Telefon çalarsa aç — paket sipariş çok daha kârlı.", "Upgrade aldıkça işler otomatikleşir.", "Sos şişesine bas — dürüm daha pahalı satılır.", "İskender: pide al → tahtada doğra → döner → tereyağı → yoğurt.", "Garnitür (domates + biber) iskenderi daha pahalı yapar.", "Tabela ve dükkân büyütme daha çok müşteri getirir.", "Kola, fanta ve ayran ayrı musluklardır — üçünü aynı anda doldurabilirsin.", "Şube açmak için önce dükkânı geliştir; şube geliri günlük performansına bağlıdır.", "Gün başında tepsiler boştur — önce kutudan stok doldur."]
	game.j_BRANCH = [{"name": "İSTANBUL", "p": 5000.0, "inc": 620.0, "req": 9.0, "desc": "Vapur iskelesinin yanı, sabahtan akşama kuyruk."}, {"name": "BERLİN", "p": 12000.0, "inc": 1950.0, "req": 14.0, "desc": "Dönerin ikinci vatanı. Burada iddia büyük."}, {"name": "LONDRA", "p": 27000.0, "inc": 5400.0, "req": 19.0, "desc": "Gece yarısı bile kapanmayan bir köşe."}, {"name": "MANİLA", "p": 48000.0, "inc": 9800.0, "req": 23.0, "desc": "Sokak yemeği başkenti — kuyruk hiç bitmez."}, {"name": "PARİS", "p": 88000.0, "inc": 17500.0, "req": 27.0, "desc": "Küçük bir dükkân, çok titiz bir şehir."}, {"name": "DUBAİ", "p": 220000.0, "inc": 56000.0, "req": 32.0, "desc": "Gökdelenlerin altında, turist akını."}, {"name": "TOKYO", "p": 600000.0, "inc": 180000.0, "req": 38.0, "desc": "Titizliğin ödüllendirildiği tek şehir."}, {"name": "NEW YORK", "p": 1500000.0, "inc": 570000.0, "req": 44.0, "desc": "Zincirin tacı. Uyumayan şehirde döner."}, {"name": "DEMİRKENT", "p": 2500000.0, "inc": 780000.0, "req": 52.0, "ferman": true, "desc": "Yönetim her sabah ferman yayınlar. Kurala uymayan dükkân kapanır."}]
	game.j_FERMAN_CEZA_SINIR = 10.0
	game.j_FERMAN_CEZA_PARA = 310.0
	game.j_FERMANLAR = [{"id": "gozluk", "tip": "musteri", "metin": "Gözlüklüye satış yasak", "test": game.achievement_conditions._closure_163.bind({})}, {"id": "sapka", "tip": "musteri", "metin": "Şapkalıya satış yasak", "test": game.achievement_conditions._closure_164.bind({})}, {"id": "sakal", "tip": "musteri", "metin": "Sakallıya satış yasak", "test": game.achievement_conditions._closure_165.bind({})}, {"id": "cocuk", "tip": "musteri", "metin": "Çocuğa satış yasak", "test": game.achievement_conditions._closure_166.bind({})}, {"id": "kirmizi", "tip": "musteri", "metin": "Kırmızı giyene satış yasak", "test": game.achievement_conditions._closure_167.bind({})}, {"id": "aci", "tip": "urun", "metin": "Acı sos yasak", "test": game.achievement_conditions._closure_168.bind({})}, {"id": "sarimsak", "tip": "urun", "metin": "Sarımsak sosu yasak", "test": game.achievement_conditions._closure_169.bind({})}, {"id": "patates", "tip": "urun", "metin": "Patates satışı yasak", "test": game.achievement_conditions._closure_170.bind({})}, {"id": "icecek", "tip": "urun", "metin": "İçecek satışı yasak", "test": game.achievement_conditions._closure_171.bind({})}, {"id": "tatli", "tip": "urun", "metin": "Tatlı satışı yasak", "test": game.achievement_conditions._closure_172.bind({})}, {"id": "iskender", "tip": "urun", "metin": "İskender satışı yasak", "test": game.achievement_conditions._closure_173.bind({})}, {"id": "tekTip", "tip": "dunya", "metin": "Herkes devletin tulumunu giyecek"}, {"id": "bassiz", "tip": "dunya", "metin": "Baş örtmek yasak"}, {"id": "tras", "tip": "dunya", "metin": "Traş mecburiyeti"}, {"id": "sokak", "tip": "dunya", "metin": "Sokağa çıkma kısıtlaması"}, {"id": "kurye", "tip": "dunya", "metin": "Motorlu kuryelere çıkma yasağı"}, {"id": "telefon", "tip": "dunya", "metin": "Her siparişe cevap verilecek"}, {"id": "karne", "tip": "dunya", "metin": "Herkese tek tip tayın verilecek"}]
	game.j_FERMAN_CAKISMA = {"kurye": ["telefon"], "telefon": ["kurye"], "tekTip": ["kirmizi"], "kirmizi": ["tekTip"], "bassiz": ["sapka"], "sapka": ["bassiz"], "tras": ["sakal"], "sakal": ["tras"]}
	game.j_FERMAN_MANSET = {"gozluk": "CAM, HALKIN GÖZÜNÜ BOZUYOR", "sapka": "BAŞ ÖRTMEK GİZLENMEKTİR", "sakal": "TIRAŞ, İTAATİN İLK ŞARTIDIR", "cocuk": "ÇOCUK MİDESİ DEVLETİN EMANETİ", "kirmizi": "KIRMIZI, HUZURU BOZAN RENKTİR", "aci": "ACI, HALKI ÖFKELENDİRİYOR", "sarimsak": "SARIMSAK KOKUSU YASAKLANDI", "patates": "PATATES STOKLARI DEVLETİNDİR", "icecek": "SU İÇMEK YETERLİDİR", "tatli": "TATLI, TEMBELLİĞE YOL AÇAR", "iskender": "İSKENDER, LÜKS SAYILDI", "tekTip": "TEK TİP, TEK YÜREK", "bassiz": "AÇIK BAŞ, AÇIK VİCDAN", "tras": "SAKAL, ARKASINA SAKLANILAN PERDEDİR", "sokak": "SOKAK, GEREKSİZ KALABALIKTAN ARINDIRILDI", "kurye": "MOTOR GÜRÜLTÜSÜ HALKI RAHATSIZ EDİYOR", "telefon": "HİÇBİR VATANDAŞ CEVAPSIZ BIRAKILAMAZ", "karne": "TAYIN SİSTEMİ BUGÜN UYGULANACAK"}
	game.j_FERMAN_HABER = preload("res://data/ferman_haber.gd").VALUE.duplicate(true)
	game.j_LIDER_SOZ = ["Çalışan halk, düşünmeye vakit bulamayan halktır.", "Sabır, devletin vatandaşa en büyük armağanıdır.", "Şikâyet eden, henüz yeterince çalışmamıştır.", "Bir milletin gücü, sorduğu soruların azlığıyla ölçülür.", "Ekmek bölünür, itaat bölünmez.", "Kapısı açık dükkân, kalbi açık vatandaştır.", "Düzen, herkesin yerini bilmesidir.", "Bugün fedakârlık, yarın yine fedakârlık.", "Az konuşan çok üretir.", "Devlet görür, devlet bilir, devlet unutmaz.", "Kuyruğa girmek, düzene girmektir.", "Boş vakit, düşmanın en sadık dostudur."]
	game.j_GAZETE_HAVA = ["açık", "bulutlu", "sisli", "yağmurlu", "soğuk", "rüzgârlı"]
	game.j_LIDER_ILK_GUN = 4.0
	game.j_LIDER_ODUL = 3100.0
	game.j_LIDER_CEZA = 3.0
	game.j_FP_BASLANGIC = 1480.0
	game.j_FP_BATIK_SINIR = 3.0
	game.j_EVLER = [{"ad": "Bodrum katı", "kira": 295.0, "pesinat": 0.0, "isinma": 1.55, "hasta": 1.75}, {"ad": "Arka sokak odası", "kira": 370.0, "pesinat": 5550.0, "isinma": 1.25, "hasta": 1.35}, {"ad": "İşçi bloğu", "kira": 455.0, "pesinat": 14800.0, "isinma": 1.0, "hasta": 1.0}, {"ad": "Devlet lojmanı", "kira": 545.0, "pesinat": 34600.0, "isinma": 0.76, "hasta": 0.68}, {"ad": "Merkez apartmanı", "kira": 615.0, "pesinat": 74000.0, "isinma": 0.55, "hasta": 0.42}, {"ad": "Parti konutu", "kira": 690.0, "pesinat": 101000.0, "isinma": 0.38, "hasta": 0.22}]
	game.j_FGUN_TAVAN = 45.0
	game.j_HANE_UYE = [{"id": "es", "ad": "Eş"}, {"id": "ogul", "ad": "Oğul"}, {"id": "kiz", "ad": "Kız"}, {"id": "anne", "ad": "Anne"}]
	game.j_GIDER = [{"id": "dukkan", "ad": "Dükkân kirası", "zorunlu": true, "temel": 642.0, "artis": 5.0}, {"id": "ev", "ad": "Ev kirası", "zorunlu": true, "temel": 420.0, "artis": 6.0, "evBagli": true}, {"id": "yemek", "ad": "Yemek", "zorunlu": false, "temel": 105.0, "artis": 0.9, "kisiBasi": true}, {"id": "isinma", "ad": "Isınma", "zorunlu": false, "temel": 216.0, "artis": 2.5}, {"id": "ilac", "ad": "İlaç", "zorunlu": false, "temel": 296.0, "artis": 5.0, "hastaGerek": true}]
	game.j_FP_IYI_GUN = 3450.0
	game.j_BR_MIN = 0.35
	game.j_BR_MAX = 1.15
	# basarim.js
	game.j_BS_BUNDLE = "com.babamindonercisi.game"
	game.j_BASARIM = [{"id": "ilk_durum", "grup": "servis", "ikon": "wrap", "kademe": 1.0, "hedef": 1.0, "ad": "İlk Dürüm", "ac": "İlk dürümünü sat.", "oku": game.achievement_conditions._closure_176.bind({})}, {"id": "durum_100", "grup": "servis", "ikon": "wrap", "kademe": 1.0, "hedef": 100.0, "ad": "Tezgâhın Sahibi", "ac": "100 dürüm sat.", "oku": game.achievement_conditions._closure_177.bind({})}, {"id": "durum_1000", "grup": "servis", "ikon": "wrap", "kademe": 2.0, "hedef": 1000.0, "ad": "Bin Dürüm", "ac": "1000 dürüm sat.", "oku": game.achievement_conditions._closure_178.bind({})}, {"id": "durum_10000", "grup": "servis", "ikon": "wrap", "kademe": 3.0, "hedef": 10000.0, "ad": "Dürüm Efsanesi", "ac": "10.000 dürüm sat.", "oku": game.achievement_conditions._closure_179.bind({})}, {"id": "ilk_iskender", "grup": "servis", "ikon": "iskender", "kademe": 1.0, "hedef": 1.0, "ad": "Tereyağı Kokusu", "ac": "İlk İskender tabağını çıkar.", "oku": game.achievement_conditions._closure_180.bind({})}, {"id": "iskender_500", "grup": "servis", "ikon": "iskender", "kademe": 2.0, "hedef": 500.0, "ad": "İskender Ustası", "ac": "500 İskender tabağı çıkar.", "oku": game.achievement_conditions._closure_181.bind({})}, {"id": "icecek_1000", "grup": "servis", "ikon": "cola", "kademe": 2.0, "hedef": 1000.0, "ad": "Buzlu Servis", "ac": "1000 içecek sat.", "oku": game.achievement_conditions._closure_182.bind({})}, {"id": "patates_500", "grup": "servis", "ikon": "fbox", "kademe": 2.0, "hedef": 500.0, "ad": "Kızartma Kralı", "ac": "500 porsiyon patates sat.", "oku": game.achievement_conditions._closure_183.bind({})}, {"id": "tatli_250", "grup": "servis", "ikon": "sweet", "kademe": 2.0, "hedef": 250.0, "ad": "Tatlı Kaçamağı", "ac": "250 tatlı sat.", "oku": game.achievement_conditions._closure_184.bind({})}, {"id": "gun_40_musteri", "grup": "servis", "ikon": "meat", "kademe": 2.0, "hedef": 40.0, "ad": "Yoğun Gün", "ac": "Tek günde 40 ürün sat.", "oku": game.achievement_conditions._closure_185.bind({})}, {"id": "ilk_bin", "grup": "para", "ikon": "coin", "kademe": 1.0, "hedef": 1000.0, "ad": "İlk Bin", "ac": "Toplam $1.000 kazan.", "oku": game.achievement_conditions._closure_186.bind({})}, {"id": "kazanc_100k", "grup": "para", "ikon": "coin", "kademe": 2.0, "hedef": 100000.0, "ad": "Yüz Bin", "ac": "Toplam $100.000 kazan.", "oku": game.achievement_conditions._closure_187.bind({})}, {"id": "kazanc_1m", "grup": "para", "ikon": "coin", "kademe": 3.0, "hedef": 1000000.0, "ad": "Milyoner", "ac": "Toplam $1.000.000 kazan.", "oku": game.achievement_conditions._closure_188.bind({})}, {"id": "kazanc_10m", "grup": "para", "ikon": "coin", "kademe": 3.0, "hedef": 10000000.0, "ad": "On Milyon", "ac": "Toplam $10.000.000 kazan.", "oku": game.achievement_conditions._closure_189.bind({})}, {"id": "gun_1000", "grup": "para", "ikon": "coin", "kademe": 1.0, "hedef": 1000.0, "ad": "İyi Gün", "ac": "Tek günde $1.000 kazan.", "oku": game.achievement_conditions._closure_190.bind({})}, {"id": "gun_5000", "grup": "para", "ikon": "coin", "kademe": 2.0, "hedef": 5000.0, "ad": "Harika Gün", "ac": "Tek günde $5.000 kazan.", "oku": game.achievement_conditions._closure_191.bind({})}, {"id": "gun_15000", "grup": "para", "ikon": "star", "kademe": 3.0, "hedef": 15000.0, "ad": "Rekor Gün", "ac": "Tek günde $15.000 kazan.", "oku": game.achievement_conditions._closure_192.bind({})}, {"id": "bahsis_5000", "grup": "para", "ikon": "heart", "kademe": 2.0, "hedef": 5000.0, "ad": "Cömert Müşteriler", "ac": "Toplam $5.000 bahşiş topla.", "oku": game.achievement_conditions._closure_193.bind({})}, {"id": "borc_ilk", "grup": "borc", "ikon": "coin", "kademe": 1.0, "hedef": 1.0, "ad": "İlk Taksit", "ac": "Borcundan ilk ödemeyi yap.", "oku": game.achievement_conditions._closure_194.bind({})}, {"id": "borc_100k", "grup": "borc", "ikon": "coin", "kademe": 2.0, "hedef": 100000.0, "ad": "Faiz Eriyor", "ac": "Borcundan $100.000 öde.", "oku": game.achievement_conditions._closure_195.bind({})}, {"id": "borc_yari", "grup": "borc", "ikon": "star", "kademe": 2.0, "hedef": 1.0, "ad": "Yarı Yolda", "ac": "Borcun yarısını kapat.", "oku": game.achievement_conditions._closure_196.bind({})}, {"id": "borc_bitti", "grup": "borc", "ikon": "star", "kademe": 3.0, "hedef": 1.0, "ad": "Babanın Borcu", "ac": "Borcun tamamını kapat.", "oku": game.achievement_conditions._closure_197.bind({})}, {"id": "borc_hizli", "grup": "borc", "ikon": "star", "kademe": 3.0, "hedef": 1.0, "ad": "Erken Kapanış", "ac": "120 günden önce borcu bitir.", "oku": game.achievement_conditions._closure_198.bind({})}, {"id": "ilk_upgrade", "grup": "dukkan", "ikon": "star", "kademe": 1.0, "hedef": 1.0, "ad": "İlk Yatırım", "ac": "İlk geliştirmeni satın al.", "oku": game.achievement_conditions._closure_199.bind({})}, {"id": "upgrade_15", "grup": "dukkan", "ikon": "star", "kademe": 2.0, "hedef": 15.0, "ad": "Yenileme", "ac": "15 geliştirme seviyesi al.", "oku": game.achievement_conditions._closure_200.bind({})}, {"id": "upgrade_hepsi", "grup": "dukkan", "ikon": "star", "kademe": 3.0, "hedef": 1.0, "ad": "Tam Donanım", "ac": "Bütün geliştirmeleri sonuna kadar aç.", "oku": game.achievement_conditions._closure_201.bind({})}, {"id": "sube_1", "grup": "dukkan", "ikon": "pide", "kademe": 1.0, "hedef": 1.0, "ad": "İkinci Şube", "ac": "İlk şubeni aç.", "oku": game.achievement_conditions._closure_202.bind({})}, {"id": "sube_3", "grup": "dukkan", "ikon": "pide", "kademe": 2.0, "hedef": 3.0, "ad": "Zincir", "ac": "3 şube aç.", "oku": game.achievement_conditions._closure_203.bind({})}, {"id": "sube_hepsi", "grup": "dukkan", "ikon": "pide", "kademe": 3.0, "hedef": 1.0, "ad": "İmparatorluk", "ac": "Bütün şubeleri aç.", "oku": game.achievement_conditions._closure_204.bind({})}, {"id": "telefon_25", "grup": "dukkan", "ikon": "fries", "kademe": 1.0, "hedef": 25.0, "ad": "Paket Servis", "ac": "25 telefon siparişi tamamla.", "oku": game.achievement_conditions._closure_205.bind({})}, {"id": "telefon_200", "grup": "dukkan", "ikon": "fries", "kademe": 2.0, "hedef": 200.0, "ad": "Hat Meşgul", "ac": "200 telefon siparişi tamamla.", "oku": game.achievement_conditions._closure_206.bind({})}, {"id": "moto_tamir", "grup": "dukkan", "ikon": "fbox", "kademe": 1.0, "hedef": 1.0, "ad": "Yolda Kalma", "ac": "Dayının motorunu bir kez tamir ettir.", "oku": game.achievement_conditions._closure_207.bind({})}, {"id": "dayi_20", "grup": "dukkan", "ikon": "meat", "kademe": 2.0, "hedef": 20.0, "ad": "Dayının Eli", "ac": "Dayıdan 20 kez yardım iste.", "oku": game.achievement_conditions._closure_208.bind({})}, {"id": "sehir_2", "grup": "sehir", "ikon": "plate", "kademe": 1.0, "hedef": 2.0, "ad": "Yolcu", "ac": "2 farklı şehirde dükkân aç.", "oku": game.achievement_conditions._closure_209.bind({})}, {"id": "sehir_5", "grup": "sehir", "ikon": "plate", "kademe": 2.0, "hedef": 5.0, "ad": "Gezgin", "ac": "5 farklı şehirde dükkân aç.", "oku": game.achievement_conditions._closure_210.bind({})}, {"id": "sehir_hepsi", "grup": "sehir", "ikon": "star", "kademe": 3.0, "hedef": J.getv(game.j_SEHIR, "length"), "ad": "Bütün Ülke", "ac": "Bütün şehirlerde dükkân aç.", "oku": game.achievement_conditions._closure_211.bind({})}, {"id": "gece_30", "grup": "sehir", "ikon": "pickle", "kademe": 2.0, "hedef": 30.0, "ad": "Otuz Gece", "ac": "30 gün oyna.", "oku": game.achievement_conditions._closure_212.bind({})}, {"id": "gun_100", "grup": "sehir", "ikon": "pickle", "kademe": 3.0, "hedef": 100.0, "ad": "Yüz Gün", "ac": "100 gün oyna.", "oku": game.achievement_conditions._closure_213.bind({})}, {"id": "gun_365", "grup": "sehir", "ikon": "star", "kademe": 3.0, "hedef": 365.0, "ad": "Bir Yıl", "ac": "365 gün oyna.", "oku": game.achievement_conditions._closure_214.bind({})}, {"id": "mukemmel_gun", "grup": "usta", "ikon": "heart", "kademe": 1.0, "hedef": 1.0, "ad": "Kusursuz Gün", "ac": "Bir günü tek müşteri kaçırmadan bitir.", "oku": game.achievement_conditions._closure_215.bind({})}, {"id": "mukemmel_10", "grup": "usta", "ikon": "heart", "kademe": 3.0, "hedef": 10.0, "ad": "Kusursuz On", "ac": "10 kusursuz gün çıkar.", "oku": game.achievement_conditions._closure_216.bind({})}, {"id": "seri_10", "grup": "usta", "ikon": "garlic", "kademe": 1.0, "hedef": 10.0, "ad": "Seri", "ac": "Üst üste 10 müşteriyi memnun et.", "oku": game.achievement_conditions._closure_217.bind({})}, {"id": "seri_30", "grup": "usta", "ikon": "garlic", "kademe": 2.0, "hedef": 30.0, "ad": "Uzun Seri", "ac": "Üst üste 30 müşteriyi memnun et.", "oku": game.achievement_conditions._closure_218.bind({})}, {"id": "seri_75", "grup": "usta", "ikon": "star", "kademe": 3.0, "hedef": 75.0, "ad": "Kesintisiz", "ac": "Üst üste 75 müşteriyi memnun et.", "oku": game.achievement_conditions._closure_219.bind({})}, {"id": "temiz_mutfak", "grup": "usta", "ikon": "sauce", "kademe": 2.0, "hedef": 10.0, "ad": "Temiz Mutfak", "ac": "Üst üste 10 gün hijyen cezası alma.", "oku": game.achievement_conditions._closure_220.bind({})}, {"id": "depo_tam", "grup": "usta", "ikon": "pickle", "kademe": 1.0, "hedef": 1.0, "ad": "Depo Dolu", "ac": "Bir günü deposu dolu kapat.", "oku": game.achievement_conditions._closure_221.bind({})}, {"id": "buyuk_siparis", "grup": "usta", "ikon": "plate", "kademe": 2.0, "hedef": 25.0, "ad": "Kalabalık Sofra", "ac": "4 ve üstü ürünlü 25 sipariş tamamla.", "oku": game.achievement_conditions._closure_222.bind({})}, {"id": "demirkent_ilk", "grup": "demirkent", "ikon": "plate", "kademe": 1.0, "hedef": 1.0, "ad": "Sınırın Ötesi", "ac": "Demirkent'e geç.", "oku": game.achievement_conditions._closure_223.bind({})}, {"id": "demirkent_10", "grup": "demirkent", "ikon": "plate", "kademe": 2.0, "hedef": 10.0, "ad": "Direniş", "ac": "Demirkent'te 10 gün dayan.", "oku": game.achievement_conditions._closure_224.bind({})}, {"id": "demirkent_30", "grup": "demirkent", "ikon": "star", "kademe": 3.0, "hedef": 30.0, "ad": "Demirkent Sakini", "ac": "Demirkent'te 30 gün dayan.", "oku": game.achievement_conditions._closure_225.bind({})}, {"id": "ev_2", "grup": "demirkent", "ikon": "pide", "kademe": 1.0, "hedef": 1.0, "ad": "Arka Sokak", "ac": "Bodrumdan çık, daha iyi bir eve taşın.", "oku": game.achievement_conditions._closure_226.bind({})}, {"id": "ev_4", "grup": "demirkent", "ikon": "pide", "kademe": 2.0, "hedef": 3.0, "ad": "Devlet Lojmanı", "ac": "Devlet lojmanına taşın.", "oku": game.achievement_conditions._closure_227.bind({})}, {"id": "ev_son", "grup": "demirkent", "ikon": "star", "kademe": 3.0, "hedef": (J.getv(game.j_EVLER, "length") - 1.0), "ad": "Parti Konutu", "ac": "En üst basamağa, parti konutuna çık.", "oku": game.achievement_conditions._closure_228.bind({})}, {"id": "lider_siparis", "grup": "demirkent", "ikon": "iskender", "kademe": 2.0, "hedef": 1.0, "ad": "Liderin Siparişi", "ac": "Ülkenin liderine doğru siparişi ver.", "oku": game.achievement_conditions._closure_229.bind({})}, {"id": "lider_3", "grup": "demirkent", "ikon": "star", "kademe": 3.0, "hedef": 3.0, "ad": "Sadık Esnaf", "ac": "Lidere 3 kez doğru siparişi ver.", "oku": game.achievement_conditions._closure_230.bind({})}, {"id": "sicil_temiz", "grup": "demirkent", "ikon": "sauce", "kademe": 2.0, "hedef": 1.0, "ad": "Sicili Temiz", "ac": "Demirkent'te bir günü hiç ihlalsiz kapat.", "oku": game.achievement_conditions._closure_231.bind({})}, {"id": "kacakci", "grup": "demirkent", "ikon": "hot", "kademe": 2.0, "hedef": 10.0, "ad": "Kaçakçı", "ac": "Yasaklı ürünü 10 kez yakalanmadan ver.", "oku": game.achievement_conditions._closure_232.bind({})}, {"id": "muhur", "grup": "gizli", "ikon": "hot", "kademe": 1.0, "hedef": 1.0, "gizli": true, "ad": "Mühürlü Dükkân", "ac": "Müfettiş dükkânı bir kez kapatsın.", "oku": game.achievement_conditions._closure_233.bind({})}, {"id": "yanik", "grup": "gizli", "ikon": "meat", "kademe": 1.0, "hedef": 10.0, "gizli": true, "ad": "Ateşle Oynama", "ac": "Izgarada 10 dürüm yak.", "oku": game.achievement_conditions._closure_234.bind({})}, {"id": "hirsiz", "grup": "gizli", "ikon": "coin", "kademe": 1.0, "hedef": 1.0, "gizli": true, "ad": "Kepenk Kırıldı", "ac": "Gece bir kez soyul.", "oku": game.achievement_conditions._closure_235.bind({})}, {"id": "sifir_kasa", "grup": "gizli", "ikon": "coin", "kademe": 1.0, "hedef": 1.0, "gizli": true, "ad": "Sıfır Kasa", "ac": "Bir günü cebinde hiç para kalmadan kapat.", "oku": game.achievement_conditions._closure_236.bind({})}, {"id": "sabirsiz", "grup": "gizli", "ikon": "fries", "kademe": 1.0, "hedef": 50.0, "gizli": true, "ad": "Bekleyemem", "ac": "50 müşteri kaçır.", "oku": game.achievement_conditions._closure_237.bind({})}, {"id": "buyuk_bahsis", "grup": "gizli", "ikon": "heart", "kademe": 2.0, "hedef": 25.0, "gizli": true, "ad": "Cebi Geniş", "ac": "Tek seferde $25 bahşiş al.", "oku": game.achievement_conditions._closure_238.bind({})}, {"id": "evsiz", "grup": "gizli", "ikon": "heart", "kademe": 2.0, "hedef": 10.0, "gizli": true, "ad": "Karnını Doyur", "ac": "10 kez parası olmayanı doyur.", "oku": game.achievement_conditions._closure_239.bind({})}]
	game.j_BSQ = {"kuyruk": [], "t": 0.0, "sesli": true}
	# game.js
	game.j_G = {"scene": "title", "t": 0.0, "sceneT": 0.0, "day": 1.0, "money": 0.0, "up": {}, "best": 0.0, "totalSold": 0.0, "debt": game.j_DEBT_START, "act": 0.0, "branch": 0.0, "city": (-J.n(1.0)), "timeLeft": 0.0, "cfg": null, "spit": null, "shave": null, "meat": 0.0, "stock": {"pickle": 16.0, "yogurt": 16.0, "ayran": 0.0, "sweet": 0.0, "tomato": 0.0, "pepper": 0.0}, "cut": null, "fryer": null, "friesTray": 0.0, "boards": [], "sel": 0.0, "paper": null, "grill": null, "drinkM": null, "cups": null, "fbox": null, "hand": null, "coins": [], "customers": [], "spawnT": 0.0, "stat": null, "chef": {"mode": "idle", "armT": 0.0}, "uncle": {"left": 0.0, "flashT": 0.0}, "crate": {"open": false, "t": 0.0, "popT": 0.0}, "phone": null, "courier": null, "sauceFx": null, "shutT": 0.0, "shutSnd": 0.0, "flyCoins": [], "celeb": null, "night": null, "moto": {"broken": false, "cost": 0.0}, "prologueSeen": false, "luck": 0.0, "luckMsg": 0.0, "luckAmt": 0.0, "weather": "sun", "rainT": 0.0, "trash": 0.0, "emptyT": 0.0, "inspect": null, "custom": {"sign": "USTA DÖNER", "sub": "EFSANE LEZZET", "poster": 1.0, "counter": 0.0}, "stats": {"wraps": 0.0, "drinks": 0.0, "boxes": 0.0, "sweets": 0.0, "isk": 0.0, "earned": 0.0, "best": 0.0, "days": 0.0, "debtPaid": 0.0, "phone": 0.0, "lost": 0.0, "fines": 0.0}, "flyIng": [], "flyMeat": [], "fxTray": null, "stockAnim": null, "hudPop": 0.0, "hint": "", "hintT": 0.0, "tut": 99.0, "autoT": 0.0, "test": false, "bs": null, "bsT": 0.0}
	game.j_GOZ_BAK_SURE = [2.6, 4.4]
	game.j_GOZ_ARA = [5.0, 11.0]
	game.j_GOZ_SORGU_SANS = 0.55
	game.j_GOZ_KAPI = 92.0
	game.j_SAUCE_IDX = {"hot": 0.0, "garlic": 1.0, "butter": 2.0}
	game.j__bgCheck = 0.0
	game.j_STNAME = {"spit": "Döner — yukarı/aşağı sürt", "meat": "Et Tepsisi", "pickle": "Turşu", "yogurt": "Yoğurt", "friesT": "Patates", "drinkM": "İçecek", "fryer": "Fritöz", "potato": "Patates Çuvalı", "crate": "Depo Kutusu", "bread": "Lavaş", "board": "Hazırlık Tezgâhı", "paper": "Kağıt", "ayran": "Ayran Kazanı", "sweet": "Tatlı Tepsisi", "grill": "Izgara", "cut": "Doğrama Tahtası", "fbox": "Patates Porsiyon", "trash": "Çöp", "uncle": "Dayı", "sauce": "Sos Standı — acı / sarımsak / tereyağı", "garnish": "Garnitür — domates / biber"}
	game.j_TUT = [{"s": ("Parmağını dönerin üstünde yukarı-aşağı sürt" if J.truth(game.j_TOUCH) else "Fareyi dönerin üstünde yukarı-aşağı gezdir"), "st": "spit", "ok": game.session_system._closure_251.bind({})}, {"s": "Lavaş al", "st": "bread", "ok": game.session_system._closure_252.bind({})}, {"s": "Et tepsisine tıkla — 4 porsiyon gerek", "st": "meat", "ok": game.session_system._closure_253.bind({})}, {"s": "Kutuyu aç, turşu ve yoğurt doldur", "st": "crate", "ok": game.session_system._closure_254.bind({})}, {"s": J.add(J.add("Turşu koy — ", game.j_PICKLE_NEED), " porsiyon"), "st": "pickle", "ok": game.session_system._closure_255.bind({})}, {"s": J.add(J.add("Yoğurt koy — ", game.j_YOGURT_NEED), " porsiyon"), "st": "yogurt", "ok": game.session_system._closure_256.bind({})}, {"s": "Çuvaldan patates al", "st": "potato", "ok": game.session_system._closure_257.bind({})}, {"s": "Tahtaya tıklayarak doğra", "st": "cut", "ok": game.session_system._closure_258.bind({})}, {"s": "Fritöze at, kızarınca çıkar", "st": "fryer", "ok": game.session_system._closure_259.bind({})}, {"s": J.add(J.add("Patatesi dürüme koy — ", game.j_FRIES_NEED), " porsiyon"), "st": "friesT", "ok": game.session_system._closure_260.bind({})}, {"s": "Dürümü tutup YUKARI sürükleyerek sar", "st": "board", "ok": game.session_system._closure_261.bind({})}, {"s": "Kağıdı tut, dürümün üstüne bırak", "st": "paper", "ok": game.session_system._closure_262.bind({})}, {"s": "Dürümü al, müşteriye ver", "st": null, "ok": game.session_system._closure_263.bind({})}, {"s": "Paraları topla", "st": null, "para": true, "ok": game.session_system._closure_264.bind({})}]
	game.j_TUTFX = {"x": 0.0, "y": 0.0, "w": 0.0, "h": 0.0, "ilk": true, "karart": 0.0}
	# prologue.js
	game.j_PRO = {"i": 0.0, "t": 0.0, "ch": 0.0, "done": false}
	game.j_PRO_SCENES = [{"dur": 13.0, "lines": ["Babam bu tezgâhta kırk yıl döner kesti.", "Ocağı sabah beşte yakar,", "kepengi gece yarısı indirirdi."], "draw": game.story_draw._closure_266.bind({})}, {"dur": 12.0, "lines": ["\"Bu kapıdan kimse aç çıkmaz,\" derdi.", "Cebinde parası olsun, olmasın."], "draw": game.story_draw._closure_267.bind({})}, {"dur": 11.0, "lines": ["Geçen kış onu kaybettik.", "Kepenk üç ay açılmadı."], "draw": game.story_draw._closure_268.bind({})}, {"dur": 14.0, "lines": ["Sonra icradan bir yazı geldi.", "Yıllarca kimseyi aç göndermemenin bedeli:", "$5.000.000"], "draw": game.story_draw._closure_269.bind({})}, {"dur": 13.0, "lines": ["Satmamı söylediler. Satmadım.", "Ocağı yaktım, kepengi kaldırdım.", "Bu kapıdan yine kimse aç çıkmayacak."], "draw": game.story_draw._closure_270.bind({})}]
	game.j_PRO_KAT = {}
	game.j_PRO_SIS_PROFIL = [0.5, 0.74, 0.9, 0.99, 1.0, 0.97, 0.91, 0.83, 0.73, 0.61, 0.47, 0.31, 0.16]
	# logo-veri.js
	game.j_LOGO_VERI = {"w": 275.0, "h": 88.0, "cx": 138.0, "arka": {"src": "res://assets/images/asset_07.png", "x": 88.0, "y": 0.0, "kw": 100.0, "kh": 77.0, "yak": 5.0, "tit": 12.0, "titFps": 6.0, "yakBas": 0.3, "yakAdim": 0.09}, "sis": {"src": "res://assets/images/asset_08.png", "x": 118.0, "y": 0.0, "kw": 40.0, "kh": 87.0, "n": 64.0, "sut": 8.0, "turSn": 5.464, "tepe": [138.0, 0.0]}, "isitici": [88.0, 0.0, 188.0, 77.0], "on": {"tr": {"src": "res://assets/images/asset_09.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_10.png", "metin": ["BABAMIN", "DÖNERCİSİ"]}, "en": {"src": "res://assets/images/asset_11.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_12.png", "metin": ["MY FATHER'S", "KEBAB SHOP"]}, "de": {"src": "res://assets/images/asset_13.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_14.png", "metin": ["MEINES VATERS", "DÖNERLADEN"]}, "es": {"src": "res://assets/images/asset_15.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_16.png", "metin": ["EL LOCAL", "DE MI PADRE"]}, "fr": {"src": "res://assets/images/asset_17.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_18.png", "metin": ["LA BOUTIQUE", "DE MON PÈRE"]}, "pt": {"src": "res://assets/images/asset_19.png", "x": 0.0, "y": 36.0, "w": 275.0, "h": 52.0, "maske": "res://assets/images/asset_20.png", "metin": ["A LOJA", "DO MEU PAI"]}}}
	# logo.js
	game.j_LOGO = {"im": {}, "istek": 0.0, "tamam": 0.0, "giris": (-J.n(99.0)), "son": (-J.n(99.0)), "dil": null, "dilT": (-J.n(99.0)), "pc": null}
	game.j_LOGO_DUSUS = 0.5
	game.j_LOGO_PARILTI = 0.7
	game.j_LOGO_PARILTI_ARA = 6.0
	game.f_logoYukle()
	# ui.js
	game.j_titleSpit = {"rot": 0.0, "roast": 0.85, "mass": 1.0, "sliceT": 0.0, "cutDepth": 0.0}
	game.j_DILUI = {"anim": (-J.n(1.0)), "hedef": 0.0, "hiz": 0.0, "parla": 0.0, "son": (-J.n(1.0))}
	game.j_EVP = {"open": false}
	game.j_SHOP = {"bake": null, "sel": null, "buyT": 0.0, "sec": null}
	game.j_KART_ZEMIN = "#2b2119"
	game.j_KART_YAZI = "#c9b48c"
	game.j_KART_TAM = "#8fb88f"
	game.j_KART_KILIT = "#d9977a"
	game.j_KART_PAHALI = "#e0a0a0"
	game.j_DERS_ADIM = [{"hedef": null, "bas": "BURASI DÜKKÂN", "sat": ["Gün bitince buraya gelirsin.", "Kazandığın parayla dükkânı büyütürsün."]}, {"hedef": "tongs", "bas": "GELİŞTİRME ETİKETLERİ", "sat": ["Her etiket bir istasyona ok atar.", "Üstündeki fiyat, altındaki noktalar seviyedir."]}, {"hedef": "store", "bas": "İLK GELİŞTİRME BİZDEN", "sat": ["DEPO: turşu ve yoğurt stokun büyür.", "Hediyemiz olsun — hadi devam."]}]
	game.j_ROZET_OFSET = {"ayran": [(-J.n(24.0)), 4.0]}
	game.j_TESTP = {"x": 8.0, "y": 8.0, "w": 464.0, "h": 256.0, "page": 0.0}
	game.j_CUSTOM = {"open": false, "edit": false}
	game.j_STATS = {"open": false}
	game.j_SESP = {"open": false, "tutulan": null}
	game.j_PAYP = {"open": false, "amt": 0.0}
	game.j_BRP = {"open": false, "t": 0.0}
	game.j_BSP = {"open": false, "sec": null, "kay": 0.0}
	game.j_BS_GRUP = [["servis", "SERVİS"], ["para", "PARA"], ["borc", "BORÇ"], ["dukkan", "DÜKKÂN"], ["sehir", "ŞEHİR"], ["usta", "USTALIK"], ["demirkent", "DEMİRKENT"], ["gizli", "GİZLİ"]]
	game.j_BS_KADEME = ["#b0763a", "#b8c0c8", "#e8c05a"]
	# main.js
	J.invoke(game.game_setup._closure_272.bind({}), [])
	game.j__last = game.clock_ms
	game.j__acc = 0.0
	game.j__fps = 0.0
	game.j__fpsT = 0.0
	game.j__frames = 0.0

func _closure_1(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_ch: Variant = null
	var v_rows: Variant = null
	var v_wch: Variant = null
	var v_minx: Variant = null
	var v_maxx: Variant = null
	var v_y: Variant = null
	var v_x: Variant = null
	for _key_2 in J.keys(game.j_GLYPHS):
		v_ch = _key_2
		v_rows = J.method(J.getv(game.j_GLYPHS, v_ch), "split", ["/"])
		v_wch = J.getv(J.getv(v_rows, 0.0), "length")
		v_minx = 99.0
		v_maxx = (-J.n(1.0))
		v_y = 0.0
		while J.lt(v_y, J.getv(v_rows, "length")):
			v_x = 0.0
			while J.lt(v_x, v_wch):
				if J.eq(J.getv(J.getv(v_rows, v_y), v_x), "#"):
					if J.lt(v_x, v_minx):
						v_minx = v_x
					if J.gt(v_x, v_maxx):
						v_maxx = v_x
				v_x = J.add(v_x, 1.0)
			v_y = J.add(v_y, 1.0)
		if J.lt(v_maxx, 0.0):
			v_minx = 0.0
			v_maxx = 1.0
		J.setv(game.j_FONT, v_ch, {"rows": v_rows, "x0": v_minx, "w": J.add((v_maxx - v_minx), 1.0)})
	J.setv(J.getv(game.j_FONT, " "), "w", 2.0)
	return null

func _closure_74(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_n: Variant = null
	var v_a: Variant = null
	var v_i: Variant = null
	v_n = 1024.0
	v_a = J.array(J.add(v_n, 1.0))
	v_i = 0.0
	while J.le(v_i, v_n):
		J.setv(v_a, v_i, asin((((float(v_i) / float(v_n)) * 2.0) - 1.0)))
		v_i = J.add(v_i, 1.0)
	return v_a
	return null

func _closure_272(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_s: Variant = null
	if J.eq(J.kind(J.ref(game.f_sprYukle, 0)), "function"):
		game.f_sprYukle()
	if J.eq(J.kind(J.ref(game.localization.f_loadLang, 0)), "function"):
		game.localization.f_loadLang()
	if J.eq(J.kind(J.ref(game.save_system.f_volYukle, 0)), "function"):
		game.save_system.f_volYukle()
	v_s = game.f_loadGame()
	if J.truth(v_s):
		J.setv(game.j_G, "best", (J.getv(v_s, "best") if J.truth(J.getv(v_s, "best")) else 1.0))
		if J.truth(J.getv(v_s, "moto")):
			J.setv(game.j_G, "moto", J.getv(v_s, "moto"))
		J.setv(game.j_G, "prologueSeen", (not (not J.truth(J.getv(v_s, "prologueSeen")))))
		J.setv(game.j_G, "luck", (J.getv(v_s, "luck") if J.truth(J.getv(v_s, "luck")) else 0.0))
	return null
