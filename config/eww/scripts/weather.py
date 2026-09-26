#!/usr/bin/env python3
"""Clima para el widget de eww (wttr.in, sin cuenta). Imprime una línea JSON.

La ciudad sale de la IP; para fijarla, poner p. ej. CITY = "Cartago".
"""
import json
import urllib.request

CITY = ""

# weatherCode de wttr.in -> ícono de Nerd Font (familia nf-weather)
ICONS = {
    "clear": ("", ""),   # día, noche
    "partly": ("", ""),
    "cloudy": ("", ""),
    "fog": ("", ""),
    "drizzle": ("", ""),
    "rain": ("", ""),
    "storm": ("", ""),
    "snow": ("", ""),
}
GROUPS = {
    "clear": {113}, "partly": {116}, "cloudy": {119, 122},
    "fog": {143, 248, 260},
    "drizzle": {176, 263, 266, 293, 296, 353},
    "rain": {299, 302, 305, 308, 311, 314, 356, 359},
    "storm": {200, 386, 389, 392, 395},
    "snow": {179, 182, 185, 227, 230, 281, 284, 317, 320, 323, 326, 329,
             332, 335, 338, 350, 362, 365, 368, 371, 374, 377},
}


def main():
    try:
        url = f"https://wttr.in/{CITY}?format=j1&lang=es"
        req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
        d = json.load(urllib.request.urlopen(req, timeout=20))
        cur = d["current_condition"][0]
        today = d["weather"][0]
        code = int(cur["weatherCode"])
        group = next((g for g, codes in GROUPS.items() if code in codes), "cloudy")
        # es de noche si la hora local está fuera de amanecer-atardecer
        hour = int(cur.get("localObsDateTime", "00:00 AM").split()[1].split(":")[0]) \
            if "localObsDateTime" in cur else 12
        if "PM" in cur.get("localObsDateTime", "") and hour != 12:
            hour += 12
        night = hour < 6 or hour >= 18
        desc = (cur.get("lang_es") or cur["weatherDesc"])[0]["value"].strip()
        out = {
            "ok": True,
            "city": d["nearest_area"][0]["areaName"][0]["value"],
            "temp": cur["temp_C"],
            "feels": cur["FeelsLikeC"],
            "desc": desc[:1].upper() + desc[1:],
            "icon": ICONS[group][1 if night else 0],
            "max": today["maxtempC"],
            "min": today["mintempC"],
            "hum": cur["humidity"],
        }
    except Exception:
        out = {"ok": False, "city": "", "temp": "--", "feels": "--",
               "desc": "Sin conexión", "icon": "", "max": "--",
               "min": "--", "hum": "--"}
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
