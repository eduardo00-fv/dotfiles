#!/usr/bin/env python3
"""Fecha y saludo en español para el widget de reloj (el sistema está en inglés)."""
import json
import time

DIAS = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
MESES = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre"]

t = time.localtime()
h = t.tm_hour
saludo = "Buenos días" if 5 <= h < 12 else "Buenas tardes" if 12 <= h < 19 else "Buenas noches"
print(json.dumps({
    "fecha": f"{DIAS[t.tm_wday]}, {t.tm_mday} de {MESES[t.tm_mon - 1]}",
    "saludo": f"{saludo}, Thrain",
}, ensure_ascii=False))
