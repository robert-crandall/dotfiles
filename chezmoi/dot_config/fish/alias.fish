# ruby
alias aliases="cat ~/.config/fish/alias.fish"
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

# papercuts
alias which "type -a"

abbr rm "rm -i"
abbr cp "cp -i"
abbr mv "mv -i"
abbr mkdir "mkdir -p"
abbr h "history"
abbr ls "ls -laG"

# misc
alias reload='exec fish'
