#!/bin/bash

# Restart Waybar
pkill waybar
waybar &

# Restart hyprland

hyprctl reload
