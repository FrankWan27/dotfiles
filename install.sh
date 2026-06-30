#!/usr/bin/env bash
# Symlinks dotfiles to their target locations, backing up any existing file.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Map of repo-relative source -> target path.
link() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "Backing up existing $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "Linked $dest -> $src"
}

link ".zshrc" "$HOME/.zshrc"
link "wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

echo "Done."
