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
end

# Hide greeting
set fish_greeting

# Init Starship
starship init fish | source
