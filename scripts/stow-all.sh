#!/bin/bash

set -e

for dir in */; do
  [[ "$dir" == "scripts/" ]] && continue
  if [[ -d "$dir/etc" ]]; then
    sudo stow -t / "$dir"
  else
    stow -R "${dir%/}"
  fi
done

