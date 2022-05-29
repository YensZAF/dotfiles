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
# Neovim setup

Check Wayland or X11
`loginctl`    # Check session id\
`loginctl show-session <SESSION_ID> -p Type`\

install xclip (X11) or wl-clipboard (Wayland).

sudo pacman -S neovim xclip
```
mkdir ~/.config/nvim
nvim ~/.config/nvim/init.vim
```
https://github.com/junegunn/vim-plug
yay -S vim-plug

:PlugInstall
:CocInstall coc-json coc-tsserver
