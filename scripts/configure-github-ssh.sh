#!/usr/bin/env bash

set -Eeuo pipefail

ssh_dir="$HOME/.ssh"
mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"

shopt -s nullglob
public_keys=("$ssh_dir"/*.pub)

if ((${#public_keys[@]} == 0)); then
  default_email=$(git config --global user.email 2>/dev/null || true)
  read -r -p "GitHub email${default_email:+ [$default_email]}: " github_email
  github_email=${github_email:-$default_email}

  if [[ -z $github_email ]]; then
    echo "An email label is required to create the SSH key." >&2
    exit 1
  fi

  key_path="$ssh_dir/id_ed25519"
  echo "[*] Creating $key_path (you will be prompted for a passphrase)..."
  ssh-keygen -t ed25519 -C "$github_email" -f "$key_path"
  public_keys=("$key_path.pub")
else
  echo "[✓] Found existing public SSH key(s); no key was overwritten."
fi

echo
echo "Public key(s) safe to add to GitHub:"
for public_key in "${public_keys[@]}"; do
  echo
  echo "--- $public_key"
  cat "$public_key"
done

if command -v wl-copy >/dev/null 2>&1 && [[ -n ${WAYLAND_DISPLAY:-} ]]; then
  wl-copy <"${public_keys[0]}"
  echo
  echo "The first public key was copied to the clipboard."
fi

echo
echo "Add the key at: https://github.com/settings/ssh/new"
read -r -p "Press Enter after adding it to GitHub; authentication will be tested next."

echo "[*] Testing GitHub SSH authentication..."
ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true
