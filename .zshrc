# History in cache directory:
HISTSIZE=2000
SAVEHIST=2000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

export VISUAL=vim
export EDITOR="$VISUAL"
export ZSH="$HOME/.oh-my-zsh"

# Disable ZSH themes
ZSH_THEME=""

# Add pure theme
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

source ~/antigen.zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle pip
antigen bundle command-not-found
antigen bundle z
antigen bundle colored-man-pages
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

antigen apply
