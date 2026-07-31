#!/usr/bin/env bash

set -Eeuo pipefail

if ! command -v gsettings >/dev/null 2>&1; then
  echo "gsettings is unavailable; install glib2 before configuring dark mode." >&2
  exit 1
fi

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

echo "[✓] GTK/GNOME applications now prefer the Adwaita dark theme."
