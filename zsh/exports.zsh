# PATH and environment variables

# Starship config — points to dotfiles repo (set after $DOTFILES is available)
export STARSHIP_CONFIG="$DOTFILES/starship.toml"

# JetBrains license server
export JETBRAINS_LICENSE_SERVER=https://github.jetbrains-ide-services.com

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ ":$PATH:" != *":$BUN_INSTALL/bin:"* ]] && export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# Go
export GOPATH="$HOME/go"
[[ ":$PATH:" != *":$GOPATH/bin:"* ]] && export PATH="$PATH:$GOPATH/bin"

# rbenv
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init - zsh)"
fi

# mise (version manager — handles Node, Ruby, Python, etc.)
if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

# Tailscale CLI
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
