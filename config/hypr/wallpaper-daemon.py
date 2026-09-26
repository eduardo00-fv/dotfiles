#!/usr/bin/env python3
"""Listener de eventos de Hyprland para el live wallpaper.

  fullscreen>>1 / fullscreen>>0   -> SIGSTOP/SIGCONT a mpvpaper (ahorra batería)
  monitoradded / monitorremoved   -> re-aplica el wallpaper
  cada ROTATE_INTERVAL segundos    -> pasa al siguiente wallpaper (Super+W
                                      hace lo mismo a mano)

Lo segundo es lo que faltaba: random-wallpaper.sh solo corre en el login, así
que un monitor externo enchufado después se quedaba sin vídeo para siempre.
"""
import os
import socket
import signal
import subprocess
import threading
import time

WALLPAPER_SCRIPT = os.path.expanduser("~/.config/hypr/random-wallpaper.sh")
# Los eventos de hotplug llegan en ráfaga (monitoradded + monitoraddedv2, y
# Hyprland reordena outputs); se agrupan antes de relanzar mpvpaper.
REAPPLY_DELAY = 1.5
ROTATE_INTERVAL = 30 * 60

_fullscreen = False

_timer = None
_timer_lock = threading.Lock()


def get_mpvpaper_pid():
    try:
        result = subprocess.run(["pgrep", "-x", "mpvpaper"], capture_output=True, text=True)
        pids = result.stdout.strip().split()
        return [int(p) for p in pids if p]
    except Exception:
        return []


def signal_mpvpaper(sig):
    for pid in get_mpvpaper_pid():
        try:
            os.kill(pid, sig)
        except ProcessLookupError:
            pass


def reapply_wallpaper():
    subprocess.Popen(
        [WALLPAPER_SCRIPT, "--reapply"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def rotate_loop():
    # Con una ventana en fullscreen el vídeo está pausado (SIGSTOP); rotar ahí
    # relanzaría mpvpaper sin pausar, así que se salta ese turno.
    while True:
        time.sleep(ROTATE_INTERVAL)
        if not _fullscreen:
            subprocess.Popen(
                [WALLPAPER_SCRIPT],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )


def schedule_reapply():
    global _timer
    with _timer_lock:
        if _timer is not None:
            _timer.cancel()
        _timer = threading.Timer(REAPPLY_DELAY, reapply_wallpaper)
        _timer.daemon = True
        _timer.start()


def main():
    global _fullscreen
    instance = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not instance:
        print("HYPRLAND_INSTANCE_SIGNATURE not set")
        return

    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    socket_path = f"{runtime_dir}/hypr/{instance}/.socket2.sock"

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(socket_path)

    threading.Thread(target=rotate_loop, daemon=True).start()

    buf = b""
    while True:
        data = sock.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            event = line.decode("utf-8", errors="ignore").strip()
            name = event.split(">>", 1)[0]

            if event == "fullscreen>>1":
                _fullscreen = True
                signal_mpvpaper(signal.SIGSTOP)
            elif event == "fullscreen>>0":
                _fullscreen = False
                signal_mpvpaper(signal.SIGCONT)
            elif name in ("monitoradded", "monitorremoved"):
                schedule_reapply()


if __name__ == "__main__":
    main()
