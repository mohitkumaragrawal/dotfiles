# dotfiles

Personal dotfiles for:

- tmux
- Vim
- WezTerm
- btop
- Ghostty
- Yazi
- Zathura
- Neovim

## Install

Run:

```bash
./install.sh
```

For a preview without changing anything:

```bash
./install.sh --dry-run
```

The installer creates symlinks into `$HOME` and moves conflicting files into:

```text
~/.local/state/dotfiles-backups/<timestamp>/
```

On this machine that means your existing standalone `~/.config/nvim` repo will be
backed up first, then replaced with a symlink into this repo.

## Neovim history

This repository is intended to keep the original history from the standalone
Neovim repo by importing it into `.config/nvim`.
