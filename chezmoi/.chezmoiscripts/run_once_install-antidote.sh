#!/bin/sh
if [ ! -d "~/.antidote" ]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi