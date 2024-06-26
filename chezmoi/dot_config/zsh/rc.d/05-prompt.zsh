#!/bin/zsh

##
# Prompt theme
#

# Reduce startup time by making the left side of the primary prompt visible
# *immediately.*
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# `znap prompt` can autoload our prompt function, because in 04-env.zsh, we
# added its parent dir to our $fpath.
