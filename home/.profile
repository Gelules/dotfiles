# Sourced by the display manager's Xsession (LightDM, GDM) at graphical login. zsh never reads it.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
# Was in .zshrc (only interactive zsh saw it). MANPAGER, not PAGER: man pages stay in colour
# with most, while git, systemctl and journalctl go back to less (most breaks their options).
export EDITOR=vim MANPAGER=most GROFF_NO_SGR=1
# Qt apps follow the GTK theme (plugin ships with qt5-base/qt6-base).
export QT_QPA_PLATFORMTHEME=gtk3
