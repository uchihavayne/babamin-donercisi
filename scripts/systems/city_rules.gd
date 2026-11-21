# Sehir kurallari (birlesik surum, 12. tur): oynanan sehrin kurali + ziyaret primi. Veri: data/sehir_kural.gd (game.j_SEHIR_KURAL).
# Kural, ayar katmanindaki (j_TUN: equipment_tuning.gd) carpanlara ve birkac noktaya baglanir; Babanin Dukkani (-1) ve Demirkent
# (ferman) kuralsizdir. Ziyaret primi: oyuncu acik bir sube sehrinde calisirken o subenin geliri ZIYARET_PRIM kadar artar
# (session_system.f_endDay, progression_system.f_branchBase ile birlikte; gider de buna gore artar).
extends "res://scripts/core/game_module.gd"

const ZIYARET_PRIM := 0.5   # calisilan subenin gelirine eklenen oran

func _g(g: Variant) -> Variant:
	return game.j_G if g == null else g

# oynanan sehrin dizini (kural / prim yoksa -1)
func f_sehir(g: Variant = null) -> int:
	var G: Variant = _g(g)
	if not (G is Dictionary): return -1
	var c: Variant = G.get("city")
	if not (c is float or c is int): return -1
	var i := int(c)
	var L: Variant = game.j_SEHIR_KURAL
	if not (L is Array) or i < 0 or i >= L.size(): return -1
	return i

# o sehrin kurali (kuralsizsa bos sozluk)
func f_kural(g: Variant = null) -> Dictionary:
	var i := f_sehir(g)
	if i < 0: return {}
	var r: Variant = game.j_SEHIR_KURAL[i]
	return r if r is Dictionary else {}

func f_kuralIndeks(i: int) -> Dictionary:
	var L: Variant = game.j_SEHIR_KURAL
	if not (L is Array) or i < 0 or i >= L.size(): return {}
	var r: Variant = L[i]
	return r if r is Dictionary else {}

# carpan alani (gelis, sabir, bahsis, fiyat, sure, ceza, iddia); alan yoksa 1
func f_carpan(alan: String, g: Variant = null) -> float:
	return float(f_kural(g).get(alan, 1.0))

# siradaki musteri yeri farki (Paris -1)
func f_yer(g: Variant = null) -> float:
	return float(f_kural(g).get("yer", 0.0))

# Tokyo: kusursuz teslim / kusurlu teslim fiyat carpani (kuralsizsa 1)
func f_teslimCarpani(kusursuz: bool, g: Variant = null) -> float:
	var r: Dictionary = f_kural(g)
	return float(r.get("kusursuz", 1.0)) if kusursuz else float(r.get("kusurlu", 1.0))

# ziyaret primi tabani: calisilan acik sube sehrinin taban geliri x ZIYARET_PRIM (Babanin Dukkani / Demirkent: 0)
func f_ziyaretTaban(g: Variant = null) -> float:
	var G: Variant = _g(g)
	var i := f_sehir(G)
	if i < 0 or J.truth(game.progression_system.f_fermanSehri(G)): return 0.0
	var acik: float = J.n(G.get("branch")) if G is Dictionary else 0.0
	if float(i) >= acik or i >= game.j_BRANCH.size(): return 0.0
	return J.n(game.j_BRANCH[i].inc) * ZIYARET_PRIM
