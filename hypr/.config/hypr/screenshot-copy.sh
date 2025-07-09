#!/bin/bash

#!/bin/bash

# Screenshot folder and save path
shot_dir="$HOME/Pictures/Screenshots"
latest_path="$shot_dir/latest.png"

# Ensure screenshot folder exists
mkdir -p "$shot_dir"

# Temp file
img_path=$(mktemp --suffix=.png)

# Take screenshot with selection
grim -g "$(slurp)" "$img_path"

# Copy to clipboard
cat "$img_path" | wl-copy

# Save as 'latest.png'
cp "$img_path" "$latest_path"

# Notify
notify-send "Screenshot Taken" "Copied to clipboard"

# Cleanup
rm "$img_path"

