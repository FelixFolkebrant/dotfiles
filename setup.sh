#!/usr/bin/env bash

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "Please don't run as root."
  exit 1
fi

set -e

echo "Configure locale"
bash scripts/locale.sh

echo "installing yay"
bash scripts/install-yay.sh

echo "[*] Installing official packages..."
sudo pacman -S --noconfirm --needed $(< packages.txt)

echo "[*] Installing AUR packages..."
yay -S --noconfirm --needed $(< aurlist.txt)

echo "Creating standard dirs"
mkdir -p ~/dev/  ~/Documents/  ~/Downloads/  ~/Pictures/

echo "Stowing directories"
bash scripts/stow-all.sh

echo Installing zsh plugins
bash scripts/install-zsh-plugins.sh

echo "Installing fonts"
bash scripts/install-fonts.sh

echo "Refreshing font cache..."
fc-cache -fv

echo "Changing default shell to ZSH"
chsh -s /bin/zsh

echo ""
read -p "🚀 Setup complete. Do you want to reboot now? [y/N]: " choice
case "$choice" in
  y|Y )
    echo "Rebooting..."
    systemctl reboot
    ;;
  * )
    echo "Alright, not rebooting. You may need to log out and back in for everything to apply."
    ;;
esac
