#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_DIR"

# Keep this list explicit. Globbing every directory previously caused untracked
# data (including the entire VS Code extensions directory) to be stowed.
home_packages=(
  bin
  eww
  gitconfig
  hypr
  kitty
  mako
  nvim
  vscode
  wallpapers
  waybar
  wofi
  zsh
)

for package in "${home_packages[@]}" keyd; do
  if [[ ! -d $package ]]; then
    echo "Missing stow package: $REPO_DIR/$package" >&2
    exit 1
  fi
done

echo "[*] Checking home-directory stow conflicts..."
if ! stow --simulate --verbose=1 --no-folding --restow \
  --target="$HOME" "${home_packages[@]}"; then
  cat >&2 <<'EOF'

Stow found existing files that it does not own. Nothing from this invocation
was changed. Move the reported files to a backup directory and rerun setup.
Do not use --adopt here: --adopt moves those files into the Git repository and
can overwrite the versions you intended to install.
EOF
  exit 1
fi

stow --no-folding --restow --target="$HOME" "${home_packages[@]}"

echo "[*] Checking system stow conflicts..."
sudo stow --simulate --verbose=1 --no-folding --restow --target=/ keyd
sudo stow --no-folding --restow --target=/ keyd
