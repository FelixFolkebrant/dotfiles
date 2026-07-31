#!/bin/bash

# Restart Waybar
pkill waybar
waybar &

# Reload the on-screen display so its stylesheet and widget definitions update.
if command -v eww >/dev/null 2>&1; then
  eww kill 2>/dev/null || true
  eww daemon
  eww open osd
fi

# Restart hyprland

hyprctl reload
