"""SES EFEKTLERI — fiziksel modelle sentez (birlesik surum, 6. tur analiz madde 18).

    python tools/sfx_uret.py            -> assets/audio/sfx/<ad>_<n>.wav + tanitim.wav

Eskiden oyunun ~45 efekti o an kare/testere dalgasiyla uretilen bip ve
gurultulerdi. Burada her biri gercek sesin fizigine yakin kurulur:
  carpma (bicak-tahta, tabak, bardak, para, zil): sonumlu kipler (modal) —
      her malzemenin kendi frekans oranlari ve sonum sureleri
  surtunme (kazima, cekmece, kagit): bant gecirgen gurultu + genlik titresimi
  kizartma / cizirti: rastgele zamanli citirti taneleri + tislama
  sivi (dokme, sos): yukselen perdeli kabarcik taneleri + akis gurultusu
Her sesin 3 cesidi var (tohum farkli) -> oyunda tekrar kulak tirmalamaz.
Kucuk bir oda yankisi (kisa, dusuk karisim) sesleri ayni mekana oturtur.
Oyun karsiligi: native_platform.gd ORNEK_SFX (j_SFX adlari).
"""
import os, wave, zlib
import numpy as np
from scipy import signal

SR = 44100
KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(KOK, "assets", "audio", "sfx")
rng = np.random.default_rng(1)


# ---------------------------------------------------------------- temel
def zaman(d):
    return np.arange(int(d * SR)) / SR


def bos(d):
    return np.zeros(int(d * SR))


def gurultu(d):
    return rng.standard_normal(int(d * SR))


def bp(x, lo, hi, o=2):
    return signal.sosfilt(signal.butter(o, [lo, min(hi, SR / 2 - 100)], btype="band", fs=SR, output="sos"), x)


def lp(x, f, o=2):
    return signal.sosfilt(signal.butter(o, f, btype="low", fs=SR, output="sos"), x)


def hp(x, f, o=2):
    return signal.sosfilt(signal.butter(o, f, btype="high", fs=SR, output="sos"), x)


def zarf(d, atak=0.002, tau=0.05):
    t = zaman(d)
    e = np.exp(-t / tau)
    a = int(atak * SR)
    if a > 0:
        e[:a] *= np.linspace(0, 1, a)
    return e


def kipler(parcalar, d, sapma=0.02):
    """Sonumlu kipler: [(frekans, sonum, genlik)] — carpan cisimlerin tinisi."""
    t = zaman(d)
    x = np.zeros_like(t)
    for f, tau, a in parcalar:
        f *= 1.0 + rng.uniform(-sapma, sapma)
        x += a * np.sin(2 * np.pi * f * t + rng.uniform(0, 6.28)) * np.exp(-t / tau)
    a = int(0.0008 * SR)
    x[:a] *= np.linspace(0, 1, a)
    return x


def ekle(hedef, x, bas):
    i = int(bas * SR)
    n = min(len(x), len(hedef) - i)
    if n > 0:
        hedef[i:i + n] += x[:n]
    return hedef


def tik(d=0.004, lo=2000, hi=9000):
    return bp(gurultu(d), lo, hi) * zarf(d, 0.0003, d / 3)


def oda(x, karisim=0.12, sure=0.28):
    """Kucuk dukkan yankisi: sonumlu, alcak gecirgen gurultu darbe tepkisi."""
    ir = lp(gurultu(sure), 5000) * np.exp(-zaman(sure) / (sure / 5))
    ir[0] = 0
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    islak = signal.fftconvolve(x, ir)[:len(x) + int(sure * SR)]
    kuru = np.concatenate([x, np.zeros(len(islak) - len(x))])
    return kuru + karisim * islak


def bitir(x, tepe, son_ms=8):
    x = x - np.mean(x)
    n = int(son_ms / 1000 * SR)
    if n and len(x) > n:
        x[-n:] *= np.linspace(1, 0, n)
    # sondaki sessizligi kirp
    esik = np.max(np.abs(x)) * 0.002
    son = len(x)
    while son > 100 and np.max(np.abs(x[son - 100:son])) < esik:
        son -= 100
    x = x[:son]
    return x / (np.max(np.abs(x)) + 1e-9) * tepe


def citirti(d, yogunluk, tepe_tane=1.0, lo=1500, hi=9000, sonum=None):
    """Kizgin yag citirtisi: Poisson zamanli kisa tane patlamalari."""
    n = int(d * SR)
    x = np.zeros(n)
    t = 0.0
    while t < d:
        yog = yogunluk(t) if callable(yogunluk) else yogunluk
        t += rng.exponential(1.0 / max(yog, 1.0))
        if t >= d:
            break
        uz = rng.uniform(0.0008, 0.004)
        tane = gurultu(uz) * np.exp(-zaman(uz) / (uz / 3)) * rng.uniform(0.2, 1.0) ** 2 * tepe_tane
        ekle(x, tane, t)
    return bp(x, lo, hi)


def kabarcik(d, f0, sonum, yukselis=2.5):
    """Sivida kabarcik: perdesi yukselen kisa sinus (Minnaert rezonansi)."""
    t = zaman(d)
    f = f0 * (1 + yukselis * t / d)
    faz = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(faz) * np.exp(-t / sonum)


def perde_egri(f0, f1, d, dalga="sin", vib=0.0, vib_hz=5.0):
    t = zaman(d)
    f = f0 * (f1 / f0) ** (t / d) * (1 + vib * np.sin(2 * np.pi * vib_hz * t))
    faz = 2 * np.pi * np.cumsum(f) / SR
    if dalga == "testere":
        return 2 * ((faz / (2 * np.pi)) % 1.0) - 1
    return np.sin(faz)


def marimba(f, d=0.5, parlak=1.0):
    """Tahta tokmakli perde: temel + 4x (marimba ust kipi) + 10x, hizli sonum."""
    return ekle(kipler([(f, 0.28, 1.0), (f * 3.93, 0.05, 0.35 * parlak), (f * 9.2, 0.015, 0.12 * parlak)], d, 0.002), tik(0.003, 1500, 5000) * 0.15, 0.0)


def can(f, d=1.2, sonum=0.6):
    """Metal can / zil: uyumsuz kipler (zil oranlari)."""
    oranlar = [(1.0, 1.0, 1.0), (2.0, 0.6, 0.55), (2.76, 0.45, 0.4), (5.4, 0.25, 0.22), (8.93, 0.12, 0.12)]
    return kipler([(f * r, sonum * s, a) for r, s, a in oranlar], d, 0.003)


def fm_can(f, d=1.0, oran=3.5, indeks=3.0, sonum=0.5):
    t = zaman(d)
    e = np.exp(-t / sonum)
    x = np.sin(2 * np.pi * f * t + indeks * e * np.sin(2 * np.pi * f * oran * t))
    return x * e


# ---------------------------------------------------------------- sesler
def s_chop():
    """Bicak patatesi kesip tahtaya iner: citir kesim + tahta gumlemesi."""
    x = bos(0.25)
    ekle(x, bp(gurultu(0.03), 900, 5000) * zarf(0.03, 0.001, 0.009) * 0.5, 0.0)
    ekle(x, kipler([(rng.uniform(170, 210), 0.05, 1.0), (430, 0.03, 0.5), (980, 0.018, 0.3), (2150, 0.008, 0.2)], 0.2), 0.012)
    ekle(x, tik(0.004, 3000, 10000) * 0.6, 0.012)
    return bitir(oda(x, 0.1), 0.42)


def s_slice():
    """Uzun doner bicagi etten talas alir: tirtikli kazima + islak doku."""
    d = rng.uniform(0.2, 0.26)
    t = zaman(d)
    zar = np.minimum(1, t / 0.02) * np.clip((d - t) / 0.07, 0, 1)
    testere = 1 + 0.55 * np.sin(2 * np.pi * rng.uniform(55, 85) * t)
    x = bp(gurultu(d), 1300, 5200) * zar * testere * 0.8
    x += lp(gurultu(d), 700) * zar * 0.5
    return bitir(oda(x, 0.08), 0.3)


def s_knife():
    d = 0.3
    x = bp(gurultu(d), 4000, 11000) * zarf(d, 0.004, 0.05) * 0.7
    x += kipler([(3100, 0.25, 0.25), (5230, 0.18, 0.15), (7900, 0.1, 0.1)], d)
    return bitir(oda(x, 0.1), 0.3)


def s_pick():
    x = ekle(kipler([(rng.uniform(480, 560), 0.03, 1.0), (1260, 0.014, 0.4), (2600, 0.006, 0.2)], 0.1), tik(0.003, 2000, 6000) * 0.3, 0.0)
    return bitir(lp(x, 5000), 0.2)


def s_drop():
    x = kipler([(rng.uniform(140, 175), 0.06, 1.0), (360, 0.04, 0.5), (820, 0.02, 0.3)], 0.2)
    x += lp(gurultu(0.2), 1200) * zarf(0.2, 0.001, 0.015) * 0.5
    return bitir(oda(x, 0.1), 0.26)


def s_cash():
    """Yazar kasa: cekmece mandali, zil, cekmece kayar, bozuk paralar."""
    x = bos(1.0)
    ekle(x, tik(0.006, 1200, 5000) * 0.8, 0.0)
    ekle(x, can(rng.uniform(1780, 1900), 0.9, 0.5) * 0.6, 0.025)
    kay = bp(gurultu(0.18), 300, 1600) * (1 + 0.4 * np.sin(2 * np.pi * 60 * zaman(0.18))) * np.hanning(int(0.18 * SR)) * 0.4
    ekle(x, kay, 0.08)
    ekle(x, kipler([(230, 0.05, 0.8), (520, 0.03, 0.4)], 0.2), 0.26)
    for q in range(5):
        ekle(x, kipler([(rng.uniform(3200, 6500), 0.05, 0.25), (rng.uniform(7000, 9500), 0.03, 0.12)], 0.12), 0.28 + q * rng.uniform(0.03, 0.06))
    return bitir(oda(x, 0.14), 0.36)


def kagit(d, yogunluk, lo=1500, hi=9000):
    """Kagit hisirtisi: bukulen liflerin kucuk tik tik kirilmalari."""
    t = zaman(d)
    x = citirti(d, lambda u: yogunluk * np.sin(np.pi * min(u / d, 1)) + 20, 1.0, lo, hi)
    x += bp(gurultu(d), 2500, 7000) * np.sin(np.pi * np.clip(t / d, 0, 1)) * 0.05
    return x


def s_serve():
    x = bos(0.3)
    ekle(x, kagit(0.14, 260), 0.0)
    ekle(x, kipler([(300, 0.04, 0.6), (700, 0.02, 0.3)], 0.12), 0.1)
    return bitir(oda(x, 0.1), 0.26)


def s_crinkle():
    return bitir(oda(kagit(rng.uniform(0.28, 0.36), 420), 0.1), 0.45)


def s_wrap():
    d = 0.42
    x = kagit(d, 300)
    x += lp(gurultu(d), 800) * np.sin(np.pi * zaman(d) / d) * 0.25
    return bitir(oda(x, 0.1), 0.5)


def s_roll():
    """Lavas yuvarlanir: yumusak hamur surtunmesi, yavas dalgalanan."""
    d = 0.3
    t = zaman(d)
    x = bp(gurultu(d), 200, 1100) * np.sin(np.pi * t / d) * (1 + 0.5 * np.sin(2 * np.pi * 11 * t))
    x += kagit(d, 60, 2000, 6000) * 0.4
    return bitir(oda(x, 0.08), 0.24)


def s_fry():
    """Sepet kizgin yaga iner: bir anda kabaran citirti, yavasca oturur."""
    d = 1.4
    t = zaman(d)
    x = citirti(d, lambda u: 50 + 900 * np.exp(-u / 0.35), 1.0, 1800, 10000)
    x += bp(gurultu(d), 2500, 9000) * (0.12 * np.exp(-t / 0.4) + 0.03)
    x[:int(0.01 * SR)] *= np.linspace(0, 1, int(0.01 * SR))
    return bitir(x, 0.6, 60)


def s_sizzle():
    d = 0.7
    t = zaman(d)
    x = citirti(d, 220, 1.0, 2000, 10000) * np.clip((d - t) / 0.2, 0, 1)
    x += bp(gurultu(d), 3000, 9000) * 0.04 * np.clip((d - t) / 0.2, 0, 1)
    return bitir(x, 0.5, 40)


def s_steam():
    d = 0.55
    t = zaman(d)
    x = bp(gurultu(d), 2200, 11000) * np.minimum(1, t / 0.05) * np.exp(-t / 0.25)
    return bitir(x, 0.25, 30)


def s_pour():
    """Kisa dokme / sicrama."""
    d = 0.35
    x = bos(d)
    for q in range(28):
        ekle(x, kabarcik(0.03, rng.uniform(500, 1500), rng.uniform(0.004, 0.012)) * rng.uniform(0.2, 0.7), rng.uniform(0, d - 0.03))
    x += bp(gurultu(d), 400, 3000) * np.sin(np.pi * zaman(d) / d) * 0.25
    return bitir(oda(x, 0.1), 0.24)


def dokme_dongu(koyu):
    """Bardaga dokulen icecek (dongu, 2 sn): akis + kabarcik; kola kopuklu."""
    d = 2.0
    x = bp(gurultu(d + 0.2), 300 if koyu else 500, 2200 if koyu else 3800)
    x *= 0.5 + 0.25 * lp(np.abs(gurultu(d + 0.2)), 8)
    for q in range(int(d * (55 if koyu else 90))):
        f0 = rng.uniform(250, 700) if koyu else rng.uniform(500, 1600)
        ekle(x, kabarcik(0.03, f0, rng.uniform(0.004, 0.01)) * rng.uniform(0.3, 1.2), rng.uniform(0, d + 0.15))
    if not koyu:
        x += citirti(d + 0.2, 350, 0.5, 4000, 12000)
    # dikissiz dongu: son 0.2 sn basa bindirilir
    n = int(d * SR)
    k = int(0.2 * SR)
    y = x[:n].copy()
    y[:k] = y[:k] * np.linspace(0, 1, k) + x[n:n + k] * np.linspace(1, 0, k)
    return y / (np.max(np.abs(y)) + 1e-9) * 0.3


def s_squirt():
    """Sos sisesi sikilir: hava + koyu sivi fisirtisi, sonda pof."""
    d = 0.22
    t = zaman(d)
    f = 1800 * (0.25 ** (t / d))
    x = np.zeros_like(t)
    parca = int(0.01 * SR)
    g = gurultu(d)
    for i in range(0, len(t), parca):
        fc = float(f[i])
        x[i:i + parca] = bp(g[i:i + parca + 200], max(150, fc * 0.5), fc * 1.6)[:len(x[i:i + parca])]
    x *= np.minimum(1, t / 0.01) * (1 + 0.6 * np.sin(2 * np.pi * 34 * t)) * np.clip((d - t) / 0.05, 0, 1)
    x = ekle(np.concatenate([x, np.zeros(int(0.08 * SR))]), lp(gurultu(0.05), 600) * zarf(0.05, 0.002, 0.012) * 0.8, d - 0.02)
    return bitir(oda(x, 0.08), 0.26)


def s_plate():
    x = kipler([(rng.uniform(1900, 2100), 0.18, 1.0), (3350, 0.12, 0.6), (5200, 0.08, 0.4), (7400, 0.05, 0.2)], 0.5)
    ekle(x, kipler([(220, 0.03, 0.5)], 0.1), 0.0)
    ekle(x, tik(0.003, 2000, 9000) * 0.5, 0.0)
    return bitir(oda(x, 0.12), 0.3)


def s_glass():
    x = kipler([(rng.uniform(3000, 3300), 0.25, 1.0), (4700, 0.2, 0.5), (7900, 0.1, 0.3)], 0.5)
    return bitir(oda(x, 0.12), 0.22)


def s_basket():
    """Tel fritoz sepeti: iki metal tinlamasi."""
    x = bos(0.45)
    for q, b in enumerate((0.0, rng.uniform(0.05, 0.09))):
        ekle(x, kipler([(740, 0.08, 1.0), (1650, 0.06, 0.7), (2900, 0.05, 0.5), (4100, 0.03, 0.3)], 0.3) * (1.0 if q == 0 else 0.6), b)
    return bitir(oda(x, 0.1), 0.3)


def s_scoop():
    d = 0.18
    x = bp(gurultu(d), 2000, 6500) * zarf(d, 0.005, 0.05) * 0.6
    x += lp(gurultu(d), 500) * zarf(d, 0.01, 0.06) * 0.6
    return bitir(oda(x, 0.08), 0.35)


def s_potato():
    """Patates dilimlenir: citir kirilma taneleri + tahta."""
    x = bos(0.2)
    for q in range(rng.integers(3, 6)):
        ekle(x, bp(gurultu(0.008), 1200, 6000) * zarf(0.008, 0.0005, 0.002), q * rng.uniform(0.004, 0.009))
    ekle(x, kipler([(210, 0.04, 0.7), (520, 0.02, 0.35)], 0.15), 0.035)
    return bitir(oda(x, 0.1), 0.36)


def s_sack():
    d = 0.35
    x = lp(gurultu(d), 400) * zarf(d, 0.003, 0.05) * 1.0
    x += bp(gurultu(d), 600, 3500) * zarf(d, 0.01, 0.12) * 0.35
    return bitir(oda(x, 0.1), 0.3)


def cekmece(kapan):
    d = 0.32
    t = zaman(d)
    kay = bp(gurultu(d), 280, 2000) * (0.6 + 0.4 * np.abs(np.sin(2 * np.pi * rng.uniform(40, 70) * t))) * np.clip(t / 0.03, 0, 1) * np.clip((0.22 - t) / 0.05, 0, 1)
    x = np.concatenate([kay, np.zeros(int(0.15 * SR))])
    ekle(x, kipler([(140 if kapan else 190, 0.05, 1.0 if kapan else 0.5), (330, 0.03, 0.4)], 0.2), 0.21)
    return bitir(oda(x, 0.1), 0.28)


def s_stamp():
    x = kipler([(115, 0.05, 1.0), (260, 0.03, 0.5)], 0.25)
    ekle(x, bp(gurultu(0.02), 700, 3000) * zarf(0.02, 0.0005, 0.005) * 0.6, 0.0)
    return bitir(oda(x, 0.1), 0.34)


def s_footstep():
    x = lp(gurultu(0.12), 500) * zarf(0.12, 0.002, 0.018) + bp(gurultu(0.12), 1500, 4000) * zarf(0.12, 0.01, 0.02) * 0.2
    return bitir(x, 0.12)


def s_slam():
    x = kipler([(80, 0.12, 1.0), (170, 0.08, 0.6), (420, 0.04, 0.3)], 0.5)
    ekle(x, lp(gurultu(0.05), 1500) * zarf(0.05, 0.001, 0.01), 0.0)
    return bitir(oda(x, 0.14), 0.36)


def s_shutter():
    """Metal kepenk: serit serit tikirti + ugultu + sonda oturma."""
    d = 1.2
    x = lp(gurultu(d), 220) * np.sin(np.pi * np.clip(zaman(d) / d, 0, 1)) * 0.5
    t = 0.0
    while t < d - 0.1:
        ekle(x, kipler([(rng.uniform(600, 2400), 0.03, 1.0), (rng.uniform(2500, 4200), 0.015, 0.4)], 0.08) * rng.uniform(0.2, 0.6), t)
        t += rng.uniform(0.02, 0.045)
    x = np.concatenate([x, np.zeros(int(0.4 * SR))])
    ekle(x, kipler([(90, 0.1, 1.2), (190, 0.06, 0.6), (800, 0.03, 0.3)], 0.4), d - 0.05)
    return bitir(oda(x, 0.15), 0.34)


def s_carPass():
    d = rng.uniform(1.1, 1.5)
    t = zaman(d)
    zar = np.exp(-((t - d * 0.5) / (d * 0.22)) ** 2)
    x = bp(gurultu(d), 180, 1400) * zar
    x += perde_egri(95, 70, d) * zar * 0.2
    return bitir(x, 0.2, 60)


def s_horn():
    d = 0.42
    x = (perde_egri(420, 420, d, "testere") + perde_egri(505, 505, d, "testere")) * np.minimum(1, zaman(d) / 0.01)
    x = bp(x, 350, 2500)
    return bitir(oda(x, 0.2), 0.22, 30)


def s_moto():
    """Dayi'nin motoru: tek silindir patpat, gaz verilir."""
    d = 1.1
    t = zaman(d)
    f = 32 + 28 * np.clip(t / 0.6, 0, 1) ** 1.5
    faz = np.cumsum(f) / SR
    darbe = np.exp(-((faz % 1.0) * 14))
    x = lp(darbe * (1 + 0.3 * gurultu(d)), 1400) + bp(gurultu(d), 800, 3000) * 0.08
    x *= np.minimum(1, t / 0.05) * np.clip((d - t) / 0.3, 0, 1)
    return bitir(x, 0.26, 60)


def s_phone():
    """Eski telefon zili: iki can, 22 Hz ceki carpmasi."""
    d = 0.9
    t = zaman(d)
    cekic = (np.sin(2 * np.pi * 22 * t) > 0).astype(float)
    cekic = lp(cekic, 300)
    x = (can(1180, d, 0.25) + can(1420, d, 0.25) * 0.8)
    x = x * 0.3 + np.sin(2 * np.pi * 1180 * t) * cekic * 0.5 + np.sin(2 * np.pi * 1420 * t) * cekic * 0.4
    x *= np.clip((0.75 - t) / 0.05, 0, 1) + np.exp(-np.maximum(0, t - 0.75) / 0.12) * (t > 0.75)
    return bitir(oda(x, 0.12), 0.28)


def s_door():
    """Kapi ustundeki pirinc zil: birkac hizli vurus."""
    x = bos(1.4)
    zaman0 = 0.0
    for q in range(rng.integers(3, 5)):
        ekle(x, can(rng.uniform(2050, 2250), 1.0, 0.35) * (0.9 ** q), zaman0)
        zaman0 += rng.uniform(0.07, 0.12)
    return bitir(oda(x, 0.15), 0.26)


def s_bell():
    """Servis zili (masa zili): tek temiz ding."""
    x = kipler([(2600, 1.0, 1.0), (6030, 0.5, 0.35), (11000, 0.2, 0.1), (1300, 0.6, 0.1)], 1.4)
    ekle(x, tik(0.003, 3000, 10000) * 0.4, 0.0)
    return bitir(oda(x, 0.12), 0.26)


def s_ding():
    x = fm_can(1320, 1.0, 3.5, 1.2, 0.35) + fm_can(1980, 1.0, 2.0, 0.6, 0.25) * 0.3
    return bitir(oda(x, 0.1), 0.22)


# ---------------------------------------------------------------- arayuz
def s_ui():
    x = ekle(kipler([(rng.uniform(1750, 1850), 0.012, 1.0), (3300, 0.006, 0.4)], 0.06), tik(0.002, 3000, 9000) * 0.3, 0.0)
    return bitir(x, 0.16)


def s_uiBack():
    x = ekle(kipler([(1050, 0.016, 1.0), (2100, 0.008, 0.3)], 0.07), tik(0.002, 2000, 6000) * 0.2, 0.0)
    return bitir(x, 0.14)


def s_tick():
    return bitir(tik(0.003, 3500, 10000), 0.07)


def s_pop():
    x = perde_egri(380, 1300, 0.05) * zarf(0.05, 0.001, 0.02)
    return bitir(x, 0.16)


def s_warn():
    x = bos(0.45)
    ekle(x, marimba(740, 0.3), 0.0)
    ekle(x, marimba(560, 0.3), 0.12)
    return bitir(x, 0.24)


def s_bad():
    x = bos(0.5)
    ekle(x, marimba(196, 0.4, 1.4), 0.0)
    ekle(x, marimba(185, 0.4, 1.4), 0.09)
    return bitir(x, 0.3)


def s_fail():
    x = bos(0.9)
    for q, f in enumerate((392, 330, 262, 196)):
        ekle(x, marimba(f, 0.4), q * 0.11)
    return bitir(oda(x, 0.12), 0.3)


def s_angry():
    """Kizgin musteri: kisa genizden 'hih' — testere + agiz formanti."""
    d = 0.22
    x = perde_egri(150, 105, d, "testere", 0.03, 18)
    x = bp(x, 450, 1100) + bp(x, 150, 300) * 0.5
    x *= zarf(d, 0.02, 0.09)
    return bitir(x, 0.22)


def s_levelup():
    x = bos(1.3)
    for q, f in enumerate((1047, 1319, 1568, 2093)):
        ekle(x, fm_can(f, 0.9, 3.5, 1.5, 0.3), q * 0.085)
    return bitir(oda(x, 0.15), 0.28)


def s_fanfare():
    """Kutlama: pirinc akor (yavas atak, vibrato) + zil arpeji."""
    d = 1.6
    t = zaman(d)
    x = np.zeros_like(t)
    for f in (262, 330, 392, 523):
        x += perde_egri(f, f, d, "testere", 0.006, 5.2)
    x = lp(x, 1800) * np.minimum(1, t / 0.06) * np.clip((d - t) / 0.4, 0, 1) * 0.35
    for q, f in enumerate((523, 659, 784, 1047, 1319)):
        ekle(x, fm_can(f * 2, 0.9, 3.5, 1.2, 0.3) * 0.5, q * 0.1)
    return bitir(oda(x, 0.18), 0.32)


def s_fine():
    """Ceza: inen, ahenksiz trombon."""
    x = bos(1.2)
    for q, f in enumerate((330, 311, 294, 262)):
        n = perde_egri(f, f * (0.94 if q == 3 else 1.0), 0.32 if q < 3 else 0.6, "testere", 0.012 if q == 3 else 0.004, 5)
        n = lp(n, 1200) * zarf(len(n) / SR, 0.02, 0.25 if q < 3 else 0.5)
        ekle(x, n, q * 0.24)
    return bitir(oda(x, 0.15), 0.3)


SESLER = {
    "chop": s_chop, "slice": s_slice, "knife": s_knife, "pick": s_pick, "drop": s_drop,
    "cash": s_cash, "serve": s_serve, "crinkle": s_crinkle, "wrap": s_wrap, "roll": s_roll,
    "fry": s_fry, "sizzle": s_sizzle, "steam": s_steam, "pour": s_pour, "squirt": s_squirt,
    "plate": s_plate, "glass": s_glass, "basket": s_basket, "scoop": s_scoop, "potato": s_potato,
    "sack": s_sack, "drawer_ac": lambda: cekmece(False), "drawer_kapa": lambda: cekmece(True),
    "stamp": s_stamp, "footstep": s_footstep, "slam": s_slam, "shutter": s_shutter,
    "carPass": s_carPass, "horn": s_horn, "moto": s_moto, "phone": s_phone, "door": s_door,
    "bell": s_bell, "ding": s_ding, "ui": s_ui, "uiBack": s_uiBack, "tick": s_tick, "pop": s_pop,
    "warn": s_warn, "bad": s_bad, "fail": s_fail, "angry": s_angry, "levelup": s_levelup,
    "fanfare": s_fanfare, "fine": s_fine,
}
ACIKLAMA = {
    "chop": "chop - bicak patatesi kesip tahtaya iner", "slice": "slice - doner bicagi talas alir",
    "knife": "knife - bicak parlamasi", "pick": "pick - urunu alma", "drop": "drop - urunu birakma",
    "cash": "cash - yazar kasa", "serve": "serve - musteriye verme", "crinkle": "crinkle - kagit hisirtisi",
    "wrap": "wrap - durumu kagida sarma", "roll": "roll - lavasi yuvarlama", "fry": "fry - sepet yaga iner",
    "sizzle": "sizzle - izgarada cizirti", "steam": "steam - buhar", "pour": "pour - kisa dokme",
    "squirt": "squirt - sos sisesi", "plate": "plate - porselen tabak", "glass": "glass - bardak",
    "basket": "basket - tel fritoz sepeti", "scoop": "scoop - kasikla alma", "potato": "potato - patates dilimleme",
    "sack": "sack - patates cuvali", "drawer_ac": "drawer - depo cekmecesi acilir",
    "drawer_kapa": "drawer - depo cekmecesi kapanir", "stamp": "stamp - muhur", "footstep": "footstep - adim",
    "slam": "slam - kapi carpma", "shutter": "shutter - kepenk", "carPass": "carPass - gecen araba",
    "horn": "horn - korna", "moto": "moto - Dayi'nin motoru", "phone": "phone - telefon zili",
    "door": "door - kapi zili (musteri gelir)", "bell": "bell - servis zili", "ding": "ding - bildirim",
    "ui": "ui - dugme", "uiBack": "uiBack - geri dugmesi", "tick": "tick - tik", "pop": "pop - balon",
    "warn": "warn - uyari", "bad": "bad - hata", "fail": "fail - basarisiz", "angry": "angry - kizgin musteri",
    "levelup": "levelup - seviye / satin alma", "fanfare": "fanfare - kutlama", "fine": "fine - ceza",
    "pour_ayran": "ayran dokme dongusu", "pour_kola": "kola dokme dongusu (kopuklu)",
}
TEK = {"ui", "uiBack", "tick", "pop", "warn", "fail", "levelup", "fanfare", "fine", "phone", "bell", "ding", "moto"}


def yaz(yol, x):
    x = np.clip(x, -1, 1)
    with wave.open(yol, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype("<i2").tobytes())


def main():
    global rng
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith(".wav"):
            os.remove(os.path.join(OUT, f))
    tanitim = []
    sayim = {}
    liste = []
    konum = lambda: sum(len(p) for p in tanitim) / SR
    for ad, fn in SESLER.items():
        n = 1 if ad in TEK else 3
        sayim[ad] = n
        liste.append("%5.1f sn  %s (%d cesit)" % (konum(), ACIKLAMA.get(ad, ad), n))
        for i in range(n):
            rng = np.random.default_rng(zlib.crc32(ad.encode()) % 100000 + i * 7919)   # kararli tohum
            x = fn()
            assert np.all(np.isfinite(x)) and len(x) > 100, ad
            yaz(os.path.join(OUT, "%s_%d.wav" % (ad, i)), x)
            tanitim += [x, np.zeros(int(0.25 * SR))]
        tanitim.append(np.zeros(int(0.35 * SR)))
    for ad, koyu in (("pour_ayran", True), ("pour_kola", False)):
        liste.append("%5.1f sn  %s" % (konum(), ACIKLAMA.get(ad, ad)))
        rng = np.random.default_rng(len(ad) * 31)
        x = dokme_dongu(koyu)
        yaz(os.path.join(OUT, ad + "_0.wav"), x)
        tanitim += [x, np.zeros(int(0.4 * SR))]
        sayim[ad] = 1
    yaz(os.path.join(KOK, "artifacts", "ses_tanitim.wav"), np.concatenate(tanitim))
    with open(os.path.join(KOK, "artifacts", "ses_tanitim.txt"), "w", encoding="utf-8") as fp:
        fp.write("\n".join(liste) + "\n")
    print("SFX", len(sayim), "ses,", sum(sayim.values()), "dosya")
    print({k: v for k, v in sayim.items()})


if __name__ == "__main__":
    main()
