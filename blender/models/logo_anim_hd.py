"""BASLIK LOGOSU — remake HD (2x). logo_anim.py'nin aynisi, iki kat cozunurlukte.

    blender --background --factory-startup --python blender/models/logo_anim_hd.py -- hepsi
    python blender/logo_hd_paketle.py

Kamera ve sahne logo_anim.py ile ayni (320x112 mantik tuvali); yalniz render
640x224. Paketleyici katmanlari ayni kutulara kirpar, oyun (remake_gorsel.gd
f_hdLogoCiz) eski zamanlamayla (atesleme, titreme, sis turu, parilti) cizer.
"""
import sys, os, bpy

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import logo as L
import logo_anim as LA

LA.OUT = os.path.join(_HERE, "out", "logo_anim_hd")
_eski_sahne = L.sahne


def sahne_hd():
    _eski_sahne()
    r = bpy.context.scene.render
    r.resolution_x = L.W * 2
    r.resolution_y = L.H * 2


LA.sahne = sahne_hd

if __name__ == "__main__":
    LA.main()
