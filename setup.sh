#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$REPO_DIR"

if [[ $EUID -eq 0 ]]; then
  echo "Please run this script as your normal user, not as root." >&2
  exit 1
fi

read_package_file() {
  local package_file=$1
  sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$package_file"
}

echo "[*] Requesting sudo access..."
sudo -v

echo "[*] Installing official packages..."
mapfile -t official_packages < <(read_package_file packages.txt)
sudo pacman -S --noconfirm --needed -- "${official_packages[@]}"

echo "[*] Configuring locale..."
bash scripts/locale.sh

read -r -p "Configure a GitHub SSH key now? [Y/n]: " configure_ssh
if [[ ! $configure_ssh =~ ^[Nn]$ ]]; then
  bash scripts/configure-github-ssh.sh
fi

echo "[*] Installing yay..."
bash scripts/install-yay.sh

mapfile -t aur_packages < <(read_package_file aurlist.txt)
if ((${#aur_packages[@]})); then
  echo "[*] Installing required AUR packages..."
  yay -S --noconfirm --needed -- "${aur_packages[@]}"
fi

read -r -p "Install optional desktop applications? [y/N]: " install_optional
if [[ $install_optional =~ ^[Yy]$ ]]; then
  mapfile -t optional_packages < <(read_package_file packages-optional.txt)
  yay -S --noconfirm --needed -- "${optional_packages[@]}"
fi

echo "[*] Creating standard directories..."
mkdir -p "$HOME/dev" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures"

echo "[*] Stowing dotfiles..."
bash scripts/stow-all.sh

echo "[*] Installing Zsh plugins..."
bash scripts/install-zsh-plugins.sh

echo "[*] Applying dark appearance settings..."
bash scripts/configure-dark-mode.sh

echo "[*] Enabling required system services..."
sudo systemctl enable --now \
  NetworkManager.service \
  bluetooth.service \
  keyd.service \
  power-profiles-daemon.service

echo "[*] Refreshing the font cache..."
fc-cache -f

zsh_path=$(command -v zsh)
if [[ ${SHELL:-} != "$zsh_path" ]]; then
  echo "[*] Changing the default shell to Zsh..."
  chsh -s "$zsh_path"
fi

echo
read -r -p "Setup complete. Reboot now? [y/N]: " reboot_choice
case "$reboot_choice" in
  y | Y)
    echo "Rebooting..."
    systemctl reboot
    ;;
  *)
    echo "Not rebooting. Log out and back in before testing keyd, brightness, or the new shell."
    ;;
esac
