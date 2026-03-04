if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Go configuration
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
# Add Go binary path if Go is installed
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# NPM global packages
if command -v npm >/dev/null 2>&1; then
  export PATH="$PATH:$(npm config get prefix)/bin"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Source custom functions from ~/.zsh/functions
if [[ -d "$HOME/.zsh/functions" ]]; then
  for function_file in "$HOME/.zsh/functions"/*; do
    [[ -r "$function_file" ]] && source "$function_file"
  done
fi

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Could try:
# export STARSHIP_CONFIG="${${(%):-%N}:A:h}/starship.toml"
# export STARSHIP_CONFIG="$(dirname "${(%):-%x}")/starship.toml"
export STARSHIP_CONFIG="$HOME/repos/dotfiles/starship.toml"
eval "$(starship init zsh)"
eval "$(~/.local/bin/mise activate)"

# bun completions
[ -s "/Users/robert-crandall/.bun/_bun" ] && source "/Users/robert-crandall/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
export PATH="$(npm prefix -g)/bin:$PATH"
