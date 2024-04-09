# Dot Files

My installation command for Mac and Codespaces

## Notes

* For Mac, also run Ruby steps from <https://mac.install.guide/rubyonrails/1>
* The ZSH files are largely taken from <https://github.com/marlonrichert/zsh-launchpad>

## Chezmoi

``` zsh
chezmoi init --source ~/repos/dotfiles # Mac only
chezmoi add ~/.zshenv --recursive
chezmoi add ~/.config/fish --recursive
```
