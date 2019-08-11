# The following lines were added by compinstall

autoload -U colors && colors

setopt prompt_subst
setopt glob_dots

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' rehash true
zstyle :compinstall filename '/home/jules/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install

# Open command in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# bindkeys 
## del, home and end
bindkey '\e[3~' delete-char
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line


## ctrl+left and ctrl+right
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word

## ctrl-bs and ctrl-del
bindkey '\e[3;5~' kill-word
bindkey '\C-_' backward-kill-word

# VCS Support
autoload -Uz vcs_info

zstyle ':vcs_info:*' actionformats \
    '%F{14}[%F{11}%b%F{11}|%F{9}%a%F{11}]%f'
zstyle ':vcs_info:*' formats \
    '%F{14}[%F{11}%b%F{14}]%f'
zstyle ':vcs_info:*' enable git hg

precmd ()
{
  vcs_info
}

# Aliases
alias ls='ls --color=auto'
alias se='sudoedit'
alias epinews='slrn -f ~/.jnewsrc-epita'
alias valgrindcolor='~/.scripts/valgrind-color.sh'

# Functions
mkcd ()
{
    if [ ! -d "$1" ]
    then
        mkdir $1
    fi
    cd $1
}

up ()
{
  sudo pacman -Syyu $1
  sudo pacmann -Scc $1
}

fuck ()
{
    if [ -n "$2" ]
    then
        echo 'Fuck you' $2
        pkill -9 $2
    fi
}

# Exports
export PROMPT='%F{207}%n% %F{75}@%F{207}%m% %F{75}[%F{214}%~% %F{75}]%F{75}$%f '
export RPROMPT='${vcs_info_msg_0_}'
export PAGER='most'
export NNTPSERVER='news.epita.fr'
export PATH="/sbin:$PATH"
export EDITOR='vim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
