#!/usr/bin/env bash

set -Eeuo pipefail

plugin_root="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$plugin_root"

# Public plugins deliberately use HTTPS. GitHub authentication is only needed
# for pushing this dotfiles repository, not for installing these plugins.
plugins=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|zsh-autosuggestions.zsh"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git|zsh-syntax-highlighting.zsh"
  "powerlevel10k|https://github.com/romkatv/powerlevel10k.git|powerlevel10k.zsh-theme"
  "calc|https://github.com/arzzen/calc.plugin.zsh.git|calc.plugin.zsh"
)

for plugin_spec in "${plugins[@]}"; do
  IFS='|' read -r name url entrypoint <<<"$plugin_spec"
  plugin_dir="$plugin_root/$name"

  if [[ -f "$plugin_dir/$entrypoint" ]]; then
    echo "[✓] $name is already installed."
    continue
  fi

  if [[ -d $plugin_dir ]] && rmdir "$plugin_dir" 2>/dev/null; then
    echo "[!] Removed empty placeholder directory for $name."
  elif [[ -e $plugin_dir ]]; then
    echo "Incomplete plugin directory found at $plugin_dir." >&2
    echo "Move it aside, then rerun this script; it will not delete non-empty data." >&2
    exit 1
  fi

  echo "[*] Cloning $name over HTTPS..."
  git clone "$url" "$plugin_dir"

  if [[ ! -f "$plugin_dir/$entrypoint" ]]; then
    echo "Clone completed, but $entrypoint is missing from $plugin_dir." >&2
    exit 1
  fi
done
