

#!/bin/bash
STATEFILE="/tmp/hypr-fulltile"

enable_mode() {
  # Kill bar + wallpaper
  pkill waybar 2>/dev/null

  # Static background color (#2b2b2b)
  hyprctl keyword misc:background_color "0xff2b2b2b"


  # Your “full-tiling” aesthetics
  hyprctl keyword decoration:shadow:enabled true
  hyprctl keyword general:gaps_in 0
  hyprctl keyword general:gaps_out 0
  hyprctl keyword general:border_size 0
  hyprctl keyword decoration:rounding 0

  # Use faster workspace transitions while locked in
  hyprctl keyword animation "workspaces, 1, 2, default"
  hyprctl keyword animation "workspacesIn, 1, 2, default"
  hyprctl keyword animation "workspacesOut, 1, 2, default"

  # Use a faster transition when opening a window
  hyprctl keyword animation "windowsIn, 1, 1, default"
  hyprctl keyword animation "fadeIn, 1, 1, default"

  # Use a faster transition when closing a window
  hyprctl keyword animation "windowsOut, 1, 1, popin"
  hyprctl keyword animation "fadeOut, 1, 1, popout"
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
