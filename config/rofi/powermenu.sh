#!/usr/bin/env bash

lock="  Lock"
suspend="  Suspend"
reboot="  Reboot"
shutdown="  Shutdown"
logout="  Logout"

chosen=$(printf "%s\n%s\n%s\n%s\n%s" "$lock" "$suspend" "$logout" "$reboot" "$shutdown" \
    | rofi -dmenu -p "power" -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    "$lock")     hyprlock ;;
    "$suspend")  systemctl suspend ;;
    "$reboot")   systemctl reboot ;;
    "$shutdown")  systemctl poweroff ;;
    "$logout")   hyprctl dispatch 'hl.dsp.exit()' ;;
esac
