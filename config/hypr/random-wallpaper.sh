#!/bin/bash
# Wallpaper de Hyprland: foto fija en alta resolución en TODOS los monitores.
#
# Toma todas las .jpg/.png de ~/Pictures/Walpapers/fotos (para agregar una,
# basta con dejarla ahí, idealmente a 3840x2160). La misma imagen se usa en el
# lock screen vía el symlink lockscreen-active.jpg.
#
# (La versión con live wallpaper en vídeo está en
#  random-wallpaper.sh.video-20260926, por si se quiere volver.)
#
# Es idempotente y se puede re-ejecutar en caliente. wallpaper-daemon.py lo
# llama con --reapply en monitoradded/monitorremoved y sin args cada 30 min.
#
# Dos modos: "fotos" (~/Pictures/Walpapers/fotos) y "degradados"
# (~/Pictures/Walpapers/degradados, generados con generar.py en la paleta).
# El modo se guarda en ~/.config/hypr/wallpaper-mode y sobrevive reinicios.
#
# Uso: random-wallpaper.sh [--reapply | --toggle-mode]
#   (sin args) saca la siguiente foto de la "bolsa" barajada: no repite
#              hasta haber pasado por todas. Lo usan el login, Super+W y la
#              rotación cada 30 min de wallpaper-daemon.py
#   --reapply  reutiliza la foto actual en vez de sortear otra
#   --toggle-mode  cambia entre fotos y degradados y pone uno del modo nuevo (Super+Shift+W)

set -u

WALL_DIR="$HOME/Pictures/Walpapers"
LOCK_LINK="$WALL_DIR/lockscreen-active.jpg"
MODE_FILE="$HOME/.config/hypr/wallpaper-mode"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/wallpaper"
STATE_FILE="$STATE_DIR/current"
mkdir -p "$STATE_DIR"

mode=fotos
[ -s "$MODE_FILE" ] && read -r mode < "$MODE_FILE"
[ "$mode" = degradados ] || mode=fotos
if [ "${1:-}" = "--toggle-mode" ]; then
    if [ "$mode" = fotos ]; then mode=degradados; else mode=fotos; fi
    printf '%s\n' "$mode" > "$MODE_FILE"
    notify-send -a Wallpaper -t 2000 "Fondos: $mode"
fi
PHOTO_DIR="$WALL_DIR/$mode"
BAG_FILE="$STATE_DIR/bag-$mode"

mapfile -t photos < <(find "$PHOTO_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -printf '%f\n' | sort)
[ "${#photos[@]}" -eq 0 ] && { echo "No hay fotos en $PHOTO_DIR" >&2; exit 1; }

current=""
[ -s "$STATE_FILE" ] && read -r current < "$STATE_FILE"

if [ "${1:-}" = "--reapply" ] && [ -n "$current" ] && [ -f "$PHOTO_DIR/$current" ]; then
    photo="$current"
else
    # Bolsa barajada: se rellena cuando se vacía (o si quedó con fotos que ya
    # no están en la carpeta). La primera de la bolsa nueva nunca es la actual.
    mapfile -t bag < <(grep -Fxf <(printf '%s\n' "${photos[@]}") "$BAG_FILE" 2>/dev/null)
    if [ "${#bag[@]}" -eq 0 ]; then
        mapfile -t bag < <(printf '%s\n' "${photos[@]}" | shuf --random-source=/dev/urandom)
        if [ "${bag[0]}" = "$current" ] && [ "${#bag[@]}" -gt 1 ]; then
            bag=("${bag[@]:1}" "${bag[0]}")
        fi
    fi
    photo="${bag[0]}"
    printf '%s\n' "${bag[@]:1}" | sed '/^$/d' > "$BAG_FILE"
    printf '%s\n' "$photo" > "$STATE_FILE"
fi

ln -sf "$PHOTO_DIR/$photo" "$LOCK_LINK"

# Restos de la versión en vídeo: si quedara algún mpvpaper o su watchdog, fuera.
for pidfile in "$STATE_DIR"/watchdog-*.pid; do
    [ -e "$pidfile" ] || continue
    kill "$(cat "$pidfile")" 2>/dev/null
    rm -f "$pidfile"
done
pkill -CONT -x mpvpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null

# El nuevo swaybg arranca antes de matar los viejos para que no haya parpadeo.
old_bg=$(pgrep -x swaybg)
swaybg -o '*' -i "$PHOTO_DIR/$photo" -m fill &
sleep 0.7
[ -n "$old_bg" ] && kill $old_bg 2>/dev/null
exit 0
