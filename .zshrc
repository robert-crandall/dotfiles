# Derive dotfiles directory from this file's location (resolves symlinks)
export DOTFILES="${${(%):-%x}:A:h}"

# Source all zsh/*.zsh files (aliases, functions, exports)
for f in "$DOTFILES/zsh/"*.zsh; do
  [[ -r "$f" ]] && source "$f"
done
unset f

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Mac-only enhancements (skipped silently in Codespaces)
if [[ -z "$CODESPACES" ]]; then
  # Syntax highlighting — valid commands green, invalid red
  [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Autosuggestions — accept suggestion with →
  [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # Starship prompt
  command -v starship &>/dev/null && eval "$(starship init zsh)"
fi
