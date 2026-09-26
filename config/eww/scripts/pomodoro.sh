#!/usr/bin/env bash
# Vista de solo lectura del pomodoro para eww. NO avanza de fase: eso lo hace
# `pomodoro status` desde la waybar; si ambos avanzaran se saltarían fases.
STATE="stopped"; PHASE="work"; SESSION=1; REMAINING=1500; END_EPOCH=0
[[ -f /tmp/pomodoro.state ]] && source /tmp/pomodoro.state
case "$PHASE" in
    work) label="Trabajo"; total=1500 ;;
    shortbreak) label="Descanso corto"; total=300 ;;
    longbreak) label="Descanso largo"; total=900 ;;
esac
if [[ "$STATE" == "running" ]]; then
    REMAINING=$(( END_EPOCH - $(date +%s) )); (( REMAINING < 0 )) && REMAINING=0
elif [[ "$STATE" == "stopped" ]]; then
    REMAINING=1500; total=1500
fi
printf '{"estado":"%s","fase":"%s","etiqueta":"%s","sesion":%d,"tiempo":"%02d:%02d","progreso":%d}\n' \
    "$STATE" "$PHASE" "$label" "$SESSION" $(( REMAINING / 60 )) $(( REMAINING % 60 )) \
    $(( (total - REMAINING) * 100 / total ))
