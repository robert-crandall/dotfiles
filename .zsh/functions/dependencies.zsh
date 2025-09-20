#!/bin/zsh

ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"

# Lazy load ASDF to improve startup time
if [[ -f "$ASDF_PATH" ]]; then
    asdf() {
        unfunction asdf
        source "$ASDF_PATH"
        asdf "$@"
    }
fi

LIBPQ_PATH="/opt/homebrew/opt/libpq/bin"
if [[ -d "$LIBPQ_PATH" ]]; then
    export PATH="$LIBPQ_PATH:$PATH"
fi
