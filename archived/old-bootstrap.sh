#!/bin/bash
# GitHub codespaces setup. This file is run automatically on codespaces startup.
# See https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account

exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

[ $(uname -s) = "Darwin" ] && export MACOS=1
[ $(uname -s) = "Linux" ] && export LINUX=1

if [ $MACOS ]
then
  VSCODE="$HOME/Library/Application Support/Code/User"
elif [ $LINUX ]
then
  VSCODE="$HOME/.config/Code/User"
fi

function link_mac() {
  if [[ ! $(pwd) -ef $HOME ]]; then
    mkdir -p ~/.config/

    ## Git config
    mkdir -p ~/.config/git/
    ln -s $(pwd)/git/ignore ~/.config/git/ignore
    ln -s $(pwd)/git/attributes ~/.config/git/attributes

    rm -f ~/.gitconfig
    ln -s $(pwd)/git/config ~/.gitconfig

    # Fixup VSCode settings path
    mkdir -p "$VSCODE"
    rm -f "$VSCODE/settings.json"
    ln -s $(pwd)/vscode/settings.jsonc "$VSCODE/settings.json"

    # Ruby
    sudo ln -s /Users/robert-crandall/.asdf/shims/rubocop /usr/local/bin/rubocop
  fi
}

function link_ssh() {
  if [[ ! $(pwd) -ef $HOME ]]; then
    mkdir -p ~/.ssh/sockets/
    rm -f ~/.ssh/config
    ln -s $(pwd)/ssh ~/.ssh/config
  fi
}

function link_codespaces() {
  if [[ ! $(pwd) -ef $HOME ]]; then
    sudo ln -s /workspaces/github/bin/rubocop /usr/local/bin/rubocop
    sudo ln -s /workspaces/github/bin/srb /usr/local/bin/srb
    sudo ln -s /workspaces/github/bin/solargraph /usr/local/bin/solargraph
    sudo ln -s /workspaces/github/bin/safe-ruby /usr/local/bin/ruby
  fi
}

function link_zsh() {
  if [[ ! $(pwd) -ef $HOME ]]; then
    rm -f ~/.zshrc
    ln -s $(pwd)/settings/zshrc ~/.zshrc

    rm -f ~/.zshenv
    ln -s $(pwd)/settings/zshenv ~/.zshenv

    mkdir -p ~/.config/
    rm -rf ~/.config/zsh
    ln -s $(pwd)/config/zsh ~/.config/

    rm -f ~/.p10k.zsh
    ln -s $(pwd)/config/zsh/p10k.zsh ~/.p10k.zsh
  fi
}

function link_fish() {
  if [[ ! $(pwd) -ef $HOME ]]; then
    # Create .config if it doesn't exist
    mkdir -p ~/.config

    # Backup any existing fish config if it exists
    if [ -d ~/.config/fish ]; then
      mv ~/.config/fish ~/.config/fish.backup
    fi

    # Create the symlink
    ln -sf $(pwd)/config/fish ~/.config/fish
    ln -sf $(pwd)/config/starship.toml ~/.config/starship.toml
  fi
}

function install_starship() {
  if ! which starship > /dev/null
  then
    if [ $MACOS ]
    then
      brew install --cask finicky
      curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    elif [ $LINUX ]
    then
      curl -sL https://starship.rs/install.sh | sh -s -- -y
    fi
  fi
}

function authorized_keys() {
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh

  curl -s https://api.github.com/users/robert-crandall/keys | \
    jq -r '.[].key' > ~/.ssh/authorized_keys

  # Set correct permissions
  chmod 600 ~/.ssh/authorized_keys
}

if [ $MACOS ]
then
  echo '🔗 Linking Mac files.'
  echo `date +"%Y-%m-%d %T"`
  link_mac
  link_fish
  link_ssh
  authorized_keys
elif [ $LINUX ]
then
  link_fish
  link_ssh
fi

if [ $CODESPACES ]
then
  echo '🔗 Linking Codespaces files.'
  echo `date +"%Y-%m-%d %T"`
  link_codespaces
fi
