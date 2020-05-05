#!/bin/sh

# The packages I like to use
if [ "$1" = "packages" ]
then
  pacman_packages="
  arduino
  audacity
  awesome
  conky
  ctags
  curl
  doxygen
  fakeroot
  feh
  filezilla
  firefox
  gcc
  gdb
  gimp
  git
  imagemagick
  inkscape
  iw
  kile
  libreoffice-fresh
  lightdm
  lightdm-gtk-greeter
  lightdm-gtk-greeter-settings
  linux-firmware
  linux-headers
  ltrace
  make
  most
  namcap
  network-manager-applet
  nmap
  pandoc
  pkg-config
  openssh
  python
  python-pip
  rxvt-unicode
  stow
  strace
  texlive-most
  thunar
  tree
  ttf-liberation
  ttf-droid
  valgrind
  unzip
  vicious
  vim
  vlc
  volumeicon
  weechat
  wget
  wireshark-qt
  xcompmgr
  xfce4-power-manager
  xfce4-settings
  xtrlock
  zathura
  zip
  zsh"

  yay_packages="
  slrn
  uctags-git
  urxvt-font-size-git"

  sudo pacman -Syyu
  sudo pacman -S -y $pacman_packages

  # yay installation
  cd /tmp/
  git clone https://aur.archlinux.org/package-query.git
  cd package-query
  makepkg -si
  cd ..
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
  yay $yay_packages

  sudo systemctl enable lightdm
fi

# Simlinks to home via stow
stow ctags
stow git
stow slrn
stow utils
stow vim
stow zsh
stow X

# Awesome needs to be symlinked to ~/.config/awesome
mkdir -p ~/.config/awesome
stow -t  ~/.config/awesome awesome

# Set the shell to zsh
chsh -s $(which zsh)
