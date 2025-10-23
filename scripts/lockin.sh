

#!/bin/bash
STATEFILE="/tmp/hypr-fulltile"

enable_mode() {
  # Kill bar + wallpaper
  pkill waybar 2>/dev/null
  pkill hyprpaper 2>/dev/null

  # Static background color (#2b2b2b)
  hyprctl keyword misc:background_color "0xff2b2b2b"


  # Your “full-tiling” aesthetics
  hyprctl keyword decoration:shadow:enabled false
  hyprctl keyword general:gaps_in 0
  hyprctl keyword general:gaps_out 0
  hyprctl keyword general:border_size 0
  hyprctl keyword decoration:rounding 0
}

disable_mode() {
  # Reload brings back your original animations (incl. workspace ones)
  hyprctl reload

  # Restore wallpaper and bar
  hyprpaper &
  waybar &
}

if [ ! -f "$STATEFILE" ]; then
  enable_mode
  echo on > "$STATEFILE"
else
  disable_mode
  rm -f "$STATEFILE"
fi


