#!/usr/bin/env bash

set -Eeuo pipefail

readonly eww_bin="eww"
readonly runtime_dir="${XDG_RUNTIME_DIR:-/tmp}/eww-osd-${UID}"
readonly generation_file="${runtime_dir}/generation"

mkdir -p -m 700 "$runtime_dir"

usage() {
  echo "Usage: ${0##*/} {volume|brightness}" >&2
  exit 64
}

volume_osd() {
  local state value muted icon
  state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  value=$(awk '/Volume:/ { printf "%d", ($2 * 100) + 0.5 }' <<<"$state")
  muted=false
  [[ $state == *"[MUTED]"* ]] && muted=true

  if $muted; then
    icon="󰝟"
    value=0
  elif (( value == 0 )); then
    icon="󰖁"
  elif (( value < 34 )); then
    icon="󰕿"
  elif (( value < 67 )); then
    icon="󰖀"
  else
    icon="󰕾"
  fi

  printf '%s\n%s\n' "$icon" "$value"
}

brightness_osd() {
  local value
  value=$(brightnessctl -m | awk -F, 'NR == 1 { gsub(/%/, "", $4); print int($4 + 0.5) }')
  printf '󰃠\n%s\n' "$value"
}

case "${1:-}" in
  volume) mapfile -t osd < <(volume_osd) ;;
  brightness) mapfile -t osd < <(brightness_osd) ;;
  *) usage ;;
esac

# Opening an already-open Eww window replays its revealer. Only open and reveal
# it when needed; subsequent key presses merely change the icon and fraction.
if ! "$eww_bin" active-windows | grep -qE '^[^:]+: osd$'; then
  "$eww_bin" open osd
fi

generation="$(date +%s%N)"
printf '%s\n' "$generation" > "$generation_file"

target=${osd[1]}
"$eww_bin" update "osd_icon=${osd[0]}" "osd_value=${target}"
if [[ $("$eww_bin" get osd_visible) != true ]]; then
  "$eww_bin" update osd_visible=true
fi

# Earlier animations and delayed hides see a different token and leave the
# current OSD visible.
(
  sleep 1.05
  [[ $(<"$generation_file") == "$generation" ]] && "$eww_bin" update osd_visible=false
) &
