#!/bin/zsh

alias aliases="cat ~/.config/zsh/functions/aliases.zsh"

# Infrequent commands
alias bootstrap="script/bootstrap"
alias reset_db="script/setup --force"
alias routes="bin/rails routes > routes.txt"
alias troubleshoot="script/dx/heal --everything"
alias troubleshoot_live="script/server | script/dx/overmind-help --live" # live troubleshooting
alias ghshell="ssh -A gh-shell"
alias serviceowners_fix="bin/generate-service-files.rb"

# server commands
alias ghserver="script/dx/server-start"
alias ghlogs="script/dx/server-logs"
alias ghenterprise="bin/setup --enterprise"
alias ghstop="script/dx/server-stop"

# test commands
alias ghtest="bin/rails test"
alias emutest="env TEST_WITH_ALL_EMUS=1 bin/rails test"
alias ftest="env TEST_ALL_FEATURES=1 bin/rails test"
alias mttest="env MULTI_TENANT_ENTERPRISE=1 bin/rails test"
alias citest="bin/run-failed-ci"
# Other commands: test_pr, test_pr_emu, test_pr_features, test_pr_all, all_tests (file)

alias sorbet_reset="bin/rails db:reset && bin/tapioca dsl"
alias sorbet_reset_long="bin/rails db:migrate db:test:soft_reset && bin/tapioca dsl"
alias sorbet_run="SRB_SKIP_GEM_RBIS=1 bin/srb tc"
alias sorbet_run_correct="SRB_SKIP_GEM_RBIS=1 bin/srb tc -a"

# misc
alias reload='exec zsh'
