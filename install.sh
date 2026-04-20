#!/usr/bin/env zsh
# Mac dotfiles setup — idempotent
# Run from the dotfiles repo directory: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Homebrew check ────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  print "❌ Homebrew not found. Install from https://brew.sh first, then re-run this script."
  exit 1
fi

# ── Install zsh plugins + Starship ────────────────────────────────────────────
print "📦 Installing zsh plugins and Starship..."
brew install zsh-syntax-highlighting zsh-autosuggestions starship

# ── Symlink helper ────────────────────────────────────────────────────────────
_symlink() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    print "✅ Already linked: $dst"
    return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    read "confirm?⚠️  $dst exists and is not a symlink. Overwrite? [y/N] "
    [[ "$confirm" =~ ^[Yy]$ ]] || { print "⏭  Skipped: $dst"; return; }
    rm "$dst"
  fi
  ln -sf "$src" "$dst"
  print "🔗 Linked: $dst"
}

# ── Shell config ──────────────────────────────────────────────────────────────
_symlink "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
_symlink "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"

# ── Git config ────────────────────────────────────────────────────────────────
_symlink "$DOTFILES_DIR/.gitconfig"        "$HOME/.gitconfig"
_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
touch "$HOME/.gitconfig-macos"
_symlink "$DOTFILES_DIR/gitconfig-macos"   "$HOME/.gitconfig-macos"

# ── VSCode settings ───────────────────────────────────────────────────────────
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
if [[ -d "$VSCODE_DIR" ]]; then
  _symlink "$DOTFILES_DIR/vscode-settings.jsonc" "$VSCODE_DIR/settings.json"
fi

# ── SSH ───────────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.ssh/sockets"
chmod 0700 "$HOME/.ssh/sockets"

print ""
print "✅ Done! Open a new terminal or run: exec zsh"
