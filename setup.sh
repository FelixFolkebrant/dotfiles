#!/usr/bin/env bash

set -e

# 1. Install yay if needed
bash scripts/install-yay.sh

# 2. Install official packages
echo "[*] Installing official packages..."
sudo pacman -S --noconfirm --needed $(< packages.txt)

# 3. Install AUR packages
echo "[*] Installing AUR packages..."
yay -S --noconfirm --needed $(< aurlist.txt)

# 4. Create standard folders
xdg-user-dirs-update

# 5. Run your dotfiles install script
./install.sh

echo "[✔] Full setup complete!"

