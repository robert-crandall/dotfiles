alias zshreload='source ~/.zshrc'             # reload ZSH

# Stats
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias ping='ping -c 5'
alias speed='speedtest-cli --single'
alias ipe='curl ipinfo.io/ip'
alias ports='netstat -tulanp'

# Program overrides and shortcuts
alias df='df -H'
alias du='du -ch'

# files
alias grep='grep --color=auto'
alias untar='tar -zxvf '
alias wget='wget -c '

alias getpass="openssl rand -base64 28"
alias sha='shasum -a 256 '

# confirmation #
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias mkdir='mkdir -p'

# ruby
alias aliases='cat ~/.zsh/aliases.zsh'
alias dotfiles='cd ~/.local/share/chezmoi'
alias ghserver="script/dx/server-start"
alias ghlogs="script/dx/server-logs"
alias ghenterprise="bin/setup --enterprise"
alias ghstop="script/dx/server-stop"
alias ghtest="bin/rails test"
alias emutest="env TEST_WITH_ALL_EMUS=1 bin/rails test"
alias ftest="env TEST_ALL_FEATURES=1 bin/rails test"
alias citest="bin/run-failed-ci"
alias bootstrap="script/bootstrap"
alias reset_db="script/setup --force"
alias routes="bin/rails routes > routes.txt"
alias troubleshoot="script/dx/heal --everything"
alias troubleshoot_live="script/server | script/dx/overmind-help --live" # live troubleshooting
alias ghshell="ssh -A gh-shell"
alias fix_sorbet_reset="bin/rails db:reset && bin/tapioca dsl"
alias fix_sorbet="bin/rails db:migrate db:test:soft_reset && bin/tapioca dsl"
alias fix_serviceowners="bin/generate-service-files.rb"