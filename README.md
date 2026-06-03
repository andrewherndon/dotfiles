# dotfiles

Personal machine setup for macOS and Amazon Linux.

## Quick install (non-interactive)

```sh
curl -fsSL andrew.by/setup | bash -s -- --yes
```

## Interactive install

```sh
bash <(curl -fsSL andrew.by/setup)
```

Prompts you to pick which components to install. Enter accepts the default (yes).

## Components

| Component | What it does |
|-----------|-------------|
| Homebrew | Package manager (macOS + Linux) |
| Neovim | Terminal editor via brew |
| LazyVim | Neovim config framework |
| Neovim config | Custom keymaps and plugins (toggleterm, vimtex, leetcode) |
| Oh My Zsh | Zsh framework |
| Zsh config | `.zshrc` symlinked from this repo |

## What gets installed where

```
~/.dotfiles/          ← this repo, cloned during install
~/.config/nvim/       ← LazyVim starter + custom config layered on top
~/.zshrc              ← symlink → ~/.dotfiles/.zshrc
```

## Idempotent

Safe to re-run. Each step checks before acting — already-installed components are skipped, not overwritten. Re-running also pulls the latest dotfiles before applying.
