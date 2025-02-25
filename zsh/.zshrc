# Source configs
for config_file ($HOME/.zsh/*.zsh); do
  source $config_file
done

# Source functions
for function_file in ~/.zsh/functions/*; do
  source "$function_file"
done

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ `uname` == "Darwin" ]]; then
  source $HOME/.zsh/os/macos.zsh
fi

alias v="nvim"
alias vvim="vim $HOME/.config/nvim/init.vim"
alias svim="source $HOME/.config/nvim/init.vim"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
# Only define `cssh` if the `rdm` binary exists
# https://github.com/BlakeWilliams/remote-development-manager
if [[ -x "$(command -v rdm)" ]]; then
  alias cssh="csw ssh -- -R 127.0.0.1:7391:$(rdm socket)"
fi


alias k="kubectl"

# Map Ctrl-x to clear
bindkey '^X' clear-screen

# Map Ctrl-f to accept suggested completion
bindkey '^F' autosuggest-accept

# Expands symlinks on cd
setopt CHASE_LINKS

