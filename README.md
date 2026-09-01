# dotfiles

Personal configuration files.

## Contents

| File | Target location | Description |
|------|-----------------|-------------|
| `.zshrc` | `~/.zshrc` | Zsh config: oh-my-zsh, Powerlevel10k theme, plugins (autosuggestions, fast-syntax-highlighting, autocomplete) |
| `.p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k prompt configuration (lean style, 24h clock, nerdfont-v3) |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | WezTerm terminal config: rose-pine-moon theme, Hack Nerd Font, per-OS window styling |

## Install

### Fresh machine (installs everything)

```sh
git clone git@github.com:frankwan27/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
exec zsh
```

`bootstrap.sh` installs the prerequisites on a bare Linux box - zsh, oh-my-zsh,
the Powerlevel10k theme, the three custom plugins, and the MesloLGS NF Nerd Font -
then calls `install.sh` to lay down the symlinks and sets zsh as the default shell.
It's idempotent, so re-running it updates the theme and plugins.

Flags: `--no-chsh` (don't change the default shell), `--no-font` (skip the font download).

### Symlink only (prerequisites already installed)

```sh
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks each file to its target location, backing up any existing
file to `<file>.bak` first.

## Notes

- `.zshrc` expects [oh-my-zsh](https://ohmyz.sh/) and the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme, plus the `zsh-autosuggestions`, `fast-syntax-highlighting`, and `zsh-autocomplete` plugins. `bootstrap.sh` installs all of these.
- After install, set your terminal font to **MesloLGS NF** so the Powerlevel10k glyphs render correctly.
- Machine-specific or work-specific shell setup is kept out of this repo (e.g. in `~/.bashrc`), which `.zshrc` sources locally if present.
- WezTerm config uses the Hack Nerd Font; install it or change the `font` lines.
