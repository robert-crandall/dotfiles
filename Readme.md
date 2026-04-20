# Dotfiles

Shell config for Mac and GitHub Codespaces. Shared aliases/functions load everywhere; Mac gets Starship, syntax highlighting, and autosuggestions on top.

## Structure

```
dotfiles/
  zsh/
    aliases.zsh       # shell + github.com dev aliases
    exports.zsh       # PATH, env vars (Bun, Go, rbenv, mise)
    dependencies.zsh  # tool paths (PostgreSQL, asdf)
    prs.zsh           # git branch/file utilities
    test_pr.zsh       # PR test runners
    start_server.zsh  # dev server helpers
  .zshrc              # entry point; sources zsh/* and loads Mac plugins
  .zprofile           # login shell (Homebrew init)
  starship.toml       # prompt config
  install.sh          # Mac setup: brew install + symlinks (idempotent)
  install-codespaces.sh  # Codespaces: symlinks only
```

## Setup

**Mac:**
```sh
cd ~/repos/dotfiles
./install.sh
```

**Codespaces:** runs automatically via `install-codespaces.sh`.

## Notes

- Mac plugins (`zsh-syntax-highlighting`, `zsh-autosuggestions`, Starship) install via Homebrew and are skipped silently in Codespaces.
- Adding a new `.zsh` file to `zsh/` activates it automatically — no need to edit `.zshrc`.
- For Ruby setup on Mac: https://mac.install.guide/rubyonrails/1

