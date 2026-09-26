#!/usr/bin/env python3
"""Reproductor actual (vía playerctld = el último que sonó) en JSON para eww.

Apple Music web en Brave publica título/artista/carátula por MPRIS, igual que
YouTube o Spotify: el widget muestra y controla lo que esté sonando.
Una línea JSON por cambio de canción/estado; al no haber reproductor, activo=false.
"""
import json
import subprocess
import sys
import time
from urllib.parse import unquote

SEP = "\x1f"
FMT = SEP.join(["{{playerName}}", "{{status}}", "{{title}}", "{{artist}}",
                "{{album}}", "{{mpris:artUrl}}"])
VACIO = {"activo": False, "estado": "Stopped", "titulo": "", "artista": "",
         "album": "", "arte": ""}


def emitir(d):
    print(json.dumps(d, ensure_ascii=False), flush=True)


def parsear(linea):
    partes = linea.rstrip("\n").split(SEP)
    if len(partes) != 6 or not partes[0]:
        return VACIO
    player, estado, titulo, artista, album, arte = partes
    arte = unquote(arte[7:]) if arte.startswith("file://") else ""
    return {"activo": bool(titulo), "estado": estado, "titulo": titulo,
            "artista": artista, "album": album, "arte": arte}


emitir(VACIO)
while True:
    proc = subprocess.Popen(
        ["playerctl", "-p", "playerctld", "--follow", "metadata", "--format", FMT],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    for linea in proc.stdout:
        emitir(parsear(linea) if linea.strip() else VACIO)
    emitir(VACIO)
    time.sleep(3)
