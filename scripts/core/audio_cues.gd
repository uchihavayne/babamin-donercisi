# Audio cues. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func _closure_3(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.09, 0.3, 2600.0, 700.0, 1.6)
	game.f_beep(340.0, 0.05, "triangle", 0.06, 180.0)
	return null

func _closure_4(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.16, 0.22, 4200.0, 900.0, 2.2)
	return null

func _closure_5(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(880.0, 0.05, "square", 0.1, 1200.0)
	return null

func _closure_6(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(320.0, 0.07, "square", 0.09, 200.0)
	return null

func _closure_7(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(392.0, 0.1, "triangle", 0.13, 349.0)
	game.f_beep(294.0, 0.16, "triangle", 0.11, 262.0, 0.07)
	game.f_noise(0.07, 0.035, 900.0, 400.0, 1.2)
	return null

func _closure_8(_args: Array, _captures: Dictionary = {}) -> Variant:
	if (J.eq(J.kind(J.ref(game.f_sndPlay, 2)), "function") and J.truth(game.f_sndPlay("coin"))):
		return null
	game.f_beep(1180.0, 0.06, "square", 0.12)
	game.f_beep(1560.0, 0.1, "square", 0.11, null, 0.06)
	return null

func _closure_9(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(900.0, 0.07, "square", 0.12)
	game.f_beep(1200.0, 0.07, "square", 0.12, null, 0.07)
	game.f_beep(1600.0, 0.14, "square", 0.12, null, 0.14)
	return null

func _closure_10(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(1320.0, 0.5, "sine", 0.13)
	game.f_beep(1980.0, 0.4, "sine", 0.05, null, 0.01)
	return null

func _closure_11(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(660.0, 0.07, "triangle", 0.12)
	game.f_beep(990.0, 0.12, "triangle", 0.1, null, 0.06)
	return null

func _closure_12(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.35, 0.14, 500.0, 1500.0, 0.8)
	return null

func _closure_13(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.5, 0.1, 1800.0, 3200.0, 0.5)
	return null

func _closure_14(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.7, 0.13, 2400.0, 1200.0, 0.4)
	return null

func _closure_15(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(720.0, 0.04, "square", 0.09)
	return null

func _closure_16(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(420.0, 0.06, "square", 0.08, 300.0)
	return null

func _closure_18(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_f: Variant = null
	var v_i: Variant = null
	v_f = J.arg(_args, 0)
	v_i = J.arg(_args, 1)
	game.f_beep(v_f, 0.16, "square", 0.12, null, (v_i * 0.085))
	return null

func _closure_17(_args: Array, _captures: Dictionary = {}) -> Variant:
	J.method([523.0, 659.0, 784.0, 1046.0], "forEach", [game.audio_cues._closure_18.bind({})])
	return null

func _closure_20(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_f: Variant = null
	var v_i: Variant = null
	v_f = J.arg(_args, 0)
	v_i = J.arg(_args, 1)
	game.f_beep(v_f, 0.18, "square", 0.11, null, (v_i * 0.1))
	return null

func _closure_19(_args: Array, _captures: Dictionary = {}) -> Variant:
	J.method([400.0, 330.0, 260.0, 200.0], "forEach", [game.audio_cues._closure_20.bind({})])
	return null

func _closure_21(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(500.0, 0.05, "sine", 0.1, 900.0)
	return null

func _closure_22(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(180.0, 0.12, "sawtooth", 0.1, 120.0)
	return null

func _closure_23(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(1568.0, 0.35, "sine", 0.12)
	game.f_beep(2093.0, 0.3, "sine", 0.06, null, 0.04)
	return null

func _closure_24(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.07, 0.18, 5200.0, 2000.0, 3.0)
	return null

func _closure_25(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(2.2, 0.05, 900.0, 1400.0, 0.3)
	return null

func _closure_26(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.08, 0.22, 500.0, 200.0, 2.0)
	game.f_beep(180.0, 0.1, "square", 0.1, 90.0)
	return null

func _closure_28(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_f: Variant = null
	var v_i: Variant = null
	v_f = J.arg(_args, 0)
	v_i = J.arg(_args, 1)
	game.f_beep(v_f, 0.22, "sawtooth", 0.11, null, (v_i * 0.12))
	return null

func _closure_27(_args: Array, _captures: Dictionary = {}) -> Variant:
	J.method([330.0, 262.0, 208.0, 165.0], "forEach", [game.audio_cues._closure_28.bind({})])
	return null

func _closure_29(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_t0: Variant = null
	var v_i: Variant = null
	var v_o: Variant = null
	var v_g: Variant = null
	if (((not J.truth(game.j_AC)) or (not J.truth(game.j_MASTER))) or J.truth(game.j_MUTED)):
		return null
	v_t0 = J.getv(game.j_AC, "currentTime")
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_o = J.method(game.j_AC, "createOscillator", [])
		v_g = J.method(game.j_AC, "createGain", [])
		J.setv(v_o, "type", "sawtooth")
		J.method(J.getv(v_o, "frequency"), "setValueAtTime", [J.add(70.0, (v_i * 8.0)), J.add(v_t0, (v_i * 0.18))])
		J.method(J.getv(v_o, "frequency"), "linearRampToValueAtTime", [J.add(150.0, (v_i * 20.0)), J.add(J.add(v_t0, (v_i * 0.18)), 0.16)])
		J.method(J.getv(v_o, "frequency"), "linearRampToValueAtTime", [J.add(85.0, (v_i * 10.0)), J.add(J.add(v_t0, (v_i * 0.18)), 0.22)])
		J.method(J.getv(v_g, "gain"), "setValueAtTime", [0.0, J.add(v_t0, (v_i * 0.18))])
		J.method(J.getv(v_g, "gain"), "linearRampToValueAtTime", [0.1, J.add(J.add(v_t0, (v_i * 0.18)), 0.03)])
		J.method(J.getv(v_g, "gain"), "exponentialRampToValueAtTime", [0.001, J.add(J.add(v_t0, (v_i * 0.18)), 0.26)])
		J.method(v_o, "connect", [v_g])
		J.method(v_g, "connect", [game.j_SFXBUS])
		J.method(v_o, "start", [J.add(v_t0, (v_i * 0.18))])
		J.method(v_o, "stop", [J.add(J.add(v_t0, (v_i * 0.18)), 0.3)])
		v_i = J.add(v_i, 1.0)
	game.f_noise(0.5, 0.06, 300.0, 900.0, 0.6)
	return null

func _closure_30(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(1180.0, 0.09, "square", 0.1)
	game.f_beep(1480.0, 0.09, "square", 0.1, null, 0.11)
	game.f_beep(1180.0, 0.09, "square", 0.1, null, 0.22)
	game.f_beep(1480.0, 0.12, "square", 0.1, null, 0.33)
	return null

func _closure_31(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(1760.0, 0.16, "sine", 0.11)
	game.f_beep(2349.0, 0.22, "sine", 0.09, null, 0.07)
	game.f_beep(1568.0, 0.3, "sine", 0.05, null, 0.14)
	return null

func _closure_32(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.1, 0.16, 3800.0, 2200.0, 1.2)
	game.f_noise(0.13, 0.11, 5200.0, 3000.0, 1.6)
	game.f_beep(760.0, 0.04, "triangle", 0.04, 520.0, 0.05)
	return null

func _closure_33(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.13, 0.13, 900.0, 320.0, 3.4)
	game.f_beep(520.0, 0.07, "sine", 0.07, 240.0)
	return null

func _closure_34(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(2093.0, 0.18, "sine", 0.1)
	game.f_beep(2794.0, 0.12, "sine", 0.05, null, 0.02)
	game.f_noise(0.05, 0.05, 5000.0, 4000.0, 3.0)
	return null

func _closure_35(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.45, 0.07, 1400.0, 4200.0, 0.6)
	return null

func _closure_36(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(430.0, 0.16, "sawtooth", 0.045)
	game.f_beep(516.0, 0.16, "sawtooth", 0.04, null, 0.01)
	game.f_beep(430.0, 0.12, "sawtooth", 0.035, null, 0.2)
	return null

func _closure_37(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_near: Variant = null
	v_near = J.arg(_args, 0)
	game.f_swell((0.9 if J.truth(v_near) else 1.3), (0.055 if J.truth(v_near) else 0.03), 180.0, (760.0 if J.truth(v_near) else 460.0), 0.7)
	return null

func _closure_38(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.05, 0.05, 300.0, 160.0, 1.4)
	return null

func _closure_39(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(2400.0, 0.1, "sine", 0.06)
	game.f_beep(3200.0, 0.07, "sine", 0.03, null, 0.02)
	return null

func _closure_40(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(1.15, 0.1, 260.0, 900.0, 1.1)
	game.f_beep(120.0, 0.12, "square", 0.05, 80.0, 0.05)
	return null

func _closure_42(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_f: Variant = null
	var v_i: Variant = null
	v_f = J.arg(_args, 0)
	v_i = J.arg(_args, 1)
	game.f_beep(v_f, 0.22, "square", 0.13, null, (v_i * 0.11))
	return null

func _closure_43(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_f: Variant = null
	var v_i: Variant = null
	v_f = J.arg(_args, 0)
	v_i = J.arg(_args, 1)
	game.f_beep(v_f, 0.3, "triangle", 0.09, null, J.add((v_i * 0.11), 0.04))
	return null

func _closure_41(_args: Array, _captures: Dictionary = {}) -> Variant:
	J.method([523.0, 659.0, 784.0, 1046.0, 1318.0], "forEach", [game.audio_cues._closure_42.bind({})])
	J.method([262.0, 330.0, 392.0, 523.0], "forEach", [game.audio_cues._closure_43.bind({})])
	game.f_beep(1568.0, 0.8, "sine", 0.1, null, 0.58)
	return null

func _closure_44(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.14, 0.26, 220.0, 90.0, 1.8)
	game.f_beep(90.0, 0.16, "square", 0.09, 60.0, 0.02)
	return null

func _closure_45(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.055, 0.34, 1900.0, 520.0, 2.2)
	game.f_beep(260.0, 0.04, "triangle", 0.07, 150.0)
	game.f_noise(0.09, 0.1, 4200.0, 2600.0, 1.4)
	return null

func _closure_46(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.16, 0.12, 700.0, 300.0, 1.1)
	game.f_beep(180.0, 0.08, "square", 0.05, 110.0)
	return null

func _closure_47(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.12, 0.16, 1100.0, 480.0, 1.6)
	game.f_beep(300.0, 0.05, "square", 0.06, 200.0)
	return null

func _closure_48(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.1, 0.13, 2400.0, 900.0, 1.8)
	game.f_beep(520.0, 0.05, "triangle", 0.06, 380.0)
	return null

func _closure_49(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.07, 0.2, 380.0, 170.0, 1.1)
	game.f_noise(0.2, 0.12, 2400.0, 1200.0, 1.0)
	game.f_beep(300.0, 0.06, "triangle", 0.08, 210.0, 0.01)
	return null

func _closure_50(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_noise(0.22, 0.13, 1800.0, 700.0, 1.4)
	game.f_beep(240.0, 0.1, "triangle", 0.09, 420.0)
	game.f_beep(520.0, 0.07, "sine", 0.05, 700.0, 0.09)
	return null

func _closure_51(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_kapan: Variant = null
	v_kapan = J.arg(_args, 0)
	game.f_noise(0.26, 0.1, 900.0, 380.0, 1.0)
	game.f_beep((180.0 if J.truth(v_kapan) else 260.0), 0.08, "triangle", 0.07, (130.0 if J.truth(v_kapan) else 200.0), 0.18)
	return null

func _closure_52(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(1000.0, 0.03, "square", 0.05)
	return null

func _closure_53(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.f_beep(760.0, 0.09, "square", 0.09)
	game.f_beep(560.0, 0.12, "square", 0.08, null, 0.1)
	return null
