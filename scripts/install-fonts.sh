#!/usr/bin/env bash

set -e

FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="JetBrainsMono"
ZIP_NAME="JetBrainsMono.zip"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${ZIP_NAME}"

echo "[*] Creating font directory at $FONT_DIR"
mkdir -p "$FONT_DIR"

echo "[*] Downloading JetBrains Mono Nerd Font..."
curl -L -o "$FONT_DIR/$ZIP_NAME" "$URL"

echo "[*] Extracting..."
unzip -o "$FONT_DIR/$ZIP_NAME" -d "$FONT_DIR"
rm "$FONT_DIR/$ZIP_NAME"

echo "[*] Refreshing font cache..."
fc-cache -fv

echo "[✔] JetBrains Mono Nerd Font installed!"

