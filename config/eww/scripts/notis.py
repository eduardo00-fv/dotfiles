#!/usr/bin/env python3
"""Hub de notificaciones para eww.

Escucha las llamadas Notify del bus de sesión con `busctl monitor` (sin
tocar swaync) y guarda las últimas. Imprime una línea JSON cada vez que
llega una notificación y cada 30 s (para refrescar el "hace X min").

  kill -USR1 $(cat $XDG_RUNTIME_DIR/eww-notis.pid)  -> vacía la lista
  (lo usa el botón "limpiar"; con pkill -f también se mataba el shell del botón)
"""
import json
import os
import signal
import subprocess
import threading
import time

KEEP = 20
SHOW = 2
RUNTIME = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
STORE = os.path.join(RUNTIME, "eww-notis.json")
PIDFILE = os.path.join(RUNTIME, "eww-notis.pid")

lock = threading.Lock()
try:
    notis = json.load(open(STORE))
except Exception:
    notis = []


def hace(ts):
    s = int(time.time() - ts)
    if s < 60:
        return "ahora"
    if s < 3600:
        return f"hace {s // 60} min"
    if s < 86400:
        return f"hace {s // 3600} h"
    return f"hace {s // 86400} d"


def emit():
    with lock:
        items = [{"app": n["app"], "titulo": n["titulo"], "cuerpo": n["cuerpo"],
                  "hace": hace(n["ts"])} for n in notis[:SHOW]]
        total = len(notis)
    print(json.dumps({"items": items, "total": total}, ensure_ascii=False), flush=True)


def save():
    try:
        json.dump(notis, open(STORE, "w"), ensure_ascii=False)
    except OSError:
        pass


def clear(*_):
    with lock:
        notis.clear()
        save()
    emit()


def ticker():
    while True:
        time.sleep(30)
        emit()


def main():
    signal.signal(signal.SIGUSR1, clear)
    with open(PIDFILE, "w") as f:
        f.write(str(os.getpid()))
    threading.Thread(target=ticker, daemon=True).start()
    emit()
    cmd = ["busctl", "--user", "monitor", "--json=short", "--match",
           "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"]
    while True:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        for line in proc.stdout:
            try:
                app, _rid, _icon, titulo, cuerpo = json.loads(line)["payload"]["data"][:5]
            except (ValueError, KeyError, TypeError):
                continue
            n = {"app": app or "Sistema", "titulo": " ".join(titulo.split()),
                 "cuerpo": " ".join(cuerpo.split()), "ts": time.time()}
            with lock:
                notis.insert(0, n)
                del notis[KEEP:]
                save()
            emit()
        time.sleep(3)   # busctl murió (p. ej. reinicio del bus): reintentar


if __name__ == "__main__":
    main()
