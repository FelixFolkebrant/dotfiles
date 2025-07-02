#!/usr/bin/env bash

set -e
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

declare -A plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  [powerlevel10k]="https://github.com/romkatv/powerlevel10k.git"
  # Add more plugins here
)

for plugin in "${!plugins[@]}"; do
  plugin_dir="$ZSH_PLUGIN_DIR/$plugin"
  if [[ ! -d "$plugin_dir" ]]; then
    echo "[*] Cloning $plugin..."
    git clone --depth=1 "${plugins[$plugin]}" "$plugin_dir"
  else
    echo "[✓] $plugin already installed."
  fi
done

