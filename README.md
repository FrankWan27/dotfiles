# dotfiles

Personal configuration files.

## Contents

| File | Target location | Description |
|------|-----------------|-------------|
| `.zshrc` | `~/.zshrc` | Zsh config: oh-my-zsh, Powerlevel10k theme, plugins (autosuggestions, fast-syntax-highlighting, autocomplete) |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | WezTerm terminal config: rose-pine-moon theme, Hack Nerd Font, per-OS window styling |

## Install

```sh
git clone git@github.com:frankwan27/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks each file to its target location, backing up any existing file to `<file>.bak` first.

## Notes

- `.zshrc` expects [oh-my-zsh](https://ohmyz.sh/) and the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme to be installed, plus the `zsh-autosuggestions`, `fast-syntax-highlighting`, and `zsh-autocomplete` plugins.
- Machine-specific or work-specific shell setup is kept out of this repo (e.g. in `~/.bashrc`), which `.zshrc` sources locally if present.
- WezTerm config uses the Hack Nerd Font; install it or change the `font` lines.
