#!/usr/bin/env bash
# Uso de / en JSON. Solo toca /, nunca los automounts de red.
df -B1G --output=pcent,avail / | awk 'NR==2 { gsub(/%/, "", $1); printf "{\"perc\":%d,\"libre\":%d}\n", $1, $2 }'
