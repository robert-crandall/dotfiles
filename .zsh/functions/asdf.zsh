#!/bin/zsh

ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"

if [[ -f "$ASDF_PATH" ]]; then
    source "$ASDF_PATH"
fi
