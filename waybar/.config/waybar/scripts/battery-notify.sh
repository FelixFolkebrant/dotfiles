#!/bin/bash

# Get battery info
capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null)

# Create notification tracking files
NOTIFY_DIR="/tmp/waybar-battery"
mkdir -p "$NOTIFY_DIR"
NOTIFIED_20="$NOTIFY_DIR/notified_20"
NOTIFIED_10="$NOTIFY_DIR/notified_10"

# Only send notifications when discharging
if [[ "$status" == "Discharging" ]]; then
    if [[ $capacity -le 10 && ! -f "$NOTIFIED_10" ]]; then
        notify-send -u critical "Battery Critical" "Battery level: ${capacity}% - Please charge immediately!"
        touch "$NOTIFIED_10"
        rm -f "$NOTIFIED_20" # Reset 20% flag for next discharge cycle
    elif [[ $capacity -le 20 && ! -f "$NOTIFIED_20" ]]; then
        notify-send -u normal "Battery Low" "Battery level: ${capacity}% - Consider charging soon"
        touch "$NOTIFIED_20"
    fi
else
    # Reset notification flags when charging/full
    rm -f "$NOTIFIED_20" "$NOTIFIED_10"
fi
