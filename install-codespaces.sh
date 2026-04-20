#!/usr/bin/env zsh
# Codespaces dotfiles setup — symlinks only, no package installs

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"

echo "✅ Dotfiles linked."
