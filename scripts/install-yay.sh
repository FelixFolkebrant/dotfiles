#!/usr/bin/env bash

set -Eeuo pipefail

if command -v yay >/dev/null 2>&1; then
  echo "[✓] yay is already installed."
  exit 0
fi

build_dir=$(mktemp -d --tmpdir yay-build.XXXXXXXX)
trap 'rm -rf -- "$build_dir"' EXIT

echo "[*] Building yay..."
git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
(
  cd "$build_dir/yay"
  makepkg -si --noconfirm
)
