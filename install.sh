#!/bin/sh

# The packages I like to use
if [ "$1" = "packages" ]
then
  pacman_packages="arduino
  audacity
  awesome
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
  kile
  libreoffice-fresh
  lightdm
  linux-headers
  ltrace
  make
  most
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
  tree
  valgrind
  unzip
  vim
  vlc
  weechat
  wget
  wireshark-qt
  zathura
  zip
  zsh"

  yaourt_packages="slrn"

  sudo pacman -Syyu
  sudo pacman -S -y $pacman_packages
  
  # yaourt installation
  cd /tmp/
  git clone https://aur.archlinux.org/package-query.git
  cd package-query
  makepkg -si
  cd ..
  git clone https://aur.archlinux.org/yaourt.git
  cd yaourt
  makepkg -si
  cd ..
  yaourt $yaourt_packages

  sudo systemctl enable lightdm
fi

# Simlinks to home via stow
stow git
stow slrn
stow utils
stow vim
stow zsh
stow X

# Awesome needs to be symlinked to ~/.config/awesome
mkdir -p ~/.config/awesome
stow -t  ~/.config/awesome awesome

echo "sh can't source ~/.zshrc so don't forget to do it!"
