#!/bin/zsh

# asdf version manager (fallback if mise is not installed)
ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"
if [[ -f "$ASDF_PATH" ]]; then
  source "$ASDF_PATH"
fi

# PostgreSQL binaries (psql, pg_dump, etc.)
POSTGRES_PATH="/opt/homebrew/opt/postgresql@15/bin"
if [[ -d "$POSTGRES_PATH" ]]; then
  export PATH="$POSTGRES_PATH:$PATH"
fi

# libpq client library
LIBPQ_PATH="/opt/homebrew/opt/libpq/bin"
if [[ -d "$LIBPQ_PATH" ]]; then
  export PATH="$LIBPQ_PATH:$PATH"
fi
