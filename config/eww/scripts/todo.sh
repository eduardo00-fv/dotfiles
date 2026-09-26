#!/usr/bin/env bash
# To-do del escritorio. Archivo de texto plano: una tarea por línea,
# "x " al inicio = hecha. Se puede editar a mano: ~/.local/share/todo/todo.txt
#
# Uso: todo.sh [json]         lista en JSON (para eww)
#      todo.sh add [texto]    agrega (sin texto: pregunta con rofi)
#      todo.sh toggle N       marca/desmarca la tarea N (desde 1)
#      todo.sh clean          borra las hechas
#      todo.sh edit           abre el archivo en el editor
set -u
FILE="$HOME/.local/share/todo/todo.txt"
mkdir -p "${FILE%/*}"; touch "$FILE"

refrescar() { eww update todo="$("$0" json)" >/dev/null 2>&1; }

case "${1:-json}" in
json)
    python3 - "$FILE" <<'PY'
import json, sys
items = []
for i, l in enumerate(open(sys.argv[1], encoding="utf-8").read().splitlines(), 1):
    if not l.strip():
        continue
    hecha = l.startswith("x ")
    items.append({"n": i, "texto": l[2:] if hecha else l, "hecha": hecha})
# pendientes primero, luego las hechas
items.sort(key=lambda t: t["hecha"])
print(json.dumps({"items": items[:4], "pendientes": sum(not t["hecha"] for t in items),
                  "hechas": sum(t["hecha"] for t in items), "extra": max(0, len(items) - 4)},
                 ensure_ascii=False))
PY
    ;;
add)
    shift
    texto="${*:-}"
    [ -z "$texto" ] && texto=$(rofi -dmenu -p "Nueva tarea" -lines 0 -theme-str 'listview {enabled: false;}' < /dev/null)
    texto=$(printf '%s' "$texto" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -n "$texto" ] && printf '%s\n' "$texto" >> "$FILE"
    refrescar ;;
toggle)
    n="${2:?falta N}"
    sed -i "${n}{s/^x //;t;s/^/x /}" "$FILE"
    refrescar ;;
clean)
    sed -i '/^x /d;/^[[:space:]]*$/d' "$FILE"
    refrescar ;;
edit)
    kitty -e "${EDITOR:-nano}" "$FILE" && refrescar ;;
esac
