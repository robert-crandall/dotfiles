# ruby
alias aliases="cat ~/.config/zsh/aliases.zsh"
alias ghserver="script/dx/server-start"
alias ghlogs="script/dx/server-logs"
alias ghenterprise="bin/setup --enterprise"
alias ghstop="script/dx/server-stop"
alias ghtest="bin/rails test"
alias emutest="TEST_WITH_ALL_EMUS=1 bin/rails test"
alias ftest="TEST_ALL_FEATURES=1 bin/rails test"
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
