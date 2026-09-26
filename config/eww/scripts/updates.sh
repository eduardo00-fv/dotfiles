#!/usr/bin/env bash
# Actualizaciones pendientes para eww. checkupdates usa una copia temporal de
# la base de datos, así que no toca el sistema ni necesita sudo.
repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(timeout 60 yay -Qua 2>/dev/null | wc -l)
last=$(grep 'starting full system upgrade' /var/log/pacman.log | tail -1 | grep -oE '^\[[^]]+\]' | tr -d '[]')
dias="?"
if [[ -n "$last" ]]; then
    # días de calendario (no horas): ayer 20:15 cuenta como "ayer"
    d=$(( ( $(date -d "$(date +%F)" +%s) - $(date -d "$(date -d "$last" +%F)" +%s) ) / 86400 ))
    case $d in 0) dias="hoy" ;; 1) dias="ayer" ;; *) dias="hace $d días" ;; esac
fi
printf '{"repo":%d,"aur":%d,"total":%d,"ultimo":"%s"}\n' "$repo" "$aur" $(( repo + aur )) "$dias"
