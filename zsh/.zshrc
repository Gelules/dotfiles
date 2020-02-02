autoload -U colors && colors

## Options section
# Auto correct mistakes
setopt correct
# Extended globbing. Allows using regular expressions with *
setopt extendedglob
# Case insensitive globbing
setopt nocaseglob
# Array expension with parameters
setopt rcexpandparam
# Warn about running processes when exiting
setopt checkjobs
# Sort filenames numerically when it makes sense
setopt numericglobsort
# No f*****g beep
setopt nobeep
# Immediately append history instead of overwriting
setopt appendhistory
# If a new command is a duplicate, remove the older one
setopt histignorealldups
# If only a directory path is entered, cd there
setopt autocd

setopt prompt_subst
setopt glob_dots

# Case insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache 

zstyle :compinstall filename '/home/jules/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# Open command in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

##  bindkeys 
bindkey -e
# del, home and end
bindkey '\e[3~' delete-char
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

# ctrl+left and ctrl+right
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word

# ctrl-bs and ctrl-del
bindkey '\e[3;5~' kill-word
bindkey '\C-_' backward-kill-word

# More control
bindkey '[[7~' beggining-of-line                      # Home key
bindkey '[[8~' end-of-line                            # End key
bindkey '[[2~' overwrite-mode                         # Insert key
bindkey '[[C'  forward-char                           # Right key
bindkey '[[D'  backward-char                          # Left key
bindkey '[[5~' history-beggining-search-backward      # Page up key
bindkey '[[6~' history-beggining-search-forward       # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[0c' forward-word
bindkey '^[0d' backward-word
bindkey '^H' backward-kill-word                       # Delete previous word with ctrl+backspace
bindkey '^Z' forward-word                             # Shift+tab undo last action

# VCS Support
autoload -Uz vcs_info

zstyle ':vcs_info:*' actionformats \
    '%F{14}[%F{11}%b%F{11}|%F{9}%a%F{11}]%f'
zstyle ':vcs_info:*' formats \
    '%F{14}[%F{11}%b%F{14}]%f'
zstyle ':vcs_info:*' enable git

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
  sudo pacman -Syyu
  sudo pacman -Scc
}

fuck ()
{
    if [ -n "$2" ]
    then
        echo 'Fuck you' $2
        pkill -9 $2
    fi
}

blackscreen ()
{
  if [ "$1" = "off" ]
  then
    xset -dpms
    xset s off
  else
    xset +dpms
    xset s on
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
