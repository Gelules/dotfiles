# zsh never reads ~/.profile: login shells (TTY, SSH) get the same PATH/env as the X session.
emulate sh -c '. ~/.profile'
