#!/usr/bin/env bash
# Frase al azar para el lock screen (hyprlock la llama cada pocos minutos).
grep -v '^\s*#' "$HOME/.config/hypr/frases-thrain.txt" | grep -v '^\s*$' | shuf -n1 --random-source=/dev/urandom
