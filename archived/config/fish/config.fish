source ~/.config/fish/alias.fish
source ~/.config/fish/env.fish

# Map Ctrl-x to clear
bind \cx 'clear; commandline -f repaint'

if status is-interactive
    # Commands to run in interactive sessions can go here
    base16-snazzy
end

if test -f "/opt/homebrew/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    set -Ux fish_user_paths $fish_user_paths /usr/local/opt/mysql-client/bin
    # fish_add_path /opt/homebrew/opt/libpq/bin # Unsure if I need this
    set -Ux fish_user_paths $fish_user_paths /Users/robert-crandall/.asdf/shims
end

# Hide greeting
set fish_greeting

# Init Starship
starship init fish | source


# ASDF 
# Configuration for asdf should always be the last line in the ~/.zshrc file, after setting any $PATH configuration. - https://mac.install.guide/ruby/5
# Trying fisher install rstacruz/fish-asdf instead
# if test -e /opt/homebrew/opt/asdf/libexec/asdf.fish
#     source /opt/homebrew/opt/asdf/libexec/asdf.fish
# end
