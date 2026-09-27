#!/bin/bash
# Barras ▁▂▃▄▅▆▇█ para la waybar; línea vacía (módulo oculto) cuando hay silencio
exec cava -p ~/.config/cava/config-waybar | sed -u 's/;//g; s/^0*$//; y/01234567/▁▂▃▄▅▆▇█/'
