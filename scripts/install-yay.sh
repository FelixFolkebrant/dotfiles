#!/usr/bin/env bash

if ! command -v yay &> /dev/null; then
  echo "[*] Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
else
  echo "[✓] yay already installed"
fi

