#!/bin/zsh

##
# Commands, funtions and aliases
#
# Always set aliases _last,_ so they don't get used in function definitions.
#
# These aliases enable us to paste example code into the terminal without the
# shell complaining about the pasted prompt symbol.
alias %= \$=

# Set preferences for default commands
alias ping='ping -c 5'
alias ipe='curl ipinfo.io/ip'
alias reload='exec zsh'
alias df='df -H'
alias du='du -ch'
alias ls='ls -alG'
alias grep='grep --color=auto'
alias untar='tar -zxvf '
alias wget='wget -c '

# confirmation
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias mkdir='mkdir -p'

# Note that, unlike with Bash, you do not need to inform Zsh's completion system
# of your aliases. It will figure them out automatically.

# Set $PAGER if it hasn't been set yet. We need it below.
# `:` is a builtin command that does nothing. We use it here to stop Zsh from
# evaluating the value of our $expansion as a command.
: ${PAGER:=less}

# Associate file name .extensions with programs to open them.
# This lets you open a file just by typing its name and pressing enter.
# Note that the dot is implicit; `gz` below stands for files ending in .gz
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'


# Use `< file` to quickly view the contents of any text file.
READNULLCMD=$PAGER  # Set the program to use for this.
