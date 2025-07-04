#!/usr/bin/env bash

set -e

echo "Uncommenting needed locales in /etc/locale.gen..."
sudo sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^#\(sv_SE.UTF-8 UTF-8\)/\1/' /etc/locale.gen

echo "Generating locales..."
sudo locale-gen

echo "Setting system locale in /etc/locale.conf..."
sudo tee /etc/locale.conf > /dev/null <<EOF
LANG=en_US.UTF-8
LC_NUMERIC=sv_SE.UTF-8
LC_TIME=sv_SE.UTF-8
LC_MONETARY=sv_SE.UTF-8
LC_PAPER=sv_SE.UTF-8
LC_MEASUREMENT=sv_SE.UTF-8
EOF

echo "Locale configuration complete."
