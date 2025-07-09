#!/bin/bash

# Temp file for screenshot
img_path=$(mktemp --suffix=.png)

# Take screenshot of selected area
grim -g "$(slurp)" "$img_path"

# Run OCR and copy to clipboard
tesseract "$img_path" - -l swe | wl-copy

# Remove temp image
rm "$img_path"

notify-send "OCR" "Extracted text copied to clipboard"
