if command -v asdf >/dev/null 2>&1; then
  # Let asdf handle Ruby version management
  . $(brew --prefix asdf)/libexec/asdf.sh
fi

# if [ ! -z "$ARCH" ]; then
# 	RUBIES=(~/.rubies/$ARCH/*)
# fi

selectgem(){
       if [ -z "$1" ]; then
               bundle show | tr -s ' ' | cut -d ' ' -f 3 | fzy
       else
               echo "$1"
       fi
}

gempath() {
       bundle show $(selectgem $1)
}

tmgem() {
       GEM=$(selectgem "$1")
       tmux new-window -c $(bundle show $GEM) -n "$GEM"
}

gemcd() {
       pushd $(gempath "$1")
}

alias be="bundle exec"
alias bi="bundle install"
alias cop-git="git ls-files -m | xargs ls -1 2>/dev/null | grep "\.rb$" | xargs rubocop"
