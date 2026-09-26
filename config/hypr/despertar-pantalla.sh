#!/usr/bin/env bash
# Tras despertar, el kernel devuelve la consola a Hyprland (VT switch por el driver
# de NVIDIA) y en despertares alternos las salidas quedan apagadas aunque Hyprland
# las crea encendidas (dpmsStatus 1), así que un "dpms on" solo no hace nada.
# Apagar y prender fuerza un modeset real, igual que suspender por segunda vez.
# Ojo: un "on" menos de ~1 s después del "off" se ignora; por eso la espera y
# los reintentos hasta que todas las pantallas reporten dpmsStatus 1.
sleep 1
hyprctl dispatch 'hl.dsp.dpms("off")' >/dev/null
sleep 1.2
for _ in 1 2 3 4 5 6; do
    hyprctl dispatch 'hl.dsp.dpms("on")' >/dev/null
    sleep 1
    hyprctl monitors | grep -q 'dpmsStatus: 0' || exit 0
done
