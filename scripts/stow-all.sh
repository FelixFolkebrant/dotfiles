#!/bin/bash

set -e

for dir in */; do
  [[ "$dir" == "scripts/" ]] && continue
  stow -R "${dir%/}"  # -R = restow: unstow first, then stow again
done

echo "✅ Dotfiles stowed successfully. (ignored /scripts)"

