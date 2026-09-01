#!/usr/bin/env bash
#
# bootstrap.sh - full fresh-Linux setup for these dotfiles.
#
# install.sh only symlinks the config files and assumes oh-my-zsh, the
# Powerlevel10k theme, the plugins and a Nerd Font are already present.
# bootstrap.sh installs all of those prerequisites first, then calls
# install.sh to lay down the symlinks.
#
# Idempotent: safe to re-run (updates the theme/plugins on repeat runs).
#
# Usage:
#   ./bootstrap.sh            # install prerequisites + symlink dotfiles
#   ./bootstrap.sh --no-chsh  # don't change the default shell
#   ./bootstrap.sh --no-font  # skip the Nerd Font download
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

DO_CHSH=1
DO_FONT=1
for arg in "$@"; do
  case "$arg" in
    --no-chsh) DO_CHSH=0 ;;
    --no-font) DO_FONT=0 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }

# ----------------------------------------------------------------------------
# 1. zsh + git + curl via whatever package manager exists
# ----------------------------------------------------------------------------
install_pkgs() {
  local pkgs=(zsh git curl)
  if   command -v apt-get >/dev/null 2>&1; then sudo apt-get update -y && sudo apt-get install -y "${pkgs[@]}" fontconfig
  elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y "${pkgs[@]}" fontconfig
  elif command -v yum     >/dev/null 2>&1; then sudo yum install -y "${pkgs[@]}" fontconfig
  elif command -v pacman  >/dev/null 2>&1; then sudo pacman -Sy --noconfirm "${pkgs[@]}" fontconfig
  elif command -v zypper  >/dev/null 2>&1; then sudo zypper install -y "${pkgs[@]}" fontconfig
  elif command -v apk     >/dev/null 2>&1; then sudo apk add "${pkgs[@]}" fontconfig
  else warn "No known package manager found. Ensure zsh, git and curl are installed."
  fi
}

log "Installing zsh, git, curl..."
install_pkgs
command -v zsh >/dev/null 2>&1 || { echo "zsh not on PATH after install; aborting." >&2; exit 1; }

# ----------------------------------------------------------------------------
# 2. oh-my-zsh (unattended, keep the .zshrc this repo installs)
# ----------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh already present; skipping."
fi

# ----------------------------------------------------------------------------
# 3. Powerlevel10k theme + custom plugins
# ----------------------------------------------------------------------------
clone_or_pull() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")..."
    git -C "$dest" pull --ff-only --quiet || warn "Could not fast-forward $dest"
  else
    log "Cloning $(basename "$dest")..."
    git clone --depth=1 "$url" "$dest"
  fi
}

clone_or_pull https://github.com/romkatv/powerlevel10k.git                     "$ZSH_CUSTOM/themes/powerlevel10k"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions.git             "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
clone_or_pull https://github.com/marlonrichert/zsh-autocomplete.git            "$ZSH_CUSTOM/plugins/zsh-autocomplete"

# ----------------------------------------------------------------------------
# 4. MesloLGS NF Nerd Font (recommended by Powerlevel10k)
# ----------------------------------------------------------------------------
if [[ "$DO_FONT" -eq 1 ]]; then
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
    log "Installing MesloLGS Nerd Font..."
    base="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for f in "MesloLGS%20NF%20Regular.ttf" "MesloLGS%20NF%20Bold.ttf" \
             "MesloLGS%20NF%20Italic.ttf"  "MesloLGS%20NF%20Bold%20Italic.ttf"; do
      out="$FONT_DIR/$(printf '%b' "${f//%/\\x}")"
      curl -fsSL "$base/$f" -o "$out" || warn "Failed to download $f"
    done
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
  else
    log "MesloLGS Nerd Font already installed; skipping."
  fi
  warn "Set your terminal font to 'MesloLGS NF' for correct Powerlevel10k glyphs."
fi

# ----------------------------------------------------------------------------
# 5. Symlink the dotfiles (delegates to install.sh - single source of truth)
# ----------------------------------------------------------------------------
log "Symlinking dotfiles..."
"$DOTFILES_DIR/install.sh"

# ----------------------------------------------------------------------------
# 6. Make zsh the default shell
# ----------------------------------------------------------------------------
if [[ "$DO_CHSH" -eq 1 ]]; then
  zsh_path="$(command -v zsh)"
  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    log "Setting default shell to $zsh_path (may prompt for password)..."
    if grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
      chsh -s "$zsh_path" || warn "chsh failed; run 'chsh -s $zsh_path' manually."
    fi
  else
    log "zsh already the default shell."
  fi
fi

log "Done. Start a new shell:  exec zsh"
