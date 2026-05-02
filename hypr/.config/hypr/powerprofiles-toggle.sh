#!/bin/sh
# Toggle power profile between performance and power-saver using powerprofilesctl
# Location: ~/.config/hypr/powerprofiles-toggle.sh

current=$(powerprofilesctl get 2>/dev/null || echo unknown)

case "$current" in
  performance)
    powerprofilesctl set power-saver && notify-send "Power mode: Power Save"
    ;;
  "power-saver"|powersave)
    powerprofilesctl set balanced && notify-send "Power mode: Balanced"
    ;;
  balanced)
    powerprofilesctl set performance && notify-send "Power mode: Performance"
    ;;
  balanced|battery|unknown)
    powerprofilesctl set performance && notify-send "Power mode: Performance"
    ;;
  *)
    powerprofilesctl set performance && notify-send "Power mode: Performance"
    ;;
esac
