#!/usr/bin/env bash

set -e

echo "[*] Symlinking configs using stow..."
stow kitty
stow fonts

echo "[*] Running install scripts..."
./scripts/install_fonts.sh

echo "[✔] Setup complete. Restart Kitty to apply the new font."

