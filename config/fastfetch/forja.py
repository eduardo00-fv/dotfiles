#!/usr/bin/env python3
"""fastfetch "la forja": un casco enano da una vuelta en 3D y THRAIN se forja abajo.

  forja.py         fastfetch + animación (lo llama .zshrc al abrir terminal)
  forja.py --gen   regenera casco.json (cuadros) y logo.txt (logo estático)

El casco se renderiza con raymarching (numpy) a medio-bloques ▀▄: cada celda
de terminal = 2 píxeles. Los cuadros se calculan una vez y se guardan en
~/.cache/forja; al abrir terminal solo se reproducen.
La animación se dibuja ENCIMA del logo estático que ya imprimió fastfetch,
así que si algo falla (terminal chica, sin tty) queda el logo normal.
"""
import json, os, random, subprocess, sys, time

AQUI = os.path.dirname(os.path.abspath(__file__))
LOGO = os.path.join(AQUI, "logo.txt")
CACHE = os.path.expanduser("~/.cache/forja/casco.json")
VERSION = 4                       # subir si cambia el modelo → regenera la caché

# ---------------------------------------------------------------- nombre
LETRAS = {
    "T": ["██████", "  ██  ", "  ██  ", "  ██  ", "  ██  "],
    "H": ["██  ██", "██  ██", "██████", "██  ██", "██  ██"],
    "R": ["█████ ", "██  ██", "█████ ", "██ ██ ", "██  ██"],
    "A": [" ████ ", "██  ██", "██████", "██  ██", "██  ██"],
    "I": ["██", "██", "██", "██", "██"],
    "N": ["██   ██", "███  ██", "██ █ ██", "██  ███", "██   ██"],
}
FILAS = ["".join(LETRAS[c][f] + " " for c in "THRAIN").rstrip() for f in range(5)]
ANCHO_NOMBRE = max(len(f) for f in FILAS)
# metal ya frío: ocre claro arriba → terracota oscura abajo
FINAL = [(232, 191, 106), (217, 164, 65), (232, 116, 74), (224, 85, 31), (201, 70, 27)]
NOGAL = (94, 82, 69)
BLANCO = (255, 244, 222)

# ---------------------------------------------------------------- casco
CW, CH = 36, 12                   # celdas del casco (px: 36 x 24)
CUADROS = 40
ANCHO = max(CW, ANCHO_NOMBRE)
OFF_CASCO = (ANCHO - CW) // 2
FILA_NOMBRE = CH + 1              # una fila libre para chispas entre casco y nombre
PAD_TOP, PAD_LEFT = 1, 2          # igual que "padding" del logo en config.jsonc


def fg(c):
    return f"\033[38;2;{c[0]};{c[1]};{c[2]}m"


def bg(c):
    return f"\033[48;2;{c[0]};{c[1]};{c[2]}m"


def render_casco(theta):
    """Devuelve CH filas de texto ANSI (cada una exactamente CW celdas)."""
    import numpy as np
    W, H = CW, CH * 2
    xs = np.linspace(-1.8, 1.8, W)
    ys = np.linspace(1.3, -1.1, H)
    X, Y = np.meshgrid(xs, ys)
    c, s = np.cos(theta), np.sin(theta)

    def a_objeto(px, py, pz):          # rotar cámara → objeto (eje Y, -theta)
        return c * px - s * pz, py, s * px + c * pz

    def length(*v):
        return np.sqrt(sum(a * a for a in v))

    def elipsoide(x, y, z, r):
        k0 = length(x / r[0], y / r[1], z / r[2])
        k1 = length(x / r[0] ** 2, y / r[1] ** 2, z / r[2] ** 2)
        return k0 * (k0 - 1.0) / np.maximum(k1, 1e-6)

    def capsula(x, y, z, a, b, r1, r2):
        pa = (x - a[0], y - a[1], z - a[2])
        ba = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
        h = np.clip((pa[0] * ba[0] + pa[1] * ba[1] + pa[2] * ba[2]) / sum(v * v for v in ba), 0, 1)
        return length(pa[0] - ba[0] * h, pa[1] - ba[1] * h, pa[2] - ba[2] * h) - (r1 + (r2 - r1) * h), h

    def escena(x, y, z):
        cy = -0.1
        cupula = np.maximum(elipsoide(x, y - cy, z, (1.0, 1.08, 1.0)), -(y + 0.12))
        cresta = np.maximum(np.maximum(np.abs(x) - 0.08, elipsoide(x, y - cy, z, (1.08, 1.17, 1.08))), -(y - 0.0))
        banda = np.maximum(length(x, z) - 1.07, np.abs(y + 0.22) - 0.11)
        nasal = np.maximum.reduce([np.abs(x) - 0.1, np.abs(y + 0.45) - 0.25, np.abs(z - 1.03) - 0.07])
        remache = np.full_like(x, 9.0)
        for k in range(8):
            ang = k * np.pi / 4 + np.pi / 8
            remache = np.minimum(remache, length(x - 1.09 * np.sin(ang), y + 0.22, z - 1.09 * np.cos(ang)) - 0.075)
        cuerno = np.full_like(x, 9.0)
        t_cuerno = np.zeros_like(x)
        for sg in (-1, 1):
            d1, h1 = capsula(x, y, z, (sg * 0.9, -0.08, 0), (sg * 1.38, 0.22, 0.05), 0.2, 0.13)
            d2, h2 = capsula(x, y, z, (sg * 1.38, 0.22, 0.05), (sg * 1.5, 0.92, 0.0), 0.13, 0.03)
            t = np.where(d1 < d2, h1 * 0.5, 0.5 + h2 * 0.5)
            d = np.minimum(d1, d2)
            t_cuerno = np.where(d < cuerno, t, t_cuerno)
            cuerno = np.minimum(cuerno, d)
        partes = [cupula, cresta, banda, nasal, remache, cuerno]
        d = np.minimum.reduce(partes)
        mat = np.argmin(np.stack(partes), axis=0)
        return d, mat, t_cuerno

    # raymarch ortográfico desde +z
    t = np.zeros_like(X)
    hit = np.zeros(X.shape, bool)
    for _ in range(90):
        pz = 3.0 - t
        d, _, _ = escena(*a_objeto(X, Y, pz))
        hit |= d < 0.003
        t = np.where(hit, t, t + d * 0.85)
    hit &= t < 6
    pz = 3.0 - t
    ox, oy, oz = a_objeto(X, Y, pz)
    _, mat, tc = escena(ox, oy, oz)
    e = 0.003
    nx = escena(ox + e, oy, oz)[0] - escena(ox - e, oy, oz)[0]
    ny = escena(ox, oy + e, oz)[0] - escena(ox, oy - e, oz)[0]
    nz = escena(ox, oy, oz + e)[0] - escena(ox, oy, oz - e)[0]
    n = length(nx, ny, nz) + 1e-9
    nx, ny, nz = nx / n, ny / n, nz / n
    # normal de objeto → cámara (rotar +theta)
    cx, cz = c * nx + s * nz, -s * nx + c * nz
    luz = np.array([-0.55, 0.65, 0.55]); luz /= np.linalg.norm(luz)
    dif = np.clip(cx * luz[0] + ny * luz[1] + cz * luz[2], 0, 1)
    # especular (Blinn) con vista (0,0,1)
    hv = luz + np.array([0, 0, 1.0]); hv /= np.linalg.norm(hv)
    esp = np.clip(cx * hv[0] + ny * hv[1] + cz * hv[2], 0, 1)

    albedo = {0: (150, 136, 112),    # cúpula: acero viejo
              1: (217, 164, 65),     # cresta: bronce
              2: (196, 140, 58),     # banda: bronce oscuro
              3: (217, 164, 65),     # nasal
              4: (224, 85, 31)}      # remaches: terracota
    brillo = {0: 0.55, 1: 0.7, 2: 0.6, 3: 0.7, 4: 0.3, 5: 0.25}
    img = np.zeros(X.shape + (3,))
    for m, col in albedo.items():
        img[mat == m] = col
    marfil, punta = np.array([226, 205, 168]), np.array(NOGAL)
    k = (tc ** 2)[..., None]
    img = np.where((mat == 5)[..., None], marfil * (1 - k) + punta * k, img)
    b = np.vectorize(brillo.get)(mat)
    shade = 0.3 + 0.7 * dif
    img = img * shade[..., None] + (esp ** 60 * b * 150)[..., None] * np.array([1.0, 0.92, 0.78])
    img = np.clip(img, 0, 255).astype(int)

    filas = []
    for r in range(CH):
        linea = []
        for x in range(W):
            a, b2 = hit[2 * r, x], hit[2 * r + 1, x]
            ca, cb = tuple(img[2 * r, x]), tuple(img[2 * r + 1, x])
            if a and b2:
                linea.append(fg(ca) + bg(cb) + "▀")
            elif a:
                linea.append("\033[49m" + fg(ca) + "▀")
            elif b2:
                linea.append("\033[49m" + fg(cb) + "▄")
            else:
                linea.append("\033[49m ")
        filas.append("".join(linea) + "\033[0m")
    return filas


def cuadros():
    try:
        datos = json.load(open(CACHE))
        if datos.get("v") == VERSION:
            return datos["cuadros"]
    except (OSError, ValueError):
        pass
    import math
    lista = []
    for i in range(CUADROS):
        u = i / (CUADROS - 1)
        theta = -2 * math.pi * (1 - u) ** 3      # una vuelta completa que frena de frente
        lista.append(render_casco(theta))
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    json.dump({"v": VERSION, "cuadros": lista}, open(CACHE, "w"))
    return lista


def gen():
    final = cuadros()[-1]
    pad = " " * OFF_CASCO
    lineas = [pad + f for f in final]
    lineas.append("")
    lineas += [fg(FINAL[i]) + f + "\033[0m" for i, f in enumerate(FILAS)]
    open(LOGO, "w").write("\n".join(lineas) + "\n")


# ---------------------------------------------------------------- animación
def mezcla(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def calor(h):
    """0 = frío (nogal) … 1 = blanco. Rampa de herrero."""
    rampa = [NOGAL, (176, 105, 90), (224, 85, 31), (232, 191, 106), BLANCO]
    x = max(0.0, min(1.0, h)) * (len(rampa) - 1)
    i = min(int(x), len(rampa) - 2)
    return mezcla(rampa[i], rampa[i + 1], x - i)


def animar(n_lineas, lista):
    out = sys.stdout
    w = out.write
    w("\033[?25l")
    w(f"\033[{n_lineas}A\0337")
    col0 = PAD_LEFT + 1

    def ir(fila, col):
        return "\0338" + (f"\033[{PAD_TOP + fila}B" if PAD_TOP + fila else "") + f"\033[{col}G"

    enfria = 18
    chispas = []
    total = len(lista)
    for p, casco in enumerate(lista):
        buf = []
        for r, fila in enumerate(casco):
            buf.append(ir(r, col0 + OFF_CASCO) + fila)
        frente = (p / (total - 1)) * (ANCHO_NOMBRE + enfria)
        if frente < ANCHO_NOMBRE + 2 and random.random() < 0.9:
            chispas.append([frente, 0.5, random.uniform(-1.6, 1.6), random.uniform(-0.9, -0.3), 1.0])
        buf.append(ir(FILA_NOMBRE - 1, col0) + " " * ANCHO)
        for s in chispas:
            s[0] += s[2]; s[1] += s[3]; s[3] += 0.3; s[4] -= 0.16
            if s[4] > 0 and 0 <= s[1] < 1 and 0 <= s[0] < ANCHO:
                buf.append(ir(FILA_NOMBRE - 1, col0 + int(s[0])) + fg(calor(s[4])) + ("·" if s[4] < 0.5 else "*"))
        chispas = [s for s in chispas if s[4] > 0]
        for r, fila in enumerate(FILAS):
            linea = []
            for x, ch in enumerate(fila.ljust(ANCHO_NOMBRE)):
                d = frente - x
                if ch == " " or d < 0:
                    linea.append(" ")
                else:
                    h = max(0.0, 1.0 - d / enfria)
                    linea.append(fg(mezcla(FINAL[r], calor(0.35 + 0.65 * h), h)) + ch)
            buf.append(ir(FILA_NOMBRE + r, col0) + "".join(linea))
        w("".join(buf) + "\033[0m")
        out.flush()
        time.sleep(0.03)
    for r, fila in enumerate(FILAS):
        w(ir(FILA_NOMBRE + r, col0) + fg(FINAL[r]) + fila)
    w("\033[0m\0338" + f"\033[{n_lineas}B" + "\r\033[?25h")
    out.flush()


def main():
    if "--gen" in sys.argv:
        if os.path.exists(CACHE):
            os.remove(CACHE)
        gen()
        return
    if not os.path.exists(LOGO):
        gen()
    salida = subprocess.run(["fastfetch", "--pipe", "false"], capture_output=True, text=True).stdout
    sys.stdout.write(salida)
    sys.stdout.flush()
    n = salida.count("\n")
    try:
        filas_term = os.get_terminal_size().lines
    except OSError:
        return
    if sys.stdout.isatty() and filas_term > n + 2 and os.environ.get("FORJA_QUIETA") != "1":
        try:
            animar(n, cuadros())
        except KeyboardInterrupt:
            sys.stdout.write("\0338" + f"\033[{n}B" + "\r\033[0m\033[?25h")


if __name__ == "__main__":
    main()
