#!/bin/zsh

if [[ "$(uname)" != "Darwin" ]]; then
  return
fi

if command -v brew >/dev/null 2>&1 && brew --prefix asdf >/dev/null 2>&1; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
else
  echo "brew or asdf not found"
fi

export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
