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

