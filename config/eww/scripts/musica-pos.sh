#!/usr/bin/env bash
# Progreso de la canción actual en % (0 si no hay nada o es un stream sin duración).
playerctl -p playerctld metadata --format '{{position}} {{mpris:length}}' 2>/dev/null |
    awk '{ if ($2 > 0) printf "%d\n", $1 * 100 / $2; else print 0 } END { if (NR == 0) print 0 }'
