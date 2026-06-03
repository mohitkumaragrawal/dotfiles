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

The tmux setup vendors the Catppuccin tmux runtime under `.config/tmux` so the
theme works without Git submodules or a separate plugin checkout.

## Install

Run:

```bash
./install.sh
```

If `ya` is installed, the script also runs `ya pkg install` so Yazi flavors and
plugins are bootstrapped after the symlink is created.

For a preview without changing anything:

```bash
./install.sh --dry-run
```

The installer creates symlinks into `$HOME` and moves conflicting files into:

```text
~/.local/state/dotfiles-backups/<timestamp>/
```
