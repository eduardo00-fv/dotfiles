#!/usr/bin/env python3
"""Fondos degradados/texturizados en la paleta Tinta.
Uso: gen.py ANCHO ALTO DIR [nombres...]"""
import sys, os
import numpy as np
from PIL import Image, ImageFilter

W, H, OUT = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
SOLO = set(sys.argv[4:])
os.makedirs(OUT, exist_ok=True)

def hx(h):
    h = h.lstrip('#'); return np.array([int(h[i:i+2], 16) for i in (0, 2, 4)], float) / 255

def lin(c):  return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
def srgb(c): return np.where(c <= 0.0031308, c * 12.92, 1.055 * np.clip(c, 0, None) ** (1 / 2.4) - 0.055)

yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
xx /= W; yy /= H
asp = W / H

def blobs(base, manchas):
    """base + manchas gaussianas suaves (x, y, radio, color, fuerza), mezcla en lineal."""
    img = np.broadcast_to(lin(hx(base)), (H, W, 3)).copy()
    for x, y, r, col, a in manchas:
        d2 = ((xx - x) * asp) ** 2 + (yy - y) ** 2
        w = (a * np.exp(-d2 / (2 * r * r)))[..., None]
        img = img * (1 - w) + lin(hx(col)) * w
    return img

def vertical(stops):
    img = np.zeros((H, W, 3), np.float32)
    ps = [p for p, _ in stops]; cs = [lin(hx(c)) for _, c in stops]
    t = yy + 0.08 * np.sin(xx * 3.1 + 0.7)          # un pelo de curva, no recto
    for k in range(3):
        img[..., k] = np.interp(t, ps, [c[k] for c in cs])
    return img

rng = np.random.default_rng(7)

def papel(img, fuerza):
    """Textura tipo papel/pared: ruido multi-escala suave."""
    tot = np.zeros((H, W), np.float32)
    for esc, peso in ((0.004, 1.0), (0.015, 0.6), (0.06, 0.35)):
        w, h = max(8, int(W * esc)), max(8, int(H * esc))
        n = Image.fromarray(((rng.random((h, w)) * 255)).astype(np.uint8)).resize((W, H), Image.BICUBIC)
        tot += (np.asarray(n, np.float32) / 255 - 0.5) * peso
    return img * (1 + fuerza * tot[..., None])

def terminar(img, nombre, grano=0.022):
    out = srgb(np.clip(img, 0, 1))
    out = out + rng.normal(0, grano, (H, W, 1))       # grano de película, monocromo
    Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)).save(
        os.path.join(OUT, nombre + '.png' if W < 2000 else nombre + '.jpg'), quality=95)

T = {  # paleta
 'tinta': '#1d1a16', 'sup': '#2a241d', 'terra': '#e0551f', 'terra2': '#c9461b',
 'crema': '#ecdcc0', 'arena': '#bfae90', 'nogal': '#5e5245', 'ocre': '#d9a441',
 'musgo': '#6b7b3f', 'musgo2': '#3f4a26', 'musgo3': '#8a9a5b', 'salvia': '#a3ad86',
}
F = {
 '01-brasa':        lambda: blobs(T['tinta'], [(0.15, 1.05, 0.45, T['terra2'], 0.85), (0.35, 0.95, 0.25, T['ocre'], 0.35), (0.9, 0.1, 0.4, T['sup'], 0.6)]),
 '02-musgo-profundo': lambda: blobs(T['musgo2'], [(0.8, 0.2, 0.45, T['musgo'], 0.7), (0.2, 0.9, 0.35, '#262c17', 0.8), (0.65, 0.6, 0.18, T['salvia'], 0.25)]),
 '03-atardecer-terra': lambda: vertical([(0.0, '#2e2a33'), (0.35, '#7a4a3a'), (0.7, T['terra2']), (1.0, T['ocre'])]),
 '04-musgo-y-brasa':  lambda: blobs(T['tinta'], [(0.1, 0.95, 0.45, T['musgo'], 0.8), (0.95, 0.1, 0.4, T['terra2'], 0.7), (0.5, 0.5, 0.3, T['nogal'], 0.3)]),
 '05-pared-musgo':    lambda: papel(blobs(T['musgo'], [(0.3, 0.3, 0.6, T['musgo3'], 0.35), (0.9, 0.9, 0.5, T['musgo2'], 0.4)]), 0.10),
 '06-pared-terracota':lambda: papel(blobs(T['terra2'], [(0.25, 0.2, 0.6, T['terra'], 0.4), (0.85, 0.95, 0.5, '#8f3212', 0.5)]), 0.10),
 '07-niebla-salvia':  lambda: blobs(T['salvia'], [(0.15, 0.1, 0.4, T['crema'], 0.7), (0.9, 0.85, 0.45, T['musgo'], 0.55), (0.6, 0.4, 0.3, '#c9c3a0', 0.4)]),
 '08-papel-crema':    lambda: papel(blobs(T['crema'], [(0.85, 0.15, 0.5, '#f0c9a0', 0.5), (0.1, 0.9, 0.5, T['arena'], 0.45)]), 0.06),
 '09-tinta-sola':     lambda: papel(blobs(T['tinta'], [(0.7, 0.35, 0.5, '#2f2820', 0.8), (0.2, 0.8, 0.4, '#16130f', 0.6)]), 0.08),
 '10-ocre-y-musgo':   lambda: vertical([(0.0, T['musgo2']), (0.45, T['musgo']), (0.8, '#b0893a'), (1.0, T['ocre'])]),
 '11-lampara':        lambda: blobs(T['nogal'], [(0.5, 0.45, 0.35, T['ocre'], 0.75), (0.5, 0.45, 0.15, T['crema'], 0.4), (0.0, 1.0, 0.5, T['tinta'], 0.8), (1.0, 0.0, 0.5, T['tinta'], 0.8)]),
 '12-bosque-noche':   lambda: blobs('#1b2014', [(0.75, 0.25, 0.4, T['musgo'], 0.55), (0.25, 0.75, 0.35, T['terra2'], 0.3), (0.5, 0.5, 0.6, T['musgo2'], 0.3)]),
}
for nombre, f in F.items():
    if SOLO and nombre not in SOLO: continue
    terminar(f(), nombre)
    print(nombre)
