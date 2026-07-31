#!/usr/bin/env bash

set -Eeuo pipefail

# Temp file for screenshot
img_path=$(mktemp --suffix=.png)
trap 'rm -f -- "$img_path"' EXIT

# Take screenshot of selected area
if ! geometry=$(slurp); then
  exit 0
fi
grim -g "$geometry" "$img_path"

# Run OCR and copy to clipboard
tesseract "$img_path" - -l swe | wl-copy

notify-send "OCR" "Extracted text copied to clipboard"
