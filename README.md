# dotfiles
Start of the dotfile journey

# ZSH setup
install zsh
`sudo pacman -S zsh`\
change shell for current user
`chsh -s /bin/zsh`\
install ohmyzsh
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`\
install antigen
`curl -L git.io/antigen > antigen.zsh`\
install pure theme
```cmd
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
```
