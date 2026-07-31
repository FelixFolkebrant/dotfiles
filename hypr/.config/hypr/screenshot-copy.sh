#!/usr/bin/env bash

set -Eeuo pipefail

# Screenshot folder and save path
shot_dir="$HOME/Pictures/Screenshots"
latest_path="$shot_dir/latest.png"

# Ensure screenshot folder exists
mkdir -p "$shot_dir"

# Temp file
img_path=$(mktemp --suffix=.png)
trap 'rm -f -- "$img_path"' EXIT

# Take screenshot with selection
if ! geometry=$(slurp); then
  exit 0
fi
grim -g "$geometry" "$img_path"

# Copy to clipboard
wl-copy <"$img_path"

# Save as 'latest.png'
cp "$img_path" "$latest_path"

# Notify
notify-send "Screenshot Taken" "Copied to clipboard"
