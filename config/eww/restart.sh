#!/usr/bin/env bash
# Reinicio limpio de los widgets. `eww reload` en la 0.5.0 deja el daemon
# colgado ("channel closed") y corta los deflisten, así que siempre se reinicia
# entero. También lo usa el autostart de Hyprland.
eww kill >/dev/null 2>&1
pkill -x eww 2>/dev/null
sleep 0.5
rm -f "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/eww-server_*   # socket huérfano
cd "$HOME" || exit 1
setsid eww daemon --no-daemonize >/dev/null 2>&1 < /dev/null &
for _ in $(seq 40); do       # el daemon tarda 5-18 s en abrir el socket
    eww ping >/dev/null 2>&1 && break
    sleep 1
done
# al iniciar sesión el monitor puede tardar en aparecer: reintentar
for _ in $(seq 10); do eww open escritorio >/dev/null 2>&1 && eww active-windows | grep -q escritorio && break; sleep 2; done
