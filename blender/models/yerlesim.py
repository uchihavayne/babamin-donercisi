"""Birlesik surumun pencere / cam olculeri (scripts/counter_design.gd _ready).

Remake 272x100 pencere (cam 264x92) kullaniyordu; yeni tezgah yerlesiminde
pencere 300x103, cam 292x95. Vitrin ve sokak arka plani betikleri buradan okur.
"""
WIN = (126, 28, 300, 103)      # x, y, w, h (mantik pikseli)
GLASS = (130, 32, 292, 95)

WIN_W, WIN_H = WIN[2], WIN[3]
GL_W, GL_H = GLASS[2], GLASS[3]
GL_X, GL_Y = GLASS[0] - WIN[0], GLASS[1] - WIN[1]   # cam, pencereye gore

SPIT_CX, SPIT_TOP, SPIT_BOT = 66, 56, 174          # LAY.spit (remake: 80, 58, 168)
