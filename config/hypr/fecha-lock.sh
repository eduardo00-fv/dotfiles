#!/usr/bin/env bash
# Fecha en español y mayúsculas para hyprlock (el sistema no tiene locale es_*).
dias=(DOMINGO LUNES MARTES MIÉRCOLES JUEVES VIERNES SÁBADO)
meses=(ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SEPTIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE)
echo "${dias[$(date +%w)]} · $(date +%-d) DE ${meses[$(( $(date +%-m) - 1 ))]}"
