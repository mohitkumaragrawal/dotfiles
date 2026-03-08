# dotfiles

Personal dotfiles for:

- tmux
- WezTerm
- Ghostty
- Yazi
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

## Neovim history

This repository is intended to keep the original history from the standalone
Neovim repo by importing it into `.config/nvim`.
