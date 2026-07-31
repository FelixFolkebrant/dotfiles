

#!/usr/bin/env bash

set -Eeuo pipefail

STATEFILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-fulltile-${UID}"

is_enabled() {
  [[ $(hyprctl getoption general:gaps_out) == *"css gap data: 0 0 0 0"* ]]
}

enable_mode() {
  pkill waybar 2>/dev/null || true
  pkill hyprpaper 2>/dev/null || true

  # Full-tiling aesthetics. Lua config sessions require eval rather than the
  # legacy `keyword` command. These runtime overrides are reset by a reload.
  hyprctl eval '
    hl.config({
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        extend_border_grab_area = 0,
      },
      decoration = {
        rounding = 0,
        shadow = {enabled = false},
      },
    })
  '
}

disable_mode() {
  hyprctl reload

  pgrep -x hyprpaper >/dev/null || hyprpaper >/dev/null 2>&1 &
  pgrep -x waybar >/dev/null || waybar >/dev/null 2>&1 &
}

if is_enabled; then
  disable_mode
  rm -f -- "$STATEFILE"
else
  enable_mode
  printf 'on\n' >"$STATEFILE"
fi
