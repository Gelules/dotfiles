## Options section
# Auto correct mistakes
setopt correct
# Case insensitive globbing
setopt nocaseglob
# Array expension with parameters
setopt rcexpandparam
# Sort filenames numerically when it makes sense
setopt numericglobsort
# No f*****g beep
setopt nobeep
# Write each command to the history file as soon as it is entered (with its
# timestamp); a command typed with a leading space is not saved
setopt inc_append_history extended_history hist_ignore_space
# If a new command is a duplicate, remove the older one
setopt histignorealldups
# If only a directory path is entered, cd there
setopt autocd

setopt prompt_subst
setopt glob_dots

# LS_COLORS for ls and for the completion list colours below
eval "$(dircolors -b)"

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

autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
# Emacs keymap: needed, zsh would start in vi mode because EDITOR=vim
bindkey -e

# Open command in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

##  bindkeys 
# del, home and end
bindkey '\e[3~' delete-char
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

# ctrl+left and ctrl+right
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word

# ctrl-bs and ctrl-del
bindkey '\e[3;5~' kill-word

# insert, page up and page down
bindkey '\e[2~' overwrite-mode
bindkey '\e[5~' history-beginning-search-backward
bindkey '\e[6~' history-beginning-search-forward

bindkey '^H' backward-kill-word                       # Delete previous word with ctrl+backspace
bindkey '\e[Z' undo                                   # Shift+tab undo last action

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
alias ll='ls -l'
alias se='sudoedit'
alias sizeof='du -sh'

# Functions
mkcd ()
{
    mkdir -p -- "$1" && cd -- "$1"
}

up ()
{
  paru -Syu || return       # repo + AUR in one pass, Arch news first (NewsOnUpgrade, ~/.config/paru/paru.conf).
                            # The cache is trimmed by paccache.timer
  if pacman -Qdtq >/dev/null; then sudo pacman -Rns $(pacman -Qdtq); fi
}

setup ()
{
    setopt local_options err_return   # stop at the first failure (e.g. "n" to paru after reading the news)
    up
    rustup update
    vim -c ':PlugUpgrade' -c ':PlugUpdate' -c ':quitall!'
    fastfetch
}

fuck()
{
  if killall -9 "$2"; then
    echo ; echo " (╯°□°)╯ ~$(echo "$2"|toilet -f term -F rotate)"; echo
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

# Prompt (shell settings, not exported). EDITOR, MANPAGER... are in ~/.profile
# %(?..X) prints X only when the last command failed: its exit code, in red
PROMPT='%(?..%F{196}[%?]%f )%F{207}%n% %F{75}@%F{207}%m% %F{75}[%F{214}%~% %F{75}]%F{75}$%f '
RPROMPT='${vcs_info_msg_0_}'

# Plugins from the official repos (pkglists/base.txt), skipped when not installed
(( $+commands[fzf] )) && eval "$(fzf --zsh)"              # Ctrl-R history, Ctrl-T files, Alt-C dirs
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"    # z <dir>
hl=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # must stay last
[[ -r $hl ]] && source $hl
unset hl
