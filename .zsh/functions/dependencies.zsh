#!/bin/zsh

ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"

if [[ -f "$ASDF_PATH" ]]; then
    source "$ASDF_PATH"
fi

LIBPQ_PATH="/opt/homebrew/opt/libpq/bin"
if [[ -d "$LIBPQ_PATH" ]]; then
    export PATH="$LIBPQ_PATH:$PATH"
fi
